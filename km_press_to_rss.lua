#!/usr/bin/env lua
-- Generiert einen RSS feed aus den Pressemitteilungen des Landkreis Meissen.
-- Schade das es keinen direkt auf der Seite gibt...

local http = require('socket.http')
local htmlparser = require('htmlparser')
local etlua = require('etlua')
local date = require('date')

local URL = 'http://www.kreis-meissen.org'
local DESC = 'RSS Feed der Pressemitteilungen Kreis Meißen.'
local GEN = 'km_press_to_rss.lua'

local TEMPLATE_FILE = arg[1] or './template.xml'
local OUT = arg[2] or './km_pressemitteilungen.xml'
local LOG_FILE = arg[3] or './km_press_to_rss.log'

http.USERAGENT = 'km_press_to_rss/0.0.1 (https://codeberg.org/imo/km_press_to_rss / Bitte stellt selbst einen RSS Feed bereit)'


local logfile_fh = assert(io.open(LOG_FILE, 'a'))
local function logger(level, msg, fmt)
    logfile_fh:write(('%s %s - %s\n'):format(os.date(nil, os.time()), level:upper(), msg:format(fmt)))
end

-- generiert vom Datum aus dem Titel einen rfc-822 date time string
local function rfc_822_date_time(raw)
    local ok, date_obj = pcall(date, raw[3], raw[2], raw[1])

    if not ok then return end

    return date_obj:fmt('%a, %d %b %Y %T %z')
end

-- erstellt für jeden Artikel eine table und fügt diese data.articles hinzu
local function get_articles(parsed, data)
    for _, element in ipairs(parsed:select('div.inhaltsbereich-box')) do
        local title = element:select('div.border_o_r > h2')[1]:getcontent()
        local rfc_date = rfc_822_date_time({ title:match('^(%d+)%.(%d+)%.(%d+)%s+.*$') })
        local p_element = element:select('p')[1]

        logger('info', 'Found article %q', title)

        table.insert(data.articles, {
            title = title,
            content = p_element and p_element:getcontent():gsub('&nbsp;', ' '),
            link = URL .. element:select('a')[1].attributes.href,
            date = rfc_date
        })
    end

    return data
end

-- parsed die empfangene Webseite
local function parse_html(raw_html)
    local ok, parsed = pcall(htmlparser.parse, raw_html)

    if not ok then
        logger('error', 'Parsing received raw HTML failed: %s', parsed)
        return
    end

    logger('info', 'Successful parsed raw HTML, now picking needed data out of it')

    local data = {
        title = parsed:select('title')[1]:getcontent(),
        url = URL .. '/61.html',
        description = DESC,
        generator = GEN,
        articles = {}
    }

    return get_articles(parsed, data)
end

-- holt die Pressemitteilungswebseite
local function get_data_from_url()
    local data, code = http.request(URL.. '/61.html')

    if code ~= 200 then
        logger('error', 'Failed to receive website')
        return
    end

    logger( 'info','Successful received press website')
    return parse_html(data)
end

-- lädt das Template in etlua
local function load_template()
    local fh = assert(io.open(TEMPLATE_FILE, 'r'))
    local template_xml = fh:read('a')
    fh:close()

    return etlua.compile(template_xml)
end


local template = load_template()
local data = get_data_from_url()

logfile_fh:close()

if not data then os.exit(1) end

-- schreibt den generierten RSS Feed in eine Datei
local fh = io.open(OUT, 'w')
fh:write(template(data))
fh:close()
