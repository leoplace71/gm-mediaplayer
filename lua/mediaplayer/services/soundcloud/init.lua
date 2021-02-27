AddCSLuaFile "shared.lua"
include "shared.lua"

local urllib = url

local ClientId = MediaPlayer.GetConfigValue('soundcloud.client_id')

-- http://developers.soundcloud.com/docs/api/reference
local MetadataUrl = {
	resolve = "http://api.soundcloud.com/resolve.json?url=%s&client_id=" .. ClientId,
	tracks = ""
}

local function OnReceiveMetadata( self, callback, body )
	local resp = util.JSONToTable(body)
	if not resp then
		callback(false)
		return
	end

	if resp.errors then
		callback(false, "The requested SoundCloud song wasn't found")
		return
	end

	local artist = resp.user and resp.user.username or "[Unknown artist]"
	local stream = resp.stream_url

	if not stream then
		callback(false, "The requested SoundCloud song doesn't allow streaming")
		return
	end

	local thumbnail = resp.artwork_url
	if thumbnail then
		thumbnail = string.Replace( thumbnail, 'large', 't500x500' )
	end

	-- http://developers.soundcloud.com/docs/api/reference#tracks
	local metadata = {}
	metadata.title		= (resp.title or "[Unknown title]") .. " - " .. artist
	metadata.duration	= math.ceil(tonumber(resp.duration) / 1000) -- responds in ms
	metadata.thumbnail	= thumbnail

	metadata.extra = {
		stream = stream
	}

	self:SetMetadata(metadata, true)

	self.url = stream .. "?client_id=" .. ClientId

	callback(self._metadata)
end

function SERVICE:GetMetadata( callback )
	if self._metadata then
		callback( self._metadata )
		return
	end
	-- TODO: predetermine if we can skip the call to /resolve; check for
	-- /track or /playlist in the url path.

	local apiurl = MetadataUrl.resolve:format( self.url )

	self:Fetch( apiurl,
		function( body, length, headers, code )
			OnReceiveMetadata( self, callback, body )
		end,
		function( code )
			callback(false, "Failed to load SoundCloud ["..tostring(code).."]")
		end
	)
end
