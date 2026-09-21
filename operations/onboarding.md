# Onboarding PDE

## Первый час

1. Прочитать root README и `AGENTS.md`.
2. Прочитать PDE charter, glossary, risk и lifecycle.
3. Запустить `pwsh ./scripts/doctor.ps1`.
4. Открыть демонстрационный Outcome и сопоставить `pack.md` с `pack.json`.
5. Запустить проверки Pack и Evidence.
6. Для нового Outcome из входных документов просмотреть `integrations/openspec/README.md` и эталон `fixtures/sample-project`.

## Первый день

1. Получить доступ к GitHub и Redmine.
2. Найти Outcome в Redmine и перейти на конкретный Pack commit.
3. Определить свою роль и границы решений.
4. Пройти один Ready Review как наблюдатель.
5. Создать учебный Outcome только в личной ветке или `workspaces/examples/`.

## Проверка onboarding

Участник может объяснить источники истины, различие Output/Outcome, риск/автономию, Definition Change и назначение ASE/QSRE handoff.

## Windows и UTF-8

Все файлы репозитория используют UTF-8. Если внешний Python-валидатор читает русскоязычный `SKILL.md` через системную `cp1251`, запускайте его как `python -X utf8 <validator> <skill-folder>` или задайте `PYTHONUTF8=1` на время процесса.
