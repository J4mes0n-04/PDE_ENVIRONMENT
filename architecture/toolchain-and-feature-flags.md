# Инструменты и отключаемые возможности

## Обязательное ядро

GitHub, GitHub Actions и Redmine образуют минимальный рабочий контур. Cursor и Codex являются взаимозаменяемыми агентными интерфейсами: процесс не должен зависеть от наличия обоих одновременно.

## OpenSpace

OpenSpace подключается локально через MCP. Он читает `.agents/skills`, создаёт локальные quality records и предложения эволюции. Облачные функции и телеметрия выключены. Источником истины для принятой версии skill остаётся Git.

## OpenSpec

OpenSpec — опциональный intake перед Outcome. CLI и репозиторий инструмента живут вне `workspaces/`. Рабочие change-файлы создаются только в `workspaces/projects/<project-id>/openspec/`. Pack остаётся единственным источником истины для gates. Телеметрия OpenSpec выключена. Реализация кода через `/opsx:apply` в PDE запрещена.

## Unleash

Unleash не требуется для запуска среды. Он включается, когда команда действительно использует feature flags для контролируемого rollout и rollback. До этого release plan описывает доступный механизм управления выпуском.

## OpenTelemetry и Grafana

Они включаются после определения metric contract и источников данных. До включения Pack может ссылаться на существующую telemetry/support систему. Наличие dashboard без baseline и decision rule не считается Outcome Measurement.

## Управление состоянием

`config/features.yaml` — декларация выбранных возможностей. Для перевода `enabled` в `true` требуются:

- владелец интеграции;
- проверенная конфигурация;
- описание данных и прав;
- rollback интеграции;
- обновлённый `operations/activation-runbook.md`;
- Pull Request и approval.
