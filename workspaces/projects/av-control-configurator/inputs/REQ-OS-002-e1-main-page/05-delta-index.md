# REQ-OS-002 · Индекс delta specs и трассировка

Change OpenSpec: **`openspec/changes/chg-002-e1-main-page/`**

Один Outcome · без Pack · без archive до release (APP-11).

---

## Карта файлов delta

| # | Delta spec | Требования | Входной документ |
| --- | --- | --- | --- |
| 1 | `specs/e1-entry/spec.md` | `AC-035` | `01-scope`, `02-functional-ac` |
| 2 | `specs/e1-library/spec.md` | `AC-036`, `AC-037`, `AC-040` | `02-functional-ac`, `04-visual-nfr` |
| 3 | `specs/e1-open-workspace/spec.md` | `AC-038`, `AC-041` | `02-functional-ac`, `03-jrn-scenarios` |
| 4 | `specs/e1-create-flow/spec.md` | `AC-039`, `AC-042` | `02-functional-ac`, `03-jrn-scenarios` |
| 5 | `specs/e1-visual/spec.md` | `NFR-026`…`NFR-030` | `04-visual-nfr`, `VIS-CFG-001` |

---

## Связь с change chg-001

| Тема | chg-001 | chg-002 |
| --- | --- | --- |
| Библиотека в целом | `AC-002` (общий) | `AC-035`…`AC-042` (детализация UI `Э-1`) |
| Визуал домашнего экрана | `NFR-012` (общий) | `NFR-027` (измеримый критерий для `Э-1`) |
| Мастер | `wizard-change` | только handoff с `AC-039` |

При конфликте текста побеждает **более новый** change `chg-002` для экрана `Э-1`; противоречия вне `Э-1` не трогать.

---

## Матрица AC → JTBD → JRN → VAL

| AC | JTBD | JRN | VAL |
| --- | --- | --- | --- |
| AC-035 | INT-F1 | JRN-KIT-01 | VAL-01, VAL-04 |
| AC-036 | INT-F2 | JRN-KIT-01 | VAL-02 |
| AC-037 | INT-F2 | JRN-KIT-01 | VAL-06 |
| AC-038 | INT-F1 | JRN-KIT-02 | VAL-01, VAL-06 |
| AC-039 | INT-F1 | JRN-KIT-01 | VAL-01 |
| AC-040 | INT-F1 | JRN-KIT-01 | VAL-09, VAL-12 |
| AC-041 | INT-F2 | JRN-KIT-02 | VAL-02, VAL-06 |
| AC-042 | INT-F4 | JRN-KIT-01/02 | VAL-03, VAL-08 |

---

## Артефакты OpenSpec для агента

| Артефакт | Источник |
| --- | --- |
| `explore.md` | `01-scope`, `03-jrn-scenarios`, расхождения § |
| `proposal.md` | Outcome + scope.in/out из `01-scope` |
| `design.md` | `BLK-22`, `Э-1` карта экранов, `NFR-026`…`030`, handoff `C-PRJ-3` |
| `tasks.md` | срезы: макет `Э-1` → список → создание → визуал → интеграция с `Э-2` |
| delta specs | пять файлов в таблице выше |

---

## scope.out (свод для proposal)

См. полную таблицу в `01-scope-and-outcome.md`. OpenSpec SHALL copy each row into proposal section «Не входит» without designing those screens.

---

## Проверка APP-03 (CAN)

Каждый `CAN-*`, относящийся к библиотеке на `Э-1`, отражён в `02-functional-ac.md` или помечен scope.out. Полный конфигуратор (`CAN-01`…`CAN-59`) — в `REQ-OS-001`; этот change не дублирует весь перечень.
