# Feature Audit (reaudit, cycle-1 exit gate) — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-30T02-08
- Branch: `feature/batch-budget-state-portability-596` at `a7d4dd27`
- Base: `origin/epic/claude-runtime-portability-integration` (merge-base `6df37664`)
- Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source
- AC source: `docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md`, section
  `## Acceptance Criteria` (lines 680-780)
- Prior audit under reaudit: `audit/2026-08-29T23-07/feature-audit.md` (0 Blocking, 2 Major, 6 Minor)

## Finding Counts (stated for mechanical arithmetic)

| Class | Count |
| --- | --- |
| **FAIL / Blocking** | **0** |
| **Blocking PARTIAL** | **0** |
| Non-blocking PARTIAL | 1 (criterion 17; unsatisfiable from inside this worktree, resolves on merge) |
| Major | 0 |
| Minor (advisory, non-blocking) | 11 (N-1 through N-11; 6 carried, 5 new) |
| UNVERIFIED | 0 |

**blocking_count contribution from this artifact: 0.**

The finding set is the same set described in `policy-audit.md` and `code-review.md`, not an
additional set.

**Total `blocking_count` across all three reaudit artifacts: 0.**

## Work Mode Resolution

`issue.md` line 12 carries `- Work Mode: full-bug`. `spec.md` line 9 confirms it and states that
`spec.md` is the sole acceptance-criteria source. No `user-story.md` exists in the feature folder.
The marker is present and well-formed, so no fail-closed normalization was required.

Per the `acceptance-criteria-tracking` skill, the acceptance criteria are the markdown checkbox items
under the `## Acceptance Criteria` heading. The section-scoped counter was used rather than a
whole-file checkbox count:

```
Import-Module ./.claude/lib/requirements/GeneratedDocumentCounters.psm1 -Force
Get-NamedSectionCheckboxCount -Document $doc -Heading 'Acceptance Criteria'
17
```

Counted with the section boundary enforced (from `## Acceptance Criteria` to `## Risks & Mitigations`):
**17 criteria, 16 checked, 1 unchecked.** The single unchecked item is at `spec.md:773`.

Checkbox items elsewhere in `spec.md` — the Impact/Severity selection at lines 27-30, the
Logs/Screenshots item at line 118, and the three Test Strategy items at lines 591-593 — are template
or selection constructs, not acceptance criteria, and are excluded by the section boundary.

## Criterion State Change During Cycle 1

**No acceptance criterion changed state during cycle 1.** Verified directly:

```
git diff 9e41b9bf..HEAD -- docs/features/active/.../spec.md
(empty)
```

`spec.md` was not modified at any point during the remediation. The counts at HEAD (17 / 16 / 1) are
identical to those the prior audit recorded.

This is the expected outcome and the directive predicted it correctly. B-1 and B-2 were conformance
failures against criteria already recorded as satisfied — the criteria enumerate cases that the
defective code passed, so closing the defects did not change any criterion's truth value as recorded.
B-3 closed a `## Test Strategy` edge case at `spec.md:623` that carries no acceptance criterion.

## Acceptance Criteria Evaluation

Every criterion was re-evaluated at HEAD rather than carried from the prior audit, because the
remediation edited production files that four of the criteria depend on. A fix can invalidate a
criterion that was verified before it, so nothing was assumed to survive.

### Defect 1 — shared session identity

| # | Criterion (abbreviated) | Verdict | Re-verification at HEAD |
| --- | --- | --- | --- |
| 1 | PowerShell suite has three passing state-file-name tests (env / state file / worktree-derived), names pairwise different | **PASS** | Suite re-run in this review as part of a 102/102 combined invocation. The pairwise-distinctness assertion (`Select-Object -Unique \| Should -HaveCount 3`) is present and passing. Unaffected by the D-1 edit, which touched the containment helper only. |
| 2 | Python suite has the same three tests | **PASS** | Same combined 102/102 run. |
| 3 | Case-sensitive search for `'default'` returns nothing across the two hooks and two mirrors; matched before | **PASS** | **Re-run at HEAD**, because the production files changed: 0 matches in all four files. Before-state reconstructed from base revision `6df37664`: 2 per hook. Gate non-vacuous and still holds after the D-1 edit. |
| 4 | Each suite asserts a hostile session id yields a name matching `^(powershell\|python)-batch-budget\.[A-Za-z0-9._-]+\.json$` | **PASS** | Included in the 102/102 run. The D-1 edit did not touch `ConvertTo-*BatchBudgetSafeSegment` or the name composition. |
| 5 | `persist-session-id.Tests.ps1` asserts `WriteStateFile` **and** `AppendLine` are both invoked when `CLAUDE_ENV_FILE` is set; pre-existing tests remain green | **PASS** | `persist-session-id.ps1` was not edited in cycle 1 (hash unchanged at `8c0d0b1d...`). Suite re-run: 16/16 passing. |

### Defect 2 — never-resetting inheritance of a poisoned counter

| # | Criterion (abbreviated) | Verdict | Re-verification at HEAD |
| --- | --- | --- | --- |
| 6 | Each suite has a passing test where persisted `prodFiles` holds an out-of-root path and three in-root production files are still admitted; fixture is the literal `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py` | **PASS** | **Directly affected by the D-1 edit** — the rehydrate filter calls the changed predicate. Re-verified two ways: the test passes in the 102/102 run, and the rehydrate path was executed directly with a seeded poisoned entry, which was dropped while an in-root entry survived. The spec's literal fixture constant is present at suite line 27, unchanged. |

### Defect 3 — unscoped recorded paths

| # | Criterion (abbreviated) | Verdict | Re-verification at HEAD |
| --- | --- | --- | --- |
| 7 | Each suite has passing tests for (a) relative recorded, (b) in-root absolute recorded, (c) out-of-root absolute yields `allow` + `shouldWriteState` false + unchanged list, (d) in-root absolute differing only in case recorded | **PASS** | **Directly affected by the D-1 edit.** All four cases re-executed against the shipped predicate: relative admitted, in-root absolute admitted, unrelated absolute rejected, case-differing in-root admitted. All four tests pass in the 102/102 run. Cycle 1 added a fifth case (prefix-sibling) that the criterion does not enumerate; it does not weaken any of the four. |
| 8 | `(Get-Location).Path` search returns nothing across the four files; one match per file before. No `Resolve-Path` or `GetFullPath` introduced | **PASS** | **Re-run at HEAD**: 0 matches in all four files for `(Get-Location).Path` and 0 for `Resolve-Path`/`GetFullPath`. Before-state from base revision: exactly 1 per hook. Gate non-vacuous and still holds. |

### Defect 4 — destination-side ignore delivery

| # | Criterion (abbreviated) | Verdict | Re-verification at HEAD |
| --- | --- | --- | --- |
| 9 | `claude-gitignore-merge.ts` exists, exports a merge function performing no I/O; suite passes with all seven enumerated cases | **PASS** | **Directly affected by the D-2 edit.** Module still has zero import statements, so purity remains structural. All seven enumerated cases re-executed against the compiled shipped module: each reaches a fixed point and emits exactly one begin sentinel. Suite passes. |
| 10 | A Jest test drives the push-down against `InMemoryPushDownFileSystem` and asserts `<destination>/.gitignore` carries `.claude/state/` between the sentinels, on both an unscoped and a `packs: ["core"]` publish | **PASS** | `claude-gitignore-delivery.test.ts` unchanged in cycle 1. Both cases pass in the 235/235 push-down directory run. |
| 11 | Idempotency: two publishes, two reads byte-identical, each sentinel exactly once, destination path absent from the second publish's recorded writes | **PASS** | Re-verified independently: `f(f(x)) === f(x)` holds on all nine inputs tested, including the previously-broken malformed input. The well-formed current block returns byte-identical to its input. The delivery test's write-log slice is unchanged. |
| 12 | A Jest test seeds unrelated entries and asserts all are present in original relative order after publish | **PASS** | **Directly affected by the D-2 edit**, which changes how much content is preserved. Ordering preservation re-confirmed by execution on every input; the test passes in the 235/235 run. |
| 13 | `jest.config.cjs` carries a `coverageThreshold` entry for the new module at `lines: 85, branches: 75`, and `npx jest --coverage` passes with it | **PASS** | Entry confirmed present at `jest.config.cjs:213-216`. Full `npx jest --coverage` re-run: exit 0, no `coverage threshold for` line emitted. Module measures 98.79 lines / 95 branches, both above the entry's floors. |

### Cross-cutting gates

| # | Criterion (abbreviated) | Verdict | Re-verification at HEAD |
| --- | --- | --- | --- |
| 14 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with no `.claude/state/` present | **PASS** | `.claude/state/` confirmed absent from this worktree — the fresh-checkout condition the criterion names. Test executed: `1 passed in 0.11s`. |
| 15 | Mirror parity proven by `git hash-object` producing identical object ids for the three named pairs | **PASS** | **Directly affected by the D-1 edit**, which changed two of the six files. Recomputed: `bbbf70a6...`, `858bfb11...`, `8c0d0b1d...`, each identical across its pair, and each cross-checked against the HEAD tree via `git ls-tree`. The first two differ from the prior audit's values, as expected after the edit; the third is unchanged, as expected because `persist-session-id.ps1` was not edited. |
| 16 | `PreToolUseSchema.Contract.Tests.ps1` passes with no change to its assertions | **PASS** | Suite is absent from the branch diff, so its assertions are unchanged. Included in the 102/102 passing run. |
| 17 | `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` all pass in a single consecutive run with no file modifications, **and** all three hooks are >= 85 percent line coverage versus baseline | **PARTIAL — correctly left unchecked; NON-BLOCKING** | Coverage half satisfied and improved: re-measured 95.35 / 95.35 / 88.10, all above 85. Format half satisfied: PoshQC format via a capturing seam would rewrite 0 files. Analyze half satisfied: no findings. Test half not satisfied: the unscoped Pester run exits non-zero on two pre-existing failures reproduced below. |

### Summary

| Verdict | Count |
| --- | --- |
| PASS | 16 |
| PARTIAL (non-blocking) | 1 |
| FAIL | 0 |
| UNVERIFIED | 0 |

Every criterion evaluated PASS is checked in `spec.md`. The single PARTIAL criterion is unchecked.
**There is no criterion checked off that I could not verify, and no criterion left unchecked that I
found satisfied.** The check-off state is accurate at HEAD.

Four criteria — 6, 7, 9, and 12 — depend directly on code the remediation changed, and 15 depends on
files it changed. Each was re-verified against the shipped code rather than carried forward. None was
invalidated by the fixes.

## Check-Off Protocol Compliance

`git diff <base>...HEAD -- spec.md` contains 32 changed checkbox lines, that is 16 `- [ ]` /
`- [x]` pairs, with the criterion text byte-identical on both sides of each pair. No criterion text
was edited, no criterion was added, and no criterion was removed. This satisfies rules 3 and 5 of the
`acceptance-criteria-tracking` skill.

`git diff 9e41b9bf..HEAD -- spec.md` is empty: the remediation performed no check-off at all, which is
correct, since it closed no criterion that was not already recorded as satisfied.

As reviewer I checked off no additional criteria: the only unchecked criterion is correctly unchecked.

## Criterion 17 — Re-Verification of the Pre-Existing Claim

The claim was re-verified at `a7d4dd27` rather than carried from the prior audit, because the tree
changed.

1. **Both failures reproduce at HEAD.** Running only the two owning suites: 49 total, 47 passed,
   2 failed.

   ```
   FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
   FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
   ```

   Both names are byte-identical to the pair recorded at the prior audit and in the Phase 0 baseline,
   and the counts are identical. Cycle 1 neither introduced nor repaired anything here.

2. **Not attributable to this branch.** `git diff --name-only <base>...HEAD` filtered for
   `pr-author`, `codex`, and `wave-barrier` returns nothing. The branch does not touch either owning
   suite, `enforce-pr-author-skill.ps1`, `enforce-epic-wave-barrier.ps1`, or the Codex handler
   registry.

3. **The recorded root cause is still accurate.** The Codex handler-matcher failure is produced by
   `enforce-epic-wave-barrier.ps1` denying a benign payload because the ambient epic checkpoint
   records issue 596 as carrying unmerged `depends_on` edges:

   ```
   EPIC_WAVE_BARRIER_BLOCKED: '596' cannot mutate until every depends_on edge is
   merged or worktree_removed in the epic checkpoint.
   ```

   The cause is orchestration context, not feature code. The criterion is unsatisfiable from inside
   this epic worktree regardless of the feature's correctness, and clears once the epic checkpoint
   advances or in a fresh checkout where no checkpoint is present.

**Disposition: this PARTIAL does not contribute to `blocking_count`.** The criterion is compound;
three of its four halves are satisfied, and the fourth is blocked by suites this feature neither owns
nor touches, one of which names this very issue as its blocking condition.

## Baseline Comparison — Defect Closure

Reassessed against the four defects enumerated in `issue.md` Steps to Reproduce, independent of the
criteria. Two rows changed status since the prior audit.

| Defect | Prior status | Status now | Basis |
| --- | --- | --- | --- |
| 1. Sessions without a resolved id share one `default` counter | CLOSED | **CLOSED** | `'default'` absent from all four files, re-verified at HEAD against a base-revision before-state of 2 per hook. Three-source resolution chain with sanitization; three composed names proven pairwise distinct. The unreadable-file fall-through is now driven by a test and measured as covered. |
| 2. Poisoned counter never resets | CLOSED | **CLOSED** | Rehydrate-time containment filter drops out-of-root persisted entries. Re-verified by direct execution, including the prefix-sibling case that cycle 1 fixed: a seeded `/repo-sibling/...` entry is dropped and an in-root entry survives. TTL explicitly out of scope with recorded rationale. |
| 3. Paths from another worktree counted against this worktree | **PARTIALLY CLOSED** | **CLOSED** | The prefix-collision gap is closed. Both of the reviewer's original counterexamples (`agent-abc-r2`, `agent-abcdef` against root `agent-abc`) are now rejected, on both the decision path and the rehydrate path, verified by executing the shipped predicate. The exact-root, case-differing, backslash, and relative cases are all still admitted. |
| 4. No destination-side `.gitignore` writer exists | CLOSED (one robustness defect) | **CLOSED** | The malformed-block content loss is fixed. `b/` and `c/` survive the reviewer's original input, the result is a fixed point with one occurrence of each sentinel, and the well-formed path is byte-identical to its input. Delivery verified on unscoped and pack-scoped publishes. |

Defect 3 is the defect this feature exists to fix, and it is now fully closed against every case
identified in review.

Two known limitations were accepted in the spec rather than fixed, and remain accurate: Windows 8.3
short-name paths are classified out-of-root and under-counted, and two concurrent sessions in one
worktree with no resolvable id still share a counter. Both are documented in `spec.md` Risks &
Mitigations and neither is a regression.

## Disposition of the Six Carried Minor Findings

Each of the six advisory findings the prior audit raised and cycle 1 did not address was re-checked
against the tree. None has become blocking.

| Id | Subject | Recorded disposition | Verified at HEAD | Still correct |
| --- | --- | --- | --- | --- |
| N-1 | Uncovered lines, including the unreadable-session-id catch block | "addressed IN PART ONLY", reported as PARTIAL | Catch block now covered (lines 154/155 absent from the re-measured missed set). Null/whitespace guard and empty-root guard still uncovered (lines 79/89 and 76/86). Empty-root fail-open confirmed by execution. | **Yes** — reported neither as unaddressed nor as complete, which is the accurate statement |
| N-2 | `codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state | Out of scope, not owned by this feature | Failure reproduced at HEAD with an identical name and count; suite absent from the branch diff | **Yes** — external to the branch, resolves on merge |
| N-3 | Duplicated write sequence in `persist-session-id.ps1` | Out of scope; file not edited this cycle | File hash unchanged at `8c0d0b1d...`; duplication present at lines 105-115 and 117-123 | **Yes** — behaviorally correct, DRY observation only |
| N-4 | Three unchecked Test Strategy checkboxes | Out of scope; left as found | Still `- [ ]` at `spec.md:591-593`; section-scoped counter confirms they are outside the AC total of 17 | **Yes** |
| N-5 | `!`-negation case untested | Out of scope | No `!`-negation case in the merge suite; behaviour confirmed correct by nine-input execution | **Yes** |
| N-6 | `appendManagedBlock` trailing-blank loop uncovered | Out of scope; lines displaced to 153-154 | Confirmed: module reports `LF:166, LH:164` with uncovered range `153-154` | **Yes** — the displacement is correctly explained by the two added comment lines |

The reconciliation artifact's handling of N-1 is worth singling out: it declines to report the finding
as delivered merely because its highest-value component was closed, and enumerates precisely which
components remain open. That is the correct treatment of a compound finding.

Five further advisory observations arose during this reaudit — N-7 (no rehydrate-path regression test
for the prefix-sibling case), N-8 (sentinel uniqueness is conditional on the destination not carrying
a stray closer), N-9 (`claude-customizations.ts` has no armed `coverageThreshold` entry), N-10 (the
177-character predicate line), and N-11 (5 lines of headroom on the PowerShell suite). All are
advisory and none blocks. Full detail is in `code-review.md`.

## Evidence Quality

Every figure this reaudit re-measured matched the recorded evidence: the three mirror hashes, the
three PowerShell per-file coverage figures, all four TypeScript percentages and the uncovered line
range, the before-state literal counts, the two failing test names, the two suite line counts, and
the two hook file line counts. No discrepancy was found between artifact and tree.

Two artifacts on disk do not correspond to HEAD and were not relied on:
`artifacts/pester/powershell-coverage.xml` records a single scoped run, and
`extensions/drm-copilot/coverage/lcov.info` records the pre-fix merge module. Both are transient
build outputs rather than feature evidence, and the feature's own evidence artifacts record the
correct figures. Both languages were re-measured independently, with output directed to scratchpad
paths so that no repository file was modified.

The remediation evidence is self-critical in the places where that is hardest: the fail-before
exception dossier states that a failing run is structurally impossible rather than manufacturing one;
the coverage-delta artifact proves the no-regression claim arithmetically rather than asserting it;
and the reconciliation artifact reports one finding as PARTIAL rather than as delivered.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md
- Total AC items: 17
- Checked off (delivered): 16
- Remaining (unchecked): 1
- Items remaining:
  - `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
    `mcp__drm-copilot__run_poshqc_test` all pass in a single consecutive run with no file
    modifications, and the Pester line coverage for the three hooks is >= 85% for each file,
    compared against the pre-change baseline.
    (Coverage half satisfied and improved, at 95.35 / 95.35 / 88.10 percent. Format and analyze
    halves satisfied. Test half blocked by two verified pre-existing failures the feature does not
    own and is not authorized to repair; one of the two is caused by ambient epic-checkpoint state
    naming issue 596 itself, so the criterion is unsatisfiable from inside this worktree and
    resolves on merge.)
```

## Merge Assessment

**Ready to merge.**

The reasoning is as follows.

1. **Both prior Major findings are closed, and each was verified by executing the shipped code rather
   than by reading it.** B-1's two counterexamples are rejected on both the decision path and the
   rehydrate path while every legitimate case is still admitted. B-2's counterexample preserves `b/`
   and `c/`, reaches a fixed point, emits each sentinel once, and leaves the well-formed path
   byte-identical.

2. **The remaining prior Minor finding, B-3, is closed and measurable.** The catch bodies moved from
   uncovered to covered in both hooks, confirmed by independent re-measurement, and the fall-through
   behaviour was confirmed by driving the seam to throw.

3. **No criterion was invalidated by the fixes.** All 17 criteria were re-evaluated at HEAD, including
   the five that depend directly on files the remediation changed. Sixteen hold and are checked; one
   is correctly unchecked.

4. **Defect 3, the defect this feature exists to fix, is now fully closed.** The prior audit recorded
   it as partially closed; that qualification no longer applies.

5. **Every toolchain stage within the feature's control passes**, re-executed independently and
   non-mutatingly: format (0 files would be rewritten), lint (no findings, exit 0), type check (exit
   0), unit tests (102/102 PowerShell, 2734/2734 TypeScript), contract tests, and integration tests
   (235/235 push-down).

6. **Coverage rose on every measured axis and declined on none.** The two PowerShell per-file figures
   moved 93.8 → 95.35, the merge module's branch coverage moved 90 → 95, and the no-regression claim
   was established arithmetically rather than asserted: the current missed-line set is a strict subset
   of the baseline missed-line set in both hooks, and the TypeScript branch denominator is unchanged
   while its numerator rose.

7. **Criterion 17 should not hold up the merge.** The failures are verified pre-existing, reproduce
   identically at HEAD, live in suites absent from the branch diff, and one is caused by the epic
   checkpoint recording this very issue as unmerged — a condition that only merging can clear.

The eleven advisory findings are genuine and worth tracking, but none of them is a defect in delivered
behaviour. N-2 should be filed as its own issue, since it blocks the unscoped Pester run for every
feature in this epic. N-11 (5 lines of headroom on the PowerShell suite) should be resolved before the
next change to that suite rather than during one, and would pair naturally with closing N-7.
