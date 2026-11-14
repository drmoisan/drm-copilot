# Preflight Fixes - Issue #1173

Timestamp: 2026-11-14T06-10
Plan: docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/plan.2026-11-14T00-13.md
Validator: branch-current Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` passed before and after the fixes (exit 0).

## Fixes

1. `## Execution Rules (bind every task)` | validator-blind defect class (disk-discovered guard outside the task file set) | Added a bullet requiring each new `.claude/lib/docs/*.psm1` module to carry the `.claude/lib` module convention and adding `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` to the task check of each task that creates one. That suite discovers every `.claude/lib` module from disk, so `[P2-T3]`, `[P4-T2]`, `[P4-T4]` and `[P5-T1]` would otherwise fail it only at the phase gate.
2. `[P1-T4]` | validator-blind defect class (brief edit with a ledger chain test) | Added `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` to the task-check suites, because the process-reduction ledger chain reverts stored patches against `.claude/skills/execution-environment/SKILL.md`.
3. `[P4-T1]` | changed existing behavior without a named asserting test | Named `Get-DocsCommandTable carries the coverage and update-ledger rows bound to DocsLedgerCommands.psm1 and the validate row bound to DocsValidateCommands.psm1` in `DocsLedgerCommands.Tests.ps1` as Updated: it asserts the exact `update-ledger` option list, which gains `Operations`.
4. `[P5-T3]` | changed existing behavior without a named asserting test | Named `is registered directly under the 1024 anchor with its module, function and options` in `DocsReferenceWriter.Tests.ps1` as Updated: it asserts the exact `generate-reference` option list, which gains `PathPrefix` (`multi`).
5. `[P6-T4]` | changed existing behavior without a named asserting test | Named the suites that read `python-surface-corpus.json` or `python-native-corpus.json` (four analyzer suites, two inventory suites, the native protocol suite, the native parity suite and the pytest corpus test) with their disposition: the corpus expected entries are extended for the new fixture sources.

Each fix names tests or suites only; no task was added, removed or reordered, and no asserted value was changed.
