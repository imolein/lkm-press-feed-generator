rockspec_format = "3.0"
package = "lkm-press-feed-generator"
version = "dev-1"
source = {
    url = "git+ssh://git@codeberg.org/imo/lkm-press-feed-generator.git"
}
description = {
    detailed = "Generiert einen RSS feed aus den Pressemitteilungen des Landkreis Meissen",
    homepage = "https://codeberg.org/imo/lkm-press-feed-generator",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1, < 5.5",
    "luasocket",
    "luasec",
    "htmlparser",
    "html-entities",
    "etlua",
    "date"
}
build = {
    type = "builtin",
    install = {
        bin = {
            lkm-press-feed-generator = "lkm-press-feed-generator.lua"
        }
    }
}
