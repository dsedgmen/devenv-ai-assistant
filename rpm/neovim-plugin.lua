-- Packpath loader for devenv-ai-assistant-neovim RPM.
-- Does not replace ~/.config/nvim/init.lua.
local conf = "/usr/share/devenv-ai-assistant/nvim-init.lua"
local ok, err = pcall(dofile, conf)
if not ok then
  vim.notify("devenv-ai-assistant: failed to load " .. conf .. ": " .. tostring(err), vim.log.levels.ERROR)
end
