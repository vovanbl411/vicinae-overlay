# Vicinae Wayland-only для Gentoo

Overlay содержит ebuild для сборки Vicinae 0.29.2 из исходников через Portage.
Патч исключает X11/XCB-бэкенды Linux, сохраняя Wayland-бэкенд, layer shell и
общий `xkbcommon`. Overlay предназначен для Wayland; пакет помечен только для
`~amd64`.

## Установка

Добавьте локальную копию overlay в `/etc/portage/repos.conf/vicinae-overlay.conf`:

```ini
[vicinae-overlay]
location = /var/db/repos/vicinae-overlay
masters = gentoo
sync-type = git
sync-uri =  https://github.com/vovanbl411/vicinae-overlay
auto-sync = yes
```

Затем установите пакет:

```sh
emerge --ask =gui-apps/vicinae-0.29.2
```

Чтобы собрать поддержку TypeScript extensions, включите USE-флаг:

```sh
USE="typescript-extensions" emerge --ask =gui-apps/vicinae-0.29.2
```

Флаг `typescript-extensions` по умолчанию выключен. При его включении npm-пакеты
берутся из lockfile и загружаются через `SRC_URI`; установка модулей выполняется
в offline-режиме. При выключенном флаге npm-подготовка не запускается.

## Ограничения проверки

Overlay не назначает capabilities и не меняет владельца или режим input-helper.
Для snippet expansion upstream требует отдельно определить права
`vicinae-input-server`. Без этого ввод с клавиатуры через helper может быть
недоступен.

На workstation проверен релиз 0.29.2 для amd64: пакет установлен и вручную
работал в Umbriel. В прямых ELF-зависимостях и дереве зависимостей сервера не
обнаружены X11/XCB и `xkbcommon-x11`. Автозапуск настроен, но повторный вход в
сессию ещё не проверен. Конфигурация workstation в overlay не входит.

CI запускает pkgcheck для пакета, проверяет применение патчей к исходникам
релиза и сверяет npm-набор с lockfile и Manifest. CI не собирает пакет и не
проверяет его работу во время выполнения. USE-вариант с
`typescript-extensions` отдельно не собирался и не проверялся.

Для ручной сверки npm-набора передайте скрипту распакованные исходники Vicinae
0.29.2. По умолчанию он только проверяет данные; `--generate` явно перезаписывает
существующие npm-блоки ebuild из двух lockfile:

```sh
python3 scripts/check-npm-distfiles.py --source-dir /путь/к/исходникам
python3 scripts/check-npm-distfiles.py --source-dir /путь/к/исходникам --generate
```

После сборки отдельно проверьте ELF-зависимости (`scanelf` и `lddtree`) и запуск
под Wayland. Транзитивные X11-библиотеки, которые Qt может установить системно,
не означают прямую зависимость Vicinae от X11.
