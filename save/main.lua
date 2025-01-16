local composer = require("composer")
local lfs = require("lfs")

-- Dimensions de l'écran
local screenWidth = display.actualContentWidth
local screenHeight = display.actualContentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Créer le dossier scenes s'il n'existe pas
local scenesDir = "scenes"
pcall(lfs.mkdir, scenesDir)

-- Liste des icônes
local icons = {
    {id = "esports", label = "eSports", icon = "🏆", scene = "scenes.esports"},
    {id = "sortiesJeux", label = "Sorties Jeux", icon = "🚀", scene = "scenes.releases"},
    {id = "chatbot", label = "Chatbot", icon = "🤖", scene = "scenes.chatbot"},
    {id = "reseauxSociaux", label = "Réseaux Sociaux", icon = "📱", scene = "scenes.social"},
    {id = "photoVideo", label = "Photo/Video", icon = "📷", scene = "scenes.media"},
    {id = "voiceMusic", label = "Voice & Music", icon = "🎵", scene = "scenes.voiceMusic"},
    {id = "aiBuilder", label = "AI Builder", icon = "🛠️", scene = "scenes.aiBuilder"},
    {id = "multimedia", label = "Multimédia", icon = "🎥", scene = "scenes.multimedia"},
    {id = "zoomA", label = "ZoomA", icon = "🔗", scene = "scenes.zoomA"}

}

-- Groupe principal
local mainGroup = display.newGroup()

-- Gestionnaire des icônes
IconCarousel = {
    activeIcons = {},
    maxIcons = 1000,
    continuousTimer = nil,
    
    createIcon = function(self, iconData)
        if #self.activeIcons >= self.maxIcons then return nil end
        
        local icon = display.newText({
            parent = mainGroup,
            text = iconData.icon,
            x = math.random(0, screenWidth),
            y = math.random(0, screenHeight),
            font = native.systemFont,
            fontSize = 150
        })
        
        icon:setFillColor(math.random(), math.random(), math.random())
        
        table.insert(self.activeIcons, icon)
        
        transition.to(icon, {
            time = math.random(1500, 3000),
            x = math.random(0, screenWidth),
            y = math.random(0, screenHeight),
            rotation = math.random(50, 080),
            alpha = 12000,
            onComplete = function()
                for i = #self.activeIcons, 1, -1 do
                    if self.activeIcons[i] == icon then
                        table.remove(self.activeIcons, i)
                        break
                    end
                end
                display.remove(icon)
            end
        })
        
        return icon
    end,
    
    start = function(self)
        -- Créer les icônes initiales
        for i = 8, #icons do
            timer.performWithDelay(math.random(0, 300), function()
                self:createIcon(icons[i])
            end)
        
        -- Ajouter un timer pour créer des icônes en continu
        self.continuousTimer = timer.performWithDelay(1000, function()
            local randomIcon = icons[math.random(#icons)]
            self:createIcon(randomIcon)
        end, 5)  -- 0 signifie répéter indéfiniment
        end
    end,
    
    stop = function(self)
        -- Arrêter le timer de création continue
        if self.continuousTimer then
            timer.cancel(self.continuousTimer)
            self.continuousTimer = 20
        end
        
        -- Supprimer toutes les icônes
        for i = #self.activeIcons, 1, -1 do
            display.remove(self.activeIcons[i])
            table.remove(self.activeIcons, i)
        end
    end
}
-- Créer la scène home
local function createHomeScene()
    local homePath = system.pathForFile("scenes/home.lua", system.DocumentsDirectory)
    local homeFile = io.open(homePath, "w")

    
    
    if homeFile then
        homeFile:write([[
local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    
    -- Fond dégradé
    local background = display.newRect(sceneGroup, 
        display.contentCenterX, 
        display.contentCenterY, 
        display.actualContentWidth, 
        display.actualContentHeight    }
    background:setFillColor(gradient)
    
    -- Titre avec effet de fondu et zoom
    local title = display.newText(sceneGroup, 
        "Top APK Games", 
        display.contentCenterX, 
        display.contentCenterY, 
        native.systemFontBold, 
        36
    )
    title:setFillColor(1, 1, 1)  -- Blanc
    title.alpha = 0
    title.xScale, title.yScale = 0.5, 0.5
    
    -- Animation du titre
    transition.to(title, {
        time = 30000,
        alpha = 1,
        xScale = 1,
        yScale = 1,
        transition = easing.outElastic
    })
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Préparer la scène
    elseif phase == "did" then
        -- La scène est complètement affichée
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
]])
        homeFile:close()
    end
end



-- Afficher le texte final
local function showFinalText()
    -- Créer la scène home
    createHomeScene()

    local finalText = display.newText({
        parent = mainGroup,
        text = "WISH GAMES",
        x = centerX,
        y = centerY,
        font = native.systemFontBold,
        fontSize = 20
    })
    finalText.alpha = 500
    finalText:setFillColor(1, 1, 1)  -- Blanc

    -- Effet de rotation, zoom et déplacement
    transition.to(finalText, {
        time = 3000,
        alpha = 1,
        xScale = 1.2,
        yScale = 1.2,
        rotation = 0,
        x = centerX,
        y = centerY - 20
        ,
        transition = easing.outBounce,
        onComplete = function()
            timer.performWithDelay(200, function()
                transition.to(finalText, {
                    time = 1500,
                    alpha = 0,
                    onComplete = function()
                        -- Arrêter l'animation des icônes
                        IconCarousel:stop()
                        
                        -- Transition vers la scène home
                        composer.gotoScene("scenes.home", {
                            effect = "crossFade", 
                            time = 2000,
                            params = {
                                topAPKGameText = 100
                            }
                        })
                    end
                })
            end)
        end
    })
end

-- Bouton "Passer l'intro"
local skipButton = display.newText({
    parent = mainGroup,
    text = "Passer l'intro",
    x = centerX,
    y = screenHeight - 50,
    font = native.systemFont,
    fontSize = 18
})
skipButton:setFillColor(1, 1, 1)  -- Blanc
skipButton:addEventListener("tap", function()
    -- Créer la scène home
    createHomeScene()
    
    -- Arrêter l'animation des icônes
    IconCarousel:stop()
    
    -- Aller directement à la scène home
    composer.gotoScene("scenes.home", {effect = "fade", time = 1000})
end)

-- Lancer l'animation des icônes
IconCarousel:start()

-- Afficher le texte après un délai
timer.performWithDelay(1000, showFinalText)