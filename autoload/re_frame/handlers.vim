" Main Functions: {{{

function! re_frame#handlers#candidates_transform(items, kind) abort "{{{
  " Remove and shorten items (subs, events, .etc) by #db_ns.
  " To provide smaller set of cmdline complete results.
  let db_ns = re_frame#db_ns()

  if !empty(db_ns)
    call filter(a:items, function('s:filter_handler_by_ns', [db_ns]))
    call map(a:items, function('s:shorten_handler_by_ns', [db_ns, a:kind]))
  endif
endfunction "}}}


function! re_frame#handlers#candidates_restore(id, kind) abort "{{{
  " Reverse id previously shorten by candidates_transform
  let id = a:id

  if index(['.', '~'], id[0]) > -1
    let db_ns = re_frame#db_ns()

    if a:kind == 'sub'
      let shorten = 'subs'
    elseif a:kind == 'event'
      let shorten = 'events'
    endif

    if id[0] == '.'
      let id = db_ns . '.' . shorten . '/' . id[1:]
    else
      let id = db_ns . '.' . shorten . id[1:]
    endif
  endif

  return id
endfunction "}}}

" }}} Main Functions


" Helpers: {{{

function! s:filter_handler_by_ns(ns, _idx, id) abort "{{{
  " Only keeps
  " 1. items under current db-ns
  " 2. items under toplevel ns (i.e., no special ns prefixed)
  let ns = split(a:id, '/')[0]

  return ns !~ '\.' || strpart(ns, 0, len(a:ns)) == a:ns
endfunction "}}}


function! s:shorten_handler_by_ns(ns, kind, _idx, id) abort "{{{
  " For example, shorten
  "   :my.company.b2b.some-page.subs/some-field
  " to
  "   .some-field             (when db-ns is `:my.company.b2b.some-page`)
  "   ~some-page.some-field   (when db-ns is `:my.company.b2b`)
  let id = a:id
  let ns = split(id, '/')[0]
  let db_ns_len = len(a:ns)
  let shorten = ''

  if a:kind == 'sub'
    let shorten = 'subs'
  elseif a:kind == 'event'
    let shorten = 'events'
  endif

  if strpart(ns, 0, db_ns_len + 1) == a:ns . '.'
    let id = '~' . id[db_ns_len + 1:]
    if strpart(id, 1, len(shorten) + 1) == shorten . '/'
      let id = '.' . id[len(shorten) + 2:]
    endif
  endif

  return id
endfunction "}}}

" }}} Helpers
