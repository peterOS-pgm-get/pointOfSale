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

local cart = {}

local function calcTotal()
    local total = 0
    for _, p in pairs(cart) do
        total = total + (p.qty * p.price)
    end
    return total
end

gui.cartList = pos.gui.ListField(32, 5, 16, gui.window.h - 1)
gui.window:addElement(gui.cartList)

gui.cartTotal = pos.gui.TextBox(32, 4, nil, nil, 'Total: $0.00', gui.window.w - 32)
gui.window:addElement(gui.cartTotal)

gui.cartClear = pos.gui.Button(32, 3, 5, 1, nil, nil, 'Clear', function()
    for _, prod in pairs(cart) do
        gui.cartList:removeElement(prod.buttonId)
    end
    cart = {}
    gui.cartTotal:setText("Total: $0.00")
end)

local function addToCart(product)
    if cart[product.id] then
        local prod = cart[product.id]
        prod.qty = prod.qty + 1
        prod.button.text = ('% 3dx % 9s %s'):format(prod.qty, ('$%.2f'):format(prod.price), prod.name)
    else
        local prod = {}
        prod.id = product.id
        prod.price = product.price
        prod.name = product.name
        prod.qty = 1
        prod.button = pos.gui.Button(1, #cart + 1, 16, 1, nil, nil,
            ('% 3dx % 9s %s'):format(prod.qty, ('$%.2f'):format(prod.price), prod.name), function(btn)
            if btn ~= 2 then
                return
            end
            prod.qty = prod.qty - 1
            gui.cartTotal:setText(("Total: $%.2f"):format(calcTotal()))
            if prod.qty <= 0 then
                cart[prod.id] = nil
                gui.cartList:removeElement(prod.buttonId)
                return
            end
            prod.button.text = ('% 3dx % 9s %s'):format(prod.qty, ('$%.2f'):format(prod.price), prod.name)
        end)
        prod.buttonId = gui.cartList:addElement(prod.button)
        cart[prod.id] = prod
    end
    gui.cartTotal:setText(("Total: $%.2f"):format(calcTotal()))
end

gui.idSearch = pos.gui.TextInput(1, 3, 5)
gui.window:addElement(gui.idSearch)
gui.nameSearch = pos.gui.TextInput(17, 3, 12)
gui.window:addElement(gui.nameSearch)

gui.productList = pos.gui.ListField(1, 4, 30, gui.window.h - 1)
gui.window:addElement(gui.productList)

gui.prodEls = {}
for i, product in pairs(products) do
    local text = ('% 5d % 9s %s'):format(product.id, ('$%.2f'):format(product.price), product.name)
    local prod = product
    product.button = pos.gui.Button(1, i, 30, 1, colors.black, nil, text, function(btn)
        if btn ~= 1 then
            return
        end
        addToCart(prod)
    end)
    gui.productList:addElement(product.button)
    gui.prodEls[product.id] = product
end

local idSearch = ''
local nameSearch = ''
pos.gui.run(function(event)
    if gui.idSearch.text ~= idSearch or gui.nameSearch.text ~= nameSearch then
        idSearch = gui.idSearch.text
        for _, product in pairs(products) do
            local idStr = '' .. product.id
            local si, ei = idStr:find(idSearch)
            if si == 1 or ei == #idStr then
                product.button.visible = true
            else
                product.button.visible = false
            end
        end
        nameSearch = gui.nameSearch.text
        for _, product in pairs(products) do
            if not product.name:lower():cont(nameSearch) then
                product.button.visible = false
            end
        end
    end
end)