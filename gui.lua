local gui = {}
local cfg = {
    productFilePath = '/home/products.json'
}
local config = pos.Config('%appdata%/pointOfSale/cfg.json', cfg, true)
cfg = config.data

if not fs.exists(cfg.productFilePath) then
    error('Product file does not exits')
    return
end
local pf = fs.open(cfg.productFilePath, 'r')
if not pf then
    error('Could not read product file')
    return
end
local products = textutils.unserialiseJSON(pf.readAll())
pf.close()
if not products then
    error('Product file corrupted')
    return
end

gui.window = pos.gui.Window('Point Of Sale')
pos.gui.addWindow(gui.window)
gui.window:show()

gui.idSearch = pos.gui.TextInput(1, 2, 4)
gui.window:addElement(gui.idSearch)
gui.nameSearch = pos.gui.TextInput(12, 2, 12)
gui.window:addElement(gui.nameSearch)

gui.productList = pos.gui.ListField(1, 3, 32, gui.window.h - 1)
gui.window:addElement(gui.productList)

gui.prodEls = {}
for i, product in pairs(products) do
    local text = ('% 4d % 6s %s'):format(product.id, ('$%.2f'):format(product.price), product.name)
    product.button = pos.gui.Button(1, i, 32, 1, colors.black, nil, text, function()

    end)
    gui.productList:addElement(product.button)
    gui.prodEls[product.id] = product
end

local idSearch = ''
local nameSearch = ''
pos.gui.run(function(event)
    if gui.idSearch:getText() ~= idSearch or gui.nameSearch:getText() ~= nameSearch then
        idSearch = gui.idSearch:getText()
        for id, product in pairs(products) do
            local idStr = '' .. id
            local si, ei = idStr:find(idSearch)
            if si == 1 or ei == #idStr then
                product.button.visible = true
            else
                product.button.visible = false
            end
        end
        nameSearch = gui.nameSearch:getText()
        for _, product in pairs(products) do
            if not product.name:cont(nameSearch) then
                product.button.visible = false
            end
        end
    end
end)