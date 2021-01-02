AddCSLuaFile()

ENT.PrintName = "Repeater"
ENT.Category = "Media Player"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Spawnable = true

ENT.Model = Model("models/props_phx/rt_screen.mdl")

ENT.MediaPlayerType = "entity"
ENT.IsMediaPlayerEntity = true

local ErrorModel = "models/error.mdl"

function ENT:Initialize()
    if SERVER then
        if self:GetModel() == ErrorModel then
            self:SetModel( self.Model )
        end

        self:SetUseType( SIMPLE_USE )

        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )

        local phys = self:GetPhysicsObject()
        if IsValid( phys ) then
            phys:EnableMotion( false )
        end
    end

    -- Apply player config based on model
    self.PlayerConfig = self:GetMediaPlayerConfig()
end

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "MediaPlayerID" )
end

function ENT:GetMediaPlayerConfig()
    local model = self:GetModel()
    local MPModelConfigs = list.Get( "MediaPlayerModelConfigs" )
    local config = MPModelConfigs and MPModelConfigs[model] or self.PlayerConfig
    return config
end

if SERVER then
    function ENT:UpdateTransmitState()
        return TRANSMIT_PVS
    end

    function ENT:KeyValue( key, value )
        if key == "model" then
            self.Model = value
        end
    end

    function ENT:AcceptInput( name, activator, caller, data )
        local mp = self:GetMediaPlayer()
        if not IsValid(mp) then return false end

        local ply = IsValid(activator) and activator:IsPlayer() and activator

        if name == "AddPlayer" then
            if ply and not mp:HasListener(ply) then
                mp:AddListener(ply)
            end
        elseif name == "RemovePlayer" then
            if ply and mp:HasListener(ply) then
                mp:RemoveListener(ply)
            end
        elseif name == "RemoveAllPlayers" then
            mp:SetListeners({})
        elseif name == "PlayPauseMedia" then
            mp:PlayPause()
        elseif name == "SkipMedia" then
            mp:OnMediaFinished()
        elseif name == "ClearMedia" then
            mp:ClearMediaQueue()
            mp:OnMediaFinished()
        else
            return false
        end

        return true
    end

    function ENT:SetupMediaPlayer(mp)
    end
end

function ENT:Think()
    local thisOwner = self.CPPIGetOwner and self:CPPIGetOwner() or self:GetOwner()

    if (not self._mp or not IsValid(self._mp)) and thisOwner ~= CPPI.CPPI_DEFER then
        local toFind = ents.FindByClass("mediaplayer_tv")
        table.Add(toFind, ents.FindByClass("mediaplayer_projector"))

        for _, ent in pairs(toFind) do
            local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
            if not IsValid(ent) or owner == CPPI.CPPI_DEFER or owner ~= thisOwner then continue end

            self._mp = ent:GetMediaPlayer()
            if self._mp then
                self:SetupMediaPlayer(self._mp)
                self._mp.Entity = ent

                break
            end
        end
    end
end

if CLIENT then
    local draw = draw
    local surface = surface
    local Start3D2D = cam.Start3D2D
    local End3D2D = cam.End3D2D
    local DrawHTMLMaterial = DrawHTMLMaterial

    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
    local color_white = color_white

    local StaticMaterial = Material( "theater/STATIC" )
    local TextScale = 700

    local RenderScale = 0.1
    local InfoScale = 1 / 17
    local BaseInfoHeight = 60
    local FullscreenCvar = MediaPlayer.Cvars.Fullscreen
    function ENT:SetupMediaPlayer(mp)
        local function Draw(s, bDrawingDepth, bDrawingSkybox)
            local ent = s
            local _mp = s:GetMediaPlayer()

            if --bDrawingSkybox or
                    FullscreenCvar:GetBool() or -- Don't draw if we're drawing fullscreen
                    not IsValid(ent) or
                    (ent.IsDormant and ent:IsDormant()) or (not _mp or not IsValid(_mp)) then
                return
            end

            local media = _mp:GetMedia()
            local w, h, pos, ang = s:GetMediaPlayerPosition()

            -- Render scale
            local rw, rh = w / RenderScale, h / RenderScale

            if IsValid(media) then

                -- Custom media draw function
                if media.Draw then
                    Start3D2D( pos, ang, RenderScale )
                        media:Draw( rw, rh )
                    End3D2D()
                end
                -- TODO: else draw 'not yet implemented' screen?

                -- scale based off of height
                local scale = InfoScale * ( h / BaseInfoHeight )

                -- Media info
                Start3D2D( pos, ang, scale )
                    local iw, ih = w / scale, h / scale
                    _mp:DrawMediaInfo( media, iw, ih )
                End3D2D()

            else

                Start3D2D( pos, ang, RenderScale )
                    _mp:DrawIdlescreen( rw, rh )
                End3D2D()

            end
        end
        hook.Add("PostDrawOpaqueRenderables", self, Draw)
    end

    function ENT:Draw()
        self:DrawModel()

        local mp = self:GetMediaPlayer()

        if not mp or not IsValid(mp) then
            self:DrawMediaPlayerOff()
        end
    end

    local HTMLMAT_STYLE_ARTWORK_BLUR = "htmlmat.style.artwork_blur"
    AddHTMLMaterialStyle( HTMLMAT_STYLE_ARTWORK_BLUR, {
        width = 720,
        height = 480
    }, HTMLMAT_STYLE_BLUR )

    function ENT:DrawMediaPlayerOff()
        local w, h, pos, ang = self:GetMediaPlayerPosition()

        Start3D2D( pos, ang, 1 )
            surface.SetDrawColor( color_white )
            surface.SetMaterial( StaticMaterial )
            surface.DrawTexturedRect( 0, 0, w, h )
        End3D2D()

        local scale = w / TextScale
        Start3D2D( pos, ang, scale )
            local tw, th = w / scale, h / scale
            draw.SimpleText( "Awaiting Source...", "MediaTitle",
                tw / 2, th / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        End3D2D()
    end
end
