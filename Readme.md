# nyarna.org Website

This is the source of the [nyarna.org](https://nyarna.org) website.
It uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) as build system.
Build the website with

    nix build github:nyarnalang/website

or in a working copy simply

    nix build

Building the website will build Nyarna for your system (to generate the website) and for WASM (to provide the interpreter for the tour on the website) if those are not yet available.

## Developers

This site is written in Nyarna.
`Site.ny` is the schema and `website.ny` is the content.

After building, you can host the website locally via

    python -m http.server 80 -d result/www

## License

[MIT](/License.md)