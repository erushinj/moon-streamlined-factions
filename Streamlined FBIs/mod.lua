if not StreamFBIs then

	StreamFBIs = {
		mod_instance = ModInstance
	}

	-- Check faction tweaks
	if not Global.stream_fbis_check then
		Global.stream_fbis_check = true

		if StreamHeist and StreamHeist.settings.faction_tweaks.fbi then
			return
		end

		StreamFBIs.mod_instance.supermod:GetAssetLoader():LoadAssetGroup("main")
	end

end

if RequiredScript == "lib/tweak_data/charactertweakdata" then
	-- Custom maps often break the character_map, need to be safe when adding to it
	local logged_error
	local function safe_add(char_map_table, element)
		if not char_map_table or not char_map_table.list then
			if not logged_error then
				logged_error = true

				log("[Streamlined FBIs] WARNING: CharacterTweakData:character_map has missing data! One of your mods uses outdated code, check for mods overriding this function!")
			end

			return
		end

		table.insert(char_map_table.list, element)
	end

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_fbis_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.basic, "ene_fbi_heavy_r870")

		return char_map
	end )
end
