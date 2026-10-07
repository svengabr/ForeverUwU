-- Floating uwu text over the character: pops up with every sound, floats up a
-- little and fades out, like the game's crit numbers. Addons can't read where
-- the character stands on screen, but the default camera keeps it in the
-- middle, so the text sits at an adjustable offset from the screen center.

local _, ns = ...;

local MEDIA = "Interface\\AddOns\\ForeverUwU\\";
-- Mochiy Pop One (SIL OFL 1.1, fonts/OFL.txt), cut down to Latin characters.
local FONT = MEDIA .. "fonts\\MochiyPopOne-Regular.ttf";
local FONT_SIZE = 40;
local LIFETIME = 1.7;
local POP = 0.22;
local FADE = 0.5;
local RISE = 40;
local MAX_POPUPS = 6;

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

local function OnUpdate(self, elapsed)
	self.age = self.age + elapsed;
	local age = self.age;
	if age >= LIFETIME then
		self:Hide();
		return;
	end
	local style = self.style;
	local scale = style.scale * PopScale(age);
	local fade = age > LIFETIME - FADE and (LIFETIME - age) / FADE or 1;
	self:SetScale(scale);
	self:SetAlpha(style.alpha * math.min(1, age / 0.08) * fade);
	-- Offsets are in the frame's own scale, so undo it to keep the spot fixed.
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", self.x / scale, (self.y + RISE * age / LIFETIME) / scale);
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
	f.text:SetShadowOffset(0, -3);
	f.text:SetPoint("CENTER");

	f.heart = f:CreateTexture(nil, "OVERLAY");
	f.heart:SetTexture(MEDIA .. "textures\\heart");
	f.heart:SetSize(30, 30);
	f.heart:SetPoint("LEFT", f.text, "RIGHT", 6, 10);

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

function ns.ShowBubble(kind, x, y)
	local texts, style = TEXTS[kind], STYLES[kind];
	if not texts then
		return;
	end
	local f = Acquire();
	f.style = style;
	f.age = 0;
	f.x, f.y = x, y;
	-- Small uwus scatter so several in a row don't stack on one spot.
	if kind == "small" then
		f.x = x + math.random(-110, 110);
		f.y = y + math.random(-40, 60);
	end
	f.text:SetText(texts[math.random(#texts)]);
	f.text:SetTextColor(unpack(style.text));
	f.heart:SetShown(style.heart == true);
	f.heart:SetVertexColor(unpack(style.text));
	OnUpdate(f, 0);
	f:Show();
end
