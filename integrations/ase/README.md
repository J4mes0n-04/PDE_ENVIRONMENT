# ASE adapter

ASE — будущая среда Agentic Software Engineering. Сейчас адаптер закрепляет стабильный вход реализации.

## Input

`templates/ase-handoff.md`, immutable Pack SHA, risk/autonomy, AC/NFR и expected evidence.

## Output

Pull Request/commit, technical decisions, карта требований к tests, ограничения реализации, release contribution и остаточный риск.

## Activation

При создании отдельной ASE среды меняется `features.ase_adapter.mode` с `contract-only` на согласованный transport/API. Семантика contract version 1.0 сохраняется или выпускается major-версия.
