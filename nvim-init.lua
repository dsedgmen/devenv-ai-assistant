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
local log_enabled = false
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
        print("AI Monitor closed")
    else
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
                vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
                    "=== AI Activity Monitor ===",
                    "Tracking all AI assistant operations",
                    "Commands: :AIMonitorClear to clear, :AIMonitor to toggle",
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

        print("AI Monitor opened")
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

-- AI Complete - complete code and insert at cursor
local function ai_complete()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()

    log_activity("AI Complete (inline): lang=" .. lang .. ", backend=" .. backend)

    local cmd = ai_helper .. " complete " .. tmpfile .. " " .. lang .. " " .. backend
    local start_time = os.time()
    local output = vim.fn.systemlist(cmd)
    local duration = os.time() - start_time
    vim.fn.delete(tmpfile)

    -- Insert completion at cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row, row, false, output)

    log_activity("Completed in " .. duration .. "s, inserted " .. #output .. " lines")
    print("AI completion inserted (" .. backend .. ")")
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

-- AI Chat - ask questions about code
local function ai_chat()
    local question = vim.fn.input("Ask AI: ")
    if question == "" then return end

    local tmpfile = vim.fn.tempname()
    local backend = get_backend()

    -- Check if visual mode for context
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' then
        vim.cmd("'<,'>write! " .. tmpfile)
        local cmd = string.format("chat '%s' %s %s",
            question, tmpfile, backend)
        run_ai_command(cmd)
        vim.fn.delete(tmpfile)
    else
        local cmd = string.format("chat '%s' %s",
            question, backend)
        run_ai_command(cmd)
    end
end

-- Key mappings (Leader key is space by default)
vim.g.mapleader = " "

-- AI commands in normal mode
vim.keymap.set('n', '<Leader>ac', ai_complete, { desc = 'AI Complete code (inline)' })
vim.keymap.set('n', '<Leader>as', ai_complete_split, { desc = 'AI Complete code (in split)' })
vim.keymap.set('n', '<Leader>ar', ai_review, { desc = 'AI Review code' })
vim.keymap.set('n', '<Leader>ag', ai_generate, { desc = 'AI Generate code' })
vim.keymap.set('n', '<Leader>aq', ai_chat, { desc = 'AI Chat/Question' })
vim.keymap.set('n', '<Leader>ab', switch_backend, { desc = 'AI Switch backend (Ollama/Claude)' })

-- AI monitoring commands
vim.keymap.set('n', '<Leader>am', toggle_monitor, { desc = 'AI Toggle monitor panel' })
vim.keymap.set('n', '<Leader>al', toggle_logging, { desc = 'AI Toggle logging on/off' })

-- AI commands in visual mode
vim.keymap.set('v', '<Leader>ae', ai_explain, { desc = 'AI Explain selection' })
vim.keymap.set('v', '<Leader>ar', ai_review, { desc = 'AI Review selection' })
vim.keymap.set('v', '<Leader>af', ai_refactor, { desc = 'AI Refactor selection' })
vim.keymap.set('v', '<Leader>aq', ai_chat, { desc = 'AI Chat about selection' })

-- Command-line commands
vim.api.nvim_create_user_command('AIComplete', ai_complete, {})
vim.api.nvim_create_user_command('AICompleteSplit', ai_complete_split, {})
vim.api.nvim_create_user_command('AIExplain', ai_explain, { range = true })
vim.api.nvim_create_user_command('AIReview', ai_review, { range = true })
vim.api.nvim_create_user_command('AIRefactor', ai_refactor, { range = true })
vim.api.nvim_create_user_command('AIGenerate', ai_generate, {})
vim.api.nvim_create_user_command('AIChat', ai_chat, { range = true })
vim.api.nvim_create_user_command('AISwitchBackend', switch_backend, {})

-- Monitoring commands
vim.api.nvim_create_user_command('AIMonitor', toggle_monitor, {})
vim.api.nvim_create_user_command('AIMonitorClear', clear_monitor, {})
vim.api.nvim_create_user_command('AILogging', toggle_logging, {})

-- Status line showing current AI backend
vim.opt.statusline = "%f %h%m%r%=%{luaeval('vim.env.VIM_AI_BACKEND or \"ollama\"')} | %l,%c %P"

print("AI Coding Assistant loaded! Leader = Space")
print("Commands: <Space>ac (complete inline), <Space>as (complete split)")
print("          <Space>ar (review), <Space>ag (generate), <Space>aq (chat)")
print("Visual: <Space>ae (explain), <Space>af (refactor), <Space>aq (chat)")
print("Switch backend: <Space>ab | Monitor: <Space>am | Logging: <Space>al")
