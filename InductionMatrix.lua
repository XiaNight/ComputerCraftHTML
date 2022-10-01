---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/29

os.loadAPI("/transmitter")

local function register_induction_matrix()
	local induction_matrix = peripheral.wrap("left")

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

	local modem = transmitter.NewModem("right", 1, 2)

	if modem == nil then
		print("Modem initiation failed")
	else
		local energy_capacity_data = transmitter.NewData(get_energy_capacity_fn, 1)
		local stored_energy_data = transmitter.NewData(get_stored_energy_fn, 1)
		local transfer_rate_data = transmitter.NewData(get_transfer_rate_fn, 1)
		local input_energy_data = transmitter.NewData(get_input_energy_fn, 1)
		local output_energy_data = transmitter.NewData(get_output_energy_fn, 1)
		local in_out_energy_data = transmitter.NewData(get_in_out_energy_fn, 1)
	
		modem:AddData(energy_capacity_data)
		modem:AddData(stored_energy_data)
		modem:AddData(transfer_rate_data)
		modem:AddData(input_energy_data)
		modem:AddData(output_energy_data)
		modem:AddData(in_out_energy_data)
	end
end

register_induction_matrix()
transmitter.Init()