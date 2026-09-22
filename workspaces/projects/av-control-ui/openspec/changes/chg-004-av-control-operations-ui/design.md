# Design: эксплуатационный интерфейс AV Control

## Status

Проектное решение имеет статус `draft`. Оно описывает поведение UI и проверяемые границы, но не утверждает API, форматы файлов, криптографические алгоритмы, числовые пороги или visual baseline. Все владельцы не назначены; Redmine — Не создана.

## Approach

Эксплуатационные функции размещаются в одной ролевой области Admin Web UI. UI использует сервер как единственный source of truth и разделяет четыре типа взаимодействия:

1. **Read model** — снимок состояния с ревизией, временем наблюдения и признаком freshness.
2. **Command** — явное действие авторизованной роли над конкретным ресурсом.
3. **Long-running operation** — update, bundle, backup, restore, cleanup и recovery с видимыми стадиями, correlation context и итоговой проверкой.
4. **Recovery decision** — остановка, retry, rollback, restore или переход в Safe Mode, когда обычный успех невозможен.

UI не выводит успех из факта нажатия кнопки или завершения HTTP-запроса. Успех показывается только после получения подтверждённого итогового состояния от соответствующего сервиса.

## System boundaries

- Admin Web UI отображает состояние, собирает подтверждение пользователя, отправляет разрешённую команду и показывает progress/result.
- Сервер выполняет аутентификацию, RBAC, валидацию, атомарность, аудит и фактическое действие.
- Monitoring предоставляет health, logs, freshness и данные для bundle.
- Security предоставляет identity, effective permissions, TLS, audit integrity и временный доступ.
- Update service проверяет локальный пакет, создаёт restore point, устанавливает, выполняет self-check и rollback.
- Backup/storage service создаёт и проверяет backup, выполняет compatibility preflight, restore, retention и cleanup.
- License service возвращает authoritative license state, usage и limit.
- Room/session service возвращает authoritative active-meeting state.
- Room Client принимает только серверный режим `Safe Mode`/обычный режим и выполняет resync после восстановления.

UI не реализует резервные локальные версии этих источников и не принимает критическое решение по stale cache.

## Information model

### Common state

Каждый эксплуатационный read model должен давать UI достаточно сведений, чтобы показать:

- объект и его человекочитаемое имя;
- тип объекта и родительский контекст;
- текущее semantic state;
- время последнего подтверждённого наблюдения;
- freshness или явный признак stale/unknown;
- версию или ревизию, если она влияет на решение;
- разрешённые текущей роли actions, полученные от сервера;
- correlation context для перехода к журналам;
- причину и recovery action при ошибке без раскрытия секрета.

Точные имена API-полей не задаются этим change. Отсутствие любого обязательного смысла считается gap контракта, а не поводом вычислить значение в браузере.

### Long-running operation state

Для bundle, update, backup, restore, cleanup и Safe Mode recovery UI различает как минимум:

- подготовку и проверку входа;
- готовность к отдельному подтверждению;
- выполнение с названием текущей стадии;
- итоговую проверку;
- подтверждённый успех;
- отказ до изменения;
- отказ после изменения;
- rollback в процессе;
- подтверждённый rollback;
- recovery required, когда автоматическое восстановление не завершилось.

Повторное открытие страницы читает серверное состояние операции. Перезагрузка браузера не должна запускать операцию повторно или превращать неизвестный итог в успех.

### Sensitive data

- Пароль, private key, license secret, service credential и известные секреты из логов не возвращаются в UI после отправки.
- UI не сохраняет чувствительные поля в URL, browser history, analytics payload или долговременный client storage.
- Bundle manifest перечисляет категории и исключения, но не показывает замаскированные значения.
- Audit view показывает разрешённые атрибуты события и результат integrity verification, но не предоставляет mutation controls.

## Role and authorization design

Навигация скрывает недоступные разделы для снижения ошибок, но безопасность обеспечивается серверным deny-by-default:

- IT Admin видит только подтверждённые матрицей administrative actions.
- Support Operator видит health, logs, triage и разрешённую подготовку bundle; update, role changes, TLS и unrestricted restore не выводятся без отдельного права.
- Security Auditor получает read-only audit и разрешённые фильтры/экспорт; команды изменения отсутствуют и отклоняются сервером при прямом запросе.
- Vendor Support видит только ресурсы и действия активной временной сессии.
- End User не получает Admin routes; в Safe Mode Room Client показывает только пользовательскую заглушку.

До утверждения role matrix UI проектируется по принципу минимальных прав. Неизвестное право трактуется как denied, а не как разрешённое.

## Health and triage design

### Health dashboard

Dashboard показывает одну иерархию: контроллер → комнаты → клиенты/устройства/драйверы/сценарии. Для каждого уровня доступны:

- суммарное semantic state;
- число и тип проблем без ложного объединения `unknown` со `healthy`;
- freshness;
- версия для диагностируемых software-компонентов;
- переход к деталям и связанным событиям;
- явное degraded state, если источник Monitoring доступен частично.

Сортировка выводит критические и неизвестные состояния перед штатными, но не меняет серверный severity. Empty state различает «объекты не настроены» и «данные не получены».

### Triage and logs

Переход из health в logs переносит контекст объекта, временной интервал вокруг события, severity и correlation context. Пользователь может сузить или сбросить каждый фильтр и видит активные фильтры отдельными controls.

Состояния различаются:

- событий действительно нет;
- источник не ответил;
- запрос отклонён;
- часть источников недоступна;
- доступ запрещён;
- результат усечён политикой.

Возврат к health сохраняет выбранный объект и фильтры в рамках текущей пользовательской сессии, но не сохраняет содержимое журналов как source of truth.

## Diagnostic bundle design

Bundle использует двухфазный поток:

1. Пользователь задаёт разрешённый период и компоненты.
2. UI получает preview manifest: включённые категории, исключённые категории, применённые правила redaction и оценку доступности источников.
3. Пользователь отдельно подтверждает локальное формирование.
4. Сервер собирает данные, применяет privacy policy, выполняет внутреннюю проверку и только затем публикует локальный результат.
5. UI показывает итог, manifest, redaction summary, размер, checksum и локальное действие получения файла.

Автоматическая отправка Vendor Support отсутствует. Передача выполняется отдельным явным процессом, который не входит в change.

Если обязательный источник не очищен, privacy policy неизвестна или post-generation scan обнаруживает запрещённое значение, UI показывает fail-closed result. Небезопасный файл не предлагается пользователю; временные материалы удаляются сервером по утверждённой политике.

## Bootstrap, network and NTP design

Неинициализированный контроллер открывает только bootstrap flow. Основание доступа выдаёт сервер; точная trust model остаётся блокером.

Порядок:

1. Проверить, что контроллер действительно в состоянии первичной инициализации.
2. Создать первого администратора с политикой, полученной от сервера.
3. Ввести network и NTP settings в staged state.
4. Выполнить серверные проверки формата, конфликта, связности и NTP.
5. Показать результат каждой проверки и будущий адрес доступа.
6. Запросить явное подтверждение применения.
7. После применения проверить доступность и authoritative time state.
8. Завершить bootstrap только после подтверждённого результата.

При неуспешной проверке действующая сеть не заменяется, введённые несекретные значения сохраняются для исправления, а first-admin record не дублируется. При прерывании после создания администратора повторный вход продолжает серверное состояние процесса, а не создаёт второго администратора.

## Users and roles design

Экран пользователей показывает status, назначенные роли и effective permissions summary. Изменение выполняется как reviewable transaction:

1. выбрать существующего пользователя или создать нового;
2. выбрать только роли из серверного каталога;
3. увидеть добавляемые и удаляемые effective permissions;
4. подтвердить изменение;
5. получить authoritative result и ссылку на audit context.

Неизвестная комбинация, privilege escalation без права, попытка обойти UI прямым запросом или изменение уже устаревшей ревизии отклоняются без частичной записи. Политика последнего доступного администратора должна быть определена Security Owner; до решения UI не заявляет возможность его удаления.

## TLS, audit and SIEM design

### TLS

Новый сертификат и связанные чувствительные данные проходят staged validation до активации:

- parse и поддерживаемый формат;
- соответствие certificate/private key без отображения private key;
- цепочка доверия;
- срок действия;
- имена, необходимые для доступного адреса;
- возможность безопасно сохранить текущую конфигурацию до подтверждения.

Invalid certificate не заменяет активный. UI заранее показывает server-provided expiration warning, а после активации проверяет новый TLS endpoint. Точный emergency recovery при истёкшем сертификате остаётся блокером.

### Audit

Audit view:

- read-only для всех ролей этого change;
- фильтрует входы, изменения ролей, TLS, update, restore, license, retention, vendor access и security events;
- показывает actor, role, target, action, result, time, correlation и integrity-verification state в разрешённом объёме;
- не содержит edit/delete actions;
- отличает отсутствие событий от отказа чтения и integrity failure.

### SIEM/syslog

IT Admin выбирает разрешённые категории, вводит endpoint settings, запускает connection test и отдельно применяет настройку. Security Auditor видит read-only delivery status, если это разрешено матрицей.

При недоступности получателя локальный audit остаётся доступным. UI показывает last confirmed delivery, backlog/gap state и причину без раскрытия credential. Политика очереди, retry и потери остаётся частью блокирующего backend contract.

## Offline update design

Поток update:

1. IT Admin выбирает локальный package file.
2. UI показывает metadata и полный доступный patch note.
3. Сервер проверяет signature, integrity, compatibility, license и свободное storage.
4. UI повторно читает authoritative active-meeting state.
5. При активной встрече включается отдельный meeting gate из `AC-038`.
6. После подтверждения сервер создаёт и проверяет restore point.
7. Установка показывает текущую стадию, но не предлагает закрывать/retry до серверного результата.
8. После установки сервер выполняет self-check и возвращает фактическую версию/health.
9. При отказе сервер начинает rollback; UI различает rollback in progress, rolled back и recovery required.
10. Итог содержит installed/restored version, health result, audit context и доступ к релевантным logs.

Package verification failure не создаёт restore point и не меняет runtime. Browser refresh возвращает текущую серверную операцию. Повторное нажатие не создаёт параллельную установку.

## Active meeting gate design

Gate появляется между успешным preflight и созданием restore point:

- показывает, что встреча активна, какие room/session данные разрешено раскрыть и почему update может прервать работу;
- основное безопасное действие — отложить;
- продолжение доступно только при отдельном effective permission;
- продолжение требует отдельного подтверждения непосредственно перед стартом;
- перед стартом сервер повторно проверяет встречу и право.

Отсутствие права, stale meeting state или новый конфликт останавливают update. Закрытие предупреждения и выбор «Отложить» не создают restore point и не меняют систему.

## Backup and restore design

### Backup

UI показывает scope, source version, created time, verification result, compatibility metadata и checksum. Backup получает статус «проверен» только после серверной проверки читаемости и состава.

### Restore

Restore использует staged flow:

1. выбрать локальный или серверный backup;
2. прочитать metadata без применения;
3. выполнить integrity и compatibility preflight;
4. показать, что будет восстановлено, сохранено и исключено;
5. определить текущий или replacement controller context;
6. создать pre-restore recovery point, если это поддерживается утверждённым контрактом;
7. отдельно подтвердить restore;
8. применить атомарно;
9. проверить версии, health и доступность Admin Web UI;
10. показать success только после self-check.

Повреждённый или несовместимый backup не применяется частично. Если apply начался и завершился ошибкой, система возвращает pre-restore state либо входит в Safe Mode с явным recovery required. Состав секретов, сертификатов, сети и device identity остаётся блокирующим решением и всегда показывается в preflight.

## Safe Mode design

Safe Mode использует отдельную ограниченную композицию Admin Web UI:

- заметный persistent banner и причина входа;
- server/runtime version, last-known-good и доступная recovery source;
- разрешённые logs/crash dump;
- restore и rollback только при соответствующем праве;
- progress, result и integrity/self-check;
- отсутствие project editing, runtime control и обычных destructive actions.

Room Client одновременно показывает пользовательский stub: система временно недоступна, управление заблокировано, доступен утверждённый путь обращения. Техническая причина, stack trace, driver/tag/protocol и recovery controls не показываются.

После успешного recovery сервер подтверждает normal mode и health. Admin Web UI показывает результат, Room Client выполняет resync и только затем возвращает controls. Failed recovery оставляет Safe Mode и не показывает ложный success.

## License design

License screen отображает только authoritative server state:

- понятный status;
- effective limit;
- current usage;
- expiration или remaining emulator time, если применимо;
- affected actions;
- active-runtime behavior;
- локальное действие применения нового license file, если разрешено;
- путь поддержки без коммерческого checkout.

При limit exceeded новый deploy/расширение блокируется сервером, а active runtime продолжает работу согласно входному документу. Invalid license file не заменяет действующую лицензию. Точные states и grace behavior остаются блокером; UI не придумывает их.

## Temporary vendor access design

IT Admin перед выдачей видит:

- целевого Vendor Support principal или утверждённый способ приглашения;
- разрешённые resources;
- разрешённые actions;
- срок действия;
- reason;
- итоговый effective scope.

После подтверждения UI показывает активную сессию, expiry, scope, activity status и revoke action. Vendor Support не может выйти за scope, продлить доступ или сделать его постоянным. Expiry и revoke прекращают дальнейшие действия и инвалидируют доступ согласно серверному контракту. Выдача, вход, разрешённые/запрещённые действия, истечение и отзыв пишутся в tamper-evident audit.

## Retention and storage-full design

Retention screen показывает текущую политику отдельно для logs, dumps и других разрешённых категорий, текущий usage, ожидаемый эффект изменения и protected data. Audit retention меняется только если это явно допускает утверждённая политика; обычная cleanup-команда не удаляет обязательный audit.

Изменение политики:

1. IT Admin вводит значение в разрешённом сервером диапазоне.
2. UI показывает validation и preview затрагиваемых категорий.
3. Пользователь подтверждает.
4. Сервер применяет policy и возвращает audit result.

При storage pressure/full:

- dashboard и navigation показывают persistent warning;
- UI называет заполненное хранилище и защищённые/остановленные категории;
- некритические операции, которые не могут безопасно записать результат, блокируются;
- IT Admin получает cleanup preview и разрешённые действия;
- Security Auditor продолжает читать доступный audit;
- success показывается после освобождения storage и повторной проверки writers.

Приоритет удаления и числовые thresholds не задаются до решения владельца.

## Non-functional constraints

### Security

- Любой Admin route требует authenticated session.
- Любая команда повторно проверяется серверным RBAC.
- Plain HTTP не используется для authenticated Admin/API traffic.
- UI не является единственной enforcement boundary.
- Audit integrity failure отображается как security state, а не как пустой журнал.

### Privacy

- Bundle создаётся по allowlist категорий и redaction policy.
- Discovery и observability не содержат secrets, private keys, password fields или raw meeting data.
- Vendor access не включается автоматически вместе с bundle.

### Offline-first

- Static assets, fonts, help text, patch note rendering и workflows доступны без внешнего интернета.
- Offline package/license/backup выбираются локально.
- SIEM и Vendor Support остаются optional explicit integrations; их отсутствие не ломает локальное администрирование.

### Recovery

- Update/restore не имеют partial-success UI.
- Rollback подтверждается версией, health и audit result.
- Failed rollback приводит к recovery required/Safe Mode.
- UI reconnect читает операцию с сервера и не повторяет command автоматически.

### Observability

- Каждая ошибка long-running operation содержит user-safe reason, stage, time и correlation context.
- Инженерная роль может перейти к связанным logs в пределах RBAC.
- Health всегда показывает freshness и gaps.
- Один correlation context связывает UI result, operation log и audit event без включения секрета.

### Performance discovery

Инструментируются локальные точки: первый полезный health render, переход к деталям, применение log filters, получение bundle preview, update preflight, backup metadata read и Safe Mode view. Запись содержит hardware/browser/build/data-size context и сырой результат. До утверждения target отчёт использует формулировку «baseline collected» или «data insufficient», но не `pass`.

### Accessibility

- Все P0 Admin actions достижимы Tab/Shift+Tab и активируются стандартными клавишами.
- Focus видим во всех semantic states.
- Dialog/drawer удерживает focus только пока открыт и возвращает его к инициатору после закрытия.
- Validation error связывается с полем и получает focus/announcement.
- Progress, warning, error и success имеют текст/семантику и не кодируются только цветом.
- Точный WCAG level и обязательный screen reader matrix остаются блокером.

## Recovery matrix

- Monitoring stale/unavailable: сохранить last confirmed state с маркировкой stale, запретить ложный healthy, предложить retry.
- Log query failed: сохранить filters/context, показать отказ источника, не подставлять широкий неотфильтрованный результат.
- Bundle privacy failed: не публиковать файл, удалить temporary result, показать источник и retry после исправления policy/source.
- Network/NTP check failed: оставить действующую конфигурацию, сохранить несекретный draft, дать повторную проверку.
- TLS validation failed: сохранить active certificate, очистить чувствительные поля браузера, показать конкретную проверку.
- SIEM unavailable: сохранить local audit, показать delivery gap, не заявлять доставку.
- Update verification failed: не менять runtime и не создавать установочную операцию.
- Update failed: выполнить rollback; подтвердить restored version/health.
- Rollback failed: перейти в Safe Mode/recovery required.
- Backup incompatible/corrupt: не применять, оставить current state.
- Restore failed: восстановить pre-restore state либо остаться в Safe Mode.
- License import failed: сохранить действующую license state.
- Vendor access expired/revoked: отклонить дальнейшие действия и показать состояние IT Admin.
- Storage full: остановить небезопасные некритические writes, сохранить защищённые данные, выполнить контролируемую cleanup.

## Evidence design

Evidence планируется, но не создаётся этим change. Для будущего выполнения:

- Все записи выполняются на одном Git SHA и содержат версию server/UI, роль, браузер, hardware context и fixture manifest.
- Main и negative/recovery scenario каждого requirement записываются отдельно.
- UI recording сопровождается server log/audit/result там, где UI не доказывает enforcement.
- Security evidence включает прямые denied requests, TLS scan и audit tamper test.
- Privacy evidence включает fixture с известными marker values и machine-readable scan результата bundle.
- Recovery evidence включает injected failure, pre-state, transition, returned version/health и отсутствие partial state.
- Offline evidence включает blocked egress и network capture.
- Accessibility evidence включает keyboard recording, focus trace и semantic inspection.
- Performance evidence сохраняет raw samples и context; итог не содержит выдуманного target.
- Непройденный прогон содержит observed result и ссылку на defect/open decision; его нельзя исключить из отчёта без объяснения.

## Dependencies and compatibility

- Foundation change должен определить общую shell/navigation/auth/focus/error grammar. Этот design не дублирует её.
- Backend contracts должны поддерживать authoritative permissions, operation resume, freshness, correlation и atomic recovery.
- Совместимость update/backup/license определяется server metadata, а не расширением файла или догадкой UI.
- Replacement controller должен пройти минимальную bootstrap-подготовку, необходимую для доступа к restore; точный boundary остаётся блокером.
- Поддерживаемые browser/OS/hardware не утверждены, поэтому compatibility claim отсутствует.
- RU/EN тексты и форматирование наследуются от foundation; критический смысл не должен обрезаться.

## Risks and mitigations

- Слишком много функций в одном экране: разделить dashboard, security administration, maintenance и storage на отдельные routes внутри одной operations surface, сохранив общий контекст.
- Смешение Support и IT прав: строить actions из effective permissions и проверять прямые запросы.
- Потеря состояния при refresh: long-running operation всегда перечитывается с сервера.
- Секреты в diagnostics/telemetry: использовать allowlist, redaction, marker fixtures и fail-closed.
- Деструктивное действие во время встречи: authoritative meeting gate перед restore point.
- Непроверенное восстановление: показывать success только после version/health self-check.
- Невозможность назначить числовой target: выполнить discovery, сохранить raw context и оставить Ready заблокированным до решения владельца.

## Deferred decisions

До подтверждения change остаются неутверждёнными role matrix, API fields, file formats, trust roots, bundle policy, SIEM transport, Safe Mode threshold, license states, vendor-session mechanism, retention thresholds, hardware/browser matrix, WCAG level, metrics target/window и rollout ownership. Реализация не должна выбирать эти значения молча.

## No hidden scope

Design не включает код, schema миграции, endpoint design, cloud services, package/backup format, cryptographic algorithm, обычный Room Client, configurator, kiosk, booking, billing или hardware changes. Добавление любого из этих пунктов потребует отдельного подтверждения определения, а не расширения задачи реализации.
