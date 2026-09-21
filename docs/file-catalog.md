# Каталог файлов PDE-репозитория

Каталог объясняет назначение каждого файла начальной версии. При добавлении нового постоянного файла обновите этот список тем же Pull Request.

## Корень

- `README.md` — главная инструкция: быстрый старт, карта каталогов, источники истины и механика передачи PDE → ASE → QSRE.
- `AGENTS.md` — автоматически загружаемые инструкции Codex для всего репозитория.
- `CONTRIBUTING.md` — порядок веток, Pull Request и изменений governance/skills.
- `SECURITY.md` — базовые правила безопасности до появления отраслевых требований.
- `CHANGELOG.md` — история версий пакета среды.
- `INC1.md` — пошаговая программа создания, объединения и вывода сред PDE, ASE, QSRE и общей нормативной основы в production.
- `INC2.md` — инструкция развёртывания и настройки готового комплекта сред в новом GitHub-контуре или на новой площадке.
- `INC3.md` — полный контекст программы, принятые решения, текущее состояние и точка продолжения для нового диалога или участника.
- `.editorconfig` — единая UTF-8/LF-конфигурация текстовых файлов.
- `.gitignore` — исключение секретов, локального OpenSpace state и generated reports.
- `LICENSE` — намеренно отсутствует по решению владельца.

## Конфигурация агентов

- `.codex/config.toml` — проектная конфигурация Codex; OpenSpace MCP подготовлен, выключен и ограничен локальным режимом.
- `.cursor/rules/00-pde-core.mdc` — всегда применяемые границы PDE.
- `.cursor/rules/05-outcome-intake.mdc` — обязательные уточняющие вопросы по входным документам и размещение каждого Outcome в отдельном каталоге проекта.
- `.cursor/rules/06-openspec-intake.mdc` — OpenSpec change обязателен до нового Pack при включённом intake.
- `.cursor/commands/pde-intake-openspec.md` — команда Cursor для разбора требований до Outcome.
- `.cursor/rules/10-pack-work.mdc` — правила изменения `pack.md` и `pack.json`.
- `.cursor/rules/20-evidence.mdc` — правила качества Evidence Bundle.
- `.cursor/rules/30-governance-change.mdc` — change control нормативных документов.
- `.cursor/rules/40-skill-change.mdc` — безопасное изменение skills и OpenSpace proposals.
- `.agents/skills/pde-create-pack/SKILL.md` — создание согласованных Pack для человека и машины.
- `.agents/skills/pde-intake-openspec/SKILL.md` — разбор бизнес-требований через OpenSpec до Pack.
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
- `.github/ISSUE_TEMPLATE/cross-repo-signal.yml` — ручное межрепозиторное уведомление без merge и без изменения Pack.
- `.github/workflows/validate-repository.yml` — целостность структуры и doctor.
- `.github/workflows/validate-pack.yml` — проверка Pack по schema и согласованности Markdown/JSON.
- `.github/workflows/validate-evidence.yml` — проверка покрытия AC/NFR Evidence Bundle.
- `.github/workflows/governance-change-control.yml` — отдельный gate причины и влияния изменения governance.
- `.github/workflows/notify-ase-ready.yml` — ручное уведомление ASE о PDE Ready; создаёт Issue и не объединяет Pull Request.
- `.github/workflows/listen-qsre-feedback.yml` — локальное Issue по обратной связи QSRE.

## Управление возможностями

- `config/features.yaml` — включение/выключение GitHub, Redmine, agents, OpenSpace, OpenSpec, Unleash, observability, ASE и QSRE adapters.

## Документация репозитория

- `docs/file-catalog.md` — этот полный перечень и назначение каждого файла.
- `docs/pde-environment-flow.png` — основная визуальная карта пути Signal → PDE → ASE → QSRE → Outcome Check и локального контура OpenSpace.
- `docs/pde-web-interface-mockup.png` — концептуальный макет web-интерфейса первичной настройки, подключений и проверки среды PDE.
- `docs/pde-ase-qsre-handoff-flow.png` — слайд со схемой передачи работы и обратной связи между PDE, ASE и QSRE.
- `docs/target-architecture.png` — целевая архитектура среды PDE и связанных контуров.
- `docs/pde_ase_qsre_all.png` — сводная схема контуров PDE, ASE и QSRE.

## Архитектура

- `architecture/system-context.md` — границы PDE и внешних систем.
- `architecture/repository-layout.md` — разделение платформы и рабочих проектов; односторонняя граница: платформа влияет на `workspaces/`, работа в `workspaces/` не изменяет платформу.
- `architecture/pde-ase-qsre-flow.md` — прямой и обратный поток PDE–ASE–QSRE.
- `architecture/toolchain-and-feature-flags.md` — роли инструментов и правила их включения.
- `architecture/repository-separation-plan.md` — инвентаризация файлов, внутренних зависимостей и безопасных миграционных единиц перед разделением PDE, общей нормативной основы, ASE и QSRE.
- `architecture/governance-duplicate-removal-plan.md` — отдельный план будущего удаления дубликатов governance из PDE; до выхода из периода параллельной работы файлы не удаляются.

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
- `operations/parallel-stabilization-period.md` — период параллельной работы PDE/control/ASE/QSRE, чеклист циклов и критерии выхода до удаления дубликатов.

## Интеграции

- `integrations/README.md` — общий индекс отключаемых адаптеров.
- `integrations/github/README.md` — repository settings и branch protection.
- `integrations/redmine/README.md` — подключение Redmine без копии Pack.
- `integrations/redmine/field-mapping.yaml` — названия trackers, custom fields и states.
- `integrations/openspace/README.md` — будущая установка, shadow mode, безопасность и rollback OpenSpace.
- `integrations/openspace/openspace.env.example` — local-only environment variables без секретов.
- `integrations/openspec/README.md` — роль OpenSpec как intake перед Outcome, границы, запреты и проверки.
- `integrations/openspec/openspec.env.example` — выключенная телеметрия OpenSpec без секретов.
- `integrations/openspec/pack-mapping.yaml` — соответствие артефактов OpenSpec полям Pack.
- `integrations/openspec/fixtures/sample-project/README.md` — описание эталонного разбора intake.
- `integrations/openspec/fixtures/sample-project/inputs/brd.md` — входное бизнес-требование фикстуры.
- `integrations/openspec/fixtures/sample-project/openspec/config.yaml` — OpenSpec config эталона.
- `integrations/openspec/fixtures/sample-project/openspec/specs/README.md` — пояснение пустых specs фикстуры.
- `integrations/openspec/fixtures/sample-project/openspec/specs/.gitkeep` — сохранение каталога specs фикстуры.
- `integrations/openspec/fixtures/sample-project/openspec/changes/README.md` — индекс change фикстуры.
- `integrations/openspec/fixtures/sample-project/openspec/changes/archive/.gitkeep` — архив change фикстуры.
- `integrations/openspec/fixtures/sample-project/openspec/changes/chg-001-device-status/proposal.md` — предложение эталонного change.
- `integrations/openspec/fixtures/sample-project/openspec/changes/chg-001-device-status/design.md` — проектное решение эталонного change.
- `integrations/openspec/fixtures/sample-project/openspec/changes/chg-001-device-status/tasks.md` — срезы поставки эталонного change.
- `integrations/openspec/fixtures/sample-project/openspec/changes/chg-001-device-status/specs/alerting/spec.md` — delta spec с AC-001, AC-002 и NFR-001.
- `integrations/openspec/fixtures/sample-project/outcomes/OUT-FIX-001-device-status/pack.md` — Pack, собранный из эталонного change.
- `integrations/openspec/fixtures/sample-project/outcomes/OUT-FIX-001-device-status/pack.json` — машиночитаемый Pack эталона.
- `integrations/openspec/fixtures/sample-project/outcomes/OUT-FIX-001-device-status/specifications.md` — сценарии, перенесённые скриптом mapping.
- `integrations/openspec/fixtures/sample-project/outcomes/OUT-FIX-001-device-status/openspec-traceability.md` — трассировка change → Pack эталона.
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
- `templates/specifications.md` — человекочитаемые сценарии, перенесённые из OpenSpec.
- `templates/openspec-traceability.md` — таблица соответствия change и Pack.
- `templates/openspec/README.md` — пояснение каталога OpenSpec внутри проекта.
- `templates/openspec/config.yaml` — PDE-контекст и правила артефактов OpenSpec.
- `templates/openspec/specs/README.md` — правило не заполнять specs до release.
- `templates/openspec/specs/.gitkeep` — сохранение пустого каталога текущих спецификаций.
- `templates/openspec/changes/README.md` — правило один change на один Outcome.
- `templates/openspec/changes/archive/.gitkeep` — архив завершённых change.
- `templates/openspec-change/explore.md` — черновик исследования сигнала.
- `templates/openspec-change/proposal.md` — шаблон предложения change.
- `templates/openspec-change/design.md` — шаблон проектного решения change.
- `templates/openspec-change/tasks.md` — срезы поставки для ASE.
- `templates/openspec-change/specs/domain/spec.md` — шаблон delta spec с AC/NFR.
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
- `scripts/validate-openspec-change.ps1` — структурная проверка OpenSpec change и идентификаторов AC/NFR.
- `scripts/map-openspec-to-pack.ps1` — перенос сценариев OpenSpec в `specifications.md` и трассировку Outcome.
- `scripts/init-openspec-project.ps1` — инициализация `openspec/` внутри проекта без записи в корень PDE.
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
- `workspaces/projects/pixel-space-dodger/README.md` — обзор тестового проекта пиксельной космической аркады.
- `workspaces/projects/pixel-space-dodger/task-brief.md` — входное тестовое описание игры: корабль, астероиды, автострельба, меню и рекорды.
- `workspaces/projects/pixel-space-dodger/openspec/README.md` — OpenSpec-каталог проекта для новых разборов.
- `workspaces/projects/pixel-space-dodger/openspec/config.yaml` — PDE-правила OpenSpec проекта.
- `workspaces/projects/pixel-space-dodger/openspec/specs/README.md` — текущие specs после выпуска, сейчас пусто.
- `workspaces/projects/pixel-space-dodger/openspec/specs/.gitkeep` — сохранение каталога specs.
- `workspaces/projects/pixel-space-dodger/openspec/changes/README.md` — место для будущих change до нового Outcome.
- `workspaces/projects/pixel-space-dodger/openspec/changes/archive/.gitkeep` — архив change проекта.
- `workspaces/projects/pixel-space-dodger/outcomes/README.md` — правило размещения отдельных Outcomes проекта.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/README.md` — индекс Outcome OUT-PSD-001.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/pack.md` — человекочитаемый Mini Pack OUT-PSD-001 версии 1.0.0.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/pack.json` — машиночитаемый Mini Pack OUT-PSD-001 версии 1.0.0.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/ase-handoff.md` — передача OUT-PSD-001 в ASE.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/definition-change.md` — DC-001 расширение критериев AC-008…AC-030.
- `workspaces/projects/pixel-space-dodger/outcomes/OUT-PSD-001-pixel-space-dodger/definition-change-dc-002.md` — DC-002 жизни, силуэт корабля и спавн врагов за краем поля.
- `workspaces/projects/av-control-configurator/README.md` — обзор проекта веб-конфигуратора AV Control.
- `workspaces/projects/av-control-configurator/project-context.md` — границы проекта и North Star.
- `workspaces/projects/av-control-configurator/inputs/README.md` — индекс входных документов конфигуратора.
- `workspaces/projects/av-control-configurator/inputs/SRC-CFG-001-sources.md` — указатель исходников Working.
- `workspaces/projects/av-control-configurator/inputs/BRD-CFG-001-configurator.md` — бизнес-требование на создание конфигуратора по CJM и ценностям.
- `workspaces/projects/av-control-configurator/inputs/VIS-CFG-001-visual-prohibitions.md` — запреты визуала против шаблона ИИ.
- `workspaces/projects/av-control-configurator/openspec/README.md` — OpenSpec-каталог проекта до Pack.
- `workspaces/projects/av-control-configurator/openspec/config.yaml` — PDE-правила OpenSpec проекта.
- `workspaces/projects/av-control-configurator/openspec/specs/README.md` — текущие specs после выпуска, сейчас пусто.
- `workspaces/projects/av-control-configurator/openspec/specs/.gitkeep` — сохранение каталога specs.
- `workspaces/projects/av-control-configurator/openspec/changes/README.md` — место для change до Outcome.
- `workspaces/projects/av-control-configurator/openspec/changes/archive/.gitkeep` — архив change проекта.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/explore.md` — разбор BRD и VIS перед change.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/proposal.md` — предложение веб-конфигуратора комплектов.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/design.md` — решение без скрытого расширения области.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/tasks.md` — срезы поставки для ASE, не SoT Pack.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/specs/kit-workspace/spec.md` — delta AC рабочего пространства комплекта.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/specs/wizard-change/spec.md` — delta AC мастера и версии комплекта.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/specs/hygiene-incomplete/spec.md` — delta AC уборки и неполного железа.
- `workspaces/projects/av-control-configurator/openspec/changes/chg-001-web-configurator/specs/visual-surface/spec.md` — delta NFR поверхности «К» по VIS-BAN.
- `workspaces/projects/av-control-configurator/outcomes/README.md` — правило размещения Outcomes проекта.
- `workspaces/projects/av-control-configurator/outcomes/OUT-CFG-001-web-configurator/pack.md` — человекочитаемый Pack веб-конфигуратора.
- `workspaces/projects/av-control-configurator/outcomes/OUT-CFG-001-web-configurator/pack.json` — машиночитаемый Pack веб-конфигуратора.
- `workspaces/projects/av-control-configurator/outcomes/OUT-CFG-001-web-configurator/specifications.md` — сценарии OpenSpec, перенесённые в Outcome.
- `workspaces/projects/av-control-configurator/outcomes/OUT-CFG-001-web-configurator/openspec-traceability.md` — трассировка change на Pack.
