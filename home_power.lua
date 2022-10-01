---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/22

os.loadAPI("/framework")

framework.SetDebugMonitorId("top")

local induction_matrix = peripheral.wrap("inductionPort_0")

local function get_energy_capacity_fn()
	return induction_matrix.getMaxEnergy() / 10 * 4
end

local function get_stored_energy_fn()
	return induction_matrix.getEnergy() / 10 * 4
end

local function get_transfer_rate_fn()
	return induction_matrix.getTransferCap() / 10 * 4
end

local function get_input_energy_fn()
	return induction_matrix.getLastInput() / 10 * 4
end

local function get_output_energy_fn()
	return induction_matrix.getLastOutput() / 10 * 4
end

local function get_in_out_energy_fn()
	local input = get_input_energy_fn()
	local denominator = input + get_output_energy_fn()
	if denominator == 0 then
		return nil
	end
	return input / denominator
end

local function register_main_page()

	local main_monitor = framework.CreateMonitor("monitor_2", 0.7)

	if main_monitor == nil then
		return
	end

	local document = main_monitor:add_window("Home")

	local main_style = main_style or framework.NewStyle(true, true, true, colors.white, colors.gray, colors.black)

	local menu_panel = document:append_percentage_div(framework.NewRect(0, 0, 0.45, 1), main_style, "Menu")
	local energy_panel = document:append_percentage_div(framework.NewRect(0.45, 0, 0.55, 1), main_style, "Energy") -- create div 1
	local storage_panel = document:append_percentage_div(framework.NewRect(0.45, 0, 0.55, 1), main_style, "Storage") -- create div 2
	
	--- Energy Panel
	-- energy_panel:add_element(framework.NewDynamicText(get_energy_capacity_fn, main_style.color, main_style.background_color))
	-- energy_panel:add_element(framework.NewDynamicText(get_stored_energy_fn, main_style.color, main_style.background_color))
	-- energy_panel:add_element(framework.NewDynamicText(get_input_energy_fn, main_style.color, main_style.background_color))
	-- energy_panel:add_element(framework.NewDynamicText(get_output_energy_fn, main_style.color, main_style.background_color))
	energy_panel:append_text("Storage")
	energy_panel:add_element(framework.NewProgressBar(get_stored_energy_fn, get_energy_capacity_fn(), colors.lime, colors.lightGray))
	energy_panel:append_text("Input")
	energy_panel:add_element(framework.NewProgressBar(get_input_energy_fn, get_transfer_rate_fn(), colors.green, colors.lightGray))
	energy_panel:append_text("Output")
	energy_panel:add_element(framework.NewProgressBar(get_output_energy_fn, get_transfer_rate_fn(), colors.red, colors.lightGray))
	energy_panel:append_text("In / Out")
	energy_panel:add_element(framework.NewProgressBar(get_in_out_energy_fn, 1, colors.green, colors.red))
	
	--- Storage Panel
	storage_panel.activated = false
	storage_panel:append_text("Storage")

	--- Menu Panel
	menu_panel:add_element(framework.NewButton("Energy", function()
	energy_panel.activated = true
		storage_panel.activated = false
		main_monitor:redraw_all()
		framework.DebugLog("Energy Tab Activated")
	end, colors.black, colors.lime))
	menu_panel:add_element(framework.NewButton("Storage", function() 
		energy_panel.activated = false
		storage_panel.activated = true
		main_monitor:redraw_all()
		framework.DebugLog("Storage Tab Activated")
	end, colors.black, colors.lightBlue))
	
	-- local graphics = document:append_percentage_div(framework.NewRect(0.45, 0, 0.55, 1), main_style, "Graphics") 

	framework.RegisterMonitor(main_monitor)
end

local function register_modem_data_listeners()
	framework.NewModemDataListener(1, 1, function(data)
		framework.DebugLog("Received Data: " .. data)
	end)
end

framework.DebugLog("Energy: " .. (induction_matrix.getEnergy() / 10 * 4))

register_main_page()
register_modem_data_listeners()

local modem = peripheral.wrap("modem_0")
modem.open(1)

framework.Init(5, os.pullEvent)