if not StreamMercs then

	StreamMercs = {
		mod_instance = ModInstance,
		save_path = SavePath .. "streamlined_mercs.json",
		settings = {
			n_h_light_units = true
		}
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedMercs", function(loc)
		loc:add_localized_strings({
			stream_mercs_menu_main = "Streamlined Mercs",
			stream_mercs_menu_n_h_light_units = "Change Normal/Hard Light Units",
			stream_mercs_menu_n_h_light_units_desc = "When disabled, keeps the light and Shield units seen on Normal and Hard the same as vanilla. Use when playing with a mod that adds them to other difficulties. Requires full game restart."
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedMercs", function(_, nodes)

		local menu_id = "stream_mercs_menu"
		MenuHelper:NewMenu(menu_id)

		MenuCallbackHandler.stream_mercs_setting_toggle = function(self, item)
			StreamMercs.settings[item:name()] = (item:value() == "on")
		end

		MenuCallbackHandler.stream_mercs_save = function()
			io.save_as_json(StreamMercs.settings, StreamMercs.save_path)
		end

		MenuHelper:AddToggle({
			id = "n_h_light_units",
			title = "stream_mercs_menu_n_h_light_units",
			desc = "stream_mercs_menu_n_h_light_units_desc",
			callback = "stream_mercs_setting_toggle",
			value = StreamMercs.settings.n_h_light_units,
			menu_id = menu_id
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "stream_mercs_save" })
		MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "stream_mercs_menu_main")

	end )

	-- Load settings
	if io.file_is_readable(StreamMercs.save_path) then
		local data = io.load_as_json(StreamMercs.save_path)
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
			merge(StreamMercs.settings, data)
		end
	end

	-- Check faction tweaks
	if not Global.stream_mercs_check then
		Global.stream_mercs_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.russia then
			return
		end

		local asset_loader = StreamMercs.mod_instance.supermod:GetAssetLoader()

		asset_loader:LoadAssetGroup("main")

		if StreamMercs.settings.n_h_light_units then
			asset_loader:LoadAssetGroup("n_h_light_units")
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

				log("[Streamlined Mercs] WARNING: CharacterTweakData:character_map has missing data! One of your mods uses outdated code, check for mods overriding this function!")
			end

			return
		end

		table.insert(char_map_table.list, element)
	end

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_mercs_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.mad, "ene_akan_fbi_heavy_r870")
		safe_add(char_map.mad, "ene_akan_fbi_shield_dw_sr2_smg")
		safe_add(char_map.mad, "ene_akan_cs_heavy_r870")

		return char_map
	end )
end
