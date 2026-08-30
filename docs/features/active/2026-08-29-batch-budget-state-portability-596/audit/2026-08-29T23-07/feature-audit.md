# Feature Audit — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-29T23-07
- Branch: `feature/batch-budget-state-portability-596` at `9e41b9bf`
- Base: `origin/epic/claude-runtime-portability-integration` (merge-base `6df37664`)
- Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source
- AC source: `docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md`, section
  `## Acceptance Criteria` (lines 680-779)

Findings: **0 Blocking, 2 Major, 6 Minor.**

## Work Mode Resolution

`issue.md` line 12 carries `- Work Mode: full-bug`. `spec.md` line 9 confirms it and states
explicitly that `spec.md` is the sole acceptance-criteria source with no `user-story.md`. No
`user-story.md` exists in the feature folder. The marker is present and well-formed, so no fail-closed
normalization was required.

Per the `acceptance-criteria-tracking` skill, the acceptance criteria are the markdown checkbox items
under the `## Acceptance Criteria` heading. Checkbox items elsewhere in `spec.md` — the
Impact/Severity selection at lines 27-30, the Logs/Screenshots item at line 118, and the three Test
Strategy items at lines 591-593 — are template or selection constructs, not acceptance criteria, and
are excluded from the count. Their state is noted separately under Observations.

Counted with the section boundary enforced (from `## Acceptance Criteria` to `## Risks & Mitigations`):
**17 criteria, 16 checked, 1 unchecked.**

## Acceptance Criteria Evaluation

### Defect 1 — shared session identity

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | PowerShell suite has three passing state-file-name tests (env / state file / worktree-derived), names pairwise different | **PASS** | Suite lines 253-302 supply the three tests; line 304-342 asserts pairwise distinctness via `Select-Object -Unique \| Should -HaveCount 3`. Re-run in this review: 96/96 passed across the four hook suites. |
| 2 | Python suite has the same three tests | **PASS** | Mirror structure confirmed in `enforce-python-batch-budget.Tests.ps1`; included in the same 96/96 run. |
| 3 | Case-sensitive search for `'default'` returns nothing across the two hooks and two mirrors; matched before | **PASS** | After: 0 in all four files. Before, reconstructed from the base revision: 2 per file (`:157` parameter default, `:250` entry-point assignment) — exactly the 2-per-file the criterion predicts. Gate is non-vacuous. |
| 4 | Each suite asserts a hostile session id yields a name matching `^(powershell\|python)-batch-budget\.[A-Za-z0-9._-]+\.json$` | **PASS** | PowerShell suite lines 344-360 drive `-SessionId '../../etc/passwd'` and assert both the pattern and the exact literal `powershell-batch-budget..._.._etc_passwd.json`. |
| 5 | `persist-session-id.Tests.ps1` asserts `WriteStateFile` **and** `AppendLine` are both invoked when `CLAUDE_ENV_FILE` is set; pre-existing tests remain green | **PASS** | Suite lines 214-224 assert both seams invoked `-Times 1 -Exactly`. Whole suite green in the 96/96 run. Implementation at `persist-session-id.ps1:104-115` performs both. |

### Defect 2 — never-resetting inheritance of a poisoned counter

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 6 | Each suite has a passing test where persisted `prodFiles` holds an out-of-root path and three in-root production files are still admitted; fixture is the literal `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py` | **PASS** | PowerShell suite lines 403-429; constant defined at line 27 with the exact literal the criterion names. Verified capable of failing: with the poisoned entry retained (pre-fix behavior), the third of three files would hit the cap of 3 and be denied, failing the assertion at line 426. |

### Defect 3 — unscoped recorded paths

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 7 | Each suite has passing tests for (a) relative recorded, (b) in-root absolute recorded, (c) out-of-root absolute yields `allow` + `shouldWriteState` false + unchanged list, (d) in-root absolute differing only in case recorded | **PASS** | PowerShell suite lines 362-401 supply all four. Case (c) verified capable of failing against the base revision, whose decision function has no `-Root` parameter and no containment check and would record the path. See policy audit Adjudication 3. |
| 8 | `(Get-Location).Path` search returns nothing across the four files; one match per file before. No `Resolve-Path` or `GetFullPath` introduced | **PASS** | After: 0 in all four. Before, from the base revision: exactly 1 per file (`:158`). `Resolve-Path` and `GetFullPath`: 0 occurrences in both hooks. Gate is non-vacuous. |

### Defect 4 — destination-side ignore delivery

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 9 | `claude-gitignore-merge.ts` exists, exports a merge function performing no I/O; suite passes with all seven enumerated cases | **PASS** | Module has zero import statements, so purity is structural. All seven cases present in `claude-gitignore-merge.test.ts`. `npx jest` on both new suites: 11 passed, 11 total. |
| 10 | A Jest test drives the push-down against `InMemoryPushDownFileSystem` and asserts `<destination>/.gitignore` carries `.claude/state/` between the sentinels, on both an unscoped and a `packs: ["core"]` publish | **PASS** | `claude-gitignore-delivery.test.ts` lines 45-67 supply both cases, asserting the full expected block text. |
| 11 | Idempotency: two publishes, two reads byte-identical, each sentinel exactly once, destination path absent from the second publish's recorded writes | **PASS** | Lines 69-93. The write log is sliced from the first publish's length so the assertion inspects only the second publish — the test cannot pass vacuously. Independently confirmed `f(f(x)) === f(x)` across seven inputs by executing the shipped merge logic. |
| 12 | A Jest test seeds unrelated entries and asserts all are present in original relative order after publish | **PASS** | Lines 95-115 assert every entry present and positions monotonically increasing. |
| 13 | `jest.config.cjs` carries a `coverageThreshold` entry for the new module at `lines: 85, branches: 75`, and `npx jest --coverage` passes with it | **PASS** | Entry present at `jest.config.cjs:211-217`. Independently re-measured: 98.78 percent lines, 90 percent branches — both above the entry's floors. |

### Cross-cutting gates

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 14 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with no `.claude/state/` present | **PASS** | `.claude/state/` confirmed absent from this worktree — the fresh-checkout condition the criterion names. Test executed during this review: `1 passed in 0.10s`. |
| 15 | Mirror parity proven by `git hash-object` producing identical object ids for the three named pairs | **PASS** | Verified directly, not read from the artifact: `d4503c77...` , `db025b9d...`, `8c0d0b1d...`, each identical across its pair. |
| 16 | `PreToolUseSchema.Contract.Tests.ps1` passes with no change to its assertions | **PASS** | Suite is absent from the branch diff, so its assertions are unchanged. Included in the 96/96 passing run. |
| 17 | `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` all pass in a single consecutive run with no file modifications, **and** all three hooks are >= 85 percent line coverage versus baseline | **PARTIAL** — correctly left unchecked | Coverage half satisfied: 93.8 / 93.8 / 88.1 percent, all above 85. Toolchain half not satisfied: the unscoped Pester run exits 2 on two failures. Verified pre-existing — see below. |

### Summary

| Verdict | Count |
| --- | --- |
| PASS | 16 |
| PARTIAL | 1 |
| FAIL | 0 |
| UNVERIFIED | 0 |

Every criterion evaluated PASS is checked in `spec.md`. The single PARTIAL criterion is unchecked.
**There is no criterion checked off that I could not verify**, and no criterion left unchecked that I
found satisfied. The check-off state is accurate.

## Check-Off Protocol Compliance

`git diff <base>...HEAD -- spec.md` contains exactly 16 changed line pairs, every one of which is a
`- [ ]` to `- [x]` transition with the criterion text byte-identical on both sides. No criterion text
was edited, no criterion was added, and no criterion was removed. This satisfies rules 3 and 5 of the
`acceptance-criteria-tracking` skill.

As reviewer I checked off no additional criteria: the only unchecked criterion is correctly unchecked.

## Criterion 17 — Independent Verification of the Pre-Existing Claim

The claim that both Pester failures are pre-existing was verified rather than accepted, by four
independent means. Full detail is in the policy audit, Adjudication 2.

1. **Reproduced at HEAD.** Running only the two owning suites: 49 total, 47 passed, 2 failed. Both
   failing test names are byte-identical to the pair recorded in the Phase 0 baseline artifact.
2. **Not attributable to this branch.** Neither owning suite, nor `enforce-pr-author-skill.ps1`, nor
   `enforce-epic-wave-barrier.ps1`, nor the Codex handler registry appears anywhere in
   `git diff --name-only <base>...HEAD`. The branch cannot have introduced either failure.
3. **Failure count constant across a rising discovery count.** Baseline `tests=3851 failures=2`;
   final `tests=3904 failures=2`. Fifty-three tests added, no new failure.
4. **Root cause inspected.** The Codex handler-matcher failure is produced by
   `enforce-epic-wave-barrier.ps1` denying a benign payload because the ambient epic checkpoint
   records issue 596 as having unmerged `depends_on` edges:

   ```
   EPIC_WAVE_BARRIER_BLOCKED: '596' cannot mutate until every depends_on edge is
   merged or worktree_removed in the epic checkpoint.
   ```

   The cause is orchestration context, not feature code. This criterion is therefore unsatisfiable
   from inside this epic worktree regardless of the feature's correctness, and should clear once the
   epic checkpoint advances or in a fresh checkout where no checkpoint is present.

Conclusion: the claim is confirmed. Leaving criterion 17 unchecked is the correct and honest
disposition; checking it would be false. This criterion should **not** block merge, because the
feature satisfies every part of it that is within its control.

## Baseline Comparison — Defect Closure

Assessed against the four defects enumerated in `issue.md` Steps to Reproduce, independent of the
criteria.

| Defect | Status | Basis |
| --- | --- | --- |
| 1. Sessions without a resolved id share one `default` counter | **CLOSED** | `'default'` removed from all four files; three-source resolution chain with sanitization; three composed names proven pairwise distinct. |
| 2. Poisoned counter never resets | **CLOSED** | Rehydrate-time containment filter drops out-of-root persisted entries, proven by the three-admissions test. TTL explicitly out of scope with recorded rationale. |
| 3. Paths from another worktree counted against this worktree | **PARTIALLY CLOSED** | Absolute out-of-root paths are discarded. **Sibling worktrees whose directory name extends this root's name are still admitted** because the comparison omits the trailing separator the spec pins. See Major finding B-1. |
| 4. No destination-side `.gitignore` writer exists | **CLOSED** | Net-new pure merge module plus post-copy call site; delivery verified on unscoped and pack-scoped publishes; idempotency verified across seven inputs. One robustness defect on malformed input — see Major finding B-2. |

Two known limitations were accepted in the spec rather than fixed, and remain accurate: Windows 8.3
short-name paths are classified out-of-root and under-counted, and two concurrent sessions in one
worktree with no resolvable id still share a counter. Both are documented in `spec.md` Risks &
Mitigations and neither is a regression.

## Observations

**Three Test Strategy checkboxes remain unchecked.** `spec.md` lines 591-593 carry `- [ ]` items
seeded from the issue (unit coverage areas, integration scenario to retest, manual verification
notes). All three are in fact satisfied by the delivered work. They sit under `## Test Strategy`, not
`## Acceptance Criteria`, so they are correctly excluded from the AC count of 17. A checkbox-counting
tool run over the whole file will nonetheless report three additional incomplete items and mislead a
later reader. Recorded as Minor finding N-4.

**Evidence quality.** The 53 evidence artifacts are unusually complete and self-critical. The
coverage-delta artifact recomputes every percentage from raw covered/missed counts rather than
copying summary lines, and reports the two per-file declines plainly under a heading that says so.
The toolchain convergence artifact states that the loop did not fully converge and records the task as
NOT MET rather than checking it off. Every figure I independently re-measured — the three mirror
hashes, the TypeScript coverage percentages and uncovered line numbers, the before-state search
counts, the two failing test names — matched the recorded values exactly. No discrepancy was found
between artifact and tree.

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
    (Coverage half satisfied at 93.8 / 93.8 / 88.1 percent. Toolchain half blocked by two
    verified pre-existing failures the feature does not own and is not authorized to repair;
    one of the two is caused by ambient epic-checkpoint state naming issue 596 itself.)
```

## Merge Assessment

**Not ready to merge**, on the two Major findings — neither of which is an acceptance-criteria
failure.

All 17 criteria are correctly dispositioned and the 16 checked ones are genuinely satisfied. The
blocking consideration is not the criteria but two code defects that the criteria do not reach:

1. **B-1** leaves Defect 3 — the defect this feature exists to fix — only partly closed, and
   contradicts a containment rule the spec settled explicitly rather than deferred.
2. **B-2** can silently delete content from a consumer repository's `.gitignore`, contradicting the
   module's own documented invariant, with no summary-artifact reporting to surface the loss.

Both are small, well-understood changes with regression tests that fit inside the remaining
500-line-cap headroom. Neither requires redesign.

Criterion 17 should **not** hold up the merge: the failures are verified pre-existing, unrelated to
every file this branch touches, and one is caused by the epic checkpoint recording this very issue as
unmerged — a condition that resolves on merge.
