if not StreamFederales then

	StreamFederales = {
		mod_instance = ModInstance,
		save_path = SavePath .. "streamlined_federales.json",
		settings = {
			shields_only = false
		}
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedFederales", function(loc)
		loc:add_localized_strings({
			stream_federales_menu_main = "Streamlined Federales",
			stream_federales_menu_main_desc = "Settings require a full game restart to take effect after toggling.",
			stream_federales_menu_shields_only = "Shields Only",
			stream_federales_menu_shields_only_desc = "When enabled, adds only the new Policia Federal shield model. Use when playing with another mod that remodels Federales. Requires full game restart."
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedFederales", function(_, nodes)

		local menu_id = "stream_federales_menu"
		MenuHelper:NewMenu(menu_id)

		MenuCallbackHandler.stream_federales_setting_toggle = function(self, item)
			StreamFederales.settings[item:name()] = (item:value() == "on")
		end

		MenuCallbackHandler.stream_federales_save = function()
			io.save_as_json(StreamFederales.settings, StreamFederales.save_path)
		end

		MenuHelper:AddToggle({
			id = "shields_only",
			title = "stream_federales_menu_shields_only",
			desc = "stream_federales_menu_shields_only_desc",
			callback = "stream_federales_setting_toggle",
			value = StreamFederales.settings.shields_only,
			menu_id = menu_id
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "stream_federales_save" })
		MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "stream_federales_menu_main")

	end )

	-- Load settings
	if io.file_is_readable(StreamFederales.save_path) then
		local data = io.load_as_json(StreamFederales.save_path)
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
			merge(StreamFederales.settings, data)
		end
	end

	-- Check faction tweaks
	if not Global.stream_federales_check then
		Global.stream_federales_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.federales then
			return
		end

		local asset_loader = StreamFederales.mod_instance.supermod:GetAssetLoader()

		asset_loader:LoadAssetGroup("main")

		if not StreamFederales.settings.shields_only then
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

				log("[Streamlined Federales] WARNING: CharacterTweakData:character_map has missing data! One of your mods uses outdated code, check for mods overriding this function!")
			end

			return
		end

		table.insert(char_map_table.list, element)
	end

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_federales_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.bex, "ene_swat_policia_federale_fbi")
		safe_add(char_map.bex, "ene_swat_policia_federale_fbi_r870")

		return char_map
	end )
end
