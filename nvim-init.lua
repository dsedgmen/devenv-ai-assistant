-- devenv-ai-assistant — Neovim AI keymaps (calls devenv-ai-helper)
-- Optional LSP/Treesitter/flowchart modules come from devenv-lsp-setup.

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.g.mapleader = " "

-- Prefer devenv-ai-helper (RPM/PATH), then vim-ai-helper compat, then ~/.local/bin
local ai_helper = "devenv-ai-helper"
if vim.fn.executable(ai_helper) == 0 then
  if vim.fn.executable("vim-ai-helper") == 1 then
    ai_helper = "vim-ai-helper"
  else
    local local_helper = vim.fn.expand("~/.local/bin/devenv-ai-helper")
    if vim.fn.executable(local_helper) == 1 then
      ai_helper = local_helper
    else
      local_helper = vim.fn.expand("~/.local/bin/vim-ai-helper")
      if vim.fn.executable(local_helper) == 1 then
        ai_helper = local_helper
      end
    end
  end
end

-- Monitoring / logging
local log_buffer = nil
local log_window = nil
local log_enabled = (vim.env.DEVENV_AI_LOGGING or vim.env.VIM_AI_LOGGING) ~= "0"
local log_file = vim.fn.expand("~/.cache/devenv-ai-activity.log")
vim.fn.mkdir(vim.fn.expand("~/.cache"), "p")

local function log_activity(message)
  if not log_enabled then
    return
  end
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local log_entry = string.format("[%s] %s", timestamp, message)
  local f = io.open(log_file, "a")
  if f then
    f:write(log_entry .. "\n")
    f:close()
  end
  if log_buffer and vim.api.nvim_buf_is_valid(log_buffer) then
    local lines = vim.api.nvim_buf_get_lines(log_buffer, 0, -1, false)
    table.insert(lines, log_entry)
    vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, lines)
    if log_window and vim.api.nvim_win_is_valid(log_window) then
      vim.api.nvim_win_set_cursor(log_window, { #lines, 0 })
    end
  end
end

local function toggle_monitor()
  if log_window and vim.api.nvim_win_is_valid(log_window) then
    vim.api.nvim_win_close(log_window, true)
    log_window = nil
    log_activity("Monitor panel closed")
    print("AI Monitor closed")
    return
  end
  log_activity("Monitor panel opened")
  if not log_buffer or not vim.api.nvim_buf_is_valid(log_buffer) then
    log_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(log_buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(log_buffer, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(log_buffer, "swapfile", false)
    vim.api.nvim_buf_set_name(log_buffer, "AI Activity Monitor")
    local f = io.open(log_file, "r")
    if f then
      local lines = {}
      for line in f:lines() do
        table.insert(lines, line)
      end
      f:close()
      vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, lines)
    else
      local status = log_enabled and "ENABLED" or "DISABLED (press <Space>al to enable)"
      vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
        "=== AI Activity Monitor ===",
        "Logging status: " .. status,
        "",
      })
    end
  end
  vim.cmd("botright vsplit")
  log_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(log_window, log_buffer)
  vim.api.nvim_win_set_width(log_window, 60)
  vim.api.nvim_win_set_option(log_window, "wrap", true)
  vim.api.nvim_win_set_option(log_window, "number", false)
  print("AI Monitor opened")
end

local function clear_monitor()
  local f = io.open(log_file, "w")
  if f then
    f:write("")
    f:close()
  end
  if log_buffer and vim.api.nvim_buf_is_valid(log_buffer) then
    vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
      "=== AI Activity Monitor ===",
      "Log cleared at " .. os.date("%Y-%m-%d %H:%M:%S"),
      "",
    })
  end
  print("AI Monitor log cleared")
end

local function toggle_logging()
  log_enabled = not log_enabled
  local status = log_enabled and "enabled" or "disabled"
  log_activity("Logging " .. status)
  print("AI activity logging " .. status)
end

local function get_language()
  return vim.bo.filetype or ""
end

local function get_backend()
  return vim.env.VIM_AI_BACKEND or "ollama"
end

local function switch_backend()
  local current = get_backend()
  local new_backend
  if current == "ollama" then
    new_backend = "claude"
  elseif current == "claude" then
    new_backend = "gemini"
  else
    new_backend = "ollama"
  end
  vim.env.VIM_AI_BACKEND = new_backend
  log_activity("Backend switched: " .. current .. " -> " .. new_backend)
  print("Switched AI backend to: " .. new_backend)
end

-- Async helper: run devenv-ai-helper without freezing Neovim
local function run_ai_async(argv, on_done)
  local start_time = os.time()
  log_activity("Async: " .. table.concat(argv, " "))
  print("AI running (async)...")

  if not vim.system then
    -- Fallback for older Neovim
    local cmd = ai_helper .. " " .. table.concat(argv, " ")
    local output = vim.fn.systemlist(cmd)
    on_done(output, vim.v.shell_error, os.time() - start_time)
    return
  end

  local full_argv = { ai_helper }
  for _, a in ipairs(argv) do
    table.insert(full_argv, a)
  end

  vim.system(full_argv, { text = true }, function(obj)
    vim.schedule(function()
      local out = obj.stdout or ""
      local lines = {}
      if out ~= "" then
        for line in out:gmatch("[^\n]+") do
          table.insert(lines, line)
        end
        -- preserve trailing empty lines behavior of systemlist roughly
        if out:sub(-1) == "\n" and #lines > 0 then
          -- ok
        end
      end
      if (not lines or #lines == 0) and obj.stderr and obj.stderr ~= "" then
        for line in obj.stderr:gmatch("[^\n]+") do
          table.insert(lines, line)
        end
      end
      on_done(lines, obj.code or 0, os.time() - start_time)
    end)
  end)
end

local function open_output_split(lines, lang, title)
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  pcall(vim.api.nvim_buf_set_name, buf, title or string.format("AI Response [%s]", os.date("%H:%M:%S")))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  if lang and lang ~= "" then
    vim.api.nvim_buf_set_option(buf, "filetype", lang)
  end
  return buf
end

local function run_ai_command(argv)
  local backend = get_backend()
  local lang = get_language()
  run_ai_async(argv, function(output, code, duration)
    log_activity(string.format("Completed code=%s in %ss, lines=%d", tostring(code), duration, #output))
    open_output_split(output, lang)
  end)
end

-- Preview / apply state (completion, refactor, generate)
local apply_preview = {
  buffer = nil,
  window = nil,
  lines = nil,
  mode = nil, -- insert | replace
  target_buf = nil,
  start_row = nil, -- 0-indexed
  end_row = nil, -- exclusive 0-indexed
}

local function close_apply_preview()
  if apply_preview.window and vim.api.nvim_win_is_valid(apply_preview.window) then
    vim.api.nvim_win_close(apply_preview.window, true)
  end
  apply_preview.window = nil
end

function _G.ai_accept_apply()
  if not apply_preview.lines or not apply_preview.target_buf then
    print("Nothing to apply")
    return
  end
  close_apply_preview()
  local buf = apply_preview.target_buf
  if not vim.api.nvim_buf_is_valid(buf) then
    print("Original buffer gone")
    return
  end
  if apply_preview.mode == "replace" then
    vim.api.nvim_buf_set_lines(buf, apply_preview.start_row, apply_preview.end_row, false, apply_preview.lines)
  else
    vim.api.nvim_buf_set_lines(buf, apply_preview.start_row, apply_preview.start_row, false, apply_preview.lines)
  end
  log_activity("Applied " .. #apply_preview.lines .. " lines (" .. apply_preview.mode .. ")")
  print("Applied (" .. #apply_preview.lines .. " lines)")
  apply_preview.lines = nil
end

function _G.ai_reject_apply()
  close_apply_preview()
  log_activity("Apply rejected")
  print("Rejected")
  apply_preview.lines = nil
end

local function show_apply_preview(output, mode, start_row, end_row, lang, backend, duration)
  apply_preview.lines = output
  apply_preview.mode = mode
  apply_preview.target_buf = vim.api.nvim_get_current_buf()
  apply_preview.start_row = start_row
  apply_preview.end_row = end_row or start_row

  if not apply_preview.buffer or not vim.api.nvim_buf_is_valid(apply_preview.buffer) then
    apply_preview.buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(apply_preview.buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(apply_preview.buffer, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(apply_preview.buffer, "swapfile", false)
  end

  local header = {
    "=== AI Apply Preview ===",
    string.format("Backend: %s | Duration: %ss | Lines: %d | Mode: %s", backend, duration, #output, mode),
    "",
    "Press 'a' to ACCEPT | Press 'r' or 'q' to REJECT",
    "",
    "--- Proposed change ---",
  }
  local preview_lines = {}
  for _, h in ipairs(header) do
    table.insert(preview_lines, h)
  end
  for _, line in ipairs(output) do
    table.insert(preview_lines, line)
  end

  vim.api.nvim_buf_set_option(apply_preview.buffer, "modifiable", true)
  vim.api.nvim_buf_set_lines(apply_preview.buffer, 0, -1, false, preview_lines)
  if lang and lang ~= "" then
    vim.api.nvim_buf_set_option(apply_preview.buffer, "filetype", lang)
  end
  vim.api.nvim_buf_set_option(apply_preview.buffer, "modifiable", false)

  vim.cmd("botright split")
  apply_preview.window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(apply_preview.window, apply_preview.buffer)
  vim.api.nvim_win_set_height(apply_preview.window, math.min(18, #preview_lines))

  vim.keymap.set("n", "a", function()
    ai_accept_apply()
  end, { buffer = apply_preview.buffer, silent = true })
  vim.keymap.set("n", "r", function()
    ai_reject_apply()
  end, { buffer = apply_preview.buffer, silent = true })
  vim.keymap.set("n", "q", function()
    ai_reject_apply()
  end, { buffer = apply_preview.buffer, silent = true })

  print("Preview ready | a=accept r=reject")
end

local function ai_complete()
  local tmpfile = vim.fn.tempname()
  vim.cmd("write! " .. tmpfile)
  local lang = get_language()
  local backend = get_backend()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  run_ai_async({ "complete", tmpfile, lang, backend }, function(output, _, duration)
    vim.fn.delete(tmpfile)
    log_activity("Complete done in " .. duration .. "s")
    show_apply_preview(output, "insert", row, row, lang, backend, duration)
  end)
end

local function ai_complete_split()
  local tmpfile = vim.fn.tempname()
  vim.cmd("write! " .. tmpfile)
  local lang = get_language()
  local backend = get_backend()
  run_ai_command({ "complete", tmpfile, lang, backend })
  vim.defer_fn(function()
    vim.fn.delete(tmpfile)
  end, 5000)
end

local function visual_range_0indexed()
  local s = vim.fn.line("'<") - 1
  local e = vim.fn.line("'>")
  return s, e
end

local function ai_fix()
  local tmpfile = vim.fn.tempname()
  vim.cmd("'<,'>write! " .. tmpfile)
  local lang = get_language()
  local backend = get_backend()
  local s, e = visual_range_0indexed()
  run_ai_async({ "refactor", tmpfile, "fix all bugs and errors", lang, backend }, function(output, _, duration)
    vim.fn.delete(tmpfile)
    show_apply_preview(output, "replace", s, e, lang, backend, duration)
  end)
end

local function ai_explain()
  local tmpfile = vim.fn.tempname()
  vim.cmd("'<,'>write! " .. tmpfile)
  local lang = get_language()
  local backend = get_backend()
  run_ai_command({ "explain", tmpfile, lang, backend })
  vim.defer_fn(function()
    vim.fn.delete(tmpfile)
  end, 5000)
end

local function ai_review()
  local tmpfile = vim.fn.tempname()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    vim.cmd("'<,'>write! " .. tmpfile)
  else
    vim.cmd("write! " .. tmpfile)
  end
  local lang = get_language()
  local backend = get_backend()
  run_ai_command({ "review", tmpfile, lang, backend })
  vim.defer_fn(function()
    vim.fn.delete(tmpfile)
  end, 5000)
end

local function ai_refactor()
  local instruction = vim.fn.input("Refactor instruction: ")
  if instruction == "" then
    return
  end
  local tmpfile = vim.fn.tempname()
  vim.cmd("'<,'>write! " .. tmpfile)
  local lang = get_language()
  local backend = get_backend()
  local s, e = visual_range_0indexed()
  run_ai_async({ "refactor", tmpfile, instruction, lang, backend }, function(output, _, duration)
    vim.fn.delete(tmpfile)
    show_apply_preview(output, "replace", s, e, lang, backend, duration)
  end)
end

local function ai_generate()
  local description = vim.fn.input("Code description: ")
  if description == "" then
    return
  end
  local lang = get_language()
  local backend = get_backend()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  run_ai_async({ "generate", description, lang, backend }, function(output, _, duration)
    show_apply_preview(output, "insert", row, row, lang, backend, duration)
  end)
end

-- Chat with real multi-turn history sent to the model
local chat_state = {
  buffer = nil,
  window = nil,
  history = {},
  context_file = nil,
}

local function write_chat_history_file()
  local path = vim.fn.tempname() .. "-ai-history.json"
  local f = io.open(path, "w")
  if not f then
    return nil
  end
  f:write(vim.json.encode(chat_state.history))
  f:close()
  return path
end

local function ai_chat()
  local context = nil
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    local tmpfile = vim.fn.tempname()
    vim.cmd("'<,'>write! " .. tmpfile)
    chat_state.context_file = tmpfile
    local f = io.open(tmpfile, "r")
    if f then
      context = f:read("*all")
      f:close()
    end
  end

  if not chat_state.buffer or not vim.api.nvim_buf_is_valid(chat_state.buffer) then
    chat_state.buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(chat_state.buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(chat_state.buffer, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(chat_state.buffer, "swapfile", false)
    pcall(vim.api.nvim_buf_set_name, chat_state.buffer, "AI Chat")
    chat_state.history = {}

    local welcome = {
      "=== AI Chat Session ===",
      "Backend: " .. get_backend(),
      "",
      "Commands: i=ask  c=clear  q=close",
      "History is sent to the model on each turn.",
      "",
    }
    if context then
      table.insert(welcome, "Context attached from selection.")
      table.insert(welcome, "")
    end
    table.insert(welcome, "Press 'i' to start chatting...")
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, welcome)
  end

  if not chat_state.window or not vim.api.nvim_win_is_valid(chat_state.window) then
    vim.cmd("botright split")
    chat_state.window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(chat_state.window, chat_state.buffer)
    vim.api.nvim_win_set_height(chat_state.window, 20)
  end

  vim.keymap.set("n", "i", function()
    chat_ask_question()
  end, { buffer = chat_state.buffer, silent = true })
  vim.keymap.set("n", "c", function()
    chat_clear()
  end, { buffer = chat_state.buffer, silent = true })
  vim.keymap.set("n", "q", function()
    chat_close()
  end, { buffer = chat_state.buffer, silent = true })

  log_activity("Chat session opened")
  print("Chat ready | i=ask c=clear q=quit")
end

function _G.chat_ask_question()
  local question = vim.fn.input("Your question: ")
  if question == "" then
    return
  end

  local backend = get_backend()
  log_activity("Chat question: " .. question)

  local lines = vim.api.nvim_buf_get_lines(chat_state.buffer, 0, -1, false)
  table.insert(lines, "")
  table.insert(lines, "[You] " .. question)
  table.insert(lines, "[AI] Thinking...")
  vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, lines)

  local hist_file = write_chat_history_file()
  local argv = { "chat", "--history", hist_file, question }
  if chat_state.context_file then
    table.insert(argv, chat_state.context_file)
  end
  table.insert(argv, backend)

  run_ai_async(argv, function(output, _, _)
    if hist_file then
      vim.fn.delete(hist_file)
    end
    lines = vim.api.nvim_buf_get_lines(chat_state.buffer, 0, -1, false)
    -- remove thinking line
    if lines[#lines] and lines[#lines]:match("%[AI%] Thinking") then
      table.remove(lines)
    end
    table.insert(lines, "[AI]")
    for _, line in ipairs(output) do
      table.insert(lines, "  " .. line)
    end
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, lines)
    local line_count = vim.api.nvim_buf_line_count(chat_state.buffer)
    if chat_state.window and vim.api.nvim_win_is_valid(chat_state.window) then
      vim.api.nvim_win_set_cursor(chat_state.window, { line_count, 0 })
    end

    table.insert(chat_state.history, { role = "user", content = question })
    table.insert(chat_state.history, { role = "assistant", content = table.concat(output, "\n") })
    log_activity("Chat response (" .. #output .. " lines), history=" .. #chat_state.history)
    print("Response ready | Press 'i' for follow-up")
  end)
end

function _G.chat_clear()
  chat_state.history = {}
  vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, {
    "=== AI Chat Session ===",
    "Backend: " .. get_backend(),
    "",
    "Chat history cleared.",
    "",
    "Press 'i' to start chatting...",
    "",
  })
  log_activity("Chat history cleared")
  print("Chat history cleared")
end

function _G.chat_close()
  if chat_state.window and vim.api.nvim_win_is_valid(chat_state.window) then
    vim.api.nvim_win_close(chat_state.window, true)
    chat_state.window = nil
  end
  if chat_state.context_file then
    vim.fn.delete(chat_state.context_file)
    chat_state.context_file = nil
  end
  log_activity("Chat session closed")
  print("Chat session closed")
end

-- Keymaps
vim.keymap.set("n", "<Leader>ac", ai_complete, { desc = "AI Complete (preview/accept)" })
vim.keymap.set("n", "<Leader>as", ai_complete_split, { desc = "AI Complete (split)" })
vim.keymap.set("n", "<Leader>ar", ai_review, { desc = "AI Review" })
vim.keymap.set("n", "<Leader>ag", ai_generate, { desc = "AI Generate (preview/accept)" })
vim.keymap.set("n", "<Leader>aq", ai_chat, { desc = "AI Chat (multi-turn)" })
vim.keymap.set("n", "<Leader>ab", switch_backend, { desc = "AI Switch backend" })
vim.keymap.set("n", "<Leader>am", toggle_monitor, { desc = "AI Monitor" })
vim.keymap.set("n", "<Leader>al", toggle_logging, { desc = "AI Toggle logging" })

vim.keymap.set("v", "<Leader>ae", ai_explain, { desc = "AI Explain" })
vim.keymap.set("v", "<Leader>ar", ai_review, { desc = "AI Review selection" })
vim.keymap.set("v", "<Leader>af", ai_refactor, { desc = "AI Refactor (preview/accept)" })
vim.keymap.set("v", "<Leader>ax", ai_fix, { desc = "AI Fix (preview/accept)" })
vim.keymap.set("v", "<Leader>aq", ai_chat, { desc = "AI Chat about selection" })

vim.api.nvim_create_user_command("AIComplete", ai_complete, {})
vim.api.nvim_create_user_command("AICompleteSplit", ai_complete_split, {})
vim.api.nvim_create_user_command("AIExplain", ai_explain, { range = true })
vim.api.nvim_create_user_command("AIReview", ai_review, { range = true })
vim.api.nvim_create_user_command("AIRefactor", ai_refactor, { range = true })
vim.api.nvim_create_user_command("AIFix", ai_fix, { range = true })
vim.api.nvim_create_user_command("AIGenerate", ai_generate, {})
vim.api.nvim_create_user_command("AIChat", ai_chat, { range = true })
vim.api.nvim_create_user_command("AISwitchBackend", switch_backend, {})
vim.api.nvim_create_user_command("AIMonitor", toggle_monitor, {})
vim.api.nvim_create_user_command("AIMonitorClear", clear_monitor, {})
vim.api.nvim_create_user_command("AILogging", toggle_logging, {})

vim.opt.statusline = "%f %h%m%r%=%{luaeval('(vim.env.DEVENV_AI_BACKEND or vim.env.VIM_AI_BACKEND) or \"ollama\"')} | %l,%c %P"

-- Optional modules from devenv-lsp-setup / install-nvim-plugins.sh (soft-require)
pcall(require, "plugins-config")
pcall(require, "lsp-config")
pcall(require, "treesitter-config")
local flow_ok, flow = pcall(require, "code-flowchart")
if flow_ok and flow and flow.setup then
  flow.setup()
end

print("devenv-ai-assistant loaded (Leader = Space)")
print("  AI: <Space>ac complete | <Space>aq chat | <Space>ag generate | <Space>ab backend | <Space>am monitor")
print("  Visual: <Space>ae explain | <Space>af refactor | <Space>ax fix")
if flow_ok then
  print("  Flowchart: <Space>mf Mermaid | <Space>mF ASCII (devenv-lsp-setup)")
end
if log_enabled then
  log_activity("AI Assistant initialized")
end
