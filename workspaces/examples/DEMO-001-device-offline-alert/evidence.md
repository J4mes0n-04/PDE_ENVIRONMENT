# Evidence Bundle DEMO-001

- Outcome ID: `OUT-DEMO-001`
- Pack version: `1.1.0`
- Pack commit SHA: `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`
- Risk: `R2`
- Evidence owner: Demo QA Owner
- Status: `complete`
- Внимание: результаты синтетические и предназначены только для примера.

## Evidence index

| Evidence ID | Requirement | Method | Result | Immutable link | Environment | Executed at | Producer | Limitations |
|---|---|---|---|---|---|---|---|---|
| EVD-001 | AC-001 | deterministic clock test | pass | `demo://ci/run-20260919/alert-timing` | simulated controller | 2026-09-19T10:00:00Z | Demo CI | not production hardware |
| EVD-002 | AC-002 | integration test | pass | `demo://ci/run-20260919/recovery-audit` | test event store | 2026-09-19T10:05:00Z | Demo CI | single protocol |
| EVD-003 | NFR-001 | 14-day event replay | pass, 1.4% | `demo://report/run-20260919/false-positive` | synthetic site | 2026-09-19T10:10:00Z | Demo Analytics | synthetic traffic |
| EVD-004 | NFR-002 | load profile | pass, +1.8% | `demo://report/run-20260919/controller-load` | lab controller | 2026-09-19T10:15:00Z | Demo Performance Lab | one controller model |

## Coverage gaps

Все AC/NFR имеют passing evidence. Production device diversity не проверена и остаётся ограничением перед масштабированием.

## Independent review

- Reviewer: Demo QSRE Function Owner
- Scope: AC-001, AC-002, NFR-001, NFR-002 и ограничения демонстрационного pilot release
- Decision: accepted for demo pilot only
- Residual risk: разнообразие production-устройств и протоколов не проверено; реальный production release запрещён
