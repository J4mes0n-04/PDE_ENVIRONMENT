# Управление нормативными документами

Document ID: PDE-GOV-015  
Type: Policy  
Status: Draft  
Version: 0.1.0

## Жизненный цикл

`Draft -> In Review -> Active -> Superseded -> Archived`

Утверждённая версия неизменна как исторический baseline. Обновление создаёт новую версию через Pull Request; предыдущая версия сохраняется в Git history и помечается superseded в каталоге.

## Обязательные метаданные

Document ID, type, status, version, owner, approver, область действия, дата вступления, review cycle и история изменений.

## Триггеры пересмотра

- плановая дата review;
- инцидент или escaped defect;
- повторяющийся waiver;
- изменение законодательства, архитектуры или инструментов;
- сигнал QSRE;
- устойчивый негативный quality record skill;
- появление новой среды ASE/QSRE.

## Изменение

Issue/RFC -> impact analysis -> Pull Request -> owner review -> approver decision -> effective date -> синхронизация templates/rules/skills/CI -> коммуникация.

OpenSpace может создать сигнал или черновик, но не переводит документ в Active и не выполняет merge.
