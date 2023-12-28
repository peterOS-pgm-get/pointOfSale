local args = {...}

if args[1] == 'mon' then
    print("Not yet implemented")
    return
elseif #args > 0 then
    printError("Unknown argument")
    return
end

term.write('Enter Amount: $')
local a = tonumber(read())
if not a then
    printError('Must enter a number')
    return
end

print('')
print('Press enter when card is in')
read('')

local s, r = pgm.pointOfSale.makeTransaction(a)
if s then
    print(r)
else
    printError(r)
end