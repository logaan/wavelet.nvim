-- Start the Wavelet language server (wavelet-lsp) for `.wlt` buffers in Neovim.
--
-- Neovim only: classic Vim has no built-in LSP client, so this is a no-op there
-- and you still get syntax highlighting from syntax/wavelet.vim.
--
-- The server binary is located, in order:
--   1. g:wavelet_lsp_path, if set;
--   2. `wavelet-lsp` on the PATH.
-- If neither is found, this is a silent no-op (you keep highlighting). Install
-- the server from the Wavelet repo (`cargo install --path tooling/wavelet-lsp`),
-- or download a prebuilt `wavelet-lsp-<platform>` binary from the Wavelet
-- releases page onto your PATH.

if vim.fn.has("nvim-0.8") == 0 then
  return
end

local function server_cmd()
  if vim.g.wavelet_lsp_path and vim.g.wavelet_lsp_path ~= "" then
    return vim.g.wavelet_lsp_path
  end
  local on_path = vim.fn.exepath("wavelet-lsp")
  if on_path ~= "" then
    return on_path
  end
  return nil
end

local function start(buf)
  local cmd = server_cmd()
  if not cmd then
    return
  end
  vim.lsp.start({
    name = "wavelet-lsp",
    cmd = { cmd },
    root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "wavelet",
  callback = function(args)
    start(args.buf)
  end,
})

-- If this plugin is loaded lazily (e.g. on the `wavelet` filetype), the buffer
-- that triggered the load may already have passed its FileType event, so start
-- the server for any wavelet buffers that are already open.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "wavelet" then
    start(buf)
  end
end
