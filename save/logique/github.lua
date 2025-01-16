local json = require("json")
local network = require("network")
local native = require("native")
local base64 = require("logique.utils.base64")

local github = {}

local GITHUB_TOKEN = "YOUR_PERSONAL_ACCESS_TOKEN"  -- À remplacer par votre token
local REPO_OWNER = "turnzack"
local REPO_NAME = "wishgames-users"
local BRANCH = "main"

function github.pushWishToGitHub(wishData)
    local filename = os.date("%Y%m%d_%H%M%S") .. "_" .. wishData.title:gsub("%s+", "_") .. ".json"
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/mes_voeux/%s",
        REPO_OWNER,
        REPO_NAME,
        filename
    )

    local headers = {
        ["Authorization"] = "token " .. GITHUB_TOKEN,
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/vnd.github.v3+json"
    }
    
    local content = base64.encode(json.encode(wishData))
    local body = json.encode({
        message = "Adding new wish: " .. wishData.title,
        content = content,
        branch = BRANCH
    })

    network.request(url, "PUT", 
        function(event)
            if event.isError then
                print("Erreur réseau:", event.response)
                native.showAlert("Erreur", "Échec de la sauvegarde sur GitHub", {"OK"})
                return
            end

            if event.status >= 200 and event.status < 300 then
                native.showAlert("Succès", "Votre vœu a été enregistré sur GitHub", {"OK"})
            else
                print("Erreur HTTP:", event.status, event.response)
                native.showAlert("Erreur", "Échec de la sauvegarde (HTTP " .. event.status .. ")", {"OK"})
            end
        end,
        {
            headers = headers,
            body = body
        }
    )
end

return github
