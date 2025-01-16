local widget = require("widget")
local native = require("native")
local database = require("logique.database")
local github = require("logique.github")

local form = {}

function form.createSubmitHandler(formFields, resetForm)
    return function()
        -- Validation des champs
        if not formFields.title or not formFields.title.text or formFields.title.text == "" or
           not formFields.description or not formFields.description.text or formFields.description.text == "" then
            native.showAlert("Erreur", "Veuillez remplir tous les champs obligatoires", {"OK"})
            return
        end
        
        -- Création de l'objet vœu
        local wishData = {
            title = formFields.title.text,
            category = formFields.category and formFields.category.text or "Non catégorisé",
            description = formFields.description.text,
            createdAt = os.date("%Y-%m-%d %H:%M:%S")
        }
        
        -- Sauvegarde locale
        local status, error = database.saveWishToDatabase(wishData)
        if not status then
            native.showAlert("Erreur", "Échec de la sauvegarde locale: " .. tostring(error), {"OK"})
            return
        end
        
        -- Envoi vers GitHub
        github.pushWishToGitHub(wishData)
        
        -- Réinitialiser le formulaire
        if resetForm then
            resetForm()
        end
    end
end

function form.createSubmitButton(options)
    return widget.newButton({
        label = options.label or "Sauvegarder",
        x = options.x or display.contentCenterX,
        y = options.y or display.contentCenterY,
        width = options.width or 200,
        height = options.height or 40,
        shape = "roundedRect",
        cornerRadius = 8,
        fillColor = { 
            default = {0.4, 0.6, 0.8}, 
            over = {0.5, 0.7, 0.9} 
        },
        labelColor = { default={1,1,1}, over={1,1,1} },
        onRelease = options.onRelease
    })
end

return form
