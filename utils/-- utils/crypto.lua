-- utils/crypto.lua
local openssl_digest = require "openssl.digest"
local openssl_hex = require "openssl.hex"

local crypto = {}

-- Fonction pour hasher un mot de passe
function crypto.hash_password(password)
    local digest = openssl_digest.new("sha256")
    digest:update(password)
    return openssl_hex(digest:final())
end

return crypto
