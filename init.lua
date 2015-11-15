local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path .. "/chatcommands.lua")

langton_ant = {}

langton_ant.white = {name = "wool:white"}
langton_ant.black = {name = "wool:black"}

langton_ant.timer = 0
langton_ant.step_timer = 0.05

langton_ant.ants = {}

langton_ant.register_new_ant = function(player)
	-- Normalize player location
	local pos = player:getpos()
	local yaw = player:getyaw()

	math.floor(pos.x)
	math.floor(15.0)
	math.floor(pos.z)
	yaw = 0.0

	player:setpos(pos)
	player:setyaw(yaw)

	langton_ant.ants[player:get_player_name()] = {direction = {x=0,y=1,z=0,yaw=0}, player = player}
end

langton_ant.turn_right = function(yaw)
	return yaw - math.pi/2
end

langton_ant.turn_left = function(yaw)
	return yaw + math.pi/2
end


langton_ant.update_block = function(node_pos, name)
	
	if name ~= langton_ant.white.name then
		minetest.set_node(node_pos,langton_ant.white)
	else
		minetest.set_node(node_pos,langton_ant.black)
	end
end

langton_ant.update_ant = function(ant)
	local pos = ant.player:getpos()
	local node_pos = pos

	node_pos.y = node_pos.y - 1

	local node = minetest.get_node(node_pos)
	local dir = ant.direction
	local name = node.name

	langton_ant.update_ant(node_pos, name)

	if name ~= langton_ant.white.name then
		dir.yaw = langton_ant.turn_right(dir.yaw)
	else
		dir.yaw = langton_ant.turn_left(dir.yaw)
	end

	dir.x = math.cos(dir.yaw)
	dir.z = math.sin(dir.yaw)

	pos.x = pos.x + dir.x
	pos.y = pos.y + dir.y
	pos.z = pos.z + dir.z

	ant.player:setpos(pos)
end

langton_ant.unregister_ant = function(player)
	langton_ant.ants[player:get_player_name()] = nil
end

minetest.register_globalstep(function(dt)
	langton_ant.timer = langton_ant.timer + dt

	if langton_ant.timer >= langton_ant.step_timer then
		for key,val in pairs(langton_ant.ants) do
			langton_ant.update_ant(val)
		end
		langton_ant.timer = 0
	end
end)
