let g:vimtex_view_general_viewer = 'SumatraPDF'
let g:vimtex_view_general_options
  \ = '-reuse-instance -forward-search @tex @line @pdf'
let g:vimtex_quickfix_mode = 0
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
call vimtex#imaps#add_map({
    \ 'lhs' : 'B',
    \ 'rhs' : 'vimtex#imaps#style_math("mathbb")',
    \ 'expr' : 1,
    \ 'leader' : '#',
    \ 'wrapper' : 'vimtex#imaps#wrap_math'
    \})
