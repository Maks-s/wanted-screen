include('shared.lua')

--[[-------------------------------------------------------------------------
	Update
---------------------------------------------------------------------------]]

net.Receive( "S:WantedScreen:Update", function()
	local tblEnts = net.ReadTable() or {}

	for k,v in pairs( tblEnts ) do
		if IsValid( v ) then
			v:StartLoading( true )
		end
	end
end)

--[[-------------------------------------------------------------------------
	Animation
---------------------------------------------------------------------------]]

local tblNextWanted = {}
local tblLastWanted = {}
local nextLetter = 0
local nextLetterNum = 0
local textToDisplay = ""

--[[-------------------------------------------------------------------------
	Materials
---------------------------------------------------------------------------]]

local matIcon = Material( "materials/slownls/wanted_screen/siren.png" )
local matIconBg = Material( "materials/slownls/wanted_screen/bg.jpg" )
local matIconLoad = Material( "materials/slownls/wanted_screen/loader.png" )

--[[-------------------------------------------------------------------------
	Model
---------------------------------------------------------------------------]]

SAddons.WantedScreen.Mdl = vgui.Create( "ModelImage" )
SAddons.WantedScreen.Mdl:SetSize( 325, SAddons.WantedScreen.DoScroll && 300 || 325 )
SAddons.WantedScreen.Mdl:SetVisible( false )
SAddons.WantedScreen.Mdl:SetPaintedManually( true )

--[[-------------------------------------------------------------------------
	Wanted message too long
---------------------------------------------------------------------------]]

local specialReason = {}

hook.Add( "DarkRPVarChanged", "S-Wanted-Screen:Wanted:Manipulation", function( ply, var, _, value )
	if var == "wantedReason" then
		if value then
			surface.SetFont( "Trebuchet24" )

			if surface.GetTextSize( value ) > 270 then
				local newReason = ""
				specialReason[ ply ] = {}

				for i=1, #value do
					if value[i] == "\n" then continue end -- ignore les retour a la ligne
					if surface.GetTextSize( newReason .. value[i] ) >= 270 then
						table.insert( specialReason[ ply ], newReason )
						newReason = value[i]
						continue
					end
					newReason = newReason .. value[i]
				end
				table.insert( specialReason[ ply ], newReason )
			end
		else
			specialReason[ ply ] = nil
		end
	end
end)

--[[-------------------------------------------------------------------------
	Nice television
---------------------------------------------------------------------------]]

function ENT:StartLoading( boolP )
	if boolP then
		if !IsValid( self:GetPlayerWanted() ) then self.Loaded = true return end
	end

	self.Loaded = false

	timer.Simple( math.Rand( 1, 2 ), function()
		self.Loaded = true
	end)
end

function ENT:Initialize()
	if SAddons.WantedScreen.DoFade then
		tblNextWanted[self] = {}
		tblLastWanted[self] = {}
		self:CallOnRemove("RemoveFromLastWanted",function( ent )
			tblNextWanted[self] = nil
			tblLastWanted[self] = nil
		end)
	else
		self:StartLoading( false )
	end
end

function ENT:Draw()
	self:DrawModel()

	if SAddons.WantedScreen.ViewDistance > 0 && self:GetPos():DistToSqr( LocalPlayer():GetPos() ) > SAddons.WantedScreen.ViewDistance*SAddons.WantedScreen.ViewDistance then return end

	local ply = self:GetPlayerWanted()

	if ply:IsValid() && ply:isWanted() && ValidPanel( SAddons.WantedScreen.Mdl ) then
		SAddons.WantedScreen.Mdl:SetPos( 5, 5 )
		SAddons.WantedScreen.Mdl:SetVisible( true )

		local plyModel = ply:GetModel()

		if !SAddons.WantedScreen.Mdl.Mdl || SAddons.WantedScreen.Mdl.Mdl ~= plyModel || ( SAddons.WantedScreen.DoFade && !tblNextWanted[self][1] ) then
			if SAddons.WantedScreen.DoFade then
				tblNextWanted[self] = {
					CurTime() + SAddons.WantedScreen.FadeDuration,
					plyModel,
					ply,
					ply:UserID(),
				}
			else
				SAddons.WantedScreen.Mdl:SetModel( plyModel )
			end

			SAddons.WantedScreen.Mdl.Mdl = plyModel
		end
		
		if SAddons.WantedScreen.DoFade && tblNextWanted[self][1] < CurTime() then
			tblLastWanted[self] = {
				ply:Nick(),
				specialReason[ ply ] || ply:getDarkRPVar('wantedReason'),
				ply:UserID(),
			}
		end
	end
	
	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	local pos = self:GetPos()
	pos = pos + self:GetAngles():Right() * 27.9
	pos = pos + self:GetAngles():Forward() * 6
	pos = pos + self:GetAngles():Up() * 36

    cam.Start3D2D( pos, ang, 0.1 )
	    draw.RoundedBox( 6, 0, 0, 558, 335, Color( 30, 30, 30, 255 ) )

	    surface.SetDrawColor( color_white )
		surface.SetMaterial( matIconBg )
		surface.DrawTexturedRect( 0, 0, 558, 335 )

		if !(SAddons.WantedScreen.DoFade || self.Loaded) then
	    	surface.SetDrawColor( color_white )
			surface.SetMaterial( matIconLoad )
			surface.DrawTexturedRectRotated( 558 / 2, 335 / 2, 128, 128, CurTime() * - 100 )
			cam.End3D2D()
			return
		end

 		if ply:IsValid() && ply:isWanted() then
			if ValidPanel( SAddons.WantedScreen.Mdl ) then
        		SAddons.WantedScreen.Mdl:PaintManual()
        	end

			surface.SetFont( "DermaLarge" )

        	if SAddons.WantedScreen.DoScroll then
				if nextLetter < CurTime() then
					local newText = string.sub( textToDisplay, 2, -1 )
					newText = newText .. SAddons.WantedScreen.ScrollText[nextLetterNum]

					local charNum = #SAddons.WantedScreen.ScrollText
					while surface.GetTextSize( newText ) <= 580 do
						nextLetterNum = nextLetterNum + 1
						if nextLetterNum > charNum then
							nextLetterNum = 1
						end
						newText = newText .. SAddons.WantedScreen.ScrollText[nextLetterNum]
					end
					newText = string.sub( newText, 1, -2 )

					textToDisplay = newText
					nextLetter = CurTime() + SAddons.WantedScreen.ScrollSpeed
				end

				-- smoothy
				local pos = surface.GetTextSize( textToDisplay[ 1 ] ) - surface.GetTextSize( textToDisplay[ 1 ] ) * ( ( nextLetter - CurTime() ) / SAddons.WantedScreen.ScrollSpeed )

				surface.SetTextColor( 255, 255, 255 )
				surface.SetTextPos( -pos, 302 )
				surface.DrawText( textToDisplay )
			end

        	local intTitleSizeW, intTitleSizeH = surface.GetTextSize( "Avis de recherche" )

			draw.SimpleText( "Avis de recherche", "DermaLarge", 280, 15, color_white )

			surface.SetDrawColor( color_white )
			surface.DrawRect( 280, intTitleSizeH + 15, intTitleSizeW, 1 )

			surface.SetMaterial( matIcon )
			surface.DrawTexturedRect( 280 + intTitleSizeW + 15, intTitleSizeH - 15, 32, 32 )

        	draw.SimpleText( "Nom du supect", "Trebuchet24", 280, 85, color_white )
			draw.SimpleText( "Raison de la recherche", "Trebuchet24", 280, 150, color_white )

			if SAddons.WantedScreen.DoFade && tblNextWanted[self][1] && tblNextWanted[self][1] > CurTime() then
				-- 0 < x < 1
				local transitionTick = ( tblNextWanted[self][1] - CurTime() ) / SAddons.WantedScreen.FadeDuration
				local color_white = color_white
				local nick, reason

				if transitionTick < 0.5 then
					nick = ply:Nick()
					reason = specialReason[ ply ] || ply:getDarkRPVar('wantedReason')
					color_white = Color( 255, 255, 255, 255 - transitionTick * 512 )
					SAddons.WantedScreen.Mdl:SetModel( tblNextWanted[self][2] )
				else
					nick = tblLastWanted[self][1]
					reason = tblLastWanted[self][2]
					color_white = Color( 255, 255, 255, transitionTick * 255 )
				end

				if istable( reason ) then
					for i=1, #reason do
						draw.SimpleText( reason[i], "Trebuchet24", 280, 155 + 20*i, color_white )
					end
				else
					draw.SimpleText( reason, "Trebuchet24", 280, 175, color_white )
				end
				draw.SimpleText( nick, "Trebuchet24", 280, 110, color_white )

			else
				draw.SimpleText( ply:Nick(), "Trebuchet24", 280, 110, color_white )
				if specialReason[ ply ] then
					for i=1, #specialReason[ ply ] do
						draw.SimpleText( specialReason[ ply ][i], "Trebuchet24", 280, 155 + 20*i, color_white )
					end
				else
					draw.SimpleText( ply:getDarkRPVar('wantedReason'), "Trebuchet24", 280, 175, color_white )
				end
			end

		end
    cam.End3D2D()
end
