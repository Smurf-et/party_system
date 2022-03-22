print('SCRIPT LOADED')
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
PvpParty = {}
Tunnel.bindInterface("PvpParty-system", PvpParty)
Client = Tunnel.getInterface("PvpParty-system")
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------
local PartyManager = module('party_system', 'server/utils/PartyManager')
local PlayerBucketManager = module('party_system', 'server/utils/PlayerBucketManager')
local jsonConfig = json.decode(LoadResourceFile('party_system', 'config.json'))
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARTY COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('party', function(source, args)
    local source = source
    if args[1] == 'join' then
        if args[2] == nil or args[3] == nil or Client.getCurrentParty(source) ~= nil then
            TriggerClientEvent('Notify', source, 'error', 'PARTY', 'Você deve colocar o número da party e o time que quer jogar, Vermelho ou Azul')
            return
        end
        if args[3] == 'red' then
            if PartyManager.insertPlayerIntoParty(args[2], source, vRP.getUserId(source), 'red') then
                Client.manageCurrentParty(source, args[2])
                Client.manageCurrentTeam(source, 'red')
                Client.teleportPlayers(source, jsonConfig.coordsLobbyPartyRed.x, jsonConfig.coordsLobbyPartyRed.y, jsonConfig.coordsLobbyPartyRed.z)
                TriggerClientEvent('Notify', source, 'sucesso', 'PARTY', 'Você entrou na party ' ..args[2].. ',  No time red, Bom Jogo.')
            end
        elseif args[3] == 'blue' then
            if PartyManager.insertPlayerIntoParty(args[2], source, vRP.getUserId(source), 'blue') then
                Client.manageCurrentParty(source, args[2])
                Client.manageCurrentTeam(source, 'blue')
                Client.teleportPlayers(source, jsonConfig.coordsLobbyPartyBlue.x, jsonConfig.coordsLobbyPartyBlue.y, jsonConfig.coordsLobbyPartyBlue.z)
                TriggerClientEvent('Notify', source, 'sucesso', 'PARTY', 'Você entrou na party ' ..args[2].. ',  No time blue, Bom Jogo.')
            end
        end
    elseif args[1] == 'create' then
        if not PartyManager.isPlayerAlreadyHasCreatedParty(source) then
            local party = PartyManager.createParty(source)
            if party then
                TriggerClientEvent('Notify', source, 'sucesso', 'PARTY', 'Você criou a party com o número ' ..party.. '. Para entrar utilize /party join NÚMERO TIME')
            else
                TriggerClientEvent('Notify', source, 'error', 'PARTY', 'Não conseguimos criar a party, talvez você já tenha uma criada ou o número máximo de partys no server foi atingido, Aguarde para criar novamente')
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARTY COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
function PvpParty.checkIsLastPlayer(party)
    local source = source
    if PartyManager.removePlayerFromParty(party, source) then
        for k,v in pairs(PartyManager.getPartyPlayersAmount(party)) do
            if #k <= 1 then
                Client.manageCurrentParty(v.source)
                TriggerClientEvent('chatMessage', -1, {131,174,0}, vRP.getUserIdentity(vRP.getUserId(source)).name.. ' ' ..vRP.getUserIdentity(vRP.getUserId(source)).name2.. ' TIME ' ..Client.getCurrentTeam(v.source).. ' VENCEDOR DA PARTIDA NÚMERO ' ..party)
                Client.manageCurrentTeam(v.source, nil)
            else
                Client.resetValues(source)
            end
            Client.teleportPlayers(v.source, 201.2,-927.1,30.7)
            PlayerBucketManager.insertPlayerIntoPartyBucket(v.source, 0)
            Client.resetValues(source)
            PlayerBucketManager.insertPlayerIntoPartyBucket(source, 0)
            Client.teleportPlayers(source, 201.2,-927.1,30.7)
            return true
        end
    end
    return false
end