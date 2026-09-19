# Жизненный цикл Outcome и gates

Document ID: PDE-GOV-009  
Type: Standard  
Status: Draft  
Version: 0.1.0

## Состояния

`New -> Defined -> Ready -> Committed -> In Progress -> In Review -> Released -> Outcome Check -> Done`

Дополнительные состояния: `Blocked`, `Adapt`, `Reverted`, `Closed`.

## Gates

- **Defined**: проблема, пользователь, владелец и предполагаемый Outcome записаны.
- **Ready**: Pack согласован, риск назначен, AC/NFR проверяемы, открытые вопросы не блокируют реализацию.
- **Committed**: WIP-limit свободен, ASE function приняла handoff.
- **In Review**: реализация связана с Pack и содержит evidence plan.
- **Released**: release decision, rollback и обязательное evidence доступны.
- **Outcome Check**: прошло заданное окно измерения и доступны данные.
- **Done**: записан вердикт `scale`, `keep`, `adapt` или `revert`, а следующий сигнал связан.

Переход через gate без обязательного evidence запрещён. Waiver оформляется по `12-ci-gates-and-exceptions.md`.
