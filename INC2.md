# Развёртывание готовой системы PDE, ASE и QSRE в новом месте

## 1. Назначение инструкции

Эта инструкция предназначена для установки уже созданной и выпущенной системы в другой GitHub organization, на другом компьютере или в другом внутреннем контуре.

Она предполагает, что существуют стабильные releases следующих репозиториев:

- `engineering-control`;
- `pde-environment`;
- `ase-environment`;
- `qsre-environment`.

Если ASE/QSRE ещё не выпущены, а `engineering-control` остаётся `staging`, используйте `INC1.md`: текущая система ещё создаётся, а не переносится как готовая production-платформа.

## 2. Что переносится, а что создаётся заново

### Переносится из Git

- код и документация сред;
- утверждённые нормативные releases;
- schemas, templates, skills и rules;
- validators и GitHub Actions;
- adapter configuration без секретов;
- примеры и миграционные инструкции.

### Создаётся заново в новом контуре

- GitHub organization/repositories и доступы;
- teams, CODEOWNERS и branch rules;
- GitHub Apps, tokens, secrets и environments;
- Redmine project, custom fields и workflow;
- локальная конфигурация Cursor/Codex/OpenSpace;
- Unleash, OpenTelemetry и Grafana endpoints;
- рабочие проекты и Outcomes;
- backup, retention, incident и compliance settings.

Нельзя переносить секреты в Git или копировать чужие рабочие Outcomes как шаблон новой production-среды.

## 3. Подготовить паспорт установки

До начала заполните локально, не добавляя секреты в Git:

```text
GitHub organization:        <organization>
Control repository:         <organization>/engineering-control
PDE repository:             <organization>/pde-environment
ASE repository:             <organization>/ase-environment
QSRE repository:            <organization>/qsre-environment
Control release tag:        <vX.Y.Z>
Control full commit SHA:     <40-character-sha>
Environment release tags:   <versions>
Redmine base URL:            <url>
Redmine project key:         <key>
OpenSpace mode:              disabled | local-shadow
Unleash:                     disabled | enabled
OpenTelemetry:               disabled | enabled
Grafana:                     disabled | enabled
Data classification:        <classification>
Installation owner:         <person/team>
Rollback owner:             <person/team>
```

Используйте только releases, разрешённые владельцем системы. Не устанавливайте production из случайной ветки или последнего состояния `main`.

## 4. Предварительные требования

На рабочей машине:

- Git;
- PowerShell 7+ (`pwsh`);
- GitHub CLI (`gh`) — рекомендуется;
- доступ к GitHub organization;
- Cursor и/или Codex, если они входят в выбранный профиль;
- Python 3.12+, только если включается подготовленная версия OpenSpace;
- сетевой доступ к Redmine и другим явно включённым сервисам.

Проверка:

```powershell
git --version
pwsh --version
gh --version
gh auth status
```

## 5. Выбрать способ размещения

### Вариант A. Новый независимый контур

Создайте четыре новых репозитория из утверждённых release tags. Сохраните происхождение: исходный URL, tag и SHA.

### Вариант B. Использование центральных репозиториев

Клонируйте существующие репозитории, а локальные настройки держите вне Git. Этот вариант подходит, когда организация продолжает использовать центральную нормативную основу.

### Вариант C. Fork для сотрудников

Главные репозитории остаются защищёнными. Сотрудники работают через fork и Pull Request. Подробный порядок для PDE приведён в `integrations/github/README.md`.

Не создавайте несвязанную копию без записи происхождения: позже невозможно будет доказать версию норм и совместимость сред.

## 6. Создать репозитории GitHub

Рекомендуемый порядок:

1. `engineering-control`;
2. `pde-environment`;
3. `ase-environment`;
4. `qsre-environment`.

Для каждого репозитория:

1. импортировать содержимое утверждённого release;
2. сохранить исходный tag и SHA в migration/install manifest;
3. назначить `main` default branch;
4. запретить прямые изменения `main`;
5. настроить CODEOWNERS;
6. включить обязательные CI checks;
7. запретить branch deletion и force-push;
8. ограничить GitHub Actions permissions;
9. включить secret scanning/dependency controls, если они доступны;
10. проверить настройки тестовым Pull Request.

Пример клонирования центрального комплекта:

```powershell
git clone https://github.com/<organization>/engineering-control.git
git clone https://github.com/<organization>/pde-environment.git
git clone https://github.com/<organization>/ase-environment.git
git clone https://github.com/<organization>/qsre-environment.git
```

После клонирования переходите на утверждённый tag или созданную от него установочную ветку. Не начинайте настройку из неизвестного commit.

## 7. Проверить подлинность и совместимость releases

Для каждого репозитория:

```powershell
git fetch --tags
git tag --list
git rev-parse <release-tag>
git status --short --branch
```

Сравните полученный SHA с паспортом установки.

Для `engineering-control` выполните:

```powershell
pwsh ./scripts/validate-control.ps1
```

Проверьте `contracts/compatibility.yaml`:

- версии PDE → ASE совпадают по поддерживаемой major-версии;
- версии ASE → QSRE совместимы;
- версии QSRE → PDE совместимы;
- control release имеет статус, разрешённый для выбранного режима;
- production не использует `draft`/`staging`, если это отдельно не разрешённый пилот.

## 8. Зафиксировать зависимость каждой среды от control

В каждой среде укажите:

```yaml
control_repository: https://github.com/<organization>/engineering-control.git
control_tag: <vX.Y.Z>
control_commit: <full-40-character-sha>
contract_major: <supported-major>
```

Требования:

- tag и SHA задаются вместе;
- validator проверяет совпадение;
- обновление выполняется через Pull Request;
- major update требует миграционного плана;
- автоматическое обновление governance запрещено.

## 9. Выполнить базовую настройку PDE

В корне PDE:

```powershell
pwsh ./scripts/doctor.ps1
pwsh ./scripts/validate-repository.ps1
```

Настройте:

1. реальные GitHub users/teams в `.github/CODEOWNERS`;
2. владельцев и approvers в `governance/document-control.yaml` и соответствующих заголовках документов;
3. Redmine mapping;
4. feature flags в `config/features.yaml`;
5. разрешённый Cursor/Codex profile;
6. локальные пути без добавления абсолютных пользовательских путей в общие файлы;
7. каталог `workspaces/projects/` для новых рабочих проектов.

Запрещено помещать рабочие проекты в `workspaces/examples/` или в `engineering-control`.

## 10. Настроить Redmine

1. Создать проект Redmine.
2. Определить trackers, statuses, priorities и custom fields.
3. Настроить отображение lifecycle PDE ↔ Redmine.
4. Заменить `TBD` и `redmine.example.invalid` в mapping.
5. Назначить права ролям.
6. Создать тестовый Outcome.
7. Проверить хранение ссылки на Pack и конкретного commit SHA.

Полный Pack не копируется в Redmine. Redmine хранит состояние, приоритет и ссылку на неизменяемую версию в Git.

Токены Redmine храните в secret store или переменных среды, но не в репозитории.

## 11. Настроить ASE Environment

Проверьте, что ASE:

- получает PDE → ASE handoff установленной версии;
- валидирует Pack tag/SHA и contract payload;
- требует ACK до начала реализации;
- связывает delivery work с продуктовым репозиторием;
- создаёт карту AC/NFR → tests/evidence;
- формирует ASE → QSRE handoff;
- не меняет смысл Pack без Definition Change.

Запустите validators, перечисленные в README ASE, и отрицательный тест с невалидным handoff.

## 12. Настроить QSRE Environment

Проверьте, что QSRE:

- принимает ASE → QSRE handoff установленной версии;
- проверяет Pack SHA и implementation SHA;
- требует результаты по каждому обязательному AC/NFR;
- фиксирует environment, execution time и immutable evidence URLs;
- проверяет release и rollback;
- формирует QSRE → PDE feedback;
- не изменяет Pack и governance напрямую.

Запустите validators, перечисленные в README QSRE, и отрицательный тест с неполным Evidence Bundle.

## 13. Настроить Cursor и Codex

1. Откройте конкретный environment как отдельный workspace.
2. Прочитайте корневой `AGENTS.md`.
3. Проверьте `.cursor/rules/`, `.agents/skills/` и `.codex/config.toml`.
4. Убедитесь, что агент видит только нужный environment и разрешённые внешние пути.
5. Не помещайте токены в rules, skills или prompt-файлы.
6. Выполните тестовую задачу без изменения governance.
7. Проверьте `git diff` после теста.

Правила конкретной среды имеют силу только в её репозитории и не заменяют нормативную основу.

## 14. Опционально включить OpenSpace local

По умолчанию оставить выключенным:

```text
config/features.yaml: openspace_local.enabled = false
.codex/config.toml:   mcp_servers.openspace.enabled = false
```

Для включения:

1. установить проверенную версию OpenSpace в отдельный каталог инструментов;
2. проверить её commit и dependencies;
3. отключить cloud mode, cloud telemetry и automatic evolution triggers;
4. провести security review доступных MCP tools;
5. изменить оба флага на `true` одним Pull Request;
6. запустить repository validator;
7. перезапустить Codex/Cursor;
8. провести shadow test поиска skill и создания quality record;
9. подтвердить, что governance не изменяется автоматически.

OpenSpace может предложить улучшение skill. Результат становится частью среды только после человеческой проверки и Pull Request.

## 15. Опционально включить Unleash

Включайте только при наличии:

- развёрнутого Unleash instance;
- владельца;
- утверждённого проекта/environment;
- токенов в secret store;
- правил создания и удаления feature flags;
- стратегии аварийного отключения;
- проверки сетевой доступности.

После настройки изменить feature flag среды через Pull Request и провести тест включения/выключения безопасной демонстрационной функции.

## 16. Опционально включить OpenTelemetry и Grafana

До активации определить:

- какие сигналы собираются: traces, metrics, logs;
- какие данные запрещены к отправке;
- OTLP endpoint и authentication;
- retention;
- dashboards и alerts;
- владельца реакции;
- поведение при недоступности telemetry backend.

Секреты endpoint не хранить в Git. Активацию `opentelemetry` и `grafana` проводить одним контролируемым Pull Request только после проверки подключения.

## 17. Проверить GitHub Actions

Для каждой среды:

1. открыть тестовый Pull Request;
2. убедиться, что все ожидаемые workflows запустились;
3. убедиться, что невалидный артефакт делает проверку красной;
4. убедиться, что `main` нельзя изменить напрямую;
5. убедиться, что зелёный CI не обходит required review;
6. проверить permissions workflow;
7. проверить отсутствие секретов в logs/artifacts.

Название required status check должно точно совпадать с context, который создаёт workflow.

## 18. Провести installation acceptance test

Создайте отдельный учебный R1 Outcome и выполните:

1. создание Pack в PDE;
2. `validate-pack`;
3. Ready Review;
4. PDE → ASE handoff;
5. ASE ACK;
6. тестовый implementation PR;
7. Evidence Bundle;
8. `validate-evidence`;
9. ASE → QSRE handoff;
10. QSRE review;
11. QSRE → PDE feedback;
12. Outcome Check.

Дополнительно проверьте:

- неверный SHA;
- несовместимую major-версию;
- отсутствующий обязательный AC result;
- недоступность Redmine;
- отключённый OpenSpace;
- rollback на предыдущий control release.

Installation acceptance успешен только если положительный сценарий проходит, а отрицательные сценарии корректно блокируются.

## 19. Перевести установку в рабочий режим

После acceptance:

1. зафиксировать install manifest и результаты проверок;
2. записать versions/tags/SHA всех четырёх репозиториев;
3. утвердить дату запуска;
4. назначить on-call/эскалацию, если требуется;
5. включить backup;
6. открыть первый реальный Outcome с подходящим риском;
7. не использовать R3 до завершения security/compliance readiness;
8. назначить дату первого review установки.

## 20. Обновление готовой установки

Обновлять по одному control release за раз:

1. прочитать release notes;
2. определить breaking changes;
3. создать ветку обновления;
4. обновить tag и SHA;
5. запустить control и environment validators;
6. провести contract tests;
7. провести shadow test;
8. получить человеческое решение;
9. выполнить merge;
10. наблюдать согласованный период;
11. закрыть изменение или откатить pins.

Не обновлять все среды вручную в разное время без compatibility plan.

## 21. Откат установки

При проблеме:

1. остановить новые handoff;
2. сохранить evidence и logs;
3. определить затронутые environments;
4. вернуть control tag/SHA к предыдущей подтверждённой версии через Pull Request;
5. повторно запустить validators;
6. подтвердить совместимость;
7. возобновить поток;
8. оформить incident/decision record.

Не переписывать Git history и не использовать force-push для отката.

## 22. Контрольный список готовности новой установки

### Репозитории

- [ ] Четыре репозитория созданы или подключены.
- [ ] Происхождение releases записано.
- [ ] Tags и полные SHA проверены.
- [ ] `main` защищён.
- [ ] CODEOWNERS настроен.
- [ ] Required checks реально запускаются.

### Общая основа

- [ ] Control release разрешён для выбранного режима.
- [ ] `authoritative: true` для production.
- [ ] Контракты stable и совместимы.
- [ ] Validators зелёные.

### Интеграции

- [ ] Redmine mapping заполнен и проверен.
- [ ] Cursor/Codex используют правила нужной среды.
- [ ] OpenSpace выключен или работает только локально в разрешённом режиме.
- [ ] Unleash выключен или полностью настроен.
- [ ] OpenTelemetry/Grafana выключены или полностью настроены.
- [ ] Секретов в Git нет.

### Процесс

- [ ] Сквозной R1 acceptance пройден.
- [ ] Отрицательные contract tests пройдены.
- [ ] Rollback испытан.
- [ ] Backup/restore испытаны.
- [ ] Владельцы и review cycle назначены.
- [ ] Сотрудникам доступна инструкция работы через fork.

## 23. Обязательные записи после установки

Сохраните в разрешённом операционном журнале:

- дату и владельца установки;
- URL репозиториев;
- release tags и полные SHA;
- результаты validators и acceptance test;
- включённые feature flags;
- ссылки на решения по security/compliance;
- известные ограничения;
- rollback versions;
- дату следующего review.

Секреты и персональные данные в эту запись не включаются.
