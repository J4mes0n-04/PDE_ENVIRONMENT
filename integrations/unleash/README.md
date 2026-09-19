# Unleash integration

Состояние по умолчанию: выключено.

Unleash включается, когда продукт поддерживает feature flags и команде нужен управляемый staged rollout. До включения используются существующие механизмы выпуска.

## Условия включения

- определены instance URL, project/environment и владельцы;
- token хранится в secret store;
- naming convention связывает flag с Outcome/Slice;
- есть правила создания, expiry и удаления flags;
- release plan содержит variants, stop conditions и rollback;
- проверена недоступность Unleash и безопасное default behavior.

Feature flag не заменяет authorization, validation или Definition Change.
