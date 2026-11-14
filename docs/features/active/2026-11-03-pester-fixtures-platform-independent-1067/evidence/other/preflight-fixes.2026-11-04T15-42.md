# Preflight Fixes — Remediation Plan, cycle 1

Timestamp: 2026-11-04T15-42
Plan: docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067/remediation-plan.2026-11-04T15-31.md
Directive: proportionate remediation cycle (single-pass preflight, then execute)

## Fixes

1. `[P2-T2]` | stale cross-reference (trivial) | `[P2-T3]` requires "a one-line comment matching `[P2-T2]`", but `[P2-T2]` named no comment. Added "with a one-line comment stating that the escape keeps the literal valid for any path" to `[P2-T2]`, which matches the comment wording `[P2-T1]` already requires. No acceptance condition changed.

## Checks performed without a fix

- Installed validator (`validate_orchestration_artifacts`, `plan`): ok.
- Branch-current validator (`scripts.dev_tools.validate_orchestration_artifacts plan`, module form): `plan validation passed`, EXIT 0.
- Anchors re-derived against the tree: `Describe "link-feature-docs.ps1"` `BeforeAll` (sets the variable and defines `function global:gh`, no `AfterAll`); `link-parent-child.Tests.ps1` file-level `BeforeAll` (no `AfterAll`); `sync-agents-from-instructions.Tests.ps1` `$script:PriorSkipScriptExecution` save/restore; `Enter-DrmCopilotShell.Tests.ps1` `Describe "DrmCopilotPromptSupport.ps1"` prompt capture and restore; the four named `It` blocks and the `Create(...)` sources in the three R1-F2/R1-F4 files; the three templates under `docs/features/templates/policy_audit/`; `evidence/qa-gates/coverage-final.2026-11-04T14-46.md`.
- Expect-fail probe for `[P2-T7]` on unmodified code (`SCRATCH/issue-1067-escape-probe.ps1`): `ESCAPE-ROUNDTRIP=True`, `UNESCAPED-PARSE=error`.
- `git grep` for `TestDrive`, `GetTempPath`, `New-TemporaryFile`, and `-Skip` over the five change-set files: 0 matches before any edit, so `[P3-T6]` is satisfiable.
- `git grep` for `global:gh`, `Mock gh`, `CommandName gh`, `Get-Command gh` under `tests/`: one definition (`link-feature-docs.Tests.ps1`) and one fixture-text match (`check-powershell-test-purity.Tests.ps1`), consistent with `## Existing Tests That Assert Changed Behavior`.

Substantive defects: none.
