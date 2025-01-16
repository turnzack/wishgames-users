local composer = require("composer")
local widget = require("widget")
local json = require("json")
local colors = require("logique.theme.colors")

local scene = composer.newScene()

local function createForm(sceneGroup)
    -- Titre (hors du scrollView pour rester fixe)
    local title = display.newText({
        parent = sceneGroup,
        text = "Mes Vœux",
        x = display.contentCenterX,
        y = 30,
        width = 300,
        fontSize = 24,
        font = "Arial-Bold"
    })
    title:setFillColor(1, 1, 1)

    -- Création du scrollView
    local scrollView = widget.newScrollView({
        top = 70,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - 150,
        hideBackground = false,
        backgroundColor = {0.9, 0.9, 0.9},
        horizontalScrollDisabled = true
    })
    sceneGroup:insert(scrollView)
    
    local yPos = 20
    
    -- Section Informations de base
    local baseInfoLabel = display.newText({
        parent = scrollView,
        text = "Informations de base",
        x = display.contentCenterX,
        y = yPos,
        width = 300,
        fontSize = 16,
        font = "Arial"
    })
    baseInfoLabel:setFillColor(0)
    yPos = yPos + 30
    
    -- Champ Nom complet
    local nameField = native.newTextField(display.contentCenterX, yPos + 30, 300, 40)
    nameField.placeholder = "Nom complet"
    nameField:setTextColor(0)
    scrollView:insert(nameField)
    yPos = yPos + 50
    
    -- Champ Email
    local emailField = native.newTextField(display.contentCenterX, yPos + 80, 300, 40)
    emailField.placeholder = "Adresse e-mail"
    emailField:setTextColor(0)
    scrollView:insert(emailField)
    yPos = yPos + 70
    
    -- Section Type de Vœu
    local wishTypeLabel = display.newText({
        parent = scrollView,
        text = "Type de Vœu",
        x = display.contentCenterX,
        y = yPos + 140,
        width = 300,
        fontSize = 16,
        font = "Arial"
    })
    wishTypeLabel:setFillColor(0)
    yPos = yPos + 30
    
    -- Boutons radio pour le type de vœu
    local selectedWishType = nil
    local wishTypes = {
        {label = "Expérience unique", icon = "🌍"},
        {label = "Événement spécial", icon = "🎉"},
        {label = "Aide ou soutien", icon = "🤝"},
        {label = "Personnel du projet", icon = "🎨"},
        {label = "Autre", icon = "❓"}
    }
    
    for i, wishType in ipairs(wishTypes) do
        local option = widget.newButton({
            label = wishType.icon .. " " .. wishType.label,
            x = display.contentCenterX,
            y = yPos + 170 + (i-1)*50,
            width = 300,
            height = 40,
            shape = "roundedRect",
            cornerRadius = 8,
            fontSize = 14,
            fillColor = { default = {0.4, 0.6, 0.8}, over = {0.5, 0.7, 0.9} },
            labelColor = { default = {1, 1, 1}, over = {0.9, 0.9, 0.9} },
            onRelease = function()
                selectedWishType = wishType.label
            end
        })
        scrollView:insert(option)
    end
    
    -- Section Détails du Vœu
    local wishDetailsLabel = display.newText({
        parent = scrollView,
        text = "Détails du Vœu",
        x = display.contentCenterX,
        y = yPos + 420,
        width = 300,
        fontSize = 16,
        font = "Arial"
    })
    wishDetailsLabel:setFillColor(0)
    yPos = yPos + 30

    -- Champ Description
    local descriptionField = native.newTextBox(display.contentCenterX, yPos + 450, 300, 100)
    descriptionField.placeholder = "Décrivez votre vœu ici"
    descriptionField:setTextColor(0)
    scrollView:insert(descriptionField)
    yPos = yPos + 120

    -- Champ Destination
    local destinationField = native.newTextField(display.contentCenterX, yPos + 570, 300, 40)
    destinationField.placeholder = "Destination idéale"
    destinationField.font = native.newFont(native.systemFont, 14)
    scrollView:insert(destinationField)
    yPos = yPos + 50
    
    -- Champ Date
    local dateField = native.newTextField(display.contentCenterX, yPos + 620, 300, 40)
    dateField.placeholder = "Date (JJ/MM/AAAA)"
    dateField:setTextColor(0)
    scrollView:insert(dateField)
    yPos = yPos + 50

    -- Bouton de soumission
    local submitButton = widget.newButton({
        label = "Enregistrer",
        x = display.contentCenterX - 110,
        y = yPos,
        width = 200,
        height = 50,
        shape = "roundedRect",
        cornerRadius = 8,
        fontSize = 16,
        font = "Arial",
        fillColor = { default = {0.4, 0.6, 0.8}, over = {0.5, 0.7, 0.9} },
        labelColor = { default = {1, 1, 1}, over = {0.9, 0.9, 0.9} },
        onRelease = function()
            if not selectedWishType then
                native.showAlert("Erreur", "Veuillez sélectionner un type de vœu", {"OK"})
                return
            end
            
            local wishData = {
                name = nameField.text,
                email = emailField.text,
                description = descriptionField.text,
                type = selectedWishType,
                destination = destinationField.text,
                date = dateField.text,
                createdAt = os.date("%Y-%m-%d %H:%M:%S")
            }
            
            -- Sauvegarde locale dans un fichier JSON
            local path = system.pathForFile("wish.json", system.DocumentsDirectory)
            local file = io.open(path, "w")
            
            if file then
                file:write(json.encode(wishData))
                file:close()
                native.showAlert("Succès", "Vœu enregistré localement", {"OK"})
            else
                native.showAlert("Erreur", "Impossible de sauvegarder localement", {"OK"})
            end
        end
    })
    sceneGroup:insert(submitButton)
    
    -- Bouton de sauvegarde GitHub
    local saveButton = widget.newButton({
        label = "Sauvegarder sur GitHub",
        x = display.contentCenterX + 110,
        y = yPos,
        width = 200,
        height = 50,
        shape = "roundedRect",
        cornerRadius = 8,
        fontSize = 16,
        font = "Arial",
        fillColor = { default = {0.2, 0.8, 0.4}, over = {0.3, 0.9, 0.5} },
        labelColor = { default = {1, 1, 1}, over = {0.9, 0.9, 0.9} },
        onRelease = function()
            local github = require("logique.github")
            local path = system.pathForFile("wish.json", system.DocumentsDirectory)
            local file = io.open(path, "r")
            
            if file then
                local content = file:read("*a")
                file:close()
                
                github.saveToGitHub({
                    filename = "wish_"..os.date("%Y%m%d_%H%M%S")..".json",
                    content = content,
                    onSuccess = function()
                        native.showAlert("Succès", "Vœu sauvegardé sur GitHub", {"OK"})
                    end,
                    onError = function(err)
                        native.showAlert("Erreur", "Échec de la sauvegarde: "..tostring(err), {"OK"})
                    end
                })
            else
                native.showAlert("Erreur", "Aucun vœu à sauvegarder", {"OK"})
            end
        end
    })
    sceneGroup:insert(saveButton)

    -- Titre (hors du scrollView pour rester fixe)
    local title = display.newText({
        parent = sceneGroup,
        text = "Mes Vœux",
        x = display.contentCenterX,
        y = 30,
        width = 300,
        fontSize = 24,
        font = "Arial-Bold"
    })
    title:setFillColor(1, 1, 1)
    
    -- Boutons en bas (hors du scrollView pour rester fixes)
    local buttonGroup = display.newGroup()
    sceneGroup:insert(buttonGroup)
    
    -- Bouton de soumission
    local submitButton = widget.newButton({
        label = "Enregistrer",
        x = display.contentCenterX - 110,
        y = display.contentHeight - 70,
        width = 200,
        height = 50,
        shape = "roundedRect",
        cornerRadius = 8,
        fontSize = 16,
        font = "Arial",
        fillColor = { default = {0.4, 0.6, 0.8}, over = {0.5, 0.7, 0.9} },
        labelColor = { default = {1, 1, 1}, over = {0.9, 0.9, 0.9} },
        onRelease = function()
            if not selectedWishType then
                native.showAlert("Erreur", "Veuillez sélectionner un type de vœu", {"OK"})
                return
            end
            
            local wishData = {
                name = nameField.text,
                email = emailField.text,
                description = descriptionField.text,
                type = selectedWishType,
                destination = destinationField.text,
                date = dateField.text,
                createdAt = os.date("%Y-%m-%d %H:%M:%S")
            }
            
            -- Sauvegarde locale dans un fichier JSON
            local path = system.pathForFile("wish.json", system.DocumentsDirectory)
            local file = io.open(path, "w")
            
            if file then
                file:write(json.encode(wishData))
                file:close()
                native.showAlert("Succès", "Vœu enregistré localement", {"OK"})
            else
                native.showAlert("Erreur", "Impossible de sauvegarder localement", {"OK"})
            end
        end
    })
    buttonGroup:insert(submitButton)
    
    -- Bouton de sauvegarde GitHub
    local saveButton = widget.newButton({
        label = "Sauvegarder sur GitHub",
        x = display.contentCenterX + 110,
        y = display.contentHeight - 70,
        width = 200,
        height = 50,
        shape = "roundedRect",
        cornerRadius = 8,
        fontSize = 16,
        font = "Arial",
        fillColor = { default = {0.2, 0.8, 0.4}, over = {0.3, 0.9, 0.5} },
        labelColor = { default = {1, 1, 1}, over = {0.9, 0.9, 0.9} },
        onRelease = function()
            local github = require("logique.github")
            local path = system.pathForFile("wish.json", system.DocumentsDirectory)
            local file = io.open(path, "r")
            
            if file then
                local content = file:read("*a")
                file:close()
                
                github.saveToGitHub({
                    filename = "wish_"..os.date("%Y%m%d_%H%M%S")..".json",
                    content = content,
                    onSuccess = function()
                        native.showAlert("Succès", "Vœu sauvegardé sur GitHub", {"OK"})
                    end,
                    onError = function(err)
                        native.showAlert("Erreur", "Échec de la sauvegarde: "..tostring(err), {"OK"})
                    end
                })
            else
                native.showAlert("Erreur", "Aucun vœu à sauvegarder", {"OK"})
            end
        end
    })
    buttonGroup:insert(saveButton)
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
    background:setFillColor(0.9, 0.9, 0.9)
    
    createForm(sceneGroup)
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
