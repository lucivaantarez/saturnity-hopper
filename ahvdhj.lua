getgenv().Config = {
    Dashboard = {
        Enabled = true, -- Send stats to dashboard
        SyncConfig = true, -- Accept config pushes from dashboard
        GroupName = "Hopper", -- Group name for organising accounts on dashboard (https://zekehub.com/dashboard/adoptme)
    },
    BabyFarm = false, -- Does baby farm
    AutoCertificate = false, -- Auto use Pet Handler Pro Certificate when less than 30 days remaining
    EventFarm = {
        Fishing = {
            Enabled = false, -- auto catches fish (free now, no bait needed)
            AutoUpgradeRod = false, -- bronze -> silver -> gold as fish count allows
            AutoSell = false, -- sell excess fish above the goal amounts below
            Goals = {
                summer_2026_rainbow_fish = 1,
                summer_2026_gold_fish = 15,
                summer_2026_silver_fish = 35,
                summer_2026_bronze_fish = 75,
            }, -- keep this many of each; anything extra gets sold
        },
        AutoTreasureHunt = {
            Enabled = false, -- enables autocollect, auto hand in bottles and pages
        },
        Skydiving = {
            Enabled = false, -- auto does all the skydiving tasks
        },
    },
    PetFarm = {
        Enabled = false, -- Enables the Pet Farm
        FarmEggs = false, -- If true, equips eggs to hatch them. If false, equips regular pets
        BuyEggs = false, -- If FarmEggs is true and no eggs in inventory, buy eggs automatically
        EggTypes = {}, -- Which eggs to equip ({} = any egg, or {"cracked_egg", "royal_egg"} for specific)
        BuyEggType = "any", -- Which egg to buy when BuyEggs is true ("any" or specific egg ID)
        MaxPets = 1, -- How many pets to equip at once (1 = free, 2 = requires Robux gamepass)
        FarmUntilFullGrown = false, -- If true, selects pets that aren't full grown first
        PrioritizeFriendship = false, -- If true, selects pets with higher friendship level first
        SelectiveFarm = false, -- If true, only farm pets in SelectedPetTypes list
        SelectedPetTypes = {}, -- Pet IDs to farm when SelectiveFarm is true (e.g., {"dog", "cat"})
    },
    AutoTrade = {
        Enabled = true, -- Enable auto trading
        AutoAcceptTrades = true, -- Accept incoming trade requests
        AutoLeaveAfterTrades = false, -- Leave the game after completing trades
        Usernames = {"Crystal0bKingN1381"}, -- Players to send trades to (e.g. {"player1", "player2"})
        TradeMode = "specific", -- "all" = everything in categories, "specific" = only Items list
        Categories = {"pets"}, -- {"pets", "toys", "food", "transport", "gifts", "stickers", "pet_accessories", "roleplay"}
        Items = {
            "admin_abuse_2025_sushi_penguin",
            "penguins_2025_dango_penguins",
            "admin_abuse_egg_2026_robot_chicken",
            "food_pets_2026_dragonfruit_fox",
            "ice_dimension_2025_frostbite_bear",
            "journey_2026_pilot_gull",
            "journey_2026_sheepdog_duck",
            "endangered_2026_silverback_gorilla",
            "pet_recycler_2025_emberlight",
            "summer_2026_rainbow_trout",
            "icey_aura",
            "gifthat_2026_chocolate_chip_bat_dragon_backpack",
            "summer_2026_river_otter",
            "summer_2026_stygian_owl",
            "2d_tuesdays_2025_2d_kitty",
            "summer_2026_ruddy_duck",
        }, -- Item IDs when TradeMode = "specific" (e.g. {"dog", "cat", "turtle"})
        ItemCounts = {}, -- Max count per item matching Items order (e.g. {30, 12, 5}. {} = unlimited all)
        GlobalPetFilter = {
            Versions = {}, -- {} = all versions, {"regular", "neon", "mega"} = only these. Fallback for pets NOT in PetFilters
            Ages = {}, -- {} = all ages, {1, 2, 3, 4, 5, 6} = only these. Mega ignores ages. Fallback for pets NOT in PetFilters
        },
        PetFilters = {}, -- Per-pet overrides. If a pet is listed here, GlobalPetFilter is IGNORED for that pet
        -- Version not listed = NOT traded. {} after version = all ages. {6} = only full grown. Mega always ignores ages
        -- Example:
        -- PetFilters = {
        --     sugarfest_2026_mochi_meow = {
        --         regular = {6},      -- only full grown regulars
        --         neon = {4, 5, 6},   -- only flare/sunshine/luminous neons
        --         mega = {},          -- all megas (ages always ignored for mega)
        --     },
        --     turtle = {
        --         mega = {},          -- ONLY mega turtles (regular and neon NOT traded)
        --     },
        -- }
    },
    AutoNeon = {
        Enabled = false, -- Enable auto neon/mega fusion
        MakeMega = true, -- Fuse neons into mega neons
        NeonAll = false, -- Neon everything possible
        SelectedPets = {
            "summer_2026_river_otter",
            "summer_2026_irish_setter",
            "journey_2026_pilot_gull",
            "journey_2026_bison",
            "summer_2026_lake_monster",
            "summer_2026_stygian_owl",
        }, -- {} when NeonAll = true, otherwise {"dog", "cat"} etc
        MaxPerType = {}, -- {} = unlimited, {dog = 2, cat = 1} = limits per pet type
    },
    AutoPotion = {
        Enabled = false, -- Use age potions on pets to level them up
        SelectedPets = {}, -- Pet IDs to use potions on (empty = does nothing)
        PotionVersionFilter = {}, -- Per-pet version filter e.g. {dog = {"neon"}} - empty = all versions
    },
    AutoBuy = {
        Enabled = false, -- Automatically buy items from shops
        SelectedItems = {}, -- Item IDs to buy
        BuyAmounts = {}, -- How many of each item to buy. Empty {} = infinite of each. Fewer amounts than items = remaining default to infinite
    },
    AutoPay = {
        Enabled = false, -- Send bucks to another player
        TargetPlayer = {}, -- Username of player to pay bucks to
        Methods = {}, -- Payment methods: "register" (cash register), "mannequin" (buy outfits), "hotdog" (refreshment stands)
    },
    AutoOpen = {
        Enabled = false, -- Open gift boxes, baits, etc automatically
        Items = {}, -- Item IDs to auto open
    },
    AutoRecycle = {
        Enabled = false, -- Toggle auto recycling on/off
        RarityFilter = {
            -- Each rarity maps to a list of versions to recycle
            -- Versions: "regular", "neon", "mega"
            -- If a rarity is not listed or empty, pets of that rarity will NOT be recycled
            -- If a rarity has versions listed, ONLY those versions will be recycled
            --
            -- common = {"regular", "neon", "mega"},     -- Recycle all common versions
            -- uncommon = {"neon"},                      -- Only recycle neon uncommons
            -- rare = {"regular", "neon", "mega"},       -- Recycle all rare versions
            -- ultra_rare = {"regular", "neon", "mega"}, -- Recycle all ultra rare versions
            -- legendary = {"mega"},                     -- Only recycle mega legendaries
        },
        AgeFilter = {}, -- Empty = all ages, or specific ages e.g. {1, 2, 3, 4, 5, 6} (1=Newborn, 6=Full Grown)
        ExcludedPets = {}, -- Pet IDs to never recycle e.g. {"dog", "cat", "shadow_dragon"}
    },
    IdleProgression = {
        Enabled = false, -- Put pets in pet pen for idle leveling
        SelectedPets = {}, -- Pet IDs to put in pet pen (empty = use all)
        ExcludedPets = {}, -- Pet IDs to never put in pet pen
        PriorityOrder = {}, -- Order: first = highest priority for pen slots (e.g. {"neon", "regular", "mega"})
        PenVersionFilter = {}, -- Per-pet version filter e.g. {dog = {"neon"}} - empty = all versions
    },
    AccountManager = {
        Enabled = false, -- Master toggle for account management
        Tool = "", -- "yummy", "farmsync", "farmerv5", "kick" (kick just kicks you from the game instead of yummy/farmsync actions)
        Yummy = {
            Action = "completed", -- "completed" = remove cookie/stop, "swap" = next cookie
            Reason = "Done", -- Suffix for completed file (Completed-{Reason})
        },
        FarmSync = {
            Action = "completed", -- "completed" = move to done folder, "swap" = move and replace, "disable" = disable account (requires ApiKey)
            FromFolderId = "", -- Fresh cookies folder ID
            ToFolderId = "", -- Done cookies folder ID
            ChangeWithoutReplacement = false, -- Remove even if no replacement available
            ConfigId = nil, -- Config for new account (nil = same config)
            ApiKey = "", -- FarmSync API key (device key)
        },
        FarmerV5 = {
            ApiKey = "", -- FarmerV5 API key (bearer token)
        },
        Triggers = {
            AfterTradeComplete = false, -- Requires AutoTrade.AutoLeaveAfterTrades to be enabled
            MinBucks = 0, -- Change account when bucks >= this (0 = off)
            MinPotions = 0, -- Change account when potions >= this (0 = off)
        },
    },
    Settings = {
        AutoShowUI = true, -- Load the UI on script start (disable for less memory usage)
        ShowOverlay = false, -- Show stats overlay (disables 3D rendering)
        ReduceGraphics = false, -- Reduce graphics quality to minimum
        FPSCap = 10, -- FPS cap option (0 = uncapped)
        LureId = "ice_dimension_2025_ice_soup_bait", -- What lure to use, e.g. "ice_dimension_2025_ice_soup_bait"
        TradeInvites = "Everyone", -- "Everyone" or "Friends"
    },
    Webhook = {
        Enabled = false, -- Send webhook notifications to Discord
        URL = "https://discord.com/api/", -- Discord webhook URL for notifications
        PetUnlock = {
            Enabled = false, -- Send webhook when hatching/unlocking a pet
            URL = "https://discord.com/api/webhooks/", -- Webhook URL for pet unlocks
            FilterRarities = {"legendary", "ultra_rare"}, -- Only send for these rarities
        },
    },
    TaskExclusion = {
        Enabled = false, -- Skip certain farming tasks
        ExcludedTasks = {}, -- Task IDs to skip (e.g., {"buccaneer_band", "summerfest_bonfire"})
    },
};
getgenv().scriptkey="PWUyrezPKtBiJjNHFgMYfmfDOKCZZmHi"
loadstring(game:HttpGet("https://zekehub.com/scripts/AdoptMe/MassFarm.lua"))()
