# Changelog

Все существенные изменения этого пакета фиксируются здесь.

## 0.1.0-draft

- Создан самостоятельный каркас PDE-среды.
- Добавлены нормативные документы, шаблоны и контракты PDE–ASE–QSRE.
- Добавлены пять PDE skills, Cursor rules и Codex configuration.
- Добавлены облегчённая JSON Schema Pack и четыре workflow GitHub Actions.
- OpenSpace подготовлен как выключенная локальная интеграция без облачного обмена.
- OpenSpec подготовлен как локальный intake перед Outcome: CLI вне `workspaces/`, рабочие файлы только в проекте, телеметрия выключена.
- Unleash, OpenTelemetry и Grafana подготовлены как выключенные опциональные интеграции.
- Демонстрационный Outcome изолирован в `workspaces/examples/`.
- Зафиксирован внешний каркас ASE: https://github.com/J4mes0n-04/ase-environment.git. QSRE как отдельная среда ещё не создана.
- Добавлены ручные межрепозиторные уведомления `notify-ase-ready` и `listen-qsre-feedback`: создаётся Issue, Pack и Pull Request не изменяются.
- Зафиксирован внешний каркас QSRE: https://github.com/J4mes0n-04/qsre-environment.git.
- Добавлены период параллельной работы и отдельный план удаления дубликатов governance без удаления файлов из PDE.
