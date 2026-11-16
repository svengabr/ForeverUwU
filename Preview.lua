-- The live preview in the General tab of the options: a small box that shows
-- what the addon puts on screen (the floating crit text, the count under it,
-- a small uwu, the hurt text, the milestone popup and the counter box), in
-- the chosen pack's look and with the current settings. Switched-off parts
-- stay visible, faded with an "off", so players see the feature exists.
-- Hovering an option pops its part.

local _, ns = ...;

local WIDTH, HEIGHT = 160, 300;
local OFF_ALPHA = 0.25;
local DIM = 0.5;
local POP = 0.22;
-- Parts sit a little left of center to leave room for the "off" tags.
local SHIFT = -12;

-- Sample texts per pack; a pack that isn't listed uses the uwu ones.
local SAMPLES = {
	uwu = { crit = "uwu~", small = "uwu", hurt = "kyaa!" },
	mlg = { crit = "DAMN SON", small = "+10", hurt = "OOF" },
};

-- Each part: the option it shows, the options it also needs to show in game,
-- its height in the box (center, from the top) and its font size.
local PARTS = {
	{ key = "bubbles", needs = { "crit" }, y = -54, size = 22, kind = "crit", icon = 40 },
	{ key = "bubbleCount", needs = { "crit", "bubbles" }, y = -82, size = 12, kind = "crit" },
	{ key = "small", needs = { "crit", "bubbles" }, y = -112, size = 14, kind = "small", icon = 24 },
	{ key = "hurt", needs = { "bubbles" }, y = -148, size = 20, kind = "hurt", icon = 40 },
	{ key = "milestones", needs = { "crit", "bubbles" }, y = -190, size = 15, kind = "crit" },
	-- Its "off" tag goes under the box, so it can use the full width.
	{ key = "counter", needs = {}, y = -246, shift = 0 },
};
-- Widest a text may get at rest; the pop grows it by a quarter.
local MAX_TEXT = 110;

local function SetPartPoint(preview, part, scale)
	part:ClearAllPoints();
	-- Offsets are in the part's own scale, so undo it to keep the spot fixed.
	part:SetPoint("CENTER", preview, "TOP", (part.def.shift or SHIFT) / scale, part.def.y / scale);
end

-- Sets the font size, then shrinks it until the text fits maxWidth.
local function FitFont(text, font, size, flags, maxWidth)
	text:SetFont(font, size, flags);
	local width = text:GetStringWidth();
	if width > maxWidth then
		text:SetFont(font, math.max(8, math.floor(size * maxWidth / width)), flags);
	end
end

local function CreateText(part, size)
	local text = part:CreateFontString(nil, "OVERLAY");
	text:SetFont(ns.BUBBLE_FONT, size, "OUTLINE");
	text:SetShadowColor(0, 0, 0, 1);
	text:SetShadowOffset(0, -1);
	text:SetPoint("CENTER");
	return text;
end

local function CreatePart(preview, def)
	local part = CreateFrame("Frame", nil, preview);
	part.def = def;
	part:SetSize(WIDTH, 30);
	SetPartPoint(preview, part, 1);
	if def.key == "counter" then
		part.bg = part:CreateTexture(nil, "BACKGROUND");
		part.bg:SetAllPoints();
		part.bg:SetColorTexture(0, 0, 0, 0.6);
		part.main = CreateText(part, 14);
		part.main:ClearAllPoints();
		part.main:SetPoint("TOP", 0, -5);
		part.sub = part:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		part.sub:SetPoint("TOP", part.main, "BOTTOM", 0, -2);
		part.subFont = { part.sub:GetFont() };
	else
		part.text = CreateText(part, def.size);
		if def.icon then
			part.icon = part:CreateTexture(nil, "OVERLAY");
			part.icon:SetSize(def.icon, def.icon);
			part.icon:SetPoint("CENTER");
		end
		if def.key == "bubbles" then
			part.heart = part:CreateTexture(nil, "OVERLAY");
			part.heart:SetTexture(ns.BUBBLE_MEDIA .. "textures\\heart");
			part.heart:SetSize(16, 16);
			part.heart:SetPoint("LEFT", part.text, "RIGHT", 3, 6);
		end
	end
	-- The "off" tag sits at the right edge of the box, not on the part, so it
	-- doesn't fade or pop with it.
	part.off = preview:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
	part.off:SetText("off");
	-- The counter box is wide, so its tag goes under it.
	part.off:SetPoint("RIGHT", preview, "TOPRIGHT", -6, def.key == "counter" and def.y - 30 or def.y);
	return part;
end

-- Fills a part from the pack's style and the current counts.
local function Fill(part, pack)
	local def = part.def;
	if def.key == "counter" then
		local session, total, _, best = ns.CritCounts();
		-- Big counts shrink the font so the box stays inside the preview.
		local inner = WIDTH - 24;
		part.main:SetText(ns.FormatCount(session) .. (session == 1 and " crit" or " crits"));
		FitFont(part.main, ns.BUBBLE_FONT, 14, "OUTLINE", inner);
		part.main:SetTextColor(1, 0.49, 0.76);
		part.sub:SetText(ns.FormatCount(total) .. " total" .. (best and ", best " .. ns.FormatCount(best) or ""));
		local font, size, flags = unpack(part.subFont);
		FitFont(part.sub, font, size, flags, inner);
		local width = math.max(part.main:GetStringWidth(), part.sub:GetStringWidth()) + 16;
		part:SetSize(width, part.main:GetStringHeight() + part.sub:GetStringHeight() + 12);
		part.styleAlpha = 1;
		return;
	end
	-- Unlike ShowBubble, a pack style without this kind falls back to the uwu
	-- look instead of showing nothing; every shipped pack has all three kinds.
	local style = ns.BubbleStyle(pack, def.kind) or ns.BubbleStyle("uwu", def.kind);
	local samples = SAMPLES[pack] or SAMPLES.uwu;
	local text;
	if def.key == "bubbleCount" then
		text = "#" .. ns.FormatCount(128);
	elseif def.key == "milestones" then
		text = ns.FormatCount(1000) .. " CRITS!";
	else
		text = samples[def.kind];
	end
	-- A pack with an icon shows it in place of the text, like in game; the
	-- count and the milestone stay text there too.
	local icon = part.icon and style.icon;
	part.text:SetShown(not icon);
	if part.icon then
		part.icon:SetShown(icon and true or false);
		if icon then
			part.icon:SetTexture(ns.BUBBLE_MEDIA .. "textures\\" .. icon);
			part.icon:SetVertexColor(unpack(style.text));
		end
	end
	part.text:SetText(text);
	-- Wide samples ("DAMN SON") shrink so the pop stays inside the box; the
	-- heart needs room too.
	FitFont(part.text, ns.BUBBLE_FONT, def.size, "OUTLINE", part.heart and MAX_TEXT - 20 or MAX_TEXT);
	part.text:SetTextColor(unpack(style.text));
	if part.heart then
		part.heart:SetShown(style.heart == true and not icon);
		part.heart:SetVertexColor(unpack(style.text));
	end
	part.styleAlpha = style.alpha or 1;
end

local function IsShownInGame(def)
	if not ns.db[def.key] then
		return false;
	end
	for _, need in ipairs(def.needs) do
		if not ns.db[need] then
			return false;
		end
	end
	return true;
end

local function ApplyAlphas(preview)
	for key, part in pairs(preview.parts) do
		local alpha = part.baseAlpha or 1;
		if preview.highlight then
			alpha = key == preview.highlight and part.styleAlpha or alpha * DIM;
		end
		part:SetAlpha(alpha);
	end
end

local function OnUpdate(preview, elapsed)
	local part = preview.parts[preview.highlight];
	if not part then
		preview:SetScript("OnUpdate", nil);
		return;
	end
	preview.popAge = preview.popAge + elapsed;
	local scale = ns.PopScale(preview.popAge);
	part:SetScale(scale);
	SetPartPoint(preview, part, scale);
	if preview.popAge >= POP then
		preview:SetScript("OnUpdate", nil);
	end
end

-- The box, unanchored; Options.lua places it.
function ns.CreatePreview(parent)
	local preview = CreateFrame("Frame", nil, parent);
	preview:SetSize(WIDTH, HEIGHT);

	local bg = preview:CreateTexture(nil, "BACKGROUND");
	bg:SetAllPoints();
	bg:SetColorTexture(0, 0, 0, 0.45);

	local caption = preview:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	caption:SetPoint("TOPLEFT", 6, -6);
	caption:SetText("Preview");

	preview.parts = {};
	for _, def in ipairs(PARTS) do
		preview.parts[def.key] = CreatePart(preview, def);
	end

	function preview:Refresh()
		local db = ns.db;
		if not db then
			return;
		end
		for _, part in pairs(self.parts) do
			Fill(part, db.pack);
			part.baseAlpha = IsShownInGame(part.def) and part.styleAlpha or OFF_ALPHA;
			part.off:SetShown(not db[part.def.key]);
		end
		self:SetAlpha(db.enabled and 1 or 0.4);
		ApplyAlphas(self);
	end

	-- Pops the part of the hovered option (one of the PARTS keys) and dims
	-- the others; nil puts everything back.
	function preview:Highlight(key)
		local old = self.parts[self.highlight];
		if old then
			old:SetScale(1);
			SetPartPoint(self, old, 1);
		end
		self.highlight = self.parts[key] and key or nil;
		ApplyAlphas(self);
		if self.highlight then
			self.popAge = 0;
			self:SetScript("OnUpdate", OnUpdate);
		end
	end

	return preview;
end
