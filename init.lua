local fs="additional_gravel"
local register=function (origin,name)
	minetest.log("error","["..fs.." stair provider not found to make "..origin..":"..name.." stairs, slabs, etc")
end
if minetest.get_modpath("stairs") then
	function register_stairs(origin,name)
		local node = minetest.registered_nodes[origin..":"..name]
		stairs.register_stair_and_slab(
			name,
			origin..":"..name,
			node.groups,
			node.tiles,
			node.description.." Stair",
			node.description.." Slab",
			node.sounds,
			false,
			"Inner "..node.description.." Stair",
			"Outer "..node.description.." Stair"
		)
		minetest.register_alias_force(fs..":stair_"..name,"stairs:stair_"..name)
		minetest.register_alias_force(fs..":stair_inner_"..name,"stairs:stair_inner_"..name)
		minetest.register_alias_force(fs..":stair_outer_"..name,"stairs:stair_outer_"..name)
		minetest.register_alias_force(fs..":slab_"..name,"stairs:slab_"..name)
	end
end

function get_neighbor_light_max(pos)
	local max_light = -1
	-- Only need to check 6 faces!
	local i = pos.x
	local j = pos.y
	local k = pos.z
	facet = {	vector.new(i-0.5, j, k), vector.new(i+0.5, j, k),
				vector.new(i, j-0.5, k), vector.new(i, j+0.5, k),
				vector.new(i, j, k-0.5), vector.new(i, j, k+0.5),
			}
		for n=1, #facet do
			if(tonumber(minetest.get_node_light(facet[n]))) then
				max_light = math.max(max_light, minetest.get_node_light(facet[n]))
            end
			--minetest.chat_send_all( tostring(n)..": ".. tostring( facet[n] ).." = "..tostring(minetest.get_node_light( facet[n] ))	)
		end
	return max_light
end

if minetest.get_modpath("default") then


	minetest.register_node(fs..":overgrown_gravel", {
		description = "Overgrown gravel",
		tiles = {"overgrown_gravel.png"},
		groups = {crumbly = 2, falling_node = 1},
		drop = {
			max_items = 1,
			items = {
				{items = {"default:flint"}, rarity = 16},
				{items = {fs..":overgrown_gravel"}}
			}
		},
		sounds = default.node_sound_gravel_defaults(),
	})

	if minetest.get_modpath("stairs") then
		register_stairs("default","gravel")	
		register_stairs(fs,"overgrown_gravel")	-- JD Added 10/10/2024
	end
end


--minetest.register_craft({
--	type = "shapeless",
--	output = "additional_gravel:overgrown_gravel",
--	recipe = {"default:gravel","default:grass_1"},
--})


--
-- Moss growth on gravel near water
--

local moss_correspondences = {
	["default:gravel"] = fs..":overgrown_gravel",
	["stairs:slab_gravel"] = "stairs:slab_overgrown_gravel",
	["stairs:stair_gravel"] = "stairs:stair_overgrown_gravel",
	["stairs:stair_inner_gravel"] = "stairs:stair_inner_overgrown_gravel",
	["stairs:stair_outer_gravel"] = "stairs:stair_outer_overgrown_gravel",
}
minetest.register_abm({
	label = "Moss growth",
	nodenames = {"default:gravel",
	    "stairs:slab_gravel",
	    "stairs:stair_gravel",
		"stairs:stair_inner_gravel",
		"stairs:stair_outer_gravel",
	},
	
	
	neighbors = {
		"group:water",
		fs..":overgrown_gravel",
		"stairs:slab_overgrown_gravel",
		"stairs:stair_overgrown_gravel",
		"stairs:stair_inner_overgrown_gravel",
		"stairs:stair_outer_overgrown_gravel",
	},
		
	interval = 16,
	chance = 200,
	catch_up = false,
	action = function(pos, node)
		node.name = moss_correspondences[node.name]
		if node.name then
			--minetest.chat_send_all( tostring( get_neighbor_light_max(pos) ) )
			if get_neighbor_light_max(pos) < 13 then	--Only overgrow if light is bright enough
				return
			end
			minetest.set_node(pos, node)
		end
	end
})
