-- login.lua - Scène de connexion/inscription

local composer = require("composer")
local scene = composer.newScene()
local widget = require("widget")
local json = require("json")
local auth = require("scenes.auth")  -- Module d'authentification simplifié

-- File d'attente pour les alertes
local alertQueue = {}
local isAlertShowing = false

local function showNextAlert()
    if #alertQueue > 0 and not isAlertShowing then
        isAlertShowing = true
        local nextAlert = table.remove(alertQueue, 1)
        native.showAlert(nextAlert.title, nextAlert.message, nextAlert.buttons, function()
            isAlertShowing = false
            showNextAlert()
        end)
    end
end

local function queueAlert(title, message, buttons)
    table.insert(alertQueue, {
        title = title,
        message = message,
        buttons = buttons
    })
    showNextAlert()
end

-- Variables locales
local emailField, passwordField, nameField
local isLoginMode = true
local titleText, actionButton, switchButton
local loadingIndicator

-- Alert queue system
local alertQueue = {}
local isShowingAlert = false

local function showNextAlert()
    if #alertQueue > 0 and not isShowingAlert then
        isShowingAlert = true
        local alert = table.remove(alertQueue, 1)
        native.showAlert(alert.title, alert.message, alert.buttons, function()
            isShowingAlert = false
            showNextAlert()
        end)
    end
end

local function queueAlert(title, message, buttons)
    buttons = buttons or {"OK"}
    table.insert(alertQueue, {
        title = title,
        message = message,
        buttons = buttons
    })
    showNextAlert()
end

-- Fonction pour basculer entre connexion/inscription
local function toggleMode()
    isLoginMode = not isLoginMode
    
    if isLoginMode then
        titleText.text = "Connexion"
        actionButton:setLabel("Se connecter")
        switchButton:setLabel("Créer un compte")
        nameField.isVisible = false
    else
        titleText.text = "Inscription"
        actionButton:setLabel("S'inscrire")
        switchButton:setLabel("Déjà un compte ?")
        nameField.isVisible = true
    end
end

-- Fonction de gestion du formulaire
local function handleForm()
    local email = emailField.text
    local password = passwordField.text
    
    -- Vérifier les champs obligatoires
    if email == "" or password == "" then
        queueAlert("Erreur", "Veuillez remplir tous les champs")
        return
    end
    
    -- Validation de l'email
    if not string.match(email, "^[%w%.%-]+@[%w%.%-]+%.[%a]+$") then
        queueAlert("Erreur", "Format d'email invalide")
        return
    end
    
    -- Validation du mot de passe
    if #password < 8 then
        queueAlert("Erreur", "Le mot de passe doit contenir au moins 8 caractères")
        return
    end
    
    if not string.match(password, "%d") then
        queueAlert("Erreur", "Le mot de passe doit contenir au moins un chiffre")
        return
    end
    
    if not string.match(password, "%u") then
        queueAlert("Erreur", "Le mot de passe doit contenir au moins une majuscule")
        return
    end
    
    if not string.match(password, "%l") then
        queueAlert("Erreur", "Le mot de passe doit contenir au moins une minuscule")
        return
    end

    -- Show loading indicator
    loadingIndicator.isVisible = true
    
    if isLoginMode then
        auth.login(email, password, function(success, response)
            loadingIndicator.isVisible = false
            if success then
                -- Rediriger vers home.lua au lieu de intro.lua
                composer.gotoScene("scenes.home", { 
                    time=400, 
                    effect="fade" 
                })
            else
                queueAlert("Erreur", response or "Échec de la connexion")
            end
        end)
    else
        local name = nameField.text
        if name == "" then
            loadingIndicator.isVisible = false
            queueAlert("Erreur", "Veuillez entrer votre nom")
            return
        end
        
                auth.register(name, email, password, function(success, response)
                    loadingIndicator.isVisible = false
                    if success then
                        queueAlert("Succès", "Inscription réussie!", {"OK"}, function()
                            toggleMode() -- Retour à la connexion
                        end)
                    else
                        queueAlert("Erreur", response or "Échec de l'inscription")
                    end
                end)
    end
end

-- Création de la scène
function scene:create(event)
    local sceneGroup = self.view
    
    -- Background
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    background:setFillColor(0.2, 0.4, 0.6)
    
    -- Titre
    titleText = display.newText({
        parent = sceneGroup,
        text = "Connexion",
        x = display.contentCenterX,
        y = 80,
        font = native.systemFontBold,
        fontSize = 40
    })
    
    -- Champ nom (caché par défaut)
    nameField = native.newTextField(display.contentCenterX, 140, 280, 40)
    nameField.placeholder = "Nom"
    nameField.isVisible = false
    sceneGroup:insert(nameField)
    
    -- Champ email
    emailField = native.newTextField(display.contentCenterX, 200, 280, 40)
    emailField.placeholder = "Email"
    sceneGroup:insert(emailField)
    
    -- Champ mot de passe
    passwordField = native.newTextField(display.contentCenterX, 260, 280, 40)
    passwordField.placeholder = "Mot de passe"
    passwordField.isSecure = true
    sceneGroup:insert(passwordField)
    
    -- Bouton d'action (connexion/inscription)
    actionButton = widget.newButton({
        label = "Se connecter",
        x = display.contentCenterX,
        y = 340,
        width = 200,
        onRelease = handleForm
    })
    sceneGroup:insert(actionButton)
    
    -- Bouton de bascule
    switchButton = widget.newButton({
        label = "Créer un compte",
        x = display.contentCenterX,
        y = 400,
        width = 200,
        fillColor = { default={0.4,0.4,0.8}, over={0.5,0.5,1} },
        onRelease = toggleMode
    })
    sceneGroup:insert(switchButton)
    
    -- Loading indicator
    loadingIndicator = display.newText({
        parent = sceneGroup,
        text = "Chargement...",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFont,
        fontSize = 24
    })
    loadingIndicator:setFillColor(1, 1, 1)
    loadingIndicator.isVisible = false
end

-- Fonctions standard de scène
function scene:show(event) end
function scene:hide(event)
    local phase = event.phase
    
    if phase == "will" then
        -- Nettoyer les champs de texte
        if emailField then
            emailField:removeSelf()
            emailField = nil
        end
        if passwordField then
            passwordField:removeSelf()
            passwordField = nil
        end
        if nameField then
            nameField:removeSelf()
            nameField = nil
        end
    end
end
function scene:destroy(event) end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
