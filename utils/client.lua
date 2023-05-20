Core.Utils = {}

--- Create CCTV Instruction Button Message
--- @param text string
function Core.Utils:InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

--- Create CCTV Insturction Scaleform
--- @param scaleformMovie string
function Core.Utils:CreateInstuctionScaleform(scaleformMovie)
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie(scaleformMovie)
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    if Config.CCTV.PictureWebook ~= "" then
      	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      	PushScaleformMovieFunctionParameterInt(1)
      	ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Screenshot, true))
      	Core.Utils:InstructionButtonMessage(TranslateCap("take_picture"))
      	PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Right, true))
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Left, true))
    Core.Utils:InstructionButtonMessage(TranslateCap("rot_left_right"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Down, true))
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Up, true))
    Core.Utils:InstructionButtonMessage(TranslateCap("rot_up_down"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.ZoomOut, true))
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.ZoomIn, true))
    Core.Utils:InstructionButtonMessage(TranslateCap("zoom"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.NightVision, true))
    Core.Utils:InstructionButtonMessage(TranslateCap("night_vision"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Exit, true))
    Core.Utils:InstructionButtonMessage(TranslateCap("exit"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end