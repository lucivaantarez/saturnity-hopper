 getgenv().Utility = {
        AutoPotion = {
            Enabled = false, -- Start auto potion leveling on load
            UseAllOnAll = false, -- Use all potions on all pets (highest age first)
            SelectedPets = {}, -- Specific pet IDs to level e.g. {"dog", "cat"}
        },
        AutoNeon = {
            Enabled = false, -- Start auto neon fusing on load
            MakeMega = false, -- Make mega neons instead of regular neons
            SelectedPets = {}, -- Specific pet IDs to fuse e.g. {"dog", "cat"}
        },
        AutoTrade = {
            Enabled = false, -- Start auto trading on load
            AutoAcceptTrades = true, -- Auto accept incoming trade requests
            AutoLeaveAfterTrades = true, -- Leave/shutdown when all trades complete
            Usernames = {}, -- Players to trade with e.g. {"player1", "player2"}
            TradeMode = "all", -- "all" = trade everything in categories, "specific" = only Items list
            Categories = {"pets", "toys", "food", "transport", "gifts", "stickers", "pet_accessories"}, -- Categories to include
            Items = {}, -- Item IDs/names when TradeMode = "specific" e.g. {"dog", "cat", "buffalo"}
            PetTypes = {}, -- Filter pet types, {} = all, e.g. {"regular", "neon", "mega"}
            Ages = {}, -- Filter pet ages, {} = all, e.g. {6} for full grown only
            ItemCounts = {}, -- Max count per item per player e.g. {dog = 30, cat = 12}
            Filters = {
                Kind = "ALL", -- Filter by specific item ID, "ALL" = no filter
                Type = "ALL", -- Pet type filter: "ALL", "regular", "neon", "mega"
                Rarity = "ALL", -- Rarity filter: "ALL", "common", "uncommon", "rare", "ultra_rare", "legendary"
                Search = "", -- Search filter, supports comma separated e.g. "dog, cat, buffalo"
            },
        },
        AutoOpen = {
            Enabled = false, -- Start auto opening on load
            Items = {}, -- Item IDs to open e.g. {"gift_box", "cracked_egg"}
            OpenDelay = 1, -- Seconds between each open (0.5 - 3)
        },
       Shop = {
            Enabled = false, -- Auto buy items on load
            Items = {}, -- Item IDs to auto buy e.g. {"cracked_egg", "hot_dog_stand"}
            BuyQuantity = 1, -- How many to buy per purchase (1, 5, 10, 25, 50, 100)
            BuyDelay = 1, -- Seconds between purchases (0.5 - 3)
        },
        AccountManager = {
            Enabled = false,
            Tool = "none", -- "yummy", "farmsync", "farmerv5"
            Yummy = {
                Action = "completed",
                Reason = "Done",
            },
            FarmSync = {
                Action = "completed",
                FromFolderId = "",
                ToFolderId = "",
                ChangeWithoutReplacement = false,
                ConfigId = nil,
                ApiKey = "",
            },
            FarmerV5 = {
                ApiKey = "", -- FarmerV5 API key (bearer token)
            },
        },
        Settings = {
            AutoShowUI = true, -- Show UI on script load (false = hidden, use toggle key)
            Theme = "Dark", -- UI theme: "Dark", "Midnight", "Amoled"
            ToggleKey = "RightShift", -- Key to toggle UI visibility
        },
    };
getgenv().scriptkey="PWUyrezPKtBiJjNHFgMYfmfDOKCZZmHi"
loadstring(game:HttpGet("https://zekehub.com/scripts/AdoptMe/Utility.lua"))()
