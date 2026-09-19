# GitHub integration

## До первого merge

1. Создать GitHub repository из содержимого `PROD`.
2. Заменить placeholders в `.github/CODEOWNERS` на реальные users/teams.
3. Защитить `main`: Pull Request required, approvals required, conversations resolved.
4. Назначить обязательными checks четыре workflow из `.github/workflows/`.
5. Запретить force push и deletion `main`.
6. Ограничить Actions permissions до `contents: read`, кроме отдельно утверждённых workflows.
7. Настроить environments для release, если они появятся.

## Secrets

Текущие четыре workflow не требуют секретов. Redmine token, Unleash token, OTLP credentials и другие секреты добавляются только вместе с включением соответствующей интеграции.

## Рекомендуемые labels

`outcome`, `delivery-slice`, `definition-change`, `governance`, `risk-r2`, `risk-r3`, `waiver`, `integration`, `skill`.
