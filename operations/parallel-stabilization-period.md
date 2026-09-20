# Период параллельной работы (этап 10 / пункт 30)

Document ID: PDE-OPS-PARALLEL-001  
Type: Operations checklist  
Status: Active observation  
Version: 0.1.0  
Owner: Platform Owner  
Scope: Параллельная работа PDE, `engineering-control`, ASE и QSRE до разрешения удаления локальных дубликатов.  
Effective date: 2026-09-20  
Review cycle: после каждого полного тестового цикла

## Назначение

Пока `engineering-control` остаётся `staging` и `authoritative: false`, PDE сохраняет полный локальный `governance/`. ASE и QSRE уже работают по pin `v1.0.0-rc.1`. Этот документ задаёт период параллельной работы: общие правила проверяются на практике, но локальные копии в PDE **не удаляются**.

Удаление дубликатов оформляется только отдельным планом и отдельным Pull Request: [governance-duplicate-removal-plan.md](../architecture/governance-duplicate-removal-plan.md).

## Входные условия периода

Период наблюдения можно вести, если выполнено:

| Условие | Статус на 2026-09-20 |
| --- | --- |
| Существуют четыре репозитория на GitHub | выполнено |
| Tag `pde-baseline-v0.1.0` → commit `a8df54374e2b0db6c13175c7bf1b1cf073a7441a` | выполнено |
| Tag `engineering-control v1.0.0-rc.1` → commit `abd0982171341438cab80267099b951a2027be0b` | выполнено |
| ASE pin = `v1.0.0-rc.1` / тот же SHA, `mode: shadow` | выполнено |
| QSRE pin = `v1.0.0-rc.1` / тот же SHA, `mode: shadow` | выполнено |
| PDE `config/control-plane.yaml` в `mode: shadow` | **не выполнено** |
| Reusable workflows этапа 9 влиты в `engineering-control` main | **ожидает** PR https://github.com/J4mes0n-04/engineering-control/pull/4 |
| Минимум один сквозной shadow pilot PDE → ASE → QSRE → PDE | **не выполнен** |

Наблюдение можно начинать по уже доступным проверкам. **Выход** из периода и старт PR удаления дубликатов запрещены, пока не закрыты строки «не выполнено» / «ожидает» и не пройдены циклы ниже.

## Обязательные тестовые циклы

Нужно минимум **три** полных воспроизводимых цикла. Каждый цикл — отдельная запись в таблице в конце файла.

Цикл считается полным, только если пройдены все шаги:

1. Signal → Pack в PDE (`workspaces/projects/...`, не `examples/`, не `av-control-business` как целевой архитектуры).
2. Ready Review человеком.
3. PDE → ASE handoff по contract `1.0.0` и ACK.
4. Implementation PR + Evidence Bundle.
5. ASE → QSRE handoff и независимый review.
6. QSRE → PDE feedback.
7. Outcome Check с вердиктом `scale` / `keep` / `adapt` / `revert`.
8. Фиксация SHA Pack, implementation и feedback; без ручного копирования содержимого Pack между репозиториями.

Для пилота использовать нейтральный R0–R1 Outcome. Автоматизация этапа 9 может создавать только Issue; merge, изменение Pack и Ready-решение остаются за человеком.

## Проверки пункта 30

### 1. Воспроизводимость

- Второй участник по README каждой среды повторяет doctor и validators без автора процесса.
- Один и тот же Pack SHA даёт одинаковый результат contract validation в ASE/QSRE.
- Handoff examples из `engineering-control/contracts/examples/` проходят `validate-contracts.ps1`.

Команды:

```powershell
# PDE
Set-Location <pde-root>
pwsh ./scripts/doctor.ps1
pwsh ./scripts/validate-repository.ps1

# engineering-control
Set-Location <control-root>
pwsh ./scripts/validate-control.ps1

# ASE / QSRE
git submodule update --init --recursive
pwsh ./scripts/doctor.ps1
pwsh ./scripts/validate-repository.ps1
pwsh ./scripts/validate-handoffs.ps1
```

### 2. Совместимость версий

| Артефакт | Ожидание |
| --- | --- |
| ASE/QSRE `control.tag` | `v1.0.0-rc.1` |
| ASE/QSRE `control.commit` | `abd0982171341438cab80267099b951a2027be0b` |
| Submodule HEAD | совпадает с pin, без локальных правок vendor |
| Contracts | major `1.x` согласованы consume/produce |
| `authoritative` | `false` до cutover |
| Callers reusable workflows | только после SHA, где файлы уже есть (не `v1.0.0-rc.1`) |

### 3. Доступ сотрудников

- Сотрудник работает через fork + Pull Request ([integrations/github/README.md](../integrations/github/README.md)).
- Прямой push в защищённый `main` control/ASE/QSRE запрещён.
- CODEOWNERS и branch protection проверены тестовым PR.
- Секреты notify App не лежат в Git; Environments `notify-ase` / `notify-qsre` / `notify-pde` настраиваются отдельно.

### 4. Работа CI

Обязательные checks:

- PDE: repository, pack, evidence, governance-change;
- control: `control`, `change-control`;
- ASE: `ase`;
- QSRE: `qsre`.

Фиксировать URL последнего зелёного run на `main` после каждого цикла.

### 5. Восстановление по тегам

```powershell
git fetch --tags
git checkout pde-baseline-v0.1.0
git rev-parse HEAD   # ожидание: a8df54374e2b0db6c13175c7bf1b1cf073a7441a

git checkout v1.0.0-rc.1
git rev-parse 'v1.0.0-rc.1^{}'   # ожидание: abd0982171341438cab80267099b951a2027be0b
```

После проверки вернуться на рабочую ветку `main`. Откат среды — через pin на известный tag/SHA, не через force-push.

### 6. Скрытые ссылки на старые пути

Искать и устранять:

- Markdown-ссылки на локальные абсолютные пути (`C:\...`);
- clone URL устаревшего имени `PDE_ENVIRONMENT`, если репозиторий переименован в `pde-environment`;
- записи `docs/file-catalog.md` на отсутствующие файлы;
- жёстко прошитые пути к удалённым рабочим деревьям в skills/rules;
- вызовы reusable workflows по SHA, где файлов ещё нет.

Допустимы примеры команд с локальными путями владельца в операционных заметках `INC*.md`, если они не являются Markdown-ссылками и помечены как локальные.

## Базовая проверка 2026-09-20

| Проверка | Результат | Комментарий |
| --- | --- | --- |
| Воспроизводимость validators | частично | CI на `main` PDE/ASE/QSRE зелёный; локальный `pwsh` у автора может отсутствовать |
| Совместимость ASE/QSRE pin | pass | оба на `abd0982` / `v1.0.0-rc.1` |
| PDE shadow pin | fail | нет `config/control-plane.yaml` |
| Доступ сотрудников | частично | fork-инструкция есть; тестовый fork-цикл сотрудника не зафиксирован |
| CI | pass для текущих main | PDE `6280b4a`, ASE merge PR #1, QSRE merge PR #1 |
| Восстановление по тегам | pass | оба annotated tag указывают на ожидаемые commit |
| Старые пути | найдены | README clone `PDE_ENVIRONMENT`; устаревшие записи catalog про `av-control-business`; локальные пути в INC как текст |
| Полные циклы 1–3 | не начаты | shadow pilot не проводился |

## Журнал циклов

| Цикл | Дата | Outcome ID | Pack SHA | Implementation SHA | Вердикт Outcome Check | Дефекты | Владелец записи |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | _TBD_ | | | | | | |
| 2 | _TBD_ | | | | | | |
| 3 | _TBD_ | | | | | | |

## Критерии выхода из периода

Выход разрешён только при одновременном выполнении:

1. Три полных цикла записаны и воспроизводимы вторым участником.
2. PDE подключён к control в `mode: shadow` без удаления `governance/`.
3. Pins ASE/QSRE/PDE согласованы; `authoritative` всё ещё `false`.
4. CI всех четырёх репозиториев зелёный на зафиксированных SHA.
5. Восстановление с `pde-baseline-v0.1.0` и `v1.0.0-rc.1` проверено.
6. Критические скрытые ссылки на старые пути закрыты или приняты отдельным documentation PR.
7. Владелец утвердил старт [плана удаления дубликатов](../architecture/governance-duplicate-removal-plan.md) отдельным решением.

До выхода **запрещено**:

- удалять `governance/` из PDE;
- объявлять control `authoritative: true`;
- смешивать PR удаления дубликатов с изменением смысла норм;
- включать cloud OpenSpace или глобальный токен на все репозитории.
