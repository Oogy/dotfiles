require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Register which-key group for insert commands
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  wk.add({
    { "<leader>i", group = "insert" },
    { "<leader>t", group = "task" },
  })
end

-- Bounding box helpers
local function dash_line(len)
  return string.rep("-", len)
end

local function with_border(text)
  return text .. " |"
end

local DAY_SEP_WIDTH = 63

local function get_date_str()
  local date_str = os.date("%a-%d-%m-%Y")
  date_str = date_str:gsub("%-0(%d)%-", "-%1-")
  return date_str
end

local function get_time_str()
  return os.date("%H:%M:%S") .. " EST"
end

-- Insert current date with bounding box
map("n", "<leader>id", function()
  local line = with_border(get_date_str())
  vim.api.nvim_put({line, dash_line(#line)}, "l", true, true)
end, { desc = "insert date" })

-- Insert current time with bounding box
map("n", "<leader>iT", function()
  local line = with_border(get_time_str())
  vim.api.nvim_put({line, dash_line(#line)}, "l", true, true)
end, { desc = "insert time (EST)" })

-- Insert new Day (day separators + date box + time box)
map("n", "<leader>iD", function()
  local date_line = with_border(get_date_str())
  local time_line = with_border(get_time_str())
  local sep = dash_line(DAY_SEP_WIDTH)

  local cur_row = vim.api.nvim_win_get_cursor(0)[1]
  local cur_line = vim.api.nvim_buf_get_lines(0, cur_row - 1, cur_row, false)[1]
  local on_sep = cur_line == sep

  -- Remove blank line above day separator
  if on_sep and cur_row >= 2 then
    local above = vim.api.nvim_buf_get_lines(0, cur_row - 2, cur_row - 1, false)[1]
    if above == "" then
      vim.api.nvim_buf_set_lines(0, cur_row - 2, cur_row - 1, false, {})
      cur_row = cur_row - 1
      vim.api.nvim_win_set_cursor(0, {cur_row, 0})
    end
  end

  -- When on a separator, reuse it as the top boundary; otherwise insert full block
  local lines = {}
  if not on_sep then
    table.insert(lines, sep)
  end
  vim.list_extend(lines, {
    date_line,
    dash_line(#date_line),
    time_line,
    dash_line(#time_line),
    "",
    sep,
  })
  vim.api.nvim_put(lines, "l", true, true)

  -- Position cursor on the blank line between content and closing separator
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, {row - 1, 0})
end, { desc = "insert new Day" })

-- Insert section header with bounding box
map("n", "<leader>is", function()
  vim.ui.input({ prompt = "Section header: " }, function(input)
    if input and input ~= "" then
      local line = with_border(input)
      local border = dash_line(#line)
      vim.api.nvim_put({"", border, line, border, ""}, "l", true, true)
    end
  end)
end, { desc = "insert section header" })

-- Insert a task checkbox, leave cursor in insert mode after it
map("n", "<leader>it", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, {"", "- [ ] "})
  vim.api.nvim_win_set_cursor(0, {row + 2, #("- [ ]")})
  vim.cmd("startinsert")
end, { desc = "insert task" })

-- Toggle task completion on current line
map("n", "<leader>tx", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local new_line = line:gsub("%- %[ %]", "- [x]")
  if new_line == line then
    new_line = line:gsub("%- %[x%]", "- [ ]")
  end
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
end, { desc = "toggle task complete" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
