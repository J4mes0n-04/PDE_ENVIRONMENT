# Настройка OpenSpec в PDE: понятная инструкция

Эта инструкция объясняет, как OpenSpec устроен именно в данном PDE-репозитории, как его включить для проекта и какие файлы нужно менять, чтобы повлиять на процесс, правила и итоговые документы.

Инструкция рассчитана на человека без предварительного знакомства с OpenSpec.

## 1. Что делает OpenSpec в этом репозитории

OpenSpec используется для разбора входных бизнес-требований **до создания Product Definition Pack (Pack)**.

Упрощённая цепочка работы:

```text
Входной документ
    ↓
OpenSpec change: исследование, предложение, требования и сценарии
    ↓
Подтверждение человеком
    ↓
Outcome: pack.md, pack.json, specifications.md, трассировка
    ↓
Реализация, доказательства, выпуск и проверка результата
```

Важно понимать три правила:

1. OpenSpec помогает подготовить требования, но не заменяет Pack.
2. Один каталог OpenSpec change соответствует одному будущему Outcome.
3. Источником истины для gates после переноса остаётся `pack.json`, а не файлы OpenSpec.

OpenSpec и OpenSpace — разные инструменты. OpenSpec разбирает требования. OpenSpace управляет жизненным циклом skills и в этой инструкции не рассматривается.

## 2. Где разрешено размещать OpenSpec

Рабочие файлы конкретного проекта должны находиться только здесь:

```text
workspaces/projects/<project-id>/openspec/
```

Пример:

```text
workspaces/projects/my-product/openspec/
```

Нельзя запускать `openspec init` в корне PDE-репозитория. Нельзя создавать рабочий каталог `openspec/` непосредственно в `workspaces/` или `workspaces/examples/`.

## 3. Самая важная карта настроек

Ниже перечислены основные файлы и объяснено, на что влияет каждый из них.

| Что требуется изменить | Какой файл править | На что влияет |
| --- | --- | --- |
| Включить или отключить OpenSpec intake для всей PDE-среды | `config/features.yaml` | Определяет, нужно ли проходить OpenSpec перед созданием нового Outcome |
| Изменить правила OpenSpec только для одного проекта | `workspaces/projects/<project-id>/openspec/config.yaml` | Меняет контекст и правила подготовки change в выбранном проекте |
| Изменить правила по умолчанию для новых проектов | `templates/openspec/config.yaml` | Определяет, какой `config.yaml` получат новые или повторно инициализированные проекты |
| Изменить форму будущих OpenSpec-документов | `templates/openspec-change/*.md` | Меняет каркас новых `explore.md`, `proposal.md`, `design.md`, `tasks.md` и `spec.md` |
| Изменить фактическое содержание текущего change | `workspaces/projects/<project-id>/openspec/changes/<change-id>/...` | Непосредственно меняет требования, сценарии, область работ, риски и будущий результат mapping |
| Изменить логику работы Codex-агента | `.agents/skills/pde-intake-openspec/SKILL.md` | Меняет последовательность действий агента при разборе требований |
| Изменить создание Pack из подтверждённого change | `.agents/skills/pde-create-pack/SKILL.md` | Меняет процесс формирования `pack.md` и `pack.json` |
| Изменить обязательные правила для Cursor | `.cursor/rules/06-openspec-intake.mdc` | Меняет постоянно применяемые ограничения OpenSpec intake в Cursor |
| Изменить ручную команду Cursor | `.cursor/commands/pde-intake-openspec.md` | Меняет инструкцию, выполняемую при запуске команды intake |
| Изменить договорённость о переносе полей в Pack | `integrations/openspec/pack-mapping.yaml` | Описывает соответствие разделов OpenSpec полям Pack |
| Изменить фактическую генерацию `specifications.md` и трассировки | `scripts/map-openspec-to-pack.ps1` | Меняет алгоритм чтения требований и записи результатов mapping |
| Изменить допустимую структуру change | `scripts/validate-openspec-change.ps1` | Меняет автоматические проверки файлов, языка и идентификаторов |
| Изменить способ инициализации проекта | `scripts/init-openspec-project.ps1` | Меняет вызов CLI, переменные окружения и копирование шаблонов |
| Изменить зафиксированную версию CLI | `integrations/openspec/README.md` и `integrations/openspec/pack-mapping.yaml` | Меняет документированный version pin; обновление требует отдельной проверки |

Короткое правило выбора:

- нужно изменить один текущий результат — правьте файлы конкретного change;
- нужно изменить один проект — правьте проектный `openspec/config.yaml`;
- нужно изменить будущие проекты — правьте шаблоны;
- нужно изменить поведение агента или проверки — правьте skill, rule или script отдельным платформенным изменением.

## 4. Первичная настройка OpenSpec

### Шаг 1. Проверьте предварительные условия

Для работы CLI требуется Node.js версии 20.19 или новее. Репозиторий зафиксирован на OpenSpec CLI версии `1.13.1`.

Проверка Node.js:

```powershell
node --version
```

Установка зафиксированной версии OpenSpec:

```powershell
npm install -g @fission-ai/openspec@1.13.1
```

Отключение телеметрии:

```powershell
openspec config set telemetry.enabled false
```

Проверка установки:

```powershell
openspec --version
```

Если CLI не установлен, PDE всё равно может создать структуру из локальных шаблонов. При проверке будут выполнены только структурные проверки PDE без `openspec validate`.

### Шаг 2. Проверьте глобальный переключатель

Файл:

```text
config/features.yaml
```

Нужный раздел:

```yaml
features:
  openspec_intake:
    enabled: true
    required: false
    telemetry: off
    activation_stage: intake-before-outcome
```

Значения влияют на следующее:

- `enabled: true` — для нового Outcome сначала требуется OpenSpec change;
- `enabled: false` — процесс может создавать Pack без OpenSpec intake;
- `required: false` — старые Pack без OpenSpec остаются допустимыми, а отсутствие CLI не должно ломать CI;
- `telemetry: off` — телеметрия должна быть отключена;
- `activation_stage: intake-before-outcome` — поясняет место OpenSpec в жизненном цикле.

Не меняйте `required` или `activation_stage` как случайную локальную настройку проекта. Это платформенная политика, и её изменение влияет на весь репозиторий.

### Шаг 3. Подготовьте каталог проекта

Сначала должен существовать каталог:

```text
workspaces/projects/<project-id>/
```

Пример:

```text
workspaces/projects/my-product/
```

Запустите из корня репозитория:

```powershell
pwsh ./scripts/init-openspec-project.ps1 -ProjectId my-product
```

Скрипт выполняет следующие действия:

1. Проверяет наличие проекта и платформенного шаблона.
2. Отключает телеметрию и анимацию через переменные окружения процесса.
3. При наличии CLI вызывает `openspec init <project-path> --tools none --language ru --no-animation`.
4. Копирует файлы из `templates/openspec/` в каталог проекта.

### Важное предупреждение о повторной инициализации

Скрипт `scripts/init-openspec-project.ps1` **каждый раз принудительно копирует** `templates/openspec/config.yaml` поверх проектного `openspec/config.yaml`.

Следствие: если вы вручную настроили файл

```text
workspaces/projects/<project-id>/openspec/config.yaml
```

то повторный запуск init может заменить ваши локальные правила платформенным шаблоном. Перед повторным запуском сравните изменения в Git или сохраните локальные настройки.

### Шаг 4. Проверьте созданную структуру

После инициализации ожидается:

```text
workspaces/projects/<project-id>/
└── openspec/
    ├── config.yaml
    ├── README.md
    ├── changes/
    │   ├── README.md
    │   └── archive/
    └── specs/
        └── README.md
```

Каталог `changes/` хранит ещё не выпущенные изменения. Каталог `specs/` предназначен для текущего поведения продукта после выпуска и явного архивирования change.

## 5. Как настраивать `openspec/config.yaml`

Файл проекта:

```text
workspaces/projects/<project-id>/openspec/config.yaml
```

Эталон для новых проектов:

```text
templates/openspec/config.yaml
```

Базовая структура:

```yaml
schema: spec-driven

context: |
  Здесь записывается общий контекст проекта и обязательные ограничения.

rules:
  proposal:
    - Правила для proposal.md
  specs:
    - Правила для delta-spec файлов
  design:
    - Правила для design.md
  tasks:
    - Правила для tasks.md
```

### `schema`

Определяет схему работы OpenSpec. В этом репозитории используется:

```yaml
schema: spec-driven
```

Не меняйте значение без проверки совместимости CLI, шаблонов и валидаторов.

### `context`

Это постоянный контекст, который должен учитываться при подготовке артефактов проекта. Здесь полезно фиксировать:

- язык человекочитаемого текста;
- границы проекта;
- особенности пользователей и продукта;
- обязательные требования безопасности;
- запрет на выдумывание владельцев, метрик и идентификаторов;
- правило сохранения идентификаторов `AC-NNN` и `NFR-NNN`;
- правило «один change — один Outcome».

Не помещайте сюда конкретное требование одного change. Для него предназначены `proposal.md`, `design.md` и `specs/**/spec.md`.

### `rules.proposal`

Влияет на содержание `proposal.md`. Здесь задаются обязательные разделы и правила предложения: проблема, пользователи, область работ, измеримый результат и открытые вопросы.

### `rules.specs`

Влияет на формат требований и сценариев. Для совместимости с текущими скриптами сохраняйте:

- разделы `ADDED Requirements`, `MODIFIED Requirements` или `REMOVED Requirements`;
- заголовок `### Requirement: AC-NNN Русское название` либо `NFR-NNN`;
- не менее одного сценария для каждого требования;
- шаги `WHEN` и `THEN`;
- формулировку поведения через `The system SHALL ...` или `The system MUST ...`.

### `rules.design`

Влияет на `design.md`. Здесь должны описываться подход, нефункциональные ограничения, зависимости, совместимость, восстановление и риски. Не используйте этот раздел для скрытого расширения scope.

### `rules.tasks`

Влияет на `tasks.md`. Задачи — это подсказки для будущих срезов поставки, а не источник истины Pack.

## 6. Какие файлы образуют один OpenSpec change

Каталог change создаётся здесь:

```text
workspaces/projects/<project-id>/openspec/changes/<change-id>/
```

Рекомендуемый идентификатор:

```text
chg-001-short-name
```

Пример структуры:

```text
changes/chg-001-device-status/
├── explore.md
├── proposal.md
├── design.md
├── tasks.md
└── specs/
    └── alerting/
        └── spec.md
```

### `explore.md`

Шаблон:

```text
templates/openspec-change/explore.md
```

Назначение: записать прочитанные источники, подтверждённые факты, пробелы и вопросы. Изменение этого файла влияет на полноту исследования, но скрипт mapping его не читает.

### `proposal.md`

Шаблон:

```text
templates/openspec-change/proposal.md
```

Назначение: объяснить, зачем нужно изменение, что должно измениться, что входит и не входит в scope, какие вопросы остаются открытыми.

Согласно контракту `pack-mapping.yaml`, разделы proposal используются как источник для проблемы, целевого результата, scope и открытых вопросов Pack. Фактическое создание Pack выполняет skill `pde-create-pack`, а не mapping-скрипт автоматически.

### `design.md`

Шаблон:

```text
templates/openspec-change/design.md
```

Назначение: описать технический или продуктовый подход, NFR, зависимости, совместимость, восстановление и риски.

### `tasks.md`

Шаблон:

```text
templates/openspec-change/tasks.md
```

Назначение: предложить проверяемые срезы поставки. Этот файл помогает подготовить передачу в ASE, но не определяет прохождение gates.

### `specs/<domain>/spec.md`

Шаблон:

```text
templates/openspec-change/specs/domain/spec.md
```

Назначение: хранить точные требования и проверяемые сценарии по доменам.

Пример:

```markdown
# Delta for alerting

## ADDED Requirements

### Requirement: AC-001 Показать состояние устройства
The system SHALL показывать текущее состояние устройства пользователю.

#### Scenario: Устройство недоступно
- **GIVEN** устройство зарегистрировано
- **WHEN** устройство перестаёт отвечать
- **THEN** пользователь видит состояние «Недоступно»
```

Идентификаторы должны быть уникальными в пределах change. Используйте `AC-001`, `AC-002` и `NFR-001`, `NFR-002`, сохраняя минимум три цифры.

## 7. Что именно влияет на результат

### Входные документы проекта

Расположение:

```text
workspaces/projects/<project-id>/inputs/
```

Для подготовки нового входного документа используйте шаблон:

```text
templates/business-requirements.md
```

Скопируйте его в `inputs/` проекта под именем `REQ-<код>-<краткое-название>.md`, затем заполните подтверждёнными фактами и явно отметьте неизвестные сведения.

Они содержат исходные факты. Чем точнее описаны проблема, пользователь, ожидаемый результат, scope, метрики, ограничения и риски, тем точнее будет change.

Если факта нет во входных документах, агент должен задать вопрос, а не придумывать ответ.

### Проектный `openspec/config.yaml`

Определяет постоянные правила одного проекта. Изменение влияет на будущую работу в этом проекте, но не переписывает уже существующие change автоматически.

### Файлы текущего change

Это главный источник содержания текущего результата. Если нужно изменить конкретный AC, NFR, сценарий, scope или риск, изменяйте соответствующий файл change, затем повторно запускайте проверку и mapping.

### Платформенные шаблоны

Файлы в `templates/openspec/` и `templates/openspec-change/` влияют только на новые или заново скопированные файлы. Правка шаблона не изменяет ранее созданные проекты автоматически.

### Skill агента

Файл:

```text
.agents/skills/pde-intake-openspec/SKILL.md
```

Он определяет последовательность действий Codex: изучение источников, уточняющие вопросы, создание change, язык, запреты и обязательную проверку.

Изменяйте skill, если нужно изменить поведение агента во всех проектах. Это платформенное изменение, которое требует отдельной проверки репозитория.

### Правила и команда Cursor

Файлы:

```text
.cursor/rules/06-openspec-intake.mdc
.cursor/commands/pde-intake-openspec.md
```

Rule применяется как постоянное ограничение Cursor. Command описывает ручной сценарий запуска. Эти файлы не заменяют skill Codex: если используются оба инструмента, их правила нужно поддерживать согласованными.

### Контракт mapping и исполняемый скрипт

Файлы:

```text
integrations/openspec/pack-mapping.yaml
scripts/map-openspec-to-pack.ps1
```

`pack-mapping.yaml` документирует, какие разделы должны перейти в Pack. Текущий `map-openspec-to-pack.ps1` не читает этот YAML как исполняемую конфигурацию. Он самостоятельно извлекает AC/NFR из `spec.md` и создаёт:

```text
specifications.md
openspec-traceability.md
```

Поэтому изменение только `pack-mapping.yaml` не меняет алгоритм PowerShell-скрипта. Если нужно изменить фактическое преобразование, проверьте и согласованно измените контракт, script, skill и фикстуру.

## 8. Проверка change

Команда:

```powershell
pwsh ./scripts/validate-openspec-change.ps1 `
  -ProjectPath workspaces/projects/<project-id> `
  -ChangeName <change-id>
```

Пример:

```powershell
pwsh ./scripts/validate-openspec-change.ps1 `
  -ProjectPath workspaces/projects/my-product `
  -ChangeName chg-001-device-status
```

Локальная PDE-проверка контролирует:

- наличие `openspec/config.yaml`;
- наличие каталога change;
- наличие `proposal.md` и русского текста в нём;
- наличие хотя бы одного `spec.md`;
- наличие заголовка `ADDED`, `MODIFIED` или `REMOVED Requirements`;
- наличие русского текста в delta spec;
- идентификаторы формата `AC-NNN` и `NFR-NNN`;
- отсутствие повторяющихся идентификаторов;
- отсутствие `pack.md` и `pack.json` внутри change.

Если CLI установлен, дополнительно запускается:

```powershell
openspec validate <change-id>
```

Именно CLI может проверять дополнительные правила OpenSpec. Не считайте отсутствие CLI эквивалентом полной проверки.

## 9. Перенос подтверждённого change в Outcome

Сначала человек должен подтвердить change. Затем создаётся отдельный Outcome:

```text
workspaces/projects/<project-id>/outcomes/<outcome-id>/
```

После создания `pack.md` и `pack.json` выполните:

```powershell
pwsh ./scripts/map-openspec-to-pack.ps1 `
  -ProjectPath workspaces/projects/<project-id> `
  -ChangeName <change-id> `
  -OutcomePath workspaces/projects/<project-id>/outcomes/<outcome-id>
```

Скрипт:

1. Читает все `specs/**/spec.md` выбранного change.
2. Извлекает блоки `Requirement: AC-NNN` и `Requirement: NFR-NNN`.
3. Переносит statements и scenarios в `specifications.md`.
4. Создаёт `openspec-traceability.md`.
5. Если `pack.json` уже существует, проверяет наличие каждого OpenSpec ID в Pack.

Скрипт **не создаёт и не заполняет** `pack.md` или `pack.json`. Их формирует процесс `pde-create-pack` по подтверждённому change.

После mapping проверьте Pack:

```powershell
pwsh ./scripts/validate-pack.ps1 `
  -Path workspaces/projects/<project-id>/outcomes/<outcome-id>
```

## 10. Какие файлы не являются рабочими настройками

Следующие файлы полезны, но их изменение само по себе не меняет выполнение OpenSpec:

| Файл или каталог | Для чего нужен | Почему это не рабочая настройка |
| --- | --- | --- |
| `integrations/openspec/README.md` | Описание контракта, версии, границ и команд | Это документация; исключение — согласованное обновление version pin |
| `integrations/openspec/openspec.env.example` | Пример безопасных переменных окружения | Значения начнут действовать только после установки в реальном окружении |
| `integrations/openspec/fixtures/sample-project/` | Эталон и тест интеграции | Это фикстура, а не рабочий проект |
| `workspaces/examples/` | Учебные примеры PDE | Примеры нельзя использовать как место промышленной работы |
| `templates/openspec/README.md` | Пояснение структуры нового проекта | Текст README не изменяет CLI или валидатор |
| `openspec-traceability.md` в Outcome | Результат трассировки | Обычно генерируется повторным mapping, а не настраивает его |

## 11. Типовые задачи и правильные файлы

### Добавить обязательное поле в каждое новое предложение

Измените:

```text
templates/openspec-change/proposal.md
templates/openspec/config.yaml
```

Если поле должно проверяться автоматически, дополнительно измените:

```text
scripts/validate-openspec-change.ps1
```

Для уже существующих проектов обновите их локальные `openspec/config.yaml` и change вручную.

### Изменить требования только одного проекта

Измените:

```text
workspaces/projects/<project-id>/openspec/config.yaml
```

Не меняйте глобальный шаблон, если правило не должно распространяться на другие проекты.

### Исправить один критерий приёмки

Измените соответствующий файл:

```text
workspaces/projects/<project-id>/openspec/changes/<change-id>/specs/<domain>/spec.md
```

После этого повторно выполните validation, обновите Pack по управляемому процессу и запустите mapping.

### Изменить способ переноса требований

Согласованно проверьте и при необходимости измените:

```text
integrations/openspec/pack-mapping.yaml
scripts/map-openspec-to-pack.ps1
.agents/skills/pde-create-pack/SKILL.md
integrations/openspec/fixtures/sample-project/
```

### Обновить OpenSpec CLI

Версия зафиксирована как `1.13.1`. Обновление оформляется отдельным платформенным изменением.

Нужно как минимум:

1. Изменить version pin в `integrations/openspec/README.md`.
2. Изменить `tool_version_pin` в `integrations/openspec/pack-mapping.yaml`.
3. Проверить параметры `openspec init` в `scripts/init-openspec-project.ps1`.
4. Запустить проверку фикстуры.
5. Запустить полную проверку репозитория.

Не обновляйте глобальный пакет до произвольной версии без синхронизации репозитория.

## 12. Безопасность и ограничения

- Не включайте телеметрию OpenSpec.
- Не сохраняйте токены и секреты в Git.
- Не запускайте `openspec init` в корне PDE.
- Не используйте `--tools cursor` или `--tools all`: команда может записать файлы в платформенный каталог `.cursor/`.
- Не запускайте `/opsx:apply` и не генерируйте продуктовый код из PDE intake.
- Не выполняйте `openspec archive` до выпуска Outcome и явного решения об архивировании.
- Не создавайте `pack.md` или `pack.json` внутри `openspec/changes/`.
- Не меняйте одновременно файлы рабочего проекта и платформенные правила в одном изменении.
- Не расширяйте scope подтверждённого Outcome без Definition Change.

## 13. Полный безопасный сценарий работы

```powershell
# 1. Инициализировать OpenSpec только внутри существующего проекта
pwsh ./scripts/init-openspec-project.ps1 -ProjectId my-product

# 2. Создать и заполнить change
# workspaces/projects/my-product/openspec/changes/chg-001-device-status/

# 3. Проверить change
pwsh ./scripts/validate-openspec-change.ps1 `
  -ProjectPath workspaces/projects/my-product `
  -ChangeName chg-001-device-status

# 4. После подтверждения change создать Pack через процесс pde-create-pack

# 5. Перенести требования и создать трассировку
pwsh ./scripts/map-openspec-to-pack.ps1 `
  -ProjectPath workspaces/projects/my-product `
  -ChangeName chg-001-device-status `
  -OutcomePath workspaces/projects/my-product/outcomes/OUT-001-device-status

# 6. Проверить Pack
pwsh ./scripts/validate-pack.ps1 `
  -Path workspaces/projects/my-product/outcomes/OUT-001-device-status
```

Если менялись платформенные шаблоны, scripts, skills, rules, интеграционный контракт или структура репозитория, дополнительно выполните:

```powershell
pwsh ./scripts/validate-repository.ps1
```

## 14. Диагностика частых проблем

### «Project folder is missing»

Причина: каталог `workspaces/projects/<project-id>/` не существует или в `-ProjectId` допущена ошибка.

Решение: сначала создайте каталог проекта и проверьте точное имя.

### «OpenSpec config is missing»

Причина: в проекте отсутствует `openspec/config.yaml`.

Решение: выполните init либо восстановите конфигурацию из `templates/openspec/config.yaml`.

### «Change has no delta spec.md files»

Причина: в `changes/<change-id>/specs/` нет ни одного файла с точным именем `spec.md`.

Решение: создайте доменный каталог и `spec.md` по шаблону.

### «No AC-NNN or NFR-NNN requirements found»

Причина: заголовок требования не соответствует формату.

Правильный пример:

```markdown
### Requirement: AC-001 Русское название
```

### «Duplicate requirement id»

Причина: один идентификатор использован больше одного раза в change.

Решение: назначьте уникальные номера. Один AC или NFR должен иметь один стабильный идентификатор.

### «Mapped requirement ... is not present in pack.json»

Причина: требование есть в OpenSpec, но его идентификатор отсутствует в Pack.

Решение: проверьте, был ли Pack обновлён после изменения change. Не меняйте идентификатор только ради прохождения проверки — сначала устраните смысловое расхождение.

### «OpenSpec CLI is not available; structural PDE checks only»

Это предупреждение, а не подтверждение полной валидности. Структура прошла локальные проверки, но правила CLI не проверялись. Установите зафиксированную версию CLI и повторите validation.

### После повторного init исчезли проектные правила

Причина: init-скрипт заменяет проектный `config.yaml` платформенным шаблоном.

Решение: восстановите локальные изменения из Git и решите, должны ли они остаться проектными или войти в общий шаблон.

## 15. Контрольный список перед завершением

- [ ] OpenSpec размещён только в `workspaces/projects/<project-id>/openspec/`.
- [ ] `config/features.yaml` содержит осознанное значение `openspec_intake.enabled`.
- [ ] Телеметрия выключена.
- [ ] Проектный `openspec/config.yaml` содержит актуальный контекст и правила.
- [ ] Один change соответствует одному Outcome.
- [ ] Все человекочитаемые тексты написаны на русском языке.
- [ ] Структурные заголовки OpenSpec и идентификаторы сохранены в ожидаемом формате.
- [ ] В change нет `pack.md` и `pack.json`.
- [ ] Все AC/NFR имеют уникальные стабильные идентификаторы.
- [ ] `validate-openspec-change.ps1` завершился успешно.
- [ ] Change подтверждён человеком до создания итогового Pack.
- [ ] Mapping создал `specifications.md` и `openspec-traceability.md`.
- [ ] `validate-pack.ps1` завершился успешно.
- [ ] После платформенных изменений выполнен `validate-repository.ps1`.

## 16. Где посмотреть рабочий эталон

Эталонная интеграционная фикстура:

```text
integrations/openspec/fixtures/sample-project/
```

Она показывает полную цепочку:

```text
inputs/brd.md
→ openspec/changes/chg-001-device-status/
→ outcomes/OUT-FIX-001-device-status/
```

Используйте её для понимания структуры и тестирования платформы. Для реальной работы всегда создавайте отдельный проект в `workspaces/projects/`.
