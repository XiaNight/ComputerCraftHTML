---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/22

os.loadAPI("/framework")

framework.SetDebugMonitorId("top")

local induction_matrix = peripheral.wrap("inductionPort_0")

local function get_stored_energy_fn()
	return "Stored: " .. framework.CompactValue(induction_matrix.getEnergy() / 10 * 4)
end

local function get_input_energy_fn()
	return "Input: " .. framework.CompactValue(induction_matrix.getLastInput() / 10 * 4)
end

local function get_output_energy_fn()
	return "Output: " .. framework.CompactValue(induction_matrix.getLastOutput() / 10 * 4)
end

local function register_main_page()

	local main_monitor = framework.CreateMonitor("monitor_2", 1)

	if main_monitor == nil then
		return
	end

	local document = main_monitor:add_window("Home")

	local main_style = main_style or framework.NewStyle(true, true, true, colors.white, colors.gray, colors.black)
	
	local body = document:append_percentage_div(framework.NewRect(0, 0, 0.45, 1), main_style, "Energy") -- create div 1
	body:add_element(framework.NewDynamicText(get_stored_energy_fn, main_style.color, main_style.background_color))
	body:add_element(framework.NewDynamicText(get_input_energy_fn, main_style.color, main_style.background_color))
	body:add_element(framework.NewDynamicText(get_output_energy_fn, main_style.color, main_style.background_color))

	
	-- local graphics = document:append_percentage_div(framework.NewRect(0.45, 0, 0.55, 1), main_style, "Graphics") 

	framework.RegisterMonitor(main_monitor)
end

-- for key, value in pairs(induction_matrix) do
-- 	framework.DebugLog(key)
-- end

framework.DebugLog("Energy: " .. (induction_matrix.getEnergy() / 10 * 4))

register_main_page()

framework.Init(0.5)