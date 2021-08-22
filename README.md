Vim Re-Frame Utilities
======================

Helpers for [re-frame][].



## Current Feature

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

4. `db` - Read/write app-db value

    ```vim
    :ReFrame db :foo :items 0 :color
    :ReFrame db :foo :items 0 :color = "red"
    ```



## Configuration

### Prefered backend

- `g:re_frame#backend`

There is a detection to pick nREPL backend (e.g., [vim-iced][] or [vim-fireplace][]),
you can set a fixed value to bypass the detection.

```vim
let g:re_frame#backend = 'iced'
```

The value can be one of `iced`, `fireplace`.


### Candidates filter

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

The two built-in autoload functions:

- `re_frame#handlers#candidates_transform`
- `re_frame#handlers#candidates_restore`

reduce candidates by finding current namespace, for example if you structure
your code in small scopes each has its own re-frame db/subs/event along, they
leave only handlers belong to nearest scoped ns.

For example, it shortens

    :my.company.b2b.some-page.subs/some-field

to

    .some-field             (when nearest ns is `:my.company.b2b.some-page`)
    ~some-page.some-field   (when nearest ns is `:my.company.b2b`)


## Prerequisites

- nREPL backend

  Have to communicate with CLJS REPL, currently supports:

  - [liquidz/vim-iced][vim-iced], see its instruction connecting cljs [here][vim-iced-shadow-cljs].
  - [tpope/vim-fireplace][vim-fireplace]

  Welcome contribution for other backends.
    

- Vim version

  It is suggested to use newer versions.

  Command line completion uses `matchfuzzy()` (introduced Vim 8.2.1665, Neovim PR#12995 await).

  Without built-in implementation we might use downgrade fallback.

  


[re-frame]: https://github.com/day8/re-frame
[vim-iced]: https://github.com/liquidz/vim-iced
[vim-iced-shadow-cljs]: https://liquidz.github.io/vim-iced/#clojurescript_shadow_cljs
[vim-fireplace]: https://github.com/tpope/vim-fireplace
