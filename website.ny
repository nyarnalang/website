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
    Its goal is to be a viable frontend language for LaTeX-based document generation, giving access to the typesetting system's abundant features while being more user-friendly and flexible.
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
    This potentially allows for auto-generation of code translating between input in a given Nyarna Schema and your application's native data types.

    \Section(User-friendly Learning Curve)

    Minimal knowledge is required to produce simple output.
    Basic knowledge about command structures already lets a user write input for a given schema.
    More detailed knowledge about types and functions allows for programmatic construction of the input data.
    The most complex features are usually only needed for writing Schemas.
  :right:
    \Code(\example)
  \end(Split)
\end(Page)

\Page(About, permalink=about/):
  \Split:
    Nyarna has been developed as research project at the
    \Link(https://www.iste.uni-stuttgart.de, Institute of Software Engineerung), University of Stuttgart, Germany.

    The \Link(/tour/, tour) is the current authoritative source for the language syntax and semantics.
    A proper specification has been written during the course of the language's development, but is not up-to-date and would therefore not be of any use.
    The plan is to release it after a proper rewrite.

    The reference implementation, as well as the content of this site, is licensed under the terms of the \Link(https://opensource.org/licenses/MIT, MIT license).

    \Section(Reference Implementation)

    The reference implementation written in Zig is publicly available \Link(https://github.com/nyarnalang/nyarna-zig, here).
    It is in no way stable and may crash on invalid and even valid input.

    The standard library is almost non-existing and a lot of simple functionality is missing.
    The current release is to be seen in the spirit of \Emph(release early\, release often).
  :right:

  \end(Split)
\end(Page)

\TourPage(Introduction, permalink=tour/):
  This tour introduces you to Nyarna's language features.
  On your right you'll find the example code for each step.
  You can edit and interpret this code in your browser.
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

  \Code:
    nyarna &lt;main-input&gt;.ny [--&lt;param-name&gt; &lt;arg&gt;]...
  \end(Code)

  Since there currently is no proper language specification, the tour will contain \Emph(Details) sections with more extensive information on the currently discussed features.
  You may skip these if you just want to have a quick impression on the language.

  \Pager(nextLink=/tour/basics/)
:right:
  \Interactive(who):
    \Input(input, \example)
  \end(Interactive)
\end(TourPage)

\TourPage(Basics, permalink=tour/basics/):
  By default, input characters are processed as content.
  The “\Inline(\#)” character starts a line comment, with all following characters up to and including the following line ending being part of the comment.
  If the last non-whitespace character of a comment is another “\Inline(\#)” (i.e. not the initial one), the line ending is excluded from the comment.

  A \Emph(command character) introduces non-content structures.
  By default, the only command character is the backslash “\Inline(\\)”.
  You can escape non-alphanumeric characters with a command character.

  Empty lines separate \Emph(paragraphs).
  If a paragraph does not produce any output, it will be removed after evaluation.
  You can use paragraphs to cleanly separate code like declarations or assignments from code that produces output.

  \Pager(/tour/, /tour/commands/)

  \Section(Details)

  Nyarna works on Unicode input.
  The reference implementation currently only accepts UTF-8 encoded input.

  The \Emph(space) \Inline(U+0020) and \Emph(tabular) \Inline(U+0009) character are \Emph(inline whitespace).
  The \Emph(carriage return) \Inline(U+000D), \Emph(line feed) \Inline(U+000A), or both in sequence, are a \Emph(line ending).
  A \Emph(line ending) is always processed as if it was a single \Emph(line feed).

  \Emph(Inline whitespace) in front of a \Emph(comment) or a \Emph(line ending) is always ignored.
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

\TourPage(Commands, permalink=tour/commands/):
  \Emph(Commands) start with a \Emph(symbol reference), which is a \Emph(command character) followed by a \Emph(symbol name).

  A symbol reference can stand alone, which makes it a \Emph(value retrieval).
  This can be the value of a variable, but also a defined type or function.

  You can access fields or other nested entities via “\Inline(\:\:)”, followed by an identifier.
  Besides fields, this also gives you access to functions defined on a type.

  Use “\Inline(\:\,)” if you need to end an identifier but alphanumeric content follows.

  This concludes the simple command structures.
  Next, we will look at command structures that have nested levels.

  \Pager(/tour/basics/, /tour/levels/)

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

\TourPage(Nested Levels, permalink=tour/levels/):
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

  \Pager(/tour/commands/, /tour/calls/)

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

\TourPage(Calls and Assignments, permalink=tour/calls/):
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

  \Pager(/tour/levels/, /tour/types/)

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

      # var as another keyword that injects custom syntax
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

\TourPage(Basic Types, permalink=tour/types/):
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

  \Pager(/tour/calls/, /tour/structural/)

  \Section(Details)

  Nyarna has a static type system.
  Each symbol, parameter and variable has a type that can't be changed dynamically.

  Nyarna's types form a hierarchy called a \Emph(lattice).
  This means that if \Emph(a &lt; b) for two types \Emph(a) and \Emph(b), you can use expressions of type \Emph(a) everywhere expressions of type \Emph(b) are expected.

  For any type \Emph(a) that is either textual, numeric, or an enumeration, \Emph(a &lt;\= \Inline(\\Text)) is true.
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

\TourPage(Structural Types, permalink=tour/structural/):
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

  \Pager(/tour/types/, /tour/schemas/)
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

\TourPage(Schemas, permalink=tour/schemas/):
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

  \Pager(/tour/structural/, /tour/extensions/)

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
    \end(Input)#
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

\TourPage(Extensions, permalink=tour/extensions):
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

  \Pager(/tour/schemas/, /tour/parameters/)
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
    \end(Input)#
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
    \end(Input)#
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

\TourPage(Parameters, permalink=tour/parameters/):
  A Nyarna module can define parameters.
  When importing a module with parameters, you must supply arguments for those.
  When calling a main module that defines parameters, the caller must supply arguments.

  Module parameters are typed.
  By having a main module with parameters, you can use Nyarna as templating engine.
  Parameters are interpreted as Nyarna source.

  Currently, you can only input arguments of predefined, simple types.
  In the future, parameters should implicitly supply all types of the main module's schema, so that you can input complex structures as arguments.

  On the command line, you can call the example code like this:

  \Code:
    nyarna input.ny --txt Text --num 42
  \end(Code)

  \Pager(/tour/extensions/, /tour/swallowing/)
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

\TourPage(Swallowing, permalink=tour/swallowing/):
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

  \Emph(This concludes the tour).
  The few pages that follow detail some syntax that hasn't be described yet.


  \Pager(/tour/parameters/, /tour/headers/)
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
    \end(Input)#
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

\TourPage(Block Headers, permalink=tour/headers/):
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

  \Pager(/tour/calls/, /tour/swallowing/)
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

\TourPage(Capture Variables, permalink=tour/captures/):
  A block header may define one or more \Emph(capture variables).
  These can be used on certain keyword calls to provide one or more symbols that shall reference relevant values.
  Capture variables are not assignable.

  The \Inline(\\if) keyword allows a capture variable in its \Inline(then) argument if the given condition is an \Inline(\\Optional) expression.
  The variable can then be used to reference the existing value.

  The \Inline(\\for) keyword allows for up to two capture variables in its body, with the first referencing the current item, and the second referencing its index.

  \Pager(/tour/headers/, /tour/altsyntax/)
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

\TourPage(Alternate Syntax, permalink=tour/altsyntax/):
  This page has not yet been written. Bummer.

  \Pager(/tour/captures/)
:right:
  \Interactive:
    \Input(input):

    \end(Input)
  \end(Interactive)
\end(TourPage)