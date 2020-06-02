if exists('g:loaded_bookmark') || &cp
    finish
endif
let g:loaded_bookmark = 1

let s:save_cpo = &cpo
set cpo&vim

let g:bookmark_opencmd = get(g:, 'bookmark_opencmd', 'edit')
let g:bookmark_dir = get(g:,'bookmark_dir', $HOME.'/.vim-bookmark')

if !isdirectory(g:bookmark_dir)
    call mkdir(g:bookmark_dir)
endif


command! -nargs=? BookmarkAdd exec 'call bookmark#add(<f-args>)'
command! -nargs=? BookmarkAddPos exec 'call bookmark#addpos(<f-args>)'
command! -nargs=? BookmarkDel exec 'call bookmark#del(<f-args>)'
command! -nargs=? BookmarkGo exec 'call bookmark#go(<f-args>)'

let &cpo = s:save_cpo
