# Product Definition Pack DEMO-001

## Control

- Outcome ID: `OUT-DEMO-001`
- Pack type: `full`
- Version: `1.1.0`
- Status: `done`
- Risk / autonomy: `R2 / A2`
- Redmine: `RM-DEMO-101`
- Outcome Owner: Demo Product Owner
- PDE Owner: Demo PDE
- Risk Owner: Demo Operations Owner

## Signal and problem evidence

Операторы демонстрационного бизнес-центра замечают потерю связи с контроллерами в среднем через 14 минут после факта. Это увеличивает время деградированной работы автоматизации. Источник — синтетическая выборка support tickets за 30 дней.

## Outcome and metric contract

Сократить p95 времени обнаружения потери связи до 120 секунд. Baseline: 14 минут, synthetic support dataset. Validation window: 14 дней пилота на одной тестовой площадке. Решение `keep`, если p95 не выше 120 секунд и false-positive rate ниже 2%.

## Scope

In scope: heartbeat monitoring, offline alert, восстановление статуса и audit entry.  
Out of scope: автоматическое управление оборудованием, уведомления конечным жильцам и изменение firmware.

## Acceptance criteria

- `AC-001`: система создаёт offline alert не позднее 90 секунд после пропуска допустимого heartbeat window.
- `AC-002`: после восстановления связи alert закрывается, а время offline/online сохраняется в audit log.

## Non-functional requirements

- `NFR-001`: false-positive rate на пилотной площадке ниже 2% за 14 дней.
- `NFR-002`: обработка heartbeat не увеличивает среднюю загрузку контроллера более чем на 3%.

## Risks

R2: ложные alerts влияют на операторов и могут скрыть реальные инциденты. Автоматическое воздействие на физические системы отсутствует.

## Delivery slices

1. Сбор heartbeat и наблюдаемая диагностика.
2. Создание/закрытие alert и audit log.
3. Ограниченный rollout и измерение качества.

## Release rollout rollback

Пилот на одной тестовой площадке. Stop condition: false-positive rate >= 5% за 24 часа. Rollback: выключить обработчик alerts, сохранив сырые heartbeat events.

## Change history

- `1.0.0`: Ready baseline с порогом 60 секунд.
- `1.1.0`: `DC-001` изменил порог на 90 секунд после проверки нестабильных сетевых сегментов.
