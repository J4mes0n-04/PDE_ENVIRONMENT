# Стандарт Git, Pull Request и review

Document ID: PDE-GOV-011  
Type: Standard  
Status: Draft  
Version: 0.1.0

## Ветки и Pull Request

- Прямая запись в `main` запрещена.
- Один Pull Request решает одну связанную задачу.
- PR содержит Redmine ID, Outcome ID, Pack path/version/SHA, risk, AC/NFR, evidence и rollback impact.
- Для изменения governance указываются затронутые templates, rules, skills, workflows и Outcomes.

## Review

- R0: авторская проверка и CI.
- R1: минимум один peer approval.
- R2: PDE/Engineering review и QSRE function review.
- R3: независимые approvals владельцев продукта, риска/безопасности и release.

CODEOWNERS определяет обязательных владельцев по области. До создания GitHub teams файл содержит временные placeholders, которые необходимо заменить перед branch protection.

## Merge

Разрешён только после обязательных checks и разрешения обсуждений. Force push в защищённую ветку запрещён. Merge commit или squash policy выбирается командой и фиксируется в настройках репозитория.
