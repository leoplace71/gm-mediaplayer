local MediaPlayerClass = "mediaplayer_tv"

local function AddMediaPlayerModel( spawnName, name, model, playerConfig )
	list.Set( "SpawnableEntities", spawnName, {
		PrintName = name,
		ClassName = MediaPlayerClass,
		Category = "Media Player",
		DropToFloor = true,
		KeyValues = {
			model = model
		}
	} )

	list.Set( "MediaPlayerModelConfigs", model, playerConfig )
end

AddMediaPlayerModel(
	"../spawnicons/models/hunter/plates/plate5x8",
	"Huge Billboard",
	"models/hunter/plates/plate5x8.mdl",
	{
		angle = Angle(0, 90, 0),
		offset = Vector(-118.8, 189.8, 2.5),
		width = 380,
		height = 238
	}
)

AddMediaPlayerModel(
	"../spawnicons/models/props_phx/rt_screen",
	"Small TV",
	"models/props_phx/rt_screen.mdl",
	{
		angle = Angle(-90, 90, 0),
		offset = Vector(6.5, 27.9, 35.3),
		width = 56,
		height = 33
	}
)

-- Сustom

AddMediaPlayerModel(
	"../spawnicons/models/hunter/plates/plate8x8",
	"Huge Billboard x2",
	"models/hunter/plates/plate8x8.mdl",
	{
		angle = Angle(0, 90, 0),
		offset = Vector(-237.6, 379,6.8, 5),
		width = 760,
		height = 476
	}
)

AddMediaPlayerModel(
	"../spawnicons/models/hunter/plates/plate1x1",
	"Special Screen 1x1",
	"models/hunter/plates/plate1x1.mdl",
	{
		angle = Angle(0, 90, 0),
		offset = Vector(-23.5, 23.5, 1.8),
		width = 47.5,
		height = 47.5
	}
)

if SERVER then

	-- fix for media player owner not getting set on alternate model spawn
	hook.Add( "PlayerSpawnedSENT", "MediaPlayer.SetOwner", function(ply, ent)
		if not ent.IsMediaPlayerEntity then return end
		ent:SetCreator(ply)
		local mp = ent:GetMediaPlayer()
		mp:SetOwner(ply)
	end )

end
