\standalone(schema=\import(Schema))

\declare:
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
\end(declare)

\SchemaDef(root = \Site):
  Site = \Record:
    title: \Text
    pages: \Concat(\Intersection(\Page, \TourPage)) {primary}:>
  \end(Record)

  Page = \Record:
    title    : \Text
    main     = \Bool(false)
    permalink: \Text
    content  : \Sequence(\Section, \Split, \Code, \Interactive, \Pager, \Svg, auto=\Para) {primary}:1>
  \end(Record)

  TourPage = \Record:
    title    : \Text
    permalink: \Text
    left     : \Sequence(\Section, \Code, \Interactive, \Pager, \Svg, auto=\Para) {primary}
    right    : \Sequence(\Section, \Code, \Interactive, \Pager, \Svg, auto=\Para)
  \end(Record)

  Section = \Record:
    title  : \Text
    id     : \Optional(\Text)
    content: \Sequence(\Code, \Pager, \Svg, auto=\Para) {primary}:2>
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

  SplitContent = \Sequence(\Section, \Code, \Interactive, \Pager, \Svg, auto=\Para)

  Split = \Record:
    left : \SplitContent {primary}
    right: \SplitContent
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

  Pager = \Record:
    prevLink: \Optional(\Text)
    nextLink: \Optional(\Text)
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
            <script type="module" src="/tour.js"></script>
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
      links: \Optional(\Text) {primary}
    :body:
      <nav>
        <a href="/">nyarna</a>
        <a href="/tour/">Tour</a>
        <a href="/about/">About</a>
        <a href="https://github.com/nyarnalang"><i class="icon-github-circled"></i> GitHub</a>
      </nav>
      <header>
        <h1>\title</h1>
        \if(\links):|\l|
          <ul class="links">\l</ul>
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

    page = \matcher:
    :(\Page):|\p|
      \buildPage(\p::title, \p::permalink, \p::main):
        \header(\p::title)
        <main>
          \map(\p::content, \blocks, collector=\Concat)
        </main>
      \end(buildPage)
    :(\TourPage):|\s|
      \buildPage(Tour: \s::title, \s::permalink, bclass=split, script=true):
        <div class="left">
          \header(Tour: \s::title):
            \for(\doc::root::pages, collector=\Concat):|\p|
              \match(\p):
              :(\Page):
              :(\TourPage):|\tp|
                <li\if(\tp::permalink::eq(\s::permalink), \ class\="current")><a href="/\tp::permalink">\tp::title</a></li>
              \end(match)
            \end(for)
          \end(header)
          <main>
            \map(\s::left, \blocks, collector=\Concat)
          </main>
        </div><div class="right">
          \map(\s::right, \blocks, collector=\Concat)
        </div>
        <input type="checkbox" id="popup-shown">
        <div id="popup">
          <h2 id="popup-title"><span></span></h2>
          <div id="popup-content"></div>
          <label for="popup-shown" id="popup-close">Close</label>
        </div>
      \end(buildPage)
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
    :(\Code):|\c|
      <pre><code>\if(\c::highlight, \highlight(code=\c::content), \c::content)</code></pre>\
    :(\Interactive):|\i|
      <form onsubmit="execNyarna(event); return false;">
        <fieldset class="mods">
          \for(\i::inputs):|\input, \index|
            <input type="radio" id="module-\index" name="module-tabs"\if(\index::eq(1), \ checked)>
            <label for="module-\index">\input::name</label>
          \end(for)
          <div class="module-panels">
            \for(\i::inputs):|\input|
              <textarea name="\input::name">\input::content</textarea>
            \end(for)
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
      </form>
    :(\Pager):|\p|
      <div class="pager">
        \if(\p::prevLink):|\l|
          <a href="\l" class="prev"><i class="icon-angle-left"></i> Previous</a>
        \end(if)
        \if(\p::nextLink):|\l|
          <a href="\l" class="next">Next <i class="icon-angle-right"></i></a>
        \end(if)
      </div>
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