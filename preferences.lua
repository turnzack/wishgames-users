-- preferences.lua - Gestion du stockage local des données

local M = {}
local json = require("json")

-- Initialisation
local storage = system.pathForFile("preferences.json", system.DocumentsDirectory)
local data = {}

-- Charger les données existantes
local function loadData()
    local file = io.open(storage, "r")
    if file then
        local contents = file:read("*a")
        io.close(file)
        data = json.decode(contents) or {}
    end
end

-- Sauvegarder les données
local function saveData()
    local file = io.open(storage, "w")
    if file then
        file:write(json.encode(data))
        io.close(file)
    end
end

-- Obtenir une valeur
function M.get(key)
    return data[key]
end

-- Définir une valeur
function M.set(key, value)
    data[key] = value
    saveData()
end

-- Supprimer une valeur
function M.remove(key)
    data[key] = nil
    saveData()
end

-- Vider toutes les préférences
function M.clear()
    data = {}
    saveData()
end

-- Charger les données au démarrage
loadData()

return M
