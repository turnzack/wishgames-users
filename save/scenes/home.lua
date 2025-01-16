local composer = require("composer")
local widget = require("widget")
local json = require("json")
local colors = require("logique.theme.colors")  -- Ajout de la palette de couleurs
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
local GRID_COLS = 5  -- Augmentation du nombre de colonnes
local PADDING = 8    -- Augmentation légère de l'espacement
local BLOCK_WIDTH = 55   -- Réduction supplémentaire de la largeur
local BLOCK_HEIGHT = 70  -- Réduction supplémentaire de la hauteur
local SCREEN_WIDTH = display.actualContentWidth
local SCREEN_HEIGHT = display.actualContentHeight

-- Couleurs du thème sombre
local COLORS = {
    background = {0.15, 0.15, 0.2},     -- Fond sombre
    blockBackground = {0.25, 0.25, 0.3}, -- Fond des blocs
    text = {1, 1, 1},                   -- Couleur du texte
    blockBorder = {0.4, 0.4, 0.5}       -- Bordure des blocs
}

-- Couleurs GTA 6 inspirées
local GTA_COLORS = {
    background = {0.85, 0.25, 0.07},  -- Rouge-orangé vif de GTA 6
    highlight = {1, 0.4, 0.1},         -- Ton plus lumineux
    text = {1, 1, 1}                   -- Blanc pour le texte
}

-- Couleurs de dégradé violet clair
local FUNCTION_COLORS = {
    top = {0.8, 0.7, 0.9},     -- Violet clair supérieur
    bottom = {0.7, 0.6, 0.85},  -- Violet clair inférieur légèrement plus foncé
    tapTop = {0.6, 0.5, 0.75},  -- Violet plus foncé pour le tap (haut)
    tapBottom = {0.5, 0.4, 0.7}  -- Violet encore plus foncé pour le tap (bas)
}

-- Mise à jour de la fonction getRandomColor
local function getRandomColor()
    local colors = require("logique.theme.colors")
    local buttonColors = colors.BUTTON.default
    local randomIndex = math.random(#buttonColors)
    return buttonColors[randomIndex]
end

-- Fonction modifiée pour créer un bloc d'icône avec des couleurs aléatoires
local function createIconBlock(icon, label, sceneName, x, y)
    local group = display.newGroup()
    local colors = require("logique.theme.colors")
    
    -- Obtenir deux couleurs aléatoires différentes pour le dégradé
    local color1 = getRandomColor()
    local color2 = getRandomColor()
    while color1 == color2 do
        color2 = getRandomColor()
    end
    
    -- Bloc de fond avec dégradé aléatoire
    local block = display.newRoundedRect(group, 0, 0, BLOCK_WIDTH, BLOCK_HEIGHT, 8)
    
    -- Création du dégradé initial avec les couleurs aléatoires
    local initialGradient = {
        type = "gradient",
        color1 = {color1[1], color1[2], color1[3], 0.7}, 
        color2 = {color2[1], color2[2], color2[3], 0.7},
        direction = "down"
    }
    block:setFillColor(initialGradient)
    
    block.strokeWidth = 1
    block:setStrokeColor(unpack(colors.BORDER))
    
    -- Icône avec nouvelle couleur de texte
    local iconText = display.newText({
        parent = group,
        text = icon,
        x = 0,
        y = -10,
        font = native.systemFont,
        fontSize = 22
    })
    iconText:setFillColor(unpack(colors.TEXT_LIGHT))
    
    -- Label avec nouvelle couleur de texte
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
    
    -- Position du groupe
    group.x = x
    group.y = y
    
    -- Fonction pour l'effet de tap avec nouvelles couleurs
    local function onTap(event)
        local function tapAnimation()
            -- Obtenir de nouvelles couleurs pour l'effet de tap
            local tapColor1 = getRandomColor()
            local tapColor2 = getRandomColor()
            
            local tapGradient = {
                type = "gradient",
                color1 = {tapColor1[1], tapColor1[2], tapColor1[3], 0.9},
                color2 = {tapColor2[1], tapColor2[2], tapColor2[3], 0.9},
                direction = "down"
            }
            
            transition.to(block, {
                time = 100,
                xScale = 1.1,
                yScale = 1.1,
                transition = easing.outQuad,
                onComplete = function()
                    transition.to(block, {
                        time = 100,
                        xScale = 1,
                        yScale = 1,
                        transition = easing.outQuad
                    })
                end
            })
            
            block:setFillColor(tapGradient)
            
            transition.to(block, {
                time = 500,
                onComplete = function()
                    block:setFillColor(initialGradient)
                end
            })
        end
        
        tapAnimation()
        composer.gotoScene(sceneName, {effect="slideLeft", time=300})
        return true
    end
    
    group:addEventListener("tap", onTap)
    
    return group
end

function scene:create(event)
    local sceneGroup = self.view
    
    -- Remplacer la création du fond existant par le même style que l'intro
    local background = display.newRect(
        sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.actualContentWidth,
        display.actualContentHeight
    )
    
    -- Utiliser le même dégradé que l'intro
    local gradient = {
        type = "gradient",
        color1 = {0.9, 0.4, 0.8, 0.3},  -- Violet-rose semi-transparent
        color2 = {0.3, 0.3, 0.8, 0.3}   -- Bleu semi-transparent
    }
    background:setFillColor(gradient)
    
    -- Ajout des mêmes lignes horizontales décoratives que l'intro
    local numLines = 8
    local lineSpacing = display.actualContentHeight / (numLines + 1)
    for i = 1, numLines do
        local line = display.newLine(
            sceneGroup,
            0, i * lineSpacing,
            display.actualContentWidth, i * lineSpacing
        )
        line:setStrokeColor(1, 1, 1, 0.1)  -- Blanc très transparent
        line.strokeWidth = 1
    end

    -- Supprimer les variables de couleurs qui ne sont plus nécessaires
    -- BACKGROUND_COLORS et autres variables de couleur peuvent être supprimées
    
    -- Le reste du code de création de la grille d'icônes
    local iconGroup = display.newGroup()
    sceneGroup:insert(iconGroup)
    
    -- Liste des icônes
    local icons = {
        -- Navigation Principale
        {id = "menu", label = "Menu", icon = "📋", scene = "scenes.menu"},
        {id = "user", label = "Profil", icon = "👤", scene = "scenes.user"},
        {id = "settings", label = "Paramètres", icon = "⚙️", scene = "scenes.settings"},
        
        -- Vœux et Communauté
        {id = "newWish", label = "Nouveau Vœu", icon = "✨", scene = "scenes.newWish"},
        {id = "myWishes", label = "Mes Vœux", icon = "🌟", scene = "scenes.myWishes"},
        {id = "community", label = "Communauté", icon = "👥", scene = "scenes.community"},
        
        -- Interactions
        {id = "matching", label = "Match", icon = "🤝", scene = "scenes.matching"},
        {id = "participate", label = "Participer", icon = "🎯", scene = "scenes.participate"},
        {id = "random", label = "Tirage", icon = "🎲", scene = "scenes.random"},
        
        -- Informations de base
        {id = "profile", label = "Profil", icon = "👤", scene = "scenes.profile"},
        {id = "email", label = "Email", icon = "📧", scene = "scenes.email"},
        
        -- Types de Vœux principaux
        {id = "experience", label = "Expérience", icon = "🌍", scene = "scenes.experience"},
        {id = "event", label = "Événement", icon = "🎉", scene = "scenes.event"},
        {id = "support", label = "Soutien", icon = "🤝", scene = "scenes.support"},
        {id = "personal", label = "Personnel", icon = "🎨", scene = "scenes.personal"},
        {id = "other", label = "Autre", icon = "❓", scene = "scenes.other"},
        
        -- Détails du Vœu
        {id = "description", label = "Description", icon = "📝", scene = "scenes.description"},
        {id = "location", label = "Destination", icon = "📍", scene = "scenes.location"},
        {id = "calendar", label = "Période", icon = "📅", scene = "scenes.calendar"},
        
        -- Expériences
        {id = "travel", label = "Voyage", icon = "✈", scene = "scenes.travel"},
        
        -- Support et Mentorat
        {id = "mentoring", label = "Mentorat", icon = "👨‍🏫", scene = "scenes.mentoring"},
        {id = "resources", label = "Ressources", icon = "📦", scene = "scenes.resources"},
        {id = "funding", label = "Financement", icon = "💰", scene = "scenes.funding"},
        {id = "advice", label = "Conseils", icon = "💬", scene = "scenes.advice"},
        
        -- Projets Personnels
        {id = "creative", label = "Créatif", icon = "🎨", scene = "scenes.creative"},
        {id = "professional", label = "Pro", icon = "💼", scene = "scenes.professional"},
        {id = "social", label = "Social", icon = "🤲", scene = "scenes.social"},
        
        -- Aide IA
        {id = "aiHelp", label = "Aide IA", icon = "🤖", scene = "scenes.aiHelp"},
        {id = "suggestions", label = "Suggestions", icon = "💡", scene = "scenes.suggestions"},
        {id = "templates", label = "Modèles", icon = "📜", scene = "scenes.templates"},
        
        -- Soumission et Sécurité
        {id = "share", label = "Partage", icon = "🌐", scene = "scenes.share"},
        {id = "security", label = "Sécurité", icon = "🔒", scene = "scenes.security"},
        {id = "submit", label = "Soumettre", icon = "🚀", scene = "scenes.submit"}
    }
    
    local totalRows = math.ceil(#icons / GRID_COLS)
    local availableHeight = SCREEN_HEIGHT - 40  -- Laisse une marge en haut et en bas
    local verticalSpacing = (availableHeight - (totalRows * BLOCK_HEIGHT)) / (totalRows + 1) * 0.5  -- Réduction de moitié
    
    local startY = 20 + verticalSpacing  -- Commence après la première zone d'espacement
    
    for i, iconData in ipairs(icons) do
        local col = (i-1) % GRID_COLS
        local row = math.floor((i-1) / GRID_COLS)
        
        local gridWidth = (GRID_COLS * BLOCK_WIDTH) + ((GRID_COLS - 1) * PADDING)
        local x = col * (BLOCK_WIDTH + PADDING) + (SCREEN_WIDTH - gridWidth) / 2 + 30
        
        local y = startY + row * (BLOCK_HEIGHT + verticalSpacing)
        
        local iconBlock = createIconBlock(iconData.icon, iconData.label, iconData.scene, x, y)
        iconGroup:insert(iconBlock)
    end

    -- Dans la fonction où vous créez le bouton qui mène aux vœux (probablement vers la ligne 154)
    local wishButton = widget.newButton({
        -- ...autres propriétés...
        onRelease = function()
            -- Correction: Ajouter le nom complet de la scène
            composer.gotoScene("scenes.myWishes", {effect = "slideLeft", time = 300})
            return true
        end
    })
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Code à exécuter avant que la scène ne soit affichée
    elseif phase == "did" then
        -- Code à exécuter une fois la scène affichée
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Code à exécuter avant que la scène ne soit cachée
    elseif phase == "did" then
        -- Code à exécuter une fois la scène cachée
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    -- Nettoyage des ressources si nécessaire
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene