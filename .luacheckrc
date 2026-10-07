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
  "C_Timer",
  "CreateSettingsButtonInitializer",
  "CreateFrame",
  "GetTime",
  "MinimalSliderWithSteppersMixin",
  "PlaySoundFile",
  "Settings",
  "UIParent",
  "UnitAffectingCombat",
  "UnitHealthMax",
  "UnitExists",
  "UnitIsDead",
  "strlower",
  "strtrim",
  "strupper",
  "unpack",
}
