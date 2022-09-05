\standalone(schema=\import(Schema))

\declare:
:private:
  highlight = \highlighter(nyarna):
  :text:|\t|
    \t
  :comment:|\c|
    <span class="comment">\c</span>
  :escape:|\e|
    <span class="escape">\e</span>
  :keyword:|\k|
    <span class="keyword">\k</span>
  :symref:|\s|
    <span class="symref">\s</span>
  :special:|\s|
    <span class="special">\s</span>
  :tag:|\t|
    <span class="tag">\t</span>
  \end(highlighter)

  Links = \Record:
    prev, next: \Optional(\Text)
    content   : \Text {primary}
  \end(Record)
\end(declare)

\SchemaDef(root = \Site):
  Site = \Record:
    title: \Text
    pages: \Concat(\Intersection(\Page, \Paginated)) {primary}:>
  \end(Record)

  Page = \Record:
    title    : \Text
    main     = \Bool(false)
    permalink: \Text
    content  : \Sequence(\Section, \Split, \MaxWidth, \Code, \Interactive, \Svg, auto=\Para) {primary}:1>
  \end(Record)

  TourPage = \Record:
    title    : \Text
    permalink: \Text
    left     : \Sequence(\Section, \Code, \Interactive, \Svg, auto=\Para) {primary}
    right    : \Sequence(\Section, \Code, \Interactive, \Svg, auto=\Para)
  \end(Record)

  Paginated = \Record:
    title  : \Text
    base   : \Text
    content: \Concat(\Intersection(\Page, \TourPage)) {primary}
  \end(Record)

  Section = \Record:
    title  : \Text
    id     : \Optional(\Text)
    content: \Sequence(\Code, \Svg, auto=\Para) {primary}:2>
  \end(Record)

  Para = \Record:
    id     : \Optional(\Text)
    content: \Concat(\StyledText) {primary}
  \end(Record)

  StyledText = \Intersection(\Text, \Emph, \Link, \Inline)

  Emph = \Record:
    content: \Concat(\StyledText) {primary}
  \end(Record)

  Inline = \Record:
    content: \Concat(\StyledText) {primary}
  \end(Record)

  Link = \Record:
    href   : \Text
    content: \Concat(\StyledText) {primary}
  \end(Record)

  SplitContent = \Sequence(\Section, \Code, \Interactive, \Svg, auto=\Para)

  Split = \Record:
    left : \SplitContent {primary}
    right: \SplitContent
  \end(Record)

  MaxWidth = \Record:
    content: \SplitContent {primary}
  \end(Record)

  Code = \Record:
    highlight = \Bool(false)
    content   : \Text {primary}:<off>
  \end(Record)

  Interactive = \Record:
    parameters: \List(\Identifier) {varargs}
    inputs    : \Concat(\Input) {primary}
  \end(Record)

  Input = \Record:
    name   : \Identifier
    content: \Text {primary}:<off>
  \end(Record)

  SvgContent = \Intersection(\Rect, \MultiRect, \Circ, \Arrow)

  Svg = \Record:
    width, height: \Natural
    caption: \Text
    content: \Concat(\SvgContent) {primary}
  \end(Record)

  Rect, MultiRect = \Record:
    x, y: \Integer
    content: \List(\Text) {varargs}
  \end(Record)

  Circ = \Record:
    x, y, r: \Integer
    content: \List(\Text) {varargs}
  \end(Record)

  Arrow = \Record:
    path: \Text {primary}
  \end(Record)
:backends:|\doc|
  html = \backend:
  :funcs:
    buildPage = \func:
      title    : \Text
      permalink: \Text
      main     = \Bool(false)
      bclass   : \Optional(\Text)
      script   = \Bool(false)
      content  : \Text {primary}
    :body:
      \Output(name=\if(\permalink::len()::gt(0), \permalink/index.html, index.html)):
        <!doctype html>
        <html lang=en>
        <head>
          <title>\if(\main,,\doc::root::title | \ )\title</title>
          <meta charset="UTF-8">
          <link rel="stylesheet" href="/style.css">
          <link rel="stylesheet" href="/icons.css">
          \if(\script):
            <script type="module" src="/tour.js" charset="utf-8"></script>
            <script src="/ace/ace.js" type="text/javascript" charset="utf-8"></script>
          \end(if)
        </head>
        <body\if(\bclass):|\c|
          \ class="\c"
        \end(if)>
        \content
        </body>
        </html>
      \end(Output)
    \end(func)

    header = \func:
      title: \Text
      links: \Optional(\Links) {primary}
    :body:
      <nav>
        <a href="/">nyarna</a>
        <a href="/overview/motivation/">Overview</a>
        <a href="/tour/">Tour</a>
        <a href="/about/">About</a>
        <a href="https://github.com/nyarnalang"><i class="icon-github-circled"></i> GitHub</a>
      </nav>
      <header>
        <h1>\title</h1>
        \if(\links):|\l|
          <div class="subheader">
          <div class="sub-left">
          <a href="\if(\l::prev):|\link|
            /\link" class="pagenav"><i class="icon-angle-left"></i></a>
          :else:
            \#" class="pagenav hidden"><i class="icon-angle-left"></i></a>
          \end(if)
          </div>
          <ul class="links">\l::content</ul>
          <div class="sub-right">
          <a href="\if(\l::next):|\link|
            /\link" class="pagenav"><i class="icon-angle-right"></i></a>
          :else:
            \#" class="pagenav hidden"><i class="icon-angle-right"></i></a>
          \end(if)
          </div>
          </div>
        \end(if)
      </header>
    \end(func)

    multilineText = \func:
      x, y: \Integer
      lines: \List(\Text)
    :body:
      \for(\lines, collector=\Concat):|\line, \i|
        <text text-anchor="middle" x="\x"#
          y="\y::add(5, \Integer::sub(\i, 1)::mult(20))::sub(\Integer::mult(\lines::len()::sub(1), 10))"#
          >\line</text>\
      \end(for)
    \end(func)

    render = \matcher:
    :(\Svg):|\svg|
      <figure>
      <svg width="\svg::width" height="\svg::height">
      <defs>
      <marker id="head" orient="auto" markerWidth="3" markerHeight="4" refX="0.1" refY="2">
      <path d="M 0 0 V 4 L 2 2 Z" />
      </marker>
      </defs>
      \map(\svg::content, \render, collector=\Concat)
      </svg>
      <figcaption>\svg::caption</figcaption>
      </figure>
    :(\Rect):|\r|
      <rect x="\r::x" y="\r::y" width="120" height="80" />
      \multilineText(\r::x::add(60), \r::y::add(40), \r::content)
    :(\MultiRect):|\mr|
      <rect x="\mr::x::add(20)" y="\mr::y::sub(20)" width="120" height="80" />
      <rect x="\mr::x::add(10)" y="\mr::y::sub(10)" width="120" height="80" />
      <rect x="\mr::x" y="\mr::y" width="120" height="80" />
      \multilineText(\mr::x::add(60), \mr::y::add(40), \mr::content)
    :(\Circ):|\c|
      <circle cx="\c::x" cy="\c::y" r="\c::r" />
      \multilineText(\c::x, \c::y, \c::content)
    :(\Arrow):|\a|
      <path marker-end="url(\#head)" fill="none" d="\a::path" />\
    \end(matcher)

    ppermalink = \matcher:
    :(\Page):|\p|
      \p::permalink
    :(\TourPage):|\tp|
      \tp::permalink
    \end(matcher)

    ptitle = \matcher:
    :(\Page):|\p|
      \p::title
    :(\TourPage):|\tp|
      \tp::title
    \end(matcher)

    page = \matcher:
    :(\Page):|\p|
      \buildPage(\p::title, \p::permalink, \p::main):
        \header(\p::title)
        <main>
          \map(\p::content, \blocks, collector=\Concat)
        </main>
      \end(buildPage)
    :(\Paginated):|\pagi|
      \for(\pagi::content, collector=\Concat):|\item, \index|
        \var:
          prev: \Optional(\Text) = \if(\index::gt(1), \pagi::base\ppermalink(\pagi::content(\index::sub(1))))
          next: \Optional(\Text) = \if(\index::lt(\pagi::content::len()), \pagi::base\ppermalink(\pagi::content(\index::add(1))))
        \end(var)

        \match(\item):
        :(\Page):|\p|
          \buildPage(\pagi::title\: \p::title, \pagi::base\p::permalink):
            \header(\pagi::title\: \p::title):
              \Links(\prev, \next):
                \for(\pagi::content, collector=\Concat):|\other|
                  <li\if(\ppermalink(\other)::eq(\p::permalink), \ class\="current")><a href="/\pagi::base\ppermalink(\other)">\ptitle(\other)</a></li>
                \end(for)
              \end(Links)
            \end(header)
            <main>
              \map(\p::content, \blocks, collector=\Concat)
            </main>
            <footer class="paginator">
            \if(\prev):|\link|
              <a href="/\link" class="pagenav prev"><i class="icon-angle-left"></i> Previous</a>
            :else:
              <span></span>
            \end(if)
            \if(\next):|\link|
              <a href="/\link" class="pagenav next">Next <i class="icon-angle-right"></i></a>
            :else:
              <span></span>
            \end(if)
            </footer>
          \end(buildPage)
        :(\TourPage):|\s|
          \buildPage(\pagi::title\: \s::title, \pagi::base\s::permalink, bclass=split, script=true):
            <div class="left">
              \header(Tour: \s::title):
                \Links(\prev, \next):
                  \for(\pagi::content, collector=\Concat):|\other|
                    <li\if(\ppermalink(\other)::eq(\s::permalink), \ class\="current")><a href="/\pagi::base\ppermalink(\other)">\ptitle(\other)</a></li>
                  \end(for)
                \end(Links)
              \end(header)
              <main>
                \map(\s::left, \blocks, collector=\Concat)
              </main>
              <footer class="paginator">
              \if(\prev):|\link|
                <a href="/\link" class="pagenav prev"><i class="icon-angle-left"></i> Previous</a>
              :else:
                <span></span>
              \end(if)
              \if(\next):|\link|
                <a href="/\link" class="pagenav next">Next <i class="icon-angle-right"></i></a>
              :else:
                <span></span>
              \end(if)
              </footer>
            </div><div class="right">
              \map(\s::right, \blocks, collector=\Concat)
            </div>
            <input type="checkbox" id="popup-shown">
            <div id="popup">
              <div id="popup-content">
                <h2 id="popup-title"><span></span></h2>
                <div id="popup-main"></div>
                <label for="popup-shown" id="popup-close">Close</label>
              </div>
            </div>
          \end(buildPage)#
          \for(\s::right, collector=\Concat):|\data|
            \for(\inputs(\data), collector=\Concat):|\i|
              \Output(name=\pagi::base\s::permalink/\i::name.ny):
                \i::content
              \end(Output)
            \end(for)
          \end(for)
        \end(match)
      \end(for)
    \end(matcher)

    inputs = \matcher:
    :(\Section):|\s|
    :(\Para):
    :(\Split):
    :(\MaxWidth):
    :(\Code):
    :(\Interactive):|\i|
      \for(\i::inputs):|\input|
        \input
      \end(for)
    :(\Svg):|\svg|
    \end(matcher)

    blocks = \matcher:
    :(\Section):|\s|
      <section#
      \if(\s::id):|\id|
        \ id="\id"
      \end(if)>
      <h2>\s::title</h2>
      \map(\s::content, \blocks, collector=\Concat)
      </section>\
    :(\Para):|\p|
      <p#
      \if(\p::id):|\id|
        \ id="id"
      \end(if)>
      \map(\p::content, \styled, collector=\Concat)
      </p>\
    :(\Split):|\s|
      <div class="split">
      <div class="left">
      \map(\s::left, \blocks, collector=\Concat)
      </div><div class="right">
      \map(\s::right, \blocks, collector=\Concat)
      </div>
      </div>\
    :(\MaxWidth):|\m|
      <div class="max-width">
      \map(\m::content, \blocks, collector=\Concat)
      </div>
    :(\Code):|\c|
      <pre><code>\if(\c::highlight, \highlight(code=\c::content), \c::content)</code></pre>\
    :(\Interactive):|\i|
      <form onsubmit="execNyarna(event); return false;">
        <fieldset class="mods">
          \for(\i::inputs):|\input, \index|
            <input type="radio" id="module-\index" name="module-tabs"\if(\index::eq(1), \ checked) value="\input::name">
            <label for="module-\index">\input::name</label>
          \end(for)
          <div class="module-panels">
            <div id="editor"></div>
          </div>
        </fieldset>
        <fieldset class="interpret">
          \if(\i::parameters::len()::gt(0)): # TODO: check why this is not working without paragraph sep
            <div class="args">
              \for(\i::parameters, collector=\Concat):|\p|
                <div class="arg">
                  <label for="arg-\p">\p</label>
                  <input type="text" name="\p" id="arg-\p" placeholder="enter value">
                </div>
              \end(for)
            </div>
          \end(if)
          <button type="submit"><i class="icon-cog-alt"></i> Interpret</button>
        </fieldset>
        <script>
          window.editor = ace.edit("editor");
          window.inputs = {};
          \for(\i::inputs):|\input, \index|
            fetch("\input::name.ny").then((r) => r.text()).then((text) => {
              window.inputs["\input::name"] = ace.createEditSession(text);
              \if(\index::eq(1)):
                window.editor.setSession(window.inputs["\input::name"]);
              \end(if)
            });
            document.getElementById("module-\index").addEventListener("change", function() {
              window.editor.setSession(window.inputs[this.value]);
            });
          \end(for)
        </script>
      </form>
    :(\Svg):|\svg|
      \render(\svg)
    \end(matcher)

    styled = \matcher:
    :(\Text):|\t|
      \t
    :(\Emph):|\e|
      <em>\map(\e::content, \styled)</em>
    :(\Link):|\l|
      <a href="\l::href">\map(\l::content, \styled)</a>
    :(\Inline):|\i|
      <code>\map(\i::content, \styled)</code>
    \end(matcher)
  :body:
    \map(\doc::root::pages, \page)
  \end(backend)
\end(SchemaDef)