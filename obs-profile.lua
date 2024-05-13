-- Created by Grigore Stefan <g_stefan@yahoo.com>
-- Public domain (Unlicense) <http://unlicense.org>
-- SPDX-FileCopyrightText: 2024 Grigore Stefan <g_stefan@yahoo.com>
-- SPDX-License-Identifier: Unlicense

obs = obslua

-- Description displayed in the Scripts dialog window
function script_description()
  return [[Auto fit scene on profile change]]
end

function on_item(item,sourceWidth,sourceHeight)
	local transform = obs.obs_transform_info()
	obs.obs_sceneitem_get_info(item, transform)

	-- print("* Transform")
	-- print("Position X: " .. transform.pos.x)
	-- print("Position Y: " .. transform.pos.y)
	-- print("Rotation: " .. transform.rot)
	-- print("Scale X: " .. transform.scale.x)
	-- print("Scale Y: " .. transform.scale.y)
	-- print("Alignment:" .. transform.alignment)
	-- print("Bounds Type:" .. transform.bounds_type)
	-- print("Bounds Alignment:" .. transform.bounds_alignment)
	-- print("Bounds X: " .. transform.bounds.x)
	-- print("Bounds Y: " .. transform.bounds.y)
	-- print("Source Width:" .. sourceWidth)
	-- print("Source Height:" .. sourceHeight)

	transform.pos.x = 0
	transform.pos.y = 0
	transform.rot = 0
	transform.scale.x = 1 
	transform.scale.y = 1
	transform.alignment = 5
	transform.bounds_type = 2
	transform.bounds_alignment = 0
	transform.bounds.x = sourceWidth
	transform.bounds.y = sourceHeight

	obs.obs_sceneitem_set_info(item, transform)
	return true
end

function on_scene(scene,sourceWidth,sourceHeight)
	local items = obs.obs_scene_enum_items(scene)
	if items ~= nil then
		for _, item in ipairs(items) do
			on_item(item,sourceWidth,sourceHeight)
		end
	end
	obs.sceneitem_list_release(items)
end

function on_event(event)
	if event == obs.OBS_FRONTEND_EVENT_PROFILE_CHANGED then
		local scenes = obs.obs_frontend_get_scenes()
		if scenes ~= nil then
			for _, scene in ipairs(scenes) do
				local name = obs.obs_source_get_name(scene)
    				local source = obs.obs_get_source_by_name(name)
				local sourceWidth = obs.obs_source_get_width(source)
				local sourceHeight = obs.obs_source_get_height(source)
    				local sceneContext = obs.obs_scene_from_source(source)
    				obs.obs_source_release(source)
				on_scene(sceneContext,sourceWidth,sourceHeight)
			end
		 end
		 obs.source_list_release(scenes)
	end
end

function script_load(settings)
	obs.obs_frontend_add_event_callback(on_event)
end
