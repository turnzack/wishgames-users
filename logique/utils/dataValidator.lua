-- dataValidator.lua
-- Module avancé de validation des données de jeux
-- Version : 1.4.0
-- Date : 2024-12-26

-- Configuration des contraintes de validation
local VALIDATION_CONFIG = {
    title = {
        minLength = 1,
        maxLength = 100
    },
    description = {
        minLength = 10,
        maxLength = 500
    },
    developer = {
        minLength = 1,
        maxLength = 100
    }
}

-- Liste des plateformes valides
local VALID_PLATFORMS = {
    PC = true,
    PlayStation = true,
    ["PlayStation 4"] = true,
    ["PlayStation 5"] = true,
    Xbox = true,
    ["Xbox One"] = true,
    ["Xbox Series"] = true,
    ["Xbox Series X"] = true,
    ["Xbox Series S"] = true,
    ["Xbox Series X|S"] = true,
    Nintendo = true,
    ["Nintendo Switch"] = true,
    Mobile = true,
    Mac = true,
    Linux = true,
    Streaming = true,  -- Ajout explicite de Streaming
    
    -- Alias et variations courantes
    PS = true,
    PS4 = true,
    PS5 = true,
    XBox = true,
    Switch = true,
    
    -- Variations de plateformes émergentes
    ["Cloud Gaming"] = true,
    ["Game Streaming"] = true
}

-- Fonction pour valider une URL
local function isValidURL(url)
    return type(url) == "string" and 
           url:match("^https?://[%w-_%.]+%.[%w]+") ~= nil
end

-- Fonction pour valider une date
local function isValidDate(dateString)
    -- Format YYYY-MM-DD
    local pattern = "^(%d%d%d%d)-(%d%d)-(%d%d)$"
    local year, month, day = dateString:match(pattern)
    
    if not year then return false end
    
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    
    -- Validation des plages
    return year > 1970 and 
           month >= 1 and month <= 12 and 
           day >= 1 and day <= 31
end

-- Fonction de validation détaillée d'un jeu
local function validateGameData(game)
    -- Vérifie que game est une table
    if type(game) ~= "table" then
        print("[VALIDATION] Erreur : Les données du jeu doivent être une table")
        return false, "Type de données invalide"
    end
    
    -- Champs requis avec validation spécifique
    local requiredFields = {
        {
            name = "title", 
            validator = function(v) 
                return type(v) == "string" and 
                       #v >= VALIDATION_CONFIG.title.minLength and 
                       #v <= VALIDATION_CONFIG.title.maxLength
            end,
            errorMsg = "Titre invalide"
        },
        {
            name = "description", 
            validator = function(v) 
                return type(v) == "string" and 
                       #v >= VALIDATION_CONFIG.description.minLength and 
                       #v <= VALIDATION_CONFIG.description.maxLength
            end,
            errorMsg = "Description invalide"
        },
        {
            name = "developer", 
            validator = function(v) 
                return type(v) == "string" and 
                       #v >= VALIDATION_CONFIG.developer.minLength and 
                       #v <= VALIDATION_CONFIG.developer.maxLength
            end,
            errorMsg = "Développeur invalide"
        },
        {
            name = "releaseDate", 
            validator = isValidDate,
            errorMsg = "Date de sortie invalide"
        },
        {
            name = "platforms", 
            validator = function(v) 
                return type(v) == "table" and #v > 0
            end,
            errorMsg = "Plateformes invalides"
        },
        {
            name = "logo", 
            validator = function(v)
                return type(v) == "string" and #v > 0
            end,
            errorMsg = "Logo invalide"
        }
    }
    
    -- Validation de chaque champ
    for _, field in ipairs(requiredFields) do
        local value = game[field.name]
        if value == nil then
            print(string.format("[VALIDATION] Erreur : Champ '%s' manquant", field.name))
            return false, field.errorMsg
        end
        
        if not field.validator(value) then
            print(string.format("[VALIDATION] Erreur : Champ '%s' invalide", field.name))
            return false, field.errorMsg
        end
    end
    
    -- Validation supplémentaire des plateformes
    for _, platform in ipairs(game.platforms) do
        if type(platform) ~= "string" or #platform == 0 or not VALID_PLATFORMS[platform] then
            print("[VALIDATION] Erreur : Plateforme invalide")
            return false, "Plateforme non reconnue : " .. tostring(platform)
        end
    end
    
    return true
end

-- Fonction de validation des données globales
local function validateGamesData(data)
    -- Vérifie que data est une table
    if type(data) ~= "table" then
        print("[VALIDATION] Erreur : Les données doivent être une table")
        return false, "Type de données global invalide"
    end
    
    -- Vérifie que sport.json existe et est un tableau
    local sportData = data["sport.json"]
    if type(sportData) ~= "table" then
        print("[VALIDATION] Erreur : sport.json manquant ou invalide")
        return false, "Données sport.json manquantes"
    end
    
    -- Validation de chaque jeu
    for index, game in ipairs(sportData) do
        local isValid, errorMsg = validateGameData(game)
        if not isValid then
            print(string.format("[VALIDATION] Erreur dans le jeu #%d : %s", index, errorMsg or "Erreur inconnue"))
            return false, string.format("Erreur dans le jeu #%d : %s", index, errorMsg)
        end
    end
    
    return true
end

-- Fonction de test avancée
local function selfTest()
    print("🧪 Tests de validation des données...")
    
    -- Test de données valides
    local validGame = {
        title = "Rocket League",
        description = "Jeu de football avec des voitures",
        developer = "Psyonix",
        releaseDate = "2015-07-07",
        platforms = {"PlayStation 5", "Xbox Series X|S", "PC"},
        logo = "logo.png"
    }
    
    -- Test de données invalides
    local invalidGames = {
        {
            title = "",  -- Titre trop court
            description = "Test",  -- Description trop courte
            developer = "Dev",
            releaseDate = "1950-01-01",  -- Date invalide
            platforms = {},  -- Pas de plateformes
            logo = ""
        },
        {
            title = "Jeu",
            description = "Description valide",
            developer = "Développeur",
            releaseDate = "2020-01-01",
            platforms = {"Commodore64"},  -- Plateforme non reconnue
            logo = "logo.png"
        }
    }
    
    -- Test du jeu valide
    local isValid, errorMsg = validateGameData(validGame)
    assert(isValid, "Test de jeu valide échoué : " .. tostring(errorMsg))
    
    -- Tests des jeux invalides
    for i, invalidGame in ipairs(invalidGames) do
        local isValid, errorMsg = validateGameData(invalidGame)
        assert(not isValid, "Test de jeu invalide #" .. i .. " a échoué")
        print("✅ Test de jeu invalide #" .. i .. " réussi : " .. tostring(errorMsg))
    end
    
    print("✅ Tous les tests de validation ont réussi !")
    return true
end

-- Module exporté
return {
    validateGameData = validateGameData,
    validateGamesData = validateGamesData,
    selfTest = selfTest,
    VALIDATION_CONFIG = VALIDATION_CONFIG,
    VALID_PLATFORMS = VALID_PLATFORMS
}