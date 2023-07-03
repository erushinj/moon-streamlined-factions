if not StreamMurkies then

	StreamMurkies = {
		mod_instance = ModInstance,
		save_path = SavePath .. "streamlined_murkies.json",
		settings = {
			fixed_body_armour = false
		}
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedMurkies", function(loc)
		loc:add_localized_strings({
			stream_murkies_menu_main = "Streamlined Murkies",
			stream_murkies_menu_main_desc = "Settings require a full game restart to take effect after toggling.",
			stream_murkies_menu_fixed_body_armour = "Fixed Body Armour",
			stream_murkies_menu_fixed_body_armour_desc = "When enabled, fixes the backside of Murky heavy units being bulletproof. Requires full game restart."
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedMurkies", function(_, nodes)

		local menu_id = "stream_murkies_menu"
		MenuHelper:NewMenu(menu_id)

		MenuCallbackHandler.stream_murkies_setting_toggle = function(self, item)
			StreamMurkies.settings[item:name()] = (item:value() == "on")
		end

		MenuCallbackHandler.stream_murkies_save = function()
			io.save_as_json(StreamMurkies.settings, StreamMurkies.save_path)
		end

		MenuHelper:AddToggle({
			id = "fixed_body_armour",
			title = "stream_murkies_menu_fixed_body_armour",
			desc = "stream_murkies_menu_fixed_body_armour_desc",
			callback = "stream_murkies_setting_toggle",
			value = StreamMurkies.settings.fixed_body_armour,
			menu_id = menu_id
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "stream_murkies_save" })
		MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "stream_murkies_menu_main")

	end )

	-- Load settings
	if io.file_is_readable(StreamMurkies.save_path) then
		local data = io.load_as_json(StreamMurkies.save_path)
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
			merge(StreamMurkies.settings, data)
		end
	end

	-- Check faction tweaks
	if not Global.stream_murkies_check then
		Global.stream_murkies_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.murkywater then
			return
		end

		local asset_loader = StreamMurkies.mod_instance.supermod:GetAssetLoader()

		asset_loader:LoadAssetGroup("main")

		if StreamMurkies.settings.fixed_body_armour then
			asset_loader:LoadAssetGroup("fixed_body_armour")
		else
			asset_loader:LoadAssetGroup("not_fixed_body_armour")
		end
	end

end
