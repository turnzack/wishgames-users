local sqlite3 = require("sqlite3")

local database = {}

-- Ouvrir la base de données locale
local path = system.pathForFile("wishes.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

-- Créer la table si elle n'existe pas encore
local function initDatabase()
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS wishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            createdAt TEXT NOT NULL
        );
    ]]
    
    local status, error = db:exec(createTableQuery)
    if not status then
        print("Erreur lors de la création de la table:", error)
    end
end

-- Sauvegarder un vœu dans la base de données
function database.saveWishToDatabase(wishData)
    local insertQuery = string.format([[
        INSERT INTO wishes (title, category, description, createdAt)
        VALUES ('%s', '%s', '%s', '%s');
    ]], 
    wishData.title:gsub("'", "''"),
    wishData.category:gsub("'", "''"),
    wishData.description:gsub("'", "''"),
    wishData.createdAt)
    
    local status, error = db:exec(insertQuery)
    return status, error
end

-- Récupérer tous les vœux
function database.getAllWishes()
    local wishes = {}
    for row in db:nrows("SELECT * FROM wishes ORDER BY createdAt DESC") do
        table.insert(wishes, row)
    end
    return wishes
end

-- Initialiser la base de données
initDatabase()

return database
