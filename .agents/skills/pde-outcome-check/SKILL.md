---
name: pde-outcome-check
description: Проводит проверку фактического Outcome после release и формирует решение scale, keep, adapt или revert. Использовать по завершении validation window или при раннем stop signal; не использовать как release checklist.
---

# Outcome Check

## Required context

Прочитайте `governance/14-outcome-measurement.md`, Pack, Evidence Bundle, release plan и доступные telemetry/support data.

## Workflow

1. Подтвердите версию Pack, release и фактическое observation window.
2. Воспроизведите baseline и actual из указанного источника.
3. Проверьте data quality, сегмент, исключения и изменения метода измерения.
4. Сравните target и decision rule; отдельно оцените негативные эффекты и defects.
5. Учтите открытые QSRE feedback и остаточный риск.
6. Заполните `outcome-check.md` и выберите ровно одно: `scale`, `keep`, `adapt`, `revert`.
7. Свяжите решение со следующим Signal, Outcome или Definition Change.

## Boundary

Отсутствие данных не является успехом. Не меняйте заранее утверждённую decision rule задним числом без Definition Change.
