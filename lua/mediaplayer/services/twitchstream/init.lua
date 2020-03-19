AddCSLuaFile "shared.lua"
include "shared.lua"

local urllib = url

local APIKey = MediaPlayer.GetConfigValue('twitch.client_id')
local MetadataUrl = "https://api.twitch.tv/helix/streams?user_login=%s"

local function OnReceiveMetadata( self, callback, body )

	local metadata = {}

	local response = util.JSONToTable( body )
	if not response then
		callback(false)
		return
	end

	local stream = response.data[1]

	if not stream then
		return callback( false, "Twitch.TV: The requested stream was offline" )
	end

	local thumbnail = stream.thumbnail_url
	thumbnail = thumbnail:Replace("{width}", "1280")
	thumbnail = thumbnail:Replace("{height}", "720")

	metadata.title = stream and stream.title or "Twitch.TV Stream"
	metadata.thumbnail = thumbnail

	self:SetMetadata(metadata, true)

	callback(self._metadata)

end

function SERVICE:GetMetadata( callback )

	if self._metadata then
		callback( self._metadata )
		return
	end

	local channel = self:GetTwitchChannel()
	local apiurl = MetadataUrl:format( channel )

	self:Fetch( apiurl,
		function( body, length, headers, code )
			OnReceiveMetadata( self, callback, body )
		end,
		function( code )
			callback(false, "Failed to load Twitch.TV ["..tostring(code).."]")
		end,
		{ -- Twitch.TV API Helix headers
			["Client-ID"] = APIKey
		}
	)

end