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

local group_default = hash("group_default")

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local cockpit = {}

local action_x = nil
local action_y = nil
local action_dx = nil
local action_dy = nil

local components = {}

local group_stack = { group_default }

--------------------------------------------------------------------------------
-- Local Variables
--------------------------------------------------------------------------------

local function update_component_data(component)
	if component.type == type_button then
		-- todo: possibly nothing?
	elseif component.type == type_checkbox then
		component.checked = not component.checked
	end
end

local function over_callback()
	for node, component in pairs(components) do
		if component.group == group_stack[#group_stack] then
			if gui.pick_node(node, action_x, action_y) then
				if not component.over then
					component.over = true
					if component.callback then
						component.callback(node, component.over, component.down, false)
					end
				end
			elseif component.over then
				component.over = false
				if component.callback then
					component.callback(node, component.over, component.down, false)
				end
			end
		end
	end
end

local function down_callback()
	for node, component in pairs(components) do
		if component.group == group_stack[#group_stack] then
			if component.over then
				component.down = true
				if component.callback then
					component.callback(node, component.over, component.down, false)
				end
			end
		end
	end
end

local function up_callback()
	for node, component in pairs(components) do
		if component.group == group_stack[#group_stack] then
			if component.down then
				component.down = false
				if component.over and component.callback then
					update_component_data(component)
					component.callback(node, component.over, component.down, true)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

function cockpit.create_button(node, callback, group)
	components[node] =
	{
		type = type_button,
		node = node,
		callback = callback,
		group = group or group_default,
		over = false,
		down = false
	}
	if callback then
		callback(node, components[node].over, components[node].down, false)
	end
end

function cockpit.create_checkbox(node, callback, group, checked)
	components[node] =
	{
		type = type_checkbox,
		node = node,
		callback = callback,
		group = group or group_default,
		over = false,
		down = false,
		checked = checked or false
	}
	if callback then
		callback(node, components[node].over, components[node].down, false)
	end
end

function cockpit.push_group(group)
	group_stack[#group_stack + 1] = group
end

function cockpit.pop_group(group)
	if #group_stack == 1 then
		return
	end
	group_stack[#group_stack] = nil
end

function cockpit.on_input(action_id, action)
	if not action_id then
		action_x = action.x
		action_y = action.y
		action_dx = action.dx
		action_dy = action.dy
		over_callback(action)
	elseif action.pressed then
		if action_id == hash("mouse_button_left") then
			down_callback()
		end
	elseif action.released then
		if action_id == hash("mouse_button_left") then
			up_callback()
		end
	end
end

function cockpit.get_checkbox_data(node)
	return
	{
		checked = components[node].checked
	}
end

return cockpit