# Дорожная карта внедрения

## Stage 0 Governance baseline

Назначить роли, утвердить минимальные нормы, настроить GitHub/Redmine и выбрать один R1–R2 Outcome.

## Stage 1 Core pilot

Провести один Outcome без Unleash, OpenTelemetry/Grafana и обязательного OpenSpace. Использовать Pack, gates, Evidence и Outcome Check.

## Stage 2 OpenSpace shadow

Развернуть локальный OpenSpace, индексировать пять skills, включить quality records. Evolution triggers оставить выключенными; изменения skills — только через Pull Request.

## Stage 3 Second stream

Добавить второй Outcome, проверить WIP, адаптеры ASE/QSRE и совместимость. Удалить поля и rituals, не влияющие на решение.

## Stage 4 Optional controls

При реальной необходимости включить Unleash и observability. Подключать отдельные ASE/QSRE среды без изменения смысловых контрактов.

## Scale decision

Масштабировать только при улучшении flow/acceptance без ухудшения defects, безопасности и результата Outcome.

## Stage parallel stabilization

До удаления локальных дубликатов governance провести период параллельной работы по [parallel-stabilization-period.md](parallel-stabilization-period.md). План будущего удаления — только в [governance-duplicate-removal-plan.md](../architecture/governance-duplicate-removal-plan.md); execution PR не открывать до выхода из периода.
