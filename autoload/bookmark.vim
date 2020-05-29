let s:cached_list = get(s:, 'cached_list', {})

function! s:bookmark_file(tag)
    return g:bookmark_dir.(a:tag)
endfunction

function! bookmark#list(...)
    let l:tag = !empty(a:0)? a:1 : 'default'
    if !has_key(s:cached_list, l:tag)
        let s:cached_list[l:tag] = readfile(s:bookmark_file(l:tag))
    endif
    return s:cached_list[l:tag]
endfunction

function! bookmark#add(...)
    let l:tag = !empty(a:0)? a:1 : 'default'
    let l:list = bookmark#list(l:tag)
    let l:list = uniq(extend(l:list, [expand('%:p')]))
    call writefile(l:list, s:bookmark_file(l:tag))
endfunction

function! bookmark#del(...)
    let l:tag = !empty(a:0)? a:1 : 'default'
    let l:list = bookmark#list(l:tag)
    let l:ind = index(l:list, expand('%:p'))
    if l:ind > -1
        unlet l:list[l:ind]
        call writefile(l:list, s:bookmark_file(l:tag))
    endif
endfunction

function! bookmark#edit(...)
    let l:tag = !empty(a:0)? a:1 : 'default'
    exec 'split '.s:bookmark_file(l:tag)
    wincmd J
endfunction

function! bookmark#goimpl()
   let l:path = getline('.')
   let l:can_go = v:true
   if !filereadable(l:path) && !isdirectory(l:path)
       echoerr "Not found: ".l:path
       let l:can_go = v:false
   endif
   nunmap <buffer> <cr>
   quit
   if l:can_go
       exec g:bookmark_opencmd.' '.l:path
       if isdirectory(l:path) && exists(':NETRTabdrop')
           exec g:_NETRPY.'with ranger.KeepPreviewState(): pass'
       endif
   endif
endfunction

function! bookmark#go(...)
    call bookmark#edit()
    nnoremap <buffer> <cr> :call bookmark#goimpl()<cr>
endfunction
