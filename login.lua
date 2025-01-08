-- login.lua
local github = require("utils.github")

local function signup(username, email, password)
    local success, message = github.signup(username, email, password)
    print(message)
end

local function login(username, password)
    local success, message = github.authenticate(username, password)
    print(message)
end

-- Exemple d'utilisation
signup("nouvelutilisateur", "nouvelutilisateur@example.com", "password123")
login("nouvelutilisateur", "password123")
