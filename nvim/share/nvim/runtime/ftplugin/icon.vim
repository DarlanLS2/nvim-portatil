" Vim filetype plugin file
" Language:	Icon
" Maintainer:	Doug Kearns <dougkearns@gmail.com>
" Last Change:	2024 Jan 14

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal comments=:#
setlocal commentstring=#\ %s
setlocal formatoptions-=t formatoptions+=croql

let b:undo_ftplugin = "setl fo< com< cms<"

if exists("loaded_matchit")
    let b:match_ignorecase = 0
    let b:match_words  = '^\s*$\s*if\(def\|ndef\)\=\>:^\s*$\s*elif\>:^\s*$\s*else\>:^\s*$\s*endif\>,' ..
	  \		 '\<procedure\>:\<\%(initial\|return\|suspend\|fail\)\>:\<end\>'
    let b:undo_ftplugin ..= " | unlet! b:match_ignorecase b:match_words"
endif

if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
  let b:browsefilter = "Icon Source Files (*.icn)\t*.icn\n"
  if has("win32")
    let b:browsefilter ..= "All Files (*.*)\t*\n"
  else
    let b:browsefilter ..= "All Files (*)\t*\n"
  endif
  let b:undo_ftplugin ..= " | unlet! b:browsefilter"
endif

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8
