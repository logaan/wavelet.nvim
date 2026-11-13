local M = {}

local function scan(text)
  local tokens, maps, stack = {}, {}, {}
  local i = 1
  while i <= #text do
    local c = text:sub(i, i)
    if c:match("%s") then
      i = i + 1
    elseif text:sub(i, i + 1) == "//" or (i == 1 and text:sub(i, i + 1) == "#!") then
      i = text:find("\n", i, true) or (#text + 1)
    else
      local start = i
      if c == '"' or c == "'" then
        i = i + 1
        while i <= #text do
          local next_char = text:sub(i, i)
          i = i + 1
          if next_char == "\\" then
            i = i + 1
          elseif next_char == c then
            break
          end
        end
      else
        local key = text:sub(i):match("^[%a_][%w_/%-]*:")
        if key then
          i = i + #key
        elseif c:match("[{}%[%]()]") then
          i = i + 1
        else
          i = i + 1
          while i <= #text and not text:sub(i, i):match("[%s{}%[%]()\"']") do
            if text:sub(i, i + 1) == "//" then
              break
            end
            i = i + 1
          end
        end
      end
      local token = { start = start, finish = i - 1, value = text:sub(start, i - 1) }
      tokens[#tokens + 1] = token
      local value = token.value
      if value == "{" or value == "[" or value == "(" then
        stack[#stack + 1] = { open = token, keys = {}, kind = value }
      elseif value == "}" or value == "]" or value == ")" then
        local frame = table.remove(stack)
        if frame and frame.kind == "{" and value == "}" then
          frame.close = token
          maps[#maps + 1] = frame
        end
      elseif stack[#stack] and stack[#stack].kind == "{" and value:match("^[%a_][%w_/%-]*:$") then
        local keys = stack[#stack].keys
        keys[#keys + 1] = #tokens
      end
    end
  end
  return tokens, maps
end

local function pass(text, width)
  local tokens, maps = scan(text)
  local edits = {}
  for _, map in ipairs(maps) do
    local body = text:sub(map.open.start, map.close.finish)
    local line_start = text:sub(1, map.open.start - 1):match(".*\n()") or 1
    local column = vim.fn.strdisplaywidth(text:sub(line_start, map.open.start))
    if #map.keys > 1 and (body:find("\n", 1, true) or column - 1 + vim.fn.strdisplaywidth(body) > width) then
      local first = tokens[map.keys[1]].start
      local key_line_start = text:sub(1, first - 1):match(".*\n()") or 1
      local indent = vim.fn.strdisplaywidth(text:sub(key_line_start, first - 1))
      local longest = 0
      for _, index in ipairs(map.keys) do
        longest = math.max(longest, #tokens[index].value)
      end
      for n, index in ipairs(map.keys) do
        local key = tokens[index]
        local value = tokens[index + 1]
        if value and text:sub(key.finish + 1, value.start - 1):match("^%s*$") then
          edits[#edits + 1] = { key.finish + 1, value.start - 1, string.rep(" ", longest - #key.value + 1) }
        end
        if n > 1 then
          local previous = tokens[index - 1]
          if text:sub(previous.finish + 1, key.start - 1):match("^%s*$") then
            edits[#edits + 1] = { previous.finish + 1, key.start - 1, "\n" .. string.rep(" ", indent) }
          end
        end
      end
    end
  end
  table.sort(edits, function(a, b) return a[1] > b[1] end)
  for _, edit in ipairs(edits) do
    text = text:sub(1, edit[1] - 1) .. edit[3] .. text:sub(edit[2] + 1)
  end
  return text
end

function M.lines(lines, width)
  local text = table.concat(lines, "\n")
  for _ = 1, 20 do
    local formatted = pass(text, width or 80)
    if formatted == text then
      break
    end
    text = formatted
  end
  return vim.split(text, "\n", { plain = true })
end

function M.buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.bo[buf].modifiable then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local formatted = M.lines(lines, vim.g.wavelet_format_width or 80)
  if not vim.deep_equal(lines, formatted) then
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
    vim.fn.winrestview(view)
  end
end

return M
