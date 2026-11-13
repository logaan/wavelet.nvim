vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd("runtime plugin/wavelet.lua")
local formatter = require("wavelet.format")

local function check(input, expected, width)
  local actual = formatter.lines(vim.split(input, "\n"), width)
  assert(table.concat(actual, "\n") == expected, vim.inspect(actual))
  assert(vim.deep_equal(formatter.lines(actual, width), actual), "Formatting must be idempotent")
end

check("{} [] Fn {x: u16} x", "{} [] Fn {x: u16} x")
check("{ a: 1 bb: 2}", "{ a:  1\n  bb: 2}", 10)
check("{\n  a: 1 bb: 2\n}", "{\n  a:  1\n  bb: 2\n}")
check("{a: 1 bb: 2}", "{a: 1 bb: 2}")
check("{a: 1 bb: 2}", "{a:  1\n bb: 2}", 10)
check("DefType output {state: list(u8) events: list(key-event) actions: list(action) wake-at-ms: option(u32)}",
  "DefType output {state:      list(u8)\n                events:     list(key-event)\n                actions:    list(action)\n                wake-at-ms: option(u32)}")
check("  {a: 1\n   longer: 2}", "  {a:      1\n   longer: 2}")
check('{a: "escaped \\\" {fake: 1 other: 2}" bb: 3}',
  '{a:  "escaped \\\" {fake: 1 other: 2}"\n bb: 3}', 30)
check("// {a: 1 bb: 2}\n#! ignored", "// {a: 1 bb: 2}\n#! ignored", 10)
check("{a: '{' bb: '}'}", "{a:  '{'\n bb: '}'}", 10)
check("{outer: {x: 1 longer: 2} z: 3}",
  "{outer: {x:      1\n         longer: 2}\n z:     3}", 15)
check("{a: 1 // keep this comment\n bb: 2}", "{a:  1 // keep this comment\n bb: 2}")
check("{a: // value comment\n 1 bb: 2}", "{a: // value comment\n 1\n bb: 2}")

local path = vim.fn.tempname() .. ".wlt"
vim.cmd.edit(path)
vim.bo.filetype = "wavelet"
local original = { "{a: 1", " longer: 2}" }
vim.api.nvim_buf_set_lines(0, 0, -1, false, original)
vim.cmd.write()
assert(vim.deep_equal(vim.fn.readfile(path), { "{a:      1", " longer: 2}" }))
vim.g.wavelet_format_on_save = false
vim.api.nvim_buf_set_lines(0, 0, -1, false, original)
vim.cmd.write()
assert(vim.deep_equal(vim.fn.readfile(path), original))
vim.cmd.WaveletFormat()
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "{a:      1", " longer: 2}" }))
vim.fn.delete(path)
print("Wavelet formatting checks passed")
