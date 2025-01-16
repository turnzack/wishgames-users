-- base64.lua
-- Module de décodage Base64 pour Solar2D
-- Version optimisée et sécurisée
-- Date : 2024-12-26

local system = require("system")
local base64 = {
    _VERSION = "1.3.0",
    _DESCRIPTION = "Module de décodage Base64 avancé pour Solar2D",
    _URL = "https://github.com/tigerroad1/solar2d-utils"
}

-- Optimisation des performances
local string_char = string.char
local math_floor = math.floor
local table_concat = table.concat

-- Table de correspondance Base64 optimisée et sécurisée
local BASE64_DECODE_TABLE = {
    A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8, J=9, K=10, L=11, M=12, 
    N=13, O=14, P=15, Q=16, R=17, S=18, T=19, U=20, V=21, W=22, X=23, 
    Y=24, Z=25, a=26, b=27, c=28, d=29, e=30, f=31, g=32, h=33, i=34, 
    j=35, k=36, l=37, m=38, n=39, o=40, p=41, q=42, r=43, s=44, t=45, 
    u=46, v=47, w=48, x=49, y=50, z=51, 
    ['0']=52, ['1']=53, ['2']=54, ['3']=55, ['4']=56, 
    ['5']=57, ['6']=58, ['7']=59, ['8']=60, ['9']=61, 
    ['+']=62, ['/']=63
}

-- Extensions d'image autorisées
local ALLOWED_IMAGE_EXTENSIONS = {
    jpeg = true, jpg = true, 
    png = true, 
    gif = true, 
    bmp = true,
    webp = true
}

-- Fonction de validation des données d'entrée
local function validateBase64Input(data)
    if not data or type(data) ~= "string" then
        print("[Base64] ERREUR: Entrée invalide")
        return nil
    end
    
    -- Nettoyer les espaces et caractères invalides
    data = data:gsub('%s+', ''):gsub('[^A-Za-z0-9+/=]', '')
    
    if #data == 0 then
        print("[Base64] ERREUR: Aucune donnée valide")
        return nil
    end
    
    -- Limite de taille à 2 Mo
    if #data > 2 * 1024 * 1024 then
        print("[Base64] ERREUR: Données trop volumineuses")
        return nil
    end
    
    return data
end

-- Fonction de décodage Base64 améliorée
function base64.decode(data)
    -- Validation initiale
    data = validateBase64Input(data)
    if not data then return nil end
    
    local decoded = {}
    local group, bits = 0, 0
    
    for i = 1, #data do
        local char = data:sub(i,i)
        if char ~= '=' then
            local value = BASE64_DECODE_TABLE[char]
            if not value then
                print("[Base64] ERREUR: Caractère invalide", char)
                return nil
            end
            
            group = (group * 64) + value
            bits = bits + 6
            
            if bits >= 8 then
                bits = bits - 8
                decoded[#decoded+1] = string_char(math_floor(group / (2^bits)))
                group = group % (2^bits)
            end
        end
    end
    
    return table_concat(decoded)
end

-- Fonction de décodage d'image Base64
function base64.decodeImage(imageData)
    if not imageData then 
        print("[Base64] ERREUR: Aucune donnée d'image")
        return nil 
    end
    
    -- Extraction du type MIME et des données
    local mimeType, base64Data = imageData:match("^data:image/(.+);base64,(.+)$")
    
    if not mimeType or not base64Data then
        print("[Base64] ERREUR: Format d'image invalide")
        return nil
    end
    
    -- Vérification du type d'image
    local extension = mimeType:match("^(%w+)")
    if not ALLOWED_IMAGE_EXTENSIONS[extension] then
        print("[Base64] ERREUR: Type d'image non supporté", extension)
        return nil
    end
    
    -- Décodage des données
    local decodedData = base64.decode(base64Data)
    
    if not decodedData then
        print("[Base64] ERREUR: Décodage image échoué")
        return nil
    end
    
    -- Génération de nom de fichier unique
    local filename = string.format("temp_%d_%d.%s", os.time(), math.random(1000, 9999), extension)
    local path = system.pathForFile(filename, system.TemporaryDirectory)
    
    -- S'assurer que le dossier existe
    if not path then
        local lfs = require("lfs")
        local tempPath = system.pathForFile("", system.TemporaryDirectory)
        lfs.chdir(tempPath)
        path = system.pathForFile(filename, system.TemporaryDirectory)
    end
    
    -- Écriture du fichier
    local file = io.open(path, "wb")
    if not file then
        print("[Base64] ERREUR: Impossible de créer le fichier")
        return nil
    end
    
    file:write(decodedData)
    file:close()
    
    return filename, extension
end

-- Fonction de test avancée
function base64.test(input)
    print("🔍 Test de décodage Base64...")
    
    local success, result = pcall(base64.decode, input)
    
    if success and result then
        print("✅ Décodage réussi !")
        print("📏 Longueur:", #result)
        print("🔤 Début:", result:sub(1, 20) .. "...")
        return result
    else
        print("❌ Échec du décodage")
        return nil
    end
end

-- Fonction d'informations de version
function base64.version()
    return base64._VERSION, base64._DESCRIPTION
end

-- Fonction d'auto-test complète
function base64.selfTest()
    print("🧪 Démarrage des tests automatiques...")
    
    -- Test de décodage standard
    local testData = "SGVsbG8gV29ybGQh"  -- "Hello World!" en base64
    local decoded = base64.decode(testData)
    assert(decoded == "Hello World!", "Échec du décodage standard")
    
    -- Test de décodage d'image
    local testImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
    local imagePath, imageType = base64.decodeImage(testImage)
    assert(imagePath ~= nil, "Échec du décodage d'image")
    assert(imageType == "png", "Type d'image incorrect")
    
    print("✅ Tous les tests automatiques ont réussi !")
end

-- Exécution des tests au chargement (optionnel)
base64.selfTest()

return base64