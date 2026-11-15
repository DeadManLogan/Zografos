-- 16x16 Greek amphora (black-figure style), v1
local px = dofile("tools/aseprite/lib/pixel.lua")
local C = px.use("herbs_n_spices")

local legend = {
  K = C.plum_dark,  -- outline
  B = C.ink,        -- black glaze decoration
  O = C.ochre,      -- clay base
  L = C.sand,       -- light
  S = C.terracotta, -- shade
  T = C.umber,      -- deep shade
  A = C.aubergine,  -- sheen on black glaze
}

-- v3: narrow lip + taller neck (amphora, not jar), handles span the neck,
-- no symmetric dark features on the upper body (v2 read as a face),
-- glazed black lower body with a sheen pixel.
local rows = {
  ".....KKKKKK.....", -- 0 lip top
  ".....KLOOSK.....", -- 1 lip
  "...KKKKSSKKKK...", -- 2 lip shadow, handle tops
  "..K...KLOK...K..", -- 3 neck
  "..K...KOSK...K..", -- 4 neck
  "..K..KLLOSK..K..", -- 5 shoulder
  "..KKOLLOOOSSKK..", -- 6 shoulder (handles join)
  "..KOLLOOOOSSTK..", -- 7 belly (widest)
  "..KOLOOOOOSSTK..", -- 8 belly
  "...KOOOOOSSTK...", -- 9 belly
  "...KBBBBBBBBK...", -- 10 glaze line
  "....KBABBBBK....", -- 11 glazed lower body + sheen
  ".....KBBBBK.....", -- 12 glazed lower body
  "......KBBK......", -- 13 stem
  ".....KOOSTK.....", -- 14 foot rim
  ".....KKKKKK.....", -- 15 foot base
}

px.build("amphora", rows, legend)
