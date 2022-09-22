---@diagnostic disable: undefined-global
-- Author: XiaNight
-- Date: 2022/09/22

----- Global Variables -----
local version = "v:0.0.1"
local monitor = peripheral.wrap("right")

----- Functions -----

local function new_vector2(x, y)
	return {
		x = x, y = y,
		add = function(self, other)
			return new_vector2(self.x + other.x, self.y + other.y)
		end,
		subtract = function(self, other)
			return new_vector2(self.x - other.x, self.y - other.y)
		end,
		multiply = function(self, other)
			return new_vector2(self.x * other.x, self.y * other.y)
		end,
		divide = function(self, other)
			return new_vector2(self.x / other.x, self.y / other.y)
		end,
		magnitude = function(self)
			return math.sqrt(self.x * self.x + self.y * self.y)
		end,
		normalize = function(self)
			return self:divide(new_vector2(self:magnitude(), self:magnitude()))
		end,
		to_string = function(self)
			return "(" .. self.x .. ", " .. self.y .. ")"
		end
	}
end

local function new_rect(x, y, w, h)
	return {
		x = x, y = y, w = w, h = h,
		set_size = function(self, w, h)
			return new_rect(self.x, self.y, w, h)
		end,
		set_x = function(self, x)
			return new_rect(x, self.y, self.w, self.h)
		end,
		set_y = function(self, y)
			return new_rect(self.x, y, self.w, self.h)
		end,
		set_w = function(self, w)
			return new_rect(self.x, self.y, w, self.h)
		end,
		set_h = function(self, h)
			return new_rect(self.x, self.y, self.w, h)
		end,
		offset = function (self, x, y)
			return new_rect(self.x + x, self.y + y, self.w, self.h)
		end,
		shift_x = function (self, x)
			return new_rect(self.x + x, self.y, self.w, self.h)
		end,
		shift_y = function (self, y)
			return new_rect(self.x, self.y + y, self.w, self.h)
		end,
		shift_w = function (self, w)
			return new_rect(self.x, self.y, self.w + w, self.h)
		end,
		shift_h = function (self, h)
			return new_rect(self.x, self.y, self.w, self.h + h)
		end,
		shrink = function (self, value)
			return new_rect(self.x + value, self.y + value, self.w - value * 2, self.h - value * 2)
		end,
		expand = function (self, value)
			return new_rect(self.x - value, self.y - value, self.w + value * 2, self.h + value * 2)
		end,
		to_string = function(self)
			return "Rect(" .. self.x .. ", " .. self.y .. ", " .. self.w .. ", " .. self.h .. ")"
		end
	}
end

local function new_stlye(has_margin, has_border, has_padding, color, border_color, background_color, line_spacing)
	-- default values
	color = color or colors.white
	border_color = border_color or colors.gray
	background_color = background_color or colors.black
	line_spacing = line_spacing or 1
	return {
		has_margin = has_margin,
		has_border = has_border,
		has_padding = has_padding,
		color = color,
		border_color = border_color,
		background_color = background_color,
		line_spacing = line_spacing,
		to_string = function(self)
			return "Style(margin: " .. (self.has_margin and "yes" or "no") .. ", border: " .. (self.has_border and "yes" or "no") .. ", padding: " .. (self.has_padding and "yes" or "no") .. ", color: " .. self.color .. ", border_color: " .. self.border_color .. ", background_color" .. self.background_color .. ")"
		end
	}
end

----- Environments -----

local display_width, display_height = monitor.getSize()
local screen = new_rect(1, 1, display_width, display_height)

-- debug screen size
print(string.format("Screen size: %d, %d", display_width, display_height))

----- Functions -----

local function draw_line(x, y, length, color)
	color = color or colors.white
	monitor.setBackgroundColor(color)
	monitor.setCursorPos(x, y)
	monitor.write(string.rep(" ", length))
end

local function draw_box(rect, color)
	color = color or colors.white
	for i = 0, rect.h do
		draw_line(rect.x, rect.y + i, rect.w, color)
	end
end

local function draw_hollow_box(rect, color)
	color = color or colors.white
	draw_line(rect.x, rect.y, rect.w, color)
	draw_line(rect.x, rect.y + rect.h, rect.w, color)
	for i = 1, rect.h - 1 do
		draw_line(rect.x, rect.y + i, 1, color)
		draw_line(rect.x + rect.w - 1, rect.y + i, 1, color)
	end
end

local function draw_text(pos, text, color, bg_color)
	color = color or colors.white
	bg_color = bg_color or colors.black

	monitor.setTextColor(color)
	monitor.setBackgroundColor(bg_color)
	monitor.setCursorPos(pos.x, pos.y)
	monitor.write(text)
end

local function wrap_text(str, limit)
	limit = limit or 72
	local here = 1
	local lines = 1
	local wrapped = {}
	
	while true do
		if here + limit - 2 < #str then
			wrapped[lines] = string.sub(str, here, here + limit - 2)
			lines = lines + 1
			here = here + limit - 1
		elseif here + limit > #str then
			wrapped[lines] = string.sub(str, here, #str)
			break
		else
			break
		end
	end

	return {texts = wrapped, lines = lines}
  end

local function draw_text_wrap(pos, text, width, color, bg_color)
	-- draw text with word wrap
	local wrapped_text = wrap_text(text, width)

	for _, wrap in ipairs(wrapped_text.texts) do
		draw_text(pos, wrap, color, bg_color)
		pos = pos:add(new_vector2(0, 1))
	end

	return wrapped_text.lines
end

local function draw_center_text(rect, text, color, bg_color)
	color = color or colors.white
	text = text or "Title"
	bg_color = bg_color or colors.black

	text = " " .. text .. " "
	local text_width = string.len(text)
	local text_pos = new_vector2(rect.x + math.floor((rect.w - text_width) / 2), rect.y + math.floor(rect.h / 2))
	draw_text(text_pos, text, color, bg_color)
end

local function draw_button(rect, text, color)
	color = color or colors.white
	draw_hollow_box(rect, color)
	draw_text(new_vector2(rect.x + 1, rect.y + 1), text, color)
end

local function new_text(text, color, bg_color)
	color = color or colors.white
	bg_color = bg_color or colors.black
	return {
		text = text,
		color = color,
		bg_color = bg_color,

		draw = function(self, parent_rect)
			return draw_text_wrap(new_vector2(parent_rect.x + 1, parent_rect.y + 1), self.text, parent_rect.w - 2, self.color, self.bg_color)
		end,

		to_string = function(self)
			return "Text(" .. self.text .. ", " .. self.color .. ", " .. self.bg_color .. ")"
		end
	}
end

local function new_dynamic_text(callback, color, bg_color)
	color = color or colors.white
	bg_color = bg_color or colors.black
	return {
		callback = callback,
		color = color,
		bg_color = bg_color,

		draw = function(self, parent_rect)
			return draw_text_wrap(new_vector2(parent_rect.x + 1, parent_rect.y + 1), self.callback(), parent_rect.w - 2, self.color, self.bg_color)
		end,

		to_string = function(self)
			return "Text(" .. self.callback() .. ", " .. self.color .. ", " .. self.bg_color .. ")"
		end
	}
end

local function create_div(rect, style, title)
	style = style or new_stlye()
	-- title is nil-able

	local div = {
		rect = rect,
		style = style,
		title = title,

		-- child elemets
		elements = {},

		add_element = function(self, element)
			table.insert(self.elements, element)
			return self
		end,

		get_border_rect = function(self)
			local margin = self.style.has_margin and 1 or 0
			return self.rect:shrink(margin)
		end,

		get_content_rect = function(self)
			return self:get_border_rect():shift_y(((self.title ~= nil) or self.style.has_border) and 1 or 0):shrink(self.style.has_padding and 1 or 0)
		end,

		draw = function(self, parent_rect)

			local border_rect = self:get_border_rect()
			local content_rect = self:get_content_rect()

			-- draw background
			draw_box(content_rect, self.style.background_color)

			print(self.style.has_border)
			if self.style.has_border then
				-- draw border
				draw_hollow_box(border_rect, self.style.border_color)
			end

			if self.title ~= nil then
				-- draw title
				draw_center_text(border_rect:set_h(1), self.title, self.style.color, self.style.background_color)
			end

			-- draw elements

			local cursor_pos = 0

			for _, element in ipairs(self.elements) do
				local space_used = element:draw(content_rect:shift_y(cursor_pos):shift_h(-cursor_pos))
				cursor_pos = cursor_pos + space_used + self.style.line_spacing
			end
			return self.rect.h
		end,

		append_div = function(self, rect, style, title)
			style = style or self.style
			title = title or "Div"

			local new_div = create_div(self:get_content_rect():offset(rect.x, rect.y):set_size(rect.w, rect.h), style, title)

			self:add_element(new_div)
			return new_div
		end,

		append_percentage_div = function(self, rect, style, title)
			style = style or self.style
			title = title or "Div"

			local content_rect = self:get_content_rect()
			local new_div = create_div(content_rect:offset(rect.x * content_rect.w, rect.y * content_rect.h):set_size(rect.w * content_rect.w, rect.h * content_rect.h), style, title)

			self:add_element(new_div)
			return new_div
		end,

		append_text = function(self, text)
			local new_text = new_text(text, self.style.color, self.style.background_color)
			self:add_element(new_text)
			return new_text
		end,

		append_dynamic_text = function(self, text, color, bg_color)
			local new_text = new_dynamic_text(text, color, bg_color)
			self:add_element(new_text)
			return new_text
		end,
	}
	return div
end

----- Main -----

local function draw_main_page()
	draw_box(screen, colors.black) -- clear screen

	local main_style = new_stlye(true, true, true, colors.white, colors.gray, colors.black)

	local document = create_div(screen, new_stlye(false, false, false), "Main Panel Display") -- create document div

	local body = document:append_percentage_div(new_rect(0, 0, 0.5, 0.5), main_style, "Body") -- create div 1
	body:append_text("Hello World! This is multiple lines") -- create text 1

	document:append_text("Another line") -- create text 2
	document:append_text("Another line") -- create text 3
	
	document:draw()

	draw_text(new_vector2(screen.w - #version + 1, 1), version, colors.gray, colors.black)

	print(document.style:to_string())
end

draw_main_page()