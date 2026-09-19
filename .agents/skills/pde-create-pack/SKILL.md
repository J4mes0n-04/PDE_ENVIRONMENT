---
name: pde-create-pack
description: Создаёт или существенно обновляет Product Definition Pack для PDE Outcome. Использовать, когда нужно превратить подтверждённый сигнал или проблему в проверяемые pack.md и pack.json; не использовать для реализации кода или косметической правки готового Pack.
---

# Create Product Definition Pack

## Required context

Прочитайте `governance/07-pack-standard.md`, `05-risk-model.md`, `14-outcome-measurement.md` и подходящий шаблон Pack.

## Workflow

1. Установите Signal, пользователя, проблему и evidence проблемы. Не превращайте предположение в факт.
2. Сформулируйте измеримый Outcome, baseline, target, источник, validation window и decision rule.
3. Определите in/out scope, сценарии, ошибки и recovery behavior.
4. Назначьте R0–R3 независимо от уровня автономии A0–A3.
5. Запишите проверяемые `AC-###` и `NFR-###`; каждому назначьте ожидаемый вид evidence.
6. Опишите зависимости, открытые вопросы, rollout, stop conditions и rollback.
7. Создайте согласованные `pack.md` и `pack.json` в Outcome folder.
8. Запустите `pwsh ./scripts/validate-pack.ps1 -Path <outcome-folder>`.

## Output

Черновик Pack с явными unknowns. До Ready Review используйте `pack_status: draft` или `in-review`; не переводите `outcome_state` в `ready` и `pack_status` в `baseline` без решения владельцев.
