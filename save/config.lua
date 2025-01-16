-- config.lua - Configuration de l'application

application = {
    content = {
        width = 320,
        height = 480, 
        scale = "letterbox",
        fps = 60,
        
        imageSuffix = {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
        },
    },
    
    notification = {
        iphone = {
            types = {
                "badge", "sound", "alert"
            }
        }
    }
}
