" Vim syntax file
" Language:             pam(8) configuration file
" Previous Maintainer:  Nikolai Weibull <now@bitwi.se>
" Latest Change:        2024/03/31
" Changes By:		Haochen Tong
" 			Vim Project for the @include syntax

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:has_service_field = exists("b:pamconf_has_service_field")
      \ ? b:pamconf_has_service_field
      \ : expand('%:t') == 'pam.conf' ? 1 : 0

syn match   pamconfType             '-\?[[:alpha:]]\+'
                                    \ contains=pamconfTypeKeyword
                                    \ nextgroup=pamconfControl,
                                    \ pamconfTypeLineCont skipwhite

syn keyword pamconfTypeKeyword      contained account auth password session

" The @include syntax is Debian specific
syn match   pamconfInclude         '^@include'
                                    \ nextgroup=pamconfIncludeFile
                                    \ skipwhite

syn match   pamconfIncludeFile     '\f\+$'

if s:has_service_field
    syn match   pamconfService          '^[[:graph:]]\+'
                                        \ nextgroup=pamconfType,
                                        \ pamconfServiceLineCont skipwhite

    syn match   pamconfServiceLineCont  contained '\\$'
                                        \ nextgroup=pamconfType,
                                        \ pamconfServiceLineCont skipwhite skipnl
endif

syn keyword pamconfTodo             contained TODO FIXME XXX NOTE

syn region  pamconfComment          display oneline start='#' end='$'
                                    \ contains=pamconfTodo,@Spell

syn match   pamconfTypeLineCont     contained '\\$'
                                    \ nextgroup=pamconfControl,
                                    \ pamconfTypeLineCont skipwhite skipnl

syn keyword pamconfControl          contained requisite required sufficient
                                    \ optional include substack
                                    \ nextgroup=pamconfMPath,
                                    \ pamconfControlLineContH skipwhite

syn match   pamconfControlBegin     '\[' nextgroup=pamconfControlValues,
                                    \ pamconfControlLineCont skipwhite

syn match   pamconfControlLineCont  contained '\\$'
                                    \ nextgroup=pamconfControlValues,
                                    \ pamconfControlLineCont skipwhite skipnl

syn keyword pamconfControlValues    contained success open_err symbol_err
                                    \ service_err system_err buf_err
                                    \ perm_denied auth_err cred_insufficient
                                    \ authinfo_unavail user_unknown maxtries
                                    \ new_authtok_reqd acct_expired session_err
                                    \ cred_unavail cred_expired cred_err
                                    \ no_module_data conv_err authtok_err
                                    \ authtok_recover_err authtok_lock_busy
                                    \ authtok_disable_aging try_again ignore
                                    \ abort authtok_expired module_unknown
                                    \ bad_item and default
                                    \ nextgroup=pamconfControlValueEq

syn match   pamconfControlValueEq   contained '='
                                    \ nextgroup=pamconfControlActionN,
                                    \           pamconfControlAction

syn match   pamconfControlActionN   contained '\d\+\>'
                                    \ nextgroup=pamconfControlValues,
                                    \ pamconfControlLineCont,pamconfControlEnd
                                    \ skipwhite
syn keyword pamconfControlAction    contained ignore bad die ok done reset
                                    \ nextgroup=pamconfControlValues,
                                    \ pamconfControlLineCont,pamconfControlEnd
                                    \ skipwhite

syn match   pamconfControlEnd       contained '\]'
                                    \ nextgroup=pamconfMPath,
                                    \ pamconfControlLineContH skipwhite

syn match   pamconfControlLineContH contained '\\$'
                                    \ nextgroup=pamconfMPath,
                                    \ pamconfControlLineContH skipwhite skipnl

syn match   pamconfMPath            contained '\S\+'
                                    \ nextgroup=pamconfMPathLineCont,
                                    \ pamconfArgs skipwhite

syn match   pamconfArgs             contained '\S\+'
                                    \ nextgroup=pamconfArgsLineCont,
                                    \ pamconfArgs skipwhite

syn match   pamconfMPathLineCont    contained '\\$'
                                    \ nextgroup=pamconfMPathLineCont,
                                    \ pamconfArgs skipwhite skipnl

syn match   pamconfArgsLineCont     contained '\\$'
                                    \ nextgroup=pamconfArgsLineCont,
                                    \ pamconfArgs skipwhite skipnl

hi def link pamconfTodo             Todo
hi def link pamconfComment          Comment
hi def link pamconfService          Statement
hi def link pamconfServiceLineCont  Special
hi def link pamconfType             Special
hi def link pamconfTypeKeyword      Type
hi def link pamconfTypeLineCont     pamconfServiceLineCont
hi def link pamconfControl          Macro
hi def link pamconfControlBegin     Delimiter
hi def link pamconfControlLineContH pamconfServiceLineCont
hi def link pamconfControlLineCont  pamconfServiceLineCont
hi def link pamconfControlValues    Identifier
hi def link pamconfControlValueEq   Operator
hi def link pamconfControlActionN   Number
hi def link pamconfControlAction    Identifier
hi def link pamconfControlEnd       Delimiter
hi def link pamconfMPath            String
hi def link pamconfMPathLineCont    pamconfServiceLineCont
hi def link pamconfArgs             Normal
hi def link pamconfArgsLineCont     pamconfServiceLineCont
hi def link pamconfInclude          Include
hi def link pamconfIncludeFile      Include

let b:current_syntax = "pamconf"

let &cpo = s:cpo_save
unlet s:cpo_save
