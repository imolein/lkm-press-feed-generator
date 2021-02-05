rockspec_format = "3.0"
package = "km_press_to_rss"
version = "dev-1"
source = {
    url = "git+ssh://git@codeberg.org/imo/km_press_to_rss.git"
}
description = {
    detailed = "Generiert einen RSS feed aus den Pressemitteilungen des Landkreis Meissen",
    homepage = "https://codeberg.org/imo/km_press_to_rss",
    license = "Unlicense"
}
dependencies = {
    "lua >= 5.1, < 5.5",
    "luasocket",
    "htmlparser",
    "etlua",
    "date"
}
build = {
    type = "builtin",
    install = {
        bin = {
            km_press_to_rss = "km_press_to_rss.lua"
        }
    }
}
