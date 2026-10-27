# Vicinae Wayland-only для Gentoo

Overlay содержит ebuild для сборки Vicinae 0.29.2 из исходников через Portage.
Патч исключает X11/XCB-бэкенды Linux, сохраняя Wayland, layer shell и общий
`xkbcommon`. Пакет помечен только для `~amd64`.

## Установка

Добавьте локальную копию overlay в `/etc/portage/repos.conf/vicinae-overlay.conf`:

```ini
[vicinae-overlay]
location = /путь/к/vicinae-overlay
masters = gentoo
auto-sync = no
```

Затем установите пакет:

```sh
emerge --ask =gui-apps/vicinae-0.29.2
```

Чтобы собрать поддержку TypeScript extensions, включите USE-флаг:

```sh
USE="typescript-extensions" emerge --ask =gui-apps/vicinae-0.29.2
```

Флаг по умолчанию выключен. При его включении npm-пакеты берутся из lockfile
и загружаются через `SRC_URI`; установка модулей выполняется в offline-режиме.
При выключенном флаге npm-подготовка не запускается.

## Ограничения проверки

Overlay не назначает capabilities и не меняет владельца или режим input-helper.
Для snippet expansion upstream требует отдельно определить права
`vicinae-input-server`. Без этого ввод с клавиатуры через helper может быть
недоступен.

Проверка ELF (`scanelf` и `lddtree`) и запуск под Wayland требуются после сборки.
Транзитивные X11-библиотеки, которые Qt может установить системно, не означают
прямую зависимость Vicinae от X11.
