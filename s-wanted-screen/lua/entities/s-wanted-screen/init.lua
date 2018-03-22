AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_phx/rt_screen.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	table.insert( SAddons.WantedScreen.Ents, self )

	self.tblWantedList = SAddons.WantedScreen:GetPlayersWanted()
	self.intCurrentID = 0
end