# Delta for operations-ui

## ADDED Requirements

### Requirement: AC-031 Сводная health-картина
The system SHALL показывать авторизованному Support Operator актуальную health-картину контроллера, комнат, клиентов, устройств, драйверов и сценариев с состоянием, свежестью данных и переходом к проблемному объекту.

#### Scenario: Основной путь от сводки к объекту
- **GIVEN** Support Operator авторизован, Monitoring вернул актуальные состояния нескольких комнат и одна ветвь имеет ошибку
- **WHEN** пользователь открывает health dashboard и выбирает проблемную ветвь
- **THEN** UI показывает иерархию объектов, semantic state и время последнего подтверждённого наблюдения
- **AND** открывает детали выбранного объекта с тем же состоянием и доступным переходом к triage
- **AND** состояния `unknown` и `stale` не отображаются как healthy

#### Scenario: Частично недоступный Monitoring
- **GIVEN** часть health-источников недоступна, но существует последнее подтверждённое состояние
- **WHEN** Support Operator открывает dashboard или обновляет данные
- **THEN** затронутые ветви помечаются как stale/unknown с временем последнего подтверждения и причиной недоступности
- **AND** незатронутые ветви остаются доступными с собственной свежестью
- **AND** UI не показывает общую ложную готовность и не скрывает разрыв данных

#### Scenario: Пустая конфигурация отличается от ошибки
- **GIVEN** контроллер доступен, но комнаты и диагностируемые объекты ещё не настроены
- **WHEN** Support Operator открывает health dashboard
- **THEN** UI показывает empty state с объяснением отсутствия объектов
- **AND** этот state визуально и семантически отличается от отказа Monitoring

### Requirement: AC-032 Контекстный triage и фильтры журналов
The system SHALL переносить из health в журналы контекст выбранного объекта, интервал, severity и correlation context, позволять явно изменять фильтры и сохранять их при ошибке или возврате.

#### Scenario: Основной triage от объекта к журналам
- **GIVEN** Support Operator открыл детали компонента с ошибкой и имеет право читать связанные события
- **WHEN** пользователь выбирает действие перехода к журналам
- **THEN** UI открывает журнал с активными object, interval, severity и correlation filters
- **AND** каждый фильтр виден отдельным control и может быть изменён или сброшен
- **AND** возврат к health сохраняет выбранный объект и фильтры текущей сессии

#### Scenario: Ошибка запроса журналов
- **GIVEN** фильтры заданы, но log source отклоняет запрос или недоступен
- **WHEN** UI получает отказ
- **THEN** пользователь видит конкретный error state и разрешённый retry
- **AND** выбранные фильтры и объект сохраняются
- **AND** UI не подставляет более широкий неотфильтрованный набор и не показывает пустой результат как успешный

#### Scenario: Запрещённый источник журналов
- **GIVEN** роль пользователя не разрешает чтение выбранной категории журналов
- **WHEN** пользователь переходит по прямому адресу или отправляет запрос с сохранённым фильтром
- **THEN** сервер отклоняет чтение, а UI показывает permission-denied без содержимого событий
- **AND** запрещённые строки, поля и объекты не появляются в клиентском состоянии

### Requirement: AC-033 Локальный diagnostic bundle
The system SHALL позволять авторизованной роли просмотреть manifest и privacy-обработку, отдельно подтвердить локальное формирование diagnostic bundle и получить файл только после успешной проверки состава.

#### Scenario: Основное формирование bundle
- **GIVEN** Support Operator имеет право формирования, выбрал период и компоненты, а все обязательные источники доступны
- **WHEN** пользователь просматривает manifest и redaction summary и подтверждает формирование
- **THEN** UI показывает стадии локальной сборки и после проверки предоставляет файл с checksum
- **AND** рядом доступны итоговый manifest, исключённые категории и результат privacy-проверки
- **AND** файл не отправляется Vendor Support или во внешний сервис автоматически

#### Scenario: Privacy-проверка не пройдена
- **GIVEN** обязательный источник не может быть очищен либо post-generation scan обнаружил запрещённое значение
- **WHEN** сервис завершает проверку результата
- **THEN** UI показывает fail-closed result с причиной и разрешённым повтором
- **AND** небезопасный или неполный файл не предлагается для получения
- **AND** временный результат удаляется согласно утверждённой политике

#### Scenario: Формирование запрещено роли
- **GIVEN** пользователь может видеть ограниченную health-картину, но не имеет права создавать bundle
- **WHEN** он открывает прямой route или отправляет generate command
- **THEN** сервер возвращает permission-denied и UI не запускает сборку
- **AND** temporary bundle, manifest и downloadable file не создаются

### Requirement: AC-034 Первый администратор, сеть и NTP
The system SHALL проводить уполномоченного оператора неинициализированного контроллера через создание первого администратора, staged-настройку сети и NTP, проверку и подтверждённое завершение без потери доступной конфигурации при ошибке.

#### Scenario: Успешная первичная настройка
- **GIVEN** контроллер находится в подтверждённом сервером состоянии первичной инициализации, а оператор имеет допустимое основание доступа
- **WHEN** оператор создаёт первого администратора, вводит network/NTP settings, проходит проверки и подтверждает применение
- **THEN** сервер создаёт одну административную учётную запись и применяет проверенные настройки
- **AND** UI показывает новый адрес доступа, authoritative time state и завершение bootstrap только после итоговой проверки
- **AND** пароль и другие чувствительные значения не возвращаются в UI после отправки

#### Scenario: Проверка сети или NTP не пройдена
- **GIVEN** первый администратор уже создан в текущем bootstrap, но новые network/NTP settings не проходят проверку
- **WHEN** оператор пытается применить настройки
- **THEN** UI показывает результат каждой неуспешной проверки и оставляет несекретные значения для исправления
- **AND** действующая доступная network configuration не заменяется
- **AND** вторая учётная запись первого администратора не создаётся

#### Scenario: Повторный вход в прерванный bootstrap
- **GIVEN** bootstrap был прерван после сохранённого сервером шага
- **WHEN** оператор повторно открывает flow
- **THEN** UI продолжает подтверждённое сервером состояние и не повторяет уже завершённое действие
- **AND** на полностью initialized controller прямой bootstrap route отклоняется

### Requirement: AC-035 Управление пользователями и ролями
The system SHALL позволять IT Admin создавать, изменять и отключать пользователей, назначать только утверждённые роли и до подтверждения показывать изменение effective permissions.

#### Scenario: Разрешённое назначение роли
- **GIVEN** IT Admin авторизован, пользователь существует или введены данные нового пользователя, а роль присутствует в утверждённом серверном каталоге
- **WHEN** администратор просматривает effective-permission diff и подтверждает изменение
- **THEN** сервер применяет изменение целиком и UI показывает authoritative пользователя и роли
- **AND** UI показывает correlation context соответствующего audit event

#### Scenario: Запрещённая комбинация или повышение привилегий
- **GIVEN** выбранная комбинация ролей не утверждена либо действующая роль не вправе её назначать
- **WHEN** пользователь подтверждает форму или отправляет прямой request
- **THEN** сервер отклоняет действие без partial write
- **AND** UI показывает permission/validation reason и сохраняет несекретные введённые данные для исправления
- **AND** effective permissions не расширяются

#### Scenario: Конфликт ревизии
- **GIVEN** карточка пользователя была изменена другой административной сессией после открытия формы
- **WHEN** IT Admin сохраняет устаревшую ревизию
- **THEN** UI показывает конфликт и актуальное серверное состояние
- **AND** устаревшие роли не перезаписывают новые молча

### Requirement: AC-036 TLS, read-only аудит и SIEM/syslog
The system SHALL предоставлять IT Admin staged-управление TLS и настройкой SIEM/syslog, а Security Auditor — read-only просмотр и фильтрацию аудита с видимым состоянием целостности и доставки.

#### Scenario: Успешная активация TLS-сертификата
- **GIVEN** IT Admin выбрал поддерживаемый certificate material, а действующий сертификат продолжает обслуживать Admin Web UI
- **WHEN** сервер подтверждает parse, key match, chain, name и expiry checks и администратор активирует candidate
- **THEN** UI проверяет доступность нового TLS endpoint и показывает authoritative certificate metadata
- **AND** private key не отображается и не остаётся в browser state
- **AND** прежний сертификат не считается заменённым до успешной активации

#### Scenario: Невалидный TLS candidate
- **GIVEN** candidate повреждён, не соответствует private key, имеет неподходящую цепочку, имя или срок
- **WHEN** IT Admin запускает staged validation
- **THEN** UI показывает конкретные неуспешные проверки
- **AND** active certificate и доступный endpoint не изменяются
- **AND** UI не сообщает об успешной установке

#### Scenario: Просмотр аудита и доставка в SIEM
- **GIVEN** Security Auditor имеет право чтения аудита, а IT Admin настроил разрешённый SIEM/syslog endpoint
- **WHEN** аудитор фильтрует критические события, а администратор выполняет connection test и применяет настройку
- **THEN** audit view показывает разрешённые события и integrity-verification state без edit/delete actions
- **AND** delivery view показывает last confirmed delivery и состояние разрешённых категорий
- **AND** изменение настройки создаёт audit event

#### Scenario: SIEM недоступен
- **GIVEN** локальный аудит работает, но настроенный SIEM/syslog endpoint недоступен
- **WHEN** происходит подлежащее передаче событие или запускается connection test
- **THEN** UI показывает delivery gap/failure и время последней подтверждённой доставки
- **AND** локальный аудит остаётся читаемым и не помечает событие доставленным
- **AND** credential и чувствительные детали соединения не раскрываются в ошибке

### Requirement: AC-037 Offline update, patch note, restore point и rollback
The system SHALL выполнять update только из локально выбранного пакета после показа patch note и проверок, создавать проверенный restore point до изменения и подтверждать установленную либо восстановленную версию после self-check или rollback.

#### Scenario: Успешное offline-обновление
- **GIVEN** IT Admin выбрал локальный пакет, внешняя сеть не требуется, пакет совместим и активная встреча не блокирует действие
- **WHEN** администратор просматривает metadata и patch note, подтверждает update после успешных проверок
- **THEN** сервер создаёт и проверяет restore point, выполняет установку и self-check
- **AND** UI показывает текущую стадию, итоговую версию, health result и audit context
- **AND** success появляется только после authoritative self-check

#### Scenario: Пакет не прошёл preflight
- **GIVEN** signature, integrity, compatibility, license или storage check завершился отказом
- **WHEN** IT Admin пытается продолжить
- **THEN** UI показывает каждую блокирующую причину и не запускает установку
- **AND** runtime version и active state не изменяются
- **AND** restore point для не начатой установки не выдаётся за созданный

#### Scenario: Ошибка установки и успешный rollback
- **GIVEN** restore point проверен, но установка или post-install self-check завершились ошибкой
- **WHEN** update service запускает rollback
- **THEN** UI показывает rollback in progress и не предлагает ложный success
- **AND** после завершения показывает фактическую restored version, health result и audit context

#### Scenario: Ошибка автоматического rollback
- **GIVEN** установка завершилась ошибкой и rollback не смог подтвердить рабочее состояние
- **WHEN** сервис завершает recovery attempt
- **THEN** UI показывает recovery required и перевод в Safe Mode
- **AND** сохраняет доступ к разрешённым logs и correlation context
- **AND** не маркирует систему как обновлённую или восстановленную

### Requirement: AC-038 Предупреждение об активной встрече
The system SHALL останавливать update перед созданием restore point, если сервер подтверждает активную встречу, предлагать безопасное откладывание и разрешать продолжение только роли с отдельным правом после повторной проверки.

#### Scenario: IT Admin откладывает update
- **GIVEN** package preflight успешен, но room/session service сообщает об активной встрече
- **WHEN** IT Admin видит предупреждение и выбирает «Отложить»
- **THEN** update не начинается, restore point не создаётся и runtime не изменяется
- **AND** UI сохраняет проверенный package context для разрешённого повторного запуска

#### Scenario: Осознанное продолжение разрешённой ролью
- **GIVEN** активная встреча продолжается, а IT Admin имеет отдельное effective permission на override
- **WHEN** администратор выбирает продолжение и проходит отдельное подтверждение
- **THEN** сервер повторно проверяет meeting state и permission непосредственно перед стартом
- **AND** update начинается только при подтверждённом актуальном состоянии и праве
- **AND** решение и результат фиксируются в аудите

#### Scenario: Продолжение запрещено или состояние устарело
- **GIVEN** роль не имеет override permission либо meeting state стал stale/изменился после показа предупреждения
- **WHEN** пользователь отправляет command продолжения
- **THEN** сервер отклоняет старт и UI показывает актуальную причину
- **AND** restore point и update operation не создаются

### Requirement: AC-039 Проверяемый backup и restore replacement controller
The system SHALL создавать проверяемый backup и атомарно восстанавливать совместимую конфигурацию на текущем или replacement controller после preview состава и compatibility preflight.

#### Scenario: Восстановление на совместимом replacement controller
- **GIVEN** IT Admin подготовил совместимый replacement controller и выбрал backup с подтверждёнными checksum, source version и verification result
- **WHEN** администратор просматривает included/excluded categories, проходит compatibility preflight и подтверждает restore
- **THEN** сервер применяет backup атомарно и выполняет self-check версий, health и доступности Admin Web UI
- **AND** UI показывает success только после проверки и перечисляет восстановленные и исключённые категории
- **AND** предусмотренные объекты не требуют ручной настройки каждого экземпляра

#### Scenario: Backup повреждён или несовместим
- **GIVEN** integrity check не пройден либо source/target metadata нарушают compatibility rules
- **WHEN** IT Admin запускает preflight
- **THEN** UI показывает конкретные incompatibilities и блокирует подтверждение
- **AND** текущая конфигурация и её revision/hash не изменяются
- **AND** частичное применение не начинается

#### Scenario: Restore завершился ошибкой после начала
- **GIVEN** restore был подтверждён и mutation начался, но итоговый self-check не пройден
- **WHEN** система выполняет recovery
- **THEN** она возвращает подтверждённый pre-restore state либо остаётся в Safe Mode с recovery required
- **AND** UI показывает фактический итог, версии и health
- **AND** partial success не отображается как завершённый restore

### Requirement: AC-040 Safe Mode для Admin Web UI и Room Client
The system SHALL в Safe Mode оставлять ограниченный Admin Web UI для диагностики, restore и rollback, а Room Client переводить в понятную заглушку без управления оборудованием.

#### Scenario: Вход в Safe Mode
- **GIVEN** сервер подтвердил критическое условие входа в Safe Mode
- **WHEN** IT Admin открывает Admin Web UI, а End User открывает Room Client
- **THEN** Admin Web UI показывает persistent Safe Mode state, причину, версии, last-known-good, разрешённые logs/crash dump и recovery actions
- **AND** Room Client показывает пользовательскую заглушку и путь обращения без инженерных терминов
- **AND** project editing, runtime control и equipment controls недоступны

#### Scenario: Успешное восстановление и выход
- **GIVEN** IT Admin имеет право restore/rollback и выбрал совместимый recovery source
- **WHEN** recovery и итоговый health check успешно завершены
- **THEN** сервер подтверждает normal mode, а Admin Web UI показывает восстановленную версию и результат
- **AND** Room Client выполняет resync и возвращает controls только после server confirmation

#### Scenario: Восстановление не удалось
- **GIVEN** система находится в Safe Mode, а restore/rollback не подтвердил рабочее состояние
- **WHEN** recovery attempt завершается
- **THEN** Safe Mode остаётся активным и UI показывает recovery required с correlation context
- **AND** Room Client остаётся на заглушке
- **AND** ложный normal/success state не появляется

### Requirement: AC-041 Состояния лицензии и лимиты
The system SHALL показывать authoritative license state, effective limit, current usage, срок или оставшееся время при наличии, затронутые действия и поведение active runtime.

#### Scenario: Просмотр действующей лицензии
- **GIVEN** IT Admin имеет право чтения, а license service вернул действующее состояние
- **WHEN** администратор открывает экран лицензии
- **THEN** UI показывает status, effective limit, current usage, применимый срок и затронутые возможности
- **AND** данные совпадают с authoritative server response
- **AND** экран не содержит коммерческого checkout

#### Scenario: Лимит превышен
- **GIVEN** current usage достиг или превысил effective limit, а active runtime уже работает
- **WHEN** пользователь пытается выполнить запрещённое расширение или deploy
- **THEN** сервер блокирует новое действие и UI показывает usage, limit и путь решения
- **AND** active runtime не останавливается только из-за этого отказа
- **AND** UI не сообщает, что лимит автоматически расширен

#### Scenario: Невалидный новый license file
- **GIVEN** IT Admin выбрал локальный license file, который не проходит server validation
- **WHEN** пользователь пытается применить файл
- **THEN** UI показывает причину отказа
- **AND** действующая license state и active runtime сохраняются
- **AND** внешняя онлайн-покупка или автоматическая отправка файла не запускается

### Requirement: AC-042 Временный доступ Vendor Support
The system SHALL позволять IT Admin явно выдать Vendor Support ограниченный по scope и времени доступ, показать активность и expiry и немедленно отозвать доступ с фиксацией действий в аудите.

#### Scenario: Выдача и использование ограниченного доступа
- **GIVEN** IT Admin имеет право выдачи и выбрал утверждённого Vendor Support principal, resources, actions, duration и reason
- **WHEN** администратор просматривает effective scope и подтверждает выдачу
- **THEN** UI показывает активный доступ, scope, expiry, activity state и revoke action
- **AND** Vendor Support может выполнить только действие внутри scope
- **AND** выдача, вход и действие фиксируются в tamper-evident audit

#### Scenario: Истечение или ручной отзыв
- **GIVEN** временный доступ активен
- **WHEN** наступает expiry либо IT Admin подтверждает revoke
- **THEN** сервер прекращает дальнейшие действия и инвалидирует доступ согласно утверждённому session contract
- **AND** UI показывает expired/revoked state
- **AND** истечение или отзыв фиксируется в аудите

#### Scenario: Попытка постоянного или избыточного доступа
- **GIVEN** запрошен срок или scope вне утверждённой политики либо Vendor Support обращается к ресурсу вне scope
- **WHEN** выполняется выдача или прямой request
- **THEN** сервер отклоняет действие без расширения доступа
- **AND** UI показывает policy/permission reason
- **AND** скрытый, бессрочный или административный backdoor не создаётся

### Requirement: AC-043 Ретенция и заполнение хранилища
The system SHALL позволять IT Admin просматривать и изменять разрешённую ретенцию с preview последствий, защищать обязательный аудит и показывать управляемое recovery-состояние при storage pressure/full.

#### Scenario: Разрешённое изменение ретенции
- **GIVEN** IT Admin видит текущие policies, storage usage и protected categories
- **WHEN** администратор вводит значение в разрешённом сервером диапазоне, просматривает cleanup-impact preview и подтверждает
- **THEN** сервер применяет policy и UI показывает authoritative effective value
- **AND** изменение создаёт audit event
- **AND** повторное открытие не подменяет server value browser draft

#### Scenario: Storage full и контролируемая очистка
- **GIVEN** сервер подтвердил storage pressure/full и остановил небезопасные некритические writes
- **WHEN** IT Admin открывает предупреждение, просматривает cleanup preview и запускает разрешённую очистку
- **THEN** UI показывает защищённые и очищаемые категории, стадии и фактический освобождённый результат
- **AND** warning снимается только после server recheck storage и writers
- **AND** критические данные не выдаются за удалённые или сохранённые без подтверждения

#### Scenario: Попытка удалить защищённый аудит
- **GIVEN** выбранная cleanup/retention operation затрагивает обязательные audit records вне разрешённой политики
- **WHEN** IT Admin подтверждает действие или отправляет прямой request
- **THEN** сервер отклоняет удаление и UI показывает protected-data reason
- **AND** audit integrity и read access сохраняются

### Requirement: NFR-031 Аутентификация, RBAC и TLS
The system SHALL требовать authenticated session для Admin Web UI, проверять каждое действие серверным deny-by-default RBAC и передавать authenticated Admin/API traffic только по TLS.

#### Scenario: Разрешённый ролевой доступ по TLS
- **GIVEN** пользователь аутентифицирован, TLS endpoint валиден, а role matrix разрешает конкретные action и resource
- **WHEN** пользователь открывает route и выполняет action
- **THEN** сервер выполняет действие в пределах effective permission
- **AND** UI показывает только разрешённые данные и result
- **AND** transport evidence подтверждает TLS без plain-HTTP fallback

#### Scenario: Прямой запрещённый запрос
- **GIVEN** control скрыт или route недоступен роли, но пользователь вручную отправляет прямой request
- **WHEN** сервер проверяет session, action и resource
- **THEN** запрос отклоняется без чтения или mutation защищённых данных
- **AND** UI показывает permission-denied и не раскрывает содержимое ресурса

#### Scenario: Нет сессии или TLS неприемлем
- **GIVEN** session отсутствует/истекла либо защищённый endpoint не может подтвердить допустимый TLS
- **WHEN** пользователь пытается открыть operational route или отправить command
- **THEN** operational data и command result не предоставляются
- **AND** пользователь получает безопасный auth/recovery path без downgrade на незашифрованный канал

### Requirement: NFR-032 Tamper-evident аудит
The system SHALL записывать критические действия в read-only audit с проверяемой целостностью и обнаруживать изменение или разрыв записей без возможности исправления через UI.

#### Scenario: Критическое действие оставляет проверяемый след
- **GIVEN** авторизованная роль изменяет пользователя, TLS, update, restore, license, retention или temporary vendor access
- **WHEN** сервер завершает действие успехом или отказом
- **THEN** audit содержит разрешённые actor, role, target, action, result, time и correlation attributes
- **AND** UI показывает integrity-verification state
- **AND** роли этого change не получают edit/delete action

#### Scenario: Обнаружено нарушение целостности
- **GIVEN** test fixture изменил, удалил или разорвал защищённую audit sequence
- **WHEN** выполняется integrity verification и Security Auditor открывает затронутый период
- **THEN** UI показывает security failure/gap, а не пустой или штатный журнал
- **AND** изменение нельзя скрыть, исправить или удалить через Admin Web UI

### Requirement: NFR-033 Приватность diagnostic bundle
The system SHALL формировать diagnostic bundle по утверждённому allowlist/redaction policy, исключать секреты и запрещённые данные и завершаться fail-closed, если безопасный состав нельзя подтвердить.

#### Scenario: Проверка известных чувствительных маркеров
- **GIVEN** диагностические fixtures содержат известные password, token, private-key и персональные marker values
- **WHEN** авторизованный пользователь формирует bundle и выполняется post-generation scan
- **THEN** raw marker values отсутствуют в доступном файле
- **AND** manifest и redaction report объясняют включённые, исключённые и замаскированные категории без раскрытия самих значений

#### Scenario: Источник нельзя безопасно обработать
- **GIVEN** mandatory source не классифицирован или redaction rule завершился ошибкой
- **WHEN** bundle service проверяет состав
- **THEN** результат не публикуется и UI показывает fail-closed reason
- **AND** temporary raw data удаляется по утверждённой политике
- **AND** пользователь не может обойти проверку обычным UI или прямым command без отдельного утверждённого права

### Requirement: NFR-034 Восстановление и rollback
The system SHALL после отказа update/restore возвращать подтверждённое предыдущее рабочее состояние либо явно переходить в Safe Mode/recovery required без partial-success.

#### Scenario: Автоматическое восстановление подтверждено
- **GIVEN** до destructive operation зафиксированы проверенные pre-state и recovery source
- **WHEN** injected failure запускает rollback или возврат pre-restore state
- **THEN** система подтверждает returned version/revision, health и доступность Admin Web UI
- **AND** UI показывает recovered result только после этих проверок
- **AND** audit связывает исходную операцию, отказ и recovery

#### Scenario: Автоматическое восстановление не подтверждено
- **GIVEN** rollback/restore attempt завершился ошибкой или итоговый health неизвестен
- **WHEN** операция достигает terminal failure
- **THEN** UI показывает recovery required и сохраняет Safe Mode
- **AND** доступны разрешённые logs и correlation context
- **AND** ни исходная операция, ни rollback не отображаются как успешные

### Requirement: NFR-035 Offline-first без обязательного облака
The system SHALL выполнять все штатные локальные эксплуатационные пути без интернета, CDN, внешних шрифтов, обязательных cloud API, online update delivery или автоматической отправки данных.

#### Scenario: Работа при заблокированном внешнем egress
- **GIVEN** внешний DNS и internet egress заблокированы, а controller и локальные dependencies доступны
- **WHEN** пользователь выполняет health/triage, bundle generation, bootstrap, security administration, local update, backup/restore, license view и retention
- **THEN** разрешённые пути работают на локальных assets и services
- **AND** network capture не содержит обязательных внешних запросов, cloud telemetry, CDN или automatic bundle upload

#### Scenario: Optional integration не настроена или недоступна
- **GIVEN** SIEM или Vendor Support endpoint не настроен либо недоступен
- **WHEN** IT Admin выполняет локальное администрирование, диагностику или recovery
- **THEN** локальные функции и аудит остаются доступными
- **AND** UI явно показывает состояние optional integration
- **AND** система не пытается тайно заменить её обязательным облачным сервисом

### Requirement: NFR-036 Наблюдаемость эксплуатационных путей
The system SHALL связывать user-safe UI result с локальными operation logs и audit через correlation context, показывать freshness/gaps и не включать секреты в observability data.

#### Scenario: Ошибка прослеживается через слои
- **GIVEN** long-running operation завершилась ошибкой
- **WHEN** IT Admin или Support Operator открывает result и связанные журналы в пределах своих прав
- **THEN** UI показывает stage, time, user-safe reason и correlation context
- **AND** тот же context связывает server operation log и audit event
- **AND** password, private key, token и raw confidential payload отсутствуют

#### Scenario: Наблюдаемость частично недоступна
- **GIVEN** один из Monitoring/log/audit sources не отвечает или отдаёт stale data
- **WHEN** пользователь открывает health, triage или operation result
- **THEN** UI показывает freshness и конкретный gap для затронутого source
- **AND** partial state не отображается как complete/healthy/success
- **AND** доступные источники остаются различимы

### Requirement: NFR-037 Discovery производительности без выдуманного порога
The system SHALL локально собирать воспроизводимый performance baseline для критических operations UI interactions с контекстом сборки, железа, браузера и объёма данных и не объявлять `pass` до утверждения числового target.

#### Scenario: Сбор baseline с полным контекстом
- **GIVEN** выбран candidate hardware/browser context и зафиксирован fixture manifest для health и logs
- **WHEN** выполняются первый полезный health render, переход к объекту, применение log filter, bundle preview, update preflight, backup metadata read и Safe Mode view
- **THEN** локальный отчёт сохраняет raw start/end/result data, build SHA, controller version и data-set context для каждого пути
- **AND** внешняя telemetry-передача не выполняется
- **AND** отчёт не подменяет неизвестный target произвольным числом

#### Scenario: Данных недостаточно для решения
- **GIVEN** hardware/browser/data context не зафиксирован, samples неполны либо есть незакрытые failures
- **WHEN** формируется discovery summary
- **THEN** результат помечается как «данных недостаточно» с перечислением gaps
- **AND** requirement не получает performance `pass`
- **AND** baseline, target, sample и validation window остаются блокирующим решением владельца

### Requirement: NFR-038 Клавиатура, focus и доступность
The system SHALL обеспечивать keyboard-only прохождение P0 Admin-путей, видимый управляемый focus и текстовую/семантическую передачу состояния, не полагаясь только на цвет.

#### Scenario: Критический путь проходит без мыши
- **GIVEN** пользователь начинает на health dashboard и использует только клавиатуру
- **WHEN** он проходит health → triage → logs → bundle preview и открывает administrative/recovery actions в пределах роли
- **THEN** Tab/Shift+Tab дают предсказуемый порядок, а стандартные клавиши активируют controls
- **AND** focus всегда видим и не попадает на скрытые или disabled elements
- **AND** warning, error, selected и success различимы по тексту/семантике, а не только цвету

#### Scenario: Dialog закрывается с корректным focus
- **GIVEN** пользователь клавиатурой открыл confirmation dialog или drawer для update, restore, revoke или cleanup
- **WHEN** он подтверждает, отменяет либо закрывает overlay допустимой клавишей
- **THEN** focus во время открытия остаётся внутри активного overlay и после закрытия возвращается к инициатору или следующему логичному result
- **AND** background controls не активируются случайно
- **AND** focus trap не остаётся после закрытия

#### Scenario: Ошибка формы доступна без цвета
- **GIVEN** network, NTP, user, TLS, SIEM, retention или temporary-access form содержит невалидное поле
- **WHEN** пользователь отправляет форму с клавиатуры
- **THEN** focus переходит к первой релевантной ошибке, поле связано с понятным текстом и summary сообщает результат
- **AND** уже введённые допустимые значения сохраняются
- **AND** исправление и повторная отправка доступны без мыши
