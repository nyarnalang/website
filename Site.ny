\standalone(schema=\import(Schema))

\SchemaDef(root = \Site):
  Site = \Record:
    title: \Text
    pages: \Concat(\Intersection(\Page, \TourPage)) {primary}:>
  \end(Record)

  Page = \Record:
    title    : \Text
    main     = \Bool(false)
    permalink: \Text
    content  : \Sequence(\Section, \Split, \Code, \Interactive, \Pager, auto=\Para) {primary}:1>
  \end(Record)

  TourPage = \Record:
    title    : \Text
    permalink: \Text
    left     : \Sequence(\Section, \Code, \Interactive, \Pager, auto=\Para) {primary}
    right    : \Sequence(\Section, \Code, \Interactive, \Pager, auto=\Para)
  \end(Record)

  Section = \Record:
    title  : \Text
    id     : \Optional(\Text)
    content: \Sequence(\Code, \Pager, auto=\Para) {primary}:2>
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

  SplitContent = \Sequence(\Section, \Code, \Interactive, \Pager, auto=\Para)

  Split = \Record:
    left : \SplitContent {primary}
    right: \SplitContent
  \end(Record)

  Code = \Record:
    content: \Text {primary}:<off>
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
        <a href="https://github.com/nyarnalang">GitHub</a>
      </nav>
      <header>
        <h1>\title</h1>
        \if(\links):|\l|
          <div class="links">\l</div>
        \end(if)
      </header>
    \end(func)

    linker = \matcher:
    :(\Page):
    :(\TourPage):|\tp|
      <a href="/\tp::permalink">\tp::title</a>
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
            \map(\doc::root::pages, \linker, collector=\Concat)
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
      <pre><code>\c::content</code></pre>\
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
          <button type="submit">Interpret</button>
        </fieldset>
      </form>
    :(\Pager):|\p|
      <div class="pager">
        \if(\p::prevLink):|\l|
          <a href="\l" class="prev">Previous</a>
        \end(if)
        \if(\p::nextLink):|\l|
          <a href="\l" class="next">Next</a>
        \end(if)
      </div>
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