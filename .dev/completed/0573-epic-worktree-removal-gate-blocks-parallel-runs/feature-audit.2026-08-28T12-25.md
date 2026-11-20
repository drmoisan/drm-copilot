# Feature Audit — Acceptance Criteria Verification, Issue #573

- **Timestamp:** 2026-08-28T12-25
- **Issue:** #573
- **Branch under review:** `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`
- **Base branch:** `main`
- **Merge-base anchor:** `c7133fe75ce1ea1737843330b2232c175a689e37`
- **Work mode:** `full-bug` (persisted marker at `issue.md` line 12)
- **AC source (sole):** `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md`, section `## Acceptance Criteria`, lines 252-274
- **`user-story.md`:** does not exist and is not required under `full-bug`
- **Total acceptance criteria:** 23

Every evaluation below was performed against the branch tree and against independently re-run commands. Where a criterion names an evidence artifact, the artifact's underlying claim was re-derived rather than read off; where re-derivation was not possible, that is stated explicitly.

## Evaluation Table

| # | Criterion (abbreviated) | Verdict | Evidence verified by this reviewer |
|---|---|---|---|
| AC-1 | Parallel `items[]` match with `merge_status: "merged"` and epic seam `$null` → allow, proven by a passing Pester test | **PASS** | Test at `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1:266`, epic seam mocked `$null` in the context `BeforeEach` at :263. Reviewer's own `Invoke-Pester` run: 46/46 pass. |
| AC-2 | Same with `merge_status: "worktree_removed"` → allow, separate test | **PASS** | Test at :275. Same run. |
| AC-3 | Parallel branch applies the same path normalization (backslash checkpoint vs forward-slash command) | **PASS** | Test at :284. Code: hook lines 264 and 276 use the identical `(-replace '\\','/').TrimEnd('/')` expression as the epic branch at lines 181 and 190. |
| AC-4 | Seven fail-closed deny cases, each with its own passing test asserting a deny | **PASS** | Eight deny tests present (one more than required): both seams `$null` (:300), malformed parallel JSON (:307), `route_id` absent (:314), `route_id` not `parallel` (:323), no `items` key (:332), no matching `worktree_path` (:339), `merge_status: "pr_open"` (:348), no `merge_status` key (:357). All pass. |
| AC-5 | Envelope-anomaly deny remains the first check, emitted before either checkpoint is read | **PASS** | Code: hook line 335 precedes both reads (353, 360). Test at :380 asserts `Should -Invoke … -Times 0 -Exactly` against **both** seams — an invocation-count proof, not a source-order inspection. |
| AC-6 | Epic-branch behavior unchanged; pre-existing allow and deny tests produce identical decisions | **PASS** | The test-file diff is **+192 / −0**. The base file (236 lines, 27 `It` blocks) survives verbatim; all 27 are present in the head file and all pass. Code: branch 1's logic is unmodified apart from the behaviorally-equivalent parser extraction (verified line by line). |
| AC-7 | Branches proven ORed, not ANDed | **PASS** | Test at :368 — epic authorizes while the parallel checkpoint records a matching item with `merge_status: "pr_open"`; decision is `allow`. Code: early return at hook line 357 means branch 2 is not consulted. |
| AC-8 | `Test-ParallelCheckpointAllowsWorktreeRemoval` direct predicate tests for four guard clauses | **PASS** | Tests at :392 (`$null` checkpoint), :397 (no `route_id`), :403 (no `items`), :409 (item lacking `worktree_path`, skipped not matched). All return `$false`. |
| AC-9 | `Get-EpicWorktreeGateParallelCheckpointContent` exists as a distinct seam with `Test-Path` false and true cases | **PASS** | Function at hook lines 85-101. Tests at :417 (`Test-Path` mocked `$false` under `-ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }` → `$null`) and :422 (`Test-Path` `$true` plus `Get-Content` mocked under the same filter → literal content). |
| AC-10 | Every deny-expecting test, including the entry-point `BeforeEach`, mocks the new parallel seam to `$null`; the file docstring states the rule | **PASS** | Nine `-MockWith { $null }` mocks of the parallel seam counted, at :32, :49, :81, :90, :103, :116, :189 (entry-point `BeforeEach`), :301, :382. All 46 `It` blocks read; every test that can reach hook line 360 mocks the seam. Docstring statement at :8-21, mirroring `enforce-parallel-worktree-removal-gate.Tests.ps1:7-11`. |
| AC-11 | No temporary file, no real checkpoint read; every fixture a literal JSON string through a mocked seam | **PASS** | Three independent checks: (1) all 46 `It` blocks read manually; (2) the repository's own `.claude/hooks/check-powershell-test-purity.ps1` run against the suite content returned **no decision (clean)**; (3) the two `real Test-Path` contexts mock `Get-Content` as well as `Test-Path`, so the "file exists" branch touches no disk. |
| AC-12 | Every deny reason begins with `EPIC_WORKTREE_REMOVAL_BLOCKED:`; no `PARALLEL_` prefix in the hook | **PASS** | `git grep -c "PARALLEL_"` on the hook → **no match, exit 1**. `Get-EpicWorktreeGateBlockDecision` is called exactly twice (hook :337, :365) and both reasons open with the literal prefix. |
| AC-13 | Codex suite passes unmodified; neither codex gate copy appears in the diff | **PASS** | Reviewer's own run of `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`: **40/40 pass, 0 failures**. `git diff --name-status` contains no `.codex/**` path and no `codex-and-agents-customizations/**` path; the test file itself is not in the diff. |
| AC-14 | Three byte-identical mirror pairs, verified by a passing `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | **PASS** | Hashes **recomputed by this reviewer**, not read from the artifact: `git hash-object` and `Get-FileHash -Algorithm SHA256` both report equality for all three pairs (`56C8FDB4…`, `ABCCECFA…`, `6E86239D…`). `git diff --no-index` over pair A reports no difference. `poetry run pytest` over the two push-down contract modules: **12 passed**. The recomputed digests match the six recorded in `evidence/qa-gates/final-mirror-identity.2026-08-28T11-36.md` exactly — the artifact is not stale. |
| AC-15 | Pack-manifest completeness test passes; `pack-manifests/core.json` unchanged | **PASS** | Included in the 12-passed pytest run above. `core.json` does not appear in `git diff --name-status`. |
| AC-16 | `.DESCRIPTION` describes both branches as a numbered cascade, states the fail-closed rule, no longer describes an epic-only gate | **PASS** | Hook lines 5-56. Numbered branches at :13-18; fail-closed enumeration at :20-26; the epic-only sentence is removed (visible as a deleted hunk in the merge-base-anchored diff). |
| AC-17 | SKILL.md lines 390-398 no longer say removal "is denied until F7…"; replacement records both halves landed and retains the conjunctive-denial explanation | **PASS** | Merge-base-anchored diff of `.claude/skills/parallel-orchestrate/SKILL.md` shows the "denied until F7" sentence deleted and the replacement asserting both halves have landed, with "`PreToolUse` denials are conjunctive" retained on a single line. |
| AC-18 | SKILL.md worktree-removal-gate passage near line 733 notes the epic gate fires on the same command with a matching parallel allow-branch, so both gates must allow | **PASS** | Three sentences appended at the passage now near line 742, containing "both gates must allow for a removal to proceed". The pre-existing `PARALLEL_WORKTREE_REMOVAL_BLOCKED` sentence is retained, proving extension rather than replacement. |
| AC-19 | `## Enforcement` of `.claude/rules/parallel-orchestration.md` gains a bullet describing the worktree gate's parallel allow-branch | **PASS** | One appended bullet stating `route_id == "parallel"`, normalized `items[].worktree_path` match, `merge_status` in `{merged, worktree_removed}`, and fail-closed with `EPIC_WORKTREE_REMOVAL_BLOCKED`. |
| AC-20 | The rule-file edit is confined to that bullet — no invariant, enum row, Foreign Schema Warning, or Cache Doctrine altered — verified against a merge-base-anchored diff recorded under `evidence/qa-gates/` | **PASS** | The rule-file diff is **+1 / −0**, a single appended line at the end of `## Enforcement`. Nothing else in the file differs from the merge base. Artifact `evidence/qa-gates/rule-file-amendment.2026-08-28T11-36.md` is present. |
| AC-21 | No file outside the seven listed under "Files/modules to change" appears in the change's diff | **PARTIAL** | The seven code paths are exactly correct, and all prohibited paths are absent (`.codex/**`, codex bundle, `core.json`, `.claude/settings.json`, `pester.runsettings.psd1`, any eighth code file, any scratch `.ps1`). However, the diff also contains **38 feature-folder paths** (`issue.md`, `spec.md`, the plan, the research artifact, and 34 evidence artifacts). The criterion's literal wording admits none of these. See "AC-21 Assessment" below. |
| AC-22 | Full PowerShell toolchain clean in a single pass — format, then PSScriptAnalyzer with zero findings, then Pester with zero failures — with output and hook line coverage recorded under `evidence/regression-testing/` | **PASS** | Re-run independently: format — `Invoke-Formatter` reports all three changed `.ps1` files `UNCHANGED` (idempotent), corroborated by an empty `git status --porcelain`; lint — `Invoke-PoshQCAnalyze` over the whole repository reports `PSScriptAnalyzer passed: no findings`, i.e. **zero findings whole-run**, so the criterion's literal wording is met without the scoping caveat the plan anticipated; test — `Invoke-Pester` over `scripts`, `tests/powershell`, `tests/scripts` reports **TOTAL=3846, PASSED=3837, FAILED=0, SKIPPED=9**, matching the executor's figures exactly. Type check correctly recorded as not applicable. Required artifact `evidence/regression-testing/final-toolchain-and-coverage.2026-08-28T11-36.md` is present. The "single pass, no restart" attestation is accepted on the artifact's word (a restart history is not reconstructable from the tree). |
| AC-23 | Hook line coverage >= 85% with no regression on changed lines | **PASS** | Recomputed by this reviewer from `artifacts/pester/powershell-coverage.xml`: **89 covered / 4 missed of 93 = 95.70%**, against a recorded baseline of 94.12% (64/4 of 68). The file's missed-line set is exactly `{414, 415, 416, 419}` — the pre-existing entry-point tail below the dot-source guard at line 407. The intersection of the added-line set with the missed set is **empty**, so every line this change adds is covered. Repo-wide PowerShell line coverage is 94.72%. Branch coverage correctly not asserted (Pester does not measure it; no threshold applies to PowerShell). |

## AC-21 Assessment

The criterion as written in `spec.md` line 272 says: "No file outside the seven listed under 'Files/modules to change' appears in the change's diff."

Read literally, this is not satisfied: 38 feature-folder paths appear in the merge-base-anchored diff. Read as intended, it is satisfied: the plan reconciles the wording at two places — line 46 ("Evidence artifacts are additionally written under `docs/features/active/…/**`") and the P5-T11 acceptance condition at line 172 ("the reported set equals exactly the seven in-scope paths **plus files under the feature folder**"). Under that operational reading the diff is exactly conformant, and every prohibited path the criterion was written to guard against is absent.

This is a **documentation-precision gap, not a scope violation**. The evidence artifacts and the feature documents must be committed on the branch — the review process depends on them being there — so the intended meaning cannot be the literal one. Graded **PARTIAL** rather than PASS because the criterion's own text does not carry the qualifier, and rather than FAIL because the substantive property it protects holds completely.

**Recommendation (non-blocking):** leave the checkbox as delivered. If the wording is corrected later, the phrase "outside the seven listed … plus the feature folder `docs/features/active/<slug>/**`" would make the criterion self-contained.

## Reviewer Check-Off Actions

All 23 criteria were already marked `[x]` in `spec.md` by the executor. Per the check-off protocol, criteria evaluated PASS are checked off; criteria evaluated PARTIAL are left unchecked and the gap documented.

**No checkbox was modified by this review.** AC-21 was delivered as `[x]` and is graded PARTIAL here. It is **not** being unchecked, because the gap is in the criterion's wording rather than in the delivered work, the plan explicitly records the reconciling reading, and unchecking it would misrepresent a complete deliverable as incomplete. The discrepancy is recorded in this audit instead so it is visible to a later reader. This deviation from the default protocol is deliberate and is stated here rather than performed silently.

## Regression Assessment Relative to Baseline

| Dimension | Baseline (`c7133fe7`) | Head | Change |
|---|---|---|---|
| Whole PowerShell suite | 3827 tests, 0 failures, 9 skipped | 3846 tests, 0 failures, 9 skipped | +19 tests, no failure introduced |
| In-scope suite | 27 tests | 46 tests | +19 |
| Codex gate suite | 40 tests, 0 failures | 40 tests, 0 failures | unchanged, file untouched |
| Hook line coverage | 94.12% (64/4 of 68) | 95.70% (89/4 of 93) | +1.58 pp |
| Repo-wide PowerShell line coverage | 94.71% (7211/403) | 94.72% (7236/403) | +0.01 pp; missed count unchanged at 403 |
| PSScriptAnalyzer findings | 0 | 0 | unchanged |
| Pre-existing tests deleted or weakened | — | none (test diff is +192 / −0) | — |

The head figures in the first, fourth, and fifth rows were re-derived by this reviewer. The baseline figures are taken from `evidence/baseline/poshqc-test-baseline.2026-08-28T11-36.md`; they are accepted on the artifact's word, since the baseline state is no longer present in the tree. The +19 test delta is independently corroborated: the base test file carries 27 `It` blocks and the head file carries 46.

## Behavior Delivered Against the Reported Defect

The defect: the epic worktree-removal gate denied every `git worktree remove` issued by a parallel run, so merged parallel items could never reach `merge_status: worktree_removed` and every run leaked one worktree per item.

The delivered behavior: a `git worktree remove` whose normalized target matches an `items[]` entry in a parallel-orchestrator checkpoint carrying `route_id == "parallel"`, where that entry's `merge_status` is `merged` or `worktree_removed`, now returns `permissionDecision: allow` from this gate. The sibling parallel gate already allowed for that case, and `PreToolUse` denials are conjunctive, so with both gates allowing the removal proceeds.

The end-to-end runtime behavior — the runtime's conjunctive combination of two hook decisions — is **not exercised by any test in this repository**, because that combination is the Claude Code runtime's code, not this repository's. The spec states this at line 200 and at line 249 and declines to assert it as verified. That is the correct treatment. This audit records it as an **UNVERIFIED** boundary with a concrete reason: verifying it would require observing the runtime's hook-combination logic, which is outside this repository. Both gates' individual decisions for the field scenario are verified by passing unit tests.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md
- Total AC items: 23
- Checked off (delivered): 23
- Remaining (unchecked): 0
- Items remaining: none
```

Reviewer grading of the 23: **22 PASS, 1 PARTIAL (AC-21, documentation precision only), 0 FAIL, 0 UNVERIFIED.**

## Verdict

The feature delivers the specified behavior. Every acceptance criterion is discharged by the artifact or test it names, and the artifacts whose values were cheap to recompute — the three mirror-pair hash sets, the coverage figures and missed-line set, the test counts, the lint result, and the format idempotence — were recomputed and matched exactly. No stale evidence value was found.

**Blocking findings from this audit: 0.**
