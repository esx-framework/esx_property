Core.Modules.CCTV = {}

--- Open CCTV
--- @param propertyId integer
function Core.Modules.CCTV:OpenCCTV(propertyId)
    local property = Core.Properties[propertyId]
    assert(property, 'Property '..propertyId..' not found')
    if not property.cctv.enabled then return ESX.ShowNotification('CCTV is turned off!') end
    DoScreenFadeOut(500)
    while IsScreenFadingIn() do
        Wait(50)
    end
    ESX.CloseContext()
    ESX.TriggerServerCallback('esx_property:cctv', function(cctvReady)
        if not cctvReady then
            DoScreenFadeIn(100)
            ESX.ShowNotification('CCTV Error')
            return
        end
        Core.Modules.CCTV.inCCTV = true
        ClearFocus()
        local playerPed, nightVision, pictureCooldown = ESX.PlayerData.ped, false, false
        local cctvCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", vector3(property.Entrance.x, property.Entrance.y, property.Entrance.z + Config.CCTV.HeightAboveDoor), 0, 0, 0, Config.CCTV.FOV)
        SetCamRot(cctvCamera, property.cctv.rot.x, property.cctv.rot.y, property.cctv.rot.z, 2)
        SetCamActive(cctvCamera, true)
        SetTimecycleModifier("scanline_cam_cheap")
        TriggerServerEvent("p_instance:s:leave")
        DisableAllControlActions(0)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, true)
        SetEntityVisible(playerPed, false)
        SetTimecycleModifierStrength(2.0)
        SetFocusArea(property.Entrance.x, property.Entrance.y, property.Entrance.z, 0.0, 0.0, 0.0)
        PointCamAtCoord(cctvCamera, vector3(property.Entrance.x, property.Entrance.y, property.Entrance.z + Config.CCTV.HeightAboveDoor))
        RenderScriptCams(true, false, 1, true, false)
        Wait(1000)
        DoScreenFadeIn(500)
        RequestAmbientAudioBank("Phone_Soundset_Franklin", 0, 0)
        RequestAmbientAudioBank("HintCamSounds", 0, 0)

        while IsCamActive(cctvCamera) do
            Wait(5)
            DisableAllControlActions(0)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 246, true)
            EnableControlAction(0, 249, true)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(19)
            HideHudAndRadarThisFrame()
  
            local instructions = Core.Utils:CreateInstuctionScaleform('instructional_buttons')
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)

            local getCameraRot = GetCamRot(cctvCamera, 2)
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Left) and getCameraRot.z < property.cctv.maxleft then
              PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
              SetCamRot(cctvCamera, getCameraRot.x, 0.0, getCameraRot.z + Config.CCTV.RotateSpeed, 2)
            end
            -- ROTATE RIGHT
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Right) and getCameraRot.z > property.cctv.maxright then
              PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
              SetCamRot(cctvCamera, getCameraRot.x, 0.0, getCameraRot.z - Config.CCTV.RotateSpeed, 2)
            end
  
            -- ROTATE UP
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Up) and getCameraRot.x < Config.CCTV.MaxUpRotation then
              PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
              SetCamRot(cctvCamera, getCameraRot.x + Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
            end
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
              PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
              SetCamRot(cctvCamera, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
            end
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomIn) and GetCamFov(cctvCamera) > Config.CCTV.MaxZoom then
              SetCamFov(cctvCamera, GetCamFov(cctvCamera) - 1.0)
            end
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomOut) and GetCamFov(cctvCamera) < Config.CCTV.MinZoom then
              SetCamFov(cctvCamera, GetCamFov(cctvCamera) + 1.0)
            end
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
              PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
              SetCamRot(cctvCamera, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
            end
  
            SetTextFont(4)
            SetTextScale(0.8, 0.8)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0.1, 3, 27, 27, 255)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(property.setName ~= "" and property.setName or property.Name)
            EndTextCommandDisplayText(0.01, 0.01)
  
            SetTextFont(4)
            SetTextScale(0.7, 0.7)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0.1, 3, 27, 27, 255)
            BeginTextCommandDisplayText('STRING')
            local yr, mo, da, hr, min, sec = GetPosixTime()
            AddTextComponentSubstringPlayerName("" .. da .. "/" .. mo .. "/" .. yr .. " " .. hr .. ":" .. min .. ":" .. sec)
            EndTextCommandDisplayText(0.01, 0.055)
  
            SetTextFont(4)
            SetTextScale(0.6, 0.6)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0.1, 3, 27, 27, 255)
            BeginTextCommandDisplayText('STRING')
            local zoom = ((Config.CCTV.FOV - GetCamFov(cctvCamera)) / GetCamFov(cctvCamera)) * 100
            AddTextComponentSubstringPlayerName(TranslateCap("zoom_level", math.floor(zoom)))
            EndTextCommandDisplayText(0.01, 0.09)
  
            SetTextFont(4)
            SetTextScale(0.6, 0.6)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0.1, 3, 27, 27, 255)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(nightVision and "Night Vision: Active" or "CCTV System: Active")
            EndTextCommandDisplayText(0.01, 0.12)
  
            if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
                PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)
                SetCamRot(cctvCamera, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
            end

            if IsDisabledControlJustPressed(0, 38) then
                nightVision = not nightVision
                SetNightvision(nightVision)
                SetTimecycleModifier("scanline_cam")
            end
  
            if Config.CCTV.PictureWebook ~= "" and IsDisabledControlJustPressed(0, 201) and not pictureCooldown then
                Wait(1)
                PlaySoundFrontend(-1, "Camera_Shoot", "Phone_Soundset_Franklin", 1)
                ESX.TriggerServerCallback("esx_property:GetWebhook", function(hook)
                  if hook then
                    exports['screenshot-basic']:requestScreenshotUpload(hook, "files[]", function(data)
                      local image = json.decode(data)
                      ESX.ShowNotification(TranslateCap("picture_taken"), "success")
                      SendNUIMessage({link = image.attachments[1].proxy_url})
                      ESX.ShowNotification(TranslateCap("clipboard"), "success")
                      pictureCooldown = true
                      SetTimeout(5000, function()
                        pictureCooldown = false
                      end)
                    end)
                  end
                end)
            end
  
            if IsDisabledControlPressed(1, Config.CCTV.Controls.Exit) then
                DoScreenFadeOut(1000)
                ESX.TriggerServerCallback("esx_property:ExitCCTV", function(CanExit)
                    if CanExit then
                        Core.Modules.CCTV.inCCTV = false
                        Wait(1000)
                        ClearFocus()
                        ClearTimecycleModifier()
                        ClearExtraTimecycleModifier()
                        RenderScriptCams(false, false, 0, true, false)
                        DestroyCam(cctvCamera, false)
                        SetFocusEntity(playerPed)
                        SetNightvision(false)
                        SetSeethrough(false)
                        SetEntityCollision(playerPed, true, true)
                        FreezeEntityPosition(playerPed, false)
                        SetEntityVisible(playerPed, true)
                        Wait(1500)
                        DoScreenFadeIn(1000)
                    end
                end, propertyId)
                break
            end
        end
    end, propertyId)
end