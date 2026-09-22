# Tasks: срезы поставки эксплуатационного интерфейса

## Status and gate

- Статус задач: `draft`; это подсказки для будущих delivery slices, а не Pack и не разрешение на реализацию.
- Будущий Outcome: один; идентификатор не присвоен.
- Владельцы: не назначены.
- Redmine: Не создана.
- До передачи в ASE должны быть утверждены блокирующие контракты из `explore.md` и `proposal.md`.
- Каждый пункт закрывается на одном Git SHA наблюдаемым прогоном и указанным evidence. Непройденный negative/recovery path оставляет срез открытым.

## Slice 0: contracts and discovery readiness

- [ ] Зафиксировать утверждённую матрицу `role × action × resource` для IT Admin, Support Operator, Security Auditor и Vendor Support; приложить машинно проверяемые allowed/denied cases для всех routes и commands (`NFR-031`).
- [ ] Зафиксировать backend semantics freshness, correlation context и resumable long-running operation; показать, что refresh UI читает текущую операцию, а не запускает повтор (`NFR-036`).
- [ ] Зафиксировать bundle manifest/redaction policy и подготовить fixture с известными secret/PII markers; ожидаемый результат — каждый marker исключён или замаскирован по утверждённому правилу (`NFR-033`).
- [ ] Зафиксировать update/restore state transitions и failure-injection points; ожидаемый результат — тест может отличить отказ до изменения, rollback success и recovery required (`NFR-034`).
- [ ] Подготовить стенд с заблокированным внешним egress и локальными update, backup, license и diagnostic fixtures (`NFR-035`).
- [ ] Встроить локальный сбор discovery context: build SHA, версия контроллера, роль, браузер, hardware profile, data-set size, начало/конец/результат критического пути; внешняя отправка отсутствует (`NFR-037`).
- [ ] Подготовить keyboard-only test plan для всех P0 routes, включая focus order, dialog focus return, validation focus и non-color semantics (`NFR-038`).
- [ ] Сохранить решение, что отсутствие числового performance target даёт результат «данных недостаточно» или «baseline собран», но не `pass` (`NFR-037`).

## Slice 1: health, triage and diagnostic bundle

### Health dashboard

- [ ] Support Operator открывает health dashboard и видит server, rooms, clients, devices, drivers и scenarios с semantic state, freshness и переходом к деталям; запись экрана и snapshot ответа подтверждают одинаковое состояние (`AC-031`).
- [ ] При частично недоступном Monitoring dashboard маркирует затронутые ветви `stale/unknown`, показывает время последнего подтверждения и не окрашивает их как healthy; fault-injection log прилагается (`AC-031`).
- [ ] Empty fixture без настроенных объектов показывает объяснение и разрешённое следующее действие, а fixture с отказом источника показывает ошибку, не тот же empty state (`AC-031`).

### Triage and logs

- [ ] Support Operator выбирает проблемный компонент и переходит к журналам с сохранёнными object, interval, severity и correlation filters; screen recording и serialized filter state подтверждают перенос контекста (`AC-032`).
- [ ] Пользователь изменяет фильтр, возвращается к health и снова открывает triage; выбор и фильтры сохраняются в текущей сессии, а содержимое журналов перечитывается с сервера (`AC-032`).
- [ ] При ошибке log query UI сохраняет фильтры, показывает отказ источника и не подставляет более широкий неотфильтрованный набор; сетевой ответ и запись UI входят в evidence (`AC-032`).
- [ ] При отсутствии права на выбранный log source прямой route/request получает denied, не раскрывает строки журнала и не меняет фильтры на разрешающие (`AC-032`, `NFR-031`).

### Diagnostic bundle

- [ ] Авторизованный Support Operator выбирает период и компоненты, видит preview manifest, excluded categories и redaction summary, отдельно подтверждает генерацию и получает локальный файл с checksum (`AC-033`).
- [ ] Bundle evidence содержит manifest, server generation log, checksum и privacy-scan report по известным marker values; автоматического upload и внешнего network call нет (`AC-033`, `NFR-033`, `NFR-035`).
- [ ] При недоступном обязательном source UI показывает конкретный incomplete/failure result и не помечает partial file как полный (`AC-033`).
- [ ] При failed redaction/post-generation scan небезопасный файл не предлагается, temporary result удаляется, а UI показывает fail-closed и разрешённый retry (`AC-033`, `NFR-033`).
- [ ] Неавторизованная роль не видит generate action, а прямой request отклоняется сервером без создания temporary bundle (`AC-033`, `NFR-031`).

### Observability evidence

- [ ] Для health/log/bundle error UI показывает user-safe reason, stage, time и correlation context; тот же context найден в server log и audit без secret values (`NFR-036`).
- [ ] При потере одного telemetry source UI показывает gap/freshness, а evidence доказывает отсутствие ложного healthy и ложного complete bundle (`NFR-036`).

## Slice 2: bootstrap, users, TLS, audit and SIEM

### First administrator, network and NTP

- [ ] На чистом uninitialized controller уполномоченный оператор создаёт первого администратора, вводит staged network/NTP settings, проходит проверки и завершает bootstrap только после authoritative success (`AC-034`).
- [ ] Запись bootstrap подтверждает, что пароль не попал в URL, browser storage, client log или evidence payload (`AC-034`, `NFR-031`).
- [ ] При failed network/NTP validation действующая конфигурация остаётся доступной, несекретный draft сохраняется для исправления и второй first-admin record не создаётся (`AC-034`).
- [ ] Повторное открытие прерванного bootstrap продолжает server state; попытка открыть bootstrap на initialized controller отклоняется (`AC-034`, `NFR-031`).

### Users and roles

- [ ] IT Admin создаёт пользователя, выбирает роль из утверждённого каталога, видит effective-permission diff, подтверждает и получает authoritative result с audit context (`AC-035`).
- [ ] IT Admin изменяет и отключает пользователя; evidence показывает before/after state и соответствующие audit events без раскрытия credential (`AC-035`, `NFR-032`).
- [ ] Неутверждённая role combination, stale revision и privilege escalation отклоняются без partial write; UI показывает причину и сохраняет введённые несекретные поля (`AC-035`).
- [ ] Security Auditor и Support Operator не могут изменить пользователя через UI или прямой request; role matrix test фиксирует denied result (`AC-035`, `NFR-031`).

### TLS

- [ ] IT Admin загружает поддерживаемый certificate material, видит результаты parse/key-match/chain/name/expiry checks и активирует только прошедший staged candidate (`AC-036`).
- [ ] После активации UI проверяет новый TLS endpoint и показывает server-confirmed certificate metadata; private key не отображается и очищается из browser state (`AC-036`, `NFR-031`).
- [ ] Invalid, mismatched или expired candidate не заменяет active certificate; evidence содержит прежний fingerprint/metadata до и после отказа (`AC-036`).
- [ ] Проверка transport подтверждает отсутствие authenticated Admin/API traffic по plain HTTP (`NFR-031`).

### Audit and SIEM/syslog

- [ ] Security Auditor фильтрует login, role, TLS, update, restore, license, retention и vendor-access events и видит integrity-verification state без edit/delete controls (`AC-036`, `NFR-032`).
- [ ] Прямые попытки изменить или удалить audit отклоняются сервером и сами создают разрешённое security evidence (`AC-036`, `NFR-032`).
- [ ] Integrity-tamper fixture обнаруживается проверкой и отображается как security failure, а не как пустой журнал (`NFR-032`).
- [ ] IT Admin настраивает разрешённые SIEM/syslog categories, выполняет connection test, отдельно применяет настройку и видит last confirmed delivery/status (`AC-036`).
- [ ] При недоступном SIEM/syslog локальный audit остаётся читаемым, UI показывает delivery gap и не помечает события доставленными; outage recording и local audit extract прилагаются (`AC-036`, `NFR-032`).

## Slice 3: offline update and active-meeting gate

### Offline package preflight

- [ ] IT Admin выбирает локальный update package и до любых изменений видит metadata, patch note и результаты signature/integrity/compatibility/license/storage checks (`AC-037`).
- [ ] Invalid signature, damaged package или incompatible version останавливают поток до restore point и runtime mutation; pre/post version evidence совпадает (`AC-037`).
- [ ] При blocked external egress package preflight, patch note rendering и дальнейший разрешённый update path не обращаются к CDN, cloud API или внешним fonts; network capture прилагается (`NFR-035`).

### Active meeting gate

- [ ] При server-confirmed active meeting UI останавливается после preflight, показывает влияние и безопасное действие «Отложить»; выбор откладывания не создаёт restore point и не меняет runtime (`AC-038`).
- [ ] IT Admin с отдельным правом выбирает продолжение, подтверждает его и проходит повторную server-side meeting/permission check непосредственно перед стартом (`AC-038`).
- [ ] Роль без override permission не видит разрешающего действия, а прямой request получает denied; update не начинается (`AC-038`, `NFR-031`).
- [ ] Если meeting state стал stale или изменился между подтверждением и стартом, сервер останавливает update и UI возвращает пользователя к актуальному gate (`AC-038`).

### Install, self-check and rollback

- [ ] После подтверждённого preflight сервер создаёт проверенный restore point; UI показывает stage progress, затем installed version и health self-check (`AC-037`).
- [ ] Refresh браузера во время установки восстанавливает текущую server operation; повторное действие не создаёт параллельный update (`AC-037`, `NFR-036`).
- [ ] Injected install/self-check failure запускает rollback; UI показывает rolling back, затем фактическую restored version, health и audit result (`AC-037`, `NFR-034`).
- [ ] Injected rollback failure не показывает success, переводит систему в recovery required/Safe Mode и сохраняет logs/correlation context (`AC-037`, `NFR-034`, `NFR-036`).
- [ ] Evidence update-среза включает package checksum, patch note snapshot, restore-point verification, operation log, pre/install/restored versions, health result, audit trail и blocked-egress capture (`AC-037`, `NFR-034`, `NFR-035`).

## Slice 4: backup, restore and Safe Mode

### Backup and replacement controller

- [ ] IT Admin создаёт backup и видит scope, source version, created time, compatibility metadata, checksum и server verification result (`AC-039`).
- [ ] Повреждённый backup не получает verified state и не предлагается для restore; evidence содержит failed integrity result (`AC-039`).
- [ ] На совместимом replacement controller IT Admin читает metadata, проходит compatibility preflight, видит included/excluded categories, подтверждает restore и после self-check получает restored versions/health (`AC-039`).
- [ ] После restore fixture подтверждает восстановление предусмотренных объектов без ручной донастройки каждого объекта; исключённые identity/network/secret categories совпадают с утверждённым contract (`AC-039`).
- [ ] Несовместимый backup отклоняется до mutation с конкретными incompatibilities; current controller state и configuration hash остаются прежними (`AC-039`, `NFR-034`).
- [ ] Injected failure после начала restore возвращает pre-restore state либо переводит систему в Safe Mode; partial-success state отсутствует (`AC-039`, `NFR-034`).

### Safe Mode

- [ ] Fault injection повторных критических стартов переводит сервер в Safe Mode; Admin Web UI показывает persistent reason, versions, last-known-good, logs/crash dump и только разрешённые restore/rollback actions (`AC-040`).
- [ ] Одновременно Room Client показывает понятную заглушку без tags, drivers, protocols, stack traces и equipment controls (`AC-040`).
- [ ] Неавторизованная роль и прямой URL не открывают recovery actions, хотя безопасная status page остаётся в пределах утверждённой матрицы (`AC-040`, `NFR-031`).
- [ ] Успешный restore/rollback подтверждает normal mode и health; Room Client выполняет resync и возвращает controls только после server confirmation (`AC-040`, `NFR-034`).
- [ ] Failed recovery оставляет Safe Mode, показывает recovery required и correlation context и не сообщает пользователю о возврате в normal mode (`AC-040`, `NFR-034`, `NFR-036`).

## Slice 5: license, temporary vendor access and storage

### License states and limits

- [ ] IT Admin видит server-provided license status, effective limit, current usage, expiration/remaining emulator time при наличии, affected actions и active-runtime behavior (`AC-041`).
- [ ] При limit exceeded запрещённый новый deploy/expansion получает server denial с usage/limit и путём решения, а active runtime health остаётся рабочим (`AC-041`).
- [ ] При invalid/expired state UI показывает ограниченный режим и разрешённые действия без коммерческого checkout или ложного online renewal (`AC-041`, `NFR-035`).
- [ ] Invalid offline license file не заменяет действующую license state; pre/post metadata и audit result входят в evidence (`AC-041`).

### Temporary Vendor Support

- [ ] IT Admin выбирает Vendor Support principal/invitation method, resources, actions, duration и reason, видит effective scope и отдельно подтверждает выдачу (`AC-042`).
- [ ] Активный доступ показывает scope, expiry, activity и revoke action; Vendor Support выполняет только разрешённое действие, которое появляется в audit (`AC-042`, `NFR-032`).
- [ ] Out-of-scope route/command и попытка сделать доступ постоянным отклоняются сервером и видны IT Admin/Security Auditor в разрешённом audit view (`AC-042`, `NFR-031`, `NFR-032`).
- [ ] Expiry и ручной revoke прекращают дальнейшие actions и активную session согласно утверждённому contract; повторный request получает denied (`AC-042`).
- [ ] При blocked external endpoint локальные admin, audit и recovery функции продолжают работать; vendor integration не становится обязательной облачной зависимостью (`AC-042`, `NFR-035`).

### Retention and storage full

- [ ] IT Admin видит текущие retention settings по разрешённым категориям, storage usage и protected data, вводит допустимое значение и получает cleanup-impact preview до подтверждения (`AC-043`).
- [ ] После применения server returns effective policy и audit result; повторное открытие показывает authoritative value, а не browser draft (`AC-043`).
- [ ] Значение вне утверждённого диапазона отклоняется без изменения policy; введённое значение остаётся доступным для исправления (`AC-043`).
- [ ] Попытка удалить protected audit обычной cleanup-командой отклоняется сервером; audit integrity/readability сохраняются (`AC-043`, `NFR-032`).
- [ ] Storage-full fault injection показывает persistent warning, блокирует небезопасные noncritical writes, сохраняет protected data и предлагает разрешённый cleanup path (`AC-043`).
- [ ] После cleanup UI повторно проверяет storage и writers, затем снимает warning только при authoritative recovery; usage snapshots и operation log входят в evidence (`AC-043`, `NFR-034`, `NFR-036`).

## Slice 6: cross-cutting non-functional verification

### Authentication, RBAC and TLS

- [ ] Для каждого Admin route unauthenticated/expired session не получает operational data и направляется в утверждённый auth flow; server response прилагается (`NFR-031`).
- [ ] Для каждой роли automated matrix выполняет allowed и denied direct requests; скрытие control без server denial считается провалом (`NFR-031`).
- [ ] TLS scan и network capture подтверждают защищённый transport для Admin/API и отсутствие fallback на plain HTTP (`NFR-031`).

### Tamper-evident audit

- [ ] Нормальные критические действия создают audit records с actor, role, target, action, result, time и correlation в утверждённом объёме (`NFR-032`).
- [ ] Mutation/tamper fixture обнаруживается integrity verification; UI показывает failure, а роли change не могут исправить или удалить запись (`NFR-032`).

### Bundle privacy

- [ ] Privacy fixture содержит известные password/token/private-key/PII markers; итоговый bundle scan не находит запрещённые raw values и сопоставляется с redaction report (`NFR-033`).
- [ ] Unknown/unredactable mandatory source вызывает fail-closed, отсутствие downloadable file и очистку temporary data (`NFR-033`).

### Recovery and rollback

- [ ] Update, restore и storage-recovery fault tests фиксируют pre-state, failure stage, recovery transition, final version/health и audit result (`NFR-034`).
- [ ] Failed automatic recovery приводит к Safe Mode/recovery required без partial-success label (`NFR-034`).

### Offline without mandatory cloud

- [ ] При заблокированном internet egress выполняются health, triage, bundle generation, bootstrap, user/TLS administration, update from local package, backup/restore, license view и retention (`NFR-035`).
- [ ] Network capture не содержит CDN, external fonts, cloud telemetry, update download или automatic bundle upload; только явно настроенная optional integration может инициировать разрешённый endpoint call (`NFR-035`).

### Observability

- [ ] Для каждого injected error UI result связан correlation context с operation log и audit event, при этом секреты и raw private data отсутствуют (`NFR-036`).
- [ ] Stale, partial, denied и failed states различимы и не сводятся к empty/success (`NFR-036`).

### Performance discovery

- [ ] На согласованном candidate hardware/data/browser context собрать raw timings первого полезного health render, object drill-down, log-filter apply, bundle preview, update preflight, backup metadata read и Safe Mode view (`NFR-037`).
- [ ] Discovery report перечисляет context, samples, failures и data gaps, но не объявляет performance `pass` без утверждённого target (`NFR-037`).
- [ ] Повторить измерение при выбранных малом и большом наборах health/log fixtures; конкретные размеры утверждаются владельцем до выполнения и сохраняются в fixture manifest (`NFR-037`).

### Keyboard, focus and accessibility

- [ ] Keyboard-only пользователь проходит health → triage → logs → bundle preview, user/role review, update preflight, backup restore preflight и Safe Mode recovery без мыши (`NFR-038`).
- [ ] Tab/Shift+Tab дают предсказуемый focus order, Enter/Space активируют controls, Escape закрывает допустимые overlays, а закрытие dialog/drawer возвращает focus инициатору (`NFR-038`).
- [ ] Validation error получает связанный текст и focus/announcement; warning/error/success/selected states сохраняют смысл без использования одного цвета (`NFR-038`).
- [ ] Ни один modal/drawer не оставляет focus trap после закрытия и не позволяет фокусу уйти в недоступный background во время открытия (`NFR-038`).

## Slice 7: evidence assembly and release decision inputs

- [ ] Для `AC-031`…`AC-043` и `NFR-031`…`NFR-038` приложить минимум один main и один error/forbidden/recovery run на одном SHA.
- [ ] Для каждого run сохранить actor role, preconditions, fixture manifest, exact action, observed result, expected result, timestamp, build/controller versions и verdict.
- [ ] Для security/privacy/recovery требований приложить cross-layer proof: UI recording плюс server response/log/audit/file scan, а не только screenshot.
- [ ] Для offline требования приложить blocked-egress configuration и network capture.
- [ ] Для discovery приложить raw local measurements и context manifest без придуманного target.
- [ ] Для accessibility приложить keyboard recording и focus/semantic inspection.
- [ ] Все failed runs оставить видимыми и связать с defect или открытым решением; удаление неудобного результата запрещено.
- [ ] До передачи в Ready Review назначить владельцев, создать Redmine, утвердить baseline/target/sample/window, rollout/rollback и закрыть продуктовые блокеры.
- [ ] Не создавать Pack из этого draft до отдельного подтверждения change человеком.
