" Octave indent file
" Language: Octave
" Version: 1.2
" Maintainer: Rik <rik@octave.org>
" Last Change: March 27, 2023

" Notes
"   Designed for Octave grammar 4.0.0 and above (classdef keywords).
"   This script is not a replacement for a true 'equalprg' indenter.
"
" TODO
"   Indent across line continuation ('...$')
"   Indent based on brackets


" Only load this indent file when no other was loaded
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetOctaveIndent()
setlocal indentkeys=!,o,O,0=end,0=else,0=case,0=otherwise,0=endswitch,0=unwind_protect_cleanup,0=catch,0=until

let b:undo_indent = "setlocal indentexpr< indentkeys<"

" Only define the function once
if exists("*GetOctaveIndent")
  finish
endif

let s:cpo_saved = &cpo
set cpo&vim

function GetOctaveIndent()

  " Find a non-blank line above the current line
  let lnum = prevnonblank(v:lnum - 1)

  if lnum == 0
    return 0   " At the start of the file; use zero indent.
  endif

  " Indent of preceding non-blank line
  let ind = indent(lnum)
  " Text of preceding non-blank line
  let prev_text = getline(lnum)
  " Text of current line
  let curr_text = getline(v:lnum)

  " Increase indent based on keywords from previous line
  if prev_text =~ '^\s*\%(if\|else\|elseif\|for\|while\|do\|case\|switch\|otherwise\|unwind_protect\|unwind_protect_cleanup\|try\|catch\|parfor\)\>'
    let ind += &sw

  " Additional keywords that increase indent
  elseif prev_text =~ '^\s*\%(function\|classdef\|properties\|methods\|enumeration\|events\)\>'
    let ind += &sw
  endif

  " Decrease indent based on keywords in current line
  if curr_text =~ '^\s*\%(end\%(if\|function\|for\|while\|switch\|_unwind_protect\|_try_catch\|parfor\|classdef\|enumeration\|events\|methods\|properties\)\?\|else\|elseif\|case\|otherwise\|unwind_protect_cleanup\|catch\|until\)\>'
    let ind -= &sw

    " switch blocks are doubly indented
    if curr_text =~ '^\s*\%(case\|otherwise\)'
      " Find previous non-blank, non-comment line
      while lnum > 0 && prev_text =~ '^\s*\%($\|[%#]\)'
        let lnum -= 1
        let prev_text = getline(lnum)
      endwhile
      if prev_text =~ '^\s*switch'
        let ind += &sw  " undo de-indent for first statement in switch block
      endif
    elseif curr_text =~ '^\s*endswitch' && prev_text !~ '^\s*switch'
      let ind -= &sw    " extra de-indent required to leave switch blocks
    endif
  endif

  return ind

endfunction

" Restore modified global values
let &cpo = s:cpo_saved
unlet s:cpo_saved

" vim:sw=2:sts=2:expandtab
