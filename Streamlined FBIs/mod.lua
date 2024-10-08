if not StreamFBIs then

	Global.streamlined_factions = Global.streamlined_factions or {}

	StreamFBIs = ModInstance

	-- Check faction tweaks
	if not Global.streamlined_factions.checked_fbis then
		Global.streamlined_factions.checked_fbis = true

		local sh = StreamHeist
		if sh and sh.settings and sh.settings.faction_tweaks and sh.settings.faction_tweaks.fbi then
			return
		end

		StreamFBIs:GetSuperMod():GetAssetLoader():LoadAssetGroup("main")
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

	Hooks:PostHook( CharacterTweakData, "character_map", "streamlined_fbis_character_map", function(self)
		local char_map = Hooks:GetReturn()

		safe_add(char_map.basic, "ene_fbi_heavy_r870")

		return char_map
	end )
end
