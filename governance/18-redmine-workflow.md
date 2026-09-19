# Стандарт Redmine workflow

Document ID: PDE-GOV-018  
Type: Standard  
Status: Draft  
Version: 0.1.0

## Trackers

- `Outcome` — единица проверяемой ценности.
- `Delivery Slice` — сквозной срез реализации.
- `Definition Change` — изменение baseline.
- `Risk or Blocker` — препятствие или новый риск.
- `Service` — ограниченная полоса поддержки.

## Обязательные поля Outcome

Outcome ID, owner, state, risk level, autonomy level, Pack URL, Pack version/SHA, baseline, target, validation window и next gate.

## Правила

- Redmine не хранит полный Pack.
- Статус меняется только после соответствующего gate.
- Blocked содержит владельца и следующее действие.
- WIP-limit по умолчанию: не более двух активных продуктовых Outcomes и одной service lane.
- PR и commit содержат Redmine ID; Redmine содержит ссылки на PR/Evidence.

Конкретное сопоставление полей хранится в `integrations/redmine/field-mapping.yaml`.
