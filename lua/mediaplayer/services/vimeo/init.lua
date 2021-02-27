AddCSLuaFile "shared.lua"
include "shared.lua"

local MetadataUrl = "http://vimeo.com/api/v2/video/%s.json"

local function OnReceiveMetadata( self, callback, body )

	local metadata = {}

	local data = util.JSONToTable( body )
	if not data then
		return callback( false, "Failed to parse video's metadata response." )
	end

	data = data[1]

	metadata.title		= data.title
	metadata.duration	= data.duration
	metadata.thumbnail	= data.thumbnail_medium

	self:SetMetadata(metadata, true)

	callback(self._metadata)

end

function SERVICE:GetMetadata( callback )
	if self._metadata then
		callback( self._metadata )
		return
	end
	local videoId = self:GetVimeoVideoId()
	local apiurl = MetadataUrl:format( videoId )

	self:Fetch( apiurl,
		function( body, length, headers, code )
			OnReceiveMetadata( self, callback, body )
		end,
		function( code )
			callback(false, "Failed to load Vimeo ["..tostring(code).."]")
		end
	)
end
