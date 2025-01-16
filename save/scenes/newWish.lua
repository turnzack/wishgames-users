local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local native = require("native")
local base64 = require("logique.utils.base64")
local display = require("display")
local system = require("system")
local timer = require("timer")
local theme = require("config.theme")
-- Remove this line since Runtime is globally available
-- local Runtime = require("runtime")

-- Define local colors table
local COLORS = {
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    PRIMARY = {0.2, 0.4, 0.8},
    SECONDARY = {0.8, 0.2, 0.4}
}

-- Make colors accessible globally if needed
_G.COLORS = COLORS

-- Define unpack function (Lua 5.1 compatibility)
local unpack = table.unpack or function(t, i, j)
    i = i or 1
    j = j or #t
    if i <= j then
        return t[i], unpack(t, i + 1, j)
    end
end

-- Add this function at the beginning after the requires
local function ensureTemporaryDirectory()
    local lfs = require("lfs")
    local tempPath = system.pathForFile("", system.TemporaryDirectory)
    lfs.chdir(tempPath)
    return tempPath
end

-- Define event handlers at the top of the file
local function onKeyEvent(event)
    -- Key event handling
    if event.phase == "down" then
        if event.keyName == "back" or event.keyName == "escape" then
            -- Handle back button
            composer.gotoScene("scenes.home", {effect="slideRight", time=300})
            return true
        end
    end
    return false
end

local function onSystemEvent(event)
    if event.type == "applicationExit" then
        -- Cleanup code here
    end
end

-- Scène Esports avec carrousel horizontal
local scene = composer.newScene()

-- URL de chargement des données de sorties 2025
local RELEASES_2025_DATA_URL = "https://raw.githubusercontent.com/tigerroad1/eventsgames/main/Sorties2025"

-- Configuration de l'interface utilisateur
local UI = {
    colors = COLORS,
    title = {
        text = "News Wish",
        fontSize = 14,
        y = -70
    },
    card = {
        width = display.contentWidth * 0.7,
        height = display.contentHeight * 0.9,  -- Augmenté de 0.8 à 0.9
        spacing = 0
    }
}

-- Fonction de gestion des erreurs
local function handleError(sceneGroup, message, details)
    print("Erreur: " .. tostring(message))
    if details then print("Détails: " .. tostring(details)) end
    
    local errorText = display.newText({
        parent = sceneGroup,
        text = message,
        x = display.contentCenterX,
        y = display.contentCenterY,
        fontSize = 16,
        width = display.contentWidth * 0.8,
        align = "center"
    })
    errorText:setFillColor(unpack(UI.colors.error))
    
    native.showAlert("Erreur", message, {"OK"})
end

-- Remplacer la fonction openWebView (version simplifiée)
local function openWebView(url, title)
    local overlay = display.newGroup()
    
    -- Fond noir semi-transparent avec hauteur réduite pour laisser de l'espace pour l'email
    local background = display.newRect(
        overlay,
        display.contentCenterX,
        display.contentCenterY,
        display.actualContentWidth,
        display.actualContentHeight - 50  -- Réduire la hauteur
    )
    background:setFillColor(0, 0, 0, 1)
    
    -- Ajuster la position et la taille de la webView
    local webViewY = display.contentCenterY
    local webViewHeight = display.actualContentHeight - 200  -- Réduire la hauteur
    local webViewWidth = display.actualContentWidth - 20
    
    local webView = native.newWebView(
        display.contentCenterX,
        webViewY,
        webViewWidth,
        webViewHeight
    )
    webView:request(url)
    
    -- Bouton de retour (ajusté vers le haut)
    local backButton = widget.newButton({
        label = "Games",
        x = 30,
        y = 540,
        shape = "circle",
        radius = 18,
        fillColor = { 
            default = {0.8, 0.4, 0.1},
            over = {1, 0.5, 0.2}
        },
        labelColor = { default={1,1,1}, over={0.8,0.8,0.8} },
        fontSize = 10,
        onRelease = function()
            if webView then
                webView:removeSelf()
                webView = nil
            end
            if overlay then
                overlay:removeSelf()
                overlay = nil
            end
            return true
        end
    })
    
    -- Titre
    local titleText = display.newText({
        parent = overlay,
        text = title,
        x = display.contentCenterX,
        y = 130,
        font = native.systemFontBold,
        fontSize = 18
    })
    
    -- Email toujours visible (au premier plan)
    local emailText = display.newText({
        text = "zoom.ai.ref@gmail.com",
        x = display.contentCenterX,
        y = 540,  -- Même position que dans la scène principale
        font = native.systemFont,
        fontSize = 14
    })
    emailText:setFillColor(1, 1, 1, 0.7)
    
    -- Insérer les éléments dans le bon ordre
    overlay:insert(background)
    overlay:insert(webView)
    overlay:insert(backButton)
    overlay:insert(titleText)
    overlay:insert(emailText)  -- Email au premier plan
    
    return overlay
end

-- Modifier la fonction safeLoadImage pour mieux gérer les cas d'erreur
local function safeLoadImage(parent, game, width, height)
    local group = display.newGroup()
    parent:insert(group)
    
    -- Fond du placeholder toujours visible
    local bg = display.newRect(group, 0, 0, width, height)
    bg:setFillColor(0.2, 0.2, 0.3)
    
    -- Tenter de charger l'image
    if game.logo and type(game.logo) == "string" then
        print("[DEBUG] Tentative de chargement de l'image:", game.logo:sub(1, 50) .. "...")
        
        -- Vérifier si c'est une image base64
        if game.logo:find("^data:image/.+;base64,") then
            -- S'assurer que le dossier temporaire existe
            ensureTemporaryDirectory()
            
            -- Décoder l'image base64
            local imagePath, imageType = base64.decodeImage(game.logo)
            print("[DEBUG] Image décodée:", imagePath, imageType)
            
            if imagePath then
                -- Construire le chemin complet du fichier
                local fullPath = system.pathForFile(imagePath, system.TemporaryDirectory)
                if fullPath then
                    local success, image = pcall(function()
                        return display.newImageRect(group, imagePath, system.TemporaryDirectory, width, height)
                    end)
                    
                    if success and image then
                        image.x = 0
                        image.y = 0
                        bg.isVisible = false
                        print("[DEBUG] Image chargée avec succès")
                        
                        -- Nettoyer le fichier temporaire après un délai
                        timer.performWithDelay(500, function()
                            pcall(function()
                                os.remove(fullPath)
                            end)
                        end)
                        
                        return group
                    else
                        print("[DEBUG] Échec du chargement de l'image:", imagePath)
                    end
                end
            end
        else
            -- Essayer de charger l'URL normale
            local success, image = pcall(function()
                return display.newImageRect(group, game.logo, width, height)
            end)
            
            if success and image then
                image.x = 0
                image.y = 0
                bg.isVisible = false
                return group
            end
        end
    end
    
    -- Si on arrive ici, c'est qu'aucune méthode n'a fonctionné
    -- Afficher l'initiale comme fallback
    local initial = string.sub(game.title or "?", 1, 1)
    local text = display.newText({
        parent = group,
        text = initial,
        x = 0,
        y = 0,
        font = native.systemFontBold,
        fontSize = height * 0.4
    })
    text:setFillColor(1, 1, 1)
    
    -- Ajouter une bordure décorative
    local border = display.newRect(group, 0, 0, width, height)
    border:setFillColor(0, 0, 0, 0)
    border.strokeWidth = 2
    border:setStrokeColor(1, 1, 1, 0.2)
    
    return group
end

-- Fonction de création de carte de jeu (version simplifiée sans image)
local function createGameCard(sceneGroup, game, x, y)
    local cardGroup = display.newGroup()
    
    -- Fond de la carte principale avec hauteur augmentée
    local card = display.newRect(cardGroup, 0, 0, UI.card.width, UI.card.height * 0.8)  -- Augmenté de 0.7 à 0.8
    card:setFillColor({
        type = "gradient",
        color1 = {0.9, 0.4, 0.8, 0.7},
        color2 = {0.3, 0.3, 0.8, 0.7}
    })
    
    -- Zone de contenu avec dimensions ajustées
    local contentContainer = display.newContainer(cardGroup, UI.card.width * 1.0, UI.card.height * 0.7)  -- Augmenté de 0.6 à 0.7
    contentContainer.y = 0
    
    -- 1. Image en haut (plus grande et prenant toute la largeur)
    local imageSize = UI.card.height * 0.4  -- Augmenté de 0.35 à 0.4
    local gameImage = safeLoadImage(
        contentContainer,
        game,
        UI.card.width,  -- Prendre toute la largeur de la carte
        imageSize
    )
    
    if gameImage then
        gameImage.y = -contentContainer.height * 0.3  -- Ajusté pour la nouvelle hauteur
    end
    
    -- 2. Date de sortie au-dessus du nom du jeu
    local releaseDateText = display.newText({
        parent = contentContainer,
        text = "Sortie: " .. (type(game.releaseDate) == "string" and game.releaseDate or "N/A"),
        x = 0,
        y = -contentContainer.height * -0.02,  -- Ajusté pour être sous l'image
        font = native.systemFontBold,
        fontSize = 12,  -- Taille ajustée
        align = "center"
    })
    releaseDateText:setFillColor(0.8, 0.8, 0.8)
    
    -- 3. Titre sous la date de sortie
    local titleText = display.newText({
        parent = contentContainer,
        text = game.title or "Jeu sans nom",
        x = 0,
        y = releaseDateText.y + 20,  -- Positionné sous la date de sortie
        font = native.systemFontBold,
        fontSize = 14
    })
    titleText:setFillColor(1, 1, 1)
    
    -- 4. Description sous le titre avec un espace de 3
    local description = game.description
    if type(description) == "table" then
        description = table.concat(description, " ")
    elseif type(description) ~= "string" then
        description = "Aucune description disponible"
    end
    
    local descText = display.newText({
        parent = contentContainer,
        text = description,
        x = 0,
        y = titleText.y + 45,  -- Positionné sous le titre avec un espace de 3
        width = UI.card.width * 0.90,
        font = native.systemFont,
        fontSize = 12,  -- Taille ajustée
        align = "center"
    })
    descText:setFillColor(0.9, 0.9, 1)
    
    -- 5. Développeur sous la description avec un espace de 2
    local developerText = display.newText({
        parent = contentContainer,
        text = "Développeur: " .. (game.developer or "Inconnu"),
        x = 0,
        y = descText.y + 40,  -- Positionné sous la description avec un espace de 2
        width = UI.card.width * 0.85,
        fontSize = 12,  -- Taille ajustée
        align = "center"
    })
    developerText:setFillColor(0.8, 0.8, 0.8)
    
    -- 6. Plateformes sous le développeur avec un espace de 2
    local platformsText = display.newText({
        parent = contentContainer,
        text = "Plateformes: " .. (type(game.platforms) == "table" and table.concat(game.platforms, ", ") or "N/A"),
        x = 0,
        y = developerText.y + 40,  -- Positionné sous le développeur avec un espace de 2
        width = UI.card.width * 0.85,
        fontSize = 12,  -- Taille ajustée
        align = "center"
    })
    platformsText:setFillColor(0.8, 0.8, 0.8)
    
    -- Position finale et event listeners
    cardGroup.x = x
    cardGroup.y = y
    sceneGroup:insert(cardGroup)
    
    card:addEventListener("tap", function()
        local urlToOpen = game.url or game.developer
        if urlToOpen and type(urlToOpen) == "string" and urlToOpen:match("^https?://") then
            openWebView(urlToOpen, game.title or "Jeu")
        end
        return true
    end)
    
    return cardGroup
end

-- Ajouter cette fonction pour gérer le défilement infini
local function createInfiniteCarousel(scrollView, games)
    local cardWidth = UI.card.width + 10  -- Ajouter un espace de 10 pixels entre les cartes
    local viewableCards = {}
    local screenWidth = display.contentWidth
    local totalWidth = cardWidth * #games
    local numberOfSeries = 7  -- Augmenter le nombre de séries
    
    -- Fonction pour créer une série de cartes
    local function createSeries(startX, seriesIndex)
        local xPos = startX
        for i = 1, #games do
            local card = createGameCard(
                scrollView,
                games[i],
                xPos + UI.card.width / 2,
                scrollView.height / 2
            )
            card.seriesIndex = seriesIndex
            card.gameIndex = i
            scrollView:insert(card)
            table.insert(viewableCards, card)
            xPos = xPos + cardWidth
        end
    end
    
    -- Fonction pour gérer le défilement
    local function onScroll(event)
        local x = scrollView:getContentPosition()
        local totalSeriesWidth = totalWidth * numberOfSeries
        
        -- Gestion du défilement circulaire
        if x < -(totalWidth * (numberOfSeries - 2)) then
            -- Retour au début quand on arrive vers la fin
            scrollView:scrollToPosition({
                x = -totalWidth * 2,
                y = 0,
                time = 0
            })
        elseif x > -totalWidth then
            -- Aller à la fin quand on revient trop au début
            scrollView:scrollToPosition({
                x = -(totalWidth * (numberOfSeries - 3)),
                y = 0,
                time = 0
            })
        end
    end
    
    -- Configurer le scrollView
    scrollView:setScrollWidth(totalWidth * numberOfSeries)
    
    -- Créer les 5 séries de cartes
    for i = 1, numberOfSeries do
        createSeries((i - 1) * totalWidth, i)
    end
    
    -- Position initiale (centrer sur la série du milieu)
    timer.performWithDelay(1, function()
        scrollView:scrollToPosition({
            x = -totalWidth * 2,  -- Centre sur la série du milieu
            y = 0,
            time = 0
        })
    end)
    
    -- Ajouter les listeners
    scrollView:addEventListener("scroll", onScroll)
    Runtime:addEventListener("enterFrame", function()
        for _, card in ipairs(viewableCards) do
            local cardGlobalX = card.x + scrollView:getContentPosition()
            card.isVisible = cardGlobalX > -cardWidth and cardGlobalX < display.contentWidth + cardWidth
        end
    end)
    
    return viewableCards
end

-- Modifier la fonction loadReleases2025Data
local function loadReleases2025Data(sceneGroup)
    local loadingText = display.newText({
        parent = sceneGroup,
        text = "Chargement...",
        x = display.contentCenterX,
        y = display.contentCenterY,
        fontSize = 18
    })

    local params = {
        headers = {
            ["Accept"] = "application/json",
            ["User-Agent"] = "Corona SDK App"
        }
    }
    
    network.request(RELEASES_2025_DATA_URL, "GET", function(event)
        if loadingText then loadingText:removeSelf() end
        
        -- Logs de débogage détaillés
        print("=== Début du traitement de la réponse ===")
        print("Status HTTP:", event.status)
        print("Phase:", event.phase)
        
        -- Vérification initiale de la réponse
        if not event.response or event.response == "" then
            handleError(sceneGroup, "Réponse vide du serveur")
            return
        end

        -- Décodage JSON avec gestion d'erreur
        local success, decodedData = pcall(json.decode, event.response)
        if not success or not decodedData then
            handleError(sceneGroup, "Erreur de décodage JSON")
            return
        end

        -- Vérification de la structure des données
        print("=== Structure des données ===")
        print(json.prettify(decodedData))

        if not decodedData["jeux_2025.json"] or type(decodedData["jeux_2025.json"]) ~= "table" then
            handleError(sceneGroup, "Format de données invalide")
            return
        end

        -- Extraction des jeux
        local games = decodedData["jeux_2025.json"]

        -- Affichage du nombre de jeux
        print("Nombre de jeux trouvés:", #games)
        
        -- Création de l'interface
        local scrollView = widget.newScrollView({
            top = display.contentHeight * 0.15,
            left = 0,
            width = display.contentWidth,
            height = display.contentHeight * 0.7,  -- Augmenté pour accommoder les cartes plus grandes
            horizontalScrollDisabled = false,
            verticalScrollDisabled = true,
            backgroundColor = { 0, 0, 0, 0 },
            hideScrollBar = true,
            friction = 0.92,
            maxVelocity = 8,
            isBounceEnabled = true
        })
        sceneGroup:insert(scrollView)
        
        -- Création du carrousel
        createInfiniteCarousel(scrollView, games)
        
    end, params)
end

-- Fonction pour créer un dégradé de fond
local function createBackground(sceneGroup)
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    local gradient = {
        type = "gradient",
        color1 = {0.9, 0.4, 0.8, 0.3},
        color2 = {0.3, 0.3, 0.8, 0.3}
    }
    background:setFillColor(gradient)
    
    -- Ajout de lignes horizontales décoratives
    local numLines = 18
    local lineSpacing = display.actualContentHeight / (numLines + 1)
    for i = 1, numLines do
        local line = display.newLine(sceneGroup, 
            0, i * lineSpacing,
            display.actualContentWidth, i * lineSpacing)
        line:setStrokeColor(1, 1, 1, 0.1)
        line.strokeWidth = 1
    end
    
    return background
end

-- Fonction de création de la scène
function scene:create(event)
    local sceneGroup = self.view
    
    -- Création du fond (une seule fois)
    createBackground(sceneGroup)
    
    -- Fond de la scène avec dégradé
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
    
    -- Ajout de lignes horizontales décoratives pour le fond
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
    
    -- Titre repositionné en haut de la page
    local title = display.newText({
        parent = sceneGroup,
        text = UI.title.text,
        x = display.contentCenterX,
        y = display.contentHeight * 0.08,  -- Position en haut de l'écran
        fontSize = 14,
        font = native.systemFontBold
    })
    title:setFillColor(1, 1, 1)  -- Blanc pour meilleur contraste
    
    -- Bouton de retour avec le nouveau style
    local backButton = widget.newButton({
        label = "Home",
        x = 30,
        y = 540,
        shape = "circle",
        radius = 15,
        fillColor = { 
            default = {0.8, 0.4, 0.1},
            over = {1, 0.5, 0.2}
        },
        labelColor = { default={1,1,1}, over={0.8,0.8,0.8} },
        fontSize = 10,
        onRelease = function()
            composer.gotoScene("scenes.home", {effect="slideRight", time=300})
        end
    })
    sceneGroup:insert(backButton)
    
    -- Charger les données des jeux
    loadReleases2025Data(sceneGroup)
    
    -- Ajouter le texte email en bas (aligné avec le bouton Home)
    local emailText = display.newText({
        text = "zoom.ai.ref@gmail.com",
        x = display.contentCenterX,
        y = 540,  -- Même hauteur que le bouton Home
        font = native.systemFont,
        fontSize = 14
    })
    emailText:setFillColor(1, 1, 1, 0.7)
    sceneGroup:insert(emailText)

    -- Add event listeners
    Runtime:addEventListener("key", onKeyEvent)
    Runtime:addEventListener("system", onSystemEvent)
end

-- Update Runtime references (around line 414)
local function setupEventListeners()
    Runtime:addEventListener("key", onKeyEvent)
    Runtime:addEventListener("system", onSystemEvent)
end

-- Gestionnaires d'événements de scène
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
end

function scene:hide(event)
    local sceneGroup = self.view
scene:addEventListener("hide", scene)
    local phase = event.phase
end

function scene:destroy(event)
    local sceneGroup = self.view
    -- Plus besoin de supprimer l'event listener autoScroll car il n'existe plus

    -- Remove event listeners
    Runtime:removeEventListener("key", onKeyEvent)
    Runtime:removeEventListener("system", onSystemEvent)
    Runtime:removeEventListener("enterFrame")  -- Updated to use colon
end

-- Écouteurs d'événements de la scène
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene