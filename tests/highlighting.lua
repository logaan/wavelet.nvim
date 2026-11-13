vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd("filetype on")
vim.cmd("syntax on")
vim.cmd("edit wavelet-highlighting-check.wlt")
assert(vim.bo.filetype == "wavelet", "Expected .wlt filetype detection")

local cases = {
  { "#!/usr/bin/env wavelet", "#!", "waveletShebang" },
  { "value.increment()", ".", "waveletPunctuation" },
  { "value.increment()", "increment", "waveletCallHead" },
  { "1.25", ".", "waveletNumber" },
  { "service/cache/get()", "service/cache/get", "waveletCallHead" },
  { "lib/Identity()", "lib/Identity", "waveletMacro" },
  { "lib-Identity()", "lib-Identity", "waveletMacro" },
  { "result(_ string)", "_", "waveletPlaceholder" },
}

local lines = {}
for _, case in ipairs(cases) do
  lines[#lines + 1] = case[1]
end
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.cmd("syntax sync fromstart")

for line, case in ipairs(cases) do
  local column = assert(case[1]:find(case[2], 1, true))
  local group = vim.fn.synIDattr(vim.fn.synID(line, column, 1), "name")
  assert(group == case[3], case[1] .. ": expected " .. case[3] .. ", got " .. group)
end

print("Wavelet highlighting checks passed")
