local PlayerBucketManager = {}

function PlayerBucketManager.getActualPlayerBucket(source)
    return GetPlayerRoutingBucket(source)
end

function PlayerBucketManager.insertPlayerIntoPartyBucket(source, bucket)
    SetPlayerRoutingBucket(source, bucket)
end

return PlayerBucketManager