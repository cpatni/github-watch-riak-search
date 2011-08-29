{schema,
  [
   {version, "0.1"},
   {default_field, "description"},
   {default_op, "or"},
   {n_val, 3},
   {analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}
  ],
  [
   {field, [{name, "id"},
            {analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}]},
   {field, [{name, "description"},
            {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}]},
   {field, [{name, "homepage"}]},
   {field, [{name, "clone_url"}]},
   {field, [{name, "url"}]},
   {field, [{name, "language"}]},
   {field, [{name, "ssh_url"}]},
   {field, [{name, "pushed_at"},
            {type, date}]},
   {field, [{name, "owner_url"}]},
   {field, [{name, "owner_login"}]},
   {field, [{name, "owner_id"}]},
   {field, [{name, "owner_avatar_url"}]},
   {field, [{name, "name"}]},
   {field, [{name, "git_url"}]},
   {field, [{name, "created_at"},
            {type, date}]},
   {field, [{name, "html_url"}]},
   % Skip anything we don't care about
   {dynamic_field, [{name, "*"},
                    {skip, true}]}
  ]
}.
