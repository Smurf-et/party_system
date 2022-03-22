-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PlayerBucketManager = module('party_system', 'server/utils/PlayerBucketManager')
local jsonConfig = json.decode(LoadResourceFile('party_system', 'config.json'))
local PartyManager = {}
local createdPartys = {}
local PartyPlayers = {}
local currentSourceParty = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATE PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.createParty(creatorSrc)
    local count = 45
    repeat count = count + 1 
    until createdPartys[tostring(count)] == nil 
    if count <= 46 + jsonConfig.maxPartys then
        if not PartyManager.checkPartyWasCreated(count) then
            createdPartys[tostring(count)] = {}
            createdPartys[tostring(count)].creator = creatorSrc
            createdPartys[tostring(count)].participants = {}
        else
            return false
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- IS PLAYER ALREADY HAS CREATED PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.isPlayerAlreadyHasCreatedParty(source)
    for k,v in pairs(createdPartys) do
        if v.creator == source then
            return true
        else
            return false
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK IS PARTY WAS CREATED
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.checkPartyWasCreated(party)
    if createdPartys[tostring(party)] == nil then 
        return false
    else
        return true
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSERT PLAYER INTO PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.insertPlayerIntoParty(party, source, player, team)
    if PartyManager.checkPartyWasCreated(party) then 
        if PartyManager.insertPlayerIntoPartyTeam(party, source, player, team) then
            PlayerBucketManager.insertPlayerIntoPartyBucket(source, parseInt(party))
            currentSourceParty[source] = party
            return true
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSERT PLAYER INTO PARTY TEAM
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.insertPlayerIntoPartyTeam(party, source, player, team)
    local count = 0
    repeat 
        count = count + 1 
    until count > parseInt(jsonConfig.maxPartyParticipants / 2) or createdPartys[tostring(party)].participants[tostring(count)] == nil
    if count > parseInt(jsonConfig.maxPartyParticipants / 2) then
        return false
    else
        createdPartys[tostring(party)].participants[tostring(count)] = {
            source = source,
            player = player,
            team = team,
        }
        return true
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVE PLAYER FROM PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.removePlayerFromParty(party, source)
    if PartyManager.checkPartyWasCreated(party) then
        for k,v in pairs(createdPartys[tostring(party)].participants) do
            if v.source == source then
                createdPartys[tostring(party)].participants[k] = nil
                return true
            end
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET PARTY PLAYERS AMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.getPartyPlayersAmount(party)
    if PartyManager.checkPartyWasCreated(party) then
        return createdPartys[tostring(party)].participants
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXIT PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.exitParty(party, source)
    if PartyManager.checkPartyWasCreated(party) then 
        for k,v in pairs(createdPartys[tostring(party)].participants) do
            if v ~= false and v.source == parseInt(source) then
                PlayerBucketManager.insertPlayerIntoPartyBucket(source, 0)
                createdPartys[tostring(party)].participants[k] = false
                return true
            end
        end
    else
        print('Esta party não existe')
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE PARTY
-----------------------------------------------------------------------------------------------------------------------------------------
function PartyManager.closeParty(party)
    if PartyManager.checkPartyWasCreated(party) then 
        for k,v in pairs(createdPartys[tostring(party)].participants) do
            PlayerBucketManager.insertPlayerIntoPartyBucket(v.source, 0)
            createdPartys[tostring(party)] = nil
        end
    else
        print('Esta party não existe')
    end
end

return PartyManager