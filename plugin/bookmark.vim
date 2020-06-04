if exists('g:loaded_bookmark') || &cp
    finish
endif
let g:loaded_bookmark = 1

let s:save_cpo = &cpo
set cpo&vim

let g:bookmark_opencmd = get(g:, 'bookmark_opencmd', 'edit')
let g:bookmark_dir = get(g:,'bookmark_dir', $HOME.'/.vim-bookmark/')

if !isdirectory(g:bookmark_dir)
    call mkdir(g:bookmark_dir)
endif

let g:Bookmark_pos_context_fn = get(g:, 'Bookmark_pos_context_fn', function('bookmark#pos_context_fn'))


command! -complete=customlist,bookmark#complete -nargs=? BookmarkAdd exec 'call bookmark#add(<f-args>)'
command! -complete=customlist,bookmark#complete -nargs=? BookmarkAddPos exec 'call bookmark#addpos(<f-args>)'
command! -complete=customlist,bookmark#complete -nargs=? BookmarkDel exec 'call bookmark#del(<f-args>)'
command! -complete=customlist,bookmark#complete -nargs=? BookmarkDelPos exec 'call bookmark#delpos(<f-args>)'
command! -complete=customlist,bookmark#complete -nargs=? BookmarkGo exec 'call bookmark#go(<f-args>)'

let &cpo = s:save_cpo
