# nyarna.org Website

This is the source of the [nyarna.org](https://nyarna.org) website.
Build it with

    nix build

in a checked-out repository.

## Developers

This site is written in Nyarna.
`Site.ny` is the schema and `website.ny` is the content.

After building, you can host it locally via

    python -m http.server 80 -d result/www

## License

[MIT](/License.md)