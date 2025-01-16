-- auth.lua - Gestion simplifiée de l'authentification

local auth = {}
local json = require("json")
local network = require("network")

-- Configuration de l'API Xano
local API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:SXWvI3xY"

-- Fonction utilitaire pour les requêtes
local function makeRequest(endpoint, method, body, callback)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    print("Envoi de la requête à:", API_URL .. endpoint)
    print("Méthode:", method)
    
    network.request(API_URL .. endpoint, method, function(event)
        print("Statut de la réponse:", event.status)
        print("Réponse brute:", event.response)
        
        if event.isError then
            print("Erreur réseau:", event.errorMessage)
            callback(false, "Erreur de connexion au serveur: " .. event.errorMessage)
            return
        end
        
        local status = tonumber(event.status)
        if status < 200 or status >= 300 then
            print("Erreur HTTP:", status)
            callback(false, "Erreur HTTP " .. tostring(status))
            return
        end
        
        local success, response = pcall(json.decode, event.response)
        if not success then
            print("Erreur de décodage JSON:", response)
            callback(false, "Format de réponse invalide")
            return
        end
        
        -- Vérification spécifique pour Xano API
        if response and response.authToken then
            callback(true, {
                authToken = response.authToken,
                user = response.user or {}
            })
        else
            local errorMsg = response and (response.message or response.error or "Erreur inconnue")
            print("Erreur API:", errorMsg)
            callback(false, errorMsg)
        end
    end, {
        headers = headers,
        body = body
    })
end

-- Connexion utilisateur
function auth.login(email, password, callback)
    print("Tentative de connexion avec email:", email)
    
    local body = json.encode({
        email = email,
        password = password
    })
    
    print("Corps de la requête:", body)
    
    makeRequest("/auth/login", "POST", body, function(success, response)
        print("Réponse de l'API - Succès:", success)
        print("Réponse de l'API - Contenu:", response)
        callback(success, response)
    end)
end

-- Inscription utilisateur
function auth.register(name, email, password, callback)
    local body = json.encode({
        name = name,
        email = email,
        password = password
    })
    makeRequest("/auth/signup", "POST", body, callback)
end

return auth
