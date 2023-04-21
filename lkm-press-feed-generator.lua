local http = require("socket.http")
local html_2fparser = require("htmlparser")
local html_2fentities = require("htmlEntities")
local etlua = require("etlua")
local date = require("date")
local URL = "http://www.kreis-meissen.de"
local PATH = "/Aktuelles/Pressemitteilungen/index.php?ModID=255&object=tx%2C3697.5.1&La=1&NavID=3697.12&text=&kat=3697.1031&monat=&jahr=&kuo=1&max=20"
local DESC = "Inoffizieller RSS Feed der Pressemitteilungen des Landkreis Mei\195\159en."
local GEN = "lkm-press-feed-generator.fnl"
local SRC = "https://codeberg.org/imo/lkm-press-feed-generator"
local VER = "0.1.0"
http["USERAGENT"] = string.format("%s/%s (%s)", GEN, VER, SRC)
local function help()
  io.write(string.format(("%s v%s\n\n" .. "    -h    this message\n" .. "    -l    path to log file (default: \"./lkm-press-feed-generator.log\")\n" .. "    -o    path to log file (default: \"./lkm-press-feed.xml\")\n" .. "    -t    path to template.xml (default: \"./template.xml\")\n"), GEN, VER))
  return os.exit(0)
end
local function cli_args()
  local args = {OUT = "./lkm-press-feed.xml", TEMPLATE_FILE = "./template.xml", LOG_FILE = "./lkm-press-feed-generator.log"}
  for idx, opt in ipairs(arg) do
    local _1_ = opt
    if (_1_ == "-o") then
      args["OUT"] = arg[(idx + 1)]
    elseif (_1_ == "-t") then
      args["TEMPLATE_FILE"] = arg[(idx + 1)]
    elseif (_1_ == "-l") then
      args["LOG_FILE"] = arg[(idx + 1)]
    elseif (_1_ == "-h") then
      help()
    else
    end
  end
  return args
end
local _local_3_ = cli_args()
local OUT = _local_3_["OUT"]
local TEMPLATE_FILE = _local_3_["TEMPLATE_FILE"]
local LOG_FILE = _local_3_["LOG_FILE"]
local function log(lfh, level, msg, _3ffmt)
  _G.assert((nil ~= msg), "Missing argument msg on lkm-press-feed-generator.fnl:55")
  _G.assert((nil ~= level), "Missing argument level on lkm-press-feed-generator.fnl:55")
  _G.assert((nil ~= lfh), "Missing argument lfh on lkm-press-feed-generator.fnl:55")
  local now = date():fmt("%a, %d %b %Y %T")
  local level0 = string.upper(level)
  local msg0 = string.format(msg, _3ffmt)
  return lfh:write(string.format("%s %s - %s\n", now, level0, msg0))
end
local function new_logger(path)
  _G.assert((nil ~= path), "Missing argument path on lkm-press-feed-generator.fnl:64")
  local _4_, _5_ = io.open(path, "a")
  if ((_4_ == nil) and (nil ~= _5_)) then
    local msg = _5_
    return error(msg)
  elseif (nil ~= _4_) then
    local fh = _4_
    local function _6_(...)
      return log(fh, ...)
    end
    return _6_
  else
    return nil
  end
end
local logger = new_logger(LOG_FILE)
local function raw__3erfc822(_3fraw)
  local _8_, _9_ = pcall(date, _3fraw)
  if ((_8_ == true) and (nil ~= _9_)) then
    local date_obj = _9_
    return date_obj:fmt("%a, %d %b %Y %T %z")
  elseif true then
    local _ = _8_
    return _3fraw
  else
    return nil
  end
end
local function get_article_content(_3felem)
  if _3felem then
    local _11_ = _3felem:getcontent()
    if (nil ~= _11_) then
      local _12_ = string.match(_11_, "^[\n%s]*(.+%.%.%.)%s+<span.*$")
      if (nil ~= _12_) then
        return html_2fentities.decode(_12_)
      else
        return _12_
      end
    else
      return _11_
    end
  else
    return nil
  end
end
local function get_articles(tree)
  _G.assert((nil ~= tree), "Missing argument tree on lkm-press-feed-generator.fnl:88")
  local articles = {}
  for _, elem in ipairs(tree:select("ul#liste_1 > li")) do
    local _let_16_ = elem:select("a:not([class])")
    local a_elem = _let_16_[1]
    local _let_17_ = elem:select("p:not([class])")
    local p_elem = _let_17_[1]
    local title = html_2fentities.decode(a_elem.attributes.title)
    local raw_date = (elem:select("time"))[1].attributes.datetime
    logger("info", "Found article %q", title)
    table.insert(articles, {title = title, content = get_article_content(p_elem), link = (URL .. a_elem.attributes.href), date = raw__3erfc822(raw_date)})
  end
  return {title = "Landkreis Mei\195\159en - Pressemitteilungen", description = DESC, url = (URL .. "/Aktuelles/Pressemitteilungen/"), generator = GEN, build_date = raw__3erfc822(false), articles = articles}
end
local function parse_html(raw_html)
  _G.assert((nil ~= raw_html), "Missing argument raw-html on lkm-press-feed-generator.fnl:111")
  local _18_, _19_ = pcall(html_2fparser.parse, raw_html)
  if ((_18_ == true) and (nil ~= _19_)) then
    local parsed = _19_
    return parsed
  elseif ((_18_ == false) and (nil ~= _19_)) then
    local err = _19_
    return logger("error", "Parsing received raw HTML failed: %s", err)
  else
    return nil
  end
end
local function recv_press_website()
  local _21_, _22_ = http.request((URL .. PATH))
  if ((nil ~= _21_) and (_22_ == 200)) then
    local data = _21_
    logger("info", "Successful received press website")
    return data
  elseif true then
    local _ = _21_
    return logger("error", "Failed to receive press website")
  else
    return nil
  end
end
local function save_feed(feed)
  _G.assert((nil ~= feed), "Missing argument feed on lkm-press-feed-generator.fnl:125")
  local fh = io.open(OUT, "w")
  local function close_handlers_10_auto(ok_11_auto, ...)
    fh:close()
    if ok_11_auto then
      return ...
    else
      return error(..., 0)
    end
  end
  local function _25_()
    return fh:write(feed)
  end
  return close_handlers_10_auto(_G.xpcall(_25_, (package.loaded.fennel or debug).traceback))
end
local function load_template()
  local _26_, _27_ = io.open(TEMPLATE_FILE, "r")
  if ((_26_ == nil) and (nil ~= _27_)) then
    local err = _27_
    return error(err)
  elseif (nil ~= _26_) then
    local fh = _26_
    local template_xml = fh:read("a")
    return etlua.compile(template_xml)
  else
    return nil
  end
end
local function generate_feed()
  local feed_generator = load_template()
  local _29_ = recv_press_website()
  if (nil ~= _29_) then
    local _30_ = parse_html(_29_)
    if (nil ~= _30_) then
      local _31_ = get_articles(_30_)
      if (nil ~= _31_) then
        local _32_ = feed_generator(_31_)
        if (nil ~= _32_) then
          return save_feed(_32_)
        else
          return _32_
        end
      else
        return _31_
      end
    else
      return _30_
    end
  else
    return _29_
  end
end
return generate_feed()
