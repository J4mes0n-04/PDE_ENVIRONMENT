# Redmine integration

Redmine управляет потоком, но не является нормативным хранилищем требований. Полный Pack находится в Git; карточка хранит ссылку на commit SHA.

## Настройка

1. Создать trackers из `governance/18-redmine-workflow.md`.
2. Создать custom fields из `field-mapping.yaml`.
3. Настроить workflow states и разрешённые transitions.
4. Добавить ссылку на GitHub repository и шаблон `templates/redmine-outcome.md`.
5. Сначала использовать ручные ссылки. API automation добавлять только после устойчивого пилота и с service account минимальных прав.

## Не хранить

Не копировать полный Pack, Evidence Bundle или secrets во вложения/описание Redmine. Для аудита указывать immutable Git/CI links.
