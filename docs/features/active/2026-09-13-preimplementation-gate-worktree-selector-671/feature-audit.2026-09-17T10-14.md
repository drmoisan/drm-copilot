# Feature Audit: Preimplementation Gate Worktree Selector (LACS) (#671) — Re-audit after Remediation R1

---

**Audit Date:** 2026-09-17
**Feature Folder:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration`
**Head Branch:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation (prior audit: `feature-audit.2026-09-17T08-40.md`)

---

## Scope and Baseline

- **Base branch:** `origin/epic/worktree-scoped-state-resolution-integration` @ `590b26abd1b25948b0590b060da324ba567bf707`
- **Head branch/commit:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671` @ `685bcbf50f492ae1540a50c57b15952d4fdf91e8`
- **Merge base:** `79fd5a95c00cd99238b69a3195788206ae96f4cd`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-17 14:13:59 UTC at head `685bcbf5`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/**`
  - Additional evidence (reviewer, check-only):
    - parse of `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`;
    - PSScriptAnalyzer and `Invoke-Formatter` comparison on the seven PowerShell files;
    - a 21-row read-only probe of `Test-ExemptOrchestrationStagingCommand`;
    - `git diff` against the merge base, `sha256sum`, `wc -l`, and Grep literal checks;
    - a re-run of the two Python push-down contract test files (16 passed).
- **Feature folder used:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`. For `full-bug`, `spec.md` is the only AC source.
- **Scope note:** Several criteria cite `git diff --merge-base main`.
  - `git merge-base main HEAD` resolves to `d93e2916`. The commits between `d93e2916` and the resolved epic merge base `79fd5a95` change only Markdown files.
  - The reviewer therefore evaluated the diff-based criteria against `79fd5a95`. The results for all code paths are identical under either base.
  - PR context was generated at head `685bcbf5` and was not regenerated.
- **Spec amendment note:** Remediation amendment R1 made the following changes, each recorded in `evidence/other/spec-amendment-r1.2026-09-17T09-10.md`:
  - replaced the L3a/L3b fixtures;
  - widened AC 11's permitted-change set;
  - restated AC 19 and AC 20;
  - added AC 25 and AC 26.

  The amendment was requested by `remediation-inputs.2026-09-17T08-40.md`. This audit evaluates the amended text.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` — only source (`## Acceptance Criteria`, 26 checkbox items)

### Acceptance criteria

1. The seven `issue #671 LACS allow` rows all pass in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, under `Context 'issue #671 worktree selector allow cases'`, verified by a Pester run listing node `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` as Passed.
2. The same seven allow rows, with identical label text, all pass in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
3. The chained-segment allow is pinned: node `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` passes in both command-exemption suites.
4. The `cd`-chain denial is pinned: node `denies issue #671 cd chain into the target worktree` passes in both command-exemption suites.
5. Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass: `Select-String -SimpleMatch` for each of the tokens `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`, `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, and `LACS L8` returns at least one line in each suite file, and the Pester run reports every matching node as Passed.
6. The pathspec, option, and metacharacter restrictions are not weakened (epic must-not-regress). Nodes `denies issue #671 selector with a non-exempt pathspec operand`, `denies issue #671 selector with the tree-wide all flag`, `denies issue #671 selector with an absolute pathspec operand`, and `denies issue #671 selector with an output redirection` pass in both suites.
7. No existing assertion is reversed. `git diff --merge-base main -- <two command-exemption suites>` contains no removed content line, and all 45 pre-existing `D4 row` deny rows plus all eight pre-existing allow rows in each suite report Passed.
8. The four gate files are byte-unchanged: `git diff --merge-base main -- <four enforce-orchestration-preimplementation-gate.ps1 paths>` produces empty output.
9. The four modes files are byte-unchanged: the same `git diff --merge-base main` command run against the four `enforce-orchestration-preimplementation-gate-modes.ps1` paths produces empty output.
10. The epic-merge gate's matcher is not widened (epic must-not-regress). `git diff --merge-base main -- <four hook-command-invocation.ps1 paths> .claude/hooks/enforce-epic-merge-gate.ps1` produces empty output, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` both pass.
11. The helpers diff is confined to one axis plus the remediation R1 fail-closed repair. In `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line is one of the following:
    - (a) a line whose text occurs within the pre-change lines 227–236 block;
    - (b) the pre-change line 221 `$Token` parameter declaration, re-added with `[AllowEmptyString()]` as its only change;
    - (c) a line of the pre-change per-segment loop at lines 342–347 whose whitespace-trimmed text equals that of a line added inside the fail-closed `try` block.

    No other hunk removes or modifies a line inside the protected functions or the three pre-existing `$script:` constant blocks.
12. Gates still deny when a required document is genuinely absent (epic must-not-regress). Nodes `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` and `blocks an implementation write when the checkpoint omits the feature folder` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` both pass.
13. Epic and standalone topologies behave exactly as now when cwd and target coincide (epic must-not-regress). Nodes `allows staging an epic document under the epics tree` and `allows a chained two-segment line whose every segment is independently exempt` pass unmodified in both command-exemption suites, and the Claude mode-resolution, Codex mode-resolution, and Codex mode-routing suites all pass with zero failures.
14. Node `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` in the new suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, comparing `Get-FileHash` output across all four `-helpers.ps1` paths.
15. Bundled-payload mirroring is complete. `git diff --merge-base main --name-only` lists all four `enforce-orchestration-preimplementation-gate-helpers.ps1` paths, node `keeps the canonical hooks byte-identical to their bundled copies` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
16. No file exceeds the 500-line cap. Node `keeps every surface copy of the helpers module under the 500-line cap` passes, the post-change line count of each of the four helpers copies is recorded in the QA-gate evidence artifact, and the existing Codex 500-line contract assertion in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes.
17. An **executed** fail-before capture exists at `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/`, produced before any production edit, carrying `Timestamp:`, `Command:`, and `EXIT_CODE:` fields and the eight-row result table, with rows 2 and 3 recorded as `False`. A hand-trace does not satisfy this criterion.
18. An **executed** pass-after capture exists at the same canonical evidence location, with rows 2 and 3 recorded as `True` and rows 1, 4, 5, 6, 7, and 8 identical to the fail-before capture.
19. Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact. In addition, the per-file line coverage of the `.claude/hooks` helpers copy is at or above its pre-change baseline of 94.92% (112 covered of 118), and every instrumented line in the helpers changed-line set has a hit count above zero. No branch-coverage gate applies to PowerShell.
20. The full PowerShell toolchain passes in a single pass, which requires all three of the following:
    - `run_poshqc_format` leaves the SHA256 of the four helpers copies and the three test files unchanged, as shown by paired `Get-FileHash` captures.
    - A direct `Invoke-ScriptAnalyzer` run with `pssa.settings.psd1` reports zero findings for those seven files, alongside a `run_poshqc_analyze` call that returns without error.
    - `run_poshqc_test` writes a JUnit report whose failing nodes are none, or only the two baseline failures, with no failing node whose name contains `issue #671`.
21. No Python leg is introduced: `git diff --merge-base main --name-only` contains no path ending in `.py`.
22. The change adds no new production file and no F1 dependency: `git diff --merge-base main --name-only` lists exactly four production `.ps1` paths, all of them `enforce-orchestration-preimplementation-gate-helpers.ps1`, and `Select-String -SimpleMatch 'Import-Module'` over those four files returns no line.
23. The helpers module's declared purity survives: the purity sentence returns exactly one line in each of the four helpers copies, and `Select-String -SimpleMatch` for each of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` returns no line in any of the four copies.
24. The nested-subdirectory widening is recorded in the helpers file: `Select-String -SimpleMatch 'Accepted widening'` returns at least one line in each of the four helpers copies, and the surrounding comment states the measured exposure and notes that the epic's F1 resolution module composes upstream to close it later without a schema change.
25. The remediation R1 regression rows pass. In both command-exemption suites, all seven of the following nodes pass:
    - `denies issue #671 LACS L8 - empty selector value`
    - `denies issue #671 selector followed by an unmodelled subcommand`
    - `denies issue #671 empty token beside a non-exempt operand`
    - `denies issue #671 empty token after the separator beside a non-exempt operand`
    - `denies issue #671 trailing empty token after a non-exempt operand`
    - `denies issue #671 empty commit message beside a non-exempt operand`
    - `allows issue #671 empty commit message beside an exempt operand`

    In addition, an executed probe records `Test-ExemptOrchestrationStagingCommand` returning `False` with zero error records for `git add "" -- src/foo.ps1` and `git add -- "" scripts/powershell/Sample.ps1`.
26. The selector predicate and the fail-closed guard are pinned at the unit level (remediation R1). In both command-exemption suites, under the Context `issue #671 selector predicate and fail-closed guard`, all of the following pass:
    - the three `accepts issue #671 predicate accept` nodes;
    - the twelve `rejects issue #671 predicate` nodes;
    - node `returns false when segment classification raises an error`.

Items 7, 8, 10, 11, 13, 19, 20, 23, 24, 25, and 26 are condensed or restructured here for length; the authoritative wording is in `spec.md` lines 679–704.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven LACS allow rows pass (Claude) | PASS | JUnit: 7 allow nodes Passed; the Claude suite is 105/105 Passed | reviewer `parse.py`/`suites.py` over `artifacts/pester/pester-junit.xml` | |
| 2 | Same seven allow rows pass (Codex) | PASS | Identical labels (diff); the Codex suite is 105/105 Passed | `git diff 79fd5a95 -- tests/`; `suites.py` | |
| 3 | Chained-segment allow pinned in both suites | PASS | `allow 5` Passed in both suites | `suites.py` (both suites fully Passed) | |
| 4 | `cd`-chain denial pinned in both suites | PASS | Node Passed in both suites | `suites.py` | |
| 5 | Each LACS L1–L8 has a deny row in both suites, and all pass | PASS | All 12 tokens present in both suite files. The `LACS L3a`, `LACS L3b`, and `LACS L8` nodes are Passed in both suites; all 94 `issue #671` nodes are Passed. | `parse.py "LACS L3a" "LACS L3b" "LACS L8"`; diff inspection | Prior FAIL resolved (RF-1, RF-2). |
| 6 | Pathspec, option, and metacharacter restrictions not weakened | PASS | All four nodes Passed in both suites | `suites.py`; diff inspection | |
| 7 | No existing assertion reversed | PASS | Numstat `135 0` / `136 0`. JUnit per suite: 45 pre-existing `D4 row` deny nodes, 1 pre-existing `D4 row 18` allow node, and 8 issue #539 allow nodes, all Passed. | `git diff 79fd5a95 -- <two suites>`; `git grep -c "D4 row" 79fd5a95 -- <two suites>`; `suites.py` | The 46 `D4 row` JUnit nodes are 45 deny rows plus the pre-existing row-18 allow node. |
| 8 | Four gate files byte-unchanged | PASS | Empty diff | `git diff --stat 79fd5a95 -- <4 gate files>` | |
| 9 | Four modes files byte-unchanged | PASS | Empty diff | `git diff --stat 79fd5a95 -- <4 modes files>` | |
| 10 | Epic-merge gate matcher not widened | PASS | Empty diff for 5 paths; merge-gate suites 56/56 and 12/12 Passed | `git diff --stat 79fd5a95 -- <5 paths>`; `suites.py` | |
| 11 | Helpers diff confined (amended) | PASS | 8 removed lines in total:<br>- 1 is the pre-change line 221 `param` line, re-added with `[AllowEmptyString()]` only (clause b);<br>- 3 are comment lines of the pre-change row-14 block (clause a);<br>- 4 are loop lines 342–345, whose trimmed text reappears inside the `try` block (clause c).<br>No hunk touches `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, or the constant blocks. | `git diff 79fd5a95 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`; `evidence/qa-gates/remediation-diff-confinement-helpers.2026-09-17T10-15.md` | |
| 12 | Gates still deny when a required document is absent | PASS | Both nodes Passed | `parse.py` keys `blocks implementation writes when route metadata`, `checkpoint omits the feature folder` | |
| 13 | Epic/standalone topologies unchanged when cwd equals target | PASS | Both nodes Passed in both suites; mode suites 87/87, 55/55, and 11/11 | `parse.py`; `suites.py` | |
| 14 | SHA256 parity node passes | PASS | Node Passed; reviewer `sha256sum` shows 4 identical values (`AAD0BAAF...8989`) | `sha256sum <4 copies>`; `parse.py` | |
| 15 | Bundled-payload mirroring complete | PASS | All 4 helpers paths are in `git diff --name-status`. The Codex byte-identity node is Passed. The reviewer re-ran both Python contract files: 16 passed, which includes `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. | `git diff --name-status 79fd5a95`; `poetry run python -m pytest <two files>`; `evidence/qa-gates/remediation-python-pushdown-contracts.2026-09-17T10-30.md` | |
| 16 | No file exceeds 500 lines | PASS | Each helpers copy is 441 lines (`wc -l`), and the count is recorded in `evidence/qa-gates/remediation-poshqc-format.2026-09-17T10-30.md`. The line-cap node and the Codex node `parse-checks each root and bundled hook and keeps every file within 500 lines` are Passed. | `wc -l`; `suites.py` | |
| 17 | Executed fail-before capture | PASS | `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` has `Timestamp:`, `Command:`, and `EXIT_CODE: 0`, and rows 2 and 3 are `False` | Read artifact (lines 3–6, 21–28) | |
| 18 | Executed pass-after capture | PASS | `evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md`: rows 2 and 3 are `True`; rows 1 and 4–8 are identical. The remediation capture `remediation-pass-after-probe.2026-09-17T09-30.md` keeps rows 1–19 identical. | Read artifacts | |
| 19 | Coverage ≥85%, helpers ≥94.92%, changed lines all hit (amended) | PASS | Report LINE 8986/9404 = 95.56%. Helpers file 147/152 = 96.71%. 38 instrumented changed lines, 0 with a zero hit count. Figures are recorded in `evidence/qa-gates/remediation-coverage-comparison.2026-09-17T10-30.md`. | reviewer `parse.py` over `artifacts/pester/powershell-coverage.xml` (report written after the last source edit; worktree clean at HEAD) | Prior FAIL resolved (RF-3). |
| 20 | Full PowerShell toolchain passes in a single pass (amended) | PASS | Format: the executor's 7 paired hashes are equal, and the reviewer's `Invoke-Formatter` comparison shows no change. Analyze: 0 findings on 7 files (executor and reviewer). Test: failures=2, both baseline nodes; 0 failing `issue #671` nodes. | `evidence/qa-gates/remediation-toolchain-single-pass.2026-09-17T10-30.md`; reviewer `qa.ps1`; `parse.py` | Prior FAIL resolved (RF-4). See code-review CR-R4 on tracking the baseline failures. |
| 21 | No Python leg introduced | PASS | No `.py` path in the branch diff (against either base) | `git diff --merge-base main --name-only -- "*.py"`; `git diff --name-status 79fd5a95` | |
| 22 | No new production file; no F1 dependency | PASS | The only production `.ps1` paths are the 4 helpers copies (all `M`); the only new `.ps1` is under `tests/`. Grep finds no `Import-Module`. | `git diff --merge-base main --name-only -- "*.ps1"`; Grep | |
| 23 | Helpers purity survives | PASS | The purity sentence appears once per copy (line 5); no forbidden literal appears in any copy | Grep over the 4 copies | |
| 24 | Nested-subdirectory widening recorded | PASS | `Accepted widening` appears at line 45 in each copy. The comment names seven Markdown fixtures under `resolve_execute_plan_prompt` and the F1 upstream composition. | Grep; diff inspection | |
| 25 | Remediation R1 regression rows pass, plus probe | PASS | All 7 named nodes are Passed in both suites (`suites.py`: both suites fully Passed). The executor probe (Q6, Q7) and the reviewer probe both record `False` with `errors=0` for the two named commands. | `parse.py "LACS L8" "unmodelled subcommand"`; `evidence/regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md`; reviewer `qa.ps1` | |
| 26 | Predicate and fail-closed guard pinned at unit level | PASS | 3 accept nodes, 12 reject nodes, and the guard node are Passed in both suites | `parse.py "returns false when segment classification"`; `suites.py` | |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 26 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. The three criteria that failed in the prior audit (5, 19, 20) now pass.

**Recommended follow-up verification steps (non-blocking):**

1. Confirm that the two baseline Pester failures have a tracking issue (code-review CR-R4).
2. Consider adding a `Write-Debug` diagnostic to the fail-closed `catch` in a follow-up change across all four copies (code-review CR-R1).
3. In the PR body, use a closing keyword only for #671 (code-review CR-R5).

---

## Acceptance Criteria Check-off

The acceptance-criteria tracking rules require the following:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`
- Total AC items: 26
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` | 26 | 26 | 0 | Checkbox-backed |

This review made no source-file checkbox change. The executor had already checked all 26 criteria, and this review evaluates every one of them as PASS on independent evidence, so each existing `[x]` is confirmed.
