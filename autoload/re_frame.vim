let s:iced_re_frame_complete_cache = {}


" Backend: {{{
" TODO: support backends other than vim-iced
" }}} Backend


" Main Functions: {{{

function! re_frame#complete_db(ks, lead) abort "{{{
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


function! re_frame#get_handlers(kind) abort "{{{
  autocmd vim_re_frame CmdlineLeave <buffer> ++once let s:iced_re_frame_complete_cache = {}

  let lines = get(s:iced_re_frame_complete_cache, a:kind)
  if !empty(lines)
    return lines
  endif

  let code = printf('(clojure.string/join "\n" (keys (re-frame.registrar/get-handler :%s)))', a:kind)
  let resp = iced#nrepl#sync#eval(code)
  if has_key(resp, 'value')
    let string = resp['value'][1:-2]
    let lines = split(string, '\\n')
    let lines = sort(lines)
    let s:iced_re_frame_complete_cache[a:kind] = lines

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


function! re_frame#db_ns() abort "{{{
  " Get current ns with 'db.cljs' inside.
  " Useful if code is structured as several scoped re-frame db/event/sub sub-apps.
  " Can be used to filter out events in other scopes, you might not care about.
  let db = findfile('db.cljs', '.;')
  if !empty(db)
    let segs = split(db, '/')
    let ns = join(segs[1:(len(segs) - 2)], '.')
    let ns = substitute(ns, '_', '-', 'g')
    return ':' . ns
  endif
endfunction "}}}


function! re_frame#complete(lead, line, pos) abort "{{{
  " Main cmdline complete function
  "
  "                     subcmd
  "  line    :Reframe     db    :foo :bar_
  "
  "  segs    [Reframe     db    :foo :bar]
  "  at_seg      0         1      2    3

  let commands = ['sub', 'event', 'fx', 'db']
  let segs = split(a:line)
  let at_seg = len(split(a:line[0:a:pos])) - 1

  if len(segs) < 2
    return commands
  endif

  let subcmd = matchfuzzy(commands, segs[1])

  if len(subcmd) == 0
    return []
  elseif len(subcmd) > 1
    return subcmd
  endif

  let subcmd = subcmd[0]
  if at_seg == 1 && a:lead != ''
    return [subcmd]
  endif

  if index(['sub', 'event', 'fx'], subcmd) > -1
    if at_seg == 2 && a:lead == '' || at_seg > 2
      return []
    endif

    let candidates = re_frame#get_handlers(subcmd)

    if !empty(a:lead)
      let candidates = matchfuzzy(candidates, a:lead)
    endif
    return sort(candidates)
  elseif subcmd == 'db'
    let ks = empty(a:lead) ? segs[2:] : segs[2:(at_seg - 1)]
    let candidates = re_frame#complete_db(ks, a:lead)
    return sort(candidates)
  endif

  return []
endfunction "}}}


function! re_frame#do(cmd, ...) abort "{{{
  let commands = ['sub', 'event', 'fx', 'db']

  let cmd = matchfuzzy(commands, a:cmd)
  if len(cmd) == 1
    let cmd = cmd[0]
    let id = a:1

    " Restore shorten id
    let tx = get(g:, 're_frame#handler_candidates_restore')
    if index([v:t_func, v:t_string], type(tx)) > -1
      let id = call(tx, [id, cmd])
    endif

    if cmd == 'sub'
      " De-reference the subscription
      let code = printf(
            \ '@(re-frame.subs/subscribe [%s])',
            \ join([id] + a:000[1:], ' '))
    elseif cmd == 'event'
      " Dispatch the event
      let code = printf(
            \ '(re-frame.core/dispatch [%s])',
            \ join([id] + a:000[1:], ' '))
    elseif cmd == 'fx'
      " Call the effect function
      let code = printf(
            \ '((re-frame.registrar/get-handler :fx %s false) %s)',
            \ id,
            \ join(a:000[1:], ' '))
    elseif cmd == 'db'
      " Get the db value
      " Or set value with trailing ` = xxx` arguments
      let ks = copy(a:000)
      if index(slice(a:000, a:0 - 2), '=') > -1
        if a:000[-1] == '='
          let code = printf(
                \ '(do (swap! re-frame.db/app-db #(assoc-in %% [%s] nil)) nil)',
                \ join(slice(ks, 0, -1), ' '))
        else
          let code = printf(
                \ '(do (swap! re-frame.db/app-db #(assoc-in %% [%s] %s)) %s)',
                \ join(slice(ks, 0, -2),' '),
                \ a:000[-1],
                \ a:000[-1])
        endif
      else
        let code = printf('(get-in @re-frame.db/app-db [%s])', join(ks, ' '))
      endif
    endif

    execute 'IcedEval ' . code
  else
    echohl ErrorMsg | echomsg "Unknown command for " .a:cmd | echohl None
  endif
endfunction "}}}

" }}} Main Functions
