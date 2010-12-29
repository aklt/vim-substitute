" 
" substitute.vim -- mappings for using the s/// command on the word under the cursor
"
" Author:  Anders Thøgersen <anders [at] bladre.dk>
" Date:    29-Dec-2010
" Version: 1.2
"
" $Id$
"
" See substitute.txt for help
"
" GetLatestVimScripts: 1167 1 :AutoInstall: substitute.vba.gz
" 
" TODO
"
"    Don't require g:substitute_Register
"    

if exists('loaded_substitute') || &cp
  finish
endif
let loaded_substitute = 1

let s:savedCpo = &cpoptions
set cpoptions&vim

" Configuration
if !exists("g:substitute_PromptMap")
    let g:substitute_PromptMap = ";'"
endif
if !exists("g:substitute_NoPromptMap")
    let g:substitute_NoPromptMap = ';;'
endif
if !exists("g:substitute_GlobalMap")
    let g:substitute_GlobalMap = "';"
endif
if !exists("g:substitute_Register")
    let g:substitute_Register = '9'
endif
if !exists("g:substitute_SingleWordSize")
    let g:substitute_SingleWordSize = 3
endif
     
" define the mappings 
exe 'nnoremap <unique> '. g:substitute_NoPromptMap .' yiw:let @'. g:substitute_Register ."=':%'.<SID>SubstituteAltSubst(@\", 'g', 0)<Cr>@". g:substitute_Register
exe 'nnoremap <unique> '. g:substitute_GlobalMap   .' yiw:let @'. g:substitute_Register ."=':%'.<SID>SubstituteAltSubst(@\", 'gc', 1)<Cr>@". g:substitute_Register
exe 'nnoremap <unique> '. g:substitute_PromptMap   .' yiw:let @'. g:substitute_Register ."=':%'.<SID>SubstituteAltSubst(@\", 'gc', 0)<Cr>@". g:substitute_Register
exe 'vnoremap <unique> '. g:substitute_NoPromptMap .' <ESC>gvy:let @'. g:substitute_Register ."=<SID>SubstituteVisualAltSubst(@\", 'g', 0)<Cr>@". g:substitute_Register
exe 'vnoremap <unique> '. g:substitute_GlobalMap   .' <ESC>gvy:let @'. g:substitute_Register ."=<SID>SubstituteVisualAltSubst(@\", 'gc', 1)<Cr>@". g:substitute_Register
exe 'vnoremap <unique> '. g:substitute_PromptMap   .' <ESC>gvy:let @'. g:substitute_Register ."=<SID>SubstituteVisualAltSubst(@\", 'gc', 0)<Cr>@". g:substitute_Register
cnoremap <unique> <C-R><C-R> <C-R>"

" Remove the default key sequences
unlet g:substitute_Register
unlet g:substitute_PromptMap
unlet g:substitute_NoPromptMap

fun! <SID>SubstituteAltSubst(txt, flags, global)
    let d = <SID>GetSubstDelimiter(a:txt)
    exe "let left = '\<Left>'"
    let mv = left . left
    if a:flags == 'gc'
        let mv = mv . left 
    endif
    if strlen(a:txt)==0
        let mv = mv . left
    endif
    let @" = <SID>Escape(a:txt) 
    if a:global == 1
        let len = strlen(@") + 4
        while len > 0
            let len = len - 1
            let mv = mv . left
        endwhile
        return 'g' . d . d . 's' . d . @" . d . d . a:flags . mv
    endif
    return 's' . d . @" . d . d . a:flags . mv 
endfun

fun! <SID>SubstituteVisualAltSubst(txt, flags, global)
    exe "let left = '\<Left>'"
    let mv = left . left . left
    if a:flags == 'gc'
        let mv = mv . left 
    endif
    if line("'<")!=line("'>") || (line("'<")==line("'>") && col("'<")==1 && col("'>")==col("$"))
        let d = <SID>GetSubstDelimiter(a:txt)
        return ":'<,'>s" .d .d .d . a:flags . mv
    else
        return ':%' . <SID>SubstituteAltSubst(a:txt, a:flags, a:global)    
    endif
endfun

" feel free to add more :-)
fun! <SID>GetSubstDelimiter(txt)
    if stridx(a:txt, '/') == -1 && stridx(a:txt, '\\') == -1
        return '/'
    elseif stridx(a:txt, ':') == -1
        return ':'
    elseif stridx(a:txt, '#') == -1
        return '#'
    elseif stridx(a:txt, ';') == -1
        return ';'
    elseif stridx(a:txt, '~') == -1
        return '~'
    elseif stridx(a:txt, '!') == -1
        return '!'
    else 
        return '*'
    endif
endfun

" escape as little as possible
fun! <SID>Escape(txt)
    let esc = '\\.~[]'
    let len = strlen(a:txt)
    if stridx(a:txt, '$') == (strlen(a:txt) -1)
        let esc = esc . '$'
    endif
    if stridx(a:txt, '^') == 0
        let esc = esc . '^'
    endif
    if stridx(a:txt, '*') > 0
        let esc = esc . '*'
    endif
    let esc = escape(a:txt, esc)
    if g:substitute_SingleWordSize > 0 && len <= g:substitute_SingleWordSize
        let esc = '\<'. esc .'\>'
    endif
    return esc
endfun

let &cpoptions = s:savedCpo

" vi: nowrap
