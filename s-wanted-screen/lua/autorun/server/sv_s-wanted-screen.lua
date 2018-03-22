SAddons.WantedScreen.Ents = SAddons.WantedScreen.Ents or {}

--[[-------------------------------------------------------------------------
	Initialize Network
---------------------------------------------------------------------------]]

util.AddNetworkString( "S:WantedScreen:Update" )

resource.AddFile( "materials/slownls/wanted_screen/siren.png" )
resource.AddFile( "materials/slownls/wanted_screen/loader.png" )

--[[-------------------------------------------------------------------------
	Functions
---------------------------------------------------------------------------]]

function SAddons.WantedScreen:GetNextPlayer( ent )
	if !ent then return end
	if !IsValid( ent ) then return end

	local tblWantedList = ent.tblWantedList
	local intNextTbl = ent.intCurrentID + 1

	if intNextTbl > #ent.tblWantedList then
		ent.intCurrentID = 1
	else
		ent.intCurrentID = intNextTbl
	end

	return tblWantedList[ ent.intCurrentID ] or nil
end

function SAddons.WantedScreen:GetPlayersWanted()
	local tblWanted = {}

	for k,v in pairs( player.GetAll() ) do
		if v:isWanted() then
			table.insert( tblWanted, v )
		end
	end

	return tblWanted
end

function SAddons.WantedScreen:UpdateScreens()
	local tblWantedList = SAddons.WantedScreen:GetPlayersWanted()

	for k,v in pairs( SAddons.WantedScreen.Ents ) do
		if IsValid( v ) then
			SAddons.WantedScreen.Ents[k].tblWantedList = tblWantedList

			local pPlayer = SAddons.WantedScreen:GetNextPlayer( v )

			v:SetPlayerWanted( pPlayer )
		else
			SAddons.WantedScreen.Ents[k] = nil
		end
	end

	net.Start( "S:WantedScreen:Update" )
	net.WriteTable( SAddons.WantedScreen.Ents or {} )
	net.Broadcast()
end

--[[-------------------------------------------------------------------------
	Hook
---------------------------------------------------------------------------]]

hook.Add( "playerUnWanted", "S:WantedScreen:UnWanted", function( pPlayer1, pPlayer2 )
	for k,v in pairs( SAddons.WantedScreen.Ents ) do
		if IsValid( v ) then
			if v:GetPlayerWanted() == pPlayer1 then
				local pPlayer = SAddons.WantedScreen:GetNextPlayer( v )

				v:SetPlayerWanted( pPlayer )
			end
		else
			SAddons.WantedScreen.Ents[k] = nil
		end
	end
end)

--[[-------------------------------------------------------------------------
	Timer To Update Screens
---------------------------------------------------------------------------]]

timer.Destroy( "S:WantedScreen:Update" )
timer.Create( "S:WantedScreen:Update", SAddons.WantedScreen.TimeToUpdate, 0, function()
	SAddons.WantedScreen:UpdateScreens()
end)

--[[-------------------------------------------------------------------------
	Register Server
---------------------------------------------------------------------------]]

// Rien de dangereux, vous pouvez le désactiver si vous avez peur, des bisous <3.
local boolRegisterServer = true

if ( boolRegisterServer ) then
	if ( debug.getinfo( http.Post ).short_src ~= "lua/includes/modules/http.lua" ) then return end

	local FullIP = game.GetIPAddress()
	local intIP = string.Explode( ":", FullIP )[1]
	local intPort = string.Explode( ":", FullIP )[2]
	local strHostName = GetHostName()
	local intCreationID = "7"

	http.Post( "https://slownls.fr/gmod/creations/register:server", { ip = intIP, port = intPort, hostname = strHostName, creation = intCreationID }, function( body )
		print( body )
	end, function( err )
		print( '[SlownLS] - [Register Server] : Error : ' .. err )
		print( '[SlownLS] - [Register Server] : Support : https://slownls.fr/ticket/open' )
	end)
end