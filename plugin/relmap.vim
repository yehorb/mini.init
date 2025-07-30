let g:relist = maplist()->filter({_, map -> map['mode'] == 'l'})
let g:relmap = reduce(g:relist, { acc, map -> acc->extend({map['rhs']: map['lhs']}) }, {})
function! Relmap(input)
    return substitute(a:input, '.', {m -> has_key(g:relmap, m[0]) ? g:relmap[m[0]] : m[0]}, 'g')
endfunction
