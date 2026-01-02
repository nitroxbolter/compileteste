-- Fishing System Server Module
-- Handles fishing operations on the server side

-- Configuration
local Config = {
  -- Opcode for communication with client
  OpCode = 103,
  
  -- Item IDs
  Items = {
    Worm = 3976,   -- ID of fishing worm bait item
    Fish = 2667   -- ID of fish item that player receives when successful
  }
}

-- Register login event
local LoginEvent = CreatureEvent("FishingLogin")

-- Handle player login
function LoginEvent.onLogin(player)
  -- Register extended opcode event
  player:registerEvent("FishingExtended")
 -- print("Player " .. player:getName() .. " registered for fishing events")
  return true
end

-- Register extended opcode event
local ExtendedEvent = CreatureEvent("FishingExtended")

-- Handle extended opcode messages from client
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  -- Check if this is our opcode
  if opcode ~= Config.OpCode then
    return true
  end
  
  -- Parse the message
  local status, data = pcall(function()
    return json.decode(buffer)
  end)
  
  -- Handle json parsing errors
  if not status or not data then
    print("Fishing JSON parse error")
    return true
  end
  
  -- Print debug info
  print("Fishing action received: " .. (data.action or "unknown"))
  
  -- Handle the fish action
  if data.action == "fish" then
    handleFishing(player, data.success)
  end
  
  return true
end

-- Handle fishing result
function handleFishing(player, success)
  if not player then 
    print("Fishing: Player not found")
    return 
  end
  
  -- Debug info
  print("Fishing attempt by: " .. player:getName() .. ", Success: " .. tostring(success))
  
  -- Check if player has worms as bait
  if not player:removeItem(Config.Items.Worm, 1) then
    -- Player doesn't have worms
    sendResult(player, false, "You don't have any worms for fishing!")
    return
  end
  
  -- Process fishing result
  if success then
    -- Player succeeded - give a fish
    player:addItem(Config.Items.Fish, 1)
    sendResult(player, true, "You caught a fish!")
    player:sendTextMessage(MESSAGE_STATUS, "You caught a fish!")
  else
    -- Player failed - worm is lost
    sendResult(player, false, "The fish got away with your worm!")
    player:sendTextMessage(MESSAGE_STATUS, "The fish got away with your worm!")
  end
end

-- Send result to client
function sendResult(player, success, message)
  if not player then 
    print("Fishing: Cannot send result, player not found")
    return 
  end
  
  -- Debug message
  print("Sending fishing result to " .. player:getName() .. ": " .. message)
  
  -- Send result data to client
  local data = json.encode({
    action = "result",
    success = success,
    message = message
  })
  
  player:sendExtendedOpcode(Config.OpCode, data)
end

-- Register the script
LoginEvent:register()
ExtendedEvent:register() 