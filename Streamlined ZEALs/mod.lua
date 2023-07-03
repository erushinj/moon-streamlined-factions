if not StreamZEALs then

	StreamZEALs = {
		mod_instance = ModInstance,
		save_path = SavePath .. "streamlined_zeals.json",
		settings = {
			zeal_medic = true
		}
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedZEALs", function(loc)
		loc:add_localized_strings({
			stream_zeals_menu_main = "Streamlined ZEALs",
			stream_zeals_menu_zeal_medic = "ZEAL Medic",
			stream_zeals_menu_zeal_medic_desc = "When enabled, dynamically replaces Medic textures with ZEAL variant when playing on Death Sentence difficulty."
		})
	end )

	Hooks:Add( "MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusStreamlinedZEALs", function(_, nodes)

		local menu_id = "stream_zeals_menu"
		MenuHelper:NewMenu(menu_id)

		MenuCallbackHandler.stream_zeals_setting_toggle = function(self, item)
			StreamZEALs.settings[item:name()] = (item:value() == "on")
		end

		MenuCallbackHandler.stream_zeals_save = function()
			io.save_as_json(StreamZEALs.settings, StreamZEALs.save_path)
		end

		MenuHelper:AddToggle({
			id = "zeal_medic",
			title = "stream_zeals_menu_zeal_medic",
			desc = "stream_zeals_menu_zeal_medic_desc",
			callback = "stream_zeals_setting_toggle",
			value = StreamZEALs.settings.zeal_medic,
			menu_id = menu_id
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "stream_zeals_save" })
		MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "stream_zeals_menu_main")

	end )

	-- Load settings
	if io.file_is_readable(StreamZEALs.save_path) then
		local data = io.load_as_json(StreamZEALs.save_path)
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
			merge(StreamZEALs.settings, data)
		end
	end

	-- Check faction tweaks
	if not Global.stream_zeals_check then
		Global.stream_zeals_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.zeal then
			return
		end

		StreamZEALs.mod_instance.supermod:GetAssetLoader():LoadAssetGroup("main")
	end

end

if StreamHeist then
	return
end

if RequiredScript == "lib/units/enemies/cop/copbase" then
	local is_sm_wish = Global.game_settings and Global.game_settings.difficulty == "sm_wish"

	local head_df = is_sm_wish and Idstring("units/payday2/characters/shared_textures/zeal_medic_head_df")
	or Idstring("units/payday2/characters/shared_textures/ene_medic_head_df")

	local body_df = is_sm_wish and Idstring("units/payday2/characters/shared_textures/zeal_medic_df")
	or Idstring("units/payday2/characters/shared_textures/ene_medic_df")

	local medic_head = {
		diffuse_texture = head_df
	}
	local medic_body = {
		diffuse_texture = body_df
	}

	local medic_materials = {
		mtr_head = medic_head,
		mtr_swat = medic_body,
		mtr_ene_acc_swat_helmet = medic_head,
		mat_light = medic_head,
	}

	local unit_data = {
		["units/payday2/characters/ene_medic_m4/ene_medic_m4"] = medic_materials,
		["units/payday2/characters/ene_medic_r870/ene_medic_r870"] = medic_materials
	}

	local zeal_materials = {}
	for u_name, u_materials in pairs(unit_data) do
		local materials = {}
		for m_name, m_data in pairs(u_materials) do
			materials[m_name] = m_data
			materials[m_name .. "_lod1"] = m_data
			materials[m_name .. "_lod2"] = m_data
			materials[m_name .. "_lod_1"] = m_data
			materials[m_name .. "_lod_2"] = m_data
		end

		zeal_materials[u_name:key()] = materials
		zeal_materials[(u_name .. "_contour"):key()] = materials
	end

	local zeal_materials_applied = {}

	local function chk_apply_zeal_medic_material(cop, force)
		if not zeal_materials then
			return
		end

		local mat_config_key = cop._unit:material_config():key()
		local materials = zeal_materials[mat_config_key] or force and zeal_materials_applied[mat_config_key]
		if not materials then
			return
		end

		for m_name, m_data in pairs(materials) do
			local material = cop._unit:material(Idstring(m_name))
			if material then
				for texture_type, texture in pairs(m_data) do
					Application:set_material_texture(material, Idstring(texture_type), texture)
				end
			end
		end

		-- Base material only needs to be set once since it is shared
		zeal_materials[mat_config_key] = nil
		zeal_materials_applied[mat_config_key] = materials
	end

	Hooks:PostHook(CopBase, "on_material_applied", "stream_zeals_on_material_applied", function(self)
		chk_apply_zeal_medic_material(self, true)
	end)

	Hooks:PostHook(CopBase, "init", "stream_zeals_init", function(self)
		chk_apply_zeal_medic_material(self, false)
	end)
end