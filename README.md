# wavelet.nvim

Neovim support for the [Wavelet](https://github.com/logaan/wavelet) language:
syntax highlighting, `.wlt` filetype detection, and automatic map formatting, plus automatic
language-server support (diagnostics, completion, hover, document symbols) via
the [`wavelet-lsp`](https://github.com/logaan/wavelet/tree/main/tooling/wavelet-lsp)
binary.

This is a standard Vim/Neovim runtime-path package
(`ftdetect/`, `syntax/`, `plugin/`). The canonical copy lives in the Wavelet
repo as the `tooling/neovim` submodule; this repo is what plugin managers
install.

The syntax grammar mirrors the language's lexer (`src/lexer.rs` in the Wavelet
repo) and the shared Prism grammar used by the docs. It highlights:

- `#!` leading shebang line and `//` line comments
- `"..."` strings and `'.'` chars, with `\n` / `\u{...}` escapes
- `int` / `float` / `inf` / `nan` numbers
- `true` / `false` booleans and `some` / `none` / `ok` / `err` constructors
- the standalone `_` type placeholder (an absent result arm, `result(_ e)`)
- macro heads containing a TitleCase word (`If`, `lib/Identity`, `lib-Identity`, ...)
- call heads (a name attached, with no space, to `(`), including multi-segment names
- slash-separated names (slash normalizes to hyphen) and `name:` record keys
- the `.` joining a receiver to a chained call

## Install (LazyVim / lazy.nvim)

Drop a spec in `~/.config/nvim/lua/plugins/wavelet.lua`:

```lua
return {
  {
    "logaan/wavelet.nvim",
    version = "v0.1.0",
    ft = "wavelet",
    init = function()
      vim.filetype.add({ extension = { wlt = "wavelet" } })
    end,
  },
}
```

The `init` registers the `.wlt` → `wavelet` mapping at startup so the plugin
lazy-loads on the first Wavelet buffer. (`ftdetect/wavelet.vim` also ships in the
package for non-lazy / classic-Vim setups.)

## Formatting

Neovim automatically formats maps on save. Maps that extend past column 80,
plus maps that already span multiple lines, use one field per line with values
aligned vertically. Nested maps are handled independently; short single-line
maps are left alone. Strings, characters, and comments are preserved. This is a
map formatter, not a general-purpose Wavelet pretty-printer.

Run `:WaveletFormat` to format the current buffer without saving. Formatting
works without the language server. To change the width or disable formatting
on save, set these globals in your configuration:

```lua
vim.g.wavelet_format_width = 80
vim.g.wavelet_format_on_save = false
```

## Language server

For diagnostics, completion, hover, and document symbols, put the `wavelet-lsp`
binary on your `PATH` — the plugin starts it automatically for every `.wlt`
buffer. Install it from the Wavelet repo:

```console
$ cargo install --path tooling/wavelet-lsp     # installs into ~/.cargo/bin
```

Re-run the install command after updating the Wavelet checkout to pick up
compiler diagnostics and builtin completion/hover changes. Updating this plugin
does not update the language-server binary.

Alternatively, download a prebuilt `wavelet-lsp-<platform>` binary from the
[Wavelet releases page](https://github.com/logaan/wavelet/releases/latest).

To point at a specific binary instead of searching `PATH`, set:

```lua
vim.g.wavelet_lsp_path = "/abs/path/to/wavelet-lsp"
```

Classic Vim has no built-in LSP client, so there the language server is a no-op
and you still get highlighting.

## Customising colours

The syntax groups link to the standard Vim highlight groups (`Comment`,
`String`, `Function`, `Keyword`, ...), so your colorscheme drives the colours.
To override a specific token, add e.g. `highlight link waveletMacro Special` to
your config after the colorscheme loads.

Names may use `/` as sugar for `-`, including multiple segments. A TitleCase word anywhere in a name marks a macro call; `lib/Identity` and `lib-Identity` have the same meaning.

## Development checks

From this repository, run the highlighting regression checks with Neovim:

```console
nvim --headless -u NONE -l tests/highlighting.lua
nvim --headless -u NONE -l tests/formatting.lua
```

These cover chaining punctuation, decimal literals, slash-separated calls,
prefixed macros, placeholders, and the current file extension. Formatting checks
cover nested maps, alignment, idempotence, literals, comments, the format command,
and formatting on save.
