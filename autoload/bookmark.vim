function! s:bookmark_file(tag)
    return g:bookmark_dir.a:tag
endfunction

function! bookmark#list(tag)
    if filereadable(s:bookmark_file(a:tag))
        return readfile(s:bookmark_file(a:tag))
    else
        return []
    endif
endfunction

function bookmark#complete(A,L,P)
    return systemlist("ls ".g:bookmark_dir)
endfunction

function! s:get_tag(args)
    return empty(a:args)? 'default': a:args[0]
endfunction

function! s:FilePosString()
    return substitute(expand('%:p'), $HOME, '~', '').':'.line('.')
endfunction

function! s:FileString()
    return substitute(expand('%:p'), $HOME, '~', '')
endfunction

function! bookmark#add(...)
    let l:tag = s:get_tag(a:000)
    let l:list = bookmark#list(l:tag)
    let l:file_string = s:FileString()
    if index(l:list, l:file_string) == -1
        call add(l:list, l:file_string)
        call writefile(l:list, s:bookmark_file(l:tag))
    endif
endfunction

function! bookmark#pos_context_fn()
    return getline('.')
endfunction

function! bookmark#addpos(...)
    let l:tag = s:get_tag(a:000)
    let l:list = bookmark#list(l:tag)
    call add(l:list, s:FilePosString())
    call extend(l:list, map(g:Bookmark_pos_context_fn(), '"# ".v:val'))
    call writefile(l:list, s:bookmark_file(l:tag))
endfunction

function! bookmark#del(...)
    let l:tag = s:get_tag(a:000)
    let l:list = bookmark#list(l:tag)
    let l:ind = index(l:list, s:FileString())
    if l:ind > -1
        unlet l:list[l:ind]
        call writefile(l:list, s:bookmark_file(l:tag))
    endif
endfunction

function! bookmark#delpos(...)
    let l:tag = s:get_tag(a:000)
    let l:list = bookmark#list(l:tag)
    let l:ind = index(l:list, s:FilePosString())
    if l:ind > -1
        unlet l:list[l:ind]
        while l:ind < len(l:list) && l:list[l:ind] =~ '^["#].*$'
            unlet l:list[l:ind]
        endwhile
        call writefile(l:list, s:bookmark_file(l:tag))
    endif
endfunction

function! bookmark#edit(tag)
    exec 'split '.s:bookmark_file(a:tag)
    wincmd J
    setlocal filetype=bookmark
    setlocal autoread
    setlocal commentstring=#\ %s
    silent! nunmap <buffer> <cr>
    nmap <silent><buffer> zh :call bookmark#toggle_filter()<cr>
endfunction

function! bookmark#toggle_filter()
endfunction

function! bookmark#open(...)
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

    " noautocmd in case bufenter does something bad, for e.g. auto startinsert
    " on terminal buffer which might be delayed to startinesrt on the target
    " file.
    noautocmd quit

    let l:open_cmd = len(a:000)>0? a:1 : g:bookmark_opencmd
    if l:can_go
        exec l:open_cmd.' '.fnameescape(l:path)
        " exec l:open_cmd.' '.fnameescape(l:path)
        if isdirectory(l:path) && exists(':NETRTabdrop')
            exec g:_NETRPY.'with ranger.KeepPreviewState(): pass'
        endif
    endif

    if l:line > 0
        exec 'normal! '.l:line.'G'
    endif
endfunction

function! bookmark#go(...)
    let l:tag = s:get_tag(a:000)
    call bookmark#edit(l:tag)
    nnoremap <buffer> <cr> :call bookmark#open()<cr>
endfunction
