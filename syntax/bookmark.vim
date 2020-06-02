if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "bookmark"
syntax match Comment '^["#].*$'
