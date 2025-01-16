local M = {}

M.config = {
    token = nil, -- Doit être configuré par l'utilisateur
    api_url = "https://api.github.com",
    repo = "voeux",
    owner = nil -- Doit être configuré par l'utilisateur
}

-- Fonction pour configurer les informations GitHub
function M.setConfig(config)
    M.config.token = config.token
    M.config.owner = config.owner
    M.config.repo = config.repo or "voeux"
end

-- Fonction pour sauvegarder un fichier sur GitHub
function M.saveToGitHub(params)
    local json = require("json")
    local network = require("network")
    local base64 = require("logique.utils.base64")
    
    if not M.config.token or not M.config.owner then
        return false, "Configuration GitHub manquante"
    end
    
    local path = "/repos/"..M.config.owner.."/"..M.config.repo.."/contents/"..params.filename
    local url = M.config.api_url..path
    
    local response = {}
    local content = base64.encode(params.content)
    
    local body = json.encode({
        message = "Ajout de "..params.filename,
        content = content
    })
    
    local params = {
        body = body,
        headers = {
            ["Authorization"] = "token "..M.config.token,
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/vnd.github.v3+json"
        }
    }
    
    network.request(url, "PUT", function(event)
        if event.isError then
            if params.onError then
                params.onError(event.response or "Erreur réseau")
            end
            return false, event.response or "Erreur réseau"
        end
        
        local code = event.status
        if code == 200 or code == 201 then
            if params.onSuccess then
                params.onSuccess()
            end
            return true
        else
            local err = json.decode(event.response) or {}
            if params.onError then
                params.onError(err.message or "Erreur inconnue")
            end
            return false, err.message or "Erreur inconnue"
        end
    end, params)
    
    if code == 200 or code == 201 then
        if params.onSuccess then
            params.onSuccess()
        end
        return true
    else
        local err = json.decode(table.concat(response)) or {}
        if params.onError then
            params.onError(err.message or "Erreur inconnue")
        end
        return false, err.message or "Erreur inconnue"
    end
end

-- Ancienne fonction maintenue pour compatibilité
function M.upload_wish(data)
    local json = require("json")
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    
    local path = "/repos/"..M.config.owner.."/"..M.config.repo.."/contents/wish_form.json"
    local url = M.config.api_url..path
    
    local response = {}
    local body = json.encode(data)
    
    local res, code = https.request{
        url = url,
        method = "PUT",
        headers = {
            ["Authorization"] = "token "..M.config.token,
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/vnd.github.v3+json"
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    }
    
    if code == 200 or code == 201 then
        return true, "Vœu soumis avec succès!"
    else
        return false, "Erreur lors de la soumission : "..tostring(code)
    end
end

return M
