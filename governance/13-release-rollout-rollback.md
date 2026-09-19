# Политика release, rollout и rollback

Document ID: PDE-GOV-013  
Type: Policy  
Status: Draft  
Version: 0.1.0

## Release decision

Перед выпуском доступны утверждённый Pack, Evidence Bundle, известный остаточный риск, владелец наблюдения и проверяемый rollback.

## Rollout

- R1 может выпускаться обычным управляемым способом при наличии наблюдения.
- R2 требует staged rollout по сегменту, площадке, версии или feature flag.
- R3 требует ограниченного blast radius, явного go/no-go и дежурного владельца.

Unleash применяется только при `features.unleash.enabled: true`. Отсутствие Unleash не отменяет требование контролируемого rollout; используется существующий механизм продукта.

## Rollback

План указывает trigger, полномочия, действия, время восстановления и влияние на данные/устройства. Для необратимых миграций применяется roll-forward или restore plan и риск автоматически не ниже R2.

Release не переводит Outcome в Done.
