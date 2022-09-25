---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/22

os.loadAPI("/framework")

framework.SetDebugMonitorId("monitor_0")

local induction_matrix = peripheral.wrap("inductionPort_0")
for key, value in pairs(induction_matrix) do
	print(key)
end

framework.DebugLog("Energy: " .. (induction_matrix.getEnergy() / 10 * 4))

framework.Init()