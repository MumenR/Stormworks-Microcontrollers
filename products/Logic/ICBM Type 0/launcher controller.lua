-- Author: MumenR
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!


INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool

function onTick()
    main_hardpoint = INN(1)
    vertical_instllation_hardpoint = INN(2)
    slider = INN(3)
    launcher_hinge = INN(4)
    holder_hinge = INN(5)
    pneumatic_piston = INN(6)
    launch_mode = INB(1)

    launcher_hinge_controll = launcher_hinge*4
    holder_hinge_controll = holder_hinge*4

    vertical_instllation_hardpoint_releace = false
    holder_hardpoint = false
    slider_up = false
    slider_down = false
    launch_mode_completion = false

    if launch_mode then
        pneumatic_piston_controll = 1

        if pneumatic_piston >= 0.45 then

            if (launcher_hinge <= 0.24 or slider <= 18.74) and vertical_instllation_hardpoint ~= 0 then
                holder_hinge_controll = 0
                launcher_hinge_controll = 1
                slider_up = true
            else
                launcher_hinge_controll = 1
                holder_hinge_controll = 1

                if holder_hinge <= 0.24 then
                    holder_hardpoint = true
                    vertical_instllation_hardpoint_releace = true

                elseif slider >= 0.1 and vertical_instllation_hardpoint == 0 then
                    slider_down = true
                else
                    launch_mode_completion = true
                end
            end
        end

    elseif main_hardpoint ~= 0 then
        
        if vertical_instllation_hardpoint ~= 0 and holder_hinge <= 0.1 and launcher_hinge <= 0.01 and slider <= 0.1 then
            pneumatic_piston_controll = -1
            launcher_hinge_controll = 0
            holder_hinge_controll = 0
        else
            pneumatic_piston_controll = 1

            if pneumatic_piston >= 0.45 then
                if vertical_instllation_hardpoint == 0 then
                    holder_hinge_controll = 1
                    launcher_hinge_controll = 1
                    holder_hardpoint = true
                    slider_up = true
                else
                    holder_hinge_controll = 0
                    if holder_hinge <= 0.01 then
                        slider_down = true
                        launcher_hinge_controll = 0
                    end
                end
            end
        end
    
    else

        if holder_hinge <= 0.1 and launcher_hinge <= 0.01 and slider <= 0.1 then
            pneumatic_piston_controll = -1
            launcher_hinge_controll = 0
            holder_hinge_controll = 0
        else
            pneumatic_piston_controll = 1

            if pneumatic_piston >= 0.45 then
                holder_hinge_controll = 0

                if holder_hinge <= 0.01 then
                    if slider >= 0.1 then
                        slider_down = true
                    else
                        launcher_hinge_controll = 0
                        holder_hinge_controll = 0
                    end
                end
                
            end
        end

    end

    OUN(1, launcher_hinge_controll)
    OUN(2, holder_hinge_controll)
    OUN(3, pneumatic_piston_controll)
    OUB(1, slider_up)
    OUB(2, slider_down)
    OUB(3, vertical_instllation_hardpoint_releace)
    OUB(4, holder_hardpoint)
    OUB(5, launch_mode_completion)
end