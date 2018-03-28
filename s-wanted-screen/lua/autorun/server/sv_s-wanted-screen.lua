SAddons.WantedScreen.Ents = SAddons.WantedScreen.Ents or {}

--[[-------------------------------------------------------------------------
	Initialize Network
---------------------------------------------------------------------------]]

util.AddNetworkString( "S:WantedScreen:Update" )

resource.AddFile( "materials/slownls/wanted_screen/siren.png" )
resource.AddFile( "materials/slownls/wanted_screen/loader.png" )
resource.AddFile( "materials/slownls/wanted_screen/bg.png" )

--[[-------------------------------------------------------------------------
	Functions
---------------------------------------------------------------------------]]

local intCurrentID = 0

function SAddons.WantedScreen:GetNextPlayer( tblWantedList )
	local intNextTbl = intCurrentID + 1

	if intNextTbl > #tblWantedList then
		intCurrentID = 1
	else
		intCurrentID = intNextTbl
	end

	return tblWantedList[ intCurrentID ]
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
	local pPlayer = SAddons.WantedScreen:GetNextPlayer( tblWantedList )

	for i=1, #SAddons.WantedScreen.Ents do
		if IsValid( SAddons.WantedScreen.Ents[i] ) then
			if pPlayer ~= SAddons.WantedScreen.Ents[i]:GetPlayerWanted() then
				SAddons.WantedScreen.Ents[i]:SetPlayerWanted( pPlayer )
			end
		else
			SAddons.WantedScreen.Ents[i] = nil
		end
	end
	
	if !SAddons.WantedScreen.DoFade then
		net.Start( "S:WantedScreen:Update" )
		net.WriteTable( SAddons.WantedScreen.Ents or {} )
		net.Broadcast()
	end
end

--[[-------------------------------------------------------------------------
	Hook
---------------------------------------------------------------------------]]

hook.Add( "playerUnWanted", "S:WantedScreen:UnWanted", function( pPlayer1, pPlayer2 )
	SAddons.WantedScreen:UpdateScreens()
end)

hook.Add( "playerWanted", "S:WantedScreen:Wanted", function( pPlayer1, pPlayer2 )
	SAddons.WantedScreen:UpdateScreens()
end)

--[[-------------------------------------------------------------------------
	Timer To Update Screens
---------------------------------------------------------------------------]]

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
