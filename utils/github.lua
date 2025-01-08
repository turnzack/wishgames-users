-- utils/github.lua
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("dkjson") -- Assurez-vous d'avoir une bibliothèque JSON, comme dkjson
local mime = require("mime")   -- Pour encoder en base64
local crypto = require("utils.crypto")

local github = {}
local GITHUB_API_URL = "https://api.github.com"
local REPO_OWNER = "turnzack"
local REPO_NAME = "wishgames-users"
local ACCESS_TOKEN = "your-access-token" -- Remplacez par votre jeton d'accès personnel

-- Fonction pour envoyer une requête PUT à l'API GitHub
local function github_put(path, data)
    local response_body = {}
    local request_body = json.encode(data)
    local headers = {
        ["Authorization"] = "token " .. ACCESS_TOKEN,
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#request_body)
    }

    local _, code = https.request{
        url = GITHUB_API_URL .. path,
        method = "PUT",
        headers = headers,
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    }
    return table.concat(response_body), code
end

-- Fonction pour inscrire un utilisateur
function github.signup(username, email, password)
    -- Hasher le mot de passe
    local hashed_password = crypto.hash_password(password)
    local path = string.format("/repos/%s/%s/contents/users/%s.json", REPO_OWNER, REPO_NAME, username)
    local user_data = json.encode({username = username, email = email, password = hashed_password})
    local content = mime.b64(user_data)
    local data = {
        message = "Add user " .. username,
        content = content,
        committer = {
            name = "Bot",
            email = "bot@example.com"
        }
    }
    local response, code = github_put(path, data)
    if code == 201 then
        return true, "Utilisateur inscrit avec succès!"
    else
        return false, "Échec de l'inscription de l'utilisateur: " .. response
    end
end

-- Fonction pour authentifier un utilisateur
function github.authenticate(username, password)
    local path = string.format("/repos/%s/%s/contents/users/%s.json", REPO_OWNER, REPO_NAME, username)
    local response_body = {}
    local headers = {
        ["Authorization"] = "token " .. ACCESS_TOKEN,
        ["User-Agent"] = "Lua"
    }

    local _, code = https.request{
        url = GITHUB_API_URL .. path,
        method = "GET",
        headers = headers,
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 then
        local response_data = json.decode(table.concat(response_body))
        local user_data = json.decode(mime.unb64(response_data.content))
        -- Vérifier le mot de passe haché
        if user_data and user_data.password == crypto.hash_password(password) then
            return true, "Authentification réussie!"
        else
            return false, "Échec de l'authentification: Mot de passe incorrect."
        end
    else
        return false, "Échec de l'authentification: Utilisateur non trouvé."
    end
end

return github
