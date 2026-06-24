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
    print("Switched AI backend to: " .. new_backend)
end

-- Execute AI command and show results in split window
local function run_ai_command(args)
    local cmd = ai_helper .. " " .. args

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
    local output = vim.fn.systemlist(cmd)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

    -- Set syntax highlighting
    vim.api.nvim_buf_set_option(buf, 'filetype', get_language())
end

-- AI Complete - complete code and insert at cursor
local function ai_complete()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    local lang = get_language()
    local backend = get_backend()

    local cmd = ai_helper .. " complete " .. tmpfile .. " " .. lang .. " " .. backend
    local output = vim.fn.systemlist(cmd)
    vim.fn.delete(tmpfile)

    -- Insert completion at cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row, row, false, output)

    -- Show message
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
        local cmd = string.format("%s chat '%s' %s %s",
            ai_helper, question, tmpfile, backend)
        run_ai_command(cmd)
        vim.fn.delete(tmpfile)
    else
        local cmd = string.format("%s chat '%s' %s",
            ai_helper, question, backend)
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

-- Status line showing current AI backend
vim.opt.statusline = "%f %h%m%r%=%{luaeval('vim.env.VIM_AI_BACKEND or \"ollama\"')} | %l,%c %P"

print("AI Coding Assistant loaded! Leader = Space")
print("Commands: <Space>ac (complete inline), <Space>as (complete split)")
print("          <Space>ar (review), <Space>ag (generate), <Space>aq (chat)")
print("Visual: <Space>ae (explain), <Space>af (refactor), <Space>aq (chat)")
print("Switch backend: <Space>ab")
