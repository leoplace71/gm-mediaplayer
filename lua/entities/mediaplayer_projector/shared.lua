AddCSLuaFile()

DEFINE_BASECLASS("mediaplayer_base")

ENT.PrintName = "Projector"
ENT.Category = "Media Player"

ENT.Type = "anim"
ENT.Base = "mediaplayer_base"

ENT.Spawnable = true

ENT.Model = Model("models/dav0r/camera.mdl")

ENT.PlayerConfig = {
	offset = Vector(512, -512, 256),
	angle  = Angle(0, -90, 90),
	width  = 1024,
	height = 512
}

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "String", 1, "MediaThumbnail" )
end

if SERVER then
    function ENT:SetupMediaPlayer( mp )
        mp:on("mediaChanged", function(media) self:OnMediaChanged(media) end)
    end

    function ENT:OnMediaChanged( media )
        self:SetMediaThumbnail( media and media:Thumbnail() or "" )
    end
else -- CLIENT
    local draw = draw
    local surface = surface
    local Start3D2D = cam.Start3D2D
    local End3D2D = cam.End3D2D
    local DrawHTMLMaterial = DrawHTMLMaterial

    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
    local color_white = color_white

    local StaticMaterial = Material( "theater/STATIC" )

    function ENT:ProjectorTrace()
        local filter = player.GetAll()
        filter[#filter + 1] = self

        local dir = self:GetForward() * 4000

        local tr = util.QuickTrace(self:LocalToWorld(self:OBBCenter()), dir, filter)

        return tr
    end

     local InfoScale = 1 / 17
    local BaseInfoHeight = 60
    local FullscreenCvar = MediaPlayer.Cvars.Fullscreen
    function ENT:SetupMediaPlayer( mp )
        local function Draw(s, depth, skybox)
            local ent = s.Entity

            if FullscreenCvar:GetBool() or not IsValid(ent) or (ent.IsDormant and ent:IsDormant()) then return end

            local media = s:GetMedia()
            local w, h, pos, ang = s:GetOrientation()

            local tr = ent:ProjectorTrace()

            local scale = 1

            if tr.Hit then
                scale = tr.HitPos:Distance(ent:LocalToWorld(ent:OBBCenter())) * 0.001
                ang = tr.HitNormal:Angle()
                ang:RotateAroundAxis(ang:Up(), 90)
                ang:RotateAroundAxis(ang:Forward(), 90)
                pos = tr.HitPos - ang:Right() * (h / 2 * scale) - ang:Forward() * (w / 2 * scale) + ang:Up() * 2
            end

            if IsValid(media) then
                if media.Draw then
                    Start3D2D( pos, ang, scale )
                        media:Draw( w, h )
                    End3D2D()
                end
                -- TODO: else draw 'not yet implemented' screen?

                -- scale based off of height
                local iscale = InfoScale * ( h / BaseInfoHeight ) * scale

                -- Media info
                Start3D2D( pos, ang, iscale )
                    local iw, ih = w / iscale * scale, h / iscale * scale
                    s:DrawMediaInfo( media, iw, ih )
                End3D2D()
            else
                Start3D2D( pos, ang, scale )
                    s:DrawIdlescreen( w, h )
                End3D2D()
            end
        end

        hook.Add("PostDrawOpaqueRenderables", mp, Draw)
    end

    function ENT:Draw()
        self:DrawModel()

        local mp = self:GetMediaPlayer()

        if not mp then
            self:DrawMediaPlayerOff()
        end
    end

    local HTMLMAT_STYLE_ARTWORK_BLUR = "htmlmat.style.artwork_blur"
    AddHTMLMaterialStyle( HTMLMAT_STYLE_ARTWORK_BLUR, {
        width = 720,
        height = 480
    }, HTMLMAT_STYLE_BLUR )

    local DrawThumbnailsCvar = MediaPlayer.Cvars.DrawThumbnails

    function ENT:DrawMediaPlayerOff()
        local w, h, pos, ang = self:GetMediaPlayerPosition()
        local thumbnail = self:GetMediaThumbnail()

        local tr = self:ProjectorTrace()

        local scale = 1

        if tr.Hit then
            scale = tr.HitPos:Distance(self:LocalToWorld(self:OBBCenter())) * 0.001
            ang = tr.HitNormal:Angle()
            ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            pos = tr.HitPos - ang:Right() * (h / 2 * scale) - ang:Forward() * (w / 2 * scale) + ang:Up() * 2
        end

        Start3D2D( pos, ang, scale )
            if DrawThumbnailsCvar:GetBool() and thumbnail != "" then
                DrawHTMLMaterial( thumbnail, HTMLMAT_STYLE_ARTWORK_BLUR, w, h )
            else
                surface.SetDrawColor( color_white )
                surface.SetMaterial( StaticMaterial )
                surface.DrawTexturedRect( 0, 0, w, h )
            end

            draw.SimpleText( "Press E to begin watching", "MediaTitle",
                w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        End3D2D()
    end
end
