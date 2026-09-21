# Поток PDE, ASE и QSRE

## Прямой поток

1. PDE получает Signal и формирует Outcome.
2. Если включён OpenSpec intake, PDE разбирает требования в `openspec/changes/<change-id>/` и только затем переносит AC/NFR в Pack.
3. PDE создаёт Pack, критерии приёмки, NFR, риск и план измерения.
4. Ready Review подтверждает, что определение пригодно для реализации.
5. PDE создаёт `ase-handoff.md` и передаёт стабильную версию Pack по commit SHA.
6. ASE реализует Delivery Slice и возвращает Pull Request, технические решения и evidence.
7. QSRE проверяет evidence, качество, безопасность, совместимость и release readiness.

## Обратный поток

QSRE возвращает в PDE `qsre-feedback.md`, когда обнаружены:

- непроверяемый критерий;
- противоречие между Pack и реализацией;
- новый риск или обязательство;
- невозможность собрать требуемое evidence;
- ограничение rollout/rollback;
- production signal, меняющий исходное определение.

PDE классифицирует обратную связь:

- clarification — пояснение без изменения baseline;
- definition-change — материальное изменение Pack;
- defect — реализация не соответствует действующему Pack;
- governance-signal — возможное изменение нормы через отдельный RFC/PR.

## Инвариант

ASE и QSRE никогда не исправляют Product Definition Pack неявно. Материальное изменение проходит Definition Change и создаёт новую версию baseline.
