-- Tree-sitter Configuration for Neovim
-- Uses ONLY system-installed tree-sitter grammars from Fedora repos

-- Neovim 0.9+ has built-in tree-sitter support
-- We configure it to use system libraries instead of downloading

-- Enable tree-sitter highlighting
vim.treesitter.start()

-- Configure tree-sitter to look for parsers in system paths
local parser_install_dir = "/usr/lib64"

-- Tell neovim where to find the system-installed parsers
vim.opt.runtimepath:append("/usr/share/nvim/site")

-- Language-specific tree-sitter setup
local treesitter_langs = {
    "python",
    "bash",
    "c",
    "cpp",
    "go",
    "javascript",
    "typescript",
    "json",
    "yaml",
    "html",
    "css",
    "lua",
    "rust",
    "java",
    "ruby",
}

-- Auto-enable tree-sitter highlighting for supported languages
for _, lang in ipairs(treesitter_langs) do
    vim.api.nvim_create_autocmd("FileType", {
        pattern = lang,
        callback = function()
            -- Enable tree-sitter for this buffer
            vim.treesitter.start()
        end,
    })
end

-- Tree-sitter based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false  -- Don't fold by default

-- Syntax highlighting with tree-sitter
vim.cmd([[
    if has('nvim-0.9')
        " Use tree-sitter for syntax highlighting
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
    endif
]])

print("Tree-sitter configuration loaded")
print("Using system-installed parsers for: " .. table.concat(treesitter_langs, ", "))
