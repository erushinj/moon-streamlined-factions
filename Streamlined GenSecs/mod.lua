if not StreamGenSecs then

	StreamGenSecs = {
		mod_instance = ModInstance,
		save_path = SavePath .. "streamlined_gensecs.json",
		settings = {
			shields_only = false
		}
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedGenSecs", function(loc)
		loc:add_localized_strings({
			stream_gensecs_menu_main = "Streamlined GenSecs",
			stream_gensecs_menu_main_desc = "Settings require a full game restart to take effect after toggling.",
			stream_gensecs_menu_shields_only = "Shields Only",
			stream_gensecs_menu_shields_only_desc = "When enabled, adds only the new GenSec shield model. Use when playing with another mod that remodels GenSecs. Requires full game restart."
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedGenSecs", function(_, nodes)

		local menu_id = "stream_gensecs_menu"
		MenuHelper:NewMenu(menu_id)

		MenuCallbackHandler.stream_gensecs_setting_toggle = function(self, item)
			StreamGenSecs.settings[item:name()] = (item:value() == "on")
		end

		MenuCallbackHandler.stream_gensecs_save = function()
			io.save_as_json(StreamGenSecs.settings, StreamGenSecs.save_path)
		end

		MenuHelper:AddToggle({
			id = "shields_only",
			title = "stream_gensecs_menu_shields_only",
			desc = "stream_gensecs_menu_shields_only_desc",
			callback = "stream_gensecs_setting_toggle",
			value = StreamGenSecs.settings.shields_only,
			menu_id = menu_id
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "stream_gensecs_save" })
		MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "stream_gensecs_menu_main")

	end )

	-- Load settings
	if io.file_is_readable(StreamGenSecs.save_path) then
		local data = io.load_as_json(StreamGenSecs.save_path)
		if data then
			local function merge(tbl1, tbl2)
				for k, v in pairs(tbl2) do
					if type(tbl1[k]) == type(v) then
						if type(v) == "table" then
							merge(tbl1[k], v)
						else
							tbl1[k] = v
						end
					end
				end
			end
			merge(StreamGenSecs.settings, data)
		end
	end

	-- Check faction tweaks
	if not Global.stream_gensecs_check then
		Global.stream_gensecs_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.gensec then
			return
		end

		local asset_loader = StreamGenSecs.mod_instance.supermod:GetAssetLoader()

		asset_loader:LoadAssetGroup("main")

		if not StreamGenSecs.settings.shields_only then
			asset_loader:LoadAssetGroup("not_shields_only")
		end
	end

end

if RequiredScript == "lib/tweak_data/charactertweakdata" then
	-- Custom maps often break the character_map, need to be safe when adding to it
	local logged_error
	local function safe_add(char_map_table, element)
		if not char_map_table or not char_map_table.list then
			if not logged_error then
				logged_error = true

				log("[Streamlined GenSecs] WARNING: CharacterTweakData:character_map has missing data! One of your mods uses outdated code, check for mods overriding this function!")
			end

			return
		end

		table.insert(char_map_table.list, element)
	end

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_gensecs_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.basic, "ene_city_swat_r870")
		safe_add(char_map.basic, "ene_city_shield")

		return char_map
	end )
end
