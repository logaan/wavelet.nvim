if vim.fn.has("nvim-0.8") == 0 then
  return
end

vim.api.nvim_create_user_command("WaveletFormat", function()
  require("wavelet.format").buffer()
end, {})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "wavelet" and vim.g.wavelet_format_on_save ~= false then
      require("wavelet.format").buffer(args.buf)
    end
  end,
})

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

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "wavelet" then
    start(buf)
  end
end
