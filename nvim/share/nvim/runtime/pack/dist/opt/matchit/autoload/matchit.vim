"  matchit.vim: (global plugin) Extended "%" matching
"  autload script of matchit plugin, see ../plugin/matchit.vim
"  Last Change: May 20, 2024

" Neovim does not support scriptversion
if has("vimscript-4")
  scriptversion 4
endif

let s:last_mps = ""
let s:last_words = ":"
let s:patBR = ""

let s:save_cpo = &cpo
set cpo&vim

" Auto-complete mappings:  (not yet "ready for prime time")
" TODO Read :help write-plugin for the "right" way to let the user
" specify a key binding.
"   let g:match_auto = '<C-]>'
"   let g:match_autoCR = '<C-CR>'
" if exists("g:match_auto")
"   execute "inoremap " . g:match_auto . ' x<Esc>"=<SID>Autocomplete()<CR>Pls'
" endif
" if exists("g:match_autoCR")
"   execute "inoremap " . g:match_autoCR . ' <CR><C-R>=<SID>Autocomplete()<CR>'
" endif
" if exists("g:match_gthhoh")
"   execute "inoremap " . g:match_gthhoh . ' <C-O>:call <SID>Gthhoh()<CR>'
" endif " gthhoh = "Get the heck out of here!"

let s:notslash = '\\\@1<!\%(\\\\\)*'

function s:RestoreOptions()
  " In s:CleanUp(), :execute "set" restore_options .
  let restore_options = ""
  if get(b:, 'match_ignorecase', &ic) != &ic
    let restore_options ..= (&ic ? " " : " no") .. "ignorecase"
    let &ignorecase = b:match_ignorecase
  endif
  if &ve != ''
    let restore_options = " ve=" .. &ve .. restore_options
    set ve=
  endif
  if &smartcase
    let restore_options = " smartcase " .. restore_options
    set nosmartcase
  endif
  return restore_options
endfunction

function matchit#Match_wrapper(word, forward, mode) range
  let restore_options = s:RestoreOptions()
  " In s:CleanUp(), we may need to check whether the cursor moved forward.
  let startpos = [line("."), col(".")]
  " if a count has been applied, use the default [count]% mode (see :h N%)
  if v:count
    exe "normal! " .. v:count .. "%"
    return s:CleanUp(restore_options, a:mode, startpos)
  end
  if a:mode =~# "v" && mode(1) =~# 'ni'
    exe "norm! gv"
  elseif a:mode == "o" && mode(1) !~# '[vV]'
    exe "norm! v"
  " If this function was called from Visual mode, make sure that the cursor
  " is at the correct end of the Visual range:
  elseif a:mode == "v"
    execute "normal! gv\<Esc>"
    let startpos = [line("."), col(".")]
  endif

  " First step:  if not already done, set the script variables
  "   s:do_BR   flag for whether there are backrefs
  "   s:pat     parsed version of b:match_words
  "   s:all     regexp based on s:pat and the default groups
  if !exists("b:match_words") || b:match_words == ""
    let match_words = ""
  elseif b:match_words =~ ":"
    let match_words = b:match_words
  else
    " Allow b:match_words = "GetVimMatchWords()" .
    execute "let match_words =" b:match_words
  endif
" Thanks to Preben "Peppe" Guldberg and Bram Moolenaar for this suggestion!
  if (match_words != s:last_words) || (&mps != s:last_mps)
      \ || exists("b:match_debug")
    let s:last_mps = &mps
    " quote the special chars in 'matchpairs', replace [,:] with \| and then
    " append the builtin pairs (/*, */, #if, #ifdef, #ifndef, #else, #elif,
    " #elifdef, #elifndef, #endif)
    let default = escape(&mps, '[$^.*~\\/?]') .. (strlen(&mps) ? "," : "") ..
      \ '\/\*:\*\/,#\s*if\%(n\=def\)\=:#\s*else\>:#\s*elif\%(n\=def\)\=\>:#\s*endif\>'
    " s:all = pattern with all the keywords
    let match_words = match_words .. (strlen(match_words) ? "," : "") .. default
    let s:last_words = match_words
    if match_words !~ s:notslash .. '\\\d'
      let s:do_BR = 0
      let s:pat = match_words
    else
      let s:do_BR = 1
      let s:pat = s:ParseWords(match_words)
    endif
    let s:all = substitute(s:pat, s:notslash .. '\zs[,:]\+', '\\|', 'g')
    " un-escape \, to ,
    let s:all = substitute(s:all, '\\,', ',', 'g')
    " Just in case there are too many '\(...)' groups inside the pattern, make
    " sure to use \%(...) groups, so that error E872 can be avoided
    let s:all = substitute(s:all, '\\(', '\\%(', 'g')
    let s:all = '\%(' .. s:all .. '\)'
    if exists("b:match_debug")
      let b:match_pat = s:pat
    endif
    " Reconstruct the version with unresolved backrefs.
    let s:patBR = substitute(match_words .. ',',
      \ s:notslash .. '\zs[,:]*,[,:]*', ',', 'g')
    let s:patBR = substitute(s:patBR, s:notslash .. '\zs:\{2,}', ':', 'g')
    " un-escape \, to ,
    let s:patBR = substitute(s:patBR, '\\,', ',', 'g')
  endif

  " Second step:  set the following local variables:
  "     matchline = line on which the cursor started
  "     curcol    = number of characters before match
  "     prefix    = regexp for start of line to start of match
  "     suffix    = regexp for end of match to end of line
  " Require match to end on or after the cursor and prefer it to
  " start on or before the cursor.
  let matchline = getline(startpos[0])
  if a:word != ''
    " word given
    if a:word !~ s:all
      echohl WarningMsg|echo 'Missing rule for word:"'.a:word.'"'|echohl NONE
      return s:CleanUp(restore_options, a:mode, startpos)
    endif
    let matchline = a:word
    let curcol = 0
    let prefix = '^\%('
    let suffix = '\)$'
  " Now the case when "word" is not given
  else  " Find the match that ends on or after the cursor and set curcol.
    let regexp = s:Wholematch(matchline, s:all, startpos[1]-1)
    let curcol = match(matchline, regexp)
    " If there is no match, give up.
    if curcol == -1
      return s:CleanUp(restore_options, a:mode, startpos)
    endif
    let endcol = matchend(matchline, regexp)
    let suf = strlen(matchline) - endcol
    let prefix = (curcol ? '^.*\%' .. (curcol + 1) .. 'c\%(' : '^\%(')
    let suffix = (suf ? '\)\%' .. (endcol + 1) .. 'c.*$'  : '\)$')
  endif
  if exists("b:match_debug")
    let b:match_match = matchstr(matchline, regexp)
    let b:match_col = curcol+1
  endif

  " Third step:  Find the group and single word that match, and the original
  " (backref) versions of these.  Then, resolve the backrefs.
  " Set the following local variable:
  " group = colon-separated list of patterns, one of which matches
  "       = ini:mid:fin or ini:fin
  "
  " Now, set group and groupBR to the matching group: 'if:endif' or
  " 'while:endwhile' or whatever.  A bit of a kluge:  s:Choose() returns
  " group . "," . groupBR, and we pick it apart.
  let group = s:Choose(s:pat, matchline, ",", ":", prefix, suffix, s:patBR)
  let i = matchend(group, s:notslash .. ",")
  let groupBR = strpart(group, i)
  let group = strpart(group, 0, i-1)
  " Now, matchline =~ prefix . substitute(group,':','\|','g') . suffix
  if s:do_BR " Do the hard part:  resolve those backrefs!
    let group = s:InsertRefs(groupBR, prefix, group, suffix, matchline)
  endif
  if exists("b:match_debug")
    let b:match_wholeBR = groupBR
    let i = matchend(groupBR, s:notslash .. ":")
    let b:match_iniBR = strpart(groupBR, 0, i-1)
  endif

  " Fourth step:  Set the arguments for searchpair().
  let i = matchend(group, s:notslash .. ":")
  let j = matchend(group, '.*' .. s:notslash .. ":")
  let ini = strpart(group, 0, i-1)
  let mid = substitute(strpart(group, i,j-i-1), s:notslash .. '\zs:', '\\|', 'g')
  let fin = strpart(group, j)
  "Un-escape the remaining , and : characters.
  let ini = substitute(ini, s:notslash .. '\zs\\\(:\|,\)', '\1', 'g')
  let mid = substitute(mid, s:notslash .. '\zs\\\(:\|,\)', '\1', 'g')
  let fin = substitute(fin, s:notslash .. '\zs\\\(:\|,\)', '\1', 'g')
  " searchpair() requires that these patterns avoid \(\) groups.
  let ini = substitute(ini, s:notslash .. '\zs\\(', '\\%(', 'g')
  let mid = substitute(mid, s:notslash .. '\zs\\(', '\\%(', 'g')
  let fin = substitute(fin, s:notslash .. '\zs\\(', '\\%(', 'g')
  " Set mid.  This is optimized for readability, not micro-efficiency!
  if a:forward && matchline =~ prefix .. fin .. suffix
    \ || !a:forward && matchline =~ prefix .. ini .. suffix
    let mid = ""
  endif
  " Set flag.  This is optimized for readability, not micro-efficiency!
  if a:forward && matchline =~ prefix .. fin .. suffix
    \ || !a:forward && matchline !~ prefix .. ini .. suffix
    let flag = "bW"
  else
    let flag = "W"
  endif
  " Set skip.
  if exists("b:match_skip")
    let skip = b:match_skip
  elseif exists("b:match_comment") " backwards compatibility and testing!
    let skip = "r:" .. b:match_comment
  else
    let skip = 's:comment\|string'
  endif
  let skip = s:ParseSkip(skip)
  if exists("b:match_debug")
    let b:match_ini = ini
    let b:match_tail = (strlen(mid) ? mid .. '\|' : '') .. fin
  endif

  " Fifth step:  actually start moving the cursor and call searchpair().
  " Later, :execute restore_cursor to get to the original screen.
  let view = winsaveview()
  call cursor(0, curcol + 1)
  if skip =~ 'synID' && !(has("syntax") && exists("g:syntax_on"))
        \ || skip =~ 'v:lua.vim.treesitter' && !exists('b:ts_highlight')
    let skip = "0"
  else
    execute "if " .. skip .. "| let skip = '0' | endif"
  endif
  let sp_return = searchpair(ini, mid, fin, flag, skip)
  if &selection isnot# 'inclusive' && a:mode == 'v'
    " move cursor one pos to the right, because selection is not inclusive
    " add virtualedit=onemore, to make it work even when the match ends the
    " line
    if !(col('.') < col('$')-1)
      let eolmark=1 " flag to set a mark on eol (since we cannot move there)
    endif
    norm! l
  endif
  let final_position = "call cursor(" .. line(".") .. "," .. col(".") .. ")"
  " Restore cursor position and original screen.
  call winrestview(view)
  normal! m'
  if sp_return > 0
    execute final_position
  endif
  if exists('eolmark') && eolmark
    call setpos("''", [0, line('.'), col('$'), 0]) " set mark on the eol
  endif
  return s:CleanUp(restore_options, a:mode, startpos, mid .. '\|' .. fin)
endfun

" Restore options and do some special handling for Operator-pending mode.
" The optional argument is the tail of the matching group.
fun! s:CleanUp(options, mode, startpos, ...)
  if strlen(a:options)
    execute "set" a:options
  endif
  " Open folds, if appropriate.
  if a:mode != "o"
    if &foldopen =~ "percent"
      normal! zv
    endif
    " In Operator-pending mode, we want to include the whole match
    " (for example, d%).
    " This is only a problem if we end up moving in the forward direction.
  elseif (a:startpos[0] < line(".")) ||
        \ (a:startpos[0] == line(".") && a:startpos[1] < col("."))
    if a:0
      " Check whether the match is a single character.  If not, move to the
      " end of the match.
      let matchline = getline(".")
      let currcol = col(".")
      let regexp = s:Wholematch(matchline, a:1, currcol-1)
      let endcol = matchend(matchline, regexp)
      if endcol > currcol  " This is NOT off by one!
        call cursor(0, endcol)
      endif
    endif " a:0
  endif " a:mode != "o" && etc.
  return 0
endfun

" Example (simplified HTML patterns):  if
"   a:groupBR   = '<\(\k\+\)>:</\1>'
"   a:prefix    = '^.\{3}\('
"   a:group     = '<\(\k\+\)>:</\(\k\+\)>'
"   a:suffix    = '\).\{2}$'
"   a:matchline =  "123<tag>12" or "123</tag>12"
" then extract "tag" from a:matchline and return "<tag>:</tag>" .
fun! s:InsertRefs(groupBR, prefix, group, suffix, matchline)
  if a:matchline !~ a:prefix ..
    \ substitute(a:group, s:notslash .. '\zs:', '\\|', 'g') .. a:suffix
    return a:group
  endif
  let i = matchend(a:groupBR, s:notslash .. ':')
  let ini = strpart(a:groupBR, 0, i-1)
  let tailBR = strpart(a:groupBR, i)
  let word = s:Choose(a:group, a:matchline, ":", "", a:prefix, a:suffix,
    \ a:groupBR)
  let i = matchend(word, s:notslash .. ":")
  let wordBR = strpart(word, i)
  let word = strpart(word, 0, i-1)
  " Now, a:matchline =~ a:prefix . word . a:suffix
  if wordBR != ini
    let table = s:Resolve(ini, wordBR, "table")
  else
    let table = ""
    let d = 0
    while d < 10
      if tailBR =~ s:notslash .. '\\' .. d
        let table = table .. d
      else
        let table = table .. "-"
      endif
      let d = d + 1
    endwhile
  endif
  let d = 9
  while d
    if table[d] != "-"
      let backref = substitute(a:matchline, a:prefix .. word .. a:suffix,
        \ '\' .. table[d], "")
        " Are there any other characters that should be escaped?
      let backref = escape(backref, '*,:')
      execute s:Ref(ini, d, "start", "len")
      let ini = strpart(ini, 0, start) .. backref .. strpart(ini, start+len)
      let tailBR = substitute(tailBR, s:notslash .. '\zs\\' .. d,
        \ escape(backref, '\\&'), 'g')
    endif
    let d = d-1
  endwhile
  if exists("b:match_debug")
    if s:do_BR
      let b:match_table = table
      let b:match_word = word
    else
      let b:match_table = ""
      let b:match_word = ""
    endif
  endif
  return ini .. ":" .. tailBR
endfun

" Input a comma-separated list of groups with backrefs, such as
"   a:groups = '\(foo\):end\1,\(bar\):end\1'
" and return a comma-separated list of groups with backrefs replaced:
"   return '\(foo\):end\(foo\),\(bar\):end\(bar\)'
fun! s:ParseWords(groups)
  let groups = substitute(a:groups .. ",", s:notslash .. '\zs[,:]*,[,:]*', ',', 'g')
  let groups = substitute(groups, s:notslash .. '\zs:\{2,}', ':', 'g')
  let parsed = ""
  while groups =~ '[^,:]'
    let i = matchend(groups, s:notslash .. ':')
    let j = matchend(groups, s:notslash .. ',')
    let ini = strpart(groups, 0, i-1)
    let tail = strpart(groups, i, j-i-1) .. ":"
    let groups = strpart(groups, j)
    let parsed = parsed .. ini
    let i = matchend(tail, s:notslash .. ':')
    while i != -1
      " In 'if:else:endif', ini='if' and word='else' and then word='endif'.
      let word = strpart(tail, 0, i-1)
      let tail = strpart(tail, i)
      let i = matchend(tail, s:notslash .. ':')
      let parsed = parsed .. ":" .. s:Resolve(ini, word, "word")
    endwhile " Now, tail has been used up.
    let parsed = parsed .. ","
  endwhile " groups =~ '[^,:]'
  let parsed = substitute(parsed, ',$', '', '')
  return parsed
endfun

" TODO I think this can be simplified and/or made more efficient.
" TODO What should I do if a:start is out of range?
" Return a regexp that matches all of a:string, such that
" matchstr(a:string, regexp) represents the match for a:pat that starts
" as close to a:start as possible, before being preferred to after, and
" ends after a:start .
" Usage:
" let regexp = s:Wholematch(getline("."), 'foo\|bar', col(".")-1)
" let i      = match(getline("."), regexp)
" let j      = matchend(getline("."), regexp)
" let match  = matchstr(getline("."), regexp)
fun! s:Wholematch(string, pat, start)
  let group = '\%(' .. a:pat .. '\)'
  let prefix = (a:start ? '\(^.*\%<' .. (a:start + 2) .. 'c\)\zs' : '^')
  let len = strlen(a:string)
  let suffix = (a:start+1 < len ? '\(\%>' .. (a:start+1) .. 'c.*$\)\@=' : '$')
  if a:string !~ prefix .. group .. suffix
    let prefix = ''
  endif
  return prefix .. group .. suffix
endfun

" No extra arguments:  s:Ref(string, d) will
" find the d'th occurrence of '\(' and return it, along with everything up
" to and including the matching '\)'.
" One argument:  s:Ref(string, d, "start") returns the index of the start
" of the d'th '\(' and any other argument returns the length of the group.
" Two arguments:  s:Ref(string, d, "foo", "bar") returns a string to be
" executed, having the effect of
"   :let foo = s:Ref(string, d, "start")
"   :let bar = s:Ref(string, d, "len")
fun! s:Ref(string, d, ...)
  let len = strlen(a:string)
  if a:d == 0
    let start = 0
  else
    let cnt = a:d
    let match = a:string
    while cnt
      let cnt = cnt - 1
      let index = matchend(match, s:notslash .. '\\(')
      if index == -1
        return ""
      endif
      let match = strpart(match, index)
    endwhile
    let start = len - strlen(match)
    if a:0 == 1 && a:1 == "start"
      return start - 2
    endif
    let cnt = 1
    while cnt
      let index = matchend(match, s:notslash .. '\\(\|\\)') - 1
      if index == -2
        return ""
      endif
      " Increment if an open, decrement if a ')':
      let cnt = cnt + (match[index]=="(" ? 1 : -1)  " ')'
      let match = strpart(match, index+1)
    endwhile
    let start = start - 2
    let len = len - start - strlen(match)
  endif
  if a:0 == 1
    return len
  elseif a:0 == 2
    return "let " .. a:1 .. "=" .. start .. "| let " .. a:2 .. "=" .. len
  else
    return strpart(a:string, start, len)
  endif
endfun

" Count the number of disjoint copies of pattern in string.
" If the pattern is a literal string and contains no '0' or '1' characters
" then s:Count(string, pattern, '0', '1') should be faster than
" s:Count(string, pattern).
fun! s:Count(string, pattern, ...)
  let pat = escape(a:pattern, '\\')
  if a:0 > 1
    let foo = substitute(a:string, '[^' .. a:pattern .. ']', "a:1", "g")
    let foo = substitute(a:string, pat, a:2, "g")
    let foo = substitute(foo, '[^' .. a:2 .. ']', "", "g")
    return strlen(foo)
  endif
  let result = 0
  let foo = a:string
  let index = matchend(foo, pat)
  while index != -1
    let result = result + 1
    let foo = strpart(foo, index)
    let index = matchend(foo, pat)
  endwhile
  return result
endfun

" s:Resolve('\(a\)\(b\)', '\(c\)\2\1\1\2') should return table.word, where
" word = '\(c\)\(b\)\(a\)\3\2' and table = '-32-------'.  That is, the first
" '\1' in target is replaced by '\(a\)' in word, table[1] = 3, and this
" indicates that all other instances of '\1' in target are to be replaced
" by '\3'.  The hard part is dealing with nesting...
" Note that ":" is an illegal character for source and target,
" unless it is preceded by "\".
fun! s:Resolve(source, target, output)
  let word = a:target
  let i = matchend(word, s:notslash .. '\\\d') - 1
  let table = "----------"
  while i != -2 " There are back references to be replaced.
    let d = word[i]
    let backref = s:Ref(a:source, d)
    " The idea is to replace '\d' with backref.  Before we do this,
    " replace any \(\) groups in backref with :1, :2, ... if they
    " correspond to the first, second, ... group already inserted
    " into backref.  Later, replace :1 with \1 and so on.  The group
    " number w+b within backref corresponds to the group number
    " s within a:source.
    " w = number of '\(' in word before the current one
    let w = s:Count(
    \ substitute(strpart(word, 0, i-1), '\\\\', '', 'g'), '\(', '1')
    let b = 1 " number of the current '\(' in backref
    let s = d " number of the current '\(' in a:source
    while b <= s:Count(substitute(backref, '\\\\', '', 'g'), '\(', '1')
    \ && s < 10
      if table[s] == "-"
        if w + b < 10
          " let table[s] = w + b
          let table = strpart(table, 0, s) .. (w+b) .. strpart(table, s+1)
        endif
        let b = b + 1
        let s = s + 1
      else
        execute s:Ref(backref, b, "start", "len")
        let ref = strpart(backref, start, len)
        let backref = strpart(backref, 0, start) .. ":" .. table[s]
        \ .. strpart(backref, start+len)
        let s = s + s:Count(substitute(ref, '\\\\', '', 'g'), '\(', '1')
      endif
    endwhile
    let word = strpart(word, 0, i-1) .. backref .. strpart(word, i+1)
    let i = matchend(word, s:notslash .. '\\\d') - 1
  endwhile
  let word = substitute(word, s:notslash .. '\zs:', '\\', 'g')
  if a:output == "table"
    return table
  elseif a:output == "word"
    return word
  else
    return table .. word
  endif
endfun

" Assume a:comma = ",".  Then the format for a:patterns and a:1 is
"   a:patterns = "<pat1>,<pat2>,..."
"   a:1 = "<alt1>,<alt2>,..."
" If <patn> is the first pattern that matches a:string then return <patn>
" if no optional arguments are given; return <patn>,<altn> if a:1 is given.
fun! s:Choose(patterns, string, comma, branch, prefix, suffix, ...)
  let tail = (a:patterns =~ a:comma .. "$" ? a:patterns : a:patterns .. a:comma)
  let i = matchend(tail, s:notslash .. a:comma)
  if a:0
    let alttail = (a:1 =~ a:comma .. "$" ? a:1 : a:1 .. a:comma)
    let j = matchend(alttail, s:notslash .. a:comma)
  endif
  let current = strpart(tail, 0, i-1)
  if a:branch == ""
    let currpat = current
  else
    let currpat = substitute(current, s:notslash .. a:branch, '\\|', 'g')
  endif
  " un-escape \, to ,
  let currpat = substitute(currpat, '\\,', ',', 'g')
  while a:string !~ a:prefix .. currpat .. a:suffix
    let tail = strpart(tail, i)
    let i = matchend(tail, s:notslash .. a:comma)
    if i == -1
      return -1
    endif
    let current = strpart(tail, 0, i-1)
    if a:branch == ""
      let currpat = current
    else
      let currpat = substitute(current, s:notslash .. a:branch, '\\|', 'g')
    endif
    if a:0
      let alttail = strpart(alttail, j)
      let j = matchend(alttail, s:notslash .. a:comma)
    endif
  endwhile
  if a:0
    let current = current .. a:comma .. strpart(alttail, 0, j-1)
  endif
  return current
endfun

fun! matchit#Match_debug()
  let b:match_debug = 1 " Save debugging information.
  " pat = all of b:match_words with backrefs parsed
  amenu &Matchit.&pat   :echo b:match_pat<CR>
  " match = bit of text that is recognized as a match
  amenu &Matchit.&match :echo b:match_match<CR>
  " curcol = cursor column of the start of the matching text
  amenu &Matchit.&curcol        :echo b:match_col<CR>
  " wholeBR = matching group, original version
  amenu &Matchit.wh&oleBR       :echo b:match_wholeBR<CR>
  " iniBR = 'if' piece, original version
  amenu &Matchit.ini&BR :echo b:match_iniBR<CR>
  " ini = 'if' piece, with all backrefs resolved from match
  amenu &Matchit.&ini   :echo b:match_ini<CR>
  " tail = 'else\|endif' piece, with all backrefs resolved from match
  amenu &Matchit.&tail  :echo b:match_tail<CR>
  " fin = 'endif' piece, with all backrefs resolved from match
  amenu &Matchit.&word  :echo b:match_word<CR>
  " '\'.d in ini refers to the same thing as '\'.table[d] in word.
  amenu &Matchit.t&able :echo '0:' .. b:match_table .. ':9'<CR>
endfun

" Jump to the nearest unmatched "(" or "if" or "<tag>" if a:spflag == "bW"
" or the nearest unmatched "</tag>" or "endif" or ")" if a:spflag == "W".
" Return a "mark" for the original position, so that
"   let m = MultiMatch("bW", "n") ... call winrestview(m)
" will return to the original position.  If there is a problem, do not
" move the cursor and return {}, unless a count is given, in which case
" go up or down as many levels as possible and again return {}.
" TODO This relies on the same patterns as % matching.  It might be a good
" idea to give it its own matching patterns.
fun! matchit#MultiMatch(spflag, mode)
  let restore_options = s:RestoreOptions()
  let startpos = [line("."), col(".")]
  " save v:count1 variable, might be reset from the restore_cursor command
  let level = v:count1
  if a:mode == "o" && mode(1) !~# '[vV]'
    exe "norm! v"
  endif

  " First step:  if not already done, set the script variables
  "   s:do_BR   flag for whether there are backrefs
  "   s:pat     parsed version of b:match_words
  "   s:all     regexp based on s:pat and the default groups
  " This part is copied and slightly modified from matchit#Match_wrapper().
  if !exists("b:match_words") || b:match_words == ""
    let match_words = ""
    " Allow b:match_words = "GetVimMatchWords()" .
  elseif b:match_words =~ ":"
    let match_words = b:match_words
  else
    execute "let match_words =" b:match_words
  endif
  if (match_words != s:last_words) || (&mps != s:last_mps) ||
    \ exists("b:match_debug")
    let default = escape(&mps, '[$^.*~\\/?]') .. (strlen(&mps) ? "," : "") ..
      \ '\/\*:\*\/,#\s*if\%(n\=def\)\=:#\s*else\>:#\s*elif\>:#\s*endif\>'
    let s:last_mps = &mps
    let match_words = match_words .. (strlen(match_words) ? "," : "") .. default
    let s:last_words = match_words
    if match_words !~ s:notslash .. '\\\d'
      let s:do_BR = 0
      let s:pat = match_words
    else
      let s:do_BR = 1
      let s:pat = s:ParseWords(match_words)
    endif
    let s:all = '\%(' .. substitute(s:pat, '[,:]\+', '\\|', 'g') .. '\)'
    if exists("b:match_debug")
      let b:match_pat = s:pat
    endif
    " Reconstruct the version with unresolved backrefs.
    let s:patBR = substitute(match_words .. ',',
      \ s:notslash .. '\zs[,:]*,[,:]*', ',', 'g')
    let s:patBR = substitute(s:patBR, s:notslash .. '\zs:\{2,}', ':', 'g')
  endif

  " Second step:  figure out the patterns for searchpair()
  " and save the screen, cursor position, and 'ignorecase'.
  " - TODO:  A lot of this is copied from matchit#Match_wrapper().
  " - maybe even more functionality should be split off
  " - into separate functions!
  let openlist = split(s:pat .. ',', s:notslash .. '\zs:.\{-}' .. s:notslash .. ',')
  let midclolist = split(',' .. s:pat, s:notslash .. '\zs,.\{-}' .. s:notslash .. ':')
  call map(midclolist, {-> split(v:val, s:notslash .. ':')})
  let closelist = []
  let middlelist = []
  call map(midclolist, {i,v -> [extend(closelist, v[-1 : -1]),
        \ extend(middlelist, v[0 : -2])]})
  call map(openlist,   {i,v -> v =~# s:notslash .. '\\|' ? '\%(' .. v .. '\)' : v})
  call map(middlelist, {i,v -> v =~# s:notslash .. '\\|' ? '\%(' .. v .. '\)' : v})
  call map(closelist,  {i,v -> v =~# s:notslash .. '\\|' ? '\%(' .. v .. '\)' : v})
  let open   = join(openlist, ',')
  let middle = join(middlelist, ',')
  let close  = join(closelist, ',')
  if exists("b:match_skip")
    let skip = b:match_skip
  elseif exists("b:match_comment") " backwards compatibility and testing!
    let skip = "r:" .. b:match_comment
  else
    let skip = 's:comment\|string'
  endif
  let skip = s:ParseSkip(skip)
  let view = winsaveview()

  " Third step: call searchpair().
  " Replace '\('--but not '\\('--with '\%(' and ',' with '\|'.
  let openpat = substitute(open, '\%(' .. s:notslash .. '\)\@<=\\(', '\\%(', 'g')
  let openpat = substitute(openpat, ',', '\\|', 'g')
  let closepat = substitute(close, '\%(' .. s:notslash .. '\)\@<=\\(', '\\%(', 'g')
  let closepat = substitute(closepat, ',', '\\|', 'g')
  let middlepat = substitute(middle, '\%(' .. s:notslash .. '\)\@<=\\(', '\\%(', 'g')
  let middlepat = substitute(middlepat, ',', '\\|', 'g')

  if skip =~ 'synID' && !(has("syntax") && exists("g:syntax_on"))
        \ || skip =~ 'v:lua.vim.treesitter' && !exists('b:ts_highlight')
    let skip = '0'
  else
    try
      execute "if " .. skip .. "| let skip = '0' | endif"
    catch /^Vim\%((\a\+)\)\=:E363/
      " We won't find anything, so skip searching, should keep Vim responsive.
      return {}
    endtry
  endif
  mark '
  while level
    if searchpair(openpat, middlepat, closepat, a:spflag, skip) < 1
      call s:CleanUp(restore_options, a:mode, startpos)
      return {}
    endif
    let level = level - 1
  endwhile

  " Restore options and return a string to restore the original position.
  call s:CleanUp(restore_options, a:mode, startpos)
  return view
endfun

" Search backwards for "if" or "while" or "<tag>" or ...
" and return "endif" or "endwhile" or "</tag>" or ... .
" For now, this uses b:match_words and the same script variables
" as matchit#Match_wrapper() .  Later, it may get its own patterns,
" either from a buffer variable or passed as arguments.
" fun! s:Autocomplete()
"   echo "autocomplete not yet implemented :-("
"   if !exists("b:match_words") || b:match_words == ""
"     return ""
"   end
"   let startpos = matchit#MultiMatch("bW")
"
"   if startpos == ""
"     return ""
"   endif
"   " - TODO:  figure out whether 'if' or '<tag>' matched, and construct
"   " - the appropriate closing.
"   let matchline = getline(".")
"   let curcol = col(".") - 1
"   " - TODO:  Change the s:all argument if there is a new set of match pats.
"   let regexp = s:Wholematch(matchline, s:all, curcol)
"   let suf = strlen(matchline) - matchend(matchline, regexp)
"   let prefix = (curcol ? '^.\{'  . curcol . '}\%(' : '^\%(')
"   let suffix = (suf ? '\).\{' . suf . '}$'  : '\)$')
"   " Reconstruct the version with unresolved backrefs.
"   let patBR = substitute(b:match_words.',', '[,:]*,[,:]*', ',', 'g')
"   let patBR = substitute(patBR, ':\{2,}', ':', "g")
"   " Now, set group and groupBR to the matching group: 'if:endif' or
"   " 'while:endwhile' or whatever.
"   let group = s:Choose(s:pat, matchline, ",", ":", prefix, suffix, patBR)
"   let i = matchend(group, s:notslash . ",")
"   let groupBR = strpart(group, i)
"   let group = strpart(group, 0, i-1)
"   " Now, matchline =~ prefix . substitute(group,':','\|','g') . suffix
"   if s:do_BR
"     let group = s:InsertRefs(groupBR, prefix, group, suffix, matchline)
"   endif
" " let g:group = group
"
"   " - TODO:  Construct the closing from group.
"   let fake = "end" . expand("<cword>")
"   execute startpos
"   return fake
" endfun

" Close all open structures.  "Get the heck out of here!"
" fun! s:Gthhoh()
"   let close = s:Autocomplete()
"   while strlen(close)
"     put=close
"     let close = s:Autocomplete()
"   endwhile
" endfun

" Parse special strings as typical skip arguments for searchpair():
"   s:foo becomes (current syntax item) =~ foo
"   S:foo becomes (current syntax item) !~ foo
"   r:foo becomes (line before cursor) =~ foo
"   R:foo becomes (line before cursor) !~ foo
"   t:foo becomes (current treesitter captures) =~ foo
"   T:foo becomes (current treesitter captures) !~ foo
fun! s:ParseSkip(str)
  let skip = a:str
  if skip[1] == ":"
    if skip[0] ==# "t" || skip[0] ==# "s" && &syntax != 'on' && exists("b:ts_highlight")
      let skip = "match(v:lua.vim.treesitter.get_captures_at_cursor(), '" .. strpart(skip,2) .. "') != -1"
    elseif skip[0] ==# "T" || skip[0] ==# "S" && &syntax != 'on' && exists("b:ts_highlight")
      let skip = "match(v:lua.vim.treesitter.get_captures_at_cursor(), '" .. strpart(skip,2) .. "') == -1"
    elseif skip[0] ==# "s"
      let skip = "synIDattr(synID(line('.'),col('.'),1),'name') =~? '" ..
        \ strpart(skip,2) .. "'"
    elseif skip[0] ==# "S"
      let skip = "synIDattr(synID(line('.'),col('.'),1),'name') !~? '" ..
        \ strpart(skip,2) .. "'"
    elseif skip[0] ==# "r"
      let skip = "strpart(getline('.'),0,col('.'))=~'" .. strpart(skip,2) .. "'"
    elseif skip[0] ==# "R"
      let skip = "strpart(getline('.'),0,col('.'))!~'" .. strpart(skip,2) .. "'"
    endif
  endif
  return skip
endfun

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:sts=2:sw=2:et:
