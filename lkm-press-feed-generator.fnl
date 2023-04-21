#!/usr/bin/env fennel

(local http           (require :socket.http))
(local html/parser    (require :htmlparser))
(local html/entities  (require :htmlEntities))
(local etlua          (require :etlua))
(local date           (require :date))

(local URL "http://www.kreis-meissen.de")
(local PATH "/Aktuelles/Pressemitteilungen/index.php?ModID=255&object=tx%2C3697.5.1&La=1&NavID=3697.12&text=&kat=3697.1031&monat=&jahr=&kuo=1&max=20")
(local DESC "Inoffizieller RSS Feed der Pressemitteilungen des Landkreis Meißen.")
(local GEN  "lkm-press-feed-generator.fnl")
(local SRC  "https://codeberg.org/imo/lkm-press-feed-generator")
(local VER  "0.1.0")

(tset http :USERAGENT (string.format "%s/%s (%s)" GEN VER SRC))


;; CLI args

(fn help []
  "Prints help message and exit"
  (io.write
    (string.format
      (..
        "%s v%s\n\n"
        "    -h    this message\n"
        "    -l    path to log file (default: \"./lkm-press-feed-generator.log\")\n"
        "    -o    path to log file (default: \"./lkm-press-feed.xml\")\n"
        "    -t    path to template.xml (default: \"./template.xml\")\n")
        GEN VER))
  (os.exit 0))

(fn cli-args []
  "Parses the given cli arguments and returns a table"
  (let [args {:OUT            "./lkm-press-feed.xml"
              :TEMPLATE_FILE  "./template.xml"
              :LOG_FILE       "./lkm-press-feed-generator.log"}]

      (each [idx opt (ipairs arg)]
        (case opt
          "-o"  (tset args :OUT           (. arg (+ idx 1)))
          "-t"  (tset args :TEMPLATE_FILE (. arg (+ idx 1)))
          "-l"  (tset args :LOG_FILE      (. arg (+ idx 1)))
          "-h"  (help)))
    args))

(local {: OUT
        : TEMPLATE_FILE
        : LOG_FILE}     (cli-args))


;; Logging setup

(lambda log [lfh level msg ?fmt]
  "Writes log message to file"
  (let [now   (: (date) :fmt "%a, %d %b %Y %T")
        level (string.upper level)
        msg   (string.format msg ?fmt)]
    (-> "%s %s - %s\n"
        (string.format now level msg)
        (lfh:write))))

(lambda new-logger [path]
  "Returns logging function"
  (case (io.open path :a)
    (nil msg) (error msg)
    fh        (partial log fh)))

(local logger (new-logger LOG_FILE))


;; Feed generation

(lambda raw->rfc822 [?raw]
  "Returns RFC822 conform datetime string"
  (case (pcall date ?raw)
    (true date-obj) (date-obj:fmt "%a, %d %b %Y %T %z")
    _               ?raw))

(lambda get-article-content [?elem]
  "Removed leading new lines and spaces and trailing html from text"
  (when ?elem
    (-?> (?elem:getcontent)
         (string.match "^[\n%s]*(.+%.%.%.)%s+<span.*$")
         (html/entities.decode))))

(lambda get-articles [tree]
  "Extract articles from parsed HTML and returns the final feed table"
  (let [articles []]
    (each [_ elem (ipairs (tree:select "ul#liste_1 > li"))]

      (let [[a-elem]    (elem:select "a:not([class])")
            [p-elem]    (elem:select "p:not([class])")
            title       (html/entities.decode (. a-elem :attributes :title))
            raw-date    (. (elem:select "time") 1 :attributes :datetime)]
        (logger :info "Found article %q" title)
        (table.insert articles
                      {:title    title
                       :content  (get-article-content p-elem)
                       :link     (.. URL (. a-elem :attributes :href))
                       :date     (raw->rfc822 raw-date)})))

    {:title       "Landkreis Meißen - Pressemitteilungen"
     :description DESC
     :url         (.. URL "/Aktuelles/Pressemitteilungen/")
     :generator   GEN
     :build_date  (raw->rfc822 false)
     :articles    articles}))

(lambda parse-html [raw-html]
  "Parses the raw HTML with htmlparser and returns the tree"
  (case (pcall html/parser.parse raw-html)
    (true parsed) parsed
    (false err)   (logger :error "Parsing received raw HTML failed: %s" err)))

(lambda recv-press-website []
  "Requests press website and returns the raw HTML"
  (case (http.request (.. URL PATH))
    (data 200)  (do
                  (logger :info "Successful received press website")
                  data)
    _           (logger :error "Failed to receive press website")))

(lambda save-feed [feed]
  "Writes the final XML to file"
  (with-open [fh (io.open OUT :w)]
    (fh:write feed)))

(lambda load-template []
  "Loads template file, compiles it with etlua and returns the resulting function"
  (case (io.open TEMPLATE_FILE :r)
    (nil err) (error err)
    fh        (let [template-xml (fh:read :a)]
                (etlua.compile template-xml))))

(lambda generate-feed []
  "Generates the feed from press website"
  (let [feed-generator (load-template)]
    (-?> (recv-press-website)
         (parse-html)
         (get-articles)
         (feed-generator)
         (save-feed))))

(generate-feed)
