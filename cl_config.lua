cl_cfg = {}

cl_cfg.shopItems = {

    {itemname = "bread", itemdesc = "# Slot 1 #", price = 1, type = 'item', value = 'bread'},
    {itemname = "water", itemdesc = "# Slot 2 #", price = 1, type = 'item', value = 'water'},
    {itemname = "cola", itemdesc = "# Slot 3 #", price = 1, type = 'item', value = 'cola'},
    ['vip'] = {rank = 'vip', itemdesc = '# VIP #', type = 'rank', value = 'vip', elements = {
        {rank = "vip", duration = '24h', itemdesc = '# VIP [24H] #', price = 300, value = "vip24"},
        {rank = "vip", duration = '1w', itemdesc = "# VIP [1TYG] #", price = 600, value = "vip1w"}
    }};
    ['supervip'] = {rank = 'supervip', itemdesc = '# SuperVIP #', type = 'rank', value = 'supervip', elements = {
        {rank = "svip", duration = '24h', itemdesc = '# SVIP [24H] #', price = 500, value = "svip24"},
        {rank = "svip", duration = '1w', itemdesc = "# SVIP [1TYG] #", price = 1000, value = "svip1w"}
    }};
    ['legend'] = {rank = 'legend', itemdesc = '# Legenda #', value = 'legend', type = 'rank', elements = {
        {rank = "legend", duration = '24h', itemdesc = '# Legenda [24H] #', price = 1000, value = "legend24"},
        {rank = "legend", duration = '1w', itemdesc = "# Legenda [1TYG] #", price = 2500, value = "legend1w"}
    }};

}