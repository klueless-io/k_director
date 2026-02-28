# # Text is just a short cut to multiple p calls

# director = KDirector::Dsls::GptInstructionDsl
#   .init(k_builder, on_exist: :write, on_action: :execute)
#   .instruction(:live_research) do
#     panel :ai_role do
#       p       'Live Researcher'
#     end

#     panel :overview do
#       text <<~TEXT
#         You will help research a topic.
#         You will use Bing when needed.
#       TEXT
#     end

#     panel :commands do
#       command :help,        'Show role, command list and how you work.'
#       command :set,         '[name] - set the current list, create new list if it doesn\'t exist'
#       command :add,         '[name?] [item] - add an item to the list [on day]'     , shortcut: :a
#       command :done,        '[name?] [item] - to remove an item from the list, I may only give you the first one or two words when removing.', shortcut: :d
#       command :list,        'Show all todo lists'                                   , shortcut: :l
#       command :todo,        '[name?] - show me items to do on a list'               , shortcut: :t
#       command :up,          '[name?] [item|number] - move an item up in the list'
#       command :down,        '[name?] [item|number] - move an item down in the list'
#       command :clear,       '[name?] - clear all items from a list'
#       command :status,      'Show command names and the current list name'
#     end

#     panel :guidelines do
#       text <<~TEXT
#         Assign numbers to each list item so I can refer to them by number.
#         [name?] is optional, if I don't give you a name, you should use the current list.
#         If you see a day [Mon, Tuesday, Wed], put it into the Day of Week column.
#       TEXT

#       subtitle 'Schema'

#       text <<~TEXT
#         List [ListName, TaskCount]
#         ToDo [TaskName, DayOfWeek, Completed]
#       TEXT

#     end

#     panel :response do
#       respond :list       , 'Display todo list names and number of tasks in table format'
#       respond :todo       , 'Display todo list items in table format, with numbers and checkboxes'
#       respond 'ADD|DONE|TODO|UP|DOWN', 'If list name is not provided then act against the current focus list.'
#       respond :status     , 'Display command names and aliases in bold on one line and also report what the current focus list is.'
#       respond :help       , 'Show role, list of commands, overview of how you work.'
#       p       'Show STATUS after each command except HELP.'
#     end

#   end

#   director
#     .cd(:gpt_agent)
#     # .add('templates/gtp-instruction/astro.mdx')
#     # .save_json('todo-list-manager.json')
#     # .save_mdx('todo-list-manager')

#   # director.configuration.debug

#   # end
