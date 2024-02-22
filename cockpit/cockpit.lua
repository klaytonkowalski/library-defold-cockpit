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

local state_idle = 1
local state_over = 2
local state_down = 3

local group_default = hash("group_default")
local nil_callback = function() end

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local cockpit = {}

local instruments = {}
local group_stack = { group_default }

local action_x = nil
local action_y = nil
local action_dx = nil
local action_dy = nil

--------------------------------------------------------------------------------
-- Local Variables
--------------------------------------------------------------------------------

local function cursor_callback()
	for _, instrument in pairs(instruments) do
		-- Only operate on the active group.
		if instrument.group == group_stack[#group_stack] then
			-- Check if the cursor is hovering over a node.
			if gui.pick_node(instrument.node, action_x, action_y) then
				-- Check if the cursor wasn't hovering over a node, but is now.
				if instrument.state == state_idle then
					instrument.state = state_over
					instrument.over_callback(instrument.node, true)
				end
			-- Check if the cursor was hovering over a node, but not anymore.
			elseif instrument.state == state_over then
				instrument.state = state_idle
				instrument.over_callback(instrument.node, false)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

function cockpit.add_button(node_id, group, over_callback, down_callback)
	local button =
	{
		node_id = node_id,
		node = gui.get_node(node_id),
		group = group or group_default,
		over_callback = over_callback or nil_callback,
		down_callback = down_callback or nil_callback,
		state = state_idle
	}
	instruments[node_id] = button
end

function cockpit.remove_instrument(node_id)
	instruments[node_id] = nil
end

function cockpit.remove_instrument_group(group)
	for node_id, instrument in pairs(instruments) do
		if instrument.group == group then
			cockpit.remove_instrument(node_id)
		end
	end
end

function cockpit.remove_instruments()
	for node_id, _ in pairs(instruments) do
		cockpit.remove_instrument(node_id)
	end
end

function cockpit.push_group(group)
	group_stack[#group_stack + 1] = group
end

function cockpit.pop_group()
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
		cursor_callback()
	elseif action.pressed then
		
	elseif action.released then
		
	end
end

return cockpit