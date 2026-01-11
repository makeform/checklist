module.exports =
  pkg:
    name: \@makeform/checklist
    extend: name: \@makeform/common
    host: name: \@grantdash/composer

    i18n:
      "zh-TW":
        checktype: info: ["勾選", "為正確答案"]
        sample: [
        * desc: "check list item", note: "this is the note of check list item"
        * desc: "check list item 1", note: "this is the note of check list item 1"
        * desc: "check list item 2", note: "this is the note of check list item 2"
        * desc: "check list item 3", note: "this item should not be checked"
        ]
      "en":
        checktype: info: ["check", "to pass validation"]
        sample: [
        * desc: "新檢查項目", note: "這是新檢查項目的說明文字"
        * desc: "檢查項目 1", note: "這是檢查項目 1 的說明文字"
        * desc: "檢查項目 2", note: "這是檢查項目 2 的說明文字"
        * desc: "檢查項目 3", note: "這個項目必須勾「否」"
        ]

  init: (opt) ->
    opt.pubsub.on \inited, (o = {}) ~> @ <<< o
    opt.pubsub.fire \subinit, mod: mod.call @, opt

mod = ({root, ctx, data, parent, i18n, t}) ->
  {ldview} = ctx
  lc = {}
  hitf = ~> @hitf
  items = -> hitf!get!config?items or []
  keygen = -> Math.random!toString(36)substring(2)
  getkey = (ctx) -> ctx.key or ctx.description or ctx
  @client = ->
    minibar: []
    sample: -> config: items: [
    * description: hitf!wrap "#{i18n.language}": t("sample.1.desc")
      note: hitf!wrap "#{i18n.language}": t("sample.1.desc")
      check: true, key: keygen!
    * description: hitf!wrap "#{i18n.language}": t("sample.2.desc")
      note: hitf!wrap "#{i18n.language}": t("sample.2.desc")
      check: true, key: keygen!
    * description: hitf!wrap "#{i18n.language}": t("sample.3.desc")
      note: hitf!wrap "#{i18n.language}": t("sample.3.desc")
      check: false, key: keygen!
    ]
    render: -> lc.view.render!
  init: ->
    lc := @mod.child
    lc.value = {}
    @on \change, (v) ~>
      lc.value = {} <<< (v or {})
      lc.view.render!

    handler = ~>
      lv = lc.value or {}
      rv = @value! or {}
      if !items!filter((d,i) -> lv[d.description or d] != rv[d.description or d]).length => return
      @value lv
    if !root => return
    lc.view = new ldview do
      root: root
      action: click: add: ({views}) ->
        items!push do
          description: hitf!wrap "#{i18n.language}": t("sample.0.desc")
          note: hitf!wrap "#{i18n.language}": t("sample.0.note")
          check: true, key: keygen!
        hitf!set!
        views.0.render!

      handler:
        item:
          list: ~>
            items!map (d,i) ->
              d = if typeof(d) == \string => {description: d} else d
              d.idx = (i + 1)
              d
          key: -> it.key or it.idx
          view:
            text: idx: ({ctx}) -> ctx.idx
            handler:
              checktype: ({node, ctx}) -> node.checked = !ctx.check
              name: hitf!render obj: ({ctx}) -> ctx.description
              "@": ({node, ctx}) ->
                n = getkey(ctx)
                error = if !ctx.check? => false
                else if !lc.value[n]? => false
                else if ((lc.value[n] == \yes) xor ctx.check == true) => true
                else false
                node.classList.toggle \error, error
              note:
                list: ({ctx}) ->
                  ret = if Array.isArray(ctx.note) => ctx.note else [ctx.note].filter(->it)
                  ret.map (obj, idx) -> {obj: if typeof(obj) == \string => "• #{t obj}" else obj, idx}
                key: -> it.idx
                view:
                  action: click: note: ({node, ctx, ctxs, evt}) ->
                    # richtext support list natively so we don't need list mechanism
                    # however before supporting @grantdash/composer, we use string array
                    # so, if note is object: it must be an richtext object. use it directly.
                    # otherwise, we need convert cell from string to object if necessary.
                    hitf!edit(
                      obj: ({ctx, init}) ->
                       if !Array.isArray(n = ctxs.0.note) => return ctxs.0.note
                       if !init => return ctx.obj
                       return n[ctx.idx] = if typeof(n[ctx.idx]) == \string => {} else (n[ctx.idx] or {})
                    ) {node, ctx, evt}
                  handler: note: ({node, ctx, ctxs}) ->
                    hitf!render(obj: ({ctx}) ->
                      if Array.isArray(ctxs.0.note) => ctx.obj else ctxs.0.note
                    ) {node, ctx}
              check: ({node, ctx}) ->
                [name, key] = [node.dataset.name, getkey ctx]
                node.classList.toggle \active, (lc.value[key] == name)
            action:
              change:
                checktype: ({node, ctx}) ->
                  ctx.check = !node.checked
                  hitf!set!
              click:
                remove: ({ctx}) ->
                  hitf!get!{}config.items = items!filter -> it.idx != ctx.idx
                  hitf!set!
                name: hitf!edit obj: ({ctx}) -> ctx.{}description
                check: ({node, ctx, views}) ~>
                  if !!hitf!get!readonly => return
                  [name, key] = [node.dataset.name, getkey ctx]
                  lc.value[key] = if lc.value[key] == name => '' else name
                  views.0.render!
                  handler!


  render: -> if @mod.child.view => @mod.child.view.render!
  validate: ->
    v = @value! or {}
    invalid-length = items!
      .filter (d) ->
        r = v[d.description or d]
        # TODO isn't this also check if r is defined?
        if !d.check? => return false
        d.check == true xor r == \yes
      .length
    if invalid-length => return ["error"]
    return []
  is-equal: (u = {}, v = {}) ->
    !items!
      .filter (d,i) -> (u[d.description or d] != v[d.description or d])
      .length

  is-empty: (v) ->
    if !(v and typeof(v) == \object) => return true
    !!items!
      .filter (d,i) -> !(v[d.description or d])
      .length
