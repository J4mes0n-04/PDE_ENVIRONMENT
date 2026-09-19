# QSRE adapter

QSRE — будущая среда Quality, Security and Release Engineering. Сейчас адаптер фиксирует независимый feedback loop обратно в PDE.

## Input

Pack SHA, implementation SHA, Evidence Bundle, release plan, residual risk и compatibility scope.

## Output

`templates/qsre-feedback.md` с типом `clarification`, `definition-change`, `defect` или `governance-signal`.

## Activation

При создании QSRE среды меняется `features.qsre_adapter.mode`. Автоматический feedback не изменяет Pack: PDE классифицирует сигнал и создаёт Definition Change или отдельный governance RFC.
