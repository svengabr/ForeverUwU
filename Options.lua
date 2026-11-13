-- The options window ("/uwu"): a movable window of its own with two tabs,
-- "General" (switches, volume, cooldowns, floating text) and "Sounds" (every
-- clip of the chosen pack with a checkbox to switch it off and a button to
-- hear it). The game's own Options > AddOns page only holds a button that
-- opens it. Everything else comes from ForeverUwU.lua through ns.

local _, ns = ...;

local WIDTH, HEIGHT = 520, 640;
local ROW = 24;
local GOLD = { 1, 0.82, 0 };

local window;

-- widgets ------------------------------------------------------------------

local function Text(parent, template, text)
	local label = parent:CreateFontString(nil, "ARTWORK", template or "GameFontHighlightSmall");
	label:SetJustifyH("LEFT");
	if text then
		label:SetText(text);
	end
	return label;
end

local function Tooltip(frame, title, text)
	if not text then
		return;
	end
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(title, 1, 1, 1);
		GameTooltip:AddLine(text, nil, nil, nil, true);
		GameTooltip:Show();
	end);
	frame:HookScript("OnLeave", GameTooltip_Hide);
end

local function Button(parent, text, width, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
	button:SetSize(width, 22);
	button:SetText(text);
	button:SetScript("OnClick", onClick);
	return button;
end

-- A gold heading with a thin rule under it.
local function Heading(parent, text, y)
	local label = Text(parent, "GameFontNormal", text);
	label:SetPoint("TOPLEFT", 4, y);
	local rule = parent:CreateTexture(nil, "ARTWORK");
	rule:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.25);
	rule:SetHeight(1);
	rule:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3);
	rule:SetPoint("RIGHT", parent, "RIGHT", -4, 0);
	return y - 26;
end

-- A checkbox bound to db[key]; onChange runs after the value changed.
local function Check(parent, key, label, tip, y, onChange)
	local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate");
	check:SetSize(24, 24);
	check:SetPoint("TOPLEFT", 8, y);
	check.Label = Text(parent, "GameFontHighlight", label);
	check.Label:SetPoint("LEFT", check, "RIGHT", 2, 0);
	check:SetScript("OnClick", function(self)
		ns.db[key] = self:GetChecked() and true or false;
		if onChange then
			onChange();
		end
	end);
	Tooltip(check, label, tip);
	function check:Refresh()
		self:SetChecked(ns.db[key]);
	end
	return check, y - ROW - 2;
end

-- A slider bound to db[key], in the game's own slider art, value on the right.
local function Slider(parent, key, label, tip, low, high, step, format, y)
	local caption = Text(parent, "GameFontHighlight", label);
	caption:SetPoint("TOPLEFT", 14, y - 4);
	local slider = CreateFrame("Slider", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil);
	slider:SetSize(200, 17);
	slider:SetPoint("TOPLEFT", 230, y - 2);
	slider:SetOrientation("HORIZONTAL");
	slider:SetMinMaxValues(low, high);
	slider:SetValueStep(step);
	slider:SetObeyStepOnDrag(true);
	slider:EnableMouse(true);
	if slider.SetBackdrop then
		slider:SetBackdrop({
			bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
			edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
			tile = true, tileSize = 8, edgeSize = 8,
			insets = { left = 3, right = 3, top = 6, bottom = 6 },
		});
	end
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal");
	local value = Text(parent, "GameFontHighlightSmall");
	value:SetPoint("LEFT", slider, "RIGHT", 10, 0);
	local function Snap(v)
		return math.max(low, math.min(high, math.floor(v / step + 0.5) * step));
	end
	slider:SetScript("OnValueChanged", function(self, v)
		v = Snap(v);
		value:SetText(format:format(v));
		if not self.setting then
			ns.db[key] = v;
		end
	end);
	Tooltip(slider, label, tip);
	function slider:Refresh()
		self.setting = true;
		self:SetValue(ns.db[key]);
		value:SetText(format:format(ns.db[key]));
		self.setting = nil;
	end
	return slider, y - ROW - 6;
end

-- General ------------------------------------------------------------------

local function BuildGeneral(panel)
	local controls = {};
	local function Add(control, y)
		controls[#controls + 1] = control;
		return y;
	end
	local y = -4;
	y = Heading(panel, "Forever UwU", y);
	y = Add(Check(panel, "enabled", "Enable Forever UwU", "Switches all sounds on or off.", y, ns.UpdateEvents));
	y = Add(Slider(panel, "volume", "Volume",
		"Volume of the uwus, on top of the game's master volume. The clips are already leveled so none is much louder than the others.",
		ns.VOLUME_STEP, 100, ns.VOLUME_STEP, "%d %%", y));

	-- Only worth a choice when a second pack is installed.
	local installed = {};
	for _, pack in ipairs(ns.PACKS) do
		if ns.HasSounds(pack.id) then
			installed[#installed + 1] = pack;
		end
	end
	if #installed > 1 then
		local caption = Text(panel, "GameFontHighlight", "Sound pack");
		caption:SetPoint("TOPLEFT", 14, y - 4);
		local buttons = {};
		local group = { Refresh = function()
			for _, button in ipairs(buttons) do
				local on = button.pack == ns.db.pack;
				button:SetEnabled(not on);
				button:GetFontString():SetTextColor(1, on and 1 or GOLD[2], on and 1 or GOLD[3]);
			end
		end };
		for i, pack in ipairs(installed) do
			local button = Button(panel, pack.label, 96, function()
				ns.SetPack(pack.id);
				group.Refresh();
			end);
			button.pack = pack.id;
			button:SetPoint("TOPLEFT", 230 + (i - 1) * 100, y - 1);
			Tooltip(button, pack.label, pack.id == "uwu" and "Anime uwus, owos and ara aras."
				or "The hit marker tick of old shooters, and a sniper shot when you get hit hard.");
			buttons[i] = button;
		end
		controls[#controls + 1] = group;
		y = y - ROW - 6;
	end
	local test = Button(panel, "Play uwu", 96, function()
		ns.Play("crit");
	end);
	test:SetPoint("TOPLEFT", 230, y - 1);
	Tooltip(test, "Play uwu", "Plays one uwu at the volume above, with the floating text.");
	local hurtTest = Button(panel, "Play ouch", 96, function()
		ns.Play("hurt");
	end);
	hurtTest:SetPoint("LEFT", test, "RIGHT", 4, 0);
	Tooltip(hurtTest, "Play ouch", "Plays one angry uwu, with the floating text.");
	y = y - ROW - 14;

	y = Heading(panel, "When you crit", y);
	y = Add(Check(panel, "crit", "UwU on my crits", "Plays a random uwu when you land a critical hit or heal.", y));
	y = Add(Check(panel, "small", "Small uwus in between",
		"When crits come faster than the cooldown below, plays short quiet uwus instead of nothing.", y));
	y = Add(Slider(panel, "critCooldown", "Seconds between full uwus",
		"A full uwu plays at most this often; crits in between get a small uwu.", 0, 5, 0.25, "%.2f s", y));
	y = y - 8;

	y = Heading(panel, "When you get hit hard", y);
	y = Add(Check(panel, "hurt", "Angry uwu when I get hit hard",
		"Plays an angry uwu or an ara ara when you take a critical hit or a big hit.", y));
	y = Add(Slider(panel, "hurtPercent", "Big hit threshold",
		"A single hit that takes at least this share of your maximum health counts as big. In combat the game hides hit amounts, so there only crits count.",
		5, 100, 5, "%d %%", y));
	y = Add(Slider(panel, "hurtCooldown", "Seconds between angry uwus",
		"An angry uwu plays at most this often.", 0, 10, 0.5, "%.1f s", y));
	y = y - 8;

	y = Heading(panel, "Floating text", y);
	y = Add(Check(panel, "bubbles", "Floating uwu text",
		"Shows a floating uwu over your character with every sound. Only you see it.", y));
	y = Add(Slider(panel, "bubbleX", "Position: sideways",
		"Distance of the text from the middle of the screen, where your character stands. Use the test buttons to check.",
		-600, 600, 10, "%d", y));
	Add(Slider(panel, "bubbleY", "Position: height",
		"Height of the text above the middle of the screen. Use the test buttons to check.", -400, 500, 10, "%d", y));

	function panel.Refresh()
		for _, control in ipairs(controls) do
			control:Refresh();
		end
	end
end

-- Sounds -------------------------------------------------------------------

local POOLS = {
	{ kind = "crit", label = "UwU", tip = "The full uwu on a crit." },
	{ kind = "small", label = "Small", tip = "The short quiet uwu when crits come faster than the cooldown." },
	{ kind = "hurt", label = "Ouch", tip = "The angry uwu or ara ara when you get hit hard." },
};

-- "sounds\%d\crit\cute-uwu-73482.ogg" -> "cute uwu";
-- "sounds\%d\crit\kawaiii-vvDVZA_Ui24_06.ogg" -> "kawaiii" (YouTube id and cut number)
local function ClipName(path)
	local name = path:match("([^\\]+)%.ogg$") or path;
	name = name:gsub("%-" .. ("[%w_%-]"):rep(11) .. "_%d+$", "");
	name = name:gsub("%-%d%d%d+$", "");
	return (name:gsub("%-", " "));
end

local function BuildSounds(panel)
	local kind = "crit";
	local rows, clips = {}, {};

	local tabs = {};
	for i, pool in ipairs(POOLS) do
		local button = Button(panel, pool.label, 96, function()
			kind = pool.kind;
			panel:Refresh();
		end);
		button:SetPoint("TOPLEFT", 4 + (i - 1) * 100, -2);
		button.kind = pool.kind;
		Tooltip(button, pool.label, pool.tip);
		tabs[i] = button;
	end

	local count = Text(panel, "GameFontNormal");
	count:SetPoint("TOPLEFT", 8, -34);

	local function SetAll(muted)
		for _, clip in ipairs(clips) do
			ns.SetMuted(kind, clip.path, muted);
		end
		panel:Refresh();
	end
	local allOff = Button(panel, "All off", 80, function()
		SetAll(true);
	end);
	allOff:SetPoint("TOPRIGHT", -4, -30);
	local allOn = Button(panel, "All on", 80, function()
		SetAll(false);
	end);
	allOn:SetPoint("RIGHT", allOff, "LEFT", -4, 0);

	local hint = Text(panel, "GameFontDisableSmall",
		"Untick a clip to keep it from playing. Click the arrow to hear it.");
	hint:SetPoint("TOPLEFT", 8, -56);

	local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate");
	scroll:SetPoint("TOPLEFT", 0, -74);
	scroll:SetPoint("BOTTOMRIGHT", -26, 0);
	local content = CreateFrame("Frame", nil, scroll);
	content:SetSize(WIDTH - 60, 1);
	scroll:SetScrollChild(content);

	local function Row(i)
		local row = CreateFrame("Frame", nil, content);
		row:SetHeight(ROW);
		row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW);
		row:SetPoint("RIGHT", content, "RIGHT");
		if i % 2 == 0 then
			local stripe = row:CreateTexture(nil, "BACKGROUND");
			stripe:SetAllPoints();
			stripe:SetColorTexture(1, 1, 1, 0.04);
		end
		row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
		row.check:SetSize(24, 24);
		row.check:SetPoint("LEFT", 4, 0);
		row.check:SetScript("OnClick", function(self)
			ns.SetMuted(kind, row.path, not self:GetChecked());
			panel:Refresh();
		end);
		row.play = CreateFrame("Button", nil, row);
		row.play:SetSize(20, 20);
		row.play:SetPoint("LEFT", row.check, "RIGHT", 4, 0);
		-- The spellbook's page arrow: a play symbol every client has.
		row.play:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
		row.play:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
		row.play:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
		row.play:SetScript("OnClick", function()
			ns.PlayPath(kind, row.path);
		end);
		row.label = Text(row, "GameFontHighlight");
		row.label:SetPoint("LEFT", row.play, "RIGHT", 6, 0);
		row.label:SetPoint("RIGHT", row, "RIGHT", -6, 0);
		row.label:SetWordWrap(false);
		rows[i] = row;
		return row;
	end

	function panel.Refresh()
		for _, button in ipairs(tabs) do
			local on = button.kind == kind;
			button:SetEnabled(not on);
			button:GetFontString():SetTextColor(1, on and 1 or GOLD[2], on and 1 or GOLD[3]);
		end
		clips = ns.Clips(kind);
		local on = 0;
		for i, clip in ipairs(clips) do
			local row = rows[i] or Row(i);
			row.path = clip.path;
			local muted = ns.db.muted[clip.path];
			if not muted then
				on = on + 1;
			end
			row.check:SetChecked(not muted);
			local label = ClipName(clip.path);
			if clip.set ~= "public" then
				label = label .. " |cff808080(" .. clip.set .. ")|r";
			end
			row.label:SetText(label);
			row.label:SetAlpha(muted and 0.45 or 1);
			row:Show();
		end
		for i = #clips + 1, #rows do
			rows[i]:Hide();
		end
		content:SetHeight(math.max(1, #clips * ROW));
		count:SetText(("%d of %d clips on"):format(on, #clips));
		allOn:SetEnabled(on < #clips);
		allOff:SetEnabled(on > 0);
	end
end

-- window -------------------------------------------------------------------

local function SelectTab(key)
	window.selected = key;
	for _, tab in ipairs(window.tabs) do
		local on = tab.key == key;
		if PanelTemplates_SelectTab and tab.isTopTab then
			if on then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		else
			tab:SetEnabled(not on);
		end
		window.panels[tab.key]:SetShown(on);
	end
	window.panels[key]:Refresh();
end

local function Build()
	window = CreateFrame("Frame", "ForeverUwUOptions", UIParent, "ButtonFrameTemplate");
	window:Hide();
	window:SetSize(WIDTH, HEIGHT);
	window:SetPoint("CENTER");
	window:SetFrameStrata("DIALOG");
	window:SetToplevel(true);
	window:EnableMouse(true);
	window:SetMovable(true);
	window:SetClampedToScreen(true);
	window:RegisterForDrag("LeftButton");
	window:SetScript("OnDragStart", window.StartMoving);
	window:SetScript("OnDragStop", window.StopMovingOrSizing);
	-- Escape closes it.
	tinsert(UISpecialFrames, "ForeverUwUOptions");

	if ButtonFrameTemplate_HidePortrait then
		ButtonFrameTemplate_HidePortrait(window);
	end
	if ButtonFrameTemplate_HideButtonBar then
		ButtonFrameTemplate_HideButtonBar(window);
	end
	if window.Inset then
		window.Inset:Hide();
	end
	if window.SetTitle then
		window:SetTitle("Forever UwU");
	elseif window.TitleText then
		window.TitleText:SetText("Forever UwU");
	end

	local body = CreateFrame("Frame", nil, window);
	body:SetPoint("TOPLEFT", 14, -62);
	body:SetPoint("BOTTOMRIGHT", -12, 12);

	window.panels, window.tabs = {}, {};
	for i, def in ipairs({
		{ key = "general", label = "General", build = BuildGeneral },
		{ key = "sounds", label = "Sounds", build = BuildSounds },
	}) do
		local panel = CreateFrame("Frame", nil, body);
		panel:SetAllPoints();
		panel:Hide();
		def.build(panel);
		window.panels[def.key] = panel;

		-- The client's own top tabs, plain buttons where it lacks the template.
		local ok, tab = pcall(CreateFrame, "Button", "ForeverUwUOptionsTab" .. i, window, "PanelTopTabButtonTemplate");
		if ok and tab then
			tab.isTopTab = true;
			tab:SetID(i);
			tab:SetText(def.label);
			if PanelTemplates_TabResize then
				PanelTemplates_TabResize(tab, 15, nil, 70);
			end
		else
			tab = Button(window, def.label, 90);
		end
		tab.key = def.key;
		tab:SetScript("OnClick", function(self)
			SelectTab(self.key);
		end);
		if i == 1 then
			tab:SetPoint("BOTTOMLEFT", window, "TOPLEFT", 12, -54);
		else
			tab:SetPoint("BOTTOMLEFT", window.tabs[i - 1], "BOTTOMRIGHT", 4, 0);
		end
		window.tabs[i] = tab;
	end

	window:SetScript("OnShow", function(self)
		SelectTab(self.selected or "general");
	end);
end

-- Opens the window, on a given tab ("general", "sounds") or the one shown last;
-- closes it when it is already open on that tab.
function ns.ToggleOptions(key)
	if not window then
		Build();
	end
	if window:IsShown() and (not key or key == window.selected) then
		window:Hide();
		return;
	end
	window.selected = key or window.selected;
	window:Show();
	SelectTab(window.selected or "general");
end

-- The game's Options > AddOns > Forever UwU page: a button to the window.
function ns.RegisterOptionsStub()
	local panel = CreateFrame("Frame");
	local title = Text(panel, "GameFontHighlightHuge", "Forever UwU");
	title:SetPoint("TOPLEFT", 7, -22);
	local about = Text(panel, "GameFontHighlight",
		"Forever UwU has a window of its own for its options and sounds. Type /uwu to open it.");
	about:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12);
	about:SetPoint("RIGHT", -20, 0);
	-- The window opens on top (DIALOG strata); closing Blizzard's panel from
	-- addon code could taint it.
	local open = Button(panel, "Open Forever UwU", 160, function()
		ns.ToggleOptions("general");
	end);
	open:SetPoint("TOPLEFT", about, "BOTTOMLEFT", 0, -12);
	local category = Settings.RegisterCanvasLayoutCategory(panel, "Forever UwU");
	Settings.RegisterAddOnCategory(category);
	return category;
end
