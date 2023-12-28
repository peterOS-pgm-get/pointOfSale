# Point of Sale

A [PeterOS](https://github.com/Platratio34/peterOS) [pgm-get](https://github.com/peterOS-pgm-get/pgm-get) program

Install on PeterOS via:
```console
pgm-get install pointOfSale
```

## Command

### `pointOfSale [amount]`: Command Line

Make a simple amount transaction from the account associated from card in disk drive. If `amount` is absent, it will be prompted.

### `pointOfSale -g`: Graphical

Opens a customizable GUI including product list, card, and receipt printing.


## Config

### Transaction: `%appdata%/transaction/disk.cfg`

| Field            | Default                         | Description                 |
| ---------------- | ------------------------------- | --------------------------- |
|  drive           | `/disk/`                        | Drive path for reading card |
|  server          | `api.citybank.com`              | URL of transaction server   |
|  keyPath         | `%appdata%/transaction/key.key` | Path to transaction key file |

### GUI: `%appdata%/pointOfSale/cfg.json`

| Field           | Default               | Description                |
| --------------- | --------------------- | -------------------------- |
| productFilePath | `/home/products.json` | File path for product data |

## Product file

JSON array formatted list of products objects.

| Field | Description                  |
| ----- | ---------------------------- |
| id    | Up to 4 character product ID |
| price | Product price (number)       |
| name  | Product name                 |

### Ex.

``` json
[
    {"id":1,    "price":32,   "name":"LUA for Dummies"},
    {"id":2,    "price":100,  "name":"Leather Tunic"},
    {"id":3,    "price":7,    "name":"Fish Sandwich"},
    {"id":99,   "price":153,  "name":"Movie Ticket"},
    {"id":1234, "price":9999, "name":"Elytra"}
]
```

## Program package: `_G.pgm.pointOfSale`

### Functions

```lua
pgm.pointOfSale.loadCfg(path: nil|string)
```

Load the config from provided path.

Parameters:
- `path`: `string` - Config path. If `nil` default path will be used

---

```lua
pgm.pointOfSale.makeTransaction(amount: number, card: number|nil) -> boolean, string|table
```

Make a transaction for the given amount from specified account or card in drive.

Parameters:
- `amount`: `number` - Transaction amount (Must be greater than 0)
- `card`: `number|nil` - Bank card key for origin account. If `nil`, it will be read from card in drive in config

Returns:
- `boolean` `success` - If the transaction was processed successfully
- `string|table` `response` - Response from transaction server OR error message

### Variables

```lua
pgm.pointOfSale.drive: string = '/disk/'
```

Loaded from config `drive` field.
Drive path for reading card data

---

```lua
pgm.pointOfSale.server: string = 'api.citybank.com'
```

Loaded from config `server` field.
URL for transaction API server

