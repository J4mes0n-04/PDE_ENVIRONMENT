# ASE adapter

ASE (`Agentic Software Engineering`) — инженерная функция реализации. `ASE Engineer` — выполняющая её роль человека, а `ASE Environment` — будущая специализированная среда поддержки или автоматизации этой функции. Сейчас адаптер закрепляет стабильный вход реализации независимо от наличия отдельной среды.

## Input

`templates/ase-handoff.md`, immutable Pack SHA, risk/autonomy, AC/NFR и expected evidence.

## Output

Pull Request/commit, technical decisions, карта требований к tests, ограничения реализации, release contribution и остаточный риск.

## Activation

При создании отдельной `ASE Environment` меняется `features.ase_adapter.mode` с `contract-only` на согласованный transport/API. Семантика contract version 1.0 сохраняется или выпускается major-версия.
