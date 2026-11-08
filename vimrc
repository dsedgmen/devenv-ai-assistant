" devenv-ai-assistant — Vim AI keymaps (calls devenv-ai-helper)
" LSP/ALE lives in devenv-lsp-setup (install-vim-lsp.sh / vim-ale-config.vim).

" Basic settings
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
syntax on
filetype plugin indent on

let mapleader = " "

" Resolve CLI: devenv-ai-helper, then vim-ai-helper compat, then ~/.local/bin
let s:ai_helper = "devenv-ai-helper"
if !executable(s:ai_helper)
  if executable("vim-ai-helper")
    let s:ai_helper = "vim-ai-helper"
  elseif executable(expand("~/.local/bin/devenv-ai-helper"))
    let s:ai_helper = expand("~/.local/bin/devenv-ai-helper")
  else
    let s:ai_helper = expand("~/.local/bin/vim-ai-helper")
  endif
endif

function! s:GetLanguage()
  return &filetype
endfunction

function! s:GetBackend()
  return $DEVENV_AI_BACKEND != "" ? $DEVENV_AI_BACKEND : ($VIM_AI_BACKEND != "" ? $VIM_AI_BACKEND : "ollama")
endfunction

function! s:SwitchBackend()
  let current = s:GetBackend()
  if current == "ollama"
    let new_backend = "claude"
  elseif current == "claude"
    let new_backend = "gemini"
  else
    let new_backend = "ollama"
  endif
  let $DEVENV_AI_BACKEND = new_backend
  let $VIM_AI_BACKEND = new_backend
  echo "Switched AI backend to: " . new_backend
endfunction

function! s:RunAICommand(cmd)
  botright new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  file AI\ Response
  let output = system(s:ai_helper . " " . a:cmd)
  call setline(1, split(output, "\n"))
  let &filetype = s:GetLanguage()
endfunction

function! s:AIComplete()
  let tmpfile = tempname()
  execute "write! " . tmpfile
  let lang = s:GetLanguage()
  let backend = s:GetBackend()
  let output = systemlist(s:ai_helper . " complete " . tmpfile . " " . lang . " " . backend)
  call delete(tmpfile)
  call append(line('.'), output)
  echo "AI completion inserted (" . backend . ")"
endfunction

function! s:AICompleteSplit()
  let tmpfile = tempname()
  execute "write! " . tmpfile
  let lang = s:GetLanguage()
  let backend = s:GetBackend()
  call s:RunAICommand("complete " . tmpfile . " " . lang . " " . backend)
  call delete(tmpfile)
endfunction

function! s:AIExplain() range
  let tmpfile = tempname()
  execute a:firstline . "," . a:lastline . "write! " . tmpfile
  let lang = s:GetLanguage()
  let backend = s:GetBackend()
  call s:RunAICommand("explain " . tmpfile . " " . lang . " " . backend)
  call delete(tmpfile)
endfunction

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

function! s:AIGenerate()
  let description = input("Code description: ")
  if description == ""
    return
  endif
  let lang = s:GetLanguage()
  let backend = s:GetBackend()
  call s:RunAICommand("generate '" . description . "' " . lang . " " . backend)
endfunction

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

nnoremap <Leader>ac :call <SID>AIComplete()<CR>
nnoremap <Leader>as :call <SID>AICompleteSplit()<CR>
nnoremap <Leader>ar :call <SID>AIReview()<CR>
nnoremap <Leader>ag :call <SID>AIGenerate()<CR>
nnoremap <Leader>aq :call <SID>AIChat()<CR>
nnoremap <Leader>ab :call <SID>SwitchBackend()<CR>

vnoremap <Leader>ae :call <SID>AIExplain()<CR>
vnoremap <Leader>ar :call <SID>AIReview()<CR>
vnoremap <Leader>af :call <SID>AIRefactor()<CR>
vnoremap <Leader>aq :call <SID>AIChat()<CR>

command! AIComplete call s:AIComplete()
command! AICompleteSplit call s:AICompleteSplit()
command! -range AIExplain <line1>,<line2>call s:AIExplain()
command! -range AIReview <line1>,<line2>call s:AIReview()
command! -range AIRefactor <line1>,<line2>call s:AIRefactor()
command! AIGenerate call s:AIGenerate()
command! -range AIChat <line1>,<line2>call s:AIChat()
command! AISwitchBackend call s:SwitchBackend()

set statusline=%f\ %h%m%r%=%{($DEVENV_AI_BACKEND!=''?$DEVENV_AI_BACKEND:($VIM_AI_BACKEND!=''?$VIM_AI_BACKEND:'ollama'))}\ \|\ %l,%c\ %P

echo "devenv-ai-assistant loaded (Leader = Space)"
echo "  <Space>ac complete | <Space>as split | <Space>ar review | <Space>ag generate | <Space>aq chat | <Space>ab backend"
echo "  Visual: <Space>ae explain | <Space>af refactor | <Space>aq chat"
