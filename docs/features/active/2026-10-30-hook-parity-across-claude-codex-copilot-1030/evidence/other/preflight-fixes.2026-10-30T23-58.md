# Preflight Fixes (round two)

Timestamp: 2026-10-30T23-58
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md

Each entry is a trivial in-place fix to task text or plan preamble. No task was added, removed, or reordered, and no asserted value changed.

## Fix 1 - [P0-T3]

- Defect class: ambiguous anchor in a gate comparison (validator-blind).
- Finding: the gate compared the `$script:ReasonPrefix` keys of `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` with "the Codex hooks registered in `.codex/config.toml`". On `HEAD` that file registers 25 distinct hook files across `UserPromptSubmit`, `SubagentStart`, `PreToolUse` and `SubagentStop`, while the table holds 23 keys, which are exactly the `PreToolUse` and `SubagentStop` registrations that `Get-HookRegistration` returns and It `B4: has a reason-prefix entry for every discovered Codex hook and no other` compares. A literal reading would stop execution at the gate with no actual defect present.
- Change: the comparison set is now named as the `PreToolUse` and `SubagentStop` registrations that B4 discovers. The gate still asserts equality with the set B4 enforces.

## Fix 2 - [P1-T1]

- Defect class: incomplete repository-relative path.
- Finding: `hook-import-failure-exemptions.FailClosed.Tests.ps1` exists under both `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, and the task cited the bare file name, along with other bare names in its regression list.
- Change: `PreToolUseSchema.Contract.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1` and `hook-dependency-failure.Claude.Tests.ps1` now carry the `tests/scripts/claude-hooks/` prefix, and `hook-imported-modules-no-stdout.Tests.ps1` carries the `tests/scripts/claude-runtime/` prefix. The seven-suite set is unchanged.

## Fix 3 - `## Pre-Mortem` Test isolation bullet

- Defect class: Pre-Mortem completeness wording.
- Finding: the bullet named the Pester shuffled-seed and single-process runs but did not state why the seeded Jest run and the reversed-order Python run named by the atomic-plan-contract are absent.
- Change: the bullet now states that both are not applicable because the plan creates or changes no Jest or Python test module.
