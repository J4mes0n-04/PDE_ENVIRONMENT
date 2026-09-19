# Контракт интерфейсов ASE и QSRE

Document ID: PDE-GOV-019  
Type: Standard  
Status: Draft  
Version: 0.1.0

## PDE -> ASE

Передача содержит immutable Pack link, risk/autonomy, приоритетные Slice, AC/NFR, открытые ограничения, decision log, telemetry и rollback expectations. ASE подтверждает принятие либо возвращает конкретные вопросы.

## ASE -> QSRE

Передача содержит реализацию, PR/commit, карту AC/NFR к tests/evidence, известные ограничения, release plan и residual risk.

## QSRE -> PDE

Обратная связь содержит тип `clarification`, `definition-change`, `defect` или `governance-signal`, затронутые identifiers, evidence, severity и требуемое решение.

## Совместимость во времени

Контракты версионируются. Добавление необязательного поля совместимо; удаление или изменение смысла поля требует новой major-версии. Пока отдельные среды не существуют, эти же файлы используют люди, выполняющие соответствующие функции.

Шаблоны: `templates/ase-handoff.md` и `templates/qsre-feedback.md`.
