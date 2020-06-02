let s:cached_list = get(s:, 'cached_list', {})

function! s:bookmark_file(...)
    call assert_true(a:0==1)
    let l:tag = empty(a:1)? 'default' : a:1[0]
    return g:bookmark_dir.l:tag
endfunction

function! bookmark#list(...)
    call assert_true(a:0==1)
    let l:tag = empty(a:1)? 'default' : a:1[0]
    if !has_key(s:cached_list, l:tag)
        let s:cached_list[l:tag] = readfile(s:bookmark_file(a:1))
    endif
    return s:cached_list[l:tag]
endfunction

function! bookmark#add(...)
    let l:list = bookmark#list(a:000)
    let l:list = extend(l:list, [substitute(expand('%:p'), $HOME, '~', '')])
    call writefile(l:list, s:bookmark_file(a:000))
endfunction

function! s:FilePosString()
    return substitute(expand('%:p'), $HOME, '~', '').':'.line('.')
endfunction

function! bookmark#pos_context_fn()
    return getline('.')
endfunction

function! bookmark#addpos(...)
    let l:list = bookmark#list(a:000)
    let l:list = extend(l:list, [s:FilePosString()]+map(g:Bookmark_pos_context_fn(), '"# ".v:val'))
    call writefile(l:list, s:bookmark_file(a:000))
endfunction

function! bookmark#del(...)
    let l:list = bookmark#list(a:0)
    let l:ind = index(l:list, expand('%:p'))
    if l:ind > -1
        unlet l:list[l:ind]
        call writefile(l:list, s:bookmark_file(a:000))
    endif
endfunction

function! bookmark#delpos(...)
    let l:list = bookmark#list(a:0)
    let l:ind = index(l:list, s:FilePosString())
    if l:ind > -1
        unlet l:list[l:ind]
        while l:ind < len(l:list) && l:list[l:ind] =~ '^["#].*$'
            unlet l:list[l:ind]
        endwhile
        call writefile(l:list, s:bookmark_file(a:000))
    endif
endfunction

function! bookmark#edit(...)
    exec 'split '.s:bookmark_file(a:000)
    wincmd J
    setlocal filetype=bookmark
    setlocal bufhidden=wipe
    setlocal commentstring=#\ %s
    silent! nunmap <buffer> <cr>
    nmap <silent><buffer> zh :call bookmark#toggle_filter()<cr>
endfunction

function! bookmark#toggle_filter()
endfunction

function! bookmark#goimpl()
    let l:lineno = line('.')
    let l:path = getline(l:lineno)
    while l:path =~ '^["#].*$'
        let l:lineno -= 1
        let l:path = getline(l:lineno)
    endwhile

    let l:path = expand(l:path)

    let l:can_go = v:true
    let l:pos_ind =  match(l:path, ':[0-9]*$')

    let l:line = 0
    if l:pos_ind > -1
        let l:line = l:path[l:pos_ind+1:]
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
    endif
endfunction

function! bookmark#go(...)
    call bookmark#edit()
    nnoremap <buffer> <cr> :call bookmark#goimpl()<cr>
endfunction
