local composer = require("composer")
local widget = require("widget")
local json = require("json")
local colors = {
    TEXT_LIGHT = {1, 1, 1},
    BORDER = {0.4, 0.4, 0.5},
    BUTTON = {
        default = {
            {0.9, 0.4, 0.8},
            {0.3, 0.3, 0.8},
            {0.4, 0.6, 0.9}
        }
    }
}
local display = require("display")
local native = require("native")
local transition = require("transition")
local easing = require("easing")

local unpack = table.unpack or function(t, i, j)
    i = i or 1
    j = j or #t
    if i <= j then
        return t[i], unpack(t, i + 1, j)
    end
end

local scene = composer.newScene()

-- Configuration de la grille pour Note 20 Ultra
local GRID_COLS = 5
local PADDING = 8
local BLOCK_WIDTH = 55
local BLOCK_HEIGHT = 70
local SCREEN_WIDTH = display.actualContentWidth
local SCREEN_HEIGHT = display.actualContentHeight

-- Couleurs du thème sombre
local COLORS = {
    background = {0.15, 0.15, 0.2},
    blockBackground = {0.25, 0.25, 0.3},
    text = {1, 1, 1},
    blockBorder = {0.4, 0.4, 0.5}
}

-- Couleurs GTA 6 inspirées
local GTA_COLORS = {
    background = {0.85, 0.25, 0.07},
    highlight = {1, 0.4, 0.1},
    text = {1, 1, 1}
}

-- Couleurs de dégradé violet clair
local FUNCTION_COLORS = {
    top = {0.8, 0.7, 0.9},
    bottom = {0.7, 0.6, 0.85},
    tapTop = {0.6, 0.5, 0.75},
    tapBottom = {0.5, 0.4, 0.7}
}

local function getRandomColor()
    local colors = require("logique.theme.colors")
    local buttonColors = colors.BUTTON.default
    local randomIndex = math.random(#buttonColors)
    return buttonColors[randomIndex]
end

local function createIconBlock(icon, label, sceneName, x, y)
    local group = display.newGroup()
    local colors = require("logique.theme.colors")
    
    local color1 = getRandomColor()
    local color2 = getRandomColor()
    while color1 == color2 do
        color2 = getRandomColor()
    end
    
    local block = display.newRoundedRect(group, 0, 0, BLOCK_WIDTH, BLOCK_HEIGHT, 8)
    
    local initialGradient = {
        type = "gradient",
        color1 = {color1[1], color1[2], color1[3], 0.7}, 
        color2 = {color2[1], color2[2], color2[3], 0.7},
        direction = "down"
    }
    block:setFillColor(initialGradient)
    
    block.strokeWidth = 1
    block:setStrokeColor(unpack(colors.BORDER))
    
    local iconText = display.newText({
        parent = group,
        text = icon,
        x = 0,
        y = -10,
        font = native.systemFont,
        fontSize = 22
    })
    iconText:setFillColor(unpack(colors.TEXT_LIGHT))
    
    local labelText = display.newText({
        parent = group,
        text = label,
        x = 0,
        y = 20,
        font = native.systemFontBold,
        fontSize = 8,
        width = BLOCK_WIDTH - 3,
        align = "center"
    })
    labelText:setFillColor(unpack(colors.TEXT_LIGHT))
    
    group.x = x
    group.y = y
    
    local function onTap(event)
        if sceneName then
            composer.gotoScene(sceneName, {
                effect = "slideLeft",
                time = 300
            })
        end
        return true
    end
    
    group:addEventListener("tap", onTap)
    
    return group
end

function scene:create(event)
    local sceneGroup = self.view
    
    local background = display.newRect(
        sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.actualContentWidth,
        display.actualContentHeight
    )
    
    local gradient = {
        type = "gradient",
        color1 = {0.9, 0.4, 0.8, 0.3},
        color2 = {0.3, 0.3, 0.8, 0.3}
    }
    background:setFillColor(gradient)
    
    local numLines = 8
    local lineSpacing = display.actualContentHeight / (numLines + 1)
    for i = 1, numLines do
        local line = display.newLine(
            sceneGroup,
            0, i * lineSpacing,
            display.actualContentWidth, i * lineSpacing
        )
        line:setStrokeColor(1, 1, 1, 0.1)
        line.strokeWidth = 1
    end

    local iconGroup = display.newGroup()
    sceneGroup:insert(iconGroup)
    
    local icons = {
        {id = "menu", label = "Menu", icon = "📋", scene = "scenes.menu"},
        {id = "user", label = "Profil", icon = "👤", scene = "scenes.user"},
        {id = "settings", label = "Paramètres", icon = "⚙️", scene = "scenes.settings"},
        {id = "newWish", label = "Nouveau Vœu", icon = "✨", scene = "scenes.newWish"},
        {id = "myWishes", label = "Mes Vœux", icon = "⭐", scene = "scenes.myWishes"},
        {id = "community", label = "Communauté", icon = "👥", scene = "scenes.community"},
        {id = "matching", label = "Match", icon = "🤝", scene = "scenes.matching"},
        {id = "participate", label = "Participer", icon = "🎯", scene = "scenes.participate"},
        {id = "random", label = "Tirage", icon = "🎲", scene = "scenes.random"},
        {id = "profile", label = "Profil", icon = "👤", scene = "scenes.profile"},
        {id = "email", label = "Email", icon = "📧", scene = "scenes.email"},
        {id = "experience", label = "Expérience", icon = "🌍", scene = "scenes.experience"},
        {id = "event", label = "Événement", icon = "🎉", scene = "scenes.event"},
        {id = "support", label = "Soutien", icon = "🤝", scene = "scenes.support"},
        {id = "personal", label = "Personnel", icon = "🎨", scene = "scenes.personal"},
        {id = "other", label = "Autre", icon = "❓", scene = "scenes.other"},
        {id = "description", label = "Description", icon = "📝", scene = "scenes.description"},
        {id = "location", label = "Destination", icon = "📍", scene = "scenes.location"},
        {id = "calendar", label = "Période", icon = "📅", scene = "scenes.calendar"},
        {id = "travel", label = "Voyage", icon = "✈", scene = "scenes.travel"},
        {id = "mentoring", label = "Mentorat", icon = "👨‍🏫", scene = "scenes.mentoring"},
        {id = "resources", label = "Ressources", icon = "📦", scene = "scenes.resources"},
        {id = "funding", label = "Financement", icon = "💰", scene = "scenes.funding"},
        {id = "advice", label = "Conseils", icon = "💬", scene = "scenes.advice"},
        {id = "creative", label = "Créatif", icon = "🎨", scene = "scenes.creative"},
        {id = "professional", label = "Pro", icon = "💼", scene = "scenes.professional"},
        {id = "social", label = "Social", icon = "🤲", scene = "scenes.social"},
        {id = "aiHelp", label = "Aide IA", icon = "🤖", scene = "scenes.aiHelp"},
        {id = "suggestions", label = "Suggestions", icon = "💡", scene = "scenes.suggestions"},
        {id = "templates", label = "Modèles", icon = "📜", scene = "scenes.templates"},
        {id = "share", label = "Partage", icon = "🌐", scene = "scenes.share"},
        {id = "security", label = "Sécurité", icon = "🔒", scene = "scenes.security"},
        {id = "submit", label = "Soumettre", icon = "🚀", scene = "scenes.submit"}
    }
    
    local totalRows = math.ceil(#icons / GRID_COLS)
    local availableHeight = SCREEN_HEIGHT - 40
    local verticalSpacing = (availableHeight - (totalRows * BLOCK_HEIGHT)) / (totalRows + 1) * 0.5
    
    local startY = 20 + verticalSpacing
    
    for i, iconData in ipairs(icons) do
        local col = (i-1) % GRID_COLS
        local row = math.floor((i-1) / GRID_COLS)
        
        local gridWidth = (GRID_COLS * BLOCK_WIDTH) + ((GRID_COLS - 1) * PADDING)
        local x = col * (BLOCK_WIDTH + PADDING) + (SCREEN_WIDTH - gridWidth) / 2 + 30
        
        local y = startY + row * (BLOCK_HEIGHT + verticalSpacing)
        
        local iconBlock = createIconBlock(iconData.icon, iconData.label, iconData.scene, x, y)
        iconGroup:insert(iconBlock)
    end
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
    elseif phase == "did" then
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
    elseif phase == "did" then
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
