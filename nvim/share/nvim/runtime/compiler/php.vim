" Vim compiler file
" Compiler:	PHP CLI
" Maintainer:	Doug Kearns <dougkearns@gmail.com>
" Last Change:	2024 Apr 03

if exists("current_compiler")
  finish
endif
let current_compiler = "php"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=php\ -lq
CompilerSet errorformat=%E<b>%.%#Parse\ error</b>:\ %m\ in\ <b>%f</b>\ on\ line\ <b>%l</b><br\ />,
		    \%W<b>%.%#Notice</b>:\ %m\ in\ <b>%f</b>\ on\ line\ <b>%l</b><br\ />,
		    \%E%.%#Parse\ error:\ %m\ in\ %f\ on\ line\ %l,
		    \%W%.%#Notice:\ %m\ in\ %f\ on\ line\ %l,
		    \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
