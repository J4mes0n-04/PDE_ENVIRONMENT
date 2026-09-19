# Runbook включения интеграций

## Универсальная процедура

1. Создать integration issue с владельцем и бизнес-причиной.
2. Описать данные, permissions, failure modes и rollback.
3. Подготовить secrets вне Git.
4. Проверить конфигурацию в изолированной среде.
5. Обновить integration README и `config/features.yaml`.
6. Получить approvals Engineering/Security/PDE владельцев.
7. Включить на ограниченной области и собрать evidence.
8. При отрицательном результате вернуть flag в `false` и остановить connector.

## OpenSpace

Первый режим только `pilot-shadow`: local search и records. Cloud и auto-evolution запрещены.

## Unleash

Включать вместе с первым реальным staged rollout, а не для демонстрации инструмента.

## Observability

Включать после metric contract. Начать с минимального набора signals и проверяемого dashboard.
