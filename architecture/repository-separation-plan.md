# План разделения репозиториев

## Назначение

Документ фиксирует инвентаризацию текущего PDE-репозитория перед созданием общей нормативной основы `engineering-control` и будущих сред `ase-environment` и `qsre-environment`.

Инвентаризация выполнена на baseline:

- Git tag: `pde-baseline-v0.1.0`;
- commit: `a8df54374e2b0db6c13175c7bf1b1cf073a7441a`;
- текущий источник истины: репозиторий PDE;
- режим разделения: подготовка без переноса и удаления файлов.

Этот документ не меняет источники истины, структуру каталогов, feature flags, workflows, validators или правила работы команды.

## Правила безопасного разделения

1. Существующие файлы сначала классифицируются, затем копируются в новый репозиторий и проверяются. Перемещение или удаление выполняется только отдельным последующим решением.
2. До утверждения `engineering-control` текущий каталог `governance/` остаётся единственным нормативным источником истины.
3. Копирование и смысловое изменение документа не объединяются в один коммит.
4. Каждый переносимый набор сохраняет ссылку на исходный tag и полный commit SHA.
5. PDE, ASE и QSRE используют версии контрактов и immutable-ссылки, а не независимые изменяемые копии одних и тех же норм.
6. Текущие PDE-specific skills, rules, workspace и локальная конфигурация агентов не становятся общей нормативной основой автоматически.
7. Рабочие и исторические проектные материалы не входят в целевую архитектуру репозиториев среды.

## Состояние инвентаризации

В baseline отслеживается 107 файлов:

- `governance/` — 22;
- `workspaces/` — 12;
- `integrations/` — 12;
- `templates/` — 11;
- `.github/` — 9;
- корневые файлы — 7;
- `.cursor/` — 6;
- `scripts/` — 6;
- `.agents/` — 5;
- `docs/` — 5;
- `operations/` — 5;
- `architecture/` — 4 до добавления этого плана;
- `.codex/`, `config/` и `schemas/` — по одному файлу.

Категории инвентаризации:

- `shared` — кандидат в общую нормативную основу;
- `pde-only` — принадлежит рабочей среде PDE;
- `ase-future` — заготовка или требование для будущей ASE-среды;
- `qsre-future` — заготовка или требование для будущей QSRE-среды;
- `local` — локальная конфигурация, демонстрационные данные или генерируемое состояние;
- `split-required` — каталог или файл содержит несколько типов ответственности и не может копироваться целиком без разделения.

## Инвентаризация по каталогам

### Корень репозитория

| Объект | Категория | Решение |
| --- | --- | --- |
| `README.md` | `pde-only` | Оставить главным входом PDE. Для каждого будущего репозитория создать собственный README. |
| `AGENTS.md` | `pde-only` | Оставить инструкцией PDE. Не переносить в общий репозиторий. |
| `CONTRIBUTING.md` | `split-required` | Текущие правила относятся к PDE. Общую часть change control позднее оформить отдельно в `engineering-control`. |
| `SECURITY.md` | `pde-only` | Оставить repository-level инструкцией PDE. Общие нормы безопасности уже представлены в governance. |
| `CHANGELOG.md` | `pde-only` | История версий PDE не должна смешиваться с версиями общей нормативной основы. |
| `.editorconfig` | `shared` | Можно повторно использовать как технический стандарт, но новый репозиторий получает собственную копию. |
| `.gitignore` | `pde-only` | Содержит локальные исключения PDE и OpenSpace. Для каждого репозитория формируется собственный файл. |

### `governance/`

Категория каталога: `shared`.

Первоначальная безопасная единица копирования:

```text
governance/
├── README.md
├── document-control.yaml
└── 01-pde-charter.md ... 20-compliance-obligations-register.md
```

Решение:

- на первом шаге скопировать каталог полностью без редактирования;
- сохранить исходные пути, версии, Document ID и метаданные;
- не объявлять копию нормативным источником истины до завершения проверки;
- после копирования отдельно определить, какие документы остаются PDE-specific, а какие становятся общими Engineering Governance;
- переименование PDE-норм в общие нормы допускается только отдельным governance change после миграции.

Особая зависимость: `document-control.yaml` содержит 20 жёстко заданных путей `governance/*.md`. Изменение структуры каталога потребует одновременного изменения каталога документов и validators.

### `schemas/`

| Объект | Категория | Решение |
| --- | --- | --- |
| `pack.schema.json` | `shared` | Копировать как версионируемый контракт Pack. PDE продолжает создавать Pack, а ASE и QSRE читают зафиксированную версию схемы. |

Целевое развитие общей основы:

```text
schemas/
├── pack.schema.json
├── pde-to-ase.schema.json
├── ase-to-qsre.schema.json
├── qsre-to-pde.schema.json
└── evidence.schema.json
```

Новые схемы не создаются в рамках инвентаризации.

### `templates/`

Категория каталога: `split-required`.

Кандидаты в общие contract templates:

- `ase-handoff.md`;
- `qsre-feedback.md`;
- `evidence-bundle.md`;
- `definition-change.md`;
- `decision-log.md`;
- `outcome-check.md`;
- `release-plan.md`.

PDE-specific templates:

- `pack-mini.md`;
- `pack-full.md`;
- `pack.json`;
- `redmine-outcome.md`.

Решение: не копировать весь каталог одной операцией. Общие кандидаты сначала сверяются с будущими JSON Schema и контрактными версиями. PDE-specific шаблоны остаются в PDE.

### `scripts/`

Категория каталога: `split-required`.

| Скрипт | Текущая зависимость | Решение |
| --- | --- | --- |
| `doctor.ps1` | Корневая структура PDE, локальные workflows, `features.yaml` | Оставить в PDE. Для других сред создавать отдельные doctor scripts. |
| `validate-repository.ps1` | `governance/`, skills, Pack Schema, OpenSpace и PDE-структура | Оставить в PDE; общие проверки выделять в новые скрипты без изменения текущего. |
| `validate-pack.ps1` | Локальные `schemas/pack.schema.json` и `workspaces/**/pack.json` | Кандидат на разделение: общая библиотека проверки плюс PDE wrapper. |
| `validate-evidence.ps1` | Локальные Pack и `workspaces/**/evidence.md` | Кандидат на разделение: общая контрактная проверка плюс environment wrapper. |
| `check-governance-change.ps1` | Локальный Git diff и список платформенных путей PDE | Логику change control можно адаптировать для `engineering-control`, исходный скрипт оставить в PDE. |
| `check-links.ps1` | Локальные Markdown-файлы | Можно повторно использовать, но каждый репозиторий запускает его в собственном контексте. |

Прямое копирование всех скриптов в `engineering-control` создаст ложные ошибки из-за отсутствия `workspaces/`, PDE skills и PDE feature flags.

### `.github/`

Категория каталога: `split-required`.

- `CODEOWNERS` относится к командам и путям конкретного PDE-репозитория;
- Issue templates `outcome.yml` и `definition-change.yml` относятся к PDE;
- Pull Request template содержит PDE traceability и требует отдельной версии для общего governance;
- все четыре workflow вызывают локальные скрипты и используют локальные пути PDE.

Решение:

- оставить текущую `.github/` в PDE без изменений;
- в `engineering-control` создать собственные CODEOWNERS, PR template и governance workflows;
- reusable workflows проектировать как новые интерфейсы с `workflow_call`, а не переносить текущие workflow без адаптации;
- будущие PDE, ASE и QSRE callers должны фиксировать тег или commit SHA общего workflow.

### `.agents/skills/`

Категория каталога: `pde-only`.

Все пять текущих skills реализуют PDE-процесс:

- создание Pack;
- Ready Review;
- Definition Change;
- Evidence Bundle;
- Outcome Check.

Они напрямую ссылаются на локальные governance-документы, templates и scripts. В `shared-skills/` нельзя механически копировать эти skills. Общими могут стать только новые skills, не зависящие от структуры одной рабочей среды, например проверка traceability или качества нормативного документа.

### `.cursor/rules/`

Категория каталога: `pde-only`.

Rules содержат PDE-specific пути `workspaces/`, Pack, Evidence и governance. Будущие ASE и QSRE получают собственные rules. Общий репозиторий не должен навязывать рабочей среде весь PDE-контекст.

### `.codex/`

Категория каталога: `pde-only` и `local`.

`.codex/config.toml` предполагает:

- запуск OpenSpace из корня текущего репозитория;
- локальную библиотеку `.agents/skills`;
- PDE workspace `.`;
- выключенный cloud mode.

Решение: оставить конфигурацию в PDE. Для каждой будущей среды подготовить отдельную локальную конфигурацию с минимальными правами.

### `config/`

Категория каталога: `pde-only`.

`features.yaml` описывает состояние конкретной PDE-среды, включая подготовленные ASE/QSRE adapters. Общая нормативная основа должна хранить допустимые контракты и политики, но не операционное состояние каждой среды.

В будущем каждая среда получает собственный `features.yaml`, а используемая версия общей основы фиксируется отдельным `control-plane.yaml`.

### `architecture/`

Категория каталога: `split-required`.

| Документ | Решение |
| --- | --- |
| `system-context.md` | Оставить PDE-контекстом; использовать как вход для нового общего system context. |
| `repository-layout.md` | Оставить описанием текущего PDE-репозитория. |
| `pde-ase-qsre-flow.md` | Кандидат на общую концептуальную документацию после устранения локальных предположений. |
| `toolchain-and-feature-flags.md` | Оставить PDE-документом; общая основа должна описывать только обязательные интерфейсы. |
| `repository-separation-plan.md` | Контрольный план миграции, остаётся в PDE до завершения разделения. |

### `operations/`

Категория каталога: `pde-only`.

Текущие onboarding, roadmap, activation runbook, maintenance calendar и Definition of Done описывают эксплуатацию PDE. Будущие репозитории получают собственные операции. Общие review cycles и approvals остаются в governance, а не копируются из PDE operations.

### `integrations/`

Категория каталога: `pde-only` с заготовками `ase-future` и `qsre-future`.

| Подкаталог | Категория | Решение |
| --- | --- | --- |
| `github/` | `pde-only` | Настройки и fork workflow текущего PDE. |
| `redmine/` | `split-required` | Подключение остаётся в PDE. `field-mapping.yaml` копируется в общую основу только как прямая reference dependency документа `18-redmine-workflow.md`. |
| `openspace/` | `pde-only` | Локальный OpenSpace для PDE skills. Будущие среды получают отдельные настройки. |
| `ase/` | `ase-future` | Оставить PDE-side адаптером. Использовать как требование к входу будущей ASE, не переносить как готовую среду. |
| `qsre/` | `qsre-future` | Оставить PDE-side адаптером обратной связи. |
| `unleash/` | `pde-only` | Опциональная интеграция текущей среды и release process. |
| `observability/` | `pde-only` | Опциональная интеграция измерения Outcome. |

### `workspaces/`

Категория каталога: `pde-only` и `local`.

- `workspaces/projects/` — реальные PDE-проекты и Outcomes;
- `workspaces/examples/` — демонстрационные данные для проверки PDE;
- рабочие и демонстрационные материалы не копируются в `engineering-control`;
- будущие ASE и QSRE не должны получать полную копию PDE workspace;
- обмен выполняется через версии контрактов, repository URL, path и commit SHA.

### `docs/`

Категория каталога: `pde-only` с архитектурными reference materials.

Текущие PNG относятся к объяснению PDE и целевой архитектуры. Они остаются в PDE. При необходимости общий репозиторий получает отдельную актуальную схему, а не неуправляемую копию.

`docs/file-catalog.md` содержит отдельные исторические записи о рабочих файлах, которых больше нет в отслеживаемом дереве. Это не блокирует разделение, но каталог следует исправить отдельным documentation-only изменением, не смешивая исправление с миграцией.

## Карта внутренних зависимостей

### Нормативный каталог

```text
governance/document-control.yaml
        └── governance/01...20.md
```

Зависимость жёсткая: пути и метаданные проверяются `validate-repository.ps1`.

### Pack

```text
governance/05-risk-model.md
governance/07-pack-standard.md
governance/09-lifecycle-and-gates.md
governance/14-outcome-measurement.md
        ↓
templates/pack-mini.md + templates/pack-full.md + templates/pack.json
        ↓
schemas/pack.schema.json
        ↓
scripts/validate-pack.ps1
        ↓
workspaces/**/pack.md + pack.json
        ↓
.github/workflows/validate-pack.yml
```

Нельзя вынести только Schema: validator и PDE templates должны явно фиксировать используемую версию общей схемы.

### Evidence

```text
governance/10-evidence-standard.md
        ↓
templates/evidence-bundle.md
        ↓
scripts/validate-evidence.ps1
        ↓
workspaces/**/evidence.md + pack.json
        ↓
.github/workflows/validate-evidence.yml
```

Evidence validator использует Pack baseline и поэтому зависит от совместимости как минимум двух контрактов.

### Governance change control

```text
governance/15-document-governance.md
        ↓
governance/document-control.yaml
        ↓
.cursor/rules/30-governance-change.mdc
scripts/check-governance-change.ps1
.github/pull_request_template.md
        ↓
.github/workflows/governance-change-control.yml
```

После появления `engineering-control` основной governance gate должен работать там. PDE сохраняет собственный gate для изменений adapters, templates, skills и локального control-plane reference.

### Skills и OpenSpace

```text
governance/17-skill-openspace-lifecycle.md
        ↓
.agents/skills/**/SKILL.md
        ↓
.cursor/rules/40-skill-change.mdc
.codex/config.toml
integrations/openspace/*
config/features.yaml
        ↓
scripts/validate-repository.ps1
```

Пути `.agents/skills` и workspace `.` зафиксированы в локальной конфигурации. Перенос skills в другой репозиторий без изменения OpenSpace configuration нарушит индексирование.

### Repository validation

`doctor.ps1` и `validate-repository.ps1` жёстко ожидают PDE-структуру, включая:

- `README.md` и `AGENTS.md`;
- `config/features.yaml`;
- локальный `governance/document-control.yaml`;
- локальную Pack Schema;
- четыре локальных GitHub workflows;
- `workspaces/`;
- PDE skills;
- согласованность OpenSpace flags с `.codex/config.toml`.

Поэтому удаление локального governance или Schema до появления нового режима validator немедленно сломает CI.

### Markdown links

Репозиторий содержит относительные Markdown links между README, governance, templates, integrations, workspaces и docs. Межрепозиторные относительные ссылки работать не будут. Перед переключением источника истины потребуется:

- сохранить локальные compatibility pages; или
- заменить ссылки immutable GitHub URL с tag/commit SHA; или
- научить сборку разрешать control-plane references.

## Риски разделения

1. **Преждевременное удаление локального governance.** Сломает doctor, repository validator, rules, skills и Markdown links.
2. **Два нормативных источника истины.** Возникает, если staging-копия объявлена Active до настройки версий и владельцев.
3. **Копирование PDE workflows как reusable workflows.** Текущие файлы не имеют `workflow_call` и ожидают локальные scripts.
4. **Копирование PDE skills в общий каталог.** Skills сохранят невалидные относительные пути и смешают функции сред.
5. **Несогласованные версии Pack и Evidence.** ASE или QSRE могут проверять артефакт другой версией схемы.
6. **Потеря истории происхождения.** Предотвращается baseline tag, source manifest и полным commit SHA.
7. **Слишком широкие права автоматизации.** Межрепозиторный доступ должен быть read-only по умолчанию и ограничиваться конкретными репозиториями.
8. **Смешение миграции и улучшения содержания.** Делает невозможным доказать идентичность переноса и безопасно откатить изменение.

## Рекомендуемые миграционные единицы

### Unit 1: Governance snapshot

```text
governance/**
source-baseline.yaml
```

Копируется без изменения содержания. Статус в новом репозитории: `staging`, `authoritative: false`.

Для сохранения работоспособности локальной ссылки из `18-redmine-workflow.md` вместе со snapshot допускается точная reference-копия `integrations/redmine/field-mapping.yaml`. Она не активирует интеграцию и не переносит credentials.

### Unit 2: Pack contract

```text
schemas/pack.schema.json
governance/05-risk-model.md
governance/07-pack-standard.md
governance/09-lifecycle-and-gates.md
governance/14-outcome-measurement.md
```

PDE templates и wrapper validator остаются в PDE.

### Unit 3: Handoff contracts

```text
governance/19-ase-qsre-interface-contract.md
templates/ase-handoff.md
templates/qsre-feedback.md
templates/evidence-bundle.md
templates/release-plan.md
```

После копирования для них создаются схемы и версии отдельным изменением.

### Unit 4: Shared CI interfaces

В `engineering-control` подготовлены reusable workflows `validate-pde.yml`, `validate-ase.yml`, `validate-qsre.yml` и `notify-peer.yml`. Они ещё не входят в pin `v1.0.0-rc.1`. Текущие PDE workflows не удаляются до успешного shadow-периода. Среды вызывают общие workflows только после отдельного обновления tag/SHA.

Межрепозиторные события на первом шаге создают Issue. Автоматический merge, изменение Pack и Ready-решение запрещены. Ограниченный GitHub App описывается в `engineering-control/docs/github-app.md`.

### Unit 5: Environment references

PDE получает `config/control-plane.yaml` только после выпуска проверенной версии `engineering-control`. Сначала используется `mode: shadow`.

## Что не входит в первый перенос

- `workspaces/**`;
- `.agents/skills/**`;
- `.cursor/rules/**`;
- `.codex/config.toml`;
- `config/features.yaml`;
- `operations/**`;
- `integrations/**`, кроме точной reference-копии `integrations/redmine/field-mapping.yaml`, необходимой нормативной ссылке;
- текущие `.github/workflows/**`;
- текущие Issue templates и CODEOWNERS;
- root README, AGENTS, SECURITY и CHANGELOG;
- PDE Pack templates и Redmine template;
- генерируемые reports, artifacts, локальные secrets и OpenSpace state.

## Критерии завершения этапа 2

- все основные каталоги классифицированы;
- выделены общие и PDE-specific материалы;
- зафиксированы прямые зависимости scripts, workflows, rules, skills и OpenSpace;
- определены риски преждевременного переноса;
- определены безопасные миграционные единицы;
- существующие файлы не перемещены и не удалены;
- текущая PDE-среда продолжает проходить repository validation.

## Следующий разрешённый этап

Пустой приватный репозиторий `engineering-control` создан: https://github.com/J4mes0n-04/engineering-control.git

В `engineering-control` из baseline `pde-baseline-v0.1.0` (`a8df54374e2b0db6c13175c7bf1b1cf073a7441a`) без изменения содержания скопированы:

- `Unit 1`: `governance/**`;
- общие кандидаты Unit 2/3: `schemas/pack.schema.json`, contract templates и `.editorconfig`.

Статус копии: `staging`, `authoritative: false`. Каталог `governance/` в PDE остаётся единственным нормативным источником истины. PDE-specific templates, workflows, skills и `governance/` в PDE не удалялись и не заменялись.

Следующий шаг — проверка snapshot. Units 4–5 и cutover не начинать до отдельного подтверждения.
