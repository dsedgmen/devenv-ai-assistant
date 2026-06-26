-- Neovim AI Coding Assistant Configuration
-- Supports both Ollama (Granite) and Claude API

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- AI Helper Configuration
local ai_helper = vim.fn.expand("~/.local/bin/vim-ai-helper")

-- Monitoring/Logging state
local log_buffer = nil
local log_window = nil
-- Check environment variable for auto-enable, default to true for convenience
local log_enabled = vim.env.VIM_AI_LOGGING ~= "0"  -- Set VIM_AI_LOGGING=0 to disable by default
local log_file = vim.fn.expand("~/.cache/vim-ai-activity.log")

-- Ensure log directory exists
vim.fn.mkdir(vim.fn.expand("~/.cache"), "p")

-- Log activity to file and buffer
local function log_activity(message)
    if not log_enabled then return end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local log_entry = string.format("[%s] %s", timestamp, message)

    -- Write to file
    local f = io.open(log_file, "a")
    if f then
        f:write(log_entry .. "\n")
        f:close()
    end

    -- Update buffer if visible
    if log_buffer and vim.api.nvim_buf_is_valid(log_buffer) then
        local lines = vim.api.nvim_buf_get_lines(log_buffer, 0, -1, false)
        table.insert(lines, log_entry)
        vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, lines)

        -- Auto-scroll to bottom if window is visible
        if log_window and vim.api.nvim_win_is_valid(log_window) then
            vim.api.nvim_win_set_cursor(log_window, {#lines, 0})
        end
    end
end

-- Toggle monitoring panel
local function toggle_monitor()
    if log_window and vim.api.nvim_win_is_valid(log_window) then
        -- Close the monitor
        vim.api.nvim_win_close(log_window, true)
        log_window = nil
        log_activity("Monitor panel closed")
        print("AI Monitor closed")
    else
        log_activity("Monitor panel opened")
        -- Open the monitor
        -- Create buffer if it doesn't exist
        if not log_buffer or not vim.api.nvim_buf_is_valid(log_buffer) then
            log_buffer = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(log_buffer, 'buftype', 'nofile')
            vim.api.nvim_buf_set_option(log_buffer, 'bufhidden', 'hide')
            vim.api.nvim_buf_set_option(log_buffer, 'swapfile', false)
            vim.api.nvim_buf_set_name(log_buffer, 'AI Activity Monitor')

            -- Load existing log file
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
                    "Tracking all AI assistant operations",
                    "Logging status: " .. status,
                    "",
                    "Commands:",
                    "  :AILogging (<Space>al)    - Toggle logging on/off",
                    "  :AIMonitorClear           - Clear this log",
                    "  :AIMonitor (<Space>am)    - Toggle this panel",
                    ""
                })
            end
        end

        -- Create vertical split on the right
        vim.cmd("botright vsplit")
        log_window = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(log_window, log_buffer)
        vim.api.nvim_win_set_width(log_window, 60)

        -- Set window options
        vim.api.nvim_win_set_option(log_window, 'wrap', true)
        vim.api.nvim_win_set_option(log_window, 'number', false)
        vim.api.nvim_win_set_option(log_window, 'relativenumber', false)

        -- Syntax highlighting
        vim.api.nvim_buf_set_option(log_buffer, 'filetype', 'log')

        local status = log_enabled and "Logging: ON" or "Logging: OFF (press <Space>al to enable)"
        print("AI Monitor opened | " .. status)
    end
end

-- Clear monitor log
local function clear_monitor()
    -- Clear file
    local f = io.open(log_file, "w")
    if f then
        f:write("")
        f:close()
    end

    -- Clear buffer
    if log_buffer and vim.api.nvim_buf_is_valid(log_buffer) then
        vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
            "=== AI Activity Monitor ===",
            "Log cleared at " .. os.date("%Y-%m-%d %H:%M:%S"),
            ""
        })
    end

    print("AI Monitor log cleared")
end

-- Enable/disable logging
local function toggle_logging()
    log_enabled = not log_enabled
    local status = log_enabled and "enabled" or "disabled"
    log_activity("Logging " .. status)
    print("AI activity logging " .. status)
end

-- Get current filetype as language
local function get_language()
    return vim.bo.filetype or ""
end

-- Get current backend from environment or default
local function get_backend()
    return vim.env.VIM_AI_BACKEND or "ollama"
end

-- Switch between Ollama and Claude
local function switch_backend()
    local current = get_backend()
    local new_backend = current == "ollama" and "claude" or "ollama"
    vim.env.VIM_AI_BACKEND = new_backend
    log_activity("Backend switched: " .. current .. " -> " .. new_backend)
    print("Switched AI backend to: " .. new_backend)
end

-- Execute AI command and show results in split window
local function run_ai_command(args)
    local cmd = ai_helper .. " " .. args
    local backend = get_backend()

    log_activity("Executing: " .. args .. " [backend=" .. backend .. "]")

    -- Create a new split for output
    vim.cmd("botright new")
    local buf = vim.api.nvim_get_current_buf()

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)

    -- Use unique buffer name with timestamp
    local buf_name = string.format('AI Response [%s]', os.date('%H:%M:%S'))
    vim.api.nvim_buf_set_name(buf, buf_name)

    -- Run command and capture output
    local start_time = os.time()
    local output = vim.fn.systemlist(cmd)
    local duration = os.time() - start_time

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

    -- Set syntax highlighting
    vim.api.nvim_buf_set_option(buf, 'filetype', get_language())

    log_activity("Completed in " .. duration .. "s, output lines: " .. #output)
end

-- AI Complete - show preview with accept/reject options
local completion_preview = {
    buffer = nil,
    window = nil,
    lines = nil,
    insert_row = nil
}

local function ai_complete()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()

    log_activity("AI Complete (preview): lang=" .. lang .. ", backend=" .. backend)

    local cmd = ai_helper .. " complete " .. tmpfile .. " " .. lang .. " " .. backend
    local start_time = os.time()
    local output = vim.fn.systemlist(cmd)
    local duration = os.time() - start_time
    vim.fn.delete(tmpfile)

    log_activity("Completed in " .. duration .. "s, generated " .. #output .. " lines")

    -- Store completion data
    completion_preview.lines = output
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    completion_preview.insert_row = row

    -- Create preview buffer if needed
    if not completion_preview.buffer or not vim.api.nvim_buf_is_valid(completion_preview.buffer) then
        completion_preview.buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(completion_preview.buffer, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(completion_preview.buffer, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(completion_preview.buffer, 'swapfile', false)
    end

    -- Set preview content with header
    local preview_lines = {
        "=== AI Completion Preview ===",
        "Backend: " .. backend .. " | Duration: " .. duration .. "s | Lines: " .. #output,
        "",
        "Press 'a' to ACCEPT and insert | Press 'r' to REJECT and close",
        "",
        "--- Completion starts below ---",
    }
    for _, line in ipairs(output) do
        table.insert(preview_lines, line)
    end

    vim.api.nvim_buf_set_lines(completion_preview.buffer, 0, -1, false, preview_lines)
    vim.api.nvim_buf_set_option(completion_preview.buffer, 'filetype', lang)
    vim.api.nvim_buf_set_option(completion_preview.buffer, 'modifiable', false)

    -- Open in split
    vim.cmd("botright split")
    completion_preview.window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(completion_preview.window, completion_preview.buffer)
    vim.api.nvim_win_set_height(completion_preview.window, math.min(15, #preview_lines))

    -- Set up keybindings for accept/reject
    vim.api.nvim_buf_set_keymap(completion_preview.buffer, 'n', 'a', ':lua accept_completion()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(completion_preview.buffer, 'n', 'r', ':lua reject_completion()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(completion_preview.buffer, 'n', 'q', ':lua reject_completion()<CR>',
        { noremap = true, silent = true })

    print("Preview ready | Press 'a' to accept, 'r' to reject")
end

-- Accept completion and insert into original buffer
function accept_completion()
    if not completion_preview.lines then
        print("No completion to accept")
        return
    end

    -- Close preview window
    if completion_preview.window and vim.api.nvim_win_is_valid(completion_preview.window) then
        vim.api.nvim_win_close(completion_preview.window, true)
    end

    -- Switch back to original window and insert
    vim.cmd("wincmd p")
    vim.api.nvim_buf_set_lines(0, completion_preview.insert_row, completion_preview.insert_row,
        false, completion_preview.lines)

    log_activity("Completion accepted, inserted " .. #completion_preview.lines .. " lines")
    print("Completion inserted (" .. #completion_preview.lines .. " lines)")

    -- Clear preview
    completion_preview.lines = nil
    completion_preview.insert_row = nil
end

-- Reject completion and close preview
function reject_completion()
    if completion_preview.window and vim.api.nvim_win_is_valid(completion_preview.window) then
        vim.api.nvim_win_close(completion_preview.window, true)
    end

    log_activity("Completion rejected")
    print("Completion rejected")

    -- Clear preview
    completion_preview.lines = nil
    completion_preview.insert_row = nil
end

-- AI Complete in split (for review before inserting)
local function ai_complete_split()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()
    run_ai_command("complete " .. tmpfile .. " " .. lang .. " " .. backend)
    vim.fn.delete(tmpfile)
end

-- AI Fix - fix/replace selected code
local function ai_fix()
    -- Must be in visual mode
    local mode = vim.fn.mode()
    if mode ~= 'v' and mode ~= 'V' then
        print("AI Fix requires visual selection - select code to fix")
        return
    end

    local tmpfile = vim.fn.tempname()
    vim.cmd("'<,'>write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()

    log_activity("AI Fix: lang=" .. lang .. ", backend=" .. backend)

    -- Read the buggy code
    local f = io.open(tmpfile, "r")
    local buggy_code = f:read("*all")
    f:close()

    -- Get AI to fix it (using refactor command with "fix bugs and errors" instruction)
    local cmd = ai_helper .. " refactor " .. tmpfile .. " 'fix all bugs and errors' " .. lang .. " " .. backend
    local start_time = os.time()
    local output = vim.fn.systemlist(cmd)
    local duration = os.time() - start_time
    vim.fn.delete(tmpfile)

    log_activity("Fix completed in " .. duration .. "s, generated " .. #output .. " lines")

    -- Replace selected lines with fixed code
    vim.cmd("'<,'>delete")
    local row = vim.fn.line("'<") - 1
    vim.api.nvim_buf_set_lines(0, row, row, false, output)

    print("Code fixed and replaced (" .. #output .. " lines)")
end

-- AI Explain - explain selected code
local function ai_explain()
    local tmpfile = vim.fn.tempname()

    -- Get visual selection
    vim.cmd("'<,'>write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()
    run_ai_command("explain " .. tmpfile .. " " .. lang .. " " .. backend)
    vim.fn.delete(tmpfile)
end

-- AI Review - review selected code or whole file
local function ai_review()
    local tmpfile = vim.fn.tempname()

    -- Check if visual mode
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' then
        vim.cmd("'<,'>write! " .. tmpfile)
    else
        vim.cmd("write! " .. tmpfile)
    end

    local lang = get_language()
    local backend = get_backend()
    run_ai_command("review " .. tmpfile .. " " .. lang .. " " .. backend)
    vim.fn.delete(tmpfile)
end

-- AI Refactor - refactor selected code
local function ai_refactor()
    local instruction = vim.fn.input("Refactor instruction: ")
    if instruction == "" then return end

    local tmpfile = vim.fn.tempname()
    vim.cmd("'<,'>write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()

    local cmd = string.format("%s refactor %s '%s' %s %s",
        ai_helper, tmpfile, instruction, lang, backend)
    run_ai_command(cmd)
    vim.fn.delete(tmpfile)
end

-- AI Generate - generate code from description
local function ai_generate()
    local description = vim.fn.input("Code description: ")
    if description == "" then return end

    local lang = get_language()
    local backend = get_backend()

    local cmd = string.format("%s generate '%s' %s %s",
        ai_helper, description, lang, backend)
    run_ai_command(cmd)
end

-- AI Chat - interactive chat with conversation history
local chat_state = {
    buffer = nil,
    window = nil,
    history = {},
    context_file = nil
}

local function ai_chat()
    -- Get initial context if in visual mode
    local context = nil
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' then
        local tmpfile = vim.fn.tempname()
        vim.cmd("'<,'>write! " .. tmpfile)
        chat_state.context_file = tmpfile

        -- Read context for display
        local f = io.open(tmpfile, "r")
        if f then
            context = f:read("*all")
            f:close()
        end
    end

    -- Create or reuse chat buffer
    if not chat_state.buffer or not vim.api.nvim_buf_is_valid(chat_state.buffer) then
        chat_state.buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(chat_state.buffer, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(chat_state.buffer, 'bufhidden', 'hide')
        vim.api.nvim_buf_set_option(chat_state.buffer, 'swapfile', false)
        vim.api.nvim_buf_set_name(chat_state.buffer, 'AI Chat')
        chat_state.history = {}

        -- Set initial content
        local welcome = {
            "=== AI Chat Session ===",
            "Backend: " .. get_backend(),
            "",
            "Commands:",
            "  i - Ask a question",
            "  c - Clear chat history",
            "  q - Close chat",
            "  <Space>ab - Switch backend",
            "",
        }

        if context then
            table.insert(welcome, "Context:")
            for line in context:gmatch("[^\n]+") do
                table.insert(welcome, "  " .. line)
            end
            table.insert(welcome, "")
        end

        table.insert(welcome, "Press 'i' to start chatting...")
        table.insert(welcome, "")

        vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, welcome)
    end

    -- Open chat window
    if not chat_state.window or not vim.api.nvim_win_is_valid(chat_state.window) then
        vim.cmd("botright split")
        chat_state.window = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(chat_state.window, chat_state.buffer)
        vim.api.nvim_win_set_height(chat_state.window, 20)
    end

    -- Set up keybindings
    vim.api.nvim_buf_set_keymap(chat_state.buffer, 'n', 'i', ':lua chat_ask_question()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(chat_state.buffer, 'n', 'c', ':lua chat_clear()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(chat_state.buffer, 'n', 'q', ':lua chat_close()<CR>',
        { noremap = true, silent = true })

    log_activity("Chat session opened")
    print("Chat session ready | Press 'i' to ask, 'c' to clear, 'q' to quit")
end

-- Ask a question in chat
function chat_ask_question()
    local question = vim.fn.input("Your question: ")
    if question == "" then return end

    local backend = get_backend()
    log_activity("Chat question: " .. question)

    -- Add question to history
    table.insert(chat_state.history, {role = "user", content = question})

    -- Display question in chat buffer
    local lines = vim.api.nvim_buf_get_lines(chat_state.buffer, 0, -1, false)
    table.insert(lines, "")
    table.insert(lines, "[You] " .. question)
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, lines)

    -- Build command with context if available
    local cmd
    if chat_state.context_file then
        cmd = ai_helper .. " chat '" .. question .. "' " .. chat_state.context_file .. " " .. backend
    else
        cmd = ai_helper .. " chat '" .. question .. "' " .. backend
    end

    -- Get AI response
    table.insert(lines, "[AI] Thinking...")
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, lines)

    local output = vim.fn.systemlist(cmd)

    -- Remove "thinking" message
    table.remove(lines)

    -- Add AI response
    table.insert(lines, "[AI]")
    for _, line in ipairs(output) do
        table.insert(lines, "  " .. line)
    end
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, lines)

    -- Scroll to bottom
    local line_count = vim.api.nvim_buf_line_count(chat_state.buffer)
    if chat_state.window and vim.api.nvim_win_is_valid(chat_state.window) then
        vim.api.nvim_win_set_cursor(chat_state.window, {line_count, 0})
    end

    -- Add to history
    table.insert(chat_state.history, {role = "assistant", content = table.concat(output, "\n")})

    log_activity("Chat response received (" .. #output .. " lines)")
    print("Response ready | Press 'i' for follow-up question")
end

-- Clear chat history
function chat_clear()
    chat_state.history = {}
    local welcome = {
        "=== AI Chat Session ===",
        "Backend: " .. get_backend(),
        "",
        "Chat history cleared.",
        "",
        "Press 'i' to start chatting...",
        ""
    }
    vim.api.nvim_buf_set_lines(chat_state.buffer, 0, -1, false, welcome)
    log_activity("Chat history cleared")
    print("Chat history cleared")
end

-- Close chat window
function chat_close()
    if chat_state.window and vim.api.nvim_win_is_valid(chat_state.window) then
        vim.api.nvim_win_close(chat_state.window, true)
        chat_state.window = nil
    end

    -- Clean up context file
    if chat_state.context_file then
        vim.fn.delete(chat_state.context_file)
        chat_state.context_file = nil
    end

    log_activity("Chat session closed")
    print("Chat session closed")
end

-- Key mappings (Leader key is space by default)
vim.g.mapleader = " "

-- AI commands in normal mode
vim.keymap.set('n', '<Leader>ac', ai_complete, { desc = 'AI Complete code (preview/accept)' })
vim.keymap.set('n', '<Leader>as', ai_complete_split, { desc = 'AI Complete code (in split)' })
vim.keymap.set('n', '<Leader>ar', ai_review, { desc = 'AI Review code' })
vim.keymap.set('n', '<Leader>ag', ai_generate, { desc = 'AI Generate code' })
vim.keymap.set('n', '<Leader>aq', ai_chat, { desc = 'AI Interactive Chat' })
vim.keymap.set('n', '<Leader>ab', switch_backend, { desc = 'AI Switch backend (Ollama/Claude)' })

-- AI monitoring commands
vim.keymap.set('n', '<Leader>am', toggle_monitor, { desc = 'AI Toggle monitor panel' })
vim.keymap.set('n', '<Leader>al', toggle_logging, { desc = 'AI Toggle logging on/off' })

-- AI commands in visual mode
vim.keymap.set('v', '<Leader>ae', ai_explain, { desc = 'AI Explain selection' })
vim.keymap.set('v', '<Leader>ar', ai_review, { desc = 'AI Review selection' })
vim.keymap.set('v', '<Leader>af', ai_refactor, { desc = 'AI Refactor selection' })
vim.keymap.set('v', '<Leader>ax', ai_fix, { desc = 'AI Fix selection (replace with corrected code)' })
vim.keymap.set('v', '<Leader>aq', ai_chat, { desc = 'AI Chat about selection' })

-- Command-line commands
vim.api.nvim_create_user_command('AIComplete', ai_complete, {})
vim.api.nvim_create_user_command('AICompleteSplit', ai_complete_split, {})
vim.api.nvim_create_user_command('AIExplain', ai_explain, { range = true })
vim.api.nvim_create_user_command('AIReview', ai_review, { range = true })
vim.api.nvim_create_user_command('AIRefactor', ai_refactor, { range = true })
vim.api.nvim_create_user_command('AIFix', ai_fix, { range = true })
vim.api.nvim_create_user_command('AIGenerate', ai_generate, {})
vim.api.nvim_create_user_command('AIChat', ai_chat, { range = true })
vim.api.nvim_create_user_command('AISwitchBackend', switch_backend, {})

-- Monitoring commands
vim.api.nvim_create_user_command('AIMonitor', toggle_monitor, {})
vim.api.nvim_create_user_command('AIMonitorClear', clear_monitor, {})
vim.api.nvim_create_user_command('AILogging', toggle_logging, {})

-- Status line showing current AI backend
vim.opt.statusline = "%f %h%m%r%=%{luaeval('vim.env.VIM_AI_BACKEND or \"ollama\"')} | %l,%c %P"

-- Load LSP and Tree-sitter configurations (if installed)
local lsp_ok, lsp_err = pcall(require, 'lsp-config')
if not lsp_ok then
    print("LSP config error: " .. tostring(lsp_err))
end

local ts_ok, ts_err = pcall(require, 'treesitter-config')
if not ts_ok then
    print("Tree-sitter config error: " .. tostring(ts_err))
end

print("AI Coding Assistant loaded! Leader = Space")
print("Commands: <Space>ac (complete w/preview), <Space>as (complete split)")
print("          <Space>ar (review), <Space>ag (generate), <Space>aq (interactive chat)")
print("Visual: <Space>ae (explain), <Space>af (refactor), <Space>ax (fix), <Space>aq (chat)")
print("Switch backend: <Space>ab | Monitor: <Space>am | Logging: <Space>al")
if log_enabled then
    print("Activity logging: ENABLED (log file: " .. log_file .. ")")
    log_activity("AI Assistant initialized")
else
    print("Activity logging: DISABLED (enable with <Space>al)")
end
