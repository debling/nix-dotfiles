local orgmode = require 'orgmode'

orgmode.setup_ts_grammar()

orgmode.setup({
  org_agenda_files = {'~/org/todo.org'},
  org_default_notes_file = '~/org/refile.org',
})
