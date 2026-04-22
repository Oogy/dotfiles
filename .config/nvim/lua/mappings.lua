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
map("n", "<leader>it", function()
  local line = with_border(get_time_str())
  vim.api.nvim_put({line, dash_line(#line)}, "l", true, true)
end, { desc = "insert time (EST)" })

-- Insert new Day (day separators + date box + time box)
map("n", "<leader>iD", function()
  local date_line = with_border(get_date_str())
  local time_line = with_border(get_time_str())
  local lines = {
    dash_line(DAY_SEP_WIDTH),
    date_line,
    dash_line(#date_line),
    time_line,
    dash_line(#time_line),
    "",
    dash_line(DAY_SEP_WIDTH),
  }
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

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
