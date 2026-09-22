# Proposal: эксплуатационный интерфейс AV Control

## Status

- Статус: `draft`.
- Будущий Outcome: один; идентификатор не присвоен.
- Владелец Outcome: не назначен.
- Product Owner: не назначен.
- Владелец риска: не назначен.
- Владелец данных и метрик: не назначен.
- Владелец evidence: не назначен.
- Release/Rollback Owner: не назначен.
- Redmine: Не создана.
- Готовность: change не может быть подтверждён до закрытия блокирующих вопросов из `explore.md` и этого proposal.

## Why

### Подтверждённая проблема

Эксплуатационные функции AV Control описаны во входном документе, но ещё не сведены в одну проверяемую ролевую поверхность. Сейчас не зафиксирован единый контракт, по которому:

- Support Operator начинает с health dashboard, локализует компонент, сохраняет контекст в фильтрах журналов и формирует безопасный diagnostic bundle;
- IT Admin вводит контроллер в эксплуатацию, управляет пользователями, сетью, NTP, TLS, лицензией, обновлениями, backup/restore, Safe Mode, ретенцией и временным доступом;
- Security Auditor читает неизменяемый аудит и проверяет события без административных прав;
- Room Client в Safe Mode показывает только понятную заглушку и не предлагает управление оборудованием;
- любая критическая операция имеет видимый отказ и путь восстановления, а не только happy path.

Из-за отсутствия этого контракта разработка может показать устаревшее состояние как здоровое, ограничить RBAC только скрытием кнопок, выгрузить секреты в bundle, начать update во время встречи, частично применить restore либо объявить rollback успешным без проверки возвращённой версии.

### Кто затронут

- Support Operator теряет воспроизводимый путь от симптома к причине и handoff в поддержку.
- IT Admin не получает безопасного интерфейса ввода, обслуживания и восстановления контроллера.
- Security Auditor не может подтвердить полноту и целостность критических событий.
- Vendor Support рискует получить постоянный или избыточный доступ вместо временного.
- End User видит техническую ошибку или управляющие controls вместо безопасной заглушки при Safe Mode.

### Подтверждение

Проблема, роли, пути и ограничения подтверждены разделами 2–24 и полным реестром Use Case в разделе 31 файла `workspaces/projects/av-control-ui/inputs/REQ-UI-001-av-control-interface.md`. Приоритет утверждений и запрет превращать draft-визуал в baseline определены разделами 25, 27 и 28 того же файла.

### Цена проблемы

- инцидент нельзя локализовать первой линией;
- обслуживание может прервать активную встречу;
- update/restore может оставить контроллер в нерабочем или неясном состоянии;
- bundle, аудит или сервисная сессия могут раскрыть данные;
- оператор может принять stale health за актуальный;
- без discovery нельзя обоснованно задать target и проверить Outcome.

### Что пока не доказано

Не доказаны числовые baseline и target, длительность проверки, требуемый размер выборки, пороги производительности, целевая аппаратная матрица, точная ролевой матрица, состав bundle, форматы update/backup, Safe Mode threshold, модель лицензии и сервисной сессии. Эти сведения не подменяются предположениями.

## What

Change задаёт наблюдаемое поведение одной эксплуатационной поверхности:

- Health dashboard показывает сервер, комнаты, клиенты, устройства, драйверы и сценарии, свежесть данных и переход к проблемному объекту (`AC-031`).
- Triage сохраняет выбранный объект, интервал, severity и correlation context при переходе к журналам и явно различает пустой результат, ошибку запроса и отсутствие прав (`AC-032`).
- Diagnostic bundle формируется локально только после preview состава и результата privacy-проверки; неуспешная очистка не выдаётся за готовый bundle (`AC-033`, `NFR-033`).
- Неинициализированный контроллер проводит уполномоченного оператора через создание первого администратора, staged-настройку сети/NTP и проверку до фиксации (`AC-034`).
- IT Admin управляет пользователями и только утверждёнными ролями; запрещённая комбинация или прямой запрос не меняют данные (`AC-035`, `NFR-031`).
- TLS-сертификат проверяется до активации; Security Auditor читает аудит; IT Admin настраивает явную SIEM/syslog-передачу, не теряя локальный журнал при отказе получателя (`AC-036`, `NFR-032`).
- Offline update проходит локальную проверку, показывает patch note, создаёт restore point, устанавливается с видимыми стадиями и проверяет возвращённую версию после rollback (`AC-037`, `NFR-034`, `NFR-035`).
- При активной встрече update останавливается на предупреждении; безопасное действие по умолчанию — отложить, а продолжение требует разрешённой роли и отдельного подтверждения (`AC-038`).
- Проверяемый backup восстанавливается на совместимом текущем или replacement controller без частичного применения; несовместимость сохраняет текущее состояние (`AC-039`, `NFR-034`).
- В Safe Mode Admin Web UI показывает причину, диагностику и только разрешённые recovery-действия, а Room Client показывает заглушку без управления оборудованием (`AC-040`).
- Экран лицензии показывает серверное состояние, лимит, использование, срок при наличии и последствия; превышение лимита не останавливает уже активный runtime (`AC-041`).
- IT Admin выдаёт Vendor Support видимый ограниченный доступ, видит активность и может немедленно отозвать его; постоянный или бесконтрольный доступ запрещён (`AC-042`, `NFR-032`).
- IT Admin видит использование хранилища, задаёт допустимую политику ретенции и выполняет разрешённую очистку; storage-full state защищает критические данные и не маскируется как штатное состояние (`AC-043`).
- Все пути используют обязательные auth/RBAC/TLS, локальную наблюдаемость, offline-first, клавиатурный focus и проверяемые recovery-состояния (`NFR-031`…`NFR-038`).

Проверяющий увидит не только экраны, но и серверные отказы, audit events, отсутствие внешних запросов, сохранение предыдущей версии после fault injection и privacy scan сформированного bundle.

## Measurable outcome

### Исходный уровень

Единого реализованного эксплуатационного UI и воспроизводимых измерений во входном документе не зафиксировано. Baseline считается неизвестным, а не нулевым.

### Discovery contract

Первый delivery slice обязан собрать локально и связать с ролью, сценарием, версией сборки, браузером, аппаратной конфигурацией и размером набора данных:

- факт начала, завершения, отказа, отмены и восстановления каждого критического пути;
- длительность и число шагов пути health → triage → logs → bundle;
- долю инцидентов, завершённых локальным решением или подготовленным handoff;
- длительность и результат update preflight, restore-point, установки, self-check и rollback;
- длительность и результат backup verification и restore на replacement controller;
- частоту перехода в Safe Mode и результат restore/rollback;
- случаи запрета RBAC, нарушения audit integrity, privacy scan и обязательного внешнего обращения;
- время до первого полезного health-состояния, применения log filter, открытия деталей объекта, начала bundle generation и отображения update preflight;
- состояние keyboard/focus-прохода по каждому P0 Admin-пути.

Сырые данные и агрегаты хранятся локально. Discovery не задаёт и не подразумевает числовой target. После получения baseline назначенный владелец должен отдельно утвердить target, выборку и validation window; до этого будущий Outcome не готов к Ready Review.

### Цель draft

Функциональная цель draft считается описанной, когда все `AC-031`…`AC-043` и `NFR-031`…`NFR-038` имеют воспроизводимые main и negative/recovery scenarios и план evidence. Числовая цель Outcome остаётся блокером и не считается закрытой полнотой спецификации.

### Источник и окно проверки

- Источники: локальные журналы сценариев, записи ролевых прогонов, результаты fault injection, privacy/security/a11y checks и сырые discovery-замеры на конкретном Git SHA.
- Этапы наблюдения: тестовый стенд, затем пилотное помещение.
- Размер выборки и длительность окна: не определены; блокируют подтверждение будущего Outcome.

## Scope

### In scope

- Admin Web UI: обзор health, детализация сущности, журнал событий, фильтры, correlation context и переходы triage.
- Admin Web UI: preview, формирование, локальная выдача и ошибка diagnostic bundle.
- Bootstrap UI: первый администратор, staged network settings, NTP и connectivity check.
- Admin Web UI: пользователи, роли, TLS, аудит, SIEM/syslog, license, temporary Vendor Support.
- Admin Web UI: локальная загрузка update, patch note, preflight, active-meeting gate, restore point, progress, self-check и rollback result.
- Admin Web UI: backup creation/verification, restore preflight, current/replacement controller restore и recovery.
- Admin Web UI: Safe Mode diagnostics, logs/crash dump availability, restore/rollback и подтверждённый выход.
- Room Client: только Safe Mode stub и resync после подтверждённого восстановления.
- Admin Web UI: retention settings, cleanup preview/result, storage pressure/full states.
- Ошибки, denied, stale, empty, offline, degraded, partial-source, rollback-failed и storage-full states перечисленных путей.
- Локальные события и evidence hooks для discovery без внешней телеметрии.

### Data in scope

- агрегированное и компонентное health-состояние с freshness;
- журнальные события и выбранные фильтры;
- manifest bundle и отчёт redaction без раскрытия исключённых значений;
- состояние и результат bootstrap/network/NTP checks;
- пользователи, роли и effective permissions;
- metadata сертификата без отображения private key;
- audit events и delivery status SIEM/syslog;
- metadata update, patch note, verification, restore point, stage, version and result;
- active-meeting state только в объёме, необходимом для update gate;
- metadata backup, compatibility and restore result;
- Safe Mode reason, allowed actions and recovery result;
- license state, usage, limit and applicable restriction;
- temporary-access scope, expiry, activity and revocation state;
- retention policy, storage usage and cleanup result;
- локальные discovery-события без секретов и содержимого пользовательских данных.

### Out of scope

- Конфигуратор, project wizard, canvas, preflight/deploy проекта и редактор UI: отдельный change конфигуратора.
- Обычный Room Client, kiosk, pairing, meeting controls, BYOD и booking: отдельный change клиента комнаты.
- Общая дизайн-система, окончательная IA оболочки и визуальный baseline: foundation change.
- Реализация runtime, Monitoring storage, audit store, update service, license service, identity provider, SIEM или cryptography.
- Проектирование API endpoint, wire protocol, package/archive schema и криптографических алгоритмов.
- Автоматическая облачная отправка bundle, онлайн-доставка update, CDN, внешний telemetry SaaS и обязательная облачная лицензия.
- Постоянный Vendor Support, скрытый backdoor и выдача вендору административной роли.
- Покупка лицензии, коммерческий checkout и биллинг.
- Изменение аппаратной части контроллера.

## Users and situations

- Support Operator: начинает с сигнала о проблеме и должен локализовать компонент, найти релевантные события, выполнить разрешённое действие или подготовить bundle.
- IT Admin: вводит контроллер в эксплуатацию, поддерживает безопасность и жизненный цикл, выполняет update/restore и отвечает на storage/license состояния.
- Security Auditor: читает и фильтрует audit trail и подтверждает целостность, но не меняет настройки.
- Vendor Support: входит только по временно выданному scope и не получает скрытых или постоянных прав.
- End User: при Safe Mode видит понятное недоступное состояние и путь обращения, но не техническую причину и не инженерные controls.

Ситуации отказа включают stale Monitoring, недоступный источник логов, ошибку privacy scan, неуспешный network/NTP check, запрещённую роль, invalid certificate, SIEM outage, invalid update package, active meeting, failed update/rollback, incompatible backup, failed restore, Safe Mode recovery failure, invalid/limit-exceeded license, expired/revoked vendor session и full storage.

## Open questions

### Blocking

- Утвердить и назначить владельцев Outcome, продукта, риска, метрик, evidence, выпуска и отката. Сейчас все перечисленные владельцы не назначены.
- Утвердить ролевую матрицу и effective permissions для всех действий этого change. Запрещено считать скрытую кнопку достаточной авторизацией.
- Утвердить bootstrap trust model, network commit/revert behavior и NTP success criteria.
- Утвердить TLS formats/trust chain, certificate recovery и private-key handling.
- Утвердить обязательный audit event catalog, integrity-verification mechanism и SIEM/syslog delivery contract.
- Утвердить manifest, redaction, encryption, temporary storage и handoff policy diagnostic bundle.
- Утвердить update package format, trust roots, compatibility rules, self-check, active-meeting override permission и rollback contract.
- Утвердить backup content, secret/certificate handling, replacement-controller identity и compatibility matrix.
- Утвердить Safe Mode entry/exit criteria и разрешённые actions.
- Утвердить license state machine, limits, grace behavior и offline license application.
- Утвердить Vendor Support session model, scope, maximum duration и revocation semantics.
- Утвердить retention ranges, protected records, cleanup priority и storage pressure thresholds.
- Утвердить target hardware/data/browser matrix, performance thresholds, WCAG level и screen reader scope.
- Утвердить baseline, target, sample, data owner и validation window после discovery.
- Создать и связать Redmine. Текущее состояние: Не создана.

### Non-blocking for draft, blocking for visual baseline

- Определить окончательную композицию dashboard, расположение глобального статуса и конкретный loading/skeleton pattern.
- Утвердить визуальные tokens и акцент foundation change; этот proposal не превращает UI draft в baseline.

## Constraints

- Сервер остаётся source of truth; UI не вычисляет разрешения, health, license, meeting или recovery success самостоятельно.
- End User не видит tags, drivers, protocols, stack traces, transport errors, secrets или audit internals.
- Штатная работа возможна при заблокированном внешнем интернете.
- Update и bundle поступают локально; никаких фоновых облачных загрузок.
- Любое запрещённое действие отклоняется сервером и не меняет данные.
- Нельзя показывать success до проверки фактического итогового состояния.
- Аудит нельзя изменять или удалять через роли этого change.
- Partial restore и скрытая очередь критических команд запрещены.
- Draft не задаёт числовой performance target или WCAG conformance level.

## Dependencies

- Foundation change: общая auth-shell, route guards, permission-denied, offline, focus и semantic-state patterns.
- Server API/WebSocket: source-of-truth snapshots, commands, operation progress, correlation context и resync.
- Monitoring: health hierarchy, logs, freshness, bundle sources.
- Security: identity, RBAC, TLS, audit integrity и temporary access.
- Update service: local package verification, restore point, install, self-check и rollback.
- Backup/storage: create, verify, compatibility, atomic restore, retention и cleanup.
- License service: authoritative state, limits, usage and license import result.
- Room/session service: authoritative active-meeting state.
- Room Client: Safe Mode stub and post-recovery resync.

При отсутствии зависимости UI показывает конкретное degraded/error state и не подменяет его локально вычисленным успехом.

## Risks

- Ложный зелёный health при stale data. Снижение: freshness и degraded source state обязательны.
- Privacy leak через bundle. Снижение: preview, policy-based redaction, fail-closed и fixture scan.
- UI-only RBAC. Снижение: запрещённые прямые запросы входят в evidence.
- Потеря доступа после network/TLS change. Снижение: staged validation и сохранение прежней конфигурации до успешного подтверждения.
- Update во время встречи. Снижение: authoritative meeting gate и безопасное действие «Отложить».
- Ложный rollback success. Снижение: проверка версии, health и audit result.
- Partial restore. Снижение: compatibility preflight и atomic recovery contract.
- Скрытый постоянный Vendor Support. Снижение: обязательные scope, expiry, visibility, revoke и audit.
- Удаление обязательного аудита очисткой. Снижение: protected category и серверный запрет.
- Выдуманные target после удобного пилота. Снижение: хранение raw discovery context и отдельное утверждение метрик.

## Evidence plan

- `AC-031`, `AC-032`: запись incident drill от health до фильтрованных логов; отдельный прогон stale/failed Monitoring с сохранёнными фильтрами.
- `AC-033`, `NFR-033`: manifest, redaction report, hash локального bundle и privacy scan на fixture с известными секретами; отдельный fail-closed прогон.
- `AC-034`: запись bootstrap на чистом контроллере и fault injection network/NTP с подтверждением сохранённой доступной конфигурации.
- `AC-035`, `NFR-031`: role matrix, allowed/denied UI-пути и серверные ответы на прямые запрещённые запросы через TLS.
- `AC-036`, `NFR-032`: certificate validation report, read-only audit recording, SIEM delivery/outage recording и integrity-tamper test.
- `AC-037`, `AC-038`, `NFR-034`, `NFR-035`: network capture без внешних запросов, update preflight, active-meeting gate, restore-point proof, install failure и проверенный rollback.
- `AC-039`: проверка backup integrity, restore на чистом совместимом replacement controller, incompatible-backup rejection и отсутствие partial apply.
- `AC-040`: fault injection для входа в Safe Mode, одновременная запись Admin Web UI и Room Client, successful recovery и failed-recovery state.
- `AC-041`: прогоны server-provided license states, limit block без остановки active runtime и invalid license import.
- `AC-042`: выдача ограниченного доступа, denied out-of-scope request, expiry/revoke и соответствующий audit trail.
- `AC-043`: retention preview/apply, protected-audit denial, storage-full fault injection, cleanup и возврат в нормальное состояние.
- `NFR-036`: сопоставление UI error/correlation context с локальными logs/audit без секретов.
- `NFR-037`: raw local timings и context manifest для критических операций; отчёт явно помечает отсутствие утверждённого порога.
- `NFR-038`: keyboard-only recording, focus order/focus return, semantic validation errors и проверка, что состояние не передаётся только цветом.

Каждое evidence привязывается к одному Git SHA, версии контроллера, роли, исходным данным и ожидаемому результату. Непройденный сценарий остаётся открытым; отсутствие записи не считается успехом.

## Non-goals

- Не создавать Pack или Outcome: change должен быть сначала подтверждён человеком.
- Не реализовывать UI, backend, API, update, backup, license или security code.
- Не запускать `/opsx:apply` и не архивировать change.
- Не утверждать visual baseline из draft-источников.
- Не назначать владельцев, сроки, Redmine ID, числовые targets или форматы, которых нет во входном документе.
- Не переносить сюда scope конфигуратора, обычного Room Client, booking, kiosk и pairing.
- Не добавлять облачную зависимость, automatic upload или постоянный Vendor Support.
