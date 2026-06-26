-- Neovim LSP Configuration for Containerized LSP Servers
-- Drop-in replacement for lsp-config.lua to use containers

-- Path to LSP wrapper script
local lsp_wrapper = vim.fn.expand("~/vim-ai-assistant/containers/lsp-servers/lsp-wrapper.sh")

-- Check if container runtime is available
local function check_podman()
    return vim.fn.executable("podman") == 1
end

-- Setup LSP with container
local function setup_container_lsp(lang, wrapper_arg)
    local cmd = { lsp_wrapper, wrapper_arg }

    vim.lsp.start({
        name = lang .. "-container",
        cmd = cmd,
        root_dir = vim.fn.getcwd(),
    })
end

-- Auto-start containerized LSP for supported languages
if check_podman() then
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            setup_container_lsp("pylsp", "python")
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
            setup_container_lsp("gopls", "go")
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sh", "bash" },
        callback = function()
            setup_container_lsp("bashls", "bash")
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
            setup_container_lsp("rust-analyzer", "rust")
        end,
    })

    print("✅ Using containerized LSP servers")
else
    print("⚠️  Podman not found - install podman to use containerized LSP")
end
