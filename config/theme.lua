local theme = {
    COLORS = {
        PRIMARY = {0.2, 0.4, 0.8},
        SECONDARY = {0.8, 0.2, 0.4},
        BACKGROUND = {0.15, 0.15, 0.2},
        TEXT_LIGHT = {1, 1, 1},
        TEXT_DARK = {0.2, 0.2, 0.2},
        BORDER = {0.4, 0.4, 0.5},
        BUTTON = {
            default = {
                {0.9, 0.4, 0.8},
                {0.3, 0.3, 0.8},
                {0.4, 0.6, 0.9}
            }
        }
    },
    
    FONTS = {
        DEFAULT = "Arial-Bold",
        FALLBACK = native.systemFont,
        SIZES = {
            SMALL = 14,
            MEDIUM = 18,
            LARGE = 24,
            TITLE = 32
        }
    }
}

return theme
