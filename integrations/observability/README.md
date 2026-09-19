# OpenTelemetry and Grafana integration

Состояние по умолчанию: выключено.

Observability включается после появления metric contract и владельца данных. OpenTelemetry стандартизирует сигналы, Grafana визуализирует их; ни один инструмент сам по себе не определяет Outcome.

## Условия включения

- описаны события, metrics/traces/logs и допустимые данные;
- утверждены retention и access control;
- OTLP endpoint и credentials хранятся вне Git;
- dashboards имеют owner, источник, период и decision use;
- проверены потеря telemetry и отсутствие collector;
- Outcome Check может воспроизвести вычисление baseline/actual.

Не отправляйте персональные, секретные или чувствительные данные устройств без отдельного требования и review.
