local lang = GetConVar("gmod_language"):GetString() or "en"

local function reloadlang()
	if lang == "en-PT" then
		language.Add( "mediaplayer_SEARCH_FOR_MEDIA", "GET OUT YER SPYGLASS" )
		language.Add( "mediaplayer_REQUEST_URL", "OFFER URL" )
		language.Add( "mediaplayer_ADDED_BY", "OFFERED BY" )
		language.Add( "mediaplayer_Unknown", "Uncharted Waters" )
		language.Add( "mediaplayer_Favorited", "Marked" )
		language.Add( "mediaplayer_NEXT_UP", "NEXT OFFER" )
		language.Add( "mediaplayer_ADD_MEDIA", "SET SAILS" )
		language.Add( "mediaplayer_CURRENTLY_PLAYING", "CURRENTLY PLAYIN'" )
	else
		language.Add( "mediaplayer_SEARCH_FOR_MEDIA", "SEARCH FOR MEDIA" )
		language.Add( "mediaplayer_REQUEST_URL", "REQUEST URL" )
		language.Add( "mediaplayer_ADDED_BY", "ADDED BY" )
		language.Add( "mediaplayer_Unknown", "Unknown" )
		language.Add( "mediaplayer_Favorited", "Favorited" )
		language.Add( "mediaplayer_NEXT_UP", "NEXT UP" )
		language.Add( "mediaplayer_ADD_MEDIA", "ADD MEDIA" )
		language.Add( "mediaplayer_CURRENTLY_PLAYING", "CURRENTLY PLAYING" )
	end
end

reloadlang()

cvars.AddChangeCallback( "gmod_language", function(onvar_name, value_old, value_new)
	lang = value_new
	reloadlang()
end)