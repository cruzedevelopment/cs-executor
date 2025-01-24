local function ClearHeadshots()
  for i = 1, 32 do
      if IsPedheadshotValid(i) then UnregisterPedheadshot(i) end
  end
end

RegisterNUICallback("getMugshot", function(_, cb)
  ClearHeadshots()
  local ped = PlayerPedId()
  local mugshot = RegisterPedheadshot(ped)
  
  CreateThread(function()
      local timeout = GetGameTimer() + 5000
      while not IsPedheadshotReady(mugshot) do
          if GetGameTimer() >= timeout then
              cb({ url = '/api/placeholder/48/48' })
              return
          end
          Wait(100)
      end
      
      local txd = GetPedheadshotTxdString(mugshot)
      local url = string.format("https://nui-img/%s/%s", txd, txd)
      
      SendNUIMessage({
          action = "mugshotReady",
          data = { url = url }
      })
      
      cb({ url = url })
      Wait(1000)
      UnregisterPedheadshot(mugshot)
  end)
end)

RegisterNUICallback("executeCode", function(data, cb)
  if not data.code then
      cb({ success = false, output = "No code provided" })
      return
  end

  local wrapped_code = [[
      local output = ""
      local old_print = print
      
      print = function(...)
          local args = {...}
          local str = ""
          for i,v in ipairs(args) do
              str = str .. tostring(v) .. "\t"
          end
          str = str:gsub("\t$", "") -- Remove trailing tab
          
          SendNUIMessage({
              action = "printOutput",
              data = { text = str }
          })
          
          output = output .. str .. "\n"
          old_print(...)
      end
      
      ]] .. data.code .. [[
      
      return output
  ]]

  local func, err = load(wrapped_code)
  if not func then
      cb({ success = false, output = "Syntax error: " .. tostring(err) })
      return
  end

  local success, result = pcall(func)
  cb({ success = success, output = result or "Code executed successfully" })
end)

RegisterNUICallback("hideFrame", function(_, cb)
  SetNuiFocus(false, false)
  cb({})
end)

local keybind = lib.addKeybind({
  name = 'cs-executor',
  description = 'Cruze Executor',
  defaultKey = Config.defaultKey,
  onPressed = function(self)
    local success = lib.callback.await('cs-executor:server:isAdmin')
    if success then
      SetNuiFocus(true, true)
      SendNUIMessage({ action = "toggleUI" })
    end
  end,
})