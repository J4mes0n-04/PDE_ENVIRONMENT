# Definition Change DC-001

- Outcome ID: `OUT-DEMO-001`
- Current / proposed Pack: `1.0.0 / 1.1.0`
- Status: `approved`
- Decision owner: Demo Product Owner

## Trigger

Синтетический network replay показал, что окно 60 секунд создаёт 4,8% ложных alerts в нестабильном сегменте.

## Change

`AC-001` изменён с 60 до 90 секунд. Product target p95 <= 120 секунд не изменился.

## Impact and decision

Нужно повторить alert timing и false-positive evidence; реализация ещё не выпущена. Risk остаётся R2. Изменение одобрено для снижения alert noise без ухудшения Outcome threshold.
