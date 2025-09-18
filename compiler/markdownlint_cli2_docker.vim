if exists('current_compiler')
    finish
endif
let current_compiler = 'markdownlint_cli2_docker'

let s:cpo_save = &cpo
set cpo&vim

" Use single quotes to wrap long strings, as double quotes require escaping in
" PowerShell
let s:makeprg = ''
    \ .. 'docker run --rm'
    \ .. " --mount 'type=bind,src=" .. getcwd() .. ",dst=/src,ro'"
    \ .. ' --workdir /src'
    \ .. ' davidanson/markdownlint-cli2:latest'
    \ .. " '%:.'"
" Other examples: https://github.com/search?q=%2Fmakeprg.*markdownlint%2F&type=code
let s:errorformat = '%f:%l:%c %m,%f:%l %m'

execute 'CompilerSet makeprg=' .. escape(s:makeprg, ' ')
execute 'CompilerSet errorformat=' .. escape(s:errorformat, ' ')

let &cpo = s:cpo_save
unlet s:cpo_save
