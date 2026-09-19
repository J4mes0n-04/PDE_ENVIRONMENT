# PDE repository instructions

## Source of truth

- Read `governance/` before changing rules, templates, skills, CI, or integration behavior.
- Treat `workspaces/projects/` as operational work and `workspaces/examples/` as non-production examples.
- Do not copy a full Product Definition Pack into Redmine; store a link to a Git commit instead.

## Required traceability

- Preserve the chain: Signal -> Outcome -> Pack -> Delivery Slice -> PR -> Evidence -> Release -> Outcome Check.
- Use stable English identifiers such as `OUT-001`, `AC-001`, `NFR-001`, `EVD-001`, and `DC-001`.
- Keep human-readable Russian explanations next to identifiers.

## Change boundaries

- Do not expand scope or alter an Outcome without a Definition Change record.
- Do not edit governance automatically from OpenSpace results. Create a proposal or Pull Request for human approval.
- Do not enable optional integrations or cloud data transfer without an explicit decision recorded in Git.
- Do not treat green tests alone as sufficient evidence.

## Verification

- After changing a Pack, run `pwsh ./scripts/validate-pack.ps1`.
- After changing Evidence, run `pwsh ./scripts/validate-evidence.ps1`.
- After changing repository structure, governance, templates, integrations, skills, or workflows, run `pwsh ./scripts/validate-repository.ps1`.
- Report failed checks and unresolved assumptions; do not describe unverified work as complete.

## Completion

- A delivery task is complete only when acceptance criteria have linked evidence and the required handoff is present.
- An Outcome is complete only after `outcome-check.md` records `scale`, `keep`, `adapt`, or `revert`.
