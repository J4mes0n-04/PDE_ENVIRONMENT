# План удаления дубликатов governance (этап 10 / пункт 31)

Document ID: PDE-ARCH-DEDUP-001  
Type: Migration plan  
Status: Draft — execution blocked until parallel period exit  
Version: 0.1.0  
Owner: Platform Owner  
Approver: _назначить до открытия execution PR_  
Scope: Будущее удаление локальных копий общих нормативов из PDE после стабилизации.  
Effective date: Not set  
Review cycle: перед открытием execution Pull Request

## Жёсткие ограничения

1. Этот документ **не удаляет** файлы. Он только готовит будущий execution PR.
2. До закрытия [периода параллельной работы](../operations/parallel-stabilization-period.md) execution PR открывать нельзя.
3. Execution PR не смешивается с изменением смысла норм, Skills, Pack Outcome или cutover `authoritative: true`.
4. До merge execution PR каталог `governance/` в PDE остаётся единственным нормативным источником истины.
5. ASE и QSRE уже читают pin `engineering-control`; их vendor/submodule этим планом не удаляется.

Связанные артефакты:

- [repository-separation-plan.md](repository-separation-plan.md)
- [engineering-control source-baseline.yaml](https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/source-baseline.yaml)
- Tag PDE: `pde-baseline-v0.1.0` → `a8df54374e2b0db6c13175c7bf1b1cf073a7441a`
- Tag control: `v1.0.0-rc.1` → `abd0982171341438cab80267099b951a2027be0b`

## Цель будущего execution PR

После cutover и периода стабилизации убрать из PDE **рабочие дубли** документов, которые стали жить в `engineering-control`, и заменить их явными ссылками на pin (tag + полный SHA). PDE сохраняет adapters, Pack templates, skills, workspaces и локальные CI wrappers.

## Кандидаты на удаление из PDE

Удаление допускается только если файл уже есть в `engineering-control` и PDE переведён на чтение из pin (не из локальной копии).

### A. Полный нормативный контур (Unit 1)

| Удаляемый путь в PDE | Новое местоположение | История / неизменяемая ссылка |
| --- | --- | --- |
| `governance/README.md` | `engineering-control/governance/README.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/README.md |
| `governance/document-control.yaml` | `engineering-control/governance/document-control.yaml` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/document-control.yaml |
| `governance/01-pde-charter.md` | `engineering-control/governance/01-pde-charter.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/01-pde-charter.md |
| `governance/02-glossary.md` | `engineering-control/governance/02-glossary.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/02-glossary.md |
| `governance/03-roles-and-decision-rights.md` | `engineering-control/governance/03-roles-and-decision-rights.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/03-roles-and-decision-rights.md |
| `governance/04-sources-of-truth.md` | `engineering-control/governance/04-sources-of-truth.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/04-sources-of-truth.md |
| `governance/05-risk-model.md` | `engineering-control/governance/05-risk-model.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/05-risk-model.md |
| `governance/06-agent-autonomy.md` | `engineering-control/governance/06-agent-autonomy.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/06-agent-autonomy.md |
| `governance/07-pack-standard.md` | `engineering-control/governance/07-pack-standard.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/07-pack-standard.md |
| `governance/08-definition-change-policy.md` | `engineering-control/governance/08-definition-change-policy.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/08-definition-change-policy.md |
| `governance/09-lifecycle-and-gates.md` | `engineering-control/governance/09-lifecycle-and-gates.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/09-lifecycle-and-gates.md |
| `governance/10-evidence-standard.md` | `engineering-control/governance/10-evidence-standard.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/10-evidence-standard.md |
| `governance/11-git-pr-review-standard.md` | `engineering-control/governance/11-git-pr-review-standard.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/11-git-pr-review-standard.md |
| `governance/12-ci-gates-and-exceptions.md` | `engineering-control/governance/12-ci-gates-and-exceptions.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/12-ci-gates-and-exceptions.md |
| `governance/13-release-rollout-rollback.md` | `engineering-control/governance/13-release-rollout-rollback.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/13-release-rollout-rollback.md |
| `governance/14-outcome-measurement.md` | `engineering-control/governance/14-outcome-measurement.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/14-outcome-measurement.md |
| `governance/15-document-governance.md` | `engineering-control/governance/15-document-governance.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/15-document-governance.md |
| `governance/16-ai-data-security-policy.md` | `engineering-control/governance/16-ai-data-security-policy.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/16-ai-data-security-policy.md |
| `governance/17-skill-openspace-lifecycle.md` | `engineering-control/governance/17-skill-openspace-lifecycle.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/17-skill-openspace-lifecycle.md |
| `governance/18-redmine-workflow.md` | `engineering-control/governance/18-redmine-workflow.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/18-redmine-workflow.md |
| `governance/19-ase-qsre-interface-contract.md` | `engineering-control/governance/19-ase-qsre-interface-contract.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/19-ase-qsre-interface-contract.md |
| `governance/20-compliance-obligations-register.md` | `engineering-control/governance/20-compliance-obligations-register.md` | https://github.com/J4mes0n-04/engineering-control/blob/v1.0.0-rc.1/governance/20-compliance-obligations-register.md |

После удаления вместо каталога в PDE остаётся тонкий `governance/README.md` (или `docs/governance-pointer.md`) со ссылкой на pin: repository + tag + полный SHA. Содержание норм в PDE больше не дублируется.

### B. Общие schema и shared templates (Units 2–3)

| Удаляемый или заменяемый путь в PDE | Новое местоположение | Примечание |
| --- | --- | --- |
| `schemas/pack.schema.json` | `engineering-control/schemas/pack.schema.json` | PDE validator читает schema из pin/path, локальная копия удаляется только после адаптации scripts |
| `templates/ase-handoff.md` | `engineering-control/templates/ase-handoff.md` | PDE может оставить stub со ссылкой |
| `templates/qsre-feedback.md` | `engineering-control/templates/qsre-feedback.md` | то же |
| `templates/evidence-bundle.md` | `engineering-control/templates/evidence-bundle.md` | то же |
| `templates/definition-change.md` | `engineering-control/templates/definition-change.md` | то же |
| `templates/decision-log.md` | `engineering-control/templates/decision-log.md` | то же |
| `templates/outcome-check.md` | `engineering-control/templates/outcome-check.md` | то же |
| `templates/release-plan.md` | `engineering-control/templates/release-plan.md` | то же |
| `integrations/redmine/field-mapping.yaml` | `engineering-control/integrations/redmine/field-mapping.yaml` | reference dependency; PDE integration README остаётся |

### C. Не удалять этим PR

- `workspaces/**`
- `.agents/skills/**`, `.cursor/rules/**`, `.codex/**`
- `templates/pack-mini.md`, `templates/pack-full.md`, `templates/pack.json`, `templates/redmine-outcome.md`
- `config/features.yaml`, будущий `config/control-plane.yaml`
- локальные `.github/workflows/**` до отдельного решения по callers
- `operations/**`, `architecture/**` PDE-specific документы
- `AGENTS.md`, `README.md`, `SECURITY.md`, `CHANGELOG.md`

## Обязательное содержание execution Pull Request

Заголовок: `Remove PDE governance duplicates after stabilization`

Тело PR должно содержать все поля ниже. Без них merge запрещён.

```text
Reason: <минимум 20 символов — почему дубли больше не нужны>

Governance impact: <минимум 20 символов — что меняется для источника истины>

Removed files:
- <путь>

New locations:
- <путь PDE> → <URL tag/SHA в engineering-control>

History links:
- baseline PDE: pde-baseline-v0.1.0 / a8df543...
- control pin: <tag> / <full SHA>
- pre-removal PDE commit: <full SHA>

Rollback plan:
1. Revert merge commit execution PR.
2. Восстановить governance/ из pre-removal SHA или tag pde-baseline-v0.1.0.
3. Вернуть control-plane mode в shadow/local-fallback.
4. Прогнать doctor + validate-repository + validate-pack.
5. Не использовать force-push.

Validation evidence:
- [ ] pwsh ./scripts/doctor.ps1
- [ ] pwsh ./scripts/validate-repository.ps1
- [ ] pwsh ./scripts/validate-pack.ps1
- [ ] pwsh ./scripts/check-links.ps1
- [ ] CI green on PR
- [ ] ASE/QSRE pin compatibility checked
- [ ] Parallel period exit criteria met (link to journal)

Owner approval:
- Approver: <GitHub login>
- Decision date: <YYYY-MM-DD>
- Decision record: <path or issue URL>
```

## План отката (кратко)

| Шаг | Действие |
| --- | --- |
| 1 | `git revert` merge-коммита execution PR в PDE |
| 2 | Убедиться, что `governance/**` снова на месте и совпадает с pre-removal деревом |
| 3 | Не менять `authoritative` control; при сомнении вернуть PDE pin в `shadow` |
| 4 | Прогнать validators и дождаться зелёного CI |
| 5 | Зафиксировать инцидент и причину отката в decision log |

Откат **не** делается через `git push --force` в `main`.

## Подтверждение успешных проверок до открытия PR

Перед открытием execution PR владелец подтверждает:

1. Выход из [parallel-stabilization-period.md](../operations/parallel-stabilization-period.md).
2. Stable или согласованный RC control с `authoritative: true` **уже принят отдельным cutover-решением** (это не часть данного PR, но является его предпосылкой).
3. PDE читает нормы из pin; локальные дубли больше не используются scripts/skills.
4. Сравнение PDE `governance/` и control pin не имеет неразрешённых смысловых расхождений.
5. CODEOWNERS и branch protection активны.

Если cutover ещё не выполнен, этот план остаётся Draft, а файлы в PDE не трогаются.

## Одобрение владельца

| Поле | Значение |
| --- | --- |
| План подготовлен | 2026-09-20 |
| План утверждён к исполнению | _ожидает_ |
| Approver | _ожидает_ |
| Ссылка на решение | _ожидает_ |

Пока строка «План утверждён к исполнению» пуста, удаление файлов из `PROD` запрещено.
