function! re_frame#backend#fireplace#eval(code) abort "{{{
  execute 'CljsEval ' . a:code
endfunction "}}}


function! re_frame#backend#fireplace#eval_to_list(code) abort "{{{
  let code = printf('(clojure.string/join "\n" %s)', a:code)

  let resp = fireplace#eval(code)[0]

  let string = resp[1:-2]
  return split(string, '\\n')
endfunction "}}}
