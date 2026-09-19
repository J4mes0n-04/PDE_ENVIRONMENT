# Рабочие пространства

Это единственная область репозитория для конкретных продуктовых проектов и Outcomes.

Граница односторонняя: платформа влияет на `workspaces/`, работа в `workspaces/` не изменяет платформу. Файлы среды из `governance/`, `architecture/`, `templates/`, `schemas/`, `scripts/`, `integrations/`, `.agents/` и соседних каталогов сюда не копируются как нормативный оригинал; шаблоны копируются в каталог Outcome. Создание и генерация проекта не имеют права менять файлы вне `workspaces/`. Реальная работа размещается только в `workspaces/projects/<project-id>/`.

## Каталоги

- `projects/` — реальная работа команды.
- `examples/` — демонстрационные данные, которые нельзя использовать как production evidence.

## Рекомендуемая структура проекта

```text
workspaces/projects/<project-id>/
|-- README.md
|-- project-context.md
`-- outcomes/<outcome-id>/
    |-- pack.md
    |-- pack.json
    |-- decisions.md
    |-- definition-changes/
    |-- evidence.md
    |-- release-plan.md
    |-- outcome-check.md
    `-- handoffs/
```

Каждый проект определяет собственный продуктовый контекст, но наследует governance корня.
