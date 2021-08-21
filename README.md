Vim Re-Frame Utilities
======================

Helpers for [re-frame][].



Current Features
================

`:ReFrame` command to

1. `sub` - Get subscription value

  ```vim
  :ReFrame sub :i18n/locale
  ```

2. `event` - Dispatch event

  ```vim
  :ReFrame event :submit-form
  ```

3. `fx` - Call effect function

  ```vim
  :ReFrame fx :reload-page!
  ```

4. `db` - Read/Write app-db value

  ```vim
  :ReFrame db :foo :items 0 :color
  :ReFrame db :foo :items 0 :color = "red"
  ```



Configuration
=============

The `:ReFrame` command's auto completion might have candidates too long, you
can set filter and formatter to shorten it.

```vim
let g:re_frame#handler_candidates_transform = 're_frame#handlers#candidates_transform'
let g:re_frame#handler_candidates_restore   = 're_frame#handlers#candidates_restore'
```

- `g:re_frame#handler_candidates_transform`

  This can be set to a Function or String (function name).

  The function takes `(items, kind)` arguments.

  `items` are completion candidates, `kind` is one of `['sub', 'event', 'fx']`.

  For example `event` sub command will get a list from
  `(re-frame.registrar/get-handler :event)`.
  You can do filter / map on the List (Vim mutates List in place, so return
  value is not used here).

- `g:re_frame#handler_candidates_restore`

  If transform is set, this **restore** is also needed to ensure the command
  can find back original id before transform.

  This can be set to a Function or String (function name), too.  
  Takes `(id, kind)` arguments.

The two autoload functions
`re_frame#handlers#candidates_transform`
`re_frame#handlers#candidates_restore`
reduce the candidates by finding current namespace, for example if you
structure your code in small scopes each has its own re-frame db/subs/event
along, we leave only handlers belong to nearest scoped ns. 



Dependency
==========

- [liquidz/vim-iced][vim-iced]

Require it to communicate with nREPL.

You have to connect to CLJS REPL first, see [vim-iced-shadow-cljs][].

Welcome contribution for other backend support.
  


[re-frame]: https://github.com/day8/re-frame
[vim-iced]: https://github.com/liquidz/vim-iced
[vim-iced-shadow-cljs]: https://liquidz.github.io/vim-iced/#clojurescript_shadow_cljs
