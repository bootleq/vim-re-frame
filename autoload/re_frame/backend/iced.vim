let s:complete_cache_re_frame = {}


function! re_frame#backend#iced#eval(code) abort "{{{
  execute 'IcedEval ' . a:code
endfunction "}}}


function! re_frame#backend#iced#complete_db(ks, lead) abort "{{{
  let code = printf(
        \ '(clojure.string/join "\n" ' .
        \ '  (let [o (get-in @re-frame.db/app-db [%s])]' .
        \ '    (cond (vector? o) (-> o count range)' .
        \ '          (map? o)    (keys o)' .
        \ '          :else       nil)' .
        \ '))',
        \ join(a:ks, ' '))

  let resp = iced#nrepl#sync#eval(code)
  if has_key(resp, 'value')
    let string = resp['value'][1:-2]
    let lines = split(string, '\\n')
    if !empty(a:lead)
      let lines = matchfuzzy(lines, a:lead)
    endif
    let lines = sort(lines)
    return lines
  else
    echohl ErrorMsg | echomsg "[Eval] " . resp['err'] | echohl None
  endif

  return []
endfunction "}}}


function! re_frame#backend#iced#get_handlers(kind) abort "{{{
  autocmd vim_re_frame CmdlineLeave <buffer> ++once let s:complete_cache_re_frame = {}

  let lines = get(s:complete_cache_re_frame, a:kind)
  if !empty(lines)
    return lines
  endif

  let code = printf('(clojure.string/join "\n" (keys (re-frame.registrar/get-handler :%s)))', a:kind)
  let resp = iced#nrepl#sync#eval(code)
  if has_key(resp, 'value')
    let string = resp['value'][1:-2]
    let lines = split(string, '\\n')
    let lines = sort(lines)
    let s:complete_cache_re_frame[a:kind] = lines

    let tx = get(g:, 're_frame#handler_candidates_transform')
    if index([v:t_func, v:t_string], type(tx)) > -1
      call call(tx, [lines, a:kind])
    endif

    return lines
  else
    echohl ErrorMsg | echomsg "[Eval] " . resp['err'] | echohl None
    return []
  endif
endfunction "}}}
