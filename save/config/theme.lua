local theme = {
    colors = {
        primary = {0.2, 0.4, 0.8},
        secondary = {0.8, 0.2, 0.4},
        background = {0.1, 0.1, 0.2},
        text = {1, 1, 1},
        textDark = {0.2, 0.2, 0.2},
        border = {0.4, 0.4, 0.5},
        success = {0.2, 0.8, 0.2},
        error = {0.8, 0.2, 0.2},
        warning = {0.8, 0.8, 0.2}
    },
    
    gradients = {
        primary = {
            type = "gradient",
            color1 = {0.9, 0.4, 0.8, 0.3},
            color2 = {0.3, 0.3, 0.8, 0.3}
        }
    },
    
    fonts = {
        regular = native.systemFont,
        bold = native.systemFontBold
    },
    
    sizes = {
        small = 12,
        medium = 16,
        large = 24,
        xlarge = 32
    }
}

return theme
