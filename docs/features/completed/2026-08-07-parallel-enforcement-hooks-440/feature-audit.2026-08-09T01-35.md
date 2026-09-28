# Feature Audit — F7 Parallel Enforcement Hooks (Issue #440)

- Feature folder: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440`
- Branch: `feature/parallel-enforcement-hooks-440` @ `59796e82`
- Base: `epic/parallel-orchestration-integration`, merge base `c939b5b8`
- Work mode: `full-feature` → AC sources: `spec.md` and `user-story.md`
- Audit type: REAUDIT, remediation cycle 1 exit
- Supersedes: `feature-audit.2026-08-08T23-10.md`
- Timestamp: 2026-08-09T01-35

## Baseline

The audit baseline is the merge base `c939b5b8` with
`epic/parallel-orchestration-integration`, not `main`. The branch carries exactly one commit
(`59796e82`), so `git diff c939b5b8..HEAD` is the complete and authoritative feature diff:
152 files, +14915 / -113.

Required action R-1 from the previous pass — "the branch had zero commits, so no PR could be
opened" — is **RESOLVED**. A commit exists and a pull request can now be opened against the
integration branch.

## Work Mode Resolution

`issue.md` carries the marker `- Work Mode: full-feature`. Per the acceptance-criteria-tracking
protocol, the AC sources are therefore `spec.md` **and** `user-story.md`. Both files carry an
identical 16-item `## Acceptance Criteria` section. The `## Acceptance Criteria (early draft)`
section in `issue.md` is not an AC source in `full-feature` mode and was not used for evaluation.

## AC Evaluation

16 criteria, evaluated independently against code and re-executed tests rather than against the
executor's report.

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Layer 1 denies conflicting prior-cohort item with non-terminal `merge_status`, reason carries `PARALLEL_COHORT_BARRIER_BLOCKED` | **PASS** | `enforce-parallel-cohort-barrier.Tests.ps1` deny contexts; 123/123 Pester tests re-run green; hook line 467 reads checkpoint through the seam |
| 2 | Layer 1 allows when every conflicting prior-cohort item is `merged`/`worktree_removed`, and allows an item with no conflicting prior-cohort neighbours | **PASS** | allow contexts in the same suite, driven by mocked well-formed checkpoints |
| 3 | Layer 1 allows a delegation whose prompt lacks `Parallel mode: true` | **PASS** | activation-gate context; `$script:ParallelModeMarker` checked before any checkpoint read |
| 4 | Layer 1 allows a delegation whose `subagent_type` is not `orchestrator` | **PASS** | activation-gate context |
| 5 | Layer 1 fails closed on missing or malformed checkpoint JSON | **PASS** | test lines 224 (`-MockWith { $null }`) and 232 (`-MockWith { '{ broken json' }`), both assert `deny` + `PARALLEL_COHORT_BARRIER_BLOCKED` |
| 6 | Layer 1 fails closed on unresolvable target (no path token, no `items[]` record, no current-generation cohort) | **PASS** | test line 241 (no path token) plus the two sibling contexts |
| 7 | `ci_green` does not satisfy the barrier; Layer 1 denies | **PASS** | Pester context; corpus case `earlier-ci-green-does-not-satisfy-barrier` expects 1 message; `MERGED_MERGE_STATUSES` excludes `ci_green` in both runtimes |
| 8 | Layer 2 through `validate_parallel_orchestrator_state_text` emits exactly one message per violated edge in the byte-exact form, covering structural and temporal readings | **PASS** | 64 pytest cases re-run green; corpus `same-cohort-conflicting-pair` (structural, 1), `three-conflicting-items-one-cohort` (structural, 3, ordered), `cross-cohort-later-start-earlier-pr-open` (temporal, 1), `merge-confirmed-after-later-start` (temporal timestamp disjunct, 1); literals dumped and confirmed to carry no context prefix and no trailing period |
| 9 | Layer 2 is key-gated; clean multi-cohort checkpoint produces zero barrier errors | **PASS** | corpus `gating-key-absent-cohorts`, `gating-key-absent-conflict-edges`, `gating-keys-absent-both` (all expect 0) and `clean-ordered-two-cohort-pair` (expects 0) |
| 10 | Removal gate denies non-terminal `merge_status`, fails closed on unreadable checkpoint or unmatched path, with `PARALLEL_WORKTREE_REMOVAL_BLOCKED` | **PASS** | `enforce-parallel-worktree-removal-gate.Tests.ps1`, 20 seam mocks; hook line 212 reads via seam |
| 11 | Removal gate allows `merged`/`worktree_removed`, and allows non-`git worktree remove` commands unconditionally | **PASS** | allow contexts in the same suite |
| 12 | Extended invocation-origin hook denies `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` from caller `orchestrator`; allows both from main thread and non-orchestrator callers | **PASS** | `$script:ParallelSubagentTypes` branch returns `PARALLEL_INVOCATION_ORIGIN_BLOCKED`; allow paths unchanged; 154 added test lines cover all six combinations |
| 13 | Epic invocation-origin behavior preserved byte-identically; all pre-existing tests pass unmodified | **PASS** | epic reason string is an unchanged context line in the diff; exact-string assertions at test lines 222 and 234; test file numstat **154 added / 0 deleted** |
| 14 | `.claude/settings.json` registers the cohort barrier under `PreToolUse`/`Agent`, the removal gate under `PreToolUse`/`Bash`, and a `SubagentStop` matcher `parallel-orchestrator` | **PASS** | parsed settings confirm matcher `Agent` → `enforce-parallel-cohort-barrier.ps1`, matcher `Bash` → `enforce-parallel-worktree-removal-gate.ps1`, `SubagentStop` matcher `parallel-orchestrator` → `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` |
| 15 | Line coverage >= 85% and branch coverage >= 75% for all new and changed code, with no regression on changed lines | **PASS** | new TS module 99.51% / 98.88%; new Python module 99.07% / 98.21%; seam file 99.38% / 92.11%; hooks 96.38% / 91.80% / 91.67% line; repo-wide TS 96.56% / 89.87%, Python 91.88% / 83.96%, PowerShell 94.34% line. Changed-line regression: none — the seam file's two uncovered lines (253-254) are pre-existing and unrelated; the two added lines (36, 315) are covered. PowerShell BRANCH is not emitted by the toolchain; see the explicit absence note in the policy audit |
| 16 | All test files mirrored under `tests/`, use mocked read seams instead of temp files, and are deterministic | **PASS** | `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/dev_tools/test_*.py`, `extensions/drm-copilot/test/lib/validate/*.test.ts` all mirror their production trees; zero matches for temp-file and live-checkpoint patterns; both hooks read only through named seams; no clock, timer, or randomness in any new file |

**Result: 16 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## Previous-Pass Finding Disposition

| ID | Previous finding | Disposition |
|---|---|---|
| B-1 | `parallel-orchestrator-state-core.ts` held an EMPTY F7 extension seam, so the TypeScript surface reported a cohort-ordering violation as clean while Python rejected it | **CLOSED** |
| R-1 | Branch had zero commits, so no PR could be opened | **RESOLVED** |

### B-1 closure basis

Three independent verifications, detailed in `policy-audit.2026-08-09T01-35.md`:

1. **Seam invokes the helper, minimally.** The diff against the merge base contains exactly two
   `+` lines and zero `-` lines for that file: the import at line 36 and
   `errors.push(...validateCohortBarrierOrdering(state));` at line 315, the latter inside the
   F3-reserved delimiter. File grew 320 → 322. No existing line changed.

2. **Port reproduces the reference semantics.** Every item on the required checklist verified as
   MATCH: the barrier-satisfying set `{merged, worktree_removed}` with `ci_green` excluded;
   `ITEM_START_TIMESTAMP_FIELD = "worktree_created_at"`;
   `MERGE_CONFIRMATION_TIMESTAMP_FIELD = "merged_at"`; strict generation-equality current-generation
   projection ignoring superseded generations; the structural reading; the temporal reading with
   both disjuncts; degradation to structural-plus-status when either timestamp is absent or
   non-string; key-gated backward compatibility; identical folder-hint prefix constants and
   first-occurrence resolution; and the byte-exact message with `<a>` the earlier/first endpoint,
   no context prefix, and no trailing period. No semantic divergence found within the corpus's
   declared value scope.

3. **Seam is empirically live.** Eight of the 30 corpus cases assert non-empty ordered message
   lists through the dispatched entry point `validateArtifact`. All pass. An empty seam would fail
   all eight.

## Parity Mechanism Verdict

**Adequate.** Both runtimes consume the same 30 files, assert against the same
`expected_barrier_errors` lists element-for-element in order, restate the filter token from the
specification rather than importing the implementation constant, and guard against vacuity with a
floor of 30, an on-disk-count equality assertion, a both-verdicts-present assertion, and a
name-equals-file-stem check. The TypeScript side routes through `validateArtifact` with artifact
type `parallel-orchestrator-state` and imports the helper nowhere.

- **Would it have caught B-1?** Yes. Eight failing cases.
- **Would it catch a future one-sided edit?** Yes for any behavior the corpus exercises. Not for
  the branches in Advisory A-1/A-2 or the value classes in Informational I-1.

### Named corpus gap

The corpus does not pin **first-occurrence resolution semantics** (Advisory A-1). No document
carries a duplicate `issue_num` in `items[]`, and none places one member in two current-generation
cohort rows. Both runtimes implement first-occurrence correctly today, verified by reading, but
replacing the TypeScript `!assignments.has(key)` guard with an unconditional `set` would flip the
semantics to last-occurrence and leave all 66 parity assertions green. Secondary gaps (Advisory
A-2): no non-object `items[]` entry, no non-positive-integer `issue_num`, and no absent/blank
`feature_folder`. Recommended as follow-up corpus additions, not merge blockers.

## Carried-Forward Verifications

All previously cleared items were re-verified and remain intact.

| Item | Verdict | Key evidence |
|---|---|---|
| Epic invocation-origin behavioral preservation | PASS | `EPIC_INVOCATION_ORIGIN_BLOCKED` is an unchanged context line; parallel handled by an early return placed before it; allow paths unchanged; non-gated targets still do not parse the payload; test file 154 added / 0 deleted |
| Concurrent-feature boundary (F6 #442, F8 #446) | PASS | single SKILL.md hunk confined to `## Enforcement Hooks (F7)`; all three headings survive in original order at identical line numbers 435 / 439 / 491 in **both** the repo copy and the bundled mirror; copies byte-identical |
| PowerShell hook seam binding | PASS | `Get-ParallelCohortBarrierCheckpointContent` (defined :54, called :467) and `Get-ParallelWorktreeRemovalGateCheckpointContent` (defined :34, called :212); mocked `$null` and malformed JSON both change the decision to `deny` |
| Test isolation | PASS | zero matches for temp-file and live-checkpoint patterns across all new suites; only read-only committed-corpus loads |
| Known pre-existing Pester failure out of scope | PASS | `enforce-pr-author-skill.Tests.ps1` is **not in the diff**; the failing test calls `Invoke-PrAuthorSkillDecision` with no seam mock, so the hook reads the live working-tree checkpoint; `/artifacts` is gitignored (`.gitignore:6`). Not charged to this feature |
| Bundle contracts | PASS | all five changed `.claude` files byte-identical to their mirrors (`cmp` exit 0 each); `pack-manifests/core.json` gained exactly the two new hook entries in alphabetical position |
| F5 reserved-body pin narrowing | PASS | `RESERVED_HEADINGS` untouched; heading-order and uniqueness pins untouched; `LANDED_WAVE_FOUR_FEATURES` contains `"F7"` alone, so the body pin remains fully in force for F6 and F8; 36 surface-contract tests pass |

## Feature-Review Workflow Determinations

- **`modified-workflow-needs-green-run`: NOT TRIGGERED.** No file under `.github/workflows/**`,
  `.github/actions/**`, or `scripts/benchmarks/**` appears in the branch diff.
- **`ci.yml` scheduling: VERIFIED POSITIVELY.** `.github/workflows/ci.yml` declares
  `pull_request: branches: [main, development]`. A pull request based on
  `epic/parallel-orchestration-integration` matches neither filter, so `ci.yml` schedules no run.
  Established by reading the trigger block, not by waiving a check. Consequence recorded: repository
  CI provides no signal for this branch, so local gate evidence plus the independent re-execution
  documented in the policy audit is the only available verification.

## Definition of Done

The `## Definition of Done` section in `spec.md` is a separate section from
`## Acceptance Criteria` and is not an AC source under the tracking protocol; its seven checkboxes
remain unchecked, as do the four `## Seeded Test Conditions` items. Substantively, the underlying
conditions are satisfied: AC are documented and mapped to tests, behavior matches, tests added,
edge cases and error handling covered, toolchain pass completed. No agent-authored AC item was added
or removed, per the no-phantom-criteria rule. The unchecked DoD boxes are a documentation-hygiene
observation, not an acceptance gap.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md
          docs/features/active/2026-08-07-parallel-enforcement-hooks-440/user-story.md
- Total AC items: 16 (per file; identical lists)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none
```

All 16 criteria were already marked `[x]` in both source files by the executor. This audit
independently evaluated each as PASS, so no checkbox required a change and none was modified. No
newly checked-off items to report.

## Verdict

**READY TO MERGE.**

- Blocking findings: 0
- PARTIAL findings: 0
- Advisory findings: 5 (A-1 through A-5)
- Informational findings: 2 (I-1, I-2)
- AC: 16 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED
- B-1: CLOSED. R-1: RESOLVED.

No remediation inputs artifact is produced for this cycle. The Advisory findings are recommended
follow-up work — principally the two corpus additions that would pin first-occurrence resolution
semantics — and do not block merge.
