# OpenSpec в проекте PDE

Каталог хранит разбор бизнес-требований **до** создания Outcome.

- `changes/` — один change на один будущий Outcome.
- `changes/chg-001-web-configurator` — полный конфигуратор по `BRD-CFG-001` / `VIS-CFG-001`. Черновик Pack: `../outcomes/OUT-CFG-001-web-configurator/`.
- `changes/chg-002-e1-main-page` — главная страница `Э-1`. Intake: `../inputs/REQ-OS-002-e1-main-page/`. Для экрана `Э-1` побеждает `chg-002`; вне `Э-1` текст `chg-001` не переписывается.
- `specs/` — текущее поведение продукта после выпуска; до release не заполняется из незавершённого change.

Pack создаётся только в `outcomes/<outcome-id>/` после подтверждения change. Не запускайте реализацию и `openspec archive` из этого каталога.
