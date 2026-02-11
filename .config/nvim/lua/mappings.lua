require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Insert current date (format: Day-dd-M-YYYY, e.g., Tue-11-2-2026)
map("n", "<leader>id", function()
  local date_str = os.date("%a-%d-%m-%Y")
  -- Remove leading zero from month
  date_str = date_str:gsub("%-0(%d)%-", "-%1-")
  vim.api.nvim_put({date_str}, "c", true, true)
end, { desc = "Insert current date" })

-- Insert current time in 24H format with EST timezone
map("n", "<leader>it", function()
  local time_str = os.date("%H:%M:%S") .. " EST"
  vim.api.nvim_put({time_str}, "c", true, true)
end, { desc = "Insert current time (EST)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
