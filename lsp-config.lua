-- LSP Configuration for Neovim
-- Uses ONLY system-installed LSP servers from Fedora repos

-- LSP Keybindings
local function on_attach(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- Go to definition
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- Go to declaration
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- Hover documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- Go to implementation
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- Signature help
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- Rename
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- Code action
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    -- Find references
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- Format
    vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format { async = true }
    end, opts)

    -- Diagnostics
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    print("LSP attached for " .. client.name)
end

-- Python LSP (python-lsp-server from repos)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        -- Find root directory or use current file's directory
        local root_files = {'.git', 'setup.py', 'pyproject.toml', 'requirements.txt'}
        local root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1])
        if not root_dir then
            root_dir = vim.fn.getcwd()
        end

        vim.lsp.start({
            name = "pylsp",
            cmd = { "pylsp" },
            root_dir = root_dir,
            on_attach = on_attach,
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = { enabled = true },
                        pyflakes = { enabled = true },
                        pylint = { enabled = false },
                        ruff = { enabled = true },
                        black = { enabled = true },
                    }
                }
            }
        })
    end,
})

-- Go LSP (gopls from repos)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        local root_dir = vim.fs.dirname(vim.fs.find({'go.mod', '.git'}, { upward = true })[1])
        if not root_dir then
            root_dir = vim.fn.getcwd()
        end

        vim.lsp.start({
            name = "gopls",
            cmd = { "gopls" },
            root_dir = root_dir,
            on_attach = on_attach,
        })
    end,
})

-- Bash LSP (bash-language-server from repos)
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"sh", "bash"},
    callback = function()
        local root_dir = vim.fs.dirname(vim.fs.find({'.git'}, { upward = true })[1])
        if not root_dir then
            root_dir = vim.fn.getcwd()
        end

        vim.lsp.start({
            name = "bashls",
            cmd = { "bash-language-server", "start" },
            root_dir = root_dir,
            on_attach = on_attach,
        })
    end,
})

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- Diagnostic signs
local signs = { Error = "✗", Warn = "!", Hint = "?", Info = "i" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Auto-completion setup (using built-in omnifunc)
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Trigger completion with Ctrl+Space
vim.api.nvim_set_keymap('i', '<C-Space>', '<C-x><C-o>', { noremap = true })

print("LSP configuration loaded")
print("LSP Keybindings:")
print("  gd - Go to definition")
print("  K - Hover documentation")
print("  gr - Find references")
print("  <leader>rn - Rename")
print("  <leader>ca - Code action")
print("  <leader>f - Format")
print("  [d / ]d - Previous/Next diagnostic")
