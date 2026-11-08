" Packpath/vimfiles loader for devenv-ai-assistant-vim RPM.
" Does not replace ~/.vimrc.
if exists('g:loaded_devenv_ai_assistant')
  finish
endif
let g:loaded_devenv_ai_assistant = 1

let s:conf = '/usr/share/devenv-ai-assistant/vimrc'
if filereadable(s:conf)
  execute 'source' fnameescape(s:conf)
else
  echohl ErrorMsg
  echomsg 'devenv-ai-assistant: missing ' . s:conf
  echohl None
endif
