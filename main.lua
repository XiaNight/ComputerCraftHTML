---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/22

os.loadAPI("/framework")

----- Global Variables -----

local version = "v:0.0.1"

----- Main -----

local function register_main_page()

	local main_monitor = framework.CreateMonitor("right", 0.7)
	if main_monitor == nil then
		return
	end
	local document = main_monitor:add_window()

	local main_style = main_style or framework.NewStyle(true, true, true, colors.white, colors.gray, colors.black)

	local body = document:append_percentage_div(framework.NewRect(0, 0, 0.5, 0.5), main_style, "Body") -- create div 1
	body:append_text("Hello World! This is multiple lines") -- create text 1
	body:add_element(framework.NewDynamicText(function() return "Time: " .. os.time() end, main_style.color, main_style.background_color)) -- create dynamic text 1

	document:append_text("Another line") -- create text 2
	document:append_text("Another line") -- create text 3

	local right_panel = document:append_percentage_div(framework.NewRect(0.5, 0, 0.5, 1), main_style, "Menu") -- create div 2
	right_panel:append_text("Start") -- create text 4
	right_panel:append_text("Options") -- create text 4
	right_panel:append_text("Exit") -- create text 4
	right_panel:add_element(framework.NewProgressBar(function() return 0.5 end, 1, colors.lime, colors.lightGray))

	local new_button_event = function()
		framework.DebugLog("test")
	end
	
	local page_2_btn = framework.NewButton("Next Page", new_button_event, colors.black, colors.lime)
	right_panel:add_element(page_2_btn)
	
	main_monitor:draw()

	framework.DebugLog(document.style:to_string())

	framework.RegisterMonitor(main_monitor)
end

register_main_page()
framework.Init()