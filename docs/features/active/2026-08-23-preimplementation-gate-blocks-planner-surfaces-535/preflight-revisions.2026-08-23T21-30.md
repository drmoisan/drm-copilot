# Preflight Revisions — plan.2026-08-23T20-40.md (Issue #535)

- Timestamp: 2026-08-24T01:30:00Z
- Source: atomic-executor preflight (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
- Signal: PREFLIGHT: REVISIONS REQUIRED
- Plan under validation: docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/plan.2026-08-23T20-40.md

## What passed

- Validator gate: `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>` exit 0, zero `PLAN GATE WARNING:` lines (G1–G6 clean).
- Path existence: all four hook copies, both test suites, both SKILL.md kickoff sources, all four Phase 0 policy files, the research file, and spec.md/issue.md exist. The two pinned markers `Preparation mode: true.` and `route_id: preparation.` are present verbatim at `.claude/skills/parallel-plan/SKILL.md:105` and `.claude/skills/epic-plan/SKILL.md:99`.
- Task IDs sequential per phase (P0-T1..T9, P1-T1..T3, P2-T1..T9, P3-T1..T8, P4-T1..T8).
- Evidence paths all resolve under `<FEATURE>/evidence/<kind>/`.
- Per-batch cap: Phase 1 = 0 prod + 1 test; Phase 2 = 2 prod + 1 test; Phase 3 = 2 prod + 1 test.
- Work mode full-bug; AC source spec.md only; 14 AC checkboxes covered exactly once by check-off tasks.
- `[P1-T2]` `[expect-fail]` tagged, runs new tests against unmodified hook, declares `ExpectedExitCode:`.
- Orchestrator checkpoint ready, so executor writes will pass the preimplementation gate.
- Coverage tooling: both canonical hooks already registered in `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; file-level `scan_folders` entries resolve correctly.

## Blocking findings and plan delta

### D1 — The plan cannot complete: the PowerShell batch-budget hook denies the 4th production file

`.claude/hooks/enforce-powershell-batch-budget.ps1` is registered on `Write|Edit` in `.claude/settings.json:149`. `Invoke-PowerShellBatchBudgetEntryPoint` defaults `$prodCap = 3`, and state accumulates for the whole session in `.claude/state/powershell-batch-budget.<session>.json`. All four hook copies classify as production (`Invoke-PowerShellBatchBudgetDecision` line 127: not under `tests/`, not `*.Tests.ps1`). Batch 1 records 2 production files; batch 2's second production write is the 4th distinct file and is denied. The per-batch split does not reset the counter, so `[P3-T2]` fails mid-execution.

Add as the last task of Phase 2 (no renumbering required):

```
- [ ] [P2-T10] Reset the PowerShell batch-budget state before Phase 3 so the four production hook copies do not exhaust the per-session production cap of 3 enforced by `.claude/hooks/enforce-powershell-batch-budget.ps1`. Run `Remove-Item -LiteralPath (Join-Path '.claude/state' ("powershell-batch-budget." + ($(if ($env:CLAUDE_SESSION_ID) { $env:CLAUDE_SESSION_ID } else { 'default' })) + ".json")) -Force -ErrorAction SilentlyContinue`, which is the reset mechanism named in the hook's own deny message. Record in docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/other/batch-budget-reset.<timestamp>.md with Timestamp:, Command:, EXIT_CODE:, Output Summary: (state file absent after the reset). Acceptance: artifact exists; the state file does not exist when Phase 3 begins.
```

### D2 — The Claude canonical/bundle pair is byte-identity-gated, not hunk-gated

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts content equality for every non-memory `.claude/**` file against its bundled counterpart (lines 119–126). The two copies are byte-identical at HEAD (both SHA256 `66fee0fe14619c0037b9d3d5150cbb800936b67aac7d495b0e2a090f75669677`). `[P2-T2]`'s acceptance ("the edited hunks are identical to the P2-T1 hunks") is weaker than the enforced contract.

Replace `[P2-T2]`:

```
- [ ] [P2-T2] Delegate to powershell-typed-engineer: apply the identical behavioral change to extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 so the file is byte-identical to .claude/hooks/enforce-orchestration-preimplementation-gate.ps1. Byte-identity is required, not merely identical hunks: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py compares every repo .claude/** file to its bundled counterpart for content equality. Verify by comparing Get-FileHash -Algorithm SHA256 of the two paths and record both hash values in docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/other/claude-pair-hash.<timestamp>.md with Timestamp:, Command:, EXIT_CODE:, Output Summary:. Acceptance: the two SHA256 hashes are equal and recorded; file under 500 lines.
```

Correspondingly amend `[P4-T4]` section (d): the Claude bundle inherits the canonical Claude measurement via the SHA256 equality recorded in `[P2-T2]`, not via a hunk comparison.

### D3 — Two Python push-down contract suites gate this change and are never run

The Claude bundle edit is gated by a pytest contract (D2) and the Codex bundle path is enumerated in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:98`. Neither runs in the plan's QA loop.

Amend the preamble language-scope sentence to read: PowerShell toolchain plus a targeted pytest leg for the two push-down contract suites, which gate the two bundle mirrors. Insert a new Phase 4 task and renumber the trailing tasks (`[P4-T6]`→`[P4-T7]`, `[P4-T7]`→`[P4-T8]`, `[P4-T8]`→`[P4-T9]`):

```
- [ ] [P4-T6] Push-down parity verification: run poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py. These suites gate the two bundle mirrors edited in P2-T2 and P3-T2; the Claude suite asserts content equality for every repo .claude/** file against its bundled counterpart. On failure, restore byte-identity and restart the PowerShell loop from P4-T1. Record in docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/qa-gates/pushdown-parity.<timestamp>.md with Timestamp:, Command:, EXIT_CODE:, Output Summary: (pass/fail counts). Acceptance: exit code 0, zero failed tests.
```

### D4 — Final QA misses two suites that dot-source the changed hooks

`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:65-66` dot-sources the Claude hook and asserts the deny shape — spec.md line 166 claims this suite "continues to pass without modification", which the plan never demonstrates. `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:240` dot-sources the Codex hook.

Amend `[P4-T3]` to scope the run to the folders `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` (which contain all four affected suites) rather than the two named files, keeping the same coverage and evidence requirements.

### D5 — Deny-case tests are non-deterministic unless an explicit checkpoint is supplied

`Invoke-OrchestrationPreimplementationGateDecision` (hook lines 204–206) falls back to `Get-CheckpointContent`, which reads `artifacts/orchestration/orchestrator-state.json` relative to the process working directory. That file exists in this worktree and is ready, so any deny case run without `-CheckpointRaw` returns allow. The existing suite always supplies an explicit checkpoint for deny cases (line 59, `ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false`).

Amend `[P1-T1]` by appending to its task text:

```
Every deny case (b, c, g, h, i, j) MUST supply an explicit not-ready -CheckpointRaw built with the existing ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false helper. Omitting it makes the decision depend on the on-disk artifacts/orchestration/orchestrator-state.json, which is currently ready, so the deny assertion would read allow and the test would be environment-dependent, violating the determinism requirement in .claude/rules/general-unit-test.md.
```

### D6 — Per-file coverage numbers are not produced by the stated commands

PoshQC replays only Pester's aggregate `CoverageReport` string (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:431-451`). `CodeCoverage.Path` is a global ~100-entry allow-list, so a narrowly scoped run yields a low aggregate that is not the metric the thresholds are stated against. Per-file line coverage must be read from `artifacts/pester/powershell-coverage.xml` (CoverageGutters/JaCoCo format) or its `.koverage.xml` sibling. Tasks `[P0-T8]`, `[P0-T9]`, `[P2-T4]`, `[P3-T5]`, `[P4-T3]`, `[P4-T4]` demand a numeric per-file percentage the stated command does not print.

Amend each of those six tasks by appending:

```
Extract the numeric per-file line-coverage percentage from the runner-generated coverage artifact artifacts/pester/powershell-coverage.xml (CoverageGutters/JaCoCo per-file counters), not from the aggregate console summary, and record the extracted numeric value in Output Summary:. Coverage instrumentation is supplied by the standing CodeCoverage.Path allow-list in scripts/powershell/PoshQC/settings/pester.runsettings.psd1, which already registers both canonical hook files; the MCP test tool exposes no per-invocation coverage parameter.
```

### D7 — [P3-T3] has 21 lines of headroom and a premise the file does not match

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is 478 lines (limit 500). Its only preimplementation-gate decision assertions are deny cases at lines 217–235, which the two exemptions do not change, so the work is purely additive.

Replace `[P3-T3]`'s acceptance with an explicit budget:

```
- [ ] [P3-T3] Delegate to powershell-typed-engineer: add codex-side decision coverage for the two exemptions to tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1. The file's existing preimplementation-gate assertions (the deny cases in the It named 'denies preimplementation and batch-budget violations through their pure decisions') are unchanged by the exemptions, so this task is purely additive. The file is 478 lines against the 500-line limit, so the addition MUST be a single table-driven It of at most 18 lines covering one exempt checkpoint-literal allow and one preparation-mode delegation allow, in the file's existing builder and assertion style. The byte-identity It is not edited. Acceptance: the file's line count after the edit is under 500 (recorded in P4-T5); no existing assertion is removed or weakened.
```

### D8 — [P3-T1] names a helper the .codex copy cannot call

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` dot-sources only `codex-pretooluse-file-mapping.ps1`, which neither imports `.claude/lib/hook-payload/HookPayload.psm1` nor defines `Get-ClaudeHookToolInputString`.

Amend `[P3-T1]` by appending:

```
The .codex copy has no access to Get-ClaudeHookToolInputString (it dot-sources only codex-pretooluse-file-mapping.ps1, which does not import the Claude HookPayload.psm1). Read subagent_type and prompt with the Get-StringProperty helper already defined in that file. Do not add a cross-runtime import of .claude/lib/hook-payload/HookPayload.psm1.
```

### D9 — [P4-T5] omits the file closest to the 500-line limit

`[P4-T5]` counts four hook copies plus the Claude test file (five). It omits `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Amend `[P4-T5]` to count six files and change its acceptance to "all six counts under 500".

### D10 — [P2-T9] checks off an AC item before its evidence exists

`[P2-T9]` checks off spec.md AC item 11, whose text requires passing tests for all thirteen case groups; group 13 is the Codex parity group, first verified at `[P3-T5]`. Move `[P2-T9]` into Phase 3 as a new task placed after `[P3-T5]`, renumbering Phase 3's trailing check-off tasks accordingly (or gate its acceptance on `[P3-T5]` having passed).

## Notes recorded but not requiring a delta

- The two bundle mirrors are absent from `CodeCoverage.Path` and cannot be added without duplicating their canonical counterparts; `[P4-T4]`'s inheritance argument is correct once D2 strengthens it to hash equality.
- Repo-wide format/analyze tasks are correct: with no `scan_folders`, `Get-PoshQCFileList` scans the resolved root recursively.
- Commit tasks `[P2-T5]` and `[P3-T6]` carry no evidence artifact; acceptable, verifiable from `git log`.
