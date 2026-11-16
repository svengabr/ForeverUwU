-- The crit counter on screen: a small box with this session's crits and the
-- character's total, switched on in the options ("counter") and dragged
-- anywhere with the left mouse button. Its spot is kept as an offset from the
-- screen center (counterX / counterY).

local _, ns = ...;

local FONT = "Interface\\AddOns\\ForeverUwU\\fonts\\MochiyPopOne-Regular.ttf";
local PINK = { 1, 0.49, 0.76 };
local PAD = 10;

local counter;

local function Place(f)
	f:ClearAllPoints();
	f:SetPoint("CENTER", UIParent, "CENTER", ns.db.counterX, ns.db.counterY);
end

local function Create()
	local f = CreateFrame("Frame", nil, UIParent);
	f:SetFrameStrata("MEDIUM");
	f:SetClampedToScreen(true);
	f:SetMovable(true);
	f:EnableMouse(true);
	f:RegisterForDrag("LeftButton");

	local bg = f:CreateTexture(nil, "BACKGROUND");
	bg:SetAllPoints();
	bg:SetColorTexture(0, 0, 0, 0.45);

	f.main = f:CreateFontString(nil, "OVERLAY");
	f.main:SetFont(FONT, 18, "OUTLINE");
	f.main:SetTextColor(PINK[1], PINK[2], PINK[3]);
	f.main:SetPoint("TOP", 0, -6);

	f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
	f.sub:SetPoint("TOP", f.main, "BOTTOM", 0, -2);

	f:SetScript("OnDragStart", f.StartMoving);
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing();
		-- The box has no scale of its own, so UIParent's coordinates fit.
		local x, y = self:GetCenter();
		local cx, cy = UIParent:GetCenter();
		ns.db.counterX = math.floor(x - cx + 0.5);
		ns.db.counterY = math.floor(y - cy + 0.5);
		Place(self);
	end);
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText("Crit counter", 1, 1, 1);
		GameTooltip:AddLine("Drag it where you like. Switch it off or reset it under /uwu.", nil, nil, nil, true);
		GameTooltip:Show();
	end);
	f:SetScript("OnLeave", GameTooltip_Hide);
	return f;
end

-- Shows, hides and fills the box; runs on login, on every crit and when the
-- option changes.
function ns.UpdateCounter()
	if not ns.db or not ns.db.counter then
		if counter then
			counter:Hide();
		end
		return;
	end
	if not counter then
		counter = Create();
		Place(counter);
	end
	local session, total, _, best = ns.CritCounts();
	counter.main:SetText(ns.FormatCount(session) .. (session == 1 and " crit" or " crits"));
	counter.sub:SetText(ns.FormatCount(total) .. " total" .. (best and ", best " .. ns.FormatCount(best) or ""));
	counter:SetSize(math.max(counter.main:GetStringWidth(), counter.sub:GetStringWidth()) + 2 * PAD,
		counter.main:GetStringHeight() + counter.sub:GetStringHeight() + 14);
	counter:Show();
end
