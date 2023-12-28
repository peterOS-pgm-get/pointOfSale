pos.require("net.rttp")

local pointOfSale = {
    _keyPath = '%appdata%/transaction/key.key',
    _key = nil,

    _cfgPath = '%appdata%/transaction/disk.cfg',
    _cfgLoaded = false,

    drive = '/disk/',
    server = 'api.citybank.com',
}

function pointOfSale._loadKey(path)
    path = path or pointOfSale._keyPath

    local keyF = fs.open('%appdata%/transaction/key.key', 'r')
    if not keyF then
        -- printError('Must have key file in .appdata')
        return false
    end
    pointOfSale._key = keyF.readAll()
    keyF.close()
    return true
end

function pointOfSale.loadCfg(path)
    path = path or pointOfSale._cfgPath

    local cfgF = fs.open(path, 'r')
    if cfgF then
        local cfg = textutils.unserialiseJSON(cfgF.readAll())
        cfgF.close()
        pointOfSale.drive = cfg.drive or pointOfSale.drive
        pointOfSale.server = cfg.server or pointOfSale.server
        pointOfSale._keyPath = cfg.keyPath or pointOfSale._keyPath
    end
    pointOfSale._cfgLoaded = true
end

---Make a transaction for the given amount from specified account or card in drive
---@param amount number Transaction amount (Must be greater than 0)
---@param card number|nil Bank card key for origin account or <code>nil</code> to read from card in drive in <code>pgm.pointOfSale.drive</code>
---@return boolean success If the transaction was processed successfully
---@return string|table response Response from transaction server OR error message
function pointOfSale.makeTransaction(amount, card)
    if not pointOfSale._cfgLoaded then
        pointOfSale.loadCfg()
    end
    if not pointOfSale._key then
        if not pointOfSale._loadKey() then
            return false, 'Could not load key'
        end
    end

    if not card then
        local cardF = fs.open(pointOfSale.drive .. 'key.json', 'r')
        if not cardF then
            return false, 'Invalid card'
        end
        local cardData = textutils.unserialiseJSON(cardF.readAll())
        cardF.close()
        card = cardData.key
    end

    local r = rttp.postSync(pointOfSale.server, '', 'table', {
        key = pointOfSale._key,
        origin = card,
        amount = amount
    }, nil, 10)

    if type(r) ~= 'table' then
        ---@cast r string
        return false, r
    else
        return r.header.code == 200, r.body[1]
    end
end

if not _G.pgm then
    _G.pgm = {}
end
pgm.pointOfSale = pointOfSale