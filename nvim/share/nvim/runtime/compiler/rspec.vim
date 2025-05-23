" Vim compiler file
" Language:		RSpec
" Maintainer:		Tim Pope <vimNOSPAM@tpope.org>
" URL:			https://github.com/vim-ruby/vim-ruby
" Release Coordinator:	Doug Kearns <dougkearns@gmail.com>
" Last Change:		2018 Aug 07
"			2024 Apr 03 by The Vim Project (removed :CompilerSet definition)

if exists("current_compiler")
  finish
endif
let current_compiler = "rspec"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=rspec

CompilerSet errorformat=
    \%f:%l:\ %tarning:\ %m,
    \%E%.%#:in\ `load':\ %f:%l:%m,
    \%E%f:%l:in\ `%*[^']':\ %m,
    \%-Z\ \ \ \ \ %\\+\#\ %f:%l:%.%#,
    \%E\ \ \ \ \ Failure/Error:\ %m,
    \%E\ \ \ \ \ Failure/Error:,
    \%C\ \ \ \ \ %m,
    \%C%\\s%#,
    \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8:
