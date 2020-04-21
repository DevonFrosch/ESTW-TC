local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"

gleisbildDatei = "gleisbild.txt"
stellwerkName = "St Friedenau"
bildschirm = "right"
modem = "top"

speichereFahrstrassen = false

-- Richtung: r = nach rechts, l = nach links
signale = {
    ["F"]    = {x = 09,  y = 08, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["FF"]   = {x = 09,  y = 06, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["G"]    = {x = 09,  y = 04, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["GG"]   = {x = 09,  y = 02, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    
    ["N1"]   = {x = 47,  y = 08, richtung = "l", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["N2"]   = {x = 47,  y = 06, richtung = "l", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["N3"]   = {x = 47,  y = 04, richtung = "l", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["N4"]   = {x = 47,  y = 02, richtung = "l", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    
    ["P1"]   = {x = 60,  y = 08, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["P2"]   = {x = 60,  y = 06, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["P3"]   = {x = 60,  y = 04, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    ["P4"]   = {x = 60,  y = 02, richtung = "r", stelle_hp  = {pc = "signale", au = "right", fb = 14}},
    
    ["L021X"] = {x = 20,  y = 08, richtung = "l"},
    ["L022X"] = {x = 20,  y = 06, richtung = "l"},
    ["L023X"] = {x = 20,  y = 04, richtung = "l"},
    ["L024X"] = {x = 20,  y = 02, richtung = "l"},
    
    ["L021Y"] = {x = 36,  y = 08, richtung = "r"},
    ["L022Y"] = {x = 27,  y = 06, richtung = "r"},
    ["L023Y"] = {x = 27,  y = 04, richtung = "r"},
    ["L024Y"] = {x = 39,  y = 02, richtung = "r"},
}
fsZiele = {
    ["FB"]  = {x = 01, y = 02, laenge = 7},
    ["FBG"] = {x = 01, y = 04, laenge = 7},
    
    ["021"] = {x = 22, y = 08, laenge = 13},
    ["022"] = {x = 22, y = 06, laenge = 4},
    ["023"] = {x = 22, y = 04, laenge = 4},
    ["024"] = {x = 22, y = 02, laenge = 16},
}
fsAufloeser = {
}
bahnuebergaenge = {
}
gleise = {
    ["001"] = {x = 50, y = 08, text = "--- 1 ---"},
    ["002"] = {x = 50, y = 06, text = "--- 2 ---"},
    ["003"] = {x = 50, y = 04, text = "--- 3 ---"},
    ["004"] = {x = 50, y = 02, text = "--- 4 ---"},
    
    ["021"] = {x = 22, y = 08, text = "-21----------"},
    ["022"] = {x = 22, y = 06, text = "-22-"},
    ["023"] = {x = 22, y = 04, text = "-23-"},
    ["024"] = {x = 22, y = 02, text = "-24-------------"},
}
weichen = {
}
fahrstrassenteile = {
}
fahrstrassen = {
    
}
