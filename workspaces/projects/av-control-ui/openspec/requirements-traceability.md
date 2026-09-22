# Трассировка требований OpenSpec к `REQ-UI-001`

Статус: `draft`.

Назначение файла — сохранить связь между обязательным форматом OpenSpec `AC-NNN` / `NFR-NNN` и устойчивыми идентификаторами входного документа `REQ-UI-001`. Карта не заменяет delta specs и будущий Pack.

Основной источник: `workspaces/projects/av-control-ui/inputs/REQ-UI-001-av-control-interface.md`, версия `0.2`.

## Change 1 — UI foundation

| OpenSpec ID | Исходные идентификаторы | Смысл связи |
| --- | --- | --- |
| `AC-001` | `CAP-UI-001`, `AC-UI-001` | Единая ролевая оболочка |
| `AC-002` | `CAP-UI-001`, `AC-UI-001` | Видимость по роли |
| `AC-003` | `AC-UI-001`, `GRD-004` | Запрет прямого доступа |
| `AC-004` | `CAP-UI-002`, `AC-UI-002` | Верхнеуровневая навигация |
| `AC-005` | `AC-UI-002`, `ERR-UI-012` | Сохранение dirty state |
| `AC-006` | `AC-UI-020`, `ERR-UI-001` | Loading и empty |
| `AC-007` | `CAP-UI-012`, `AC-UI-020`, `ERR-UI-002`, `ERR-UI-013` | Error, offline и permission denied |
| `AC-008` | `CAP-UI-019`, `AC-UI-021` | RU/EN |
| `AC-009` | `CAP-UI-012`, `AC-UI-011` | Severity, пользовательский и инженерный слои ошибки |
| `AC-010` | `CAP-UI-020`, `AC-UI-019`, `AC-UI-022` | Семантические токены и anti-generic ограничения |
| `NFR-001` | `NFR-UI-002` | Offline-first без внешних ресурсов |
| `NFR-002` | `NFR-UI-003` | Auth и RBAC |
| `NFR-003` | `NFR-UI-008` | Клавиатура и focus |
| `NFR-004` | `NFR-UI-009`, `Q-UI-008` | Контраст и WCAG |
| `NFR-005` | `NFR-UI-013`, `Q-UI-009` | Матрица совместимости |
| `NFR-006` | `NFR-UI-001`, `Q-UI-005`, `Q-UI-006` | Discovery производительности и метрики |

## Change 2 — Configurator UI

| OpenSpec ID | Исходные идентификаторы | Смысл связи |
| --- | --- | --- |
| `AC-011` | `CAP-UI-003`, `AC-UI-003`, `JRN-UI-001`, `PRJ-01`, `PRJ-02` | Мастера комнаты и устройств |
| `AC-012` | `CAP-UI-003`, `AC-UI-003`, `JRN-UI-002`, `PRJ-03` | Ручной проект |
| `AC-013` | `CAP-UI-004`, `AC-UI-004`, `PRJ-03`, `PRJ-05` | Дерево, холст и инспектор |
| `AC-014` | `CAP-UI-004`, `AC-UI-004` | Drag-and-drop и единый selection |
| `AC-015` | `AC-UI-023`, `PRJ-04` | Ручная правка результата мастера |
| `AC-016` | `CAP-UI-005`, `AC-UI-005`, `JRN-UI-003`, `PRJ-06` | Preflight |
| `AC-017` | `CAP-UI-004`, `PRJ-05` | Preview черновика |
| `AC-018` | `CAP-UI-006`, `AC-UI-006`, `JRN-UI-003`, `PRJ-07` | Deploy и rollback |
| `AC-019` | `PRJ-09`, `PRJ-10`, `PRJ-11` | Import/export, шаблоны и защита |
| `AC-020` | `JTBD-005`, `PRJ-12`, `LIC-03` | Работа без оборудования и эмулятор |
| `NFR-011` | `GRD-003`, `ERR-UI-012` | Целостность и dirty state |
| `NFR-012` | `NFR-UI-002` | Offline-first |
| `NFR-013` | `NFR-UI-015` | Инженерная диагностируемость |
| `NFR-014` | `NFR-UI-019` | Плотные списки |
| `NFR-015` | `PRJ-11`, `THR-UI-001` | Сдерживающая защита без ложной криптогарантии |
| `NFR-016` | `NFR-UI-008` | Клавиатура и focus |

## Change 3 — Room Client UI

| OpenSpec ID | Исходные идентификаторы | Смысл связи |
| --- | --- | --- |
| `AC-021` | `CAP-UI-007`, `AC-UI-007`, `JRN-UI-004`, `PNL-01` | Pairing, клиентский проект и kiosk |
| `AC-022` | `CAP-UI-008`, `AC-UI-008`, `JRN-UI-005`, `OPS-01` | Запуск одним действием |
| `AC-023` | `OPS-02` | Продолжение активной комнаты |
| `AC-024` | `CAP-UI-009`, `AC-UI-009`, `JRN-UI-006`, `OPS-03` | BYOD и источник |
| `AC-025` | `CAP-UI-010`, `AC-UI-009`, `JRN-UI-007`, `OPS-04` | Управление встречей |
| `AC-026` | `CAP-UI-011`, `AC-UI-010`, `JRN-UI-008`, `OPS-05` | Завершение и очистка |
| `AC-027` | `AC-UI-012`, `ERR-UI-002`, `ERR-07` | Offline без очереди и resync |
| `AC-028` | `CAP-UI-012`, `AC-UI-011`, `JRN-UI-009`, `OPS-07` | Понятные ошибки |
| `AC-029` | `PNL-04` | Синхронизация панелей |
| `AC-030` | `BVC-01`, `BVC-02`, `BVC-03`, `BVC-04`, `Q-UI-014`, `Q-UI-019` | Ограниченная область календаря и ВКС |
| `NFR-021` | `NFR-UI-005`, `FACT-003` | Сервер как source of truth |
| `NFR-022` | `NFR-UI-018`, `THR-UI-004` | Kiosk lock |
| `NFR-023` | `NFR-UI-002` | Offline-first |
| `NFR-024` | `NFR-UI-011`, `NFR-UI-012` | Touch и адаптивность |
| `NFR-025` | `NFR-UI-010`, `AC-UI-021` | RU/EN |
| `NFR-026` | `NFR-UI-001`, `Q-UI-005`, `Q-UI-006` | Discovery времени отклика |

## Change 4 — Operations UI

| OpenSpec ID | Исходные идентификаторы | Смысл связи |
| --- | --- | --- |
| `AC-031` | `CAP-UI-013`, `AC-UI-013`, `JRN-UI-010`, `MON-01` | Health |
| `AC-032` | `CAP-UI-013`, `AC-UI-013`, `MON-02` | Triage и фильтры |
| `AC-033` | `CAP-UI-014`, `AC-UI-014`, `MON-03`, `Q-UI-016` | Diagnostic bundle |
| `AC-034` | `ADM-01`, `ADM-02` | Первый администратор, сеть и NTP |
| `AC-035` | `CAP-UI-001`, `AC-UI-001`, `SEC-01`, `Q-UI-003`, `Q-UI-013` | Пользователи и роли |
| `AC-036` | `CAP-UI-018`, `AC-UI-018`, `SEC-03`, `SEC-05`, `SEC-06` | TLS, аудит и SIEM |
| `AC-037` | `CAP-UI-015`, `AC-UI-016`, `JRN-UI-011`, `UPD-01` | Offline update и rollback |
| `AC-038` | `UPD-02` | Предупреждение об активной встрече |
| `AC-039` | `CAP-UI-016`, `AC-UI-017`, `JRN-UI-012`, `UPD-03`, `UPD-04` | Backup/restore |
| `AC-040` | `CAP-UI-017`, `AC-UI-015`, `JRN-UI-013`, `ERR-13`, `ERR-14`, `Q-UI-017` | Safe Mode |
| `AC-041` | `LIC-01`, `LIC-02` | Лицензия и лимиты |
| `AC-042` | `AC-UI-025`, `SEC-04`, `SUP-02` | Временный Vendor Support |
| `AC-043` | `ADM-05`, `ERR-15` | Ретенция и storage full |
| `NFR-031` | `NFR-UI-003`, `NFR-UI-004` | Auth, RBAC и TLS |
| `NFR-032` | `NFR-UI-017` | Tamper-evident аудит |
| `NFR-033` | `NFR-UI-020`, `THR-UI-003`, `Q-UI-016` | Приватность bundle |
| `NFR-034` | `NFR-UI-014`, `GRD-005` | Recovery и rollback |
| `NFR-035` | `NFR-UI-002` | Offline-first |
| `NFR-036` | `NFR-UI-007` | Наблюдаемость |
| `NFR-037` | `NFR-UI-001`, `Q-UI-005`, `Q-UI-006` | Discovery производительности |
| `NFR-038` | `NFR-UI-008`, `NFR-UI-009`, `Q-UI-008` | Клавиатура, focus и accessibility |

## Правило изменения карты

- При изменении смысла, scope или идентификатора обновить input, соответствующий change и эту карту в одном изменении.
- Один OpenSpec requirement не должен получать новый смысл без Definition Change после будущего baseline.
- После подтверждения changes карта переносится в `openspec-traceability.md` каждого будущего Outcome через `pde-create-pack`.
