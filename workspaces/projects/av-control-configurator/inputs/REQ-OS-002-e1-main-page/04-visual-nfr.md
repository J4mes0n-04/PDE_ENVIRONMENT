# REQ-OS-002 · Главная страница (`Э-1`) — визуал и NFR

Источники: `VIS-CFG-001` §1–2, §5; токены v0.1 §1–2, §5, §12; `VAL-09`, `VAL-12`; NFR-010, NFR-011, NFR-012 из `chg-001` (уточнение применимости к `Э-1`).

Гипотеза baseline MVP (не утверждение PM, `FORB-04`): акцент `#4F8FA6`, UI-шрифт IBM Plex Sans, mono IBM Plex Mono, фон canvas `#17181B`, поверхность списка `#202226`.

---

## ADDED Requirements (NFR)

### NFR-026 Тёмная служебная база на Э-1

**JTBD:** `INT-E1` · **JRN:** `JRN-KIT-01` · **VAL:** `VAL-09`, `VAL-12`

The system SHALL render screen `Э-1` on dark neutral tokens: background `color.bg.canvas` (`#17181B`), list/table surface `color.bg.surface` (`#202226`). Light theme as primary for `Э-1` is forbidden (`VIS-BAN-11`, `NFR-011`).

#### Scenario: Приёмка макета Э-1

- **WHEN** reviewer inspects mockup or implementation of `Э-1`
- **THEN** no light SaaS-style background dominates the screen
- **AND** text hierarchy uses `color.text.label` for field labels and `color.text.value` for kit names

---

### NFR-027 Э-1 не KPI-дашборд

**JTBD:** `INT-F1` · **JRN:** `JRN-KIT-01` · **VAL:** `VAL-12`

The system SHALL NOT use on `Э-1`: KPI tiles, chart placeholders, «quick insights», analytics cards (`VIS-BAN-12`, `NFR-012`).

The home content SHALL be limited to: kit library list, search, primary action «Создать комплект», and secondary commands explicitly scoped (import/export handoff, if present).

#### Scenario: Содержимое домашнего экрана

- **WHEN** `Э-1` is displayed with at least one kit
- **THEN** at least 60% of the main content width is occupied by the kit list or table
- **AND** zero chart or KPI widgets are present

---

### NFR-028 Плотность списка комплектов

**JTBD:** `INT-E1` · **JRN:** `JRN-KIT-01` · **VAL:** `VAL-09`

The system SHALL use control height `control.size.compact` (24px) for kit list rows and `control.size.default` (32px) for the primary «Создать комплект» control (`VIS-BAN-07`, token §5).

#### Scenario: Viewport 1440px

- **GIVEN** viewport width 1440px, album orientation
- **WHEN** `Э-1` shows the kit list and toolbar
- **THEN** the list shows at least 8 kit rows without scrolling the entire page chrome (internal list scroll is allowed)

---

### NFR-029 Служебный тон пустого состояния

**JTBD:** `INT-F1` · **JRN:** `JRN-KIT-01` · **VAL:** `VAL-09`

The system SHALL use factual copy on empty `Э-1`: what is missing (no kits) and one available action (create). No welcome slogans, mascots, or motivational phrases (`VIS-BAN-10`, `NFR-010`).

#### Scenario: Пустая библиотека

- **WHEN** storage has zero kits
- **THEN** visible text states that no kits exist and names the create action
- **AND** no illustration asset is required for empty state

---

### NFR-030 Акцент и запрет AI-chrome на Э-1

**JTBD:** `INT-E1` · **JRN:** `JRN-KIT-01` · **VAL:** `VAL-12`

The system SHALL use flat accent `color.accent.default` (draft `#4F8FA6`) only for: primary «Создать комплект», focused search field border, selected kit row overlay `overlay.selected` (`rgba(79,143,166,0.16)`).

The system SHALL NOT use on `Э-1`: purple/indigo gradients, glass blur, decorative shadows on list rows (`VIS-BAN-01`–`VIS-BAN-03`, `NFR-001`–`NFR-003`).

#### Scenario: Primary action styling

- **WHEN** `Э-1` is at rest
- **THEN** «Создать комплект» uses solid accent fill without gradient
- **AND** list rows at rest have no decorative box-shadow

---

## MODIFIED (относительно chg-001) — указание для OpenSpec

| Базовое | Уточнение в chg-002 |
| --- | --- |
| `NFR-012` | применимость только к `Э-1`; количественный критерий 60% — см. `NFR-027` |
| `AC-002` (`chg-001`) | детализируется `AC-035`…`AC-042`; при merge не дублировать противоречивый текст |

---

## Приёмка визуала (FORB-03)

Pack Ready для UI `Э-1` не объявляется, пока не зафиксированы: прогон кириллицы RU/EN на списке имён комплектов; контраст accent на `#202226` (WCAG — владелец дизайна).

---

## Offline

**JTBD:** `INT-S1` · **JRN:** `JRN-KIT-03` · **VAL:** `VAL-04`

`Э-1` SHALL load kit list from local controller storage only; no cloud kit catalog (`NFR-019`, `FORB-02`).
