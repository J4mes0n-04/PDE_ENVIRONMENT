---
name: pde-ready-review
description: Проверяет готовность PDE Pack к передаче в реализацию и формирует решение Ready, conditional или not-ready. Использовать перед gate Ready и повторно после материального Definition Change; не использовать как общий code review.
---

# Ready Review

## Required context

Прочитайте `governance/09-lifecycle-and-gates.md`, `07-pack-standard.md`, `05-risk-model.md` и рассматриваемый Pack.

## Checks

- проблема подтверждена evidence и отделена от предположений;
- Outcome измерим, baseline и target определены;
- scope и non-goals исключают скрытое расширение;
- AC/NFR однозначны, проверяемы и имеют identifiers;
- риск обоснован, владельцы назначены;
- открытые вопросы имеют owner и blocking status;
- rollout/rollback соответствуют риску;
- `pack.md` и `pack.json` согласованы;
- ASE handoff можно сформировать без продуктовых догадок.

## Decision

Верните одно решение:

- `ready` — блокирующих пробелов нет;
- `conditional` — перечислите условия и запретите Committed до их закрытия;
- `not-ready` — перечислите конкретные gaps, identifiers и владельцев.

Не исправляйте смысл Pack без согласования Outcome Owner.
