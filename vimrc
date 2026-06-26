" Vim AI Coding Assistant Configuration
" Supports Ollama (Granite), Claude API, and Gemini API

" Basic settings
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
syntax on
filetype plugin indent on

" ═══════════════════════════════════════════════════════════
" ALE (LSP) Configuration
" ═══════════════════════════════════════════════════════════
" ALE provides LSP support for vim (like neovim's built-in LSP)

" Enable ALE if installed
let g:ale_enabled = 1

" LSP servers to use (same as neovim)
let g:ale_linters = {
\   'python': ['pylsp', 'ruff'],
\   'go': ['gopls'],
\   'sh': ['bashls'],
\   'bash': ['bashls'],
\   'javascript': [],
\   'typescript': [],
\}

" Enable completion
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc

" Show errors in location list
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0
let g:ale_open_list = 0

" Lint as you type
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" Signs in gutter
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '!'

" LSP Keybindings (similar to neovim)
nmap gd <Plug>(ale_go_to_definition)
nmap gr <Plug>(ale_find_references)
nmap K <Plug>(ale_hover)
nmap <leader>rn <Plug>(ale_rename)
nmap <leader>ca <Plug>(ale_code_action)
nmap [d <Plug>(ale_previous_wrap)
nmap ]d <Plug>(ale_next_wrap)
nmap <leader>e <Plug>(ale_detail)

" Completion with Ctrl+Space
inoremap <C-Space> <C-x><C-o>

" ═══════════════════════════════════════════════════════════
" AI Helper script path
let s:ai_helper = expand("~/.local/bin/vim-ai-helper")

" Get current filetype as language
function! s:GetLanguage()
    return &filetype
endfunction

" Get current backend from environment
function! s:GetBackend()
    return $VIM_AI_BACKEND != "" ? $VIM_AI_BACKEND : "ollama"
endfunction

" Switch between Ollama, Claude, and Gemini
function! s:SwitchBackend()
    let current = s:GetBackend()
    " Cycle through: ollama -> claude -> gemini -> ollama
    if current == "ollama"
        let new_backend = "claude"
    elseif current == "claude"
        let new_backend = "gemini"
    else
        let new_backend = "ollama"
    endif
    let $VIM_AI_BACKEND = new_backend
    echo "Switched AI backend to: " . new_backend
endfunction

" Execute AI command and show results in split window
function! s:RunAICommand(cmd)
    " Create new split for output
    botright new
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    file AI\ Response

    " Run command and capture output
    let output = system(s:ai_helper . " " . a:cmd)
    call setline(1, split(output, "\n"))

    " Set syntax highlighting
    let &filetype = s:GetLanguage()
endfunction

" AI Complete - complete code and insert at cursor
function! s:AIComplete()
    let tmpfile = tempname()
    execute "write! " . tmpfile
    let lang = s:GetLanguage()
    let backend = s:GetBackend()

    let cmd = s:ai_helper . " complete " . tmpfile . " " . lang . " " . backend
    let output = systemlist(cmd)
    call delete(tmpfile)

    " Insert completion at cursor position
    let row = line('.')
    call append(row, output)

    " Show message
    echo "AI completion inserted (" . backend . ")"
endfunction

" AI Complete in split - for review before inserting
function! s:AICompleteSplit()
    let tmpfile = tempname()
    execute "write! " . tmpfile
    let lang = s:GetLanguage()
    let backend = s:GetBackend()
    call s:RunAICommand("complete " . tmpfile . " " . lang . " " . backend)
    call delete(tmpfile)
endfunction

" AI Explain - explain selected code
function! s:AIExplain() range
    let tmpfile = tempname()
    execute a:firstline . "," . a:lastline . "write! " . tmpfile
    let lang = s:GetLanguage()
    let backend = s:GetBackend()
    call s:RunAICommand("explain " . tmpfile . " " . lang . " " . backend)
    call delete(tmpfile)
endfunction

" AI Review - review selected code or whole file
function! s:AIReview() range
    let tmpfile = tempname()

    if a:firstline != a:lastline
        execute a:firstline . "," . a:lastline . "write! " . tmpfile
    else
        execute "write! " . tmpfile
    endif

    let lang = s:GetLanguage()
    let backend = s:GetBackend()
    call s:RunAICommand("review " . tmpfile . " " . lang . " " . backend)
    call delete(tmpfile)
endfunction

" AI Refactor - refactor selected code
function! s:AIRefactor() range
    let instruction = input("Refactor instruction: ")
    if instruction == ""
        return
    endif

    let tmpfile = tempname()
    execute a:firstline . "," . a:lastline . "write! " . tmpfile
    let lang = s:GetLanguage()
    let backend = s:GetBackend()

    call s:RunAICommand("refactor " . tmpfile . " '" . instruction . "' " . lang . " " . backend)
    call delete(tmpfile)
endfunction

" AI Generate - generate code from description
function! s:AIGenerate()
    let description = input("Code description: ")
    if description == ""
        return
    endif

    let lang = s:GetLanguage()
    let backend = s:GetBackend()
    call s:RunAICommand("generate '" . description . "' " . lang . " " . backend)
endfunction

" AI Chat - ask questions about code
function! s:AIChat() range
    let question = input("Ask AI: ")
    if question == ""
        return
    endif

    let backend = s:GetBackend()

    if a:firstline != a:lastline
        let tmpfile = tempname()
        execute a:firstline . "," . a:lastline . "write! " . tmpfile
        call s:RunAICommand("chat '" . question . "' " . tmpfile . " " . backend)
        call delete(tmpfile)
    else
        call s:RunAICommand("chat '" . question . "' " . backend)
    endif
endfunction

" Key mappings (Leader key is space)
let mapleader = " "

" AI commands in normal mode
nnoremap <Leader>ac :call <SID>AIComplete()<CR>
nnoremap <Leader>as :call <SID>AICompleteSplit()<CR>
nnoremap <Leader>ar :call <SID>AIReview()<CR>
nnoremap <Leader>ag :call <SID>AIGenerate()<CR>
nnoremap <Leader>aq :call <SID>AIChat()<CR>
nnoremap <Leader>ab :call <SID>SwitchBackend()<CR>

" AI commands in visual mode
vnoremap <Leader>ae :call <SID>AIExplain()<CR>
vnoremap <Leader>ar :call <SID>AIReview()<CR>
vnoremap <Leader>af :call <SID>AIRefactor()<CR>
vnoremap <Leader>aq :call <SID>AIChat()<CR>

" Command-line commands
command! AIComplete call s:AIComplete()
command! AICompleteSplit call s:AICompleteSplit()
command! -range AIExplain <line1>,<line2>call s:AIExplain()
command! -range AIReview <line1>,<line2>call s:AIReview()
command! -range AIRefactor <line1>,<line2>call s:AIRefactor()
command! AIGenerate call s:AIGenerate()
command! -range AIChat <line1>,<line2>call s:AIChat()
command! AISwitchBackend call s:SwitchBackend()

" Status line showing current AI backend
set statusline=%f\ %h%m%r%=%{$VIM_AI_BACKEND!=''?$VIM_AI_BACKEND:'ollama'}\ \|\ %l,%c\ %P

echo "AI Coding Assistant loaded! Leader = Space"
echo "Commands: <Space>ac (complete inline), <Space>as (complete split)"
echo "          <Space>ar (review), <Space>ag (generate), <Space>aq (chat)"
echo "Visual: <Space>ae (explain), <Space>af (refactor), <Space>ax (fix), <Space>aq (chat)"
echo "Switch backend: <Space>ab (Ollama/Claude/Gemini)"
