local clArgs = { ... }

local parser = pos.Parser()
parser:addFlag('gui', 'g')
local args, flags = parser:parse(clArgs)

if flags.gui then
    dofile('gui.lua')
    return
end

local a = args[1] ---@type string
if not a then
    term.write('Enter Amount: $')
    a = read()
end
local amount = tonumber(a)
if not amount then
    printError('Amount must be a number')
    return
end

print('')
print('Press enter when card is in')
read('')

local s, r = pgm.pointOfSale.makeTransaction(amount)
if s then
    print(r[1])
else
    if type(r) == 'table' then
        r = r[1]
    end
    printError(r)
end