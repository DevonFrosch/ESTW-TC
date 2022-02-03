local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"

return {
    gleisbildDatei = "gleisbild.txt",
    stellwerkName = "Test",
    bildschirm = "right",
    modem = "top",

    speichereFahrstrassen = true,

    -- Richtung: r = nach rechts, l = nach links
    signale = {
        ["A"]     = {x = 09,  y = 05, richtung = "r",
            stelle_hp  = {pc = "client1", au = "right", fb = 0},
            stelle_ers = {pc = "client1", au = "right",  fb = 8},
            haltAbschnitte = {"012"},
        },
        ["AA"]    = {x = 09,  y = 03, richtung = "r",
            stelle_hp  = {pc = "client1", au = "right", fb = 1},
            stelle_ers = {pc = "client1", au = "right",  fb = 9},
            haltAbschnitte = {"012"},
        },
        ["F"]     = {x = 42,  y = 03, richtung = "l",
            stelle_hp  = {pc = "client1", au = "right", fb = 2},
            stelle_ers = {pc = "client1", au = "right",  fb = 10},
            haltAbschnitte = {"012"},
        },
        
        ["N1"]    = {x = 34,  y = 03, richtung = "r",
            stelle_hp  = {pc = "client1", au = "right", fb = 3},
            stelle_sh  = {pc = "client1", au = "left",   fb = 3},
            stelle_ers = {pc = "client1", au = "right",  fb = 11},
        },
        ["N2"]    = {x = 34,  y = 05, richtung = "r",
            stelle_hp  = {pc = "client1", au = "right", fb = 4},
            stelle_sh  = {pc = "client1", au = "left",   fb = 4},
            stelle_ers = {pc = "client1", au = "right",  fb = 12},
        },
        ["P1"]    = {x = 25,  y = 03, richtung = "l",
            stelle_hp  = {pc = "client1", au = "right", fb = 5},
            stelle_sh  = {pc = "client1", au = "left",   fb = 5},
            stelle_ers = {pc = "client1", au = "right",  fb = 13},
        },
        ["P2"]    = {x = 25,  y = 05, richtung = "l",
            stelle_hp  = {pc = "client1", au = "right", fb = 6},
            stelle_sh  = {pc = "client1", au = "left",   fb = 6},
            stelle_ers = {pc = "client1", au = "right",  fb = 14},
        },
        
        ["L011X"] = {x = 17,  y = 03, richtung = "r",
            stelle_sh = {pc = "client1", au = "left", fb = 0},
        },
        ["L012X"] = {x = 17,  y = 05, richtung = "r",
            stelle_sh = {pc = "client1", au = "left", fb = 1},
        },
    },
    fsZiele = {
        ["AH"]  = {x = 01, y = 03, laenge = 7},
        ["AHG"] = {x = 01, y = 05, laenge = 7},
        ["BH"]  = {x = 45, y = 05, laenge = 7},
        
        ["011"] = {x = 12, y = 03, laenge = 4},
        ["012"] = {x = 12, y = 05, laenge = 4},
    },
    fsAufloeser = {
        ["011A"] = {pc = "client1", au = "back", fb = 4},
        ["012A"] = {pc = "client1", au = "back", fb = 5},
        
        ["022A"] = {pc = "client1", au = "back", fb = 6},
    },
    bahnuebergaenge = {
    },
    gleise = {
        ["001"] = {x = 28, y = 03, pc = "client1", au = "back", fb = 0, text = "--1--"},
        ["002"] = {x = 28, y = 05, pc = "client1", au = "back", fb = 1, text = "--2--"},
        
        ["011"] = {x = 12, y = 03, pc = "client1", au = "back", fb = 2, text = "-11-"},
        ["012"] = {x = 12, y = 05, pc = "client1", au = "back", fb = 3, text = "-12-"},
    },
    weichen = {
        ["W1/2"]   = {pc = "client1", au = "left", fb = 14},
        ["W3/4"]   = {pc = "client1", au = "left", fb = 15},
    },
    fahrstrassenteile = {
        ["W2R"]    = {x = 19, y = 03, text = "---"},
        ["W2"]     = {x = 23, y = 03, text = "-"},
        ["W3"]     = {x = 37, y = 03, text = "-"},
        ["W3L"]    = {x = 39, y = 03, text = "--"},
        
        ["W1L"]    = {x = 21, y = 04, text = "/"},
        ["W3R"]    = {x = 39, y = 04, text = "\\"},
        
        ["W1"]     = {x = 19, y = 05, text = "-"},
        ["W1R"]    = {x = 21, y = 05, text = "---"},
        ["W4L"]    = {x = 37, y = 05, text = "---"},
        ["W4"]     = {x = 41, y = 05, text = "---"},
    },
    fahrstrassen = {
        ["A.N1"] = {
            gleise = {"012","001"},
            signale = {
                ["A"] = SIGNAL_HP,
                ["L012X"] = SIGNAL_SH,
            },
            haltAbschnitte = {"001"},
            fsTeile = {"012","W1","W1L","W2","001"},
            weichen = {"W1/2"},
        },
        ["A.N2"] = {
            gleise = {"012","002"},
            signale = {
                ["A"] = SIGNAL_HP,
                ["L012X"] = SIGNAL_SH,
            },
            haltAbschnitte = {"002"},
            fsTeile = {"012","W1","W1R","002"},
            weichen = {},
        },
        ["AA.N1"] = {
            gleise = {"011","001"},
            signale = {
                ["AA"] = SIGNAL_HP,
                ["L011X"] = SIGNAL_SH,
            },
            haltAbschnitte = {"001"},
            fsTeile = {"011","W2R","W2","001"},
            weichen = {},
        },
        ["F.P1"] = {
            gleise = {"001"},
            signale = {["F"] = SIGNAL_HP},
            haltAbschnitte = {"001"},
            fsTeile = {"W3L","W3","001"},
            weichen = {},
        },
        
        ["N1.BH"] = {
            gleise = {},
            signale = {["N1"] = SIGNAL_HP},
            aufloeseAbschn = "022A",
            fsTeile = {"W3","W3R","W4"},
            weichen = {"W3/4"},
        },
        ["N2.BH"] = {
            gleise = {},
            signale = {["N2"] = SIGNAL_HP},
            aufloeseAbschn = "022A",
            fsTeile = {"W4L","W4"},
            weichen = {},
        },
        ["P1.AH"] = {
            gleise = {"011"},
            signale = {["P1"] = SIGNAL_HP},
            haltAbschnitte = {"011"},
            aufloeseAbschn = "011A",
            fsTeile = {"011","W2R","W2"},
            weichen = {},
        },
        ["P1.AHG"] = {
            gleise = {"012"},
            signale = {["P1"] = SIGNAL_HP},
            haltAbschnitte = {"012"},
            aufloeseAbschn = "011A",
            fsTeile = {"012","W1","W1L","W2"},
            weichen = {"W1/2"},
        },
        ["P2.AHG"] = {
            gleise = {"012"},
            signale = {["P2"] = SIGNAL_HP},
            haltAbschnitte = {"012"},
            aufloeseAbschn = "011A",
            fsTeile = {"012","W1","W1R"},
            weichen = {},
        },
        
        ["L012X-N1"] = {
            rangieren = true,
            signale = {["L012X"] = SIGNAL_SH},
            haltAbschnitte = {"001"},
            fsTeile = {"W1","W1L","W2","001"},
            weichen = {"W1/2"},
        },
        ["L012X-N2"] = {
            rangieren = true,
            signale = {["L012X"] = SIGNAL_SH},
            haltAbschnitte = {"002"},
            fsTeile = {"W1","W1R","002"},
            weichen = {},
        },
        ["L011X-N1"] = {
            rangieren = true,
            signale = {["L011X"] = SIGNAL_SH},
            haltAbschnitte = {"001"},
            fsTeile = {"W2R","W2","001"},
            weichen = {},
        },
        
        ["P1-011"] = {
            rangieren = true,
            signale = {["P1"] = SIGNAL_SH},
            haltAbschnitte = {"011"},
            fsTeile = {"011","W2R","W2"},
            weichen = {},
        },
        ["P1-012"] = {
            rangieren = true,
            signale = {["P1"] = SIGNAL_SH},
            haltAbschnitte = {"012"},
            fsTeile = {"012","W1","W1L","W2"},
            weichen = {"W1/2"},
        },
        ["P2-012"] = {
            rangieren = true,
            signale = {["P2"] = SIGNAL_SH},
            haltAbschnitte = {"012"},
            fsTeile = {"012","W1","W1R"},
            weichen = {},
        },
    },
}
