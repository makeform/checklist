module.exports =
  pkg: name: "@makeform/checklist", extend: {name: "@makeform/common"}
  init: (opt) -> opt.pubsub.fire \subinit, mod: mod(opt)

mod = ({root, ctx, data, parent, t}) -> 
  {ldview} = ctx
  lc = {}
  init: ->
    lc = @mod.child
    lc.value = {}
    view = {}
    @on \change, (v) ~>
      lc.value = {} <<< (v or {})
      view.render!

    handler = ~>
      lv = lc.value or {}
      rv = @value! or {}
      if !@mod.info.config.items.filter((d,i) -> lv[d.description or d] != rv[d.description or d]).length => return
      @value lv
    if !root => return
    lc.view = view = new ldview do
      root: root
      handler:
        item:
          list: ~>
            @mod.info.config.items.map (d,i) ->
              d = if typeof(d) == \string => {description: d} else d
              d.idx = (i + 1)
              d
          key: -> it.description
          view:
            text:
              name: ({ctx}) -> ctx.description or ctx
              idx: ({ctx}) -> ctx.idx
            handler:
              note:
                list: ({ctx}) -> ctx.note or []
                key: -> it
                handler: ({node, data}) ->
                  v = t data
                  node.innerText = if v => "• #{v}" else ''
                  node.classList.toggle \d-none, !v
              check: ({node, ctx}) ->
                name = node.getAttribute(\data-name)
                desc = ctx.description or ctx
                node.classList.toggle \active, (lc.value[desc] == name)
            action: click:
              check: ({node, ctx, views}) ->
                name = node.getAttribute(\data-name)
                desc = ctx.description or ctx
                lc.value[desc] = if lc.value[desc] == name => '' else name
                views.0.render!
                handler!


  render: -> if @mod.child.view => @mod.child.view.render!
  is-empty: (v) ->
    if !(v and typeof(v) == \object) => return true
    !!@mod.info.config.items
      .filter (d,i) -> !(v[d.description or d])
      .length
