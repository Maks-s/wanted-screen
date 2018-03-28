ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.Category 		= "SlownLS | Wanted Screen"
ENT.PrintName		= "Écran de Recherche"
ENT.Author			= "SlownLS & All"
ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "PlayerWanted" )
end