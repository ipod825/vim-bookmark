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
    let l:list = uniq(extend(l:list, [substitute(expand('%:p'), $HOME, '~', '')]))
    call writefile(l:list, s:bookmark_file(l:tag))
endfunction

function! bookmark#addpos(...)
    let l:tag = !empty(a:0)? a:1 : 'default'
    let l:list = bookmark#list(l:tag)
    let l:list = uniq(extend(l:list, [substitute(expand('%:p'), $HOME, '~', '').':'.line('.').':'.col('.')]))
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
    silent! nunmap <buffer> <cr>
    nmap <silent><buffer> zh :call bookmark#toggle_filter()<cr>
    setlocal autoread
    setlocal commentstring=#\ %s
    setlocal filetype=bookmark
endfunction

function! bookmark#toggle_filter()
endfunction

function! bookmark#goimpl()
   let l:path = expand(getline('.'))
   let l:can_go = v:true
   let l:pos_ind =  match(l:path, ':[0-9]*:[0-9]*$')

   let l:line = 0
   if l:pos_ind > -1
       let [l:line, l:col] = split(l:path[l:pos_ind:], ':')
       let l:path = l:path[:l:pos_ind-1]
   endif

   if !filereadable(l:path) && !isdirectory(l:path)
       echoerr "Not found: ".l:path
       let l:can_go = v:false
   endif
   quit
   if l:can_go
       exec g:bookmark_opencmd.' '.l:path
       if isdirectory(l:path) && exists(':NETRTabdrop')
           exec g:_NETRPY.'with ranger.KeepPreviewState(): pass'
       endif
   endif

   if l:line > 0
       exec 'normal! '.l:line.'G'
       exec 'normal! '.l:col.'|'
   endif
endfunction

function! bookmark#go(...)
    call bookmark#edit()
    nnoremap <buffer> <cr> :call bookmark#goimpl()<cr>
endfunction
