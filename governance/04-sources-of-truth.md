# Источники истины

Document ID: PDE-GOV-004  
Type: Policy  
Status: Draft  
Version: 0.1.0

## Распределение

- Git: governance, Pack, decisions, templates, skills, Evidence index и Outcome Check.
- Redmine: приоритет, статус, assignee, сроки, blockers и ссылки на Git.
- Product repository: код, тесты, Pull Request и технические artifacts.
- CI: факт выполнения автоматических проверок.
- Telemetry/support system: фактические сигналы до и после release.
- OpenSpace local store: quality records и lineage skills; не нормативная версия.

## Запрет дублирования

Полный Pack нельзя независимо редактировать в Redmine, wiki или чате. Эти системы содержат ссылку на commit SHA. При расхождении действует утверждённая версия в Git.

## Стабильные ссылки

Для gates и Evidence используются ссылки на commit, tag, immutable artifact или неизменяемый snapshot. Ссылка только на moving branch недостаточна для аудита.
