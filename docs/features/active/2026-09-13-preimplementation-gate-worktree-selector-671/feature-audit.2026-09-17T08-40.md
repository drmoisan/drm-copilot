# Feature Audit: Preimplementation Gate Worktree Selector (LACS) (#671)

---

**Audit Date:** 2026-09-17
**Feature Folder:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration`
**Head Branch:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/worktree-scoped-state-resolution-integration` (commit `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
- **Head branch/commit:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671` (commit `03f4f305765e15745b9275f3a8fd42758f2c6873`)
- **Merge base:** `79fd5a95c00cd99238b69a3195788206ae96f4cd`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-17 12:33:33 UTC at head `03f4f305`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/**`
  - Additional evidence:
    - reviewer parse of `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`;
    - reviewer read-only probe of `Test-ExemptOrchestrationStagingCommand`;
    - reviewer `git diff` against the merge base, plus `sha256sum`, `wc -l`, and Grep literal checks.
- **Feature folder used:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`. For `full-bug`, `spec.md` is the only AC source.
- **Scope note:** The spec's criteria cite `git diff --merge-base main`. This branch targets the epic integration branch, so the reviewer evaluated the diff-based criteria against the resolved merge base `79fd5a95`. The executor's `--merge-base main` evidence shows the same empty or additive-only results. PR context was fresh relative to head and was not regenerated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` — only source (`## Acceptance Criteria`, 24 checkbox items)

### Acceptance criteria

1. The seven `issue #671 LACS allow` rows all pass in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, under `Context 'issue #671 worktree selector allow cases'`, verified by a Pester run listing node `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` as Passed.
2. The same seven allow rows, with identical label text, all pass in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
3. The chained-segment allow is pinned: node `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` passes in both command-exemption suites.
4. The `cd`-chain denial is pinned: node `denies issue #671 cd chain into the target worktree` passes in both command-exemption suites.
5. Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass: `Select-String -SimpleMatch` for each of the tokens `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`, `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, and `LACS L8` returns at least one line in each suite file, and the Pester run reports every matching node as Passed.
6. The pathspec, option, and metacharacter restrictions are not weakened (epic must-not-regress). Nodes `denies issue #671 selector with a non-exempt pathspec operand`, `denies issue #671 selector with the tree-wide all flag`, `denies issue #671 selector with an absolute pathspec operand`, and `denies issue #671 selector with an output redirection` pass in both suites.
7. No existing assertion is reversed. `git diff --merge-base main -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` contains no removed content line (a line beginning with a single `-` that is not the `---` file header), and all 45 pre-existing `D4 row` deny rows plus all eight pre-existing allow rows in each suite report Passed.
8. The four gate files are byte-unchanged: `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` produces empty output.
9. The four modes files are byte-unchanged: the same `git diff --merge-base main` command run against the four `enforce-orchestration-preimplementation-gate-modes.ps1` paths produces empty output.
10. The epic-merge gate's matcher is not widened (epic must-not-regress). `git diff --merge-base main -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1` produces empty output, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` both pass.
11. The helpers diff is confined to one axis: in `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line's text occurs within the pre-change lines 227–236 block, and no hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks.
12. Gates still deny when a required document is genuinely absent (epic must-not-regress). Nodes `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` and `blocks an implementation write when the checkpoint omits the feature folder` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` both pass.
13. Epic and standalone topologies behave exactly as now when cwd and target coincide (epic must-not-regress). Nodes `allows staging an epic document under the epics tree` and `allows a chained two-segment line whose every segment is independently exempt` pass unmodified in both command-exemption suites, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` all pass with zero failures.
14. Node `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` in the new suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, comparing `Get-FileHash` output across all four `-helpers.ps1` paths.
15. Bundled-payload mirroring is complete. `git diff --merge-base main --name-only` lists all four `enforce-orchestration-preimplementation-gate-helpers.ps1` paths (the two canonical and the two bundled), node `keeps the canonical hooks byte-identical to their bundled copies` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
16. No file exceeds the 500-line cap. Node `keeps every surface copy of the helpers module under the 500-line cap` passes, the post-change line count of each of the four helpers copies is recorded in the QA-gate evidence artifact, and the existing Codex 500-line contract assertion in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes.
17. An **executed** fail-before capture exists at `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/`, produced before any production edit, carrying `Timestamp:`, `Command:`, and `EXIT_CODE:` fields and the eight-row result table, with rows 2 and 3 recorded as `False`. A hand-trace does not satisfy this criterion.
18. An **executed** pass-after capture exists at the same canonical evidence location, with rows 2 and 3 recorded as `True` and rows 1, 4, 5, 6, 7, and 8 identical to the fail-before capture.
19. Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`, and coverage on the changed lines of the helpers file does not regress. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
20. The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` reports no file changed on a second invocation, `mcp__drm-copilot__run_poshqc_analyze` reports zero findings for the four edited helpers copies and the three test files, and `mcp__drm-copilot__run_poshqc_test` reports zero failed tests.
21. No Python leg is introduced: `git diff --merge-base main --name-only` contains no path ending in `.py`.
22. The change adds no new production file and no F1 dependency: `git diff --merge-base main --name-only` lists exactly four production `.ps1` paths, all of them `enforce-orchestration-preimplementation-gate-helpers.ps1`, and `Select-String -SimpleMatch 'Import-Module'` over those four files returns no line.
23. The helpers module's declared purity survives: `Select-String -SimpleMatch 'Pure string logic only: no disk, process, network, or environment access'` returns exactly one line in each of the four helpers copies, and `Select-String -SimpleMatch` for each of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` returns no line in any of the four copies.
24. The nested-subdirectory widening is recorded in the helpers file: `Select-String -SimpleMatch 'Accepted widening'` returns at least one line in each of the four helpers copies, and the surrounding comment states the measured exposure (seven Markdown test fixtures under the `resolve_execute_plan_prompt` fixture tree) and notes that the epic's F1 resolution module composes upstream to close it later without a schema change.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven LACS allow rows pass (Claude) | PASS | JUnit: the 7 allow nodes are Passed; `evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md` | reviewer parse of `artifacts/pester/pester-junit.xml` | None of the 8 failed nodes is an allow row. |
| 2 | Same seven allow rows pass (Codex) | PASS | Diff shows identical labels; JUnit failed list contains no Codex allow row; `evidence/regression-testing/codex-exemption-suite.2026-09-14T00-20.md` | `git diff 79fd5a95...HEAD -- tests/`; JUnit parse | |
| 3 | Chained-segment allow pinned in both suites | PASS | Allow 5 present in both suites and not in the failed list | JUnit parse | |
| 4 | `cd`-chain denial pinned in both suites | PASS | Row present in both suites and not in the failed list | JUnit parse | |
| 5 | Each LACS L1–L8 has a deny row in both suites, and all pass | FAIL | All 12 tokens are present (Grep count 12 per suite). `denies issue #671 LACS L3a`, `L3b`, and `L8` are Failed in both suites. | Grep `LACS L(1a\|...\|8) ` over `tests/scripts`; JUnit parse (8 failures) | L3a/L3b fixtures do not match the gate trigger. L8 fails because of the empty-token fail-open (code-review CR-1, CR-2). |
| 6 | Pathspec, option, and metacharacter restrictions not weakened | PASS | The four named deny nodes pass in both suites | JUnit parse; `evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md` | |
| 7 | No existing assertion reversed | PASS | Numstat `54 0` and `55 0`; 45 D4 deny and 8 allow rows Passed per suite | `git diff 79fd5a95...HEAD -- <two suites>`; `evidence/qa-gates/diff-additive-only-test-suites.2026-09-14T01-00.md`; `evidence/regression-testing/exemption-regression-guards.2026-09-14T00-20.md` | |
| 8 | Four gate files byte-unchanged | PASS | Empty diff | `git diff --stat 79fd5a95 HEAD -- <4 gate files>` | Reviewer re-ran against the resolved merge base. |
| 9 | Four modes files byte-unchanged | PASS | Empty diff | `git diff --stat 79fd5a95 HEAD -- <4 modes files>` | |
| 10 | Epic-merge gate matcher not widened | PASS | Empty diff for 5 paths; merge-gate suites 56/0 and 12/0 | `git diff --stat 79fd5a95 HEAD -- <5 paths>`; `evidence/qa-gates/diff-confinement-shared-parser.2026-09-14T01-00.md` | |
| 11 | Helpers diff confined to one axis | PASS | Reviewer diff: 3 removed lines, all comment lines of the pre-change row-14 block; hunks touch only the constant area (new lines after line 37), the new function, and the `Test-ExemptOrchestrationSegmentToken` prologue | `git diff 79fd5a95...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`; `evidence/qa-gates/diff-confinement-helpers.2026-09-14T01-00.md` | |
| 12 | Gates still deny when a required document is absent | PASS | Both nodes Passed; suite 35/0 | `evidence/qa-gates/must-not-regress-rollup.2026-09-14T01-00.md` | |
| 13 | Epic/standalone topologies unchanged when cwd equals target | PASS | Both nodes Passed in both suites; mode suites 87/0, 55/0, 11/0 | `evidence/qa-gates/must-not-regress-rollup.2026-09-14T01-00.md` | |
| 14 | SHA256 parity node passes | PASS | Node Passed; reviewer `sha256sum` shows 4 identical values | `sha256sum <4 copies>`; `evidence/regression-testing/helpers-parity-suite.2026-09-14T00-20.md` | |
| 15 | Bundled-payload mirroring complete | PASS | All 4 helpers paths in `git diff --name-status`; Codex byte-identity node Passed; Python contract test Passed (16/16) | `git diff --name-status 79fd5a95...HEAD`; `evidence/qa-gates/python-pushdown-contracts.2026-09-14T01-00.md` | First Python run failed on gitignored state (issue #510 pattern) and passed after reset. |
| 16 | No file exceeds 500 lines | PASS | 433 lines per helpers copy; line-cap node Passed; Codex 500-line contract node Passed | `wc -l`; roll-up evidence | |
| 17 | Executed fail-before capture | PASS | `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` has Timestamp, Command, and EXIT_CODE fields, rows 2 and 3 are `False`, and it was executed against the unmodified hash `45C339FD...` | Read artifact | |
| 18 | Executed pass-after capture | PASS | `evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md`: rows 2 and 3 `True`; rows 1 and 4–8 identical | Read artifact | |
| 19 | Line coverage ≥85% and changed-line coverage does not regress | FAIL | Repo 95.41% (meets 85%). The helpers file regressed from 94.92% to 92.72%; changed lines 253, 254, 258, 259 are unexecuted, and line 319 lost coverage. | reviewer parse of `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md` | Code-review CR-3. |
| 20 | Full PowerShell toolchain passes in a single pass | FAIL | Format and analyze are clean; the test run has 8 failures (6 attributable) | `evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md`; JUnit parse | |
| 21 | No Python leg introduced | PASS | No `.py` path in the branch diff | `git diff --name-status 79fd5a95...HEAD` | |
| 22 | No new production file; no F1 dependency | PASS | Production `.ps1` paths: exactly the 4 helpers copies (all `M`); Grep `Import-Module` returns no line | `git diff --name-status`; Grep over the 4 copies | The only new `.ps1` file is under `tests/`. |
| 23 | Helpers purity survives | PASS | Purity sentence found once per copy (line 5); no forbidden literal in any copy | Grep over the 4 copies | |
| 24 | Nested-subdirectory widening recorded | PASS | `Accepted widening` found at line 45 in each copy; the comment names seven Markdown fixtures under `resolve_execute_plan_prompt` and the F1 upstream composition | Grep; diff inspection | |

---

## Summary

**Overall Feature Readiness:** BLOCKED

**Criteria summary:**
- **PASS:** 21 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 3 criteria (5, 19, 20)

**Top gaps preventing PASS:**

1. Criterion 5: the deny rows `LACS L3a` and `LACS L3b` use commands that the gate trigger does not classify (spec fixture defect). `LACS L8` is allowed because of the pre-existing empty-token fail-open, which the plan did not permit fixing.
2. Criterion 19: coverage regression on the modified helpers file (94.92% → 92.72%). The L3 and L8 rejection lines are unexecuted, and line 319 lost coverage.
3. Criterion 20: the PoshQC test step fails, so the toolchain loop did not close.

**Recommended follow-up verification steps:**

1. After a spec/plan amendment, re-run `mcp__drm-copilot__run_poshqc_test` with coverage. Confirm 0 attributable failures, confirm that lines 253, 254, 258, 259, and 319 are executed, and confirm the helpers-file coverage is at or above 94.92%.
2. Re-run the 20-row reproduction and confirm that row 20 (`git -C "" add ...`) and the probe `git add "" -- src/foo.ps1` return `False`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`
- Total AC items: 24
- Checked off (delivered): 21
- Remaining (unchecked): 3
- Items remaining:
  - Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass: `Select-String -SimpleMatch` for each of the tokens `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`, `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, and `LACS L8` returns at least one line in each suite file, and the Pester run reports every matching node as Passed.
  - Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`, and coverage on the changed lines of the helpers file does not regress. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
  - The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` reports no file changed on a second invocation, `mcp__drm-copilot__run_poshqc_analyze` reports zero findings for the four edited helpers copies and the three test files, and `mcp__drm-copilot__run_poshqc_test` reports zero failed tests.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` | 24 | 21 | 3 | Checkbox-backed |

No source-file checkbox change was made in this review. The executor had already checked the 21 criteria this review evaluates as PASS. The 3 criteria evaluated as FAIL are already unchecked and remain unchecked.
