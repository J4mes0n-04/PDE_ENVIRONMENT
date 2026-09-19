# Каталог файлов PDE-репозитория

Каталог объясняет назначение каждого файла начальной версии. При добавлении нового постоянного файла обновите этот список тем же Pull Request.

## Корень

- `README.md` — главная инструкция, архитектура, быстрый старт и карта каталогов.
- `AGENTS.md` — автоматически загружаемые инструкции Codex для всего репозитория.
- `CONTRIBUTING.md` — порядок веток, Pull Request и изменений governance/skills.
- `SECURITY.md` — базовые правила безопасности до появления отраслевых требований.
- `CHANGELOG.md` — история версий пакета среды.
- `.editorconfig` — единая UTF-8/LF-конфигурация текстовых файлов.
- `.gitignore` — исключение секретов, локального OpenSpace state и generated reports.
- `LICENSE` — намеренно отсутствует по решению владельца.

## Конфигурация агентов

- `.codex/config.toml` — проектная конфигурация Codex; OpenSpace MCP подготовлен, выключен и ограничен локальным режимом.
- `.cursor/rules/00-pde-core.mdc` — всегда применяемые границы PDE.
- `.cursor/rules/10-pack-work.mdc` — правила изменения `pack.md` и `pack.json`.
- `.cursor/rules/20-evidence.mdc` — правила качества Evidence Bundle.
- `.cursor/rules/30-governance-change.mdc` — change control нормативных документов.
- `.cursor/rules/40-skill-change.mdc` — безопасное изменение skills и OpenSpace proposals.
- `.agents/skills/pde-create-pack/SKILL.md` — создание согласованных Pack для человека и машины.
- `.agents/skills/pde-ready-review/SKILL.md` — проверка Ready gate.
- `.agents/skills/pde-definition-change/SKILL.md` — оформление материального изменения baseline.
- `.agents/skills/pde-evidence-bundle/SKILL.md` — сбор evidence по AC/NFR.
- `.agents/skills/pde-outcome-check/SKILL.md` — проверка фактического Outcome.

## GitHub

- `.github/CODEOWNERS` — области review; placeholder teams нужно заменить до branch protection.
- `.github/pull_request_template.md` — обязательная трассировка PR, evidence и impact.
- `.github/ISSUE_TEMPLATE/config.yml` — запрещает неструктурированные blank issues.
- `.github/ISSUE_TEMPLATE/outcome.yml` — форма создания Outcome.
- `.github/ISSUE_TEMPLATE/definition-change.yml` — форма изменения Pack baseline.
- `.github/workflows/validate-repository.yml` — целостность структуры и doctor.
- `.github/workflows/validate-pack.yml` — проверка Pack по schema и согласованности Markdown/JSON.
- `.github/workflows/validate-evidence.yml` — проверка покрытия AC/NFR Evidence Bundle.
- `.github/workflows/governance-change-control.yml` — отдельный gate причины и влияния изменения governance.

## Управление возможностями

- `config/features.yaml` — включение/выключение GitHub, Redmine, agents, OpenSpace, Unleash, observability, ASE и QSRE adapters.

## Документация репозитория

- `docs/file-catalog.md` — этот полный перечень и назначение каждого файла.
- `docs/pde-environment-flow.png` — основная визуальная карта пути Signal → PDE → ASE → QSRE → Outcome Check и локального контура OpenSpace.

## Архитектура

- `architecture/system-context.md` — границы PDE и внешних систем.
- `architecture/repository-layout.md` — разделение платформы и рабочих проектов; односторонняя граница: платформа влияет на `workspaces/`, работа в `workspaces/` не изменяет платформу.
- `architecture/pde-ase-qsre-flow.md` — прямой и обратный поток PDE–ASE–QSRE.
- `architecture/toolchain-and-feature-flags.md` — роли инструментов и правила их включения.

## Нормативные документы

- `governance/README.md` — уровни нормативности и правила чтения каталога.
- `governance/document-control.yaml` — машиночитаемые ID, версии, owners, approvers, статусы и review cycles.
- `governance/01-pde-charter.md` — назначение и границы PDE.
- `governance/02-glossary.md` — общий язык, роли и нормативные слова.
- `governance/03-roles-and-decision-rights.md` — права решений и временные ASE/QSRE функции.
- `governance/04-sources-of-truth.md` — распределение истины между Git, Redmine, CI и telemetry.
- `governance/05-risk-model.md` — классы R0–R3 и обязательная глубина контроля.
- `governance/06-agent-autonomy.md` — уровни A0–A3 и ограничения агентов.
- `governance/07-pack-standard.md` — обязательное содержание и версия Product Definition Pack.
- `governance/08-definition-change-policy.md` — управление материальным изменением baseline.
- `governance/09-lifecycle-and-gates.md` — состояния Outcome и критерии переходов.
- `governance/10-evidence-standard.md` — состав и качество Evidence Bundle.
- `governance/11-git-pr-review-standard.md` — ветки, Pull Request, approvals и merge.
- `governance/12-ci-gates-and-exceptions.md` — обязательные checks и waiver.
- `governance/13-release-rollout-rollback.md` — выпуск, staged rollout и откат.
- `governance/14-outcome-measurement.md` — metric contract и решения после выпуска.
- `governance/15-document-governance.md` — версии, review и изменение самих норм.
- `governance/16-ai-data-security-policy.md` — данные, агенты, MCP и local-only OpenSpace.
- `governance/17-skill-openspace-lifecycle.md` — создание, trust, evolution и retirement skills.
- `governance/18-redmine-workflow.md` — trackers, поля, states и WIP.
- `governance/19-ase-qsre-interface-contract.md` — стабильные handoff/feedback contracts.
- `governance/20-compliance-obligations-register.md` — место для будущих регуляторных требований.

## Эксплуатация

- `operations/onboarding.md` — ввод нового участника.
- `operations/adoption-roadmap.md` — этапы от governance baseline до масштабирования.
- `operations/activation-runbook.md` — безопасное включение опциональных интеграций.
- `operations/maintenance-calendar.md` — регулярные reviews и обслуживание.
- `operations/environment-definition-of-done.md` — проверяемая готовность самой среды.

## Интеграции

- `integrations/README.md` — общий индекс отключаемых адаптеров.
- `integrations/github/README.md` — repository settings и branch protection.
- `integrations/redmine/README.md` — подключение Redmine без копии Pack.
- `integrations/redmine/field-mapping.yaml` — названия trackers, custom fields и states.
- `integrations/openspace/README.md` — будущая установка, shadow mode, безопасность и rollback OpenSpace.
- `integrations/openspace/openspace.env.example` — local-only environment variables без секретов.
- `integrations/ase/README.md` — будущий вход в среду реализации.
- `integrations/qsre/README.md` — будущий feedback loop качества и выпуска.
- `integrations/unleash/README.md` — условия включения feature flags.
- `integrations/unleash/unleash.env.example` — выключенная примерная конфигурация Unleash.
- `integrations/observability/README.md` — условия включения OpenTelemetry/Grafana.
- `integrations/observability/observability.env.example` — выключенные exporters и локальные endpoints.

## Шаблоны и schema

- `templates/pack-mini.md` — компактный Pack для R0–R1.
- `templates/pack-full.md` — расширенный Pack для R2–R3.
- `templates/pack.json` — машиночитаемый контрольный шаблон Pack.
- `templates/definition-change.md` — изменение baseline.
- `templates/evidence-bundle.md` — индекс доказательств.
- `templates/outcome-check.md` — результат после validation window.
- `templates/decision-log.md` — журнал решений.
- `templates/release-plan.md` — rollout, stop conditions и rollback.
- `templates/ase-handoff.md` — контракт передачи PDE→ASE.
- `templates/qsre-feedback.md` — контракт обратной связи QSRE→PDE.
- `templates/redmine-outcome.md` — краткая карточка потока без дублирования Pack.
- `schemas/pack.schema.json` — облегчённая JSON Schema для `pack.json`.

## Скрипты

- `scripts/doctor.ps1` — проверка минимального набора файлов, команд и feature constraints.
- `scripts/validate-repository.ps1` — проверка каталога документов, skills, schema и OpenSpace safety defaults.
- `scripts/validate-pack.ps1` — schema validation и согласованность пары Pack.
- `scripts/validate-evidence.ps1` — покрытие AC/NFR и обязательных полей Evidence.
- `scripts/check-governance-change.ps1` — дополнительный Pull Request gate для governance.
- `scripts/check-links.ps1` — проверка локальных Markdown links.

## Рабочие пространства

- `workspaces/README.md` — правило хранения конкретной работы и односторонняя граница: платформа влияет на `workspaces/`, работа в `workspaces/` не изменяет платформу.
- `workspaces/projects/README.md` — место реальных проектов и Outcomes.
- `workspaces/examples/README.md` — предупреждение о демонстрационных данных.
- `workspaces/examples/DEMO-001-device-offline-alert/README.md` — описание учебного R2 Outcome.
- `workspaces/examples/DEMO-001-device-offline-alert/pack.md` — заполненный человекочитаемый Pack.
- `workspaces/examples/DEMO-001-device-offline-alert/pack.json` — валидная машиночитаемая запись Pack.
- `workspaces/examples/DEMO-001-device-offline-alert/definition-change.md` — заполненный `DC-001`.
- `workspaces/examples/DEMO-001-device-offline-alert/evidence.md` — демонстрационный Evidence Bundle.
- `workspaces/examples/DEMO-001-device-offline-alert/release-plan.md` — демонстрационный staged rollout.
- `workspaces/examples/DEMO-001-device-offline-alert/ase-handoff.md` — пример передачи в ASE.
- `workspaces/examples/DEMO-001-device-offline-alert/qsre-feedback.md` — пример обратного сигнала QSRE.
- `workspaces/examples/DEMO-001-device-offline-alert/outcome-check.md` — заполненный вердикт `keep`.
