project('estudos-vala', 'vala', 'c')

# Aqui você lista as bibliotecas que quer que o VS Code reconheça
dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),
    dependency('gtk4'),
    dependency('granite-7') # O Granite é essencial para apps do elementary
]

# Isso aqui é só para o Meson não reclamar, 
# mas já ativa o IntelliSense para a pasta toda
executable('listView', 'apps/001/listView.vala', dependencies: dependencies)
executable('up_customer_list', 'apps/001/up_customer_list.vala', dependencies: dependencies)
executable('clipboard', 'apps/001/clipboard.vala', dependencies: dependencies)
executable('entry_completion', 'apps/001/entry_completion.vala', dependencies: dependencies)
executable('checklist', 'apps/002/001-checklist.vala', dependencies: dependencies)