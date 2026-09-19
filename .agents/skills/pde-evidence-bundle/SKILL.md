---
name: pde-evidence-bundle
description: Собирает и проверяет Evidence Bundle, связывая результаты реализации с AC/NFR конкретной версии Pack. Использовать перед review, release и при обновлении доказательств; не использовать для генерации неподтверждённых заявлений о готовности.
---

# Evidence Bundle

## Required context

Прочитайте `governance/10-evidence-standard.md`, Pack и artifacts реализации.

## Workflow

1. Зафиксируйте Pack version и immutable commit SHA.
2. Извлеките все AC/NFR identifiers.
3. Для каждого identifier найдите реальный результат, а не только план теста.
4. Запишите method, result, link, environment/time и limitation.
5. Отдельно перечислите `fail`, `partial`, `not-run` и отсутствующее evidence.
6. Проверьте, не устарело ли evidence после Definition Change.
7. Для R2–R3 запросите независимый review и residual risk.
8. Запустите `pwsh ./scripts/validate-evidence.ps1 -Path <outcome-folder>`.

## Boundary

Не создавайте фиктивные ссылки и не считайте общий зелёный pipeline доказательством всех требований.
