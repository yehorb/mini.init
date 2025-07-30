if exists('g:loaded_relmap')
  finish
endif
let g:loaded_relmap = 1

let s:save_cpo = &cpo
set cpo&vim

let s:relist = maplist()->filter({_, map -> map['mode'] ==# 'l'})
let g:relmap = reduce(s:relist,
      \ { acc, map -> acc->extend({map['rhs']: map['lhs']}) },
      \ {})

function! relmap#relmap(input)
  return substitute(a:input,
        \ '.',
        \ {m -> has_key(g:relmap, m[0]) ? g:relmap[m[0]] : m[0]},
        \ 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:sts=2:sw=2:et:
