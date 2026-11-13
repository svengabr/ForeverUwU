-- luacheck config: every WoW global the addon touches must be listed here,
-- so a typo or an accidental global fails CI instead of erroring in the client.
std = "lua51"
max_line_length = false
exclude_files = { ".luacheckrc" }

globals = {
  "ForeverUwUDB",
  "SLASH_FOREVERUWU1",
  "SlashCmdList",
}

read_globals = {
  "BackdropTemplateMixin",
  "ButtonFrameTemplate_HideButtonBar",
  "ButtonFrameTemplate_HidePortrait",
  "C_Timer",
  "CreateFrame",
  "GameTooltip",
  "GameTooltip_Hide",
  "GetTime",
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
