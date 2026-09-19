# Evidence Bundle DEMO-001

- Pack version: `1.1.0`
- Risk: `R2`
- Status: `complete-demo`
- Внимание: результаты синтетические и предназначены только для примера.

## Evidence index

| Evidence ID | Requirement | Method | Result | Link | Environment | Limitations |
|---|---|---|---|---|---|---|
| EVD-001 | AC-001 | deterministic clock test | pass | `demo://ci/alert-timing` | simulated controller | not production hardware |
| EVD-002 | AC-002 | integration test | pass | `demo://ci/recovery-audit` | test event store | single protocol |
| EVD-003 | NFR-001 | 14-day event replay | pass, 1.4% | `demo://report/false-positive` | synthetic site | synthetic traffic |
| EVD-004 | NFR-002 | load profile | pass, +1.8% | `demo://report/controller-load` | lab controller | one model |

## Coverage gaps

Production device diversity не проверена и остаётся условием перед масштабированием.

## Independent review

Demo QSRE Function Owner: evidence достаточно для демонстрационного pilot release, но не для реального production.
