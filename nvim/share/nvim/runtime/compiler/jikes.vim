" Vim Compiler File
" Compiler:	Jikes
" Maintainer:	Dan Sharp <dwsharp at hotmail dot com>
" Last Change:	2019 Jul 23
"		2024 Apr 03 by The Vim Project (removed :CompilerSet definition)
" URL:		http://dwsharp.users.sourceforge.net/vim/compiler

if exists("current_compiler")
  finish
endif
let current_compiler = "jikes"

" Jikes defaults to printing output on stderr
CompilerSet makeprg=jikes\ -Xstdout\ +E\ \"%:S\"
CompilerSet errorformat=%f:%l:%v:%*\\d:%*\\d:%*\\s%m
