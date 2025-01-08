function httpReply(port, url, responce)
    res = responce
end

res = 0

function onTick()
    async.httpGet(1, "/dev/urandom")
    output.setNumber(1, res)
end