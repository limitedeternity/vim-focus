" Focus on the fragments.
" Author: SpringHan<springchohaku@qq.com>
" Last Change: 2020.7.26
" Version: 1.0.1
" Repository: https://github.com/SpringHan/vim-focus.git
" License: MIT

if !exists('g:VimFocusLoaded')
    let g:VimFocusLoaded = 1
else
    finish
endif

command! -nargs=0 -range FocusStart call s:FocusStart()
command! -nargs=0 FocusStop call s:FocusStop()
command! -nargs=0 FocusSave call s:FocusSave()

function! s:GetSelection() abort
	let s:originBuf = bufnr('%')
	let s:focusHeaderLineNr = line("'<")
	let s:focusLastLineNr = line("'>")
	let s:originFileType = &filetype
	return getline(s:focusHeaderLineNr, s:focusLastLineNr)
endfunction

function! s:FocusStart() abort
    let l:selection = s:GetSelection()

	let s:focusBuf = bufadd('Focus')
	call setbufvar(s:focusBuf, '&buflisted', 1)
	call setbufvar(s:focusBuf, '&buftype', 'nofile')
	call setbufvar(s:focusBuf, '&filetype', s:originFileType)

	if exists('g:VimFocusOpenWay') && g:VimFocusOpenWay == 'window'
		silent execute "vertical botright split"
	endif

	execute "buf " . s:focusBuf
	call append(0, l:selection)

	let l:nowLineContent = getline(1, line('$'))
	if len(l:nowLineContent) != s:focusLastLineNr - s:focusHeaderLineNr + 1 && l:nowLineContent[-1] == ''
		silent execute "delete " . line('$')
	endif

	call cursor(1, 0)
endfunction

function! s:FocusStop() abort
	if exists('g:VimFocusOpenWay') && index(['buffer', 'window'], g:VimFocusOpenWay) == -1
		return
	endif

	let l:currentContent = getline(1, line('$'))
	silent execute "bd! " . s:focusBuf
	silent execute "buf " . s:originBuf

	call deletebufline(s:originBuf, s:focusHeaderLineNr, s:focusLastLineNr)
	call append(s:focusHeaderLineNr - 1, l:currentContent)
	execute "write"

	unlet s:focusBuf s:originBuf s:focusLastLineNr s:focusHeaderLineNr s:originFileType
endfunction

function! s:FocusSave() abort
	if exists('g:VimFocusOpenWay') && index(['buffer', 'window'], g:VimFocusOpenWay) == -1
		return
	endif

	let l:currentLastLineNr = line('$')
	let l:currentContent = getline(1, l:currentLastLineNr)
	silent execute "buf " . s:originBuf

	call deletebufline(s:originBuf, s:focusHeaderLineNr, s:focusLastLineNr)
	call append(s:focusHeaderLineNr - 1, l:currentContent)
	execute "write | buf " . s:focusBuf

	let s:focusLastLineNr = l:currentLastLineNr + s:focusHeaderLineNr - 1
endfunction
