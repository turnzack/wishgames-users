local colors = {
    primary = {0.9, 0.4, 0.8, 0.7},
    secondary = {0.3, 0.3, 0.8, 0.7},
    background = {
        gradient1 = {0.9, 0.4, 0.8, 0.3},
        gradient2 = {0.3, 0.3, 0.8, 0.3}
    },
    text = {
        primary = {1, 1, 1, 1},
        secondary = {0.8, 0.8, 0.8, 1},
        accent = {0.8, 0.4, 0.1, 1}
    },
    error = {1, 0.3, 0.3, 1},
    BUTTON = {  -- Couleurs des boutons
        default = {
            {0.8, 0.4, 0.1, 1},  -- Orange
            {0.9, 0.3, 0.7, 1},  -- Rose
            {0.3, 0.6, 0.9, 1},  -- Bleu
            {0.4, 0.8, 0.4, 1},  -- Vert
            {0.8, 0.3, 0.3, 1}   -- Rouge
        },
        over = {
            {1, 0.5, 0.2, 1},    -- Orange clair
            {1, 0.4, 0.8, 1},    -- Rose clair
            {0.4, 0.7, 1, 1},    -- Bleu clair
            {0.5, 0.9, 0.5, 1},  -- Vert clair
            {0.9, 0.4, 0.4, 1}   -- Rouge clair
        }
    },
    BORDER = {0.4, 0.4, 0.5, 1},      -- Couleur de bordure
    TEXT_LIGHT = {1, 1, 1, 1},        -- Texte clair
    TEXT_DARK = {0.2, 0.2, 0.2, 1}    -- Texte foncé
}

return colors
