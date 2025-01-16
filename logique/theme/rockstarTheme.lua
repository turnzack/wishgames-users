local easing = require("easing")

local theme = {
    colors = {
        deepPurple = { 0.16, 0.11, 0.24 },    -- #2A1B3D
        electricBlue = { 0, 0.66, 1 },        -- #00A9FF
        neonPurple = { 0.62, 0.31, 0.87 },    -- #9D4EDD
        lightBlue = { 0., 0.81, 0.94 },     -- #89CFF0
        black = { 0.04, 0.04, 0.04 },         -- #0A0A0A
        white = { 1, 1, 1 }                   -- #FFFFFF
    },
    effects = {
        glow = {
            card = { size = 15, alpha = 0.5 },
            cardHover = { size = 25, alpha = 0.7 },
            text = { size = 8, alpha = 0.6 }
        },
        gradient = {
            type = "radial",
            ratio = 0.7
        }
    },
    animation = {
        pulse = {
            time = 3000,
            iterations = 0,  -- infinite
            keyframes = {
                { time = 0, alpha = 0.5, size = 5 },
                { time = 0.5, alpha = 0.7, size = 15 },
                { time = 1, alpha = 0.5, size = 5 }
            }
        },
        transition = {
            time = 300,
            ease = easing.inOutQuad
        }
    }
}

return theme
