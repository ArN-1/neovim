-- lua/autopairs.lua
local autopairs = require("nvim-autopairs")

autopairs.setup({
  check_ts = true, -- enable treesitter integration
  disable_filetype = { "TelescopePrompt", "spectre_panel" },
})

-- Integrasi dengan nvim-cmp
local cmp_status, cmp = pcall(require, "cmp")
if cmp_status then
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
