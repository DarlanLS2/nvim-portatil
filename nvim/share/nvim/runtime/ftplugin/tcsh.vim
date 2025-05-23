" Vim filetype plugin file
" Language:		tcsh
" Maintainer:		Doug Kearns <dougkearns@gmail.com>
" Previous Maintainer:	Dan Sharp
" Last Change:		2024 Jan 14

if exists("b:did_ftplugin")
  finish
endif

let s:save_cpo = &cpo
set cpo-=C

" Define some defaults in case the included ftplugins don't set them.
let s:undo_ftplugin = ""
let s:browsefilter = "csh Files (*.csh)\t*.csh\n"
if has("win32")
    let s:browsefilter ..= "All Files (*.*)\t*\n"
else
    let s:browsefilter ..= "All Files (*)\t*\n"
endif

runtime! ftplugin/csh.vim ftplugin/csh_*.vim ftplugin/csh/*.vim
let b:did_ftplugin = 1

" Override our defaults if these were set by an included ftplugin.
if exists("b:undo_ftplugin")
  let s:undo_ftplugin = b:undo_ftplugin
endif
if exists("b:browsefilter")
  let s:browsefilter = b:browsefilter
endif

if (has("gui_win32") || has("gui_gtk")) &&
      \ (!exists("b:browsefilter") || exists("b:csh_set_browsefilter"))
  let b:browsefilter = "tcsh Scripts (*.tcsh)\t*.tcsh\n" .. s:browsefilter
  let s:undo_ftplugin = "unlet! b:browsefilter | " .. s:undo_ftplugin
endif

let b:undo_ftplugin = s:undo_ftplugin

let &cpo = s:save_cpo
unlet s:save_cpo
