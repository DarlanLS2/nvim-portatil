" Vim filetype plugin file
" Language:	bash
" Maintainer:	The Vim Project <https://github.com/vim/vim>
" Last Changed: 2023 Aug 13
"
" This is not a real filetype plugin.  It allows for someone to set 'filetype'
" to "bash" in the modeline, and gets the effect of filetype "sh" with
" b:is_bash set.  Idea from Mahmode Al-Qudsi.

if exists("b:did_ftplugin")
  finish
endif

unlet! b:is_sh
unlet! b:is_kornshell
let b:is_bash = 1

runtime! ftplugin/sh.vim ftplugin/sh_*.vim ftplugin/sh/*.vim

" vim: ts=8
