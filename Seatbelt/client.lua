--- "Wollffus" ---

local isUiOpen = false 
local speedBuffer  = {}
local velBuffer    = {}
local beltOn       = false
local wasInCar     = false

function Notify(string)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(string)
  DrawNotification(false, true)
end

AddEventHandler('seatbelt:sounds', function(soundFile, soundVolume)
  SendNUIMessage({
    transactionType     = 'playSound',
    transactionFile     = soundFile,
    transactionVolume   = soundVolume
  })
end)

function IsCar(veh)
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end
 
Citizen.CreateThread(function()
	while true do
	Citizen.Wait(0)
  
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(ped)

    if car ~= 0 and (wasInCar or IsCar(car)) then
      wasInCar = true
          if isUiOpen == false and not IsPlayerDead(PlayerId()) then
            if Config.Blinker then
              SendNUIMessage({displayWindow = 'true'})
            end
              isUiOpen = true
          end

      if beltOn then 
        DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
        DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
	    end

      speedBuffer[2] = speedBuffer[1]
      speedBuffer[1] = GetEntitySpeed(car)

      if not beltOn and speedBuffer[2] ~= nil and GetEntitySpeedVector(car, true).y > 1.0 and speedBuffer[1] > (Config.Speed / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
        local co = GetEntityCoords(ped)
        local fw = Fwv(ped)
        SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
        Citizen.Wait(1)
        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
      end
        
      velBuffer[2] = velBuffer[1]
      velBuffer[1] = GetEntityVelocity(car)
        
      if IsControlJustReleased(0, Config.Control) and GetLastInputMethod(0) then
          beltOn = not beltOn 
          if beltOn then
          Citizen.Wait(1)

        if Config.Sounds then  
        TriggerEvent("seatbelt:sounds", "buckle", Config.Volume)
        end
        if Config.Notification then
        Notify(Config.Strings.seatbelt_on)
        end
        
        if Config.Blinker then
        SendNUIMessage({displayWindow = 'false'})
        end
        isUiOpen = true 
      else 
        if Config.Notification then
        Notify(Config.Strings.seatbelt_off)
        end

        if Config.Sounds then
        TriggerEvent("seatbelt:sounds", "unbuckle", Config.Volume)
        end

        if Config.Blinker then
        SendNUIMessage({displayWindow = 'true'})
        end
        isUiOpen = true  
      end
    end
      
    elseif wasInCar then
      wasInCar = false
      beltOn = false
      speedBuffer[1], speedBuffer[2] = 0.0, 0.0
          if isUiOpen == true and not IsPlayerDead(PlayerId()) then
            if Config.Blinker then
            SendNUIMessage({displayWindow = 'false'})
            end
            isUiOpen = false 
          end
    end
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if (IsPlayerDead(PlayerId()) and isUiOpen == true) or IsPauseMenuActive() then
			SendNUIMessage({displayWindow = 'false'})
			isUiOpen = false
		end    
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3500)
    if not beltOn and wasInCar and not IsPauseMenuActive() and Config.LoopSound then
      TriggerEvent("seatbelt:sounds", "seatbelt", Config.Volume)
		end    
	end
end)

RegisterCommand("hood", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 4) > 0 then
          SetVehicleDoorShut(veh, 4, false)
      else
          SetVehicleDoorOpen(veh, 4, false, false)
      end
  end
end, false)

RegisterCommand("trunk", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 5) > 0 then
          SetVehicleDoorShut(veh, 5, false)
      else
          SetVehicleDoorOpen(veh, 5, false, false)
      end
  end
end, false)

RegisterCommand("trunk2", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 6) > 0 then
          SetVehicleDoorShut(veh, 6, false)
      else
          SetVehicleDoorOpen(veh, 6, false, false)
      end
  end
end, false)

RegisterCommand("frontleftdoor", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 0) > 0 then
          SetVehicleDoorShut(veh, 0, false)
      else
          SetVehicleDoorOpen(veh, 0, false, false)
      end
  end
end, false)

RegisterCommand("frontrightdoor", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 1) > 0 then
          SetVehicleDoorShut(veh, 1, false)
      else
          SetVehicleDoorOpen(veh, 1, false, false)
      end
  end
end, false)

RegisterCommand("backleftdoor", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 2) > 0 then
          SetVehicleDoorShut(veh, 2, false)
      else
          SetVehicleDoorOpen(veh, 2, false, false)
      end
  end
end, false)

RegisterCommand("backrightdoor", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
      if GetVehicleDoorAngleRatio(veh, 3) > 0 then
          SetVehicleDoorShut(veh, 3, false)
      else
          SetVehicleDoorOpen(veh, 3, false, false)
      end
  end
end, false)

RegisterCommand("neon", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
  --left
      if isOn then
          SetVehicleNeonLightEnabled(veh, 0, false)
          SetVehicleNeonLightEnabled(veh, 1, false)
          SetVehicleNeonLightEnabled(veh, 2, false)
          SetVehicleNeonLightEnabled(veh, 3, false)
    
    isOn = false
      else
          SetVehicleNeonLightEnabled(veh, 0, true)
          SetVehicleNeonLightEnabled(veh, 1, true)
          SetVehicleNeonLightEnabled(veh, 2, true)
          SetVehicleNeonLightEnabled(veh, 3, true)
    
    isOn = true
      end
  end
end, false)

RegisterCommand("neonleft", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
  --left
      if IsVehicleNeonLightEnabled(veh, 0) then
          SetVehicleNeonLightEnabled(veh, 0, false)
      else
          SetVehicleNeonLightEnabled(veh, 0, true)
    
    isOn = true
      end
  end
end, false)

RegisterCommand("neonright", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
  --right
      if IsVehicleNeonLightEnabled(veh, 1) then
          SetVehicleNeonLightEnabled(veh, 1, false)
      else
          SetVehicleNeonLightEnabled(veh, 1, true)
    
    isOn = true
      end
  end
end, false)

RegisterCommand("neonfront", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
  --front
      if IsVehicleNeonLightEnabled(veh, 2) then
          SetVehicleNeonLightEnabled(veh, 2, false)
      else
          SetVehicleNeonLightEnabled(veh, 2, true)
    
    isOn = true
      end
  end
end, false)

RegisterCommand("neonback", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= nil and veh ~= 0 and veh ~= 1 then
  --back
      if IsVehicleNeonLightEnabled(veh, 3) then
          SetVehicleNeonLightEnabled(veh, 3, false)
      else
          SetVehicleNeonLightEnabled(veh, 3, true)
    
    isOn = true
      end
  end
end, false)

Citizen.CreateThread(function()
TriggerEvent('chat:addSuggestion', "/neon", "turn neons on/off or try /neonfront etc")
end)