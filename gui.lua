local gui = {}
local cfg = {
    productFilePath = '/home/products.json'
}
cfg = pos.Config('%appdata%/pointOfSale/cfg.json', cfg, true)

if not fs.exits(cfg.productFilePath) then
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

gui.productList = pos.gui.ListField(1, 2, 32, gui.window.h - 1)
gui.window:addElement(gui.productList)

for i, product in pairs(products) do
    local text = ('% 4d % 6s %s'):format(product.id, '$' .. product.price, product.name)
    local button = pos.gui.Button(1, i, 32, 1, colors.black, nil, text, function()

    end)
    gui.productList:addElement(button)
end

pos.gui.run()