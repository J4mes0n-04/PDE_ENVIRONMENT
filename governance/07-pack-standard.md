# Стандарт Product Definition Pack

Document ID: PDE-GOV-007  
Type: Standard  
Status: Draft  
Version: 0.1.0

## Два представления

Каждый Outcome обязан иметь:

- `pack.md` — полное человекочитаемое определение;
- `pack.json` — контрольная машиночитаемая запись, соответствующая `schemas/pack.schema.json`.

При расхождении Pack не проходит Ready Review. `pack.json` не заменяет объяснения в `pack.md`.

## Обязательные элементы

- уникальный `outcome_id`, статус, версия и risk level;
- проблема, пользователи и evidence проблемы;
- измеримый Outcome, baseline, target и validation window;
- in scope и out of scope;
- сценарии и edge cases;
- AC и NFR со стабильными идентификаторами;
- зависимости, предположения и открытые вопросы;
- rollout, rollback и telemetry plan;
- owners и ссылки на Redmine;
- журнал изменений baseline.

## Mini и Full

Mini Pack допустим для R0–R1, если изменение обратимо и не затрагивает безопасность, данные или совместимость. Full Pack обязателен для R2–R3.

## Версия

До Ready используется `0.x`. Утверждённый baseline получает `1.0.0`. Материальное изменение после Ready увеличивает minor или major через Definition Change. Редакционное изменение увеличивает patch.
