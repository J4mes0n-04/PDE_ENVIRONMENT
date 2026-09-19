---
name: pde-definition-change
description: Классифицирует новый факт после baseline и оформляет материальное изменение Product Definition Pack. Использовать при изменении Outcome, scope, AC/NFR, риска, данных, совместимости, rollout или измерения; не использовать для опечаток без изменения смысла.
---

# Definition Change

## Required context

Прочитайте `governance/08-definition-change-policy.md` и действующую версию Pack.

## Workflow

1. Зафиксируйте новый факт и его evidence.
2. Определите, является ли изменение материальным. При сомнении перечислите оба толкования и запросите решение PDE/Outcome Owner.
3. Создайте запись из `templates/definition-change.md`.
4. Проведите impact analysis для Slice, PR, evidence, риска, release и метрик.
5. Отметьте, какая работа должна остановиться и какое evidence устарело.
6. После approval обновите `pack.md`, `pack.json`, версию и change history.
7. Повторите Pack validation и Ready Review в требуемом объёме.

## Boundary

Не изменяйте baseline только по сообщению в чате или автоматически по сигналу OpenSpace/QSRE.
