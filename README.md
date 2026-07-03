# wavelet.nvim

Neovim support for the [Wavelet](https://github.com/logaan/wavelet) language:
syntax highlighting and `.wlt` filetype detection, plus automatic
language-server support (diagnostics, completion, hover, document symbols) via
the [`wavelet-lsp`](https://github.com/logaan/wavelet/tree/main/tooling/wavelet-lsp)
binary.

This is a standard Vim/Neovim runtime-path package
(`ftdetect/`, `syntax/`, `plugin/`). The canonical copy lives in the Wavelet
repo as the `tooling/neovim` submodule; this repo is what plugin managers
install.

The syntax grammar mirrors the language's lexer (`src/lexer.rs` in the Wavelet
repo) and the shared Prism grammar used by the docs. It highlights:

- `//` line comments
- `"..."` strings and `'.'` chars, with `\n` / `\u{...}` escapes
- `int` / `float` / `inf` / `nan` numbers
- `true` / `false` booleans and `some` / `none` / `ok` / `err` constructors
- the standalone `_` type placeholder (an absent result arm, `result(_ e)`)
- TitleCase macro heads (`If`, `Def`, `Fn`, `Package`, ...)
- call heads (a name attached, with no space, to `(`)
- `alias/name` qualified references and `name:` record keys

## Install (LazyVim / lazy.nvim)

Drop a spec in `~/.config/nvim/lua/plugins/wavelet.lua`:

```lua
return {
  {
    "logaan/wavelet.nvim",
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

## Language server

For diagnostics, completion, hover, and document symbols, put the `wavelet-lsp`
binary on your `PATH` — the plugin starts it automatically for every `.wlt`
buffer. Install it from the Wavelet repo:

```console
$ cargo install --path tooling/wavelet-lsp     # installs into ~/.cargo/bin
```

or download a prebuilt `wavelet-lsp-<platform>` binary from the
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
