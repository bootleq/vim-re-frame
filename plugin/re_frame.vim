if exists('g:loaded_re_frame')
  finish
endif
let g:loaded_re_frame = 1


" let g:re_frame#backend = 'iced'
" let g:re_frame#handler_candidates_transform = 're_frame#handlers#candidates_transform'
" let g:re_frame#handler_candidates_restore = 're_frame#handlers#candidates_restore'


command! -nargs=* -complete=customlist,re_frame#complete ReFrame call re_frame#do(<f-args>)


augroup vim_re_frame
  autocmd!
augroup END
