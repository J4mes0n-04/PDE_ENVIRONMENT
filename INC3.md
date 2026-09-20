# Полный контекст программы PDE, ASE, QSRE и engineering-control

## 1. Для кого и зачем создан этот документ

Этот файл — передача контекста новому диалогу, агенту или участнику команды. Его задача — позволить продолжить создание системы с текущей точки, не повторять уже принятые решения, не потерять существующую работу и не сломать действующую PDE-среду.

Перед началом любых изменений новый исполнитель должен:

1. полностью прочитать этот файл;
2. прочитать корневой `AGENTS.md` соответствующего репозитория;
3. проверить фактическое состояние Git, потому что этот документ фиксирует контекст, но не заменяет `git status`, validators и GitHub;
4. прочитать `INC1.md` для дорожной карты создания системы;
5. прочитать `INC2.md` только когда потребуется развёртывать уже готовую систему в новом месте;
6. не удалять и не перемещать существующие файлы без отдельного плана миграции и подтверждённого отката.



## 2. Главная идея сервиса

Создаётся не один универсальный репозиторий для всех специальностей, а связанная система из трёх рабочих сред и одной общей нормативной основы.

```text
Сигнал о проблеме
       |
       v
PDE Environment
определяет ожидаемый продуктовый результат
       |
       | PDE -> ASE contract
       v
ASE Environment
реализует согласованное определение в коде
       |
       | ASE -> QSRE contract
       v
QSRE Environment
независимо проверяет качество, безопасность и выпуск
       |
       | QSRE -> PDE feedback
       v
PDE Environment
уточняет определение и проверяет фактический Outcome
```

Над тремя средами находится `engineering-control`:

```text
                         engineering-control
                 governance + schemas + contracts
                    immutable release tag + SHA
                    /             |             \
                   v              v              v
          PDE Environment   ASE Environment   QSRE Environment
```



### Почему среды разделяются

- PDE отвечает за **что и зачем должно быть получено**.
- ASE отвечает за **как это будет реализовано**.
- QSRE отвечает за **достаточно ли доказательств и безопасен ли выпуск**.
- `engineering-control` отвечает за **общий язык, нормы и совместимые интерфейсы**.

Если объединить всё в одну настраиваемую копию, разные сотрудники начнут менять общие нормы и локальные правила независимо. Через некоторое время среды разойдутся, а значение Pack, Evidence или Ready станет неодинаковым. Отдельные репозитории с общей версионированной основой предотвращают это расхождение.

## 3. Основная формула PDE

PDE — **Product Definition Engineering**. Среда превращает сигнал о проблеме в проверяемое определение продукта.

```text
Signal
  → Outcome
  → Product Definition Pack
  → Ready Review
  → ASE handoff
  → implementation
  → Evidence Bundle
  → QSRE review
  → release
  → Outcome Check
  → scale | keep | adapt | revert
```

Успешно написанный документ ещё не является результатом. Outcome считается завершённым только после доказанной реализации, выпуска и Outcome Check.

## 4. Роли, функции и среды

Три понятия нельзя смешивать.

### PDE

- **PDE function** — формирование определения продукта;
- **PDE practitioner/lead** — человек, выполняющий функцию;
- **PDE Environment** — репозиторий, правила и инструменты этой функции.



### ASE

- **ASE function** — `Agentic Software Engineering`, инженерная реализация;
- **ASE Engineer** — человек, выполняющий функцию;
- **ASE Environment** — будущая специализированная рабочая среда реализации.



### QSRE

- **QSRE function** — `Quality, Security and Release Engineering`, независимая проверка качества, безопасности и выпуска;
- **QSRE Engineer** — человек, выполняющий функцию;
- **QSRE Environment** — будущая специализированная среда проверки и выпуска.

Не использовать прежние несовместимые расшифровки вроде `Automated Solution Engineering`, `Automated Systems Engineering`, `Quality & Security Release Environment` или `Quality and Safety Review Engineering`.

## 5. Целевые репозитории

```text
engineering-control   общая нормативная основа и контракты
pde-environment       рабочая среда определения продукта
ase-environment       рабочая среда реализации
qsre-environment      рабочая среда независимой проверки
product-*             репозитории конкретных программных продуктов
```



### `engineering-control`

Содержит:

- общие governance-документы;
- общие JSON Schemas;
- межсредовые contracts;
- общие templates, не привязанные к одной среде;
- compatibility matrix;
- правила версионирования;
- validators общего контура;
- release notes и change control.

Не содержит:

- `workspaces/`;
- реальные Outcomes;
- код продуктов;
- PDE-specific skills/rules;
- локальное состояние OpenSpace;
- секреты;
- операционное состояние конкретной установки.



### `pde-environment`

Содержит:

- PDE-specific `AGENTS.md`, rules и skills;
- Pack templates и Pack validators;
- `workspaces/projects/`;
- PDE adapters к ASE и QSRE;
- локальные настройки инструментов PDE;
- ссылку на закреплённую версию `engineering-control`.



### `ase-environment`

Должен содержать:

- приём и ACK PDE → ASE handoff;
- rules и skills инженерной реализации;
- связь Pack SHA → implementation PR/SHA;
- формирование технических evidence;
- ASE → QSRE handoff;
- запрет неявного изменения продуктового определения.



### `qsre-environment`

Должен содержать:

- независимую проверку Evidence Bundle;
- проверку security/release/rollback;
- связь Pack SHA и implementation SHA;
- QSRE → PDE feedback;
- блокирование выпуска при отсутствии обязательных доказательств;
- запрет самостоятельного переписывания Pack.



## 6. Источники истины


| Объект                                | Источник истины                                   |
| ------------------------------------- | ------------------------------------------------- |
| Общие нормы и контракты после cutover | стабильный release `engineering-control`          |
| Общие нормы до cutover                | `governance/` действующего PDE                    |
| Состояние и приоритет работы          | Redmine                                           |
| Определение Outcome                   | `pack.md` + `pack.json` по конкретному commit SHA |
| Реализация                            | продуктовый Git-репозиторий и Pull Request        |
| Доказательства                        | Evidence Bundle, CI artifacts и immutable URLs    |
| Фактический результат                 | Outcome Check и telemetry/support data            |
| Инструкции агента                     | `AGENTS.md`, rules и skills конкретной среды      |


Нельзя копировать полный Pack в Redmine, мессенджер или описание Pull Request. Нужно ссылаться на repository URL, path и полный commit SHA.

## 7. Инструменты и их место



### Обязательное ядро

- Git и GitHub — история, Pull Request, releases, решения и неизменяемые версии;
- GitHub Actions — автоматические проверки;
- Redmine — поток работы, состояние и приоритет;
- Cursor и/или Codex — агентная работа по правилам среды;
- Pack, contracts и Evidence — управляемые артефакты.



### OpenSpace

OpenSpace находится между Cursor/Codex и библиотекой `.agents/skills`.

```text
Cursor / Codex
      ↕
OpenSpace local MCP
      ↕
.agents/skills
      |
      v
quality records + proposal
      |
      v
Pull Request + human decision
```

OpenSpace:

- может искать, оценивать и предлагать улучшения skills;
- работает локально без облачного обмена;
- не меняет governance автоматически;
- не выполняет merge;
- не является approver;
- сначала включается в shadow mode.

Флаги `.codex/config.toml` и `config/features.yaml` должны переключаться согласованно. `false/false` — подготовлено, но выключено; `true/true` — явно активировано. Смешанное состояние должно блокироваться validator.

### Unleash

Опционален. Нужен для управляемого включения функций и staged rollout. На раннем этапе должен оставаться выключенным.

### OpenTelemetry и Grafana

Опциональны. Нужны при появлении реальных telemetry requirements, endpoints, retention, dashboards и владельцев реакции. Само включение флага не доказывает готовность интеграции.

### Будущий web-интерфейс среды

Обсуждалась идея отдельного web-интерфейса первичной настройки:

- ввод GitHub/Redmine и локальных параметров;
- проверка валидности подключений;
- включение/выключение OpenSpace, Unleash, OpenTelemetry и Grafana;
- показ результатов validators;
- генерация конфигурации через контролируемый Pull Request.

Это полезное будущее направление, особенно для нового сотрудника, но сейчас такой интерфейс не является частью production-контура. Сначала необходимо стабилизировать репозитории, contracts и CLI/CI validators. Web UI не должен хранить секреты в Git или обходить Pull Request.

## 8. Нормативные решения, которые уже приняты



### Риск

Истиной является модель:

- `R0` — минимальный/служебный риск, если предусмотрен моделью;
- `R1` — низкий риск;
- `R2` — существенный риск;
- `R3` — критический риск.

Обратная трактовка `R1 = высокий`, `R3 = низкий` запрещена.

### Автономия

Автономия агента обозначается `A0–A3` и не равна организационному масштабу Outcome.

Нужны два независимых поля:

- `autonomy_level`: A0–A3;
- организационный scope/impact: например product, component или team.



### Lifecycle

Нужно различать:

- lifecycle Outcome;
- статус Product Definition Pack;
- статус карточки Redmine.

Основной Outcome lifecycle начинается `New → Defined → Ready → Committed → ...`. Между Pack status и Redmine status должно быть явное отображение, а не попытка назвать все состояния одинаково.

### Pack

Pack Schema должна:

- запрещать произвольные неизвестные поля;
- содержать rollout, rollback, telemetry, test plan и open questions;
- требовать Full Pack для R2/R3;
- не разрешать `ready` при блокирующих вопросах;
- требовать threat analysis и rollback для R3;
- требовать Evidence Bundle для released state.



### Evidence

Проверка Evidence должна контролировать не только наличие заголовков, но и:

- результат каждого требования;
- допустимые evidence statuses;
- immutable URL;
- commit SHA;
- среду и время выполнения;
- версию Pack;
- полноту покрытия;
- остаточный риск.

Зелёный CI должен означать доказанную полноту по установленному контракту, а не только похожую структуру файла.

### Governance

- каждый нормативный документ имеет owner, approver, scope, effective date, review cycle и changelog;
- `document-control.yaml` и заголовки документов синхронизированы;
- governance, templates, schemas, skills, rules, scripts и platform workflows проходят change control в соответствии с их влиянием;
- значения `N/A` или `impact: none` не должны позволять обойти содержательное описание нормативного изменения;
- OpenSpace не имеет права напрямую изменять governance.



## 9. Правила работы сотрудников

Сотрудник работает через fork:

1. создаёт разрешённый fork;
2. клонирует fork как `origin`;
3. добавляет главный репозиторий как `upstream`;
4. синхронизирует `main` с `upstream/main`;
5. создаёт отдельную ветку;
6. меняет только разрешённые области;
7. запускает validators;
8. отправляет ветку в fork;
9. создаёт Pull Request в главный репозиторий;
10. ждёт решения владельца.

Обычная продуктовая работа ограничена `workspaces/projects/<project-id>/`. Улучшение skill выполняется отдельной веткой и Pull Request в `.agents/skills/<skill-name>/`. Без отдельного поручения сотрудник не меняет governance, schemas, scripts, workflows или `AGENTS.md`.

Подробности: `integrations/github/README.md`.

## 10. Правила рабочих проектов PDE

Когда пользователь кладёт входные документы в `workspaces/projects/<project-id>/` и просит сформировать Outcome:

1. изучить документы;
2. определить пробелы;
3. задать уточняющие вопросы до создания итогового результата;
4. не спрашивать повторно то, что уже есть во входных данных;
5. при разрешении продолжить без ответов явно записать допущения и блокирующие вопросы;
6. создать отдельный каталог:

```text
workspaces/projects/<project-id>/outcomes/<outcome-id>/
```

1. писать человекочитаемые выходные материалы на русском языке;
2. оставлять имена файлов, ключи схем и устойчивые идентификаторы на английском;
3. не изменять платформенные каталоги во время работы над проектом.

Важно: тестовый проект `av-control-business` был только пробным прогоном. Он не должен фигурировать в дальнейшей архитектуре, новых contracts, ASE/QSRE environments, production-планах или примерах целевой системы.

## 11. Языковая политика

- Документы и человекочитаемые выходные артефакты — на русском языке.
- Имена файлов и каталогов — на английском.
- JSON/YAML keys — на английском.
- Устойчивые идентификаторы — на английском: `OUT-001`, `AC-001`, `NFR-001`, `EVD-001`, `DC-001`.
- Служебные enum values могут быть английскими: `draft`, `ready`, `pass`, `scale`.
- При первом употреблении сложного английского термина желательно дать русское объяснение.



## 12. Локальные пути и GitHub



### PDE

Локальный путь:

```text
C:\Users\maksim\Documents\ChatGPT\PDE(home)\PROD
```

GitHub remote:

```text
https://github.com/J4mes0n-04/PDE_ENVIRONMENT.git
```

Контрольный baseline:

```text
tag:    pde-baseline-v0.1.0
commit: a8df54374e2b0db6c13175c7bf1b1cf073a7441a
```

На момент создания `INC3.md` локальный `main` PDE соответствует `origin/main` на commit:

```text
d116275 Merge pull request #1 from J4mes0n-04/codex/repository-separation-inventory
```

При этом локально существуют ещё не закоммиченные документы:

```text
INC1.md
INC2.md
INC3.md
docs/file-catalog.md — добавлены записи новых инструкций
```

Новый диалог не должен потерять, перезаписать или случайно исключить эти изменения.

### engineering-control

Локальный путь:

```text
C:\Users\maksim\Documents\ChatGPT\PDE(home)\engineering-control
```

GitHub:

```text
https://github.com/J4mes0n-04/engineering-control.git
```

Репозиторий публичный. На момент создания документа:

```text
main commit: 65aa511
status: staging
authoritative: false
control version: 0.1.0-staging
contracts: 1.0.0 draft
```

Защита `main` активна:

- Pull Request обязателен;
- required checks: `control`, `change-control`;
- разрешение review threads обязательно;
- удаление `main` запрещено;
- force-push запрещён;
- required approving review count пока `0`, потому что у репозитория один владелец и обязательное стороннее одобрение заблокировало бы его собственные PR.

Последняя локальная проверка `pwsh ./scripts/validate-control.ps1` прошла успешно. CI на merge PR #2 прошёл успешно.

## 13. Что уже выполнено по этапам



### Этап 0. Контрольная точка PDE

- создан tag `pde-baseline-v0.1.0`;
- зафиксирован полный SHA;
- baseline отправлен в GitHub.



### Этап 1/2. Инвентаризация

- создан `architecture/repository-separation-plan.md`;
- классифицированы каталоги PDE;
- выявлены зависимости validators, workflows, skills, rules и OpenSpace;
- подтверждено, что `workspaces/`, PDE skills/rules и operations не переносятся в общий control repository.



### Этап 3. Общая основа

- создан `engineering-control`;
- перенесён staging snapshot governance без удаления оригинала из PDE;
- добавлен `source-baseline.yaml`;
- скопированы только выбранные общие schemas/templates/reference dependency;
- источник истины пока остаётся в PDE.



### Этап 4. Контракты

Созданы:

```text
contracts/pde-to-ase.schema.json
contracts/ase-to-qsre.schema.json
contracts/qsre-to-pde.schema.json
contracts/compatibility.yaml
contracts/examples/*.example.json
scripts/validate-contracts.ps1
```



### Этап 5. Change control общей основы

Созданы:

```text
.github/CODEOWNERS
.github/pull_request_template.md
.github/workflows/validate-control.yml
scripts/validate-control.ps1
scripts/check-control-change.ps1
CHANGELOG.md
```

PR #2 объединён. Ветка `main` защищена. Локальная слитая ветка удалена только после проверки merge.

## 14. Что сейчас не завершено

1. `CHANGELOG.md` в `engineering-control` всё ещё содержит `1.0.0-rc.1 — Unreleased`.
2. Tag/release `v1.0.0-rc.1` ещё не создан.
3. `engineering-control` ещё не authoritative.
4. Contracts ещё draft.
5. ASE Environment ещё не создана.
6. QSRE Environment ещё не создана.
7. PDE ещё не имеет control-plane pin/mode shadow.
8. Межрепозиторные compatibility checks ещё не подключены.
9. Сквозной shadow pilot ещё не проведён.
10. Stable release `v1.0.0` и production cutover ещё не выполнены.
11. Организационные роли, Redmine и будущие compliance controls должны настраиваться отдельно.



## 15. Следующий безопасный порядок действий



### Действие 1. Сохранить текущие инструкции PDE

До новой архитектурной работы:

```powershell
Set-Location "C:\Users\maksim\Documents\ChatGPT\PDE(home)\PROD"
git status --short --branch
pwsh ./scripts/validate-repository.ps1
git diff --check
```

Проверить `INC1.md`, `INC2.md`, `INC3.md` и записи `docs/file-catalog.md`. Затем оформить отдельный documentation Pull Request. Не отправлять напрямую в защищённый `main`, если правила репозитория этого не допускают.

### Действие 2. Подготовить `engineering-control v1.0.0-rc.1`

Через отдельный Pull Request:

1. заменить `Unreleased` на фактическую дату;
2. убедиться, что release notes явно говорят `staging`, `authoritative: false`, contracts `draft`;
3. запустить `validate-control.ps1`;
4. дождаться `control` и `change-control`;
5. получить человеческое решение;
6. после merge создать аннотированный tag и GitHub prerelease.

Не менять `authoritative` на `true` только из-за выпуска release candidate.

### Действие 3. Создать `ase-environment`

Создать отдельный репозиторий-каркас, а не копию PDE. Подключить `engineering-control v1.0.0-rc.1` по tag и полному SHA. Реализовать только вход PDE → ASE, ACK, связь реализации и выход ASE → QSRE.

### Действие 4. Создать `qsre-environment`

Создать отдельный репозиторий-каркас. Подключить тот же control release. Реализовать вход ASE → QSRE, evidence/release validation и выход QSRE → PDE.

### Действие 5. Подключить PDE в shadow mode

Добавить будущий `config/control-plane.yaml` или согласованный эквивалент только после готовности RC и validators. Локальный `governance/` не удалять. Сравнивать его с control snapshot и блокировать расхождение.

### Действие 6. Сквозной shadow pilot

Провести нейтральный R1 pilot, не используя `av-control-business`. Пройти полный цикл и зафиксировать evidence, дефекты контрактов, время передачи и rollback.

### Действие 7. Stable release и cutover

Только после успешного pilot:

- утвердить contracts;
- выпустить `engineering-control v1.0.0`;
- установить `authoritative: true` отдельным решением;
- обновить pins всех сред;
- выдержать период наблюдения;
- только потом рассматривать удаление рабочих дублей отдельным миграционным PR.



## 16. Команды первичной проверки для нового диалога



### PDE

```powershell
Set-Location "C:\Users\maksim\Documents\ChatGPT\PDE(home)\PROD"
git status --short --branch
git log -5 --oneline --decorate
git remote -v
pwsh ./scripts/doctor.ps1
pwsh ./scripts/validate-repository.ps1
git diff --check
```

Pack/Evidence validators могут требовать путь к конкретному Outcome. Сначала посмотреть параметры через `Get-Help` или начало скрипта, а не угадывать путь.

### engineering-control

```powershell
Set-Location "C:\Users\maksim\Documents\ChatGPT\PDE(home)\engineering-control"
git status --short --branch
git log -5 --oneline --decorate
git remote -v
pwsh ./scripts/validate-control.ps1
```

Если нужна актуальная проверка GitHub, дополнительно проверить ruleset, последние Actions runs, Pull Requests и releases через `gh`. Не считать записанное в этом документе состояние вечным.

## 17. Что нельзя делать новому диалогу без отдельного решения

- удалять `governance/` из PDE;
- объявлять staging control authoritative;
- создавать stable release до shadow pilot;
- механически копировать PDE целиком в ASE/QSRE;
- переносить `workspaces/` в control или другие environments;
- включать OpenSpace cloud mode;
- позволять OpenSpace автоматически менять governance или выполнять merge;
- включать Unleash/OpenTelemetry/Grafana только ради наличия интеграции;
- сохранять secrets в Git;
- делать direct push в защищённый `main`;
- использовать force-push или переписывать историю для отката;
- менять смысл Outcome в ASE без Definition Change;
- считать зелёные тесты единственным evidence;
- использовать тестовый `av-control-business` как часть целевой архитектуры;
- смешивать нормативное изменение и рабочий Outcome в одном Pull Request.



## 18. Как принимать решения при неопределённости

1. Сначала проверить Git, validators и существующие документы.
2. Если решение меняет архитектуру, источник истины, security boundary или release policy — остановиться и запросить человеческое решение.
3. Если действие read-only и помогает проверить состояние — выполнить его.
4. Если изменение обратимо, локально и находится в явно заданной области — выполнить после проверки правил репозитория.
5. Если существует риск потери данных — создать контрольную точку и план отката до изменения.
6. Если пользователь просит создать Outcome из входных документов — сначала задать блокирующие уточняющие вопросы.
7. Любое предположение записывать в артефакте, а не оставлять только в переписке.



## 19. Документы, которые нужно читать вместе

- `README.md` — вход для пользователей PDE;
- `AGENTS.md` — обязательные правила агента;
- `INC1.md` — полная программа доведения системы до production;
- `INC2.md` — установка готовой системы в другом месте;
- `architecture/repository-separation-plan.md` — инвентаризация и зависимости разделения;
- `architecture/pde-ase-qsre-flow.md` — логика передачи;
- `governance/02-glossary.md` — термины;
- `governance/05-risk-model.md` — риск;
- `governance/06-agent-autonomy.md` — автономия;
- `governance/09-lifecycle-and-gates.md` — lifecycle;
- `governance/10-evidence-standard.md` — evidence;
- `governance/15-document-governance.md` — управление документами;
- `governance/19-ase-qsre-interface-contract.md` — интерфейс функций;
- `integrations/github/README.md` — fork workflow сотрудника;
- `integrations/openspace/README.md` — локальный OpenSpace;
- `engineering-control/README.md` — статус общей основы;
- `engineering-control/source-baseline.yaml` — происхождение snapshot;
- `engineering-control/contracts/compatibility.yaml` — версии контрактов.



## 20. Краткое резюме для продолжения

Сейчас имеется работающая draft PDE-среда и защищённый staging-репозиторий общей нормативной основы. Контрольный baseline PDE сохранён. Инвентаризация проведена. Три межсредовых контракта созданы и валидируются. `engineering-control` ещё не источник истины, а ASE/QSRE environments ещё не существуют.

Ближайшая задача — сохранить новые инструкции через Pull Request, затем выпустить честно обозначенный `engineering-control v1.0.0-rc.1`, после чего создавать отдельные ASE и QSRE environments и подключать их к этому RC по tag и полному SHA. PDE переводится на общий control только в shadow mode, без удаления локальной нормативной базы. Production cutover возможен лишь после сквозного пилота, стабильного release и испытанного отката.  
  
------------------------Этап 8 завершён. QSRE Environment создана, опубликована и защищена:----------------------------------

[GitHub — qsre-environment](https://github.com/J4mes0n-04/qsre-environment)

Локальный путь на рабочей машине владельца: каталог `qsre-environment` рядом с `PROD` и `engineering-control`. В репозитории хранится только ссылка на GitHub.

Создано:

- самостоятельная QSRE-среда;
- русскоязычные `README.md`, `AGENTS.md` и эксплуатационные инструкции;
- процесс ASE → QSRE → PDE;
- независимая проверка evidence, security, rollout и rollback;
- шаблоны QSRE ACK, review plan и release decision;
- четыре QSRE skills:
  - приём ASE handoff;
  - проверка evidence;
  - оценка выпуска;
  - формирование обратной связи PDE;
- отдельная структура `workspaces/projects/<project-id>/reviews/<review-id>/`;
- validators для контрактов ASE → QSRE и QSRE → PDE;
- проверка неизменности Pack SHA и implementation SHA;
- GitHub Actions, CODEOWNERS и Pull Request template;
- выключенные по умолчанию OpenSpace, Unleash, OpenTelemetry и Grafana.

Общая основа закреплена:

```
tag: v1.0.0-rc.1
commit: abd0982171341438cab80267099b951a2027be0b
mode: shadow
authoritative: false
contracts: 1.0.0 draft
```

Состояние Git:

```
commit: b90b35ca3901ccb03bf867de8ed66719b57bb179
branch: main
local main = origin/main
```

Проверки:

- QSRE doctor — успешно;
- оба contract-примера — успешно;
- структура репозитория — валидна;
- найдено 4 QSRE skills;
- проверено 20 Markdown-файлов;
- GitHub Actions check `qsre` — успешно;
- рабочее дерево чистое.

Защита `main` активна:

- изменения только через Pull Request;
- обязательный check `qsre`;
- обязательное разрешение обсуждений;
- запрет force-push;
- запрет удаления `main`;
- обход защиты запрещён.

Теперь существуют три отдельных контура: PDE, ASE и QSRE, а ASE и QSRE используют одинаковую закреплённую версию `engineering-control`. Следующий этап — подключить PDE к этой общей основе в `shadow`-режиме, не удаляя существующий локальный `governance/`.  
  
--------------------------------------------Этап 9. Автоматизировать взаимодействие------------------------------------------------

### 27. Централизовать reusable workflows

После ручной проверки процесса вынести общие CI-проверки в `engineering-control`.

Каждая среда вызывает workflow по тегу или SHA:

```
uses: <организация>/engineering-control/.github/workflows/validate-pde.yml@<SHA>
```

### 28. Добавить межрепозиторные события

Только после стабильного ручного процесса:

```
PDE Ready
→ событие для ASE

ASE Evidence Ready
→ событие для QSRE

QSRE Feedback
→ уведомление PDE
```

Сначала автоматизация создаёт Issue или уведомление. Она не должна автоматически принимать решения, менять Pack или объединять Pull Request.

### 29. Подключить ограниченный GitHub App

Если потребуется автоматический доступ:

- `engineering-control` — read;
- входная среда — read;
- целевая среда — минимально необходимая запись;
- никакого глобального токена для всех репозиториев;
- секреты только в GitHub Secrets.

---

## Этап 10. Убирать дублирование только после стабилизации

### 30. Провести период параллельной работы

Минимум несколько полных тестовых циклов должны пройти с общими правилами.

Проверить:

- воспроизводимость;
- совместимость версий;
- доступ сотрудников;
- работу CI;
- восстановление по тегам;
- отсутствие скрытых ссылок на старые пути.

### 31. Составить отдельный план удаления дубликатов

Удаление локальных копий governance из PDE нельзя включать в предыдущие изменения.

Оно оформляется отдельным Pull Request, содержащим:

- список удаляемых файлов;
- новое местоположение каждого файла;
- ссылки на историю;
- план отката;
- подтверждение успешных проверок;
- одобрение владельца.

До этого момента ничего из текущего `PROD` не удаляется.

## Ближайшие пять конкретных действий

Сейчас следует выполнить только это:

1. Добавить `.build/` в `.gitignore`.
2. Зафиксировать `docs/target-architecture.png`.
3. Запустить все локальные проверки PDE.
4. Создать и отправить тег `pde-baseline-v0.1.0`.
5. Подготовить `architecture/repository-separation-plan.md` без перемещения файлов.

Только после успешного завершения этих пяти действий создаётся `engineering-control`. ASE и QSRE пока не создаём. Это даст надёжную точку восстановления и не позволит смешать сохранение текущей среды с её архитектурным разделением.

---

## Этап 9 начат — 2026-09-20

Этот блок фиксирует фактическую подготовку автоматизации. Исторические разделы 14–15 и «пять ближайших действий» выше не переписывались.

Сделано в рабочих деревьях, **ещё не влито** в защищённый `main`:

1. В `engineering-control` добавлены reusable workflows `validate-pde.yml`, `validate-ase.yml`, `validate-qsre.yml`, `notify-peer.yml` и draft-контракт `cross-repo-event`.
2. Средам пока нельзя вызывать эти workflows по SHA `v1.0.0-rc.1`: файлов там нет. Callers копируются из `examples/environment-callers/` только после merge и нового pin, например `v1.0.0-rc.2`.
3. Локальные validate workflow PDE/ASE/QSRE не удалялись.
4. Ручные `workflow_dispatch` уведомления создают Issue по маршрутам PDE Ready → ASE, ASE Evidence Ready → QSRE, QSRE Feedback → PDE.
5. Автоматизация не объединяет Pull Request, не меняет Pack и не принимает Ready-решение. `repository_dispatch` не включён из‑за требования GitHub на `contents: write`.
6. Ограниченный доступ описывается тремя GitHub App в `engineering-control/docs/github-app.md`. Приложения ещё нужно создать в GitHub UI и положить секреты в Environments.

Следующие шаги человека:

1. Отдельный Pull Request в `engineering-control` с полями `Reason:` и `Governance impact:`.
2. После merge записать полный SHA и при необходимости пометить `v1.0.0-rc.2` без `authoritative: true`.
3. Отдельные PR в PDE, ASE и QSRE с notify/listen workflows; в ASE не смешивать это с уже незакоммиченной работой Codex.
4. Создать три GitHub App и Environments `notify-ase`, `notify-qsre`, `notify-pde`.
5. Проверить ручной `workflow_dispatch`, затем shadow-pin PDE и сквозной pilot. Cutover не начинать.

---

## Этап 10 начат — 2026-09-20

Сделано без удаления файлов из `PROD`:

1. Оформлен период параллельной работы: `operations/parallel-stabilization-period.md`.
2. Зафиксирована базовая проверка: pins ASE/QSRE и теги восстановления в порядке; PDE shadow pin и три полных цикла ещё не закрыты.
3. Составлен отдельный план удаления дубликатов: `architecture/governance-duplicate-removal-plan.md` со списками путей, новыми местами, ссылками на историю, откатом и обязательными полями будущего PR.
4. Убраны устаревшие записи catalog про отсутствующий `av-control-business` и обновлён clone URL README на `pde-environment`.
5. `governance/` в PDE **не удалялся** и не объявлялся заменённым.

Выход из этапа 10 и execution PR удаления запрещены, пока не выполнены критерии выхода из периода параллельной работы.
