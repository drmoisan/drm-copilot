# Remediation Plan: Parallel run leaves uncommitted records and worktrees (#995)

Remediation-Mode: proportionate

- Feature folder (`<FEATURE>`): `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
- Inputs: `remediation-inputs.2026-10-29T11-55.md` and `code-review.2026-10-29T11-55.md` (four Minor findings; verdict PASS, no merge-preventing finding)
- `SCRATCH` is `<session scratchpad>/issue-995/`; scratch files start with `issue-995-`. Evidence artifacts record the token `SCRATCH`, never a host path.
- Tool routes, launchers, command-text restrictions, and the batch budget follow the `execution-environment` skill and are not restated here.
- Out of scope: any `enforce-epic-merge-gate*` file, Codex surfaces, `config/file-size-baseline.json`.

## Decisions

- **Finding 1 rule.** The manifest lookup `Find-CleanupWorktreeManifestRemovalRecord` ignores case for every path. The checkpoint-coverage test `Test-CleanupManifestCheckpointCoversPath` is restored to the same rule: it matches when the shared matcher holds on the inputs as given, or holds on the same inputs lower-cased with the invariant culture. The shared matcher in `WorktreeRunRecordPath.psm1` (and its tests M5 and P2) is unchanged and stays ordinal for single-slash POSIX paths, because the gates' allow lookups must remain fail-closed. Only the coverage exclusion, which exists to stop a manifest overriding a checkpoint, widens back to its prior case-insensitive behavior.
- **Finding 2 rule.** Run Closing substep 3 stages only paths beginning `docs/features/`. `artifacts/orchestration/` is dropped from the pathspec sentence because `.gitignore` ignores `/artifacts` and the docs-only precondition rejects any non-`docs/` path. Other mentions of the checkpoint path in the files stay.
- **Finding 3.** Add RE2 deny rows for the epic `features[]` branch (`pr_open`, `worktree_created`, absent status) to `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`.
- **Finding 4.** One exported `Get-WorktreeRunRecordBaseRoot -MainRoot -Read` in `WorktreeRunRecordPath.psm1` replaces `Get-ParallelWorktreeGateBaseRoot` and `Get-EpicWorktreeGateBaseRoot`. No test calls either old name (searched across `tests/`); callers are `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, and `enforce-epic-worktree-removal-gate-resolution.ps1`. The inline base-root list in `Resolve-WorktreeRunTargetByRecord` takes no `Read` object and is left unchanged.
- Production PowerShell files edited: five, plus mirrors. Execution runs on the remediation route, which the batch-budget exemption in the `execution-environment` skill covers.

### Existing tests asserting changed behavior

- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1` X1 (export list): updated to four functions. M5, P2, and the other matcher rows: unchanged, the matcher is not edited.
- `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` (three coverage-test references): unchanged for rooted and relative rows; a case-variant row is added.
- `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1`, `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` (RE1 to RE4), and `WorktreeRunResolution.RelativeRecord.Tests.ps1`: unchanged, because the base-root value each gate computes is identical.
- `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` RC4 and its `AllowedPathPrefixes` constant: updated to accept only `docs/features/`, with a new RC5; RA rows unchanged.

## Phases

### Phase 0 — Baseline

- [x] [P0-T1] Read the policy files in the order of `policy-compliance-order` and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the file exists with the three fields.
- [x] [P0-T2] Run the touched Pester suites with coverage (`WorktreeRunRecordPath.Tests.ps1`, `CleanupWorktreeManifest.Tests.ps1`, `CleanupWorktreeManifestGateMatrix.Tests.ps1`, both `*.RelativeRecord.Tests.ps1` gate suites, `WorktreeRunResolution.RelativeRecord.Tests.ps1`, `parallel-orchestrate-run-closing.Tests.ps1`) and write `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md` with the pass and fail counts read from `artifacts/pester/pester-junit.xml`. Acceptance: the artifact records `EXIT_CODE:` and `Output Summary:` with a numeric passed count and 0 failed.
- [x] [P0-T3] From `artifacts/pester/powershell-coverage.xml` record the baseline line coverage of `CleanupWorktreeManifest.psm1`, `WorktreeRunRecordPath.psm1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, and `enforce-epic-worktree-removal-gate-resolution.ps1` in `<FEATURE>/evidence/baseline/coverage-baseline.<timestamp>.md`. Acceptance: five numeric percentages are recorded.
- [x] [P0-T4] Record the logical line count of each file listed in P0-T3 plus the four test files this plan edits (`CleanupWorktreeManifest.Tests.ps1`, `WorktreeRunRecordPath.Tests.ps1`, `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`, `parallel-orchestrate-run-closing.Tests.ps1`), in `<FEATURE>/evidence/baseline/file-sizes.<timestamp>.md`, counting with `@(Get-Content -LiteralPath <path>).Count`. Acceptance: every count is numeric.

### Phase 1 — Finding 1: manifest coverage case rule

- [x] [P1-T1] In `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`, add a row "CM-case: a POSIX checkpoint record differing from the target only by case covers the target" for `Test-CleanupManifestCheckpointCoversPath` (rooted record `/synthetic/Worktrees/Agent-X`, target `/synthetic/worktrees/agent-x`, no base root), plus a relative-record variant with a base root, plus a negative row where the names differ by more than case. Acceptance: the case rows fail before P1-T2 and the negative row passes before and after; the failing run is recorded in `<FEATURE>/evidence/regression-testing/expect-fail.<timestamp>.md` tagged `[expect-fail]`.
- [x] [P1-T2] In `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, change `Test-CleanupManifestCheckpointCoversPath` so a record also covers the target when `Test-WorktreeRunRecordedPathMatchesTarget` holds on the lower-cased (invariant culture) record, target, and base roots; update the function's `.DESCRIPTION` to state the case rule and its parity with `Find-CleanupWorktreeManifestRemovalRecord`. Acceptance: the P1-T1 case rows pass and every pre-existing row in that suite still passes.
- [x] [P1-T3] Mirror `CleanupWorktreeManifest.psm1` into `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`. Acceptance: `git hash-object` returns the same value for both files.

### Phase 2 — Finding 4: one base-root helper

- [x] [P2-T1] In `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`, add rows B1 to B4 for `Get-WorktreeRunRecordBaseRoot`: main root and read root both present, main root only, read root only (read object lacking `Target`, and `Target` lacking `WorktreeRoot`), and neither (returns an empty string array, not `$null`); update X1 to expect four exported functions. Acceptance: B1 to B4 and X1 fail before P2-T2 and pass after.
- [x] [P2-T2] In `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`, add and export `Get-WorktreeRunRecordBaseRoot` with the body of the two existing helpers (blank entries dropped, string array returned through the comma operator), and update the module `.NOTES` export statement. Acceptance: B1 to B4 and X1 pass.
- [x] [P2-T3] In `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, delete `Get-ParallelWorktreeGateBaseRoot` and call `Get-WorktreeRunRecordBaseRoot` at both call sites. Acceptance: `Get-ParallelWorktreeGateBaseRoot` has no match in the file, and `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` passes unchanged.
- [x] [P2-T4] In `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, delete `Get-EpicWorktreeGateBaseRoot`, call `Get-WorktreeRunRecordBaseRoot` in `Resolve-WorktreeRunTargetByRecord`-adjacent resolution code, and correct the header comment that names the removed helper. Acceptance: `Get-EpicWorktreeGateBaseRoot` has no match in the file.
- [x] [P2-T5] In `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, replace the two `Get-EpicWorktreeGateBaseRoot` calls with `Get-WorktreeRunRecordBaseRoot`. Acceptance: `Get-EpicWorktreeGateBaseRoot` has no match anywhere under `.claude/` and `tests/`, and the epic gate suite passes unchanged.
- [x] [P2-T6] Mirror the four files of P2-T2 to P2-T5 into `extensions/drm-copilot/resources/claude-customizations/.claude/` at the same relative paths. Acceptance: `git hash-object` matches for each of the four pairs.

### Phase 3 — Finding 3: epic gate features[] deny rows

- [x] [P3-T1] In `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`, add RE2b with `-ForEach` rows for the epic `features[]` branch: relative record with `pr_open`, with `worktree_created`, and with no status, each using `Set-RelativeTopology -Epic` and `Get-RunCheckpointText -Kind epic`. Each asserts `deny` and a reason starting `EPIC_WORKTREE_REMOVAL_BLOCKED`. Acceptance: the three rows pass against current production code (deny already holds), so no fail-before artifact applies; record that reason in the self-review artifact of P5-T9.

### Phase 4 — Finding 2: Run Closing substep 3

- [x] [P4-T1] In `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1`, set `AllowedPathPrefixes` to `docs/features/` only, update the header comment, and add RC5 (skill) and RA5 (agent) that collapse whitespace in the Run Closing section and assert the staging sentence does not contain the token `or ` followed by the backticked `artifacts/orchestration/`. Acceptance: RC5 and RA5 fail before P4-T2 and P4-T3 and pass after; the failing run is appended to the expect-fail artifact.
- [x] [P4-T2] In `.claude/skills/parallel-orchestrate/SKILL.md` Run Closing substep 3, state that every pathspec begins with `docs/features/` and drop the `artifacts/orchestration/` alternative, adding one clause that `artifacts/` is gitignored and Run Closing never stages it. Acceptance: RC1 to RC5 pass.
- [x] [P4-T3] Apply the same change to `.claude/agents/parallel-orchestrator.md` Run Closing substep 3. Acceptance: RA1 to RA5 pass.
- [x] [P4-T4] Mirror both files into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` and `.../.claude/agents/parallel-orchestrator.md`. Acceptance: `git hash-object` matches for both pairs and the bundle-copy rows of RC and RA pass.
- [x] [P4-T5] Run the Python contract tests `test_parallel_orchestrator_surface_contracts.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_claude_pack_manifest_completeness.py` from `tests/scripts/dev_tools/`, plus the surface-hash test that uses `PINNED_FROZEN_SURFACE_HASHES`. Acceptance: all pass; none of the two edited files is a pinned frozen surface (confirm by reading the constant).

### Phase 5 — Final QA

- [x] [P5-T1] Run PoshQC format over the changed PowerShell files until it changes nothing, recording the before and after tree status in `<FEATURE>/evidence/qa-gates/poshqc-format.<timestamp>.md`. Acceptance: a second run leaves `git status --porcelain` unchanged from the first run's end state.
- [x] [P5-T2] Run PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the changed files and record the finding count in `<FEATURE>/evidence/qa-gates/pssa.<timestamp>.md`. Acceptance: 0 findings, read from the direct analyzer run.
- [x] [P5-T3] Run the Phase 0 Pester suite set again with coverage and record counts from `artifacts/pester/pester-junit.xml` in `<FEATURE>/evidence/qa-gates/pester-final.<timestamp>.md`. Acceptance: 0 failed, passed count at least the baseline plus the added rows.
- [x] [P5-T4] From `artifacts/pester/powershell-coverage.xml` record post-change line coverage for the five production files and compare with P0-T3 in `<FEATURE>/evidence/qa-gates/coverage-comparison.<timestamp>.md`. Acceptance: each file is at least 85% and no file is below its baseline.
- [x] [P5-T5] Run the Python generator `--check` for the Codex agent variants and the Python contract tests of P4-T5 again. Acceptance: exit 0 and 0 failed.
- [x] [P5-T6] Run isolation checks and record them in `<FEATURE>/evidence/regression-testing/isolation.<timestamp>.md`: a seeded shuffled file-order run of the touched Pester suites with three seeds (each seed and order recorded), a reversed-order run of `test_parallel_orchestrator_surface_contracts.py` and the two push-down contract modules in one process, and a fresh single-process Pester run of the `tests/scripts/claude-hooks`, `tests/scripts/claude-lib`, and `tests/scripts/claude-runtime` trees. Acceptance: 0 failures in every run.
- [x] [P5-T7] Record the logical line count of every changed production, test, and script file in `<FEATURE>/evidence/qa-gates/file-sizes.<timestamp>.md`. Acceptance: every count is at most 500 and no row exceeds its P0-T4 baseline except the files this plan grows.
- [x] [P5-T8] Confirm no temp-file API appears in the added test rows and that `git diff --name-only` against the merge base of `origin/main` and `HEAD`, together with `git status --porcelain`, lists no `enforce-epic-merge-gate` path. Acceptance: both lists contain no such path and no new file outside `<FEATURE>/`, `.claude/`, `tests/`, and the bundle mirror.
- [x] [P5-T9] Self-review: walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. Acceptance: no FAIL row; a FAIL row is fixed and the Phase 5 loop re-run before this file is rewritten.

## Pre-Mortem

- Review checklists: P5-T9 walks all three templates; the four Minor findings are each mapped to a phase, so none is left implicit, and P5-T8 checks the excluded merge-gate files.
- Coverage: P0-T3 and P5-T4 read per-file line coverage from `artifacts/pester/powershell-coverage.xml` for all five changed production files against the 85% threshold and the baseline; new branches are driven by CM-case, B1 to B4, and RE2b rows. PowerShell has no branch gate.
- Mirror parity: every `.claude` edit has a bundle-copy task (P1-T3, P2-T6, P4-T4) verified by `git hash-object` and by the push-down contract tests in P4-T5 and P5-T5. No file is added or renamed, so no pack manifest changes. No fact stated in the execution-environment brief changes (no job, tool route, or batch rule), so no brief-update task applies.
- File size: P0-T4 and P5-T7 record logical line counts; the helper move is net-negative across the hook files and adds one function to `WorktreeRunRecordPath.psm1`, and a split is required if any file passes 500.
- Test isolation: P5-T6 runs three seeded shuffled Pester file orders, a reversed-order Python run, and a fresh single-process Pester run; tests use mocks and in-memory text only, no temp files. No Jest change, so no Jest shuffle applies.
- CI-only behavior: the new rows use POSIX literals and forward-slash relative paths, read no gitignored `artifacts/` state, and the gate suites sit under `tests/scripts/claude-hooks`, which also run in `poshqc / PowerShell hook suites (Linux)`; the case-variant rows depend only on string comparison, not on filesystem case sensitivity.
- Evidence: all artifacts go under `<FEATURE>/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; counts come from the JUnit and coverage XML files because PoshQC MCP results carry no output.
