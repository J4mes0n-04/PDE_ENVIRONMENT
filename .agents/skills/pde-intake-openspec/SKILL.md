---
name: pde-intake-openspec
description: Разбирает бизнес-требования через OpenSpec до создания PDE Outcome. Использовать, когда появились входные документы и ещё нет утверждённого Pack; не использовать для реализации кода, archive или правки уже готового baseline.
---

# OpenSpec intake before Outcome

## Required context

Прочитайте `integrations/openspec/README.md`, `integrations/openspec/pack-mapping.yaml`, `governance/07-pack-standard.md` и `.cursor/rules/05-outcome-intake.mdc`.

Если `config/features.yaml` содержит `openspec_intake.enabled: false`, остановитесь и следуйте обычному `pde-create-pack` без OpenSpec-файлов.

## When to use

Пользователь положил бизнес-требования в `workspaces/projects/<project-id>/` и просит сформировать Outcome или Pack.

## Workflow

1. Найдите проект в `workspaces/projects/<project-id>/`. Не создавайте `openspec/` в корне репозитория и не запускайте `openspec init` без `--tools none`.
2. Если нет `openspec/config.yaml`, выполните `pwsh ./scripts/init-openspec-project.ps1 -ProjectId <project-id>`.
3. Изучите входные документы. Составьте только недостающие вопросы. Не повторяйте факты из документов.
4. Запишите разбор в `openspec/changes/<change-id>/explore.md` по шаблону `templates/openspec-change/explore.md`.
5. Пока есть blocking-вопросы, **не создавайте** `outcomes/<outcome-id>/pack.md`. Задайте вопросы пользователю.
6. После ответов или явного разрешения на черновик создайте **один** change:
   - `proposal.md`
   - `design.md`
   - `tasks.md`
   - `specs/<domain>/spec.md` с `## ADDED Requirements` и заголовками `### Requirement: AC-001 ...` / `### Requirement: NFR-001 ...`
7. Человекочитаемый текст — на русском. Структурные заголовки OpenSpec (`ADDED Requirements`, `Requirement`, `Scenario`, SHALL) оставьте английскими.
8. Запустите `pwsh ./scripts/validate-openspec-change.ps1 -ProjectPath workspaces/projects/<project-id> -ChangeName <change-id>`.
9. Сообщите change-id и список AC/NFR. Pack создаёт только skill `pde-create-pack` после подтверждения change.

## Forbidden

- `openspec init` в корне PDE или с `--tools cursor|all`
- `/opsx:apply`, генерация кода продукта, `openspec archive`
- `pack.md` / `pack.json` внутри `openspec/`
- несколько Outcomes из одного change без явного решения владельца
