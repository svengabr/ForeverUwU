-- Floating uwu text over the character: pops up with every sound, floats up a
-- little and fades out, like the game's crit numbers. Addons can't read where
-- the character stands on screen, but the default camera keeps it in the
-- middle, so the text sits at an adjustable offset from the screen center.

local _, ns = ...;

local MEDIA = "Interface\\AddOns\\ForeverUwU\\";
-- Mochiy Pop One (SIL OFL 1.1, fonts/OFL.txt), cut down to Latin characters.
local FONT = MEDIA .. "fonts\\MochiyPopOne-Regular.ttf";
local FONT_SIZE = 30;
local LIFETIME = 1.7;
local POP = 0.22;
local FADE = 0.5;
local RISE = 40;
local MAX_POPUPS = 6;
local COUNT_SIZE = 16;

local TEXTS = {
	crit = { "uwu~", "UwU", "owo~", "nya~", "uwu!", "^w^" },
	small = { "uwu", "owo", "uwu~", "nya" },
	hurt = { "ara ara~", "kyaa!", "itai!", "b-baka!", "UwU!!", "hmph!" },
};

-- Text color, overall scale and alpha per kind.
local STYLES = {
	crit = { text = { 1, 0.49, 0.76 }, scale = 1, alpha = 1, heart = true },
	small = { text = { 1, 0.62, 0.84 }, scale = 0.55, alpha = 0.75 },
	hurt = { text = { 1, 0.35, 0.29 }, scale = 1, alpha = 1 },
};

-- Sound packs other than the uwu one bring their own look. A style with an
-- icon shows that texture instead of a text; lifetime and rise override the
-- floating of the uwu text. The hitmarker flashes in place like the one in
-- the shooters it comes from: white on a hit, red when the player is hit.
local PACK_STYLES = {
	hitmarker = {
		crit = { text = { 1, 1, 1 }, scale = 1, alpha = 1, icon = "hitmarker", lifetime = 0.45, rise = 0 },
		small = { text = { 1, 1, 1 }, scale = 0.6, alpha = 0.8, icon = "hitmarker", lifetime = 0.35, rise = 0 },
		hurt = { text = { 1, 0.2, 0.15 }, scale = 1.2, alpha = 1, icon = "hitmarker", lifetime = 0.6, rise = 0 },
	},
	-- Montage parody captions: loud green on a crit, red when the player is hit.
	mlg = {
		crit = {
			text = { 0.4, 1, 0.2 }, scale = 1, alpha = 1,
			texts = { "WOW", "360 NO SCOPE", "OH BABY", "WOMBO COMBO", "MLG", "+100", "GET REKT", "DAMN SON",
				"HEADSHOT", "TRIPLE KILL", "GODLIKE", "RAMPAGE" },
		},
		small = { text = { 1, 0.9, 0.2 }, scale = 0.55, alpha = 0.8, texts = { "+10", "MLG", "wow", "dank", "+1" } },
		hurt = {
			text = { 1, 0.25, 0.2 }, scale = 1.1, alpha = 1,
			texts = { "REKT", "OOF", "WASTED", "BRUH", "2SAD4ME", "GG", "GAME OVER", "SLAIN" },
		},
	},
};
local ICON_FADE = 0.2;

-- The look of a kind in a pack, shared with the options preview.
function ns.BubbleStyle(pack, kind)
	return (PACK_STYLES[pack] or STYLES)[kind];
end
ns.BUBBLE_MEDIA = MEDIA;
ns.BUBBLE_FONT = FONT;
ns.BUBBLE_FONT_SIZE = FONT_SIZE;

local popups = {};

-- Pops past full size and settles back: 0.5 -> 1.25 -> 1.
local function PopScale(age)
	if age >= POP then
		return 1;
	end
	local t = age / POP;
	if t < 0.5 then
		return 0.5 + 0.75 * (t / 0.5);
	end
	return 1.25 - 0.25 * ((t - 0.5) / 0.5);
end
ns.PopScale = PopScale;

local function OnUpdate(self, elapsed)
	self.age = self.age + elapsed;
	local age = self.age;
	local style = self.style;
	local lifetime = self.lifetime or style.lifetime or LIFETIME;
	if age >= lifetime then
		self:Hide();
		return;
	end
	local fadeTime = self.showsIcon and ICON_FADE or FADE;
	local scale = style.scale * self.boost * PopScale(age);
	local fade = age > lifetime - fadeTime and (lifetime - age) / fadeTime or 1;
	self:SetScale(scale);
	self:SetAlpha(style.alpha * math.min(1, age / 0.08) * fade);
	-- Offsets are in the frame's own scale, so undo it to keep the spot fixed.
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", self.x / scale, (self.y + (self.lifetime and RISE or style.rise or RISE) * age / lifetime) / scale);
end

local function CreatePopup()
	local f = CreateFrame("Frame", nil, UIParent);
	-- Above the options panel, so the test button shows where the text sits.
	f:SetFrameStrata("FULLSCREEN_DIALOG");
	f:SetSize(300, 80);
	f:Hide();

	f.text = f:CreateFontString(nil, "OVERLAY");
	f.text:SetFont(FONT, FONT_SIZE, "THICKOUTLINE");
	f.text:SetShadowColor(0.23, 0.03, 0.13, 1);
	f.text:SetShadowOffset(0, -2);
	f.text:SetPoint("CENTER");

	f.heart = f:CreateTexture(nil, "OVERLAY");
	f.heart:SetTexture(MEDIA .. "textures\\heart");
	f.heart:SetSize(23, 23);
	f.heart:SetPoint("LEFT", f.text, "RIGHT", 5, 8);

	f.icon = f:CreateTexture(nil, "OVERLAY");
	f.icon:SetSize(64, 64);
	f.icon:SetPoint("CENTER");

	f.count = f:CreateFontString(nil, "OVERLAY");
	f.count:SetFont(FONT, COUNT_SIZE, "OUTLINE");
	f.count:SetShadowColor(0, 0, 0, 1);
	f.count:SetShadowOffset(0, -2);

	f:SetScript("OnUpdate", OnUpdate);
	return f;
end

-- A free popup, or the oldest one when all are in use.
local function Acquire()
	local oldest;
	for _, f in ipairs(popups) do
		if not f:IsShown() then
			return f;
		end
		if not oldest or f.age > oldest.age then
			oldest = f;
		end
	end
	if #popups < MAX_POPUPS then
		local f = CreatePopup();
		popups[#popups + 1] = f;
		return f;
	end
	return oldest;
end

-- The clip's own caption (Captions.lua), else a random text of the pool.
local function Caption(texts, pack, path)
	local captions = ns.CAPTIONS and ns.CAPTIONS[pack];
	local name = captions and path and path:match("([^\\/]+)%.ogg$");
	return name and captions[name] or texts[math.random(#texts)];
end

-- count, if given, shows as "#4,210" under the text or icon; path is the
-- clip that plays, to pick its caption. text replaces the caption (and shows
-- even in a pack with an icon), scale makes the popup bigger.
function ns.ShowBubble(kind, x, y, pack, count, path, text, scale)
	local style = ns.BubbleStyle(pack, kind);
	local texts = style and style.texts or TEXTS[kind];
	if not texts or not style then
		return;
	end
	local f = Acquire();
	f.style = style;
	f.boost = scale or 1;
	local icon = not text and style.icon;
	f.age = 0;
	f.x, f.y = x, y;
	-- Small uwus scatter so several in a row don't stack on one spot.
	if kind == "small" then
		f.x = x + math.random(-110, 110);
		f.y = y + math.random(-40, 60);
	end
	-- A big popup stays up longer and floats like the uwu text.
	f.lifetime = scale and scale > 1 and LIFETIME * 1.5 or nil;
	f.showsIcon = icon and true or false;
	f.text:SetShown(not icon);
	f.icon:SetShown(icon and true or false);
	if icon then
		f.icon:SetTexture(MEDIA .. "textures\\" .. icon);
		f.icon:SetVertexColor(unpack(style.text));
	else
		f.text:SetText(text or Caption(texts, pack or "uwu", path));
		f.text:SetTextColor(unpack(style.text));
	end
	f.heart:SetShown(style.heart == true);
	f.heart:SetVertexColor(unpack(style.text));
	f.count:SetShown(count ~= nil);
	if count then
		f.count:ClearAllPoints();
		f.count:SetPoint("TOP", icon and f.icon or f.text, "BOTTOM", 0, -2);
		f.count:SetText("#" .. ns.FormatCount(count));
		f.count:SetTextColor(unpack(style.text));
	end
	OnUpdate(f, 0);
	f:Show();
end
