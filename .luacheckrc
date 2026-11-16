-- luacheck config: every WoW global the addon touches must be listed here,
-- so a typo or an accidental global fails CI instead of erroring in the client.
std = "lua51"
max_line_length = false
exclude_files = { ".luacheckrc" }

globals = {
  "ForeverUwUDB",
  "SLASH_FOREVERUWU1",
  "SlashCmdList",
  "StaticPopupDialogs",
}

read_globals = {
  "GetRealmName",
  "NO",
  "StaticPopup_Show",
  "UnitName",
  "YES",
  "BackdropTemplateMixin",
  "ButtonFrameTemplate_HideButtonBar",
  "ButtonFrameTemplate_HidePortrait",
  "C_Timer",
  "CreateFrame",
  "GameTooltip",
  "GameTooltip_Hide",
  "GetTime",
  "IsInGroup",
  "IsInRaid",
  "issecretvalue",
  "PanelTemplates_DeselectTab",
  "PanelTemplates_SelectTab",
  "PanelTemplates_TabResize",
  "PlaySoundFile",
  "tinsert",
  "UISpecialFrames",
  "Settings",
  "UIParent",
  "UnitCanAttack",
  "UnitHealthMax",
  "UnitExists",
  "UnitIsDead",
  "UnitIsTapDenied",
  "strfind",
  "strlower",
  "strtrim",
  "strupper",
  "unpack",
}
