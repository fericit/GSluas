print('this defensive crap is made by @fericit on discord go suck dick now')
-- Shit is in LUA tab
local enable_flick = ui.new_checkbox("LUA", "B", "Auto Yaw Flick (90°)")
local flick_delay = ui.new_slider("LUA", "B", "Flick Delay (ticks)", 1, 64, 16, true, "", 1)
local flick_dir_hotkey = ui.new_hotkey("LUA", "B", "Switch Flick Direction")
local flick_color = ui.new_color_picker("LUA", "B", "Flick Color", 255, 90, 90, 255)

-- References to AA settings
local yaw_base, yaw_slider = ui.reference("AA", "Anti-aimbot angles", "Yaw")
local jitter_dropdown = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")

-- State
local flicking = false
local flick_tick = nil
local original_yaw = nil
local next_flick_tick = 0
local flick_direction = "Left"
local last_hotkey_state = false
local saved_jitter_mode = nil

-- Flipper
client.set_event_callback("run_command", function()
    local current_state = ui.get(flick_dir_hotkey)
    if current_state and not last_hotkey_state then
        flick_direction = (flick_direction == "Left") and "Right" or "Left"
    end
    last_hotkey_state = current_state
end)

-- Main flick
client.set_event_callback("paint", function(ctx)
    if not ui.get(enable_flick) then return end

    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return end

    local tick = globals.tickcount()

    -- Trigger flick
    if not flicking and tick >= next_flick_tick then
        original_yaw = ui.get(yaw_slider)
        saved_jitter_mode = ui.get(jitter_dropdown)

        -- Disable jitter temporarily
        ui.set(jitter_dropdown, "Off")

        flick_tick = tick
        flicking = true

        local new_yaw = original_yaw + (flick_direction == "Left" and -90 or 90)
        if new_yaw > 180 then new_yaw = new_yaw - 360 end
        if new_yaw < -180 then new_yaw = new_yaw + 360 end

        ui.set(yaw_slider, new_yaw)
    end

    -- Restore after 1 tick
    if flicking and tick > flick_tick then
        ui.set(yaw_slider, original_yaw)
        ui.set(jitter_dropdown, saved_jitter_mode)
        flicking = false
        next_flick_tick = tick + ui.get(flick_delay)
    end

    -- Visualiser
    local r, g, b, a = ui.get(flick_color)
    client.draw_indicator(ctx, r, g, b, a, "FLICK: " .. string.upper(flick_direction))
end)