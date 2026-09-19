# OpenSpace local integration

## Роль

OpenSpace находится между Cursor/Codex и библиотекой `.agents/skills`. Он предоставляет локальный поиск skills, execution quality records и предложения `FIX`, `DERIVED`, `CAPTURED`. Git остаётся источником истины, а governance меняется только через Pull Request.

## Подготовленная конфигурация

`.codex/config.toml` содержит MCP server `openspace` в состоянии `enabled = false`. Облачный режим и cloud telemetry жёстко выключены. Автоматические evolution triggers также выключены для первого shadow pilot.

Проверенная исходная база при подготовке пакета: OpenSpace `2.0.0`, commit `38277815ed44a53d757973c2bc4454c3b6426698`, Python `>=3.12`. При будущем развёртывании версию нужно повторно проверить и зафиксировать отдельным PR.

## Развёртывание по отдельной команде владельца

1. Установить Python 3.12+.
2. Получить проверенную копию OpenSpace в отдельный каталог инструментов, не внутрь `workspaces/`.
3. Зафиксировать commit и выполнить `python -m pip install -e .` из каталога OpenSpace.
4. Проверить `openspace-mcp --help`.
5. Выбрать локальную LLM-конфигурацию или разрешённый provider key через environment; ключ не сохранять в Git.
6. Проверить значения из `openspace.env.example`.
7. Выполнить security review host skills и доступных MCP tools.
8. Изменить `mcp_servers.openspace.enabled` на `true` и `features.openspace_local.enabled` на `true` одним Pull Request.
9. Перезапустить Codex и убедиться через `/mcp`, что server доступен.
10. Запустить shadow pilot: search и quality records без автоматического изменения skills.

## Запрещено

- включать `OPENSPACE_CLOUD_MODE=live`;
- добавлять cloud API key;
- использовать upload/download cloud tools;
- разрешать автоматический merge evolved skills;
- передавать restricted data в traces;
- считать локальный trust status нормативным approval.

## Откат

Установить `enabled = false`, завершить процесс MCP и сохранить локальные quality records для аудита. PDE продолжает работать с `.agents/skills` напрямую.
