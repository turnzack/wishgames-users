local M = {}

-- Define color palette
M.colors = {
    primary = { 0.2, 0.6, 1 },
    secondary = { 0.8, 0.2, 0.8 },
    background = { 0.1, 0.1, 0.1 },
    text = { 1, 1, 1 }
}

function M.getColors()
    return M.colors
end

return M