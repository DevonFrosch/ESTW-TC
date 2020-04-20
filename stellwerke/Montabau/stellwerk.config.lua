local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"

-- Richtung: r = nach rechts, l = nach links
signale = {
	-- Hauptsignale
    ["A"]    = {x = 09,  y = 10, richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 0},
        stelle_ers = {pc = "signale", au = "left",   fb = 0},
    },
    ["AA"]   = {x = 09,  y = 08,  richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 1},
        stelle_ers = {pc = "signale", au = "left",   fb = 1},
    },
    ["B"]    = {x = 09, y = 04,  richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 2},
        stelle_ers = {pc = "signale", au = "left",   fb = 2},
    },
    ["F"]    = {x = 66, y = 08,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 3},
        stelle_ers = {pc = "signale", au = "left",   fb = 3},
    },
    ["FF"]   = {x = 66, y = 10, richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 4},
        stelle_ers = {pc = "signale", au = "left",   fb = 4},
    },
    ["G"]    = {x = 62, y = 02,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 5},
        stelle_ers = {pc = "signale", au = "left",   fb = 5},
    },
    ["N1"]   = {x = 44, y = 12, richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 7},
        stelle_sh  = {pc = "signale", au = "top",  fb = 7},
        stelle_ers = {pc = "signale", au = "left",   fb = 7},
    },
    ["N2"]   = {x = 44, y = 10, richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 8},
        stelle_sh  = {pc = "signale", au = "top",  fb = 8},
        stelle_ers = {pc = "signale", au = "left",   fb = 8},
    },
    ["N4"]   = {x = 44, y = 06,  richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 9},
        stelle_sh  = {pc = "signale", au = "top",  fb = 9},
        stelle_ers = {pc = "signale", au = "left",   fb = 9},
    },
    ["N5-6"] = {x = 55, y = 02,  richtung = "r",
        stelle_hp  = {pc = "signale", au = "right", fb = 10},
        stelle_sh  = {pc = "signale", au = "top",  fb = 10},
        stelle_ers = {pc = "signale", au = "left",   fb = 10},
    },
    ["P1"]   = {x = 31, y = 12, richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 11},
        stelle_sh  = {pc = "signale", au = "top",  fb = 11},
        stelle_ers = {pc = "signale", au = "left",   fb = 11},
    },
    ["P3"]   = {x = 31, y = 08,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 12},
        stelle_sh  = {pc = "signale", au = "top",  fb = 12},
        stelle_ers = {pc = "signale", au = "left",   fb = 12},
    },
    ["P4"]   = {x = 31, y = 06,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 13},
        stelle_sh  = {pc = "signale", au = "top",  fb = 13},
        stelle_ers = {pc = "signale", au = "left",   fb = 13},
    },
    ["P5"]   = {x = 31, y = 04,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 14},
        stelle_sh  = {pc = "signale", au = "top",  fb = 14},
        stelle_ers = {pc = "signale", au = "left",   fb = 14},
    },
    ["P6"]   = {x = 31, y = 02,  richtung = "l",
        stelle_hp  = {pc = "signale", au = "right", fb = 15},
        stelle_sh  = {pc = "signale", au = "top",  fb = 15},
        stelle_ers = {pc = "signale", au = "left",   fb = 15},
    },
	
	-- Sperrsignale
    ["L003X"] = {x = 45,  y = 08, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 0},
    },
    ["L005X"] = {x = 45,  y = 04, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 1},
    },
    ["L006X"] = {x = 45,  y = 02, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 2},
    },
    ["L012X"] = {x = 16,  y = 10, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 3},
    },
    ["L013X"] = {x = 16,  y = 08, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 4},
    },
    ["L015X"] = {x = 16,  y = 04, richtung = "r",
        stelle_sh = {pc = "signale", au = "bottom", fb = 5},
    },
    ["L002Y"] = {x = 31,  y = 10, richtung = "l",
        stelle_sh = {pc = "signale", au = "bottom", fb = 6},
    },
    ["L022Y"] = {x = 60,  y = 10, richtung = "l",
        stelle_sh = {pc = "signale", au = "bottom", fb = 7},
    },
}

fsZiele = {
    ["BR"]  = {x = 01, y = 04, laenge = 7},
    ["SF"]  = {x = 01, y = 08, laenge = 7},
    ["SFG"] = {x = 01, y = 10, laenge = 7},
    ["EH"]  = {x = 65, y = 02, laenge = 6},
    ["TLG"] = {x = 69, y = 08, laenge = 7},
    ["TL"]  = {x = 69, y = 10, laenge = 7},
    ["012"] = {x = 12, y = 10, laenge = 3},
    ["013"] = {x = 12, y = 08, laenge = 3},
    ["015"] = {x = 12, y = 04, laenge = 3},
    ["022"] = {x = 62, y = 10, laenge = 3},
}

bahnuebergaenge = {}

gleise = {
    ["001"] = {x = 34, y = 12, pc = "weiche+belegung", au = "left", fb = 0, text = "--- 1 ---"},
    ["002"] = {x = 34, y = 10, pc = "weiche+belegung", au = "left", fb = 1, text = "--- 2 ---"},
    ["003"] = {x = 34, y = 08, pc = "weiche+belegung", au = "left", fb = 2, text = "--- 3 ---"},
    ["004"] = {x = 34, y = 06, pc = "weiche+belegung", au = "left", fb = 3, text = "--- 4 ---"},
    ["005"] = {x = 34, y = 04, pc = "weiche+belegung", au = "left", fb = 4, text = "--- 5 ---"},
    ["006"] = {x = 34, y = 02, pc = "weiche+belegung", au = "left", fb = 5, text = "--- 6 ---"},
    ["BR"]  = {x = 05, y = 04, pc = "weiche+belegung", au = "left", fb = 6, text = "<<-"},
    ["SF"]  = {x = 05, y = 08, pc = "weiche+belegung", au = "left", fb = 7, text = "<<-"},
    ["SFG"] = {x = 05, y = 10, pc = "weiche+belegung", au = "left", fb = 8, text = "<<-"},
    ["EH"]  = {x = 65, y = 02, pc = "weiche+belegung", au = "left", fb = 9, text = "->>"},
    ["TLG"] = {x = 69, y = 08, pc = "weiche+belegung", au = "left", fb = 10, text = "->>"},
    ["TL"]  = {x = 69, y = 10, pc = "weiche+belegung", au = "left", fb = 11, text = "->>"},
    ["012"] = {x = 12, y = 10, pc = "weiche+belegung", au = "left", fb = 12, text = "-<-"},
    ["013"] = {x = 12, y = 08, pc = "weiche+belegung", au = "left", fb = 13, text = "-<-"},
    ["015"] = {x = 12, y = 04, pc = "weiche+belegung", au = "left", fb = 14, text = "-<-"},
    ["022"] = {x = 62, y = 10, pc = "weiche+belegung", au = "left", fb = 15, text = "->-"},
}
weichen = {
	["W1/2"]   = {pc = "weiche+belegung", au = "right", fb = 0},
	["W3/4"]   = {pc = "weiche+belegung", au = "right", fb = 1},
	["W5/6"]   = {pc = "weiche+belegung", au = "right", fb = 2},
	["W11/12"] = {pc = "weiche+belegung", au = "right", fb = 4},
	["W13/14"] = {pc = "weiche+belegung", au = "right", fb = 5},
	["W15/16"] = {pc = "weiche+belegung", au = "right", fb = 6},
	["W21"]    = {pc = "weiche+belegung", au = "right", fb = 8},
	["W22"]    = {pc = "weiche+belegung", au = "right", fb = 9},
	["W23"]    = {pc = "weiche+belegung", au = "right", fb = 12},
	["W24"]    = {pc = "weiche+belegung", au = "right", fb = 13},
}
fahrstrassenteile = {
	["W22L/2"] = {x = 28, y = 02, text = "--"},
    ["006"]    = {x = 34, y = 02, text = "--- 6 ---"},
	["W23R"]   = {x = 47, y = 02, text = "----"},
	["W23"]    = {x = 52, y = 02, text = "--"},
	["026"]    = {x = 58, y = 02, text = "---"},
    ["EH"]     = {x = 65, y = 02, text = "->>"},
	
	["W22L/1"] = {x = 26, y = 03, text = "/"},
	["W23L/2"] = {x = 50, y = 03, text = "/"},
	
    ["BR"]     = {x = 05, y = 04, text = "<<-"},
    ["015"]    = {x = 12, y = 04, text = "-<-"},
	["W21"]    = {x = 18, y = 04, text = "----"},
	["W21L"]   = {x = 23, y = 04, text = "--"},
	["W22R"]   = {x = 26, y = 04, text = "----"},
    ["005"]    = {x = 34, y = 04, text = "--- 5 ---"},
	["W23L/1"] = {x = 47, y = 04, text = "--"},
	
	["W21R/1"] = {x = 23, y = 05, text = "\\"},
	
	["W21R/2"] = {x = 25, y = 06, text = "--"},
	["W4"]     = {x = 28, y = 06, text = "--"},
    ["004"]    = {x = 34, y = 06, text = "--- 4 ---"},
	["W11R/1"] = {x = 47, y = 06, text = "--"},
	
	["W4L"]    = {x = 26, y = 07, text = "/"},
	["W11R/2"] = {x = 50, y = 07, text = "\\"},
	
    ["SF"]     = {x = 05, y = 08, text = "<<-"},
    ["013"]    = {x = 12, y = 08, text = "-<-"},
	["W2R"]    = {x = 18, y = 08, text = "----"},
	["W2"]     = {x = 23, y = 08, text = "--"},
	["W3R"]    = {x = 26, y = 08, text = "----"},
    ["003"]    = {x = 34, y = 08, text = "--- 3 ---"},
	["W12L"]   = {x = 47, y = 08, text = "----"},
	["W12"]    = {x = 52, y = 08, text = "--"},
	["W15L"]   = {x = 55, y = 08, text = "----------"},
    ["TLG"]    = {x = 69, y = 08, text = "->>"},
	
	["W1L"]    = {x = 21, y = 09, text = "/"},
	["W15R"]   = {x = 55, y = 09, text = "\\"},
	
    ["SFG"]    = {x = 05, y = 10, text = "<<-"},
    ["012"]    = {x = 12, y = 10, text = "-<-"},
	["W1"]     = {x = 18, y = 10, text = "--"},
	["W1R"]    = {x = 21, y = 10, text = "----"},
	["W5L"]    = {x = 26, y = 10, text = "----"},
    ["002"]    = {x = 34, y = 10, text = "--- 2 ---"},
	["W14R"]   = {x = 47, y = 10, text = "----"},
	["W16L"]   = {x = 52, y = 10, text = "----"},
	["W16"]    = {x = 57, y = 10, text = "--"},
    ["022"]    = {x = 62, y = 10, text = "->-"},
    ["TL"]     = {x = 69, y = 10, text = "->>"},
	
	["W6R/1"]  = {x = 26, y = 11, text = "\\"},
	["W13L/2"] = {x = 50, y = 11, text = "/"},
	
	["W6R/2"]  = {x = 28, y = 12, text = "--"},
    ["001"]    = {x = 34, y = 12, text = "--- 1 ---"},
	["W13L/1"] = {x = 47, y = 12, text = "--"},
}
fahrstrassen = {
    ["A.N1"] = {
        gleise = {
            ["012"] = true,
            ["001"] = true,
        },
        signale = {
            ["A"] = SIGNAL_HP,
            ["L012X"] = SIGNAL_SH,
        },
        fsTeile = {"012","W1","W1R","W6R","001"},
		weichen = {"W5/6"},
    },
    ["A.N2"] = {
        gleise = {
            ["012"] = true,
            ["002"] = true,
        },
        signale = {
            ["A"] = SIGNAL_HP,
            ["L012X"] = SIGNAL_SH,
        },
        fsTeile = {"012","W1","W1R","W5L","002"},
		weichen = {},
    },
    ["A.N4"] = {
        gleise = {
            ["012"] = true,
            ["004"] = true,
        },
        signale = {
            ["A"] = SIGNAL_HP,
            ["L012X"] = SIGNAL_SH,
        },
        fsTeile = {"012","W1","W1L","W2","W4L","W4","004"},
		weichen = {"W1/2","W3/4"},
    },
    ["AA.N4"] = {
        gleise = {
            ["013"] = true,
            ["004"] = true,
        },
        signale = {
            ["AA"] = SIGNAL_HP,
            ["L013X"] = SIGNAL_SH,
        },
        fsTeile = {"013","W2R","W2","W4L","W4","004"},
		weichen = {"W3/4"},
    },
    ["B.N4"] = {
        gleise = {
            ["015"] = true,
            ["004"] = true,
        },
        signale = {
            ["B"] = SIGNAL_HP,
            ["L015X"] = SIGNAL_SH,
        },
        fsTeile = {"015","W21","W21R","W4","004"},
		weichen = {"W21"},
    },
    ["B.L005X"] = {
        gleise = {
            ["015"] = true,
            ["005"] = true,
        },
        signale = {
            ["B"] = SIGNAL_HP,
            ["L015X"] = SIGNAL_SH,
        },
        fsTeile = {"015","W21","W21L","W22R","005"},
		weichen = {},
    },
    ["B.L006X"] = {
        gleise = {
            ["015"] = true,
            ["006"] = true,
        },
        signale = {
            ["B"] = SIGNAL_HP,
            ["L015X"] = SIGNAL_SH,
        },
        fsTeile = {"015","W21","W21L","W22L","006"},
		weichen = {"W22"},
    },
	
    ["F.P3"] = {
        gleise = {["003"] = true},
        signale = {["F"] = SIGNAL_HP},
        fsTeile = {"W15L","W12","W12L","003"},
		weichen = {},
    },
    ["F.P4"] = {
        gleise = {["004"] = true},
        signale = {["F"] = SIGNAL_HP},
        fsTeile = {"W15L","W12","W11R","004"},
		weichen = {"W11/12"},
    },
    ["FF.P1"] = {
        gleise = {
            ["001"] = true,
            ["022"] = true,
        },
        signale = {
            ["FF"] = SIGNAL_HP,
            ["L022Y"] = SIGNAL_SH,
        },
        fsTeile = {"022","W16","W16L","W13L","001"},
		weichen = {"W13/14"},
    },
    ["FF.P3"] = {
        gleise = {
            ["003"] = true,
            ["022"] = true,
        },
        signale = {
            ["FF"] = SIGNAL_HP,
            ["L022Y"] = SIGNAL_SH,
        },
        fsTeile = {"022","W16","W15R","W12","W12L","003"},
		weichen = {"W15/16"},
    },
    ["FF.P4"] = {
        gleise = {
            ["004"] = true,
            ["022"] = true,
        },
        signale = {
            ["FF"] = SIGNAL_HP,
            ["L022Y"] = SIGNAL_SH,
        },
        fsTeile = {"022","W16","W15R","W12","W11R","004"},
		weichen = {"W15/16","W11/12"},
    },
    ["G.P5"] = {
        gleise = {["005"] = true},
        signale = {["G"] = SIGNAL_HP},
        fsTeile = {"026","W23","W23L","005"},
		weichen = {"W23"},
    },
    ["G.P6"] = {
        gleise = {["006"] = true},
        signale = {["G"] = SIGNAL_HP},
        fsTeile = {"026","W23","W23R","006"},
		weichen = {},
	},
	
    ["N1.TL"] = {
        gleise = {["022"] = true},
        signale = {["N1"] = SIGNAL_HP},
        fsTeile = {"022","W16","W16L","W13L"},
		weichen = {"W13/14"},
	},
    ["N2.TL"] = {
        gleise = {["022"] = true},
        signale = {["N2"] = SIGNAL_HP},
        fsTeile = {"022","W16","W16L","W14R"},
		weichen = {},
	},
    ["N4.TL"] = {
        gleise = {["022"] = true},
        signale = {["N4"] = SIGNAL_HP},
        fsTeile = {"022","W16","W15R","W12","W11R"},
		weichen = {"W11/12","W15/16"},
	},
    ["N4.TLG"] = {
        signale = {["N4"] = SIGNAL_HP},
        fsTeile = {"W15L","W12","W11R"},
		weichen = {"W11/12"},
	},
    ["L005X.EH"] = {
        signale = {
            ["L005X"] = SIGNAL_SH,
            ["N5-6"] = SIGNAL_HP,
        },
        fsTeile = {"026","W23","W23L"},
		weichen = {"W23"},
	},
    ["L006X.EH"] = {
        signale = {
            ["L006X"] = SIGNAL_SH,
            ["N5-6"] = SIGNAL_HP,
        },
        fsTeile = {"026","W23","W23R"},
		weichen = {},
	},
	
    ["P1.SFG"] = {
        gleise = {["012"] = true},
        signale = {["P1"] = SIGNAL_HP},
        fsTeile = {"012","W1","W1R","W6R"},
		weichen = {"W5/6"},
	},
    ["P3.SFG"] = {
        gleise = {["012"] = true},
        signale = {["P3"] = SIGNAL_HP},
        fsTeile = {"012","W1","W1L","W2","W3R"},
		weichen = {"W1/2"},
	},
    ["P4.SFG"] = {
        gleise = {["012"] = true},
        signale = {["P4"] = SIGNAL_HP},
        fsTeile = {"012","W1","W1L","W2","W4L","W4"},
		weichen = {"W1/2","W3/4"},
	},
    ["P3.SF"] = {
        gleise = {["013"] = true},
        signale = {["P3"] = SIGNAL_HP},
        fsTeile = {"013","W2R","W2","W3R"},
		weichen = {},
	},
    ["P4.SF"] = {
        gleise = {["013"] = true},
        signale = {["P4"] = SIGNAL_HP},
        fsTeile = {"013","W2R","W2","W4L","W4"},
		weichen = {"W3/4"},
	},
    ["P4.BR"] = {
        gleise = {["015"] = true},
        signale = {["P4"] = SIGNAL_HP},
        fsTeile = {"015","W21","W21R","W4"},
		weichen = {"W21"},
	},
    ["P5.BR"] = {
        gleise = {["015"] = true},
        signale = {["P5"] = SIGNAL_HP},
        fsTeile = {"015","W21","W21L","W22R"},
		weichen = {},
	},
    ["P6.BR"] = {
        gleise = {["015"] = true},
        signale = {["P6"] = SIGNAL_HP},
        fsTeile = {"015","W21","W21L","W22L"},
		weichen = {"W22"},
    },
	
	-- Rangierstrassen
    ["L012X-N1"] = {
		rangieren = true,
        signale = {["L012X"] = SIGNAL_SH},
        fsTeile = {"W1","W1R","W6R","001"},
		weichen = {"W5/6"},
    },
    ["L012X-N2"] = {
		rangieren = true,
        signale = {["L012X"] = SIGNAL_SH},
        fsTeile = {"W1","W1R","W5L","002"},
		weichen = {},
    },
    ["L012X-L003X"] = {
		rangieren = true,
        signale = {["L012X"] = SIGNAL_SH},
        fsTeile = {"W1","W1L","W2","W3R","003"},
		weichen = {"W1/2"},
    },
    ["L012X-N4"] = {
		rangieren = true,
        signale = {["L012X"] = SIGNAL_SH},
        fsTeile = {"W1","W1L","W2","W4L","W4","004"},
		weichen = {"W1/2","W3/4"},
    },
    ["L013X-L003X"] = {
		rangieren = true,
        signale = {["L013X"] = SIGNAL_SH},
        fsTeile = {"W2R","W2","W3R","003"},
		weichen = {},
    },
    ["L013X-N4"] = {
		rangieren = true,
        signale = {["L013X"] = SIGNAL_SH},
        fsTeile = {"W2R","W2","W4L","W4","004"},
		weichen = {"W3/4"},
    },
    ["L015X-N4"] = {
		rangieren = true,
        signale = {["L015X"] = SIGNAL_SH},
        fsTeile = {"W21","W21R","W4","004"},
		weichen = {"W21"},
    },
    ["L015X-L005X"] = {
		rangieren = true,
        signale = {["L015X"] = SIGNAL_SH},
        fsTeile = {"W21","W21L","W22R","005"},
		weichen = {},
    },
    ["L015X-L006X"] = {
		rangieren = true,
        signale = {["L015X"] = SIGNAL_SH},
        fsTeile = {"W21","W21L","W22L","006"},
		weichen = {"W22"},
    },
	
	["L022Y-P1"] = {
		rangieren = true,
        signale = {["L022Y"] = SIGNAL_SH},
        fsTeile = {"W16","W16L","W13L","001"},
		weichen = {"W13/14"},
    },
	["L022Y-L002Y"] = {
		rangieren = true,
        signale = {["L022Y"] = SIGNAL_SH},
        fsTeile = {"W16","W16L","W14R","002"},
		weichen = {},
    },
    ["L022Y-P3"] = {
		rangieren = true,
        signale = {["L022Y"] = SIGNAL_SH},
        fsTeile = {"W16","W15R","W12","W12L","003"},
		weichen = {"W15/16"},
    },
    ["L022Y-P4"] = {
		rangieren = true,
        signale = {["L022Y"] = SIGNAL_SH},
        fsTeile = {"W16","W15R","W12","W11R","004"},
		weichen = {"W15/16","W11/12"},
    },
	
    ["N1-022"] = {
		rangieren = true,
        signale = {["N1"] = SIGNAL_SH},
        fsTeile = {"022","W16","W16L","W13L"},
		weichen = {"W13/14"},
	},
    ["N2-022"] = {
		rangieren = true,
        signale = {["N2"] = SIGNAL_SH},
        fsTeile = {"022","W16","W16L","W14R"},
		weichen = {},
	},
    ["L003X-022"] = {
		rangieren = true,
        signale = {["L003X"] = SIGNAL_SH},
        fsTeile = {"022","W16","W15R","W12","W12L"},
		weichen = {"W15/16"},
	},
    ["N4-022"] = {
		rangieren = true,
        signale = {["N4"] = SIGNAL_SH},
        fsTeile = {"022","W16","W15R","W12","W11R"},
		weichen = {"W11/12","W15/16"},
	},
	
    ["P1-012"] = {
		rangieren = true,
        signale = {["P1"] = SIGNAL_SH},
        fsTeile = {"012","W1","W1R","W6R"},
		weichen = {"W5/6"},
	},
    ["L002Y-012"] = {
		rangieren = true,
        signale = {["L002Y"] = SIGNAL_SH},
        fsTeile = {"012","W1","W1R","W5L"},
		weichen = {},
	},
    ["P3-012"] = {
		rangieren = true,
        signale = {["P3"] = SIGNAL_SH},
        fsTeile = {"012","W1","W1L","W2","W3R"},
		weichen = {"W1/2"},
	},
    ["P4-012"] = {
		rangieren = true,
        signale = {["P4"] = SIGNAL_SH},
        fsTeile = {"012","W1","W1L","W2","W4L","W4"},
		weichen = {"W1/2","W3/4"},
	},
    ["P3-013"] = {
		rangieren = true,
        signale = {["P3"] = SIGNAL_SH},
        fsTeile = {"013","W2R","W2","W3R"},
		weichen = {},
	},
    ["P4-013"] = {
		rangieren = true,
        signale = {["P4"] = SIGNAL_SH},
        fsTeile = {"013","W2R","W2","W4L","W4"},
		weichen = {"W3/4"},
	},
    ["P4-015"] = {
		rangieren = true,
        signale = {["P4"] = SIGNAL_SH},
        fsTeile = {"015","W21","W21R","W4"},
		weichen = {"W21"},
	},
    ["P5-015"] = {
		rangieren = true,
        signale = {["P5"] = SIGNAL_SH},
        fsTeile = {"015","W21","W21L","W22R"},
		weichen = {},
	},
    ["P6-015"] = {
		rangieren = true,
        signale = {["P6"] = SIGNAL_SH},
        fsTeile = {"015","W21","W21L","W22L"},
		weichen = {"W22"},
	},
}

gleisbildDatei = "gleisbild.txt"
stellwerkName = "Montabau"
bildschirm = "right"
modem = "top"

speichereFahrstrassen = true
