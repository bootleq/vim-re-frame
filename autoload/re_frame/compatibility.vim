" slice()
function! re_frame#compatibility#slice(...) abort "{{{
  let [expr, start] = a:000
  if a:0 > 2
    return expr[start:(a:2 - 1)]
  else
    return expr[start:]
  endif
endfunction "}}}


" matchfuzzy()
function! re_frame#compatibility#matchfuzzy(...) abort "{{{
  " Note: fallback to match WITHOUT fuzzy feature
  let [list, str] = a:000
  return filter(
        \ copy(list),
        \ {_, val -> strpart(val, 0, len(str)) == str}
        \ )
endfunction "}}}
