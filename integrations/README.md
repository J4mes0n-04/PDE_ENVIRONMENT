# Интеграции PDE

Каждая интеграция изолирована и имеет собственную инструкцию. Обязательность и фактическое состояние задаются в `config/features.yaml`.

- `github/` — repository settings, branch protection и Actions.
- `redmine/` — поток и mapping полей.
- `openspace/` — локальное управление skills через MCP.
- `ase/` — будущая среда реализации.
- `qsre/` — будущая среда качества, безопасности и выпуска.
- `unleash/` — опциональное управление rollout.
- `observability/` — опциональные OpenTelemetry и Grafana.

Интеграция считается включённой только после проверки, назначения владельца и Pull Request, меняющего feature flag.
