## vim-bookmark

### Installation
Install either with [vim-plug](https://github.com/junegunn/vim-plug), [Vundle](https://github.com/gmarik/vundle), [Pathogen](https://github.com/tpope/vim-pathogen) or [Neobundle](https://github.com/Shougo/neobundle.vim).

### Usage
This plugin enables user to bookmark files and open them:
```viml
" Add the current file to the bookmark file
:BookmarkAdd
" Remove the current file from the bookmark file
:BookmarkDel
" Edit the bookmark file
:BookmarkEdit
" Display the bookmark file. Pressing `<cr>` in it brings you to the selected file
:BookmarkGo
```
All of the above command takes an optional argument specifying which bookmark you want to use. If not provided, `default` is used.


Instead of using the `BookmarkGo`, one could also use other fuzzy finder (e.g.
fzf, denite) to select the files to go:
```viml
call fzf#run(fzf#wrap({'source': bookmark#list()}))
```
