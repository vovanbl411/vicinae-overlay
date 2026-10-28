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

CI запускает pkgcheck для пакета, проверяет применение фактических PATCHES к
исходникам каждой упакованной версии и сверяет npm-набор с lockfile и Manifest.
CI не собирает пакет и не проверяет его работу во время выполнения. USE-вариант с
`typescript-extensions` отдельно не собирался и не проверялся.

## Подготовка stable-релизов

Workflow ежедневно проверяет последний публичный stable-релиз Vicinae. Его также
можно запустить вручную из GitHub Actions. Ручной запуск по умолчанию выполняет
`dry_run`: показывает версию и план без изменений в репозитории. Для подготовки
кандидата отключите `dry_run`. Если версия новее, проверки проходят и Draft PR для
неё ещё нет, workflow подготавливает ebuild-кандидат и открывает Draft PR.

Предыдущий ebuild остаётся fallback; при следующей ротации удаляется только
устаревший fallback. Слияние PR, установка пакета и проверка во время работы
выполняются вручную. После CI ebuild-кандидат не считается собранным или
установленным, а его проверка во время работы не выполнена.

## CI и обновления

Подготовка кандидата выполняется с read-only правами. Отдельный job публикует
Draft PR и имеет права записи. Обновления принимаются вручную после проверки PR.
При настройке обязательной проверки используйте точное имя status check:
`checks`.

PR, созданный с помощью `GITHUB_TOKEN`, не запускает CI автоматически. Перед
слиянием владелец репозитория вручную запускает workflow CI, выбрав ветку
`automation/vicinae-stable-update`. Ручной запуск выполняет для неё те же
проверки.

GitHub Actions закреплены по полным commit SHA, а pkgcheck запускается из
контейнера, закреплённого по sha256 digest. Dependabot еженедельно предлагает
обновления GitHub Actions. Digest контейнера обновляется вручную.

Для ручной сверки npm-набора передайте скрипту распакованные исходники Vicinae
0.29.2. По умолчанию он только проверяет данные; `--generate` явно перезаписывает
существующие npm-блоки ebuild из двух lockfile:

```sh
python3 scripts/check-npm-distfiles.py --source-dir /путь/к/исходникам
python3 scripts/check-npm-distfiles.py --source-dir /путь/к/исходникам \
  --ebuild gui-apps/vicinae/vicinae-0.29.2.ebuild
python3 scripts/check-npm-distfiles.py --source-dir /путь/к/исходникам \
  --ebuild gui-apps/vicinae/vicinae-0.29.2.ebuild --generate
```

Если в каталоге один ebuild, `--ebuild` можно опустить.

После сборки отдельно проверьте ELF-зависимости (`scanelf` и `lddtree`) и запуск
под Wayland. Транзитивные X11-библиотеки, которые Qt может установить системно,
не означают прямую зависимость Vicinae от X11.
