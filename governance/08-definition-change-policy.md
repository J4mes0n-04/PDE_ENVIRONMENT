# Политика Definition Change

Document ID: PDE-GOV-008  
Type: Policy  
Status: Draft  
Version: 0.1.0

## Материальное изменение

Definition Change обязателен, если меняется Outcome, scope, AC, NFR, risk, пользовательский flow, данные, совместимость, rollout, rollback или способ измерения.

Не является материальным исправление опечатки, ссылки или пояснение, не меняющее проверяемое поведение.

## Процесс

1. Создать запись по `templates/definition-change.md`.
2. Зафиксировать причину, альтернативы и влияние на активные Slice/PR/Evidence.
3. Определить, требуется ли остановка работы.
4. Получить решение Outcome Owner и затронутых владельцев риска.
5. Обновить `pack.md`, `pack.json`, версию и Redmine link.
6. Перепроверить Ready gate и устаревшее evidence.

Сообщение в чате не изменяет baseline.
