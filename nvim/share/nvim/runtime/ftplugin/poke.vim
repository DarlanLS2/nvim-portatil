" Vim filetype plugin file
" Language:	GNU Poke
" Maintainer:	Doug Kearns <dougkearns@gmail.com>
" Last Change:	2024 Jan 14

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s
setlocal formatoptions-=t formatoptions+=croql

setlocal include=load
setlocal suffixesadd=.pk

let b:undo_ftplugin = "setl fo< com< cms< inc< sua<"

if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
  let b:browsefilter = "Poke Files (*.pk)\t*.pk\n"
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
