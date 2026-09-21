# OpenSpec intake integration

## Роль

OpenSpec стоит **между входными бизнес-требованиями и созданием Outcome**. Он помогает разобрать сигнал, зафиксировать delta-спецификации и только после этого наполнить `pack.md` / `pack.json`.

Pack остаётся единственным источником истины для gates, Redmine, ASE handoff и evidence. OpenSpec не заменяет Pack, Ready Review и Definition Change.

Цепочка:

1. Входные документы попадают в `workspaces/projects/<project-id>/`.
2. Агент выполняет skill `pde-intake-openspec`: уточняющие вопросы, затем change в `openspec/changes/<change-id>/`.
3. Человек подтверждает change.
4. Skill `pde-create-pack` переносит требования в Outcome: Pack и `specifications.md`.
5. `validate-pack.ps1` проверяет Pack. OpenSpec-файлы gates не проходят сами по себе.

## Что не является этой интеграцией

Не путать с `integrations/openspace/`. OpenSpace управляет skills. OpenSpec — spec-driven intake перед Pack.

## Границы размещения

- Репозиторий инструмента [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) и глобальный CLI живут **вне** `workspaces/` (локальный каталог инструментов или `npm`).
- Контракт платформы — этот каталог `integrations/openspec/`.
- Рабочие артефакты — только `workspaces/projects/<project-id>/openspec/`.
- Запрещено вызывать `openspec init` в корне PDE-репозитория и с `--tools cursor`: это записало бы команды в `.cursor/` платформы.

Проверенная версия CLI при подключении: `@fission-ai/openspec@1.13.1`. Перед обновлением зафиксируйте новую версию отдельным Pull Request.

## Включение

Состояние задаёт `config/features.yaml` → `openspec_intake`.

- `enabled: true` — для **нового** Outcome из бизнес-требований intake через OpenSpec обязателен до создания Pack.
- `required: false` — уже существующие Pack без OpenSpec остаются действительными; отсутствие CLI не ломает CI.
- Телеметрия OpenSpec должна оставаться выключенной (`OPENSPEC_TELEMETRY=0`).

Значения из `openspec.env.example` задаются в окружении пользователя, не в Git.

## Локальная установка CLI

1. Node.js 20.19+.
2. `npm install -g @fission-ai/openspec@1.13.1`
3. `openspec config set telemetry.enabled false`
4. Проверить `openspec --version`.
5. Для проекта: `pwsh ./scripts/init-openspec-project.ps1 -ProjectId <project-id>`

Скрипт инициализации вызывает `openspec init --tools none` **только** в каталоге проекта. Если CLI нет, копируются шаблоны из `templates/openspec/`.

## Запрещено

- считать OpenSpec change готовым Pack или baseline;
- запускать `/opsx:apply` и писать код продукта из PDE;
- архивировать change в `openspec/specs/` до release Outcome;
- включать telemetry OpenSpec;
- копировать полный Pack в OpenSpec-файлы вместо ссылок на `outcome-id`;
- класть `openspec/` в корень `workspaces/` или в `workspaces/examples/`.

## Откат

1. Установить `features.openspec_intake.enabled: false`.
2. PDE продолжает создавать Pack через `pde-create-pack` по `AGENTS.md`.
3. Каталоги `openspec/` в проектах можно оставить как историю или удалить отдельным изменением проекта.

## Проверки

```powershell
pwsh ./scripts/init-openspec-project.ps1 -ProjectId <project-id>
pwsh ./scripts/validate-openspec-change.ps1 -ProjectPath workspaces/projects/<project-id> -ChangeName <change-id>
pwsh ./scripts/map-openspec-to-pack.ps1 -ProjectPath workspaces/projects/<project-id> -ChangeName <change-id> -OutcomePath workspaces/projects/<project-id>/outcomes/<outcome-id>
pwsh ./scripts/validate-pack.ps1 -Path workspaces/projects/<project-id>/outcomes/<outcome-id>
```

Эталонный разбор, на котором проверяется интеграция: `fixtures/sample-project/`.
