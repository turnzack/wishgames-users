local system = require("system")
local lfs = require("lfs")

local imageUtils = {}

-- Vérification de l'existence d'un fichier
function imageUtils.fileExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Création du dossier de cache si nécessaire
function imageUtils.ensureCacheDirectory()
    local path = system.pathForFile("", system.TemporaryDirectory)
    if not imageUtils.fileExists(path) then
        lfs.mkdir(path)
    end
end

-- Nettoyage des fichiers temporaires obsolètes
function imageUtils.cleanupOldFiles(maxAge)
    maxAge = maxAge or 86400 -- 24 heures par défaut
    local path = system.pathForFile("", system.TemporaryDirectory)
    for file in lfs.dir(path) do
        if file:match("^temp_.*%.jpeg$") then
            local filePath = path .. "/" .. file
            local attributes = lfs.attributes(filePath)
            if attributes and os.time() - attributes.modification > maxAge then
                os.remove(filePath)
            end
        end
    end
end

return imageUtils
