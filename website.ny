\standalone(schema=\import(Site))

\Site(nyarna)

\var:
  example = \block:<off>
    #!/usr/bin/env nyarna --
    # with a shebang, this is directly executable.

    # This document can be processed standalone.
    \standalone:
    :params:
      # takes a single argument of type Text
      who: \Text
    \end(standalone)

    # output text, refer to the argument
    Hello, \who!

    # declare your own types and functions
    \declare:
      Bus = \Record:
        fits: \Natural
        name: \Text
      \end(Record)

      Buses = \List(\Bus)

      busFor = \func:
        num: \Natural
      :body:
        \Bus(fits=\num, name=Bus for \num persons)
      \end(func)
    \end(declare)

    # have variables
    \var:
      smallBus = \busFor(10)
      largeBus = \busFor(42)
    \end(var)

    # do loops
    \for(\Buses(\smallBus, \largeBus), collector=\Concat):|\b|
      The \b::name fits \b::fits persons.\
    \end(for)
  \end(block)
\end(var)

\Page(Nyarna: A structured data authoring language, main=true, permalink=):

  \Split:
    \Section(Designed as Evolution of LaTeX)

    Nyarna's syntax and feature set was primarily inspired by \Link(https://www.latex-project.org, LaTeX).
    The initial idea was to have a language viable to be used as frontend for LaTeX – Nyarna isn't quite there yet – while being more user-friendly and flexible.
    Besides LaTeX, Nyarna also takes ideas from \Link(https://www.w3.org/TR/xslt-30/, XSLT), \Link(https://yaml.org, YAML), \Link(https://nim-lang.org, Nim) and \Link(https://ziglang.org, Zig).

    \Section(Structured Input\, Flexible Output)

    Nyarna understands complex structures and provides a static type system for modelling structured data.
    Data input is decoupled from processing.
    You can write processors that generate HTML, PDF or other outputs from the same input data.

    \Section(Extensible Schemas)

    You tell Nyarna about the structure of your data with a \Emph(Schema).
    Schemas are written in Nyarna and can contain \Emph(Backends) that define how the data can be processed.
    Other users can write \Emph(Extensions) that build upon your Schema, inject additional input structures, and extend the backends to accommodate for the additions.
    The ability to inject Extensions makes Nyarna's Schemas modular and flexible.

    \Section(Parameters and Templating)

    A document can define parameters whose values must be given by the caller.
    This makes Nyarna a type-safe templating system.

    \Section(First-Class Types and Embeddability)

    Types are first-class values, as are Schemas.
    The ability to inspect types at runtime potentially allows you to autogenerate code from a schema.
    With this, you could embed Nyarna in your application and deserialize input into native types.

    \Section(Power Tool with Complexity Layers)

    While Nyarna provides a lot of features, it is not necessary to know about them all to use the language.
    Simple use-cases, like text templating, require only minimal syntax.
    Writing content for a given schema still doesn't require the more complex features.
    You will probably not need to know much about the type system before you start writing functions.
    The most complex features are usually only needed for writing Schemas.

    \Section(Available in your Browser)

    Nyarna is nowhere near stable yet, but the implementation is good enough to demonstrate its features.
    Check out \Link(/tour/, the tour) to try it out!
  :right:
    \Code(highlight = true, content = \example)
  \end(Split)
\end(Page)

\Page(About, permalink=about/):
  \Split:
    Nyarna has been developed as research project at the
    \Link(https://www.iste.uni-stuttgart.de, Institute of Software Engineering), University of Stuttgart, Germany.

    The \Link(/tour/, tour) is the current authoritative source for the language syntax and semantics.
    A proper specification has been written during the course of the language's development, but is not up-to-date and would therefore not be of any use.
    The plan is to release it after a proper rewrite.

    The reference implementation, as well as the content of this site, is licensed under the terms of the \Link(https://opensource.org/licenses/MIT, MIT license).

    \Section(Reference Implementation)

    The reference implementation written in Zig is publicly available \Link(https://github.com/nyarnalang/nyarna-zig, here).
    It is in no way stable and may crash on invalid and even valid input.

    The standard library is almost non-existing and a lot of simple functionality is missing.
    There is no proper release yet, partly because development follows Zig's master branch and the implementation's code doesn't build with any released Zig version.
    The interactive interface in the tour is currently the best way to try out the language.
  :right:
  \end(Split)
\end(Page)

\Paginated(Overview, base=overview/):1>

\Page(Motivation, permalink=motivation/):2>
\MaxWidth:
  Nyarna is a \Emph(markup language) and mostly designed towards use-cases similar to those of \Link(https://www.latex-project.org, Latex).
  It \Link(https://journals.plos.org/plosone/article?id\=10.1371/journal.pone.0115069, has been shown) that efficiency of LaTeX users lacks behind that of Microsoft Word users.
  Nyarna attempts to alleviate some of LaTeX' problems, like the steep learning curve and cryptic errors, to allow for more efficient document authoring while still providing access to a features set similar to that of LaTeX.

  There are quite some existing tools that also provide markup for authoring documents.
  The popular ones are unable to provide the feature set of LaTeX for several reason, the most important one usually being the inability to extend the additional functionality within the provided syntax.
  For example, \Link(https://docbook.org, DocBook) provides an XML schema to write documents in – you can use everything defined by this schema, but if something is not covered by that schema, you're out of luck.
  Another feature that is usually missing is the ability to implement and use macros – and if it exists, you typically must implement it via the API of the processor, outside the markup language (as is the case in both \Link(https://asciidoctor.org, Asciidoctor) and \Link(https://docutils.sourceforge.io/rst.html, reStructuredText)).

  Another set of markup languages is available for more rigid data structures:
  \Link(https://www.json.org/, JSON), \Link(https://toml.io/, TOML) and \Link(https://yaml.org, YAML) would be the most popular ones.
  These usually define a tree or graph that contains scalar values, lists, and dictionaries.
  The shortcomings are mostly the same here, with \Link(https://dhall-lang.org, Dhall) being an exception in that it actually provides functions and types.

  In sum, few markup languages exist that provide the full flexibility and extendability of LaTeX.
  Nyarna has been designed to be such a language, while also looking at other existing languages and taking inspiration from them.

  What sets Nyarna's design apart from LaTeX is that it understands structure.
  Commands are not simple macro invocations that procedurally generate the output during processing.
  Instead, they work much more like a typical programming language:
  Commands call functions, construct compound objects or retrieve variable values.
  It has a static type system that can describe typical LaTeX input structures.
  This gives you structural validation that you would need external tools for in languages like XML or JSON.
  And to reach the level of extensibility LaTeX provides, Nyarna offers functionality to extend existing schemas right in the language.
\end(MaxWidth)

\Page(Processing Model, permalink=processing/):2>
\Split:
  With all the LaTeX libraries available at \Link(https://www.ctan.org, CTAN), it would be impossible for Nyarna to cover even a small percentage of functionality available for LaTeX, would it start to build up its own ecosystem.
  Thus, Nyarna's processing model has been designed for leveraging existing technology.
  Nyarna's command line interface specifically caters towards interaction with other tools.

  Nyarna takes one main \Emph(module) (usually a file) as input.
  From this, Nyarna generates a \Emph(document).
  This is the first processing step, which also checks your input against its declared schema, thus validating it.

  The main module you give can refer to other modules, including such modules that could be processed standalone.
  These will then be imported and become part of the input.
  The main module may also define parameters for which arguments can be given, which gives Nyarna capabilities similar to those of a templating processor.

  The second step is to create output from the generated document.
  You can generate any number of named outputs, each of which usually contains plain text again.
  A typical use-case would be to generate one or more \Inline(.tex) files that can then be further processed with LaTeX.
  Nyarna doesn't predefine what kind of files and text formats can be generated, so you can implement a \Emph(backend) for any format you need.
  This way, Nyarna can be used on top of existing technology.

  The separation of those two steps has a couple of implications:
  Firstly, to check your document, you do not need to process it completely, like you would do in LaTeX.
  It suffices to execute the first step.
  This makes checking input faster and has good potential to be used in editor tooling.

  Furthermore, you can select the implementation used for the second step, so that you can, from the same input, generate different outputs.
  For example, you could, from the same input, generate either LaTeX or HTML, using the suitable backend.
  Besides targeting different formats for presenting your document, this can also be used for tooling.
  For example, you could use a backend that reduces your input to plain text without any markup, which you can then pipe into tools that check for spelling and grammar.

  Finally, this design allows you to \Emph(write once)\:
  Even after you have written your input, if you need the contained data in a new format, you have the full flexibility of adding a new backend that transforms the existing input into that format.
  You won't have to rewrite your input manually.
:right:
  \Svg(470, 700, Processing a Nyarna input module):
    \Rect(170, 5, input module)
    \MultiRect(5, 50, arguments)
    \MultiRect(325, 50, imported, modules)
    \Arrow(M 230 85 v 63)
    \Arrow(M 65 130 v 55 h 128)
    \Arrow(M 385 130 v 55 h -118)
    \Circ(230, 185, 30, eval)
    \Arrow(M 230 215 v 38)
    \Rect(170, 260, initial, document)
    \Arrow(M 230 340 v 38)
    \Circ(230, 425, 40, process)
    \Arrow(M 230 465 v 38)
    \MultiRect(170, 530, output, documents)
  \end(Svg)
\end(Split)

\Page(Syntax, permalink=syntax/):2>
\Split:
  Nyarna's syntax is primarily inspired by LaTeX.
  Some may say that this kind of syntax is outdated or clunky, but it actually caters to Nyarna's use cases quite well.
  Alternatives have been evaluated and deemed inept:
  Indentation-based structuring (like Python or YAML) isn't a good fit for a language where data structures can frequently be longer than what's visible on the screen.
  Minimal syntax like \Link(https://asciidoc.org, AsciiDoc) doesn't provide a sensible way of accessing more complex features.

  The syntax, like LaTeX'es, assumes that by default, input is literal data.
  It then provides a small set of special characters that start command structures.
  Similar to LaTeX, you are able to modify this set of characters.

  In LaTeX, each command defines how you are to provide its arguments:
  It may want them positionally (after the command, typically within \Inline({…})), named (like \Inline([&lt;name&gt;\=&lt;value&gt;\, …])), or as block (between \Inline(\\begin{env}…\\end{env})).
  Nyarna unifies these by allowing the usage any mechanism for each argument when calling an entity.
  It also uses parentheses and commas for arguments that are not blocks, which is syntax a typical user might be more familiar with.
:right:
  \Code(highlight=true):
    This is literal data.
    Here's a command: \if(true, spam, egg)

    \if(true,     # give arguments positional,
        then=spam # named,
    ):
      egg         # or as block
    \end(if)

    \if(true):
      spam # You can have multiple blocks
    :else:
      egg  # by separating them with names
    \end(if)
  \end(Code)
\end(Split)

\Split:
  Some LaTeX commands introduce new syntax or change how following content is parsed.
  For example, \Inline(\\begin{verbatim}) would parse all following text as content regardless of command characters, until it sees \Inline(\\end{verbatim}).
  This is defined per command.

  Nyarna provides similar functionality, but again unifies it by allowing the usage of parser-influencing definitions on any block.
  Each block can explicitly define how it modifies the parser, or can implicitly inherit a default that is defined on the parameter the block argument binds to.

  Some LaTeX environments, like for example TikZ, even introduce completely new syntax.
  Nyarna can currently do this in a limited way for predefined functionality, like the syntax for defining variables or types.
  Eventually, it is planned to add functionality to let the user define syntax and use it in blocks.
:right:
  \Code(highlight=true):
    \block:<off #>
      The # character doesn't start a comment in
      this block, since it has been turned off.
    \end(block)
    # after the block, the change is reverted.

    \declare:
      Bold = \Record:
        content: \Text {primary}:<off \>
      \end(Record)
    \end(declare)

    \Bold:
      \ doesn't start commands in here due to
      the default block header that is inherited.
    \end(Bold)
  \end(Code)
\end(Split)

\Split:
  A syntactic feature that doesn't exist in LaTeX is \Emph(swallowing)\:
  Instead of starting a block for a nested level and ending it with \Inline(\\end\(…\)), you can have a call swallow the following content till the end of the surrounding block.
  This block will then be an argument as if it were a primary or named block.
  Swallowing also ends when a following call swallows at the same or a higher level.

  With swallowing, Nyarna allows you to have freestanding heading lines of chapters, sections, subsections etc., while still being able to define that they create nested structure.
  This is useful to avoid deep syntactic nesting and has been inspired by markup languages like Markdown, AsciiDoc or reStructuredText.

  The example code assumes that the given called heading types have been declared somewhere.
:right:
  \Code(highlight=true):
    \Chapter(First Chapter):1> # swallows at a depth of 1

    Some content

    \Section(First Section):2> # contained in chapter

    More content

    # same swallow depth ends previous section
    \Section(Another):2>

    # ends previous section and chapter
    \Chapter(Second Chapter):1>

    # swallowing can be implicit if the target
    # entity is set up appropriately.
    \Section(Implict)

    Content of section Implicit
  \end(Code)
\end(Split)

\Page(Type System, permalink=types/):2>
\Split:
  Nyarna's type system has been designed around the concept that types carry the content's semantics.
  For example, if you want to produce output that renders some part of a text in boldface, you would define a record type \Inline(\\Bold) with a single content field, and use that in your input.

  For a typical document, this implies that input structures are generally literal text, interleaved with record instances.
  To be able to model this in the type system, Nyarna uses a \Link(https://en.wikipedia.org/wiki/Lattice_\(order\), lattice) to define relationships between types.
  For example, the basic type \Inline(\\Text) and a record type \Inline(\\Bold) have the supertype \Inline(\\Intersection\(\\Text\, \\Bold\)).
  Content where you concatenate values of these two types would then have the type \Inline(\\Concat\(\\Intersection\(\\Text\, \\Bold\)\)).

  The type system contains some types specific for describing the structure of documents:
  Besides \Inline(\\Concat) types, which describe concatenations, there are \Inline(\\Sequence) types that describe a list of paragraphs – or more abstractly put, a sequence of separated items.

  Nyarna infers types if possible.
  For example, you do not need to specify which type a function returns, as that can be calculated automatically.
  You do need to specify types of record fields and input parameters.
:right:
  \Code(highlight=true):
    This paragraph contains some literal text
    \Bold(and some bold text).

    \declare:
      # function return types are usually inferred,
      # even for recursive functions.
      writeNTimes = \func:
        text: \Text
        num : \Natural
      :body:
        \if(\num::gt(0), \text\writeNTimes(
          \text, \num::sub(1)))
      \end(func)
    \end(declare)

    \writeNTimes(Spam, 42)
  \end(Code)
\end(Split)

\Split:
  With its somewhat peculiar set of types, Nyarna is able to understand operations on concatenation and paragraph structures:

  Concatenations will always be automatically flattened – you cannot have a concatenation value inside of a concatenation value.
  Also, concatenation of text values is an operation which generates a single text value.
  Thus, a concatenation value will never contain consecutive text values.
  Finally, a concatenation whose elements are all of type \Inline(\\Text), has the inferred type \Inline(\\Text).
  \Inline(\\Concat\(\\Text\)) is not a valid type.

  Similarly, \Inline(\\Sequence) values will also be automatically flattened.
  However, they are able to contain \Inline(\\Concat) values, and don't collapse on \Inline(\\Text).
  There is an implicit conversion defined from \Inline(\\Sequence) to \Inline(\\Concat) types so that you can use empty lines in places that don't expect a sequence.
  Any paragraph that has the type \Inline(\\Void) will be evaluated, but stripped from the resulting sequence value.
  This makes it simple to separate declarations like \Inline(\\declare) from content.

  If you want a data structure that doesn't imply these operations, there's also \Inline(\\List).
:right:
  \Code(highlight=true):
    The following call \f(x) is part of a
    concatentation and surrounded by text.

    \block:
      This call to 'block' has two paragraphs,
      its inferred type will be Sequence(Text).

      The call simply returns this content,
      the paragraphs will be flattened.
    \end(block)
  \end(Code)
\end(Split)

\Split:
  To process the input, Nyarna needs a way to separate differently typed values.
  For this, there's \Inline(\\match) and \Inline(\\matcher), where the former is a control structure while the latter defines a function.
  They infer their return type by calculating the intersection of the type of each branch.
  \Inline(\\matcher) also infers the type of its single parameter from the set of given types.

  These structures are the core of backend processing:
  You can walk over an input concatenation, and take action based on which type each item has.
  Eventually you'll generate a \Inline(\\Text) value which can then be the output.

  By separating type-based dispatching from actual types, you are able to implement multiple independent backends to generate different output from your input.

  This way of processing content has been primarily inspired by \Link(https://developer.mozilla.org/en-US/docs/Web/XSLT, XSLT).
  However, unlike XSLT's path-based selection, Nyarna's type-based approach guarantees type safety.
:right:
  \Code(highlight=true):
    \declare:
      Bold = \Record:
        content: \Concat(\Content) {primary}
      \end(Record)
      Italic = \Record:
        content: \Concat(\Content) {primary}
      \end(Record)
      Content = \Intersection(\Bold, \Italic, \Text)
      procContent = \matcher:
      :(\Text):|\t|
        \t
      :(\Bold):|\b|
        &lt;b&gt;\map(\b::content, \procContent)&lt;/b&gt;
      :(\Italic):|\i|
        &lt;i&gt;\map(\i::content, \procContent)&lt;/i&gt;
      \end(matcher)
    \end(declare)

    \map(func=\procContent):
      As we see \Italic(above), matchers
      \Bold(can be \Italic(used)) recursively
      to process typical structures.
    \end(map)
  \end(Code)
\end(Split)

\Page(Schemas and Extensions, permalink=schemas/):2>

\Split:
  To define the structure the main input ought to have, Nyarna uses a schema.
  Schemas define the root type of the documents they are used for, and additionally may define backends with which those documents can be processed.

  To create a schema, you first create a \Inline(\\SchemaDef).
  This can contain definitions of types, functions, and backends, but doesn't make the symbols visible.
  A \Inline(\\SchemaDef) can be implicitly or explicitly instantiated, which will yield a \Inline(\\Schema).
  The instantiation will establish all symbols defined in the schema.
  A \Inline(\\SchemaDef) remembers its instance, and will always return that instance on subsequent instantiations.

  You can define schemas in their own standalone modules, by using the predefined schema named \Emph(Schema).
  This is best practice, as it allows the Nyarna processor to provide an internal backend in the predefined schema that simply validates your schema – semantic errors would otherwise only be visible when the first instantiation happens.
  Other backends could be provided for the predefined schema, e.g. for autogenerating code that loads Nyarna input into native types.

  If your schema defines backends, you declare a variable with which you can access the currently processed document.
  A backend can define variables, functions, and a body which gets evaluated when the backend is used.
  The body is to emit a concatenation of \Inline(\\Output), each of which creates a document.

  Backends do not need to follow a certain style, but it is best practice to implement them via matchers.
  This enables us later to extend the schema.
:right:
  \Code(highlight=true):
    \standalone(schema=\import(Schema))

    \SchemaDef(root=\Concat(\Animal)):
      Cat = \Record:
        name : \Text
        lives: \Natural
      \end(Record)

      Dog = \Record:
        name : \Text
        breed: \Text
      \end(Record)

      Animal = \Intersection(\Cat, \Dog)
    :backends:|\doc|
      info = \backend:
      :funcs:
        writeInfo = \matcher:
        :(\Cat):|\c|
          The cat \c::name has \c::lives lives.\
        :(\Dog):|\d|
          The dog \d::name is of the breed \d::breed.\
        \end(matcher)
      :body:
        \Output(name=info.txt):
          \map(\doc::root, \writeInfo)
        \end(Output)
      \end(backend)
    \end(SchemaDef)
  \end(Code)
\end(Split)

\Split:
  Extending a schema works by creating a \Inline(\\SchemaExt) and later using it as additional input when instantiating the \Inline(\\SchemaDef).
  A \Inline(\\SchemaExt) can define additional types and backends, but can also extend certain entities.
  Currently, this works for intersections, backends, and matchers.

  By extending an intersection, an extension can allow additional content in the document.
  By extending a matcher, an extension can make it process values of types that could perviously not be processed.
  By extending a backend, an extension can extend the matchers defined within the backend, thus allowing an extended intersection to be properly processed by a backend.

  A backend must be set up appropriately for it to be extended.
  This is why it's best practice to implement backends with matchers.
  If an extension extends an intersection, but does not extend a backend that processes values of this intersection, the backend is rendered unusable.

  A \Inline(\\SchemaDef) remembers the extensions it has been instantiated with.
  A subsequent instantiation allows fewer extensions to be given, but any extension given that has not been seen in the initial instantiation will result in an error.
  Extensions are designed so that any document that is valid for a schema is also valid for any schema that is the base schema with some extensions.
  With these rules, you can use a schema in a module, and import that module somewhere else where you use a richer version of the schema.

  This concludes the overview.
  You may take the \Link(/tour, tour) for a more detailled discussion of language features and to experiment with the language.
:right:
  \Code(highlight=true):
    \fragment(\SchemaExt)

    \SchemaExt:
      Rat = \Record:
        name  : \Text
        sniffs: \Natural
      \end(Record)

      Animals |= \Intersection(\Rat)
    :backends:|\doc|
      info = \backend:
      :funcs:
        writeInfo |= \matcher:
        :(\Rat):|\r|
          The rat \r::name has sniffed \r::sniffs times.
        \end(matcher)
      \end(backend)
    \end(SchemaExt)
  \end(Code)
\end(Split)

\Paginated(Tour, base=tour/):1>

\TourPage(Introduction, permalink=):
  This tour introduces you to Nyarna's language features.
  On your right you'll find the example code for each step.
  You can edit and interpret the code in your browser.
  This page shows the example code from the main page.

  The interpreter uses Nyarna's reference implementation, compiled to WASM.
  While it can process all shown examples properly, edits may cause it to crash due to its alpha-state.
  You can open your browser's JavaScript console to see error logs for such cases.

  The discussion of some features will require multiple inputs.
  These will then be shown as tabs.
  The leftmost tab is the main input on which Nyarna is called.

  Nyarna inputs may define parameters whose arguments are to be supplied by the caller.
  You will find input fields for such arguments if applicable, like \Inline(who) for the current example.
  While the Nyarna input can freely define its parameters, the interface used for the tour will give you a hardcoded list of parameters matching those defined in the given code.
  Editing the input to have different parameters will thus not work properly.

  If you want to try out Nyarna's command line interface, you can put the input shown here into files in some directory.
  The files are to carry the name shown here with the \Inline(.ny) suffix.
  Assuming you installed Nyarna on your system, you can then interpret the input via

  \Code(highlight = false):
    nyarna &lt;main-input&gt;.ny [--&lt;param-name&gt; &lt;arg&gt;]...
  \end(Code)

  Since there currently is no proper language specification, the tour will contain \Emph(Details) sections with more extensive information on the currently discussed features.
  You may skip these if you just want to have a quick impression on the language.
:right:
  \Interactive(who):
    \Input(input, \example)
  \end(Interactive)
\end(TourPage)

\TourPage(Basics, permalink=basics/):
  By default, input characters are processed as content.
  The “\Inline(\#)” character starts a \Emph(comment), with all following characters up to and including the following line ending being part of the comment.
  If the last non-whitespace character of a comment is another “\Inline(\#)” (i.e. not the initial one), the line ending is excluded from the comment.

  A \Emph(command character) introduces non-content structures.
  By default, the only command character is the backslash “\Inline(\\)”.
  You can escape non-alphanumeric characters with a command character.

  Empty lines separate \Emph(paragraphs).
  If a paragraph does not produce any output, it will be removed after evaluation.
  You can use paragraphs to cleanly separate code like declarations or assignments from code that produces output.

  \Section(Details)

  Nyarna works on Unicode input.
  The reference implementation currently only accepts UTF-8 encoded input.

  The \Emph(space) \Inline(U+0020) and \Emph(tabular) \Inline(U+0009) character are \Emph(inline whitespace).
  The \Emph(carriage return) \Inline(U+000D), \Emph(line feed) \Inline(U+000A), or both in sequence, are a \Emph(line ending).
  A line ending is always processed as if it was a single line feed.

  Inline whitespace in front of a comment or a line ending is always ignored.
  This allows you to write end-of-line comments without adding whitespace content to your input, and prevents fully invisible characters to influence your output.

  Lines that contain nothing but whitespace are considered \Emph(empty).
  If one or more empty lines occur between non-empty lines on the same syntactical level, they are a \Emph(paragraph separator) and include the line ending from the preceding non-empty line.
:right:
  \Interactive:
    \Input(input):
      This starts the first paragraph of the file.
      It contains two lines separated by a line feed.

      Let's escape \\ and \# so that they're content.

      This line has no line feed. # because of this comment
      Look what happens in the output!

      You can keep the line feed. # like this #
      The second \# doesn't end the comment.
      # you can have multiple # in a comment.
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Commands, permalink=commands/):
  \Emph(Commands) start with a \Emph(symbol reference), which is a \Emph(command character) followed by a \Emph(symbol name).

  A symbol reference can stand alone, which makes it a \Emph(value retrieval).
  This can be the value of a variable, but also a defined type or function.

  You can access fields or other nested entities via “\Inline(\:\:)”, followed by an identifier.
  Besides fields, this also gives you access to functions defined on a type.

  Use “\Inline(\:\,)” if you need to end an identifier but alphanumeric content follows.

  This concludes the simple command structures.
  Next, we will look at command structures that have nested levels.

  \Section(Details)

  A command consists of one or more command structures, the first one always being a symbol reference.
  Each subsequent structure after the first one has the previous structure as \Emph(subject).

  Identifiers consist of alphanumeric characters. The first non-alphanumeric character ends the identifier.

  The identifier of a symbol reference resolves in the namespace of the used command character.
  You can have multiple command characters to avoid name clashes when importing symbols.

  The backslash “\Inline(\\)” contains all symbols predefined by Nyarna.
  There is a small subset of symbols defined in every character namespace, which will be discussed later on.
:right:
  \Interactive:
    \Input(input):
      # we will discuss type and variable declaration syntax later
      \declare:
        Range = \Record:
          low, high: \Integer
        \end(Record)
      \end(declare)
      \var:
        txt   = \Text(droggeljug)
        num   = \Integer(42)
        stars = \Range(1, 5)
      \end(var)

      # this evaluates to the current value of our variables
      \txt \num

      # access fields of our record value
      Can't give less than \stars::low or more than \stars::high stars.

      # access a function predefined on \Text
      The text '\txt' has \Text::len(\txt) characters.

      # there's a shorthand prefix notation
      The text '\txt' has \txt::len() characters.

      # end a command explicitly
      \txt:,gler
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Nested Levels, permalink=levels/):
  Commands can have two kinds of \Emph(arguments)\:
  \Emph(flow arguments) are given in parentheses “\Inline(\(…\))” while \Emph(blocks) are appended after a potential list of flow arguments.

  Flow arguments can be named, the name must then be an identifier followed by “\Inline(\=)”.
  They are separated by commas “\Inline(\,)”.

  A colon “\Inline(\:)” indicates that a list of blocks follows.
  The list of blocks ends with the special structure “\Inline(\\end\(…\))” where \Inline(…) is the identifier of the current command structure.
  This would usually be the symbol that is currently called or assigned to.

  In blocks, a line starting with a colon “\Inline(\:)” starts a block name.
  The block name must be an identifier, after which a second colon “\Inline(\:)” follows.

  In blocks, the indentation of the first non-empty line defines the indentation of the block.
  This indentation will be stripped away and is not processed as content.

  \Section(Details)

  There are two substructures that allow commands to have nested levels:
  \Emph(argument lists) and \Emph(block lists).

  An \Emph(argument list) starts with an opening parenthesis “\Inline(\()”, which must succeed a command structure.
  The argument list ends with a closing parenthesis “\Inline(\))”.
  Parentheses are only special characters in this context and are processed as content elsewhere.

  In an argument list, zero or more \Emph(flow arguments) may be given.
  The argument content cannot contain any of the characters “\Inline(\=\(\)\,)” unless they are escaped.
  Flow arguments may be multi-line and cannot contain blocks.

  A \Emph(block list) starts with an opening colon “\Inline(\:)”, which must succeed a command structure.
  The identifier used in \Inline(\\end\(…\)) is the name of the subject in the current command structure if that subject is a symbol, or empty otherwise.
  If the command started with a command character other than “\Inline(\\)”, that character must also be used in front of \Inline(end).

  A block list may contain an optional \Emph(primary block), and any number of \Emph(named blocks).

  A named block starts with a block name, which consists of an opening colon “\Inline(\:)”, an identifier, and a closing colon “\Inline(\:)”.
  Block names must start at the beginning of a line and may only be preceded by inline whitespace.
  Both the initial “\Inline(\:)” and the block names may have block headers but no following content.
  Other lines make up the block content.

  Whitespace is ignored at the beginning and end of any flow argument or block.
  In flow arguments, all whitespace at the beginning of each line is ignored, allowing for indentation of continuation lines.

  The first non-empty line of a block's content defines the block's indentation, which may consist of either space or tabulator characters, but not both.
  At most this number of characters of the chosen kind will be removed from the beginning of every content line of the block.
  This feature allows you to visually present block levels with indentation in your source, without causing it to add whitespace content.
:right:
  \Interactive:
    \Input(input):<map \ @, off :, off #>
      @
      @
      The top-level structure of any input is a block.
      Hence, the first empty line is not part of the content.

      # this is a trivial predefined function that returns its
      # content. You can use it to create nested levels
      \block:
        This is a primary block. It is indented by two spaces.
          These two additional spaces will be part of the output.
      \end(block)

      # call with three flow arguments, the third being named
      \if(true, # space and newlines between args are ignored
        droggel,
        else = jug
      )

      # flow arguments and blocks can be part of the same call
      \if(true):
        droggel
      :else:
        jug
      \end(if)

      # call with two flow arguments and one named block
      \if(true, then = droggel):
      :else:
        # blocks can be nested
        \block:
          jug
        \end(block)
      \end(if)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Calls and Assignments, permalink=calls/):
  You \Emph(call) a subject by giving a list of flow arguments, a list of blocks, or both.
  You can give each argument either as flow argument or block.
  This generalizes over LaTeX's commands and environments.

  You can call functions and certain types.
  Such calls are \Emph(call expressions) and will evaluate their arguments during evaluation.
  Calling a \Inline(Record) type will construct a record value, the arguments go into are the type's fields.

  You can also call \Emph(keywords).
  In Nyarna, keywords are symbols just like functions and types.

  A special kind of keywords are \Emph(prototypes) which, when called, generate types.
  For example, \Inline(\\Record) is a prototype that when called generates a record type with the given fields.

  \Emph(Assignments) are structurally similar to calls.
  They start with a “\Inline(\:\=)” after the subject, followed by either an argument list or a block list, which must contain exactly one unnamed argument.
  Assignable subjects are variables, fields of variables, as well as List and HashMap accessors.

  \Section(Details)

  A \Emph(call) is a command structure that has a subject succeeded by an argument list, a block list, or both in that order.
  Calls can be chained with other calls and accesses.
  The call subject must define a list of parameters.
  Each flow argument and block will be associated with one of those parameters.
  Each parameter's argument may be given as either flow argument or block.
  The call subject defines the order and name of parameters, and which parameter consumes the primary block.

  Calling a keyword is syntactically the same as a call expression, however while the call expression \Emph(is) an expression, the keyword call \Emph(generates) one.
  For example, a call to \Inline(\\if) will generate an \Emph(if-expression).
  This expression will, when evaluated, check its condition value and then either evaluate the \Inline(then) or the \Inline(else) branch.
  If \Inline(\\if) was a function, calling it would evaluate both branches which is not desirable.
:right:
  \Interactive:
    \Input(input):
      # a call to the declare keyword injects custom syntax for
      # its primary block, this will be discussed later on.
      \declare:
        # define a record type. fields have again custom syntax
        Range = \Record:
          low, high: \Integer
        \end(Record)
      \end(declare)

      # var is another keyword that injects custom syntax
      \var:
        # we call the record type we created above
        # to create a record value
        stars = \Range(-2, 2)
      \end(var)

      # assign a new value to our variable with a flow argument
      \stars:=(\Range(0, 5))
      #assign a new value to a field with a block
      \stars::low:=:
        1
      \end(low)

      # some parameters are optional and don't require a
      # mapped argument. This call doesn't give an argument
      # for 'else'.
      \if(
        # here we combine accesses with a call.
        # we call the predefined function 'gt' on the field
        # \stars::low, with an additional argument '0'
        \stars::low::gt(0)
      ):
        Range starts above 0!
      \end(if)

      # we can immediately call a type generated
      # by a prototype call. We can also immediately
      # access a field of the returned record value.
      \Record:
        content: \Text
      \end(Record)(content = spam)::content
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Basic Types, permalink=types/):
  \Inline(\\Text) is the default type for the output.
  Unless we specify something else, our input must be an expression of type \Inline(\\Text).
  You may have noticed that we have never written a \Inline(Record) value to the output, this is why.

  \Inline(\\Text) is a \Emph(textual) type, with the prototype \Inline(\\Textual).
  We can define other textual types that only allow specific characters in them.

  We have also seen \Emph(numeric) types, with the prototype \Inline(\\Numeric).
  \Inline(\\Integer) is a predefined numeric type.

  The prototype \Inline(\\Enum) generates \Emph(enumeration) types, which are used for example for the predefined \Inline(\\Bool) type.

  Nyarna calls these types \Emph(scalar types).
  Each scalar type can be called to create an instance of it.

  Each prototype defines a set of functions that are defined on each type generated by this prototype.
  For example, each textual type has a function \Inline(len), and each numeric type has a function \Inline(gt) (greater than).
  These functions are currently sparse, since the standard library has not been seriously worked on yet.

  Where \Inline(\\Text) is expected, you can give any scalar value and Nyarna will convert it to text.

  \Section(Details)

  Nyarna has a static type system.
  Each symbol, parameter and variable has a type that can't be changed dynamically.

  Nyarna's types form a hierarchy called a \Emph(lattice).
  This means that if \Emph(a ≤ b) for two types \Emph(a) and \Emph(b), you can use expressions of type \Emph(a) everywhere expressions of type \Emph(b) are expected.

  For any type \Emph(a) that is either textual, numeric, or an enumeration, \Emph(a ≤ \Inline(\\Text)) is true.
:right:
  \Interactive:
    \Input(input):
      # declare some types
      \declare:
        # numeric type with integer backend
        SmallNumber = \Numeric(int, min=0, max=10)
        # textual type that may only contain the letter 'a' and 'A
        OnlyA = \Textual(include=aA)
        # textual type that may contain characters in the unicode category L
        OnlyLetters = \Textual(cats=L)

        TrafficLights = \Enum(red, yellow, green)
      \end(declare)

      # all of these can be written directly into the output
      \SmallNumber(3)
      \OnlyA(aaaaaAAAAAAaaaa)
      \OnlyLetters(abcdefghijklmnoqrstuvwxyz)
      \TrafficLights(red)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Declarations, permalink=declare/):
  Besides Types, you can also define \Emph(functions) in a \Inline(\\declare) block.
  \Inline(\\declare) is one of the symbols available in every namespace and will put all symbols into the namespace which has been used to call it.
  You can give a type as flow argument which then declares symbols in the namespace of that type instead.

  Lexical order of symbol declarations is significant, you cannot refer to a symbol before it is declared.
  \Inline(\\declare) calls are an exception to that rule, inside declarations you can refer to any symbol declared in the same \Inline(\\declare) call.
  This allows for circular types and recursive functions.

  Record types declare fields in the same way functions declare parameters.
  Any parameter configuration on a record type's fields will be used for its constructor signature.
  A typical configuration is to set the \Inline(primary) parameter, so that it takes the primary block as argument in a call.

  \Section(Details)

  The primary block of \Inline(\\declare) is for \Emph(public) symbols, which can be imported to other modules.
  There is a \Inline(private) parameter available for symbols that should not be exported.

  When declaring functions, you can explicitly give a \Inline(return) argument to set their return type, but Nyarna has been designed to infer it.
  Return types can be inferred even in presence of direct or indirect recursion.

  When declaring function parameters, you can give them default block configurations.
  The details will be discussed in \Link(/tour/headers/, Headers) and \Link(/tour/swallowing/, Swallowing).
  These default configurations are what cause \Inline(\\declare) and \Inline(\\func) to use special syntax for symbol and parameter declarations respectively.

  Since functions are first-class values, you can declare anonymous functions with \Inline(\\func) outside of \Inline(\\Declare).

  There is a keyword \Inline(\\builtin) that takes parameters and a return type.
  This declares a builtin function whose implementation is to be provided by the Nyarna processor.
  Knowing this, you can read the \Link(https://github.com/nyarnalang/nyarna-zig/blob/master/lib/system.ny, system.ny) file of the standard library.
  This file is automatically loaded and defines all predefined symbols.
:right:
  \Interactive:
    \Input(input):
      \declare:
        fibonacci = \func:
          index : \Natural
        :body:
          \if(\index::lte(1), \index):
          :else:
            # recursive call allowed
            \Natural::add(
              \fibonacci(\index::sub(1)),
              \fibonacci(\index::sub(2))
            )
          \end(if)
        \end(func)

        Section = \Record:
          # type inferred from default value
          title  = \Text(Unnamed Section)
          # declare 'content' as primary parameter
          content: \Text {primary}
        \end(Record)
      \end(declare)

      # declare symbols in the namespace of \Section
      \declare(\Section):
        render = \func:
          # not auto 'this' parameter, no OOP.
          this: \Section
        :body:
          === \this::title ===
          \this::content
        \end(func)
      \end(declare)

      \fibonacci(6)
      \var:
        sec = \Section:
          # goes into content
          Unspecified Content
        \end(Section)
      \end(var)
      # prefix notation possible since 'render' is
      # in the namespace of the type of \sec
      \sec::render()
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Structural Types, permalink=structural/):
  By mixing text content with commands, we create a \Emph(concatenation).
  By adding empty lines, we create \Emph(paragraphs), which can in turn be concatenations.
  Both are syntactic constructs that produce typed expressions.

  A concatenation can be heterogeneous, i.e. contain expressions of different types.
  For example, if you want to write text and have some of that text be rendered with a bold font, you would define a \Inline(Record) named \Emph(Bold) that has textual content.
  You can then write a concatenation which contains both text and \Inline(\\Bold) values.

  Nyarna allows this structure by supporting \Emph(type intersections).
  The concatenation of \Inline(\\Text) expressions and \Inline(\\Bold) expressions will thus be of type \Inline(\\Concat\(\\Intersection\(\\Text\, \\Bold\)\)).

  A concatenation whose content is a pure scalar type will have a textual type because concatenation is an operation on textual types.
  If the inner concatenation type is an enumeration or numeric type, the resulting type will be \Inline(\\Text) because you can't concatenate numbers or enumeration values.

  Similarly, there is a prototype \Inline(\\Sequence) for paragraphs content.
  \Inline(\\Sequence) types carry the semantics of having \Emph(separated) inner items.
  The separators (i.e. empty lines) are part of the values.
  Unlike with \Inline(\\Concat), you \Emph(can) have a \Inline(\\Sequence\(\\Text\)) because the text items are separated.

  You may think, if syntactic paragraphs have a \Inline(\\Sequence\(\\Text\)) type, why can we write multiple paragraphs in the input that expects the type \Inline(\\Text)?
  That is because an implicit conversion exists from \Inline(\\Sequence\(\\Text\)) to \Inline(\\Text), which merges the paragraphs with the separators.

  \Section(Details)

  When two expressions are both contributing to an inferred type, for example by being part of the same concatenation, or by being the \Inline(then) and \Inline(else) branch of an \Inline(\\if) expression, their types get \Emph(intersected) to calculate the return type.
  Intersection is an operation on two types \Emph(a) and \Emph(b) whose result is \Emph(c) with \Emph(a ≤ c ∧ b ≤ c).

  An \Inline(\\Intersection) type contains at least two types of which at most one may be a scalar type, the others must be record types.
  It is the result of intersecting its contained types.
  The semantics of an expression having an intersection type is that it may evaluate to a value of either of the contained types.

  If you have an expression that has an intersection type, you can use \Inline(\\match) or \Inline(\\matcher) to branch on its actual type at runtime.
  We will see an example of this shortly.

  Intersections between \Inline(\\Void) (a type usually created by missing expressions, such as a missing \Inline(else) branch) and another type will create an \Inline(\\Optional) type whose inner type is the non-void type.
  An expression of \Inline(\\Optional) type will contribute its inner type to the calculated type of a concatenation a paragraphs expression.
  For example, a concatenation of \Inline(\\Bold) and \Inline(\\Optional\(\\Text\)) will have the type \Inline(\\Concat\(\\Intersection\(\\Bold\, \\Text\)\)).
:right:
  \Interactive:
    \Input(input):
      \declare:
        Section = \Record:
          title: \Text
          content: \Sequence(\Paragraph) {primary}
        \end(Record)

        ParaContent = \Intersection(\Text, \Bold)
        Paragraph   = \Concat(\ParaContent)

        Bold = \Record:
          content: \Text {primary}
        \end(Record)

        # defines a function to unfiddle our heterogeneous concat
        # this uses a bunch of syntax we haven't discussed yet
        textProc = \matcher:
        :(\Text):|\t|
          \t
        :(\Bold):|\b|
          <strong>\b::content</strong>
        \end(matcher)
      \end(declare)

      \var:
        section = \Section(A nice title):
          This \Bold(text) is the content of our section.
          It contains \Bold(both) literal text and record
          \Bold(values).

          It also contains multiple \Bold(paragraphs).
        \end(Section)
      \end(var)

      # transform our section into some nice HTML
      <section>
      <h2>\section::title</h2>
      # \for called on a sequence outputs a sequence by
      # default, we set the collector to \Concat to
      # concatenate the generated values instead.
      \for(\section::content, collector=\Concat):|\para|
        # \map applies \textProc to each item in the content
        <p>\map(\para, \textProc)</p>\
      \end(for)# comment removes additional line break
      </section>
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Schemas, permalink=schemas/):
  In the previous example, we have already seen how to transform a structured value into HTML.
  Schemas offer a more structured approach to this:
  Typically, you write a schema file that contains all required types and defines the root type, and then in your input, you import that schema and use it.

  Our new example does the same as the previous one, but with the processing and structure moved to a schema.
  The main input is now much cleaner, the types and processing has been moved to the separate \Inline(Section) input.

  A schema is defined via a call to \Inline(\\SchemaDef), which is a predefined type but acts like a keyword when called.
  We declare our types like before in the main block, and then add a \Emph(backend) named \Inline(html) that does the transformation.

  A backend can define functions, and must have a body that evaluates to a concatenation of \Inline(\\Output), another predefined type.
  An \Inline(\\Output) has a name, which means that we don't get \Inline(&lt;stdout&gt;) output anymore, but an output named \Inline(input.html).
  We can potentially create multiple outputs with a single backend.

  We now use \Inline(\\standalone) to declare the root type of our input's content.
  \Inline(\\standalone) means that this \Emph(module) can be the main module for processing.
  Nyarna calls its inputs \Emph(modules).

  Interpreting our input will automatically use the \Inline(html) backend as it's the only backend defined.
  We can define multiple backeds for our schema, for example if we also wish to produce LaTeX source code.

  \Section(Details)

  Nyarna predefines the schema \Inline(Schema) which is the schema of schemas.
  It is best practice to have your schemas use that schema.
  In the future, this predefined schema may have backends, which you could use to autogenerate code from your schema, for example if you want to load a document of your schema into your application.

  If you import a standalone module into another module, the schema of the imported module doesn't matter, just its root type.
:right:
  \Interactive:
    \Input(input):
      \standalone(schema=\import(Section))

      \Section(A nice title):
        This \Bold(text) is the content of our section.
        It contains \Bold(both) literal text and record
        \Bold(values).

        It also contains multiple \Bold(paragraphs).
      \end(Section)
    \end(Input)
    \Input(Section):
      \standalone(schema=\import(Schema))

      \SchemaDef(root=\Section):
        Section = \Record:
          title: \Text
          content: \Sequence(\Paragraph) {primary}
        \end(Record)

        ParaContent = \Intersection(\Text, \Bold)
        Paragraph   = \Concat(\ParaContent)

        Bold = \Record:
          content: \Text {primary}
        \end(Record)
      :backends:|\doc|
        html = \backend:
        :funcs:
          textProc = \matcher:
          :(\Text):|\t|
            \t
          :(\Bold):|\b|
            <strong>\b::content</strong>
          \end(matcher)
        :body:
          \Output(name=\doc::name.html):
            <section>
            <h2>\doc::root::title</h2>
            \for(\doc::root::content, collector=\Concat):|\para|
              <p>\map(\para, \textProc)</p>\
            \end(for)#
            </section>
          \end(Output)
        \end(backend)
      \end(SchemaDef)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Extensions, permalink=extensions/):
  An important feature of Nyarna is its ability to extend existing schemas.
  Imagine someone else defined a schema that produces HTML, and you want to use that.
  However you want to produce a HTML tag that is not supported by that schema.

  With \Emph(extensions), you can extend that schema to support your desired tag, without changing the schema's source code.
  Extensions let you add types to a schema, inject these types into existing intersections, and inject processing code into the backends.
  Extensions also let you add additional backends that do not exist in the original schema.

  By bundling schema types with processing code, Nyarna strives to achieve better modularity in its schemas than schemas in other languages, like for example XML schemas or JSON schemas, can provide.

  You use the special “\Inline(\|\=)” operator when defining an extension to merge expressions into existing definitions.

  The example code extends the schema we previously defined with a new type \Inline(\\Emph) that allows us to enter italic code.

  By calling the \Inline(use) function on the \Inline(\\SchemaDef), we can set the backend we want to use, and give the extensions we want to inject.
:right:
  \Interactive:
    \Input(input):
      \standalone:
      :schema:
        # last time SchemaDef was implicitly converted to Schema.
        # this time, we do it explicitly by calling 'use'.
        # we need to set the backend explicitly and can define
        # the extensions we want to use.
        \import(Section)::use(html, extensions=\import(Emph))
      \end(standalone)

      \Section(A nice title):
        This \Bold(text) is the content of our section.
        It contains \Bold(both) literal text and record
        \Bold(values).

        It also contains multiple \Bold(paragraphs).

        We can now use \Emph(italic) text!
      \end(Section)
    \end(Input)
    \Input(Section):
      \standalone(schema=\import(Schema))

      \SchemaDef(root=\Section):
        Section = \Record:
          title: \Text
          content: \Sequence(\Paragraph) {primary}
        \end(Record)

        ParaContent = \Intersection(\Text, \Bold)
        Paragraph   = \Concat(\ParaContent)

        Bold = \Record:
          content: \Text {primary}
        \end(Record)
      :backends:|\doc|
        html = \backend:
        :funcs:
          textProc = \matcher:
          :(\Text):|\t|
            \t
          :(\Bold):|\b|
            <strong>\b::content</strong>
          \end(matcher)
        :body:
          \Output(name=\doc::name.html):
            <section>
            <h2>\doc::root::title</h2>
            \for(\doc::root::content, collector=\Concat):|\para|
              <p>\map(\para, \textProc)</p>\
            \end(for)#
            </section>
          \end(Output)
        \end(backend)
      \end(SchemaDef)
    \end(Input)
    \Input(Emph):
      \fragment(\SchemaExt)

      \SchemaExt:
        Emph = \Record:
          content: \Text {primary}
        \end(Record)

        ParaContent |= \Intersection(\Emph)
      :backends:|\doc|
        html = \backend:
        :funcs:
          textProc |= \matcher:
          :(\Emph):|\em|
            <em>\em::content</em>
          \end(matcher)
        \end(backend)
      \end(SchemaExt)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Parameters, permalink=parameters/):
  A Nyarna module can define parameters.
  When importing a module with parameters, you must supply arguments for those.
  When calling a main module that defines parameters, the caller must supply arguments.

  Module parameters are typed.
  By having a main module with parameters, you can use Nyarna as templating engine.
  Parameters are interpreted as Nyarna source.

  Currently, you can only input arguments of predefined, simple types.
  In the future, parameters should implicitly supply all types of the main module's schema, so that you can input complex structures as arguments.

  On the command line, you can call the example code like this:

  \Code(highlight = false):
    nyarna input.ny --txt Text --num 42
  \end(Code)
:right:
  \Interactive(txt, num):
    \Input(input):
      \standalone:
      :params:
        txt: \Text
        num: \Integer
      \end(standalone)

      txt = \txt
      num = \num
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Swallowing, permalink=swallowing/):
  Block indentation makes sense for programming languages where you can often split up code into smaller parts if indentation gets too deep.
  But for the possibly long content Nyarna has been designed for, it doesn't always make sense – especially if the block takes up more than a whole screen.

  Nyarna provides an alternate syntax that lets you write nested structured input on a single level: \Emph(Swallowing).
  If you end a call's block list with “\Inline(&gt;)” right after the starting colon, or after a block name, the command syntactically ends.
  All of the following content till the end of the surrounding block will be used as final argument to the call.

  If you gave “\Inline(&gt;)” right after the blocks start, this final argument will be used as primary block.
  If you gave it after a block name, the final argument will be used as the block with that name.
  You mustn't give an “\Inline(\\end\(…\))” structure for a call you have used swallowing on.

  Before “\Inline(&gt;)”, you may give decimal digits denoting a \Emph(swallow depth).
  If you do, the swallowed content will alternatively end before a call that uses the same or a lesser swallow depth.

  You can define a call parameter to be \Emph(auto-swallowing).
  When you then call the entity with that parameter without an argument for that parameter, and without a block list, the following content will automatically be swallowed.
:right:
  \Interactive:
    \Input(input):
      \standalone(schema=\import(Book))

      # swallow into the primary parameter.
      # since this call is on the topmost level, all following content
      # will be swallowed.
      \Book(The Very Compact History of the World):>

      # swallow with a depth of 1.
      \Chapter(The Beginning):1>

      There was a rock in space.

      # ends the previous chapter
      # because this one has the same swallow depth
      \Chapter(The Interesting Part):1>

      # swallows at depth 2. contained in the previous chapter.
      \Section(Plants):2>

      We have them.

      \Section(Animals):2>

      Those too.

      # ends both the Section and the Chapter
      \Chapter(Finally: Humans):1>

      # swallows at depth 2 automatically
      # (check the Book schema)
      \Section(On Land)

      They walk.

      # ends previous section by auto-swallowing
      \Section(At Sea)

      They drown. Bummer.
    \end(Input)
    \Input(Book):
      \standalone(schema=\import(Schema))

      \SchemaDef(root=\Book):
        Section = \Record:
          title  : \Text
          # primary parameter, which is declared auto-swallowing
          content: \Sequence(\Text) {primary}:2>
        \end(Record)
        Chapter = \Record:
          title  : \Text
          content: \Sequence(\Text, \Section) {primary}:1>
        \end(Record)
        Book = \Record:
          title  : \Text
          content: \Sequence(\Chapter) {primary}
        \end(Record)
      :backends:|\doc|
        markdown = \backend:
        :funcs:
          process = \matcher:
          :(\Text):|\t|
            \
            \
            \t
          :(\Section):|\s|
            \
            \
            \#\#\# \s::title#
            \map(\s::content, \process, collector=\Concat)
          :(\Chapter):|\c|
            \
            \
            \#\# \c::title#
            \map(\c::content, \process, collector=\Concat)
          :(\Book):|\b|
            \# \b::title#
            \map(\b::content, \process, collector=\Concat)
          \end(matcher)
        :body:
          \Output(\doc::name.md):
            \process(\doc::root)
          \end(Output)
        \end(backend)
      \end(SchemaDef)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Block Headers, permalink=headers/):
  Any block can have a \Emph(header).
  Named blocks have their header behind their name, while the primary block has its header after the colon that starts the block list.
  A block header may consist of a \Emph(configuration), a \Emph(capture list) and a \Emph(swallow indicator).
  If more than one of those are given, they must be separated by additional colons “\Inline(\:)”.

  A \Emph(block configuration) customizes the parser while processing this block.
  It starts with a “\Inline(&lt;)”, ends with a “\Inline(&gt;)”, and separates its items with commas “\Inline(\,)”.
  It can have zero or more items, with each item having the structure “\Inline(&lt;name&gt; &lt;params&gt;)”.

  Command characters can be customized via “\Inline(map &lt;a&gt; &lt;b&gt;)”, “\Inline(csym &lt;a&gt;)” and “\Inline(off &lt;a&gt;)”.
  These can be used if you want to enter text that will contain a character that would usually be a command character.
  You can either disable that character completely, or map it to a different, unused character.

  \Inline(map) takes two characters which must both be in one of the unicode categories \Emph(M) (marks), \Emph(P) (punctuation) or \Emph(S) (symbols).
  The first character must be a command character in the outer level, the second character must not.
  Inside the new block, \Inline(a) will not be a command character anymore, and \Inline(b) will instead be one which provides access to the namespace of \Inline(a).

  \Inline(off) disables the given character \Inline(a), which must be either a command character, “\Inline(\#)” (disabling comments) or “\Inline(\:)” (disabling block names).
  You can use \Inline(off) without arguments to disable all command characters as well as comments and block names.

  \Inline(csym) enables \Inline(a) to be a new command character (with the same requirements as for \Inline(map)).
  This gives you a separate namespace to import symbols to.

  Regardless of what you do to command characters, you will always be able to end the block list with the “\Inline(\\end\(…\))” structure.
  The parser has a lookahead that checks for the current identifier inside that structure and will parse it only as block list end if the identifier is the expected one.
  You can change the expected identifier with a “\Inline(\= &lt;identifier&gt;)” in a call's argument list to give you full control of how the block ends.
:right:
  \Interactive:
    \Input(input):
      # change the default command character
      \block:<map \ @>
        \this is not a command
        @if(true):
          but this is
        @end(if)
      \end(block) # must use \end because \block started it

      # disable comments and block names
      \block:<off :>
        : not a block name :
        \block:<off #>
          # this is content because comments are disabled
        \end(block)
        # comments are enabled again
      \end(block)

      # disable everything.
      \block:<off>
        : no colons
        # no comments
        \no commands
        final destination.
      \end(block)

      # be able to use \end(block) as content
      \block( = myblock ):<off>
        \end(block)
      \end(myblock)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Capture Variables, permalink=captures/):
  A block header may define one or more \Emph(capture variables).
  These can be used on certain keyword calls to provide one or more symbols that shall reference relevant values.
  Capture variables are not assignable.

  The \Inline(\\if) keyword allows a capture variable in its \Inline(then) argument if the given condition is an \Inline(\\Optional) expression.
  The variable can then be used to reference the existing value.

  The \Inline(\\for) keyword allows for up to two capture variables in its body, with the first referencing the current item, and the second referencing its index.
:right:
  \Interactive:
    \Input(input):
      \var:
        x: \Optional(\Text) = \Text(some value)
      \end(var)

      \if(\x):|\value|
        \value
      :else:
        no x :(
      \end(if)

      \for(\List(\Text)(one, two, three), collector=\Concat):|\text, \index|
        \index\: \text\
      \end(for)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Conversions, permalink=conversions/):
  Text input in Nyarna is of one of two types, \Inline(Literal) or \Inline(Space).
  These types are internal and cannot be referenced in user code.

  Usually, text input is statically converted into the required scalar type.
  For example, “\Inline(false)” in an \Inline(\\if) expression is immediately converted to \Inline(\\Bool).

  However, the target type is not always available.
  For example, text can be in the body of a function, whose return type is inferred by Nyarna.
  In such cases, the return type of the function will use these internal types and conversion will happen at runtime, when the function is called.

  \Inline(Space) is the type of textual content consisting of only whitespace.
  \Inline(Literal) is used for all other textual content.

  The significance of \Inline(Space) is that it can be converted away implicitly when part of a concatenation.
  The example shows how two record instances are created in the function \Inline(things).
  They are separated by a newline, which is textual content and has the type \Inline(\\Space).

  If this is used in a context where textual content is not allowed, Nyarna will convert the space content away implicitly.
  This allows you to use whitespace for nice formatting in places where only record values are expected.

  If, however, the same content is used in a place where textual content \Emph(is) allowed, the newline becomes \Inline(\\Text).
  The example shows this happening by assigning the function's return value to two variables where one allows \Inline(\\Text) while the other doesn't.
  The second assignment will create an implicit conversion that strips away the whitespace.
  Try it out!

  \Section(Details)

  As discussed previously, an expression of type \Emph(a) can be used in a context where type \Emph(b) is expected if \Emph(a ≤ b).
  If this relation does not exist for \Emph(a) and \Emph(b), Nyarna may create an implicit conversion which replaces the original expression and has type \Emph(c) where \Emph(c ≤ b).

  Such conversions exist for removing \Inline(\\Space), but also for transforming a \Inline(\\Sequence) expression into \Inline(\\Concat).
  If a \Inline(\\Sequence) is converted into a \Inline(\\Concat), the separators (empty lines) are inserted into the content as \Inline(\\Space).
  These can then be stripped away if necessary.
:right:
  \Interactive:
    \Input(input):
      \declare:
        One = \Record:
          content: \Text
        \end(Record)

        Two = \Record:
          content: \Text
        \end(Record)

        things = \func:
        :body:
          \One(one)
          \Two(two)
        \end(func)

        render = \matcher:
        :(\Text):|\t|
          \t
        :(\One):|\o|
          One(\o::content)
        :(\Two):|\t|
          Two(\t::content)
        \end(matcher)
      \end(declare)

      \var:
        a : \Concat(\Intersection(\One, \Two)) = \things()
        b : \Concat(\Intersection(\One, \Two, \Text)) = \things()
      \end(var)

      === Content of a ===
      \map(\a, \render)

      === Content of b ===
      \map(\b, \render)
    \end(Input)
  \end(Interactive)
\end(TourPage)

\TourPage(Evaluation, permalink=evaluation/):
  Nyarna's keywords sometimes need to evaluate expressions statically.
  For example, the \Inline(\\func) keyword needs to evaluate parameter types (but not default values) statically.
  This is important because it means that you can't use dynamic values, such as variables and parameter values, in certain contexts.

  Whether a certain expression is evaluated statically or dynamically is a local concept and different from the classical difference between compile time and runtime.
  For example, a function body is a dynamic context, so you can retrieve a parameter's value there.
  Even if the function is called in a static context, this retrieval is still legal.
  There is no functionality that is generally not available in any transitively static context.

  Nyarna offers some static introspection keywords in the \Inline(meta) library that is part of the standard library.
  The example shows that we can, for example, iterate over the declared parameters of a function or Record.
  This is possible because even parameter declarations are first-class values with the type \Inline(\\Location).

  Like the rest of the standard library, \Inline(meta) is incomplete and currently mostly a proof-of-concept.
:right:
  \Interactive:
    \Input(input):
      \declare:
        Something = \Record:
          a: \Text
          b: \Integer
        \end(Record)
      \end(declare)

      \var:
        object = \Something(spam, 42)
      \end(var)

      # provides \params and \access
      \import(meta)

      # \unroll is a static \for that evaluates the input
      # statically and instantiates the body for each value.
      #
      # the parameter to \params is statically evaluated to
      # a function signature, which is fine heresince a
      # record type has a constructor signature.
      \unroll(\params(\Something), collector=\Concat):|\f|
        # \access statically evaluates the second parameter
        # to an identifier and creates an access node to
        # that field into the given \object (which is not
        # evaluated statically).
        #
        # we can do this because \f::name() can be statically
        # evaluated, due to our use of \unroll. \f would be
        # a dynamic variable in a \for loop.
        field \f::name() has value \access(\object, \f::name())\
      \end(unroll)
    \end(Input)
  \end(Interactive)
\end(TourPage)