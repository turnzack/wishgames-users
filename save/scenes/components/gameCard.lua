local widget = require("widget")
local display = require("display")
local network = require("network")
local system = require("system")    -- Ajout de l'import system
local native = require("native")    -- Ajout de l'import native
local json = require("json")        -- Ajout de l'import json pour le parsing

local GITHUB_CONFIG = {
    workflow_url = "https://raw.githubusercontent.com/tiggy1er/apkgames/refs/heads/main/github/workflows/APIactions.yml"
}

local function fetchGitHubData(callback)
    network.request(
        GITHUB_CONFIG.workflow_url,
        "GET",
        function(event)
            if event.isError then
                print("Network error!")
                return
            end
            
            local workflow = {
                name = "API Actions",
                state = "active",
                content = event.response
            }
            callback({workflows = {workflow}})
        end,
        {
            headers = {
                ["Accept"] = "application/vnd.github.v3.raw"
            }
        }
    )
end

local function createCard(parent, game, y)
    local card = display.newContainer(280, 400)
    card.x = display.contentCenterX
    card.y = y
    
    -- Fond de la carte
    local bg = display.newRect(0, 0, 280, 400)
    bg:setFillColor(1, 1, 1)
    bg.strokeWidth = 2
    bg:setStrokeColor(0.9, 0.9, 0.9)
    card:insert(bg)
    
    -- Image du jeu
    local gameImage = display.newImageRect(game.imageUrl, system.ResourceDirectory, 260, 150)
    gameImage.y = -120
    card:insert(gameImage)
    
    -- Titre
    local title = display.newText({
        text = game.name,
        x = 0,
        y = -20,
        width = 260,
        fontSize = 20,
        font = native.systemFontBold,
        align = "center"
    })
    title:setFillColor(0)
    card:insert(title)
    
    -- Description
    local desc = display.newText({
        text = game.description,
        x = 0,
        y = 50,
        width = 260,
        fontSize = 14,
        font = native.systemFont,
        align = "center"
    })
    desc:setFillColor(0.2)
    card:insert(desc)
    
    -- Date de sortie
    local date = display.newText({
        text = "Sortie: " .. game.releaseDate,
        x = 0,
        y = 120,
        fontSize = 14,
        font = native.systemFontBold
    })
    date:setFillColor(0.4)
    card:insert(date)
    
    -- Fetch GitHub data
    fetchGitHubData(function(data)
        -- Assuming data contains the necessary information
        local workflowInfo = data.workflows[1].name -- Example data extraction

        -- Display GitHub workflow info
        local workflowText = display.newText({
            text = "Workflow: " .. workflowInfo,
            x = 0,
            y = 160,
            fontSize = 14,
            font = native.systemFontBold
        })
        workflowText:setFillColor(0.4)
        card:insert(workflowText)
    end)
    
    parent:insert(card)
    return card
end

return createCard
