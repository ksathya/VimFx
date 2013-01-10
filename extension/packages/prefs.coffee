{ classes: Cc, interfaces: Ci } = Components

PREF_BRANCH = "extensions.VimFx.";

# Default values for the preference
# All used preferences should be mentioned here becuase 
# preference type is derived from here
DEFAULT_PREF_VALUES = 
  addon_id:     'VimFx@akhodakivskiy.github.com'
  hint_chars:   'asdfgercvhjkl;uinm'
  disabled:     false
  scroll_step:  60
  scroll_time:  100
  black_list:   '*mail.google.com*'
  blur_on_esc:  true

getPref = do ->
  branch = Services.prefs.getBranch PREF_BRANCH
  
  return (key, defaultValue=undefined) ->
    type = branch.getPrefType(key)

    switch type
      when branch.PREF_BOOL
        return branch.getBoolPref key
      when branch.PREF_INT
        return branch.getIntPref key
      when branch.PREF_STRING
        return branch.getCharPref key
      else
        if defaultValue != undefined
          return defaultValue
        else
          return DEFAULT_PREF_VALUES[key];

# Assign and save Firefox preference value
setPref = do ->
  branch = Services.prefs.getBranch PREF_BRANCH

  return (key, value) ->
    switch typeof value
      when 'boolean'
        branch.setBoolPref(key, value)
      when 'number'
        branch.setIntPref(key, value)
      when 'string'
        branch.setCharPref(key, value);
      else
        branch.clearUserPref(key);


DISABLED_COMMANDS = do ->
  str = getPref 'disabled_commands'
  try
    return JSON.parse str
  catch err
    dc = []
    for key in str.split('||')
      for c in key.split('|')
        dc.push c if c

    return dc

# Enables command
enableCommand = (key) ->
  for c in key.split('|')
    while (idx = DISABLED_COMMANDS.indexOf(c)) > -1
      DISABLED_COMMANDS.splice(idx, 1)

  setPref 'disabled_commands', JSON.stringify DISABLED_COMMANDS

# Adds command to the disabled list
disableCommand = (key) ->
  for c in key.split('|')
    if DISABLED_COMMANDS.indexOf(c) == -1
      DISABLED_COMMANDS.push c

  setPref 'disabled_commands', JSON.stringify DISABLED_COMMANDS

# Checks if given command is disabled in the preferences
isCommandDisabled = (key) ->
  for c in key.split('|')
    if DISABLED_COMMANDS.indexOf(c) > -1
      return true

  return false

exports.getPref                   = getPref
exports.setPref                   = setPref
exports.isCommandDisabled         = isCommandDisabled
exports.disableCommand            = disableCommand
exports.enableCommand             = enableCommand
