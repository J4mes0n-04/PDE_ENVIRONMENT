# PDE operating environment

Этот репозиторий — отправная точка для организации рабочей среды **PDE — Product Definition Engineering** в продуктовой команде, которая разрабатывает и поддерживает программное обеспечение для умных домов, бизнес-центров и гражданской инфраструктуры.

Документы написаны на русском языке. Имена файлов, каталогов, полей и технические идентификаторы — на английском, чтобы структура одинаково хорошо читалась человеком и обрабатывалась инструментами.

## Основной принцип

PDE превращает сигнал о проблеме в проверяемое определение продукта. Git хранит нормативные документы, Product Definition Pack, решения и доказательства. Redmine управляет потоком работы. Cursor и Codex используют `AGENTS.md`, rules и skills. OpenSpace находится между агентной средой и библиотекой skills: он помогает находить, оценивать и улучшать skills, но не имеет права автоматически менять нормативные документы.

```text
Signal -> PDE -> Product Definition Pack -> ASE adapter -> implementation
   ^                                                   |
   |                                                   v
Outcome Check <- PDE feedback <- QSRE adapter <- evidence and release

Cursor / Codex <-> OpenSpace local MCP <-> .agents/skills
                         |
                         v
                 quality records and proposals
                         |
                         v
                 Pull Request + human approval
```

ASE и QSRE пока не развёрнуты как отдельные среды. Репозиторий содержит явные контракты и адаптеры, чтобы подключить их позже без изменения базовой модели PDE.

## Быстрый старт

1. Прочитайте [PDE charter](governance/01-pde-charter.md), [глоссарий](governance/02-glossary.md) и [жизненный цикл](governance/09-lifecycle-and-gates.md).
2. Выполните `pwsh ./scripts/doctor.ps1`.
3. Настройте роли и владельцев в `governance/document-control.yaml` и `.github/CODEOWNERS`.
4. Создайте рабочий проект только внутри `workspaces/projects/` по инструкции из [workspaces/README.md](workspaces/README.md).
5. Создайте `pack.md` и `pack.json` из шаблонов. Выполните `pwsh ./scripts/validate-pack.ps1`.
6. Создайте Outcome в Redmine и свяжите его с конкретным commit SHA Pack.
7. После готовности Pack проведите Ready Review и сформируйте ASE handoff.
8. Перед выпуском соберите Evidence Bundle, получите QSRE feedback и выполните Outcome Check.

Демонстрационный Outcome находится отдельно в `workspaces/examples/` и не является действующей работой.

## Режимы среды

Обязательное ядро работает без Unleash, OpenTelemetry, Grafana и OpenSpace. Состояние интеграций задаётся в `config/features.yaml`.

- `core` — Git, GitHub Actions, Redmine, Cursor/Codex, Pack и Evidence.
- `openspace-local` — добавляется локальный OpenSpace MCP; облачный обмен запрещён.
- `release-control` — добавляется Unleash.
- `observability` — добавляются OpenTelemetry и Grafana.
- `future-engineering` — подключаются отдельные ASE и QSRE среды через стабильные handoff-контракты.

Включение флага не устанавливает инструмент автоматически. Оно означает, что конфигурация инструмента проверена, владелец назначен и команда решила использовать интеграцию.

## Структура репозитория

- `governance/` — нормативные документы. Это первичный источник обязательных правил.
- `architecture/` — описание устройства среды, границ и потоков данных.
- `operations/` — инструкции запуска, сопровождения и проверки готовности среды.
- `templates/` — шаблоны рабочих артефактов.
- `schemas/` — машиночитаемые схемы. Первая версия содержит облегчённую JSON Schema Pack.
- `workspaces/` — единственное место для проектов, Outcome и Evidence конкретной работы.
- `integrations/` — отключаемые адаптеры GitHub, Redmine, OpenSpace, ASE, QSRE, Unleash и observability.
- `.agents/skills/` — пять начальных skills PDE.
- `.cursor/rules/` — короткие правила, автоматически применяемые Cursor.
- `.codex/config.toml` — безопасная проектная конфигурация Codex; OpenSpace объявлен, но выключен.
- `.github/workflows/` — четыре базовых workflow GitHub Actions.
- `scripts/` — локальные проверки, используемые также в CI.
- `docs/file-catalog.md` — назначение каждого файла репозитория.

Полный каталог с расшифровкой находится в [file catalog](docs/file-catalog.md).

## Источники истины

- Нормативные правила — `governance/`.
- Состояние и приоритет — Redmine.
- Определение Outcome — `workspaces/projects/<project-id>/outcomes/<outcome-id>/pack.md` и `pack.json`.
- Реализация — репозиторий продукта и связанные Pull Request.
- Доказательства — Evidence Bundle и CI artifacts.
- Фактический результат — Outcome Check и ссылки на telemetry/support data.
- Инструкции агента — `AGENTS.md`, `.cursor/rules/` и `.agents/skills/`; они реализуют нормы, но не заменяют их.

## Что требуется настроить перед первым рабочим Outcome

- заменить временные команды-владельцы в `.github/CODEOWNERS`;
- определить Redmine URL, project key и custom fields;
- назначить PDE Lead, Delivery Lead, Outcome Owner и временных владельцев ASE/QSRE функций;
- утвердить документы со статусом `Draft`;
- выбрать пилот уровня R1 или R2;
- проверить branch protection и четыре workflow;
- решить, нужен ли OpenSpace в shadow mode для пилота.

## Важные ограничения

- Нельзя хранить полную независимую копию Pack в Redmine.
- Нельзя считать release завершением Outcome.
- Нельзя автоматически менять governance по результатам работы OpenSpace.
- Нельзя включать облачный обмен OpenSpace без отдельного изменения политики.
- Нельзя считать ASE или QSRE подключёнными только потому, что существуют каталоги адаптеров.
- Будущие требования ИБ, персональных данных и аудита регистрируются в `governance/20-compliance-obligations-register.md` до превращения в обязательные controls.

## Версия

Начальная версия пакета: `0.1.0-draft`. Лицензия намеренно не добавлена.
