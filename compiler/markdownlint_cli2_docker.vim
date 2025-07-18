if exists("current_compiler")
    finish
endif
let current_compiler = "markdownlint_cli2_docker"

let s:cpo_save = &cpo
set cpo&vim

let s:makeprg = ''
    \ .. 'docker run --rm'
    \ .. ' -v ' .. shellescape(fnamemodify(getcwd(), ':p') .. ':/src:rw,Z')
    \ .. ' --workdir /src'
    \ .. ' davidanson/markdownlint-cli2:latest'
    \ .. ' %:S'
" Other examples: https://github.com/search?q=%2Fmakeprg.*markdownlint%2F&type=code
let s:errorformat = '%f:%l:%c %m'

execute 'CompilerSet makeprg=' .. escape(s:makeprg, ' "\')
execute 'CompilerSet errorformat=' .. escape(s:errorformat, ' "\')

let &cpo = s:cpo_save
unlet s:cpo_save
