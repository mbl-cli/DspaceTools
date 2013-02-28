# if defined?(Sinatra)
#   # This is the configuration to use when running within sinatra
#   project_path = Sinatra::Application.root
#   environment = :development
# else
#   # this is the configuration to use when running within the compass command line tool.
#   css_dir = File.join('static', 'stylesheets')
#   relative_assets = true
#   environment = :production
# end
# 
# This is common configuration
environment = :development
firesass = true
http_path = "/"
css_dir = 'css'
sass_dir = 'css/sass'
images_dir = 'images'
http_images_path = "/images"
http_stylesheets_path = "/css"


