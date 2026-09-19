# QSRE adapter

QSRE (`Quality, Security and Release Engineering`) — независимая функция проверки. `QSRE Engineer` — выполняющая её роль человека, а `QSRE Environment` — будущая специализированная среда поддержки или автоматизации этой функции. Сейчас адаптер фиксирует независимый feedback loop обратно в PDE независимо от наличия отдельной среды.

## Input

Pack SHA, implementation SHA, Evidence Bundle, release plan, residual risk и compatibility scope.

## Output

`templates/qsre-feedback.md` с типом `clarification`, `definition-change`, `defect` или `governance-signal`.

## Activation

При создании `QSRE Environment` меняется `features.qsre_adapter.mode`. Автоматический feedback не изменяет Pack: PDE классифицирует сигнал и создаёт Definition Change или отдельный governance RFC.
