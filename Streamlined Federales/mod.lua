if not StreamFederales then

	Global.streamlined_factions = Global.streamlined_factions or {}

	StreamFederales = ModInstance
	StreamFederales.save_path = SavePath .. "streamlined_federales.json"
	StreamFederales.settings = {
		shields_only = false,
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedFederales", function(loc)
		loc:add_localized_strings({
			stream_federales_menu_main = "Streamlined Federales",
			stream_federales_menu_main_desc = "Settings require a full game restart to take effect after toggling.",
			stream_federales_menu_shields_only = "Shields Only",
			stream_federales_menu_shields_only_desc = "When enabled, adds only the new Policia Federal shield model. Use when playing with another mod that remodels Federales. Requires full game restart.",
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedFederales", function(_, nodes)

		local menu_id = "stream_federales_menu"
		MenuHelper:NewMenu(menu_id)

		function MenuCallbackHandler:stream_federales_setting_toggle(item)
			StreamFederales.settings[item:name()] = (item:value() == "on")
		end

		function MenuCallbackHandler:stream_federales_save()
			io.save_as_json(StreamFederales.settings, StreamFederales.save_path)
		end

		MenuHelper:AddToggle({
			id = "shields_only",
			title = "stream_federales_menu_shields_only",
			desc = "stream_federales_menu_shields_only_desc",
			callback = "stream_federales_setting_toggle",
			value = StreamFederales.settings.shields_only,
			menu_id = menu_id,
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
	if not Global.streamlined_factions.checked_federales then
		Global.streamlined_factions.checked_federales = true

		local sh = StreamHeist
		if sh and sh.settings and sh.settings.faction_tweaks and sh.settings.faction_tweaks.federales then
			return
		end

		local asset_loader = StreamFederales:GetSuperMod():GetAssetLoader()

		asset_loader:LoadAssetGroup("main")

		if not StreamFederales.settings.shields_only then
			asset_loader:LoadAssetGroup("not_shields_only")
		end
	end

end

if RequiredScript == "lib/tweak_data/charactertweakdata" then
	-- Custom maps often break the character_map, need to be safe when adding to it
	local function safe_add(char_map_table, element)
		if not char_map_table or not char_map_table.list then
			if not Global.streamlined_factions.logged_error then
				Global.streamlined_factions.logged_error = true

				log("[Streamlined Factions] WARNING: CharacterTweakData:character_map has missing data! One of your mods uses outdated code, check for mods overriding this function!")
			end

			return
		end

		if not table.contains(char_map_table.list, element) then
			table.insert(char_map_table.list, element)
		end
	end

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_federales_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.bex, "ene_swat_policia_federale_fbi")
		safe_add(char_map.bex, "ene_swat_policia_federale_fbi_r870")

		return char_map
	end )
end
