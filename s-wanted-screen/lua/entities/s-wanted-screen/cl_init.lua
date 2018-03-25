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
	Materials
---------------------------------------------------------------------------]]

local matIcon = Material( "materials/slownls/wanted_screen/siren.png" )
local matIconBg = Material( "materials/slownls/wanted_screen/bg.jpg" )
local matIconLoad = Material( "materials/slownls/wanted_screen/loader.png" )

--[[-------------------------------------------------------------------------
	Model
---------------------------------------------------------------------------]]

SAddons.WantedScreen.Mdl = vgui.Create( "SpawnIcon"  )
SAddons.WantedScreen.Mdl:SetPos( 0, 0)
SAddons.WantedScreen.Mdl:SetSize( 325, 325 )
SAddons.WantedScreen.Mdl:SetVisible( false )
SAddons.WantedScreen.Mdl:SetPaintedManually( true )
SAddons.WantedScreen.Mdl:PerformLayout()

--[[-------------------------------------------------------------------------
	Wanted message too long
---------------------------------------------------------------------------]]
local specialReason = {}

hook.Add( "DarkRPVarChanged", "S-Wanted-Screen:Wanted:Manipulation", function(ply, var, _, value)
	if var == "wantedReason" then
		if value then
			if surface.GetTextSize( value ) > 270 then
				surface.SetFont( "Trebuchet24" )
				local newReason = ""
				specialReason[ ply ] = {}

				for i=1, #value do
					if value[i] == "\n" then continue end -- ignore les retour a la ligne
					if surface.GetTextSize(newReason .. value[i]) >= 270 then
						table.insert(specialReason[ ply ], newReason)
						newReason = value[i]
						continue
					end
					newReason = newReason .. value[i]
				end
				table.insert(specialReason[ ply ], newReason)
			end
		else
			specialReason[ ply ] = nil
		end
	end
end)

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
	self:StartLoading( false )
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 0 )

	local pos = self:GetPos()
	pos = pos + self:GetAngles():Right() * 27.9
	pos = pos + self:GetAngles():Forward() * 6
	pos = pos + self:GetAngles():Up() * 36

	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 500 then return end

	if IsValid( self:GetPlayerWanted() ) && self:GetPlayerWanted():isWanted() && ValidPanel( SAddons.WantedScreen.Mdl ) then
		SAddons.WantedScreen.Mdl:SetPos( 5, 5 )
		SAddons.WantedScreen.Mdl:SetVisible( true )

		if !SAddons.WantedScreen.Mdl.Mdl || SAddons.WantedScreen.Mdl.Mdl != self:GetPlayerWanted():GetModel() then
			SAddons.WantedScreen.Mdl:SetModel( self:GetPlayerWanted():GetModel() )
			SAddons.WantedScreen.Mdl.Mdl = self:GetPlayerWanted():GetModel()
			SAddons.WantedScreen.Mdl:PerformLayout()
		end
	end

    cam.Start3D2D( pos, ang, 0.1 )
	    draw.RoundedBox( 6, 0, 0, 558, 335, Color( 30, 30, 30, 255 ) )

	    surface.SetDrawColor( color_white )
		surface.SetMaterial( matIconBg )
		surface.DrawTexturedRect( 0, 0, 558, 335 )

	    if !self.Loaded then
	    	surface.SetDrawColor( color_white )
			surface.SetMaterial( matIconLoad )
			surface.DrawTexturedRectRotated( 558 / 2, 335 / 2, 128, 128, CurTime() * - 100 )
	    end

 		if IsValid( self:GetPlayerWanted() ) && self:GetPlayerWanted():isWanted() && self.Loaded then
	        if ValidPanel( SAddons.WantedScreen.Mdl ) then
        		SAddons.WantedScreen.Mdl:PaintManual()
        	end

        	surface.SetFont( "DermaLarge" )
        	local intTitleSizeW, intTitleSizeH = surface.GetTextSize( "Avis de recherche" )

			draw.SimpleText( "Avis de recherche", "DermaLarge", 280, 15, color_white )

			surface.SetDrawColor( color_white )
			surface.DrawRect( 280, intTitleSizeH + 15, intTitleSizeW, 1 )

			surface.SetMaterial( matIcon )
			surface.DrawTexturedRect( 280 + intTitleSizeW + 15, intTitleSizeH - 15, 32, 32 )

        	draw.SimpleText( "Nom du supect", "Trebuchet24", 280, 85, color_white )
			draw.SimpleText( self:GetPlayerWanted():Nick(), "Trebuchet24", 280, 110, color_white )

	        draw.SimpleText( "Raison de la recherche", "Trebuchet24", 280, 150, color_white )
	        if specialReason[ self:GetPlayerWanted() ] then
	        	for i=1, #specialReason[ self:GetPlayerWanted() ] do
	        		draw.SimpleText( specialReason[ self:GetPlayerWanted() ][i], "Trebuchet24", 280, 155 + 20*i, color_white )
	        	end
	        else
				draw.SimpleText( self:GetPlayerWanted():getDarkRPVar('wantedReason'), "Trebuchet24", 280, 175, color_white )
			end
		end
    cam.End3D2D()
end
