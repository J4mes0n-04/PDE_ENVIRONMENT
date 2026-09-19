# Рабочие пространства

Это единственная область репозитория для конкретных продуктовых проектов и Outcomes. Файлы среды из `governance`, `templates`, `integrations` и `.agents` сюда не копируются.

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
