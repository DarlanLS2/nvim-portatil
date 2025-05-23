" Vim syntax file
" Language:     cmakecache - CMakeCache.txt files generated by CMake
" Author:       bfrg <https://github.com/bfrg>
" Upstream:      https://github.com/bfrg/vim-cmakecache-syntax
" Last Change:  Nov 28, 2019
" License:      Same as Vim itself (see :h license)

if exists('b:current_syntax')
    finish
endif

let s:cpo_save = &cpoptions
set cpoptions&vim

" Comments start with # or //
syntax region CMakeCacheComment start="#\|//" end="$"

" Match 'key' in key:type=value
syntax match CMakeCacheKey "^\s*\w\+\(-ADVANCED\)\=:"me=e-1

" Highlight 'str' in key:STRING=str (many thanks to Nickspoons in #vim!)
syntax region CMakeCacheStringVar   matchgroup=CMakeCacheType start=":STRING="ms=s+1,rs=e-1 end="$" contains=CMakeCacheString keepend
syntax region CMakeCacheString      start="="ms=s+1 end="$" contained

" Highlight boolean 'value' in key:BOOL=value
syntax region CMakeCacheBoolVar     matchgroup=CMakeCacheType start=":BOOL="ms=s+1,rs=e-1 end="$" contains=CMakeCacheBool keepend
syntax region CMakeCacheBool        start="="ms=s+1 end="$" contained

" Highlight 'path' in key:PATH=path
syntax region CMakeCachePathVar     matchgroup=CMakeCacheType start=":PATH="ms=s+1,rs=e-1 end="$" contains=CMakeCachePath keepend
syntax region CMakeCachePath        start="="ms=s+1 end="$" contained

" Highlight 'file' in key:FILEPATH=file
syntax region CMakeCacheFilePathVar matchgroup=CMakeCacheType start=":FILEPATH="ms=s+1,rs=e-1 end="$" contains=CMakeCacheFilePath keepend
syntax region CMakeCacheFilePath    start="="ms=s+1 end="$" contained

" Highlight 'value' in key:STATIC=value
syntax region CMakeCacheStaticVar   matchgroup=CMakeCacheType start=":STATIC="ms=s+1,rs=e-1 end="$" contains=CMakeCacheStatic keepend
syntax region CMakeCacheStatic      start="="ms=s+1 end="$" contained

" Highlight 'value' in key:Internal=value
syntax region CMakeCacheInternalVar matchgroup=CMakeCacheType start=":INTERNAL="ms=s+1,rs=e-1 end="$" contains=CMakeCacheInternal keepend
syntax region CMakeCacheInternal    start="="ms=s+1 end="$" contained

hi def link CMakeCacheComment   Comment
hi def link CMakeCacheKey       Identifier
hi def link CMakeCacheString    String
hi def link CMakeCacheBool      Constant
hi def link CMakeCachePath      Directory
hi def link CMakeCacheFilePath  Normal
hi def link CMakeCacheStatic    Normal
hi def link CMakeCacheInternal  Normal

" Highlight 'type' in key:type=value
hi def link CMakeCacheType      Type

let b:current_syntax = 'cmakecache'

let &cpoptions = s:cpo_save
unlet s:cpo_save
