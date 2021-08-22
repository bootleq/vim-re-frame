function! re_frame#backend#iced#eval(code) abort "{{{
  execute 'IcedEval ' . a:code
endfunction "}}}


function! re_frame#backend#iced#eval_to_list(code) abort "{{{
  let code = printf('(clojure.string/join "\n" %s)', a:code)

  let resp = iced#nrepl#sync#eval(code)
  if has_key(resp, 'value')
    let string = resp['value'][1:-2]
    return split(string, '\\n')
  else
    echohl ErrorMsg | echomsg "[Eval] " . resp['err'] | echohl None
  endif

  return []
endfunction "}}}
