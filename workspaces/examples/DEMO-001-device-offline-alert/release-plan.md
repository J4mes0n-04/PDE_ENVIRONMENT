# Release plan DEMO-001

- Pack: `1.1.0`
- Risk: `R2`
- Release Owner: Demo Release Owner

## Rollout

Одна тестовая площадка, 10% контроллеров на 24 часа, затем 100% площадки при false-positive rate ниже 2%.

## Stop and rollback

Остановить rollout при false-positive rate >= 5%, потере audit events или росте controller load > 3%. Rollback выключает alert processor и не удаляет heartbeat data.
