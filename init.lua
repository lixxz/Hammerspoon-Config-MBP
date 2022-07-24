-- Shift to left
hs.hotkey.bind({"cmd", "ctrl"}, "h", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- Shift to right
hs.hotkey.bind({"cmd", "ctrl"}, "l", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- Shift to bottom
hs.hotkey.bind({"cmd", "ctrl"}, "k", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)


-- Shift to top
hs.hotkey.bind({"cmd", "ctrl"}, "j", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)


-- Toggle fullscreen
-- hs.hotkey.bind({"cmd", "shift"}, "m", function()
--    local win = hs.window.focusedWindow()

-- )

-- Focus/launch firefox
-- hs.hotkey.bind("cmd", "space", "b", function()
--   hs.application.launchOrFocus("Firefox")
-- end)


-- -- Focus/launch VS Code
-- hs.hotkey.bind("cmd", "space", function()
--   hs.application.launchOrFocus("Firefox")
-- end)

-----


-- key to break out of every layer and back to normal
escapeKey = {keyNone, 'escape'}
-- generate a string representation of a key spec
-- {{'shift', 'command'}, 'a} -> 'shift+command+a'
local function createKeyName(key)
  -- key is in the form {{modifers}, key, (optional) name}
  -- create proper key name for helper
  if #key[1] == 1 and key[1][1] == 'shift' then
     -- shift + key map to Uppercase key
     -- shift + d --> D
     return keyboardUpper(key[2])
  else
     -- append each modifiers together
     local keyName = ''
     if #key[1] >= 1 then
        for count = 1, #key[1] do
           if count == 1 then
              keyName = key[1][count]
           else 
              keyName = keyName..' + '..key[1][count]
           end
        end
     end
     -- finally append key, e.g. 'f', after modifers
     return keyName..key[2]
  end
end

-- show helper of available keys of current layer
local function showHelper(keyFuncNameTable)
  -- keyFuncNameTable is a table that key is key name and value is description
  local helper = ''
  local separator = '' -- first loop doesn't need to add a separator, because it is in the very front. 
  local lastLine = ''
  for keyName, funcName in pairs(keyFuncNameTable) do
     -- only measure the length of current line
     lastLine = string.match(helper, '\n.-$')
     if lastLine and string.len(lastLine) > recursiveBindHelperMaxLineLengthInChar then
        separator = '\n'
     elseif not lastLine then
        separator = '\n'
     end
     helper = helper..separator..keyName..' → '..funcName
     separator = '   '
  end
  helper = string.match(helper, '[^\n].+$')
  -- bottom of screen, lasts for 3 sec, no border
  previousHelperID = hs.alert.show(helper, recursiveBindHelperFormat, true)
end
  

-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function


-- the actual binding function
function recursiveBind(keymap)
  if type(keymap) == 'function' then
     -- in this case "keymap" is actuall a function
     return keymap
  end
  local modal = hs.hotkey.modal.new()
  local keyFuncNameTable = {}
  for key, map in pairs(keymap) do
     local func = recursiveBind(map)
     -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f' 
     modal:bind(key[1], key[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) func() end)
     modal:bind(escapeKey[1], escapeKey[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) end)
     if #key >= 3 then
        keyFuncNameTable[createKeyName(key)] = key[3]
     end
  end
  return function()
     modal:enter()
     if showHelper then
        showHelper(keyFuncNameTable)
     end
  end
end

-- this function is used by helper to display 
-- appropriate 'shift + key' bindings
-- it turns a lower key to the corresponding
-- upper key on keyboard
function keyboardUpper(key)
  local upperTable = {
   a='A', 
   b='B', 
   c='C', 
   d='D', 
   e='E', 
   f='F', 
   g='G', 
   h='H', 
   i='I', 
   j='J', 
   k='K', 
   l='L', 
   m='M', 
   n='N', 
   o='O', 
   p='P', 
   q='Q', 
   r='R', 
   s='S', 
   t='T', 
   u='U', 
   v='V', 
   w='W', 
   x='X', 
   y='Y', 
   z='Z', 
   ['`']='~',
   ['1']='!',
   ['2']='@',
   ['3']='#',
   ['4']='$',
   ['5']='%',
   ['6']='^',
   ['7']='&',
   ['8']='*',
   ['9']='(',
   ['0']=')',
   ['-']='_',
   ['=']='+',
   ['[']='}',
   [']']='}',
   ['\\']='|',
   [';']=':',
   ['\'']='"',
   [',']='<',
   ['.']='>',
   ['/']='?'
  }
  uppperKey = upperTable[key]
  if uppperKey then
     return uppperKey
  else
     return key
  end
end

function singleKey(key, name)
  local mod = {}
  if key == keyboardUpper(key) then
     mod = {'shift'}
     key = string.lower(key)
  end

  if name then
     return {mod, key, name}
  else
     return {mod, key, 'no name'}
  end
end


-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function

mymapWithName = {
  [singleKey('b', 'firefox')] = function() hs.application.launchOrFocus("Firefox") end,
  [singleKey('[', 'vscode')] = function() hs.application.launchOrFocus("Visual Studio Code") end,
  [singleKey(']', 'alacritty')] = function() hs.application.launchOrFocus("Alacritty") end,
  [singleKey('s', 'spotify')] = function() hs.application.get("Spotify"):activate() end,
  [singleKey('n', 'notes')] = function() hs.application.launchOrFocus("Notes") end,
  -- [singleKey('d', 'notes')] = function() hs.window.desktop():focus() end
  [singleKey('m', 'mail')] = function() hs.application.launchOrFocus("Mail") end,
  [singleKey('i', 'preview')] = function() hs.application.launchOrFocus("Preview") end,
  [singleKey('h', 'hammerspoon')] = function() hs.application.launchOrFocus("Hammerspoon") end,
  [singleKey('g', 'goodnotes')] = function() hs.application.launchOrFocus("GoodNotes") end,
}

hs.hotkey.bind('cmd', 'space', nil, recursiveBind(mymapWithName))


-- switching code
---
--- Modified version of dmg hammerspoon
--- credit to the original author below

local obj={}
obj.__index = obj

-- things to configure

obj.rowsToDisplay = 14 -- how many rows to display in the chooser


-- -- for debugging purposes
-- function obj:print_table(t, f)
--    for i,v in ipairs(t) do
--       print(i, f(v))
--    end
-- end
-- 
-- -- for debugging purposes
-- 
-- function obj:print_windows()
--    function w_info(w)
--       return w:title() .. w:application():name()
--    end
--    obj:print_table(hs.window.visibleWindows(), w_info)
-- end

theWindows = hs.window.filter.new()
theWindows:setDefaultFilter{}
theWindows:setSortOrder(hs.window.filter.sortByFocusedLast)
obj.currentWindows = {}
obj.previousSelection = nil  -- the idea is that one switches back and forth between two windows all the time


-- Start by saving all windows

for i,v in ipairs(theWindows:getWindows()) do
   table.insert(obj.currentWindows, v)
end

function obj:find_window_by_title(t)
   -- find a window by title. 
   for i,v in ipairs(obj.currentWindows) do
      if string.find(v:title(), t) then
         return v
      end
   end
   return nil
end

function obj:focus_by_title(t)
   -- focus the window with given title
   if not t then
      hs.alert.show("No string provided to focus_by_title")
      return nil
   end
   w = obj:find_window_by_title(t)
   if w then
      w:focus()
   end
   return w
end

function obj:focus_by_app(appName)
   -- find a window with that application name and jump to it
--   print(' [' .. appName ..']')
   for i,v in ipairs(obj.currentWindows) do
--      print('           [' .. v:application():name() .. ']')
      if string.find(v:application():name(), appName) then
--         print("Focusing window" .. v:title())
         v:focus()
         return v
      end
   end
   return nil
end


-- the hammerspoon tracking of windows seems to be broken
-- we do it ourselves

local function callback_window_created(w, appName, event)

   if event == "windowDestroyed" then
--      print("deleting from windows-----------------", w)
      if w then
--         print("destroying window" .. w:title())
      end
      for i,v in ipairs(obj.currentWindows) do
         if v == w then
            table.remove(obj.currentWindows, i)
            return
         end
      end
--      print("Not found .................. ", w)
--      obj:print_table0(obj.currentWindows)
--      print("Not found ............ :()", w)
      return
   end
   if event == "windowCreated" then
      if w then
         -- print("creating window " .. w:title())
      end
--      print("inserting into windows.........", w)
      table.insert(obj.currentWindows, 1, w)
      return
   end
   if event == "windowFocused" then
      --otherwise is equivalent to delete and then create
      if w then
--         print("Focusing window" .. w:title())
      end
      callback_window_created(w, appName, "windowDestroyed")
      callback_window_created(w, appName, "windowCreated")
--      obj:print_table0(obj.currentWindows)
   end
end
theWindows:subscribe(hs.window.filter.windowCreated, callback_window_created)
theWindows:subscribe(hs.window.filter.windowDestroyed, callback_window_created)
theWindows:subscribe(hs.window.filter.windowFocused, callback_window_created)


function obj:list_window_choices(onlyCurrentApp)
   local windowChoices = {}
   local currentWin = hs.window.focusedWindow()
   local currentApp = currentWin:application()
   -- print("\nstarting to populate")
   -- print(currentApp)
   for i,w in ipairs(obj.currentWindows) do
      if w ~= currentWin then
         local app = w:application()
         local appImage = nil
         local appName  = '(none)'
         if app then
            appName = app:name()
            appImage = hs.image.imageFromAppBundle(w:application():bundleID())
         end
         -- print(appName, currentApp)
         if (not onlyCurrentApp) or (app == currentApp) then
            -- print("inserting...")
            table.insert(windowChoices, {
                            text = w:title() .. "--" .. appName,
                            subText = appName,
                            uuid = i,
                            image = appImage,
                            win=w})
         end
      end
   end
   return windowChoices;
end

function obj:switchWindow(onlyCurrentApp)
  local windowChoices = obj:list_window_choices(onlyCurrentApp)
     if #windowChoices == 0 then
        if onlyCurrentApp then
           hs.alert.show("no other window for this application ")
        else
           hs.alert.show("no other window available ")
        end
        return
     end
     local c =#windowChoices
     local v = windowChoices[c]["win"]
          if v then
             v:focus()
           end
end

function obj:previousWindow()
   return obj.currentWindows[2]
end

-- select any other window
hs.hotkey.bind({"alt"}, "b", function()
      obj:selectWindow(false)
end)

-- select any window for the same application
hs.hotkey.bind({"alt"}, "`", function()
      obj:switchWindow(true)
end)

-- function switcherfunc()
--     return obj:switchWindow(true)
-- end

return obj
