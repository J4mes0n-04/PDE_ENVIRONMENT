# Стандарт Evidence Bundle

Document ID: PDE-GOV-010  
Type: Standard  
Status: Draft  
Version: 0.1.0

## Требования к evidence

Каждое доказательство содержит:

- `evidence_id`;
- связанный `AC-*` или `NFR-*`;
- метод проверки;
- результат и статус `pass`, `fail`, `partial` или `not-run`;
- источник или immutable link;
- время и среду выполнения;
- автора или автоматическую систему;
- известные ограничения.

## Состав Bundle

В зависимости от риска включаются functional tests, compatibility, security, performance, migration, observability, rollout rehearsal, rollback rehearsal и независимый review.

## Недопустимое evidence

- утверждение «проверено» без результата;
- ссылка на изменяемую страницу без snapshot или периода;
- зелёный общий pipeline без связи с AC/NFR;
- скриншот без контекста, времени и источника;
- evidence, полученное до изменения baseline и не подтверждённое повторно.

Bundle индексируется в `evidence.md`; большие artifacts остаются в CI или утверждённом хранилище.
