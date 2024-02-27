--------------------------------------------------------------------------------
-- License
--------------------------------------------------------------------------------

-- Copyright (c) 2024 Klayton Kowalski

-- This software is provided 'as-is', without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it freely,
-- subject to the following restrictions:

-- 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--    If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

-- 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

-- 3. This notice may not be removed or altered from any source distribution.

--------------------------------------------------------------------------------
-- Information
--------------------------------------------------------------------------------

-- GitHub: https://github.com/klaytonkowalski/library-defold-cockpit

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local type_button = 1
local type_checkbox = 2
local type_radio = 3
local type_slider = 4

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local cockpit = {}

local action_x = nil
local action_y = nil
local action_dx = nil
local action_dy = nil

local components = {}

local input =
{
	down = { action_id = hash("mouse_button_left"), value = 0 }
}

--------------------------------------------------------------------------------
-- Local Variables
--------------------------------------------------------------------------------

local function clamp(number, min, max)
	if number < min then
		return min
	end
	if number > max then
		return max
	end
	return number
end

local function uncheck_radio_group(group)
	for node, component in pairs(components) do
		if component.enabled then
			if component.type == type_radio and component.group == group and component.checked then
				component.checked = false
				component.callback(node, component.over, component.down, true)
			end
		end
	end
end

local function over_callback()
	for node, component in pairs(components) do
		if component.enabled then
			if gui.pick_node(node, action_x, action_y) then
				if not component.over then
					component.over = true
					if component.callback then
						component.callback(node, component.over, component.down, false)
					end
				end
			elseif component.over then
				component.over = false
				component.callback(node, component.over, component.down, false)
			end
			if component.type == type_slider then
				if component.down then
					component.percent = clamp(component.percent + (component.vertical and action_dy or action_dx) / component.length * 100, 0, 100)
					component.callback(node, component.over, component.down, true)
				end
			end
		end
	end
end

local function down_callback()
	for node, component in pairs(components) do
		if component.enabled then
			if component.over then
				component.down = true
				component.callback(node, component.over, component.down, false)
			end
		end
	end
end

local function up_callback()
	for node, component in pairs(components) do
		if component.enabled then
			if component.down then
				component.down = false
				if component.over and component.callback then
					if component.type == type_checkbox then
						component.checked = not component.checked
					elseif component.type == type_radio then
						if not component.checked then
							uncheck_radio_group(component.group)
						end
						component.checked = not component.checked
					end
					component.callback(node, component.over, component.down, true)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

function cockpit.set_action_ids(action_ids)
	for key, value in pairs(input) do
		if action_ids[key] then
			value.action_id = action_ids[key]
		end
	end
end

function cockpit.on_input(action_id, action)
	if not action_id then
		action_x = action.x
		action_y = action.y
		action_dx = action.dx
		action_dy = action.dy
		over_callback(action)
	elseif action.pressed then
		if action_id == input.down.action_id then
			input.down.value = 1
			down_callback()
		end
	elseif action.released then
		if action_id == input.down.action_id then
			input.down.value = 0
			up_callback()
		end
	end
end

function cockpit.set_component_enabled(node, enabled)
	components[node].enabled = enabled
end

function cockpit.get_component_enabled(node)
	return components[node].enabled
end

-- Button ----------------------------------------------------------------------

function cockpit.create_button(node, callback)
	components[node] =
	{
		type = type_button,
		enabled = true,
		node = node,
		callback = callback,
		over = false,
		down = false
	}
	components[node].callback(node, components[node].over, components[node].down, false)
end

-- Checkbox --------------------------------------------------------------------

function cockpit.create_checkbox(node, callback, checked)
	components[node] =
	{
		type = type_checkbox,
		enabled = true,
		node = node,
		callback = callback,
		over = false,
		down = false,
		checked = checked or false
	}
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.set_checkbox_checked(node, checked)
	if checked == components[node].checked then
		return
	end
	components[node].checked = checked
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.get_checkbox_checked(node)
	return components[node].checked
end

-- Radio -----------------------------------------------------------------------

function cockpit.create_radio(node, callback, group, checked)
	components[node] =
	{
		type = type_radio,
		enabled = true,
		node = node,
		callback = callback,
		over = false,
		down = false,
		group = group,
		checked = checked or false
	}
	if checked then
		uncheck_radio_group(group)
	end
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.set_radio_checked(node, checked)
	if checked == components[node].checked then
		return
	end
	if checked then
		uncheck_radio_group(components[node].group)
	end
	components[node].checked = checked
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.get_radio_checked(node)
	return components[node].checked
end

-- Slider ----------------------------------------------------------------------

function cockpit.create_slider(node, callback, length, percent, vertical)
	components[node] =
	{
		type = type_slider,
		enabled = true,
		node = node,
		callback = callback,
		over = false,
		down = false,
		length = length,
		percent = percent or 100,
		vertical = vertical or false
	}
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.set_slider_percent(node, percent)
	components[node].percent = percent
	components[node].callback(node, components[node].over, components[node].down, true)
end

function cockpit.get_slider_percent(node)
	return components[node].percent
end

return cockpit