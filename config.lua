Config = {}

-------- Note: Can Cause quite abit of clutter ---------------
Config.ForSaleBlips = false -- Add Blips to For Sale Properties
Config.OwnedBlips = true -- Add blips for Owned Properties
---------------------------------------------------------------

--------------------- General Settings ---------------------------------
Config.Locale = GetConvar('esx:locale', 'en')
Config.SaveInterval = 5 -- How Often should all properties be saved (In Minutes)

--------------------- Interiors ---------------------------------

Config.Interiors = {
  {
    label = "Modern Apartment",
    value = "apa_v_mp_h_01_a",
    positions = {
      Wardrobe = vec3(-797.72, 328.03, 220.42)
    },
    type = "ipl",
    pos = vector3(-786.8663, 315.7642, 217.6385)
  },
  {
    label = "Mody Apartment",
    value = "apa_v_mp_h_02_a",
    positions = {
      Wardrobe = vec3(-797.591187, 327.995605, 220.424194)
    },
    type = "ipl",
    pos = vector3(-787.0749, 315.8198, 217.6386)
  },
  -- shells
  {
    label = "Housing 1",
    value = "default_housing1_k4mb1",
    positions = {
      Wardrobe = vec3(-797.591187, 327.995605, 220.424194)
    },
    type = "shell",
    pos = vector3(-787.0749, 315.8198, 217.6386)
  },
}

-------------------DONT TOUCH -------------------------
Config.OxInventory = ESX.GetConfig().OxInventory     --
                                                     --
function GetInteriorValues(Interior)                 --
 -- for _,type in pairs(Config.Interiors) do           --
    for _, interior in pairs(Config.Interiors) do                --
      if interior.value == Interior then             --
        return interior                              --  
      end                                            --
    end                                              --
 -- end                                                --
end                                                  --
--------------------------------------------------------


--[[
Copyright ©️ 2022 Kasey Fitton, ESX-Framework
All rights reserved. 

use of this source, with or without modification, are permitted provided that the following conditions are met: 

   Even if 'All rights reserved' is very clear :

  You shall not use any piece of this software in a commercial product / service
  You shall not resell this software
  You shall not provide any facility to install this particular software in a commercial product / service
  This copyright should appear in every part of the project code
]]
