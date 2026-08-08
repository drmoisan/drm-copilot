# Feature Audit — Blast-radius under-reporting gaps (Issue #452)

- Timestamp: 2026-08-08T13-26
- Branch: `bug/blast-radius-under-reporting-452`
- Base branch: `epic/parallel-orchestration-integration` (merge base `05c48ced`)
- Commit: `7a835c38` — 108 files, +7494 / -358
- **Work mode: `full-bug`** (from `- Work Mode: full-bug` in `issue.md`)
- **AC source: `spec.md` only** — per the `full-bug` mode rule in the acceptance-criteria-tracking
  skill. `user-story.md` is correctly absent for this mode; its absence is **not** a defect and is
  not reported as one.
- **Total Blocking findings: 0**
- **Total Non-blocking findings: 6**

## Defect Statement and Resolution

`issue.md` records two verified under-reporting gaps in the F1 blast-radius library, both
conformant with the approved F1 specification and both weakening the epic's fail-closed guarantee.

| Gap | Defect | Resolution delivered | Verified |
|---|---|---|---|
| 1 | `classify_path_token` requires `/`, so the three separator-free `shared_surfaces` entries (`poetry.lock`, `package-lock.json`, `quality-tiers.yml`) can never be extracted from plan or spec text; V2 cannot fire for them at plan time. | Path-token classification admits a separator-free token that is an exact ordinal member of the configured `shared_surfaces` list, sourced from that list rather than a second hardcoded one. | Yes |
| 2 | `conflicts` treats a listed directory and a glob beneath it as disjoint, while V1's `is_path_subsumed` treats a file under that directory as covered; two radii that provably share files can report no `path_overlap`. | The `conflicts` path comparison honours listed-directory prefixes on both sides of the relation, aligning it with `is_path_subsumed`. | Yes |

### Reproduction 1 — corrected, both languages

Base behaviour (from `issue.md`): `extract_plan_paths("- [ ] [P1-T1] Touch \`poetry.lock\`.")` -> `()`.

Reviewer-executed, current branch:

```
Python : extract_plan_paths(plan, root_surfaces=("poetry.lock",))  -> ('poetry.lock',)
PowerShell : Get-PlanPaths -PlanText $plan -RootSurface @('poetry.lock')  -> [poetry.lock]
PowerShell : Get-PlanPaths -PlanText $plan                                 -> []   (backward compatible)
```

### Reproduction 2 — corrected, both languages

Base behaviour (from `issue.md`): `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` -> `False`
while `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` -> `True`.

Reviewer-executed, current branch:

```
Python     : _entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")            -> True
PowerShell : Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**' -> True
PowerShell : Test-PathSubsumed -Path 'scripts/dev_tools/x.py' -CoveringPath @('scripts/dev_tools') -> True
```

The V1/`conflicts` misalignment that defined Gap 2 is closed. Verified exhaustively: over a
164,025-pair sweep there is now **no** case where `is_path_subsumed` reports coverage while
`_entries_overlap` reports disjointness.

### Fail-closed monotonicity — the load-bearing property

A correction that reported *less* overlap would be a regression, not a fix. Re-derived from the
code by the reviewer (not read from the executor's evidence artifact):

- **Structural:** each changed branch has the form `<old predicate> or <new disjunct>`; branch
  selection and the glob×glob branch are unchanged. Superset holds by construction.
- **Empirical:** 164,025 ordered pairs over a 405-token generated alphabet —
  **0 True-to-False transitions**, 0 symmetry violations.

The corrected relation is a strict superset of the previous one.

## Acceptance Criteria Evaluation

Source: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md`, lines
633-671. All 39 items were checked off by the executor. Each was independently re-verified against
the diff and by execution.

| # | Line | Criterion (abbreviated) | Verdict | Verification |
|---|---|---|---|---|
| 1 | 633 | `classify_path_token` accepts keyword-only `root_surfaces`, returns `PATH_KIND_CONCRETE` for exact ordinal member | PASS | Executed: returns `concrete` for all three configured surfaces |
| 2 | 634 | `extract_paths_from_lines` / `extract_plan_paths` accept and forward `root_surfaces` | PASS | Read `_blast_radius_extraction.py:150-208`; forwarding confirmed |
| 3 | 635 | `config_root_surfaces` is the only source; no surface name in production modules | PASS | `grep` over `scripts/dev_tools/`, `.claude/lib/`, bundled mirror: **no hits** |
| 4 | 636 | Both entry points read via `config_root_surfaces`; named pytest selection passes unmodified | PASS | `pytest -k "passes_v1_against_its_own_plan or passes_v2"` -> `12 passed, 42 deselected` |
| 5 | 637 | Ordinal exact membership: `Poetry.Lock` and `README.md` rejected | PASS | Executed: both return `None` |
| 6 | 638 | Backward compatibility: `classify_path_token("poetry.lock")` still `None` | PASS | Executed: returns `None` |
| 7 | 639 | Three PowerShell functions accept `[string[]]$RootSurface = @()`; token behaviour matches | PASS | Executed: `concrete` with `-RootSurface`, `$null` without |
| 8 | 640 | `Get-ConfigRootSurface` exists, sources only `shared_surfaces`, `@()` for missing key, passed by both entry points | PASS | Executed: empty config -> `count=0`; call sites read at `BlastRadius.psm1:160`, `BlastRadiusValidation.psm1:348` |
| 9 | 641 | Gap 1 two-language equivalence over 6 named tokens, asserted by a shared fixture | PASS | Cross-language comparison over 8 tokens (superset of the 6): **0 mismatches**; fixtures `derivation-root-surface-{reached,not-configured}.json` added |
| 10 | 642 | Gap 2 Python concrete×concrete, anchored `entry.rstrip("/") + "/"`, both directions | PASS | Read `_blast_radius_glob.py:624-629`; executed |
| 11 | 643 | Gap 2 Python concrete×glob; `("scripts/dev_tools","scripts/*/a.py")` -> `True` | PASS | Executed: `True` |
| 12 | 644 | Python glob×glob branch byte-identical to pre-change form | PASS | AST comparison against base revision: branch text unchanged |
| 13 | 645 | Gap 2 PowerShell: same disjuncts, `TrimEnd('/')`, `Ordinal` on every `StartsWith`, glob×glob unchanged | PASS | Read `BlastRadiusGlob.psm1:310-345`; every comparison passes `[System.StringComparison]::Ordinal` |
| 14 | 646 | Reproduction 1 corrected in both languages | PASS | Executed, both languages (see above) |
| 15 | 647 | Reproduction 2 corrected in both languages | PASS | Executed, both languages (see above) |
| 16 | 648 | `is_path_subsumed` / `Test-PathSubsumed` unmodified apart from relocation | PASS | AST comparison: **byte-identical**; PowerShell executed -> `True` |
| 17 | 649 | Monotonicity asserted by a test in each language, incl. 4 named pairs | PASS | `PREVIOUSLY_OVERLAPPING_ENTRY_PAIRS` (Python) and `Context 'Monotonicity, the fail-closed invariant'` (PowerShell) both present; all 4 pairs re-verified `True` |
| 18 | 650 | 4 regression guards still `False` / `$false` in both languages | PASS | All 4 executed `False` in Python; PowerShell table matched Python on all 164,025 pairs |
| 19 | 651 | F1 spec line 42 amended, contains `issue #452` | PASS | Diff of `...-447/spec.md` line 42 confirms |
| 20 | 652 | F1 spec line 118 amended (both clauses), contains `issue #452` | PASS | Diff confirms both concrete×concrete and glob×concrete clauses |
| 21 | 653 | `### Behavior semantics` bullet added recording symmetry and the accepted over-report | PASS | Diff confirms bullet at line 53 |
| 22 | 654 | F1 Python surface block and PowerShell surface list updated | PASS | Diff confirms `extract_plan_paths` (lines 94-96) and `Get-PlanPaths -PlanText [-RootSurface]` (line 133) |
| 23 | 655 | >= 5 new fixtures of the 5 named kinds | PASS | Exactly 5 added, one per named kind |
| 24 | 656 | No fixture expectation relaxed; only `A` entries | PASS | `git diff --name-status`: 5 `A`, **0 `M`, 0 `D`** |
| 25 | 657 | Both anti-vacuity floors raised from 12 to on-disk count; both parity drivers pass | PASS | Both raised 12 -> **26**, matching 26 on disk; both drivers pass |
| 26 | 658 | `BlastRadiusGlob.Tests.ps1:309-316` inverted to `Should -BeTrue`, renamed, comment cites #452 | PASS | Diff confirms all three; test passes |
| 27 | 659 | Python counterpart to the inverted Pester test exists | PASS | `test_a_directory_entry_overlaps_a_file_beneath_it` at `test_blast_radius_conflicts.py:276` |
| 28 | 660 | Bundled mirror byte-identical; push-down contract test passes | PASS | `diff -r` over the whole directory: **identical**; contract test passes |
| 29 | 661 | No new `.psm1`; `core.json`, runsettings and mirror unmodified; manifest test passes | PASS | None appear in `git diff --name-only`; `BlastRadius.Manifest.Tests.ps1` passes |
| 30 | 662 | Python split is a pure move (8 named symbols, no logic edit but the Gap 2 disjuncts); import graph acyclic | PASS (with note) | All 8 symbols present; 7 byte-identical, `_entries_overlap` differs only by the Gap 2 disjuncts; graph verified **acyclic**. See note below and NB-4. |
| 31 | 663 | PowerShell relief is a pure move; `Get-OrdinalSortedEntry` relocated and re-exported; callers unmodified | PASS | Relocated verbatim to `BlastRadiusGlob.psm1:348-384`, re-exported via `BlastRadiusExtraction.psm1:42`; 320 blast-radius tests pass |
| 32 | 664 | No file in the change set exceeds 500 lines | PASS | 32 non-Markdown files measured; **0 over 500**. Max 491 |
| 33 | 665 | Config-shape assertion in both languages (separator-free surfaces wildcard-free) | PASS | `test_blast_radius_config.py:228` and the `Describe 'Committed blast-radius truth table shape'` addition |
| 34 | 666 | Full Python toolchain passes in a single pass; no new suppression | PASS | Re-run by reviewer: black 0, ruff 0, pyright 0, pytest 2886 passed. No suppression added |
| 35 | 667 | Coverage >= 85% line / >= 75% branch, no regression on changed lines, no exclusion added | PASS | 91.72% line / 83.60% branch; baseline 91.71% / 83.58% (improved). No exclusion added |
| 36 | 668 | Full PowerShell toolchain passes in a single pass, zero PSScriptAnalyzer findings | **PARTIAL** | Format 0, analyze 0 with zero findings; **Pester exits 2** on two pre-existing environmental failures. **Unchecked by this review.** See NB-1 / NB-2 |
| 37 | 669 | `config/blast-radius.json` unmodified | PASS | `git diff -- config/blast-radius.json` produces no output |
| 38 | 670 | Declared non-goals untouched | PASS | Neither non-goal file appears in `git diff --name-only` |
| 39 | 671 | `BlastRadius.Tests.ps1:248-262` inverted to count 1 / `poetry.lock`, renamed, comment cites #452 | PASS | Diff confirms all three; assertion **strengthened** from one to two assertions; test passes |

### Note on item 30 (spec.md line 662)

Every operative clause of this criterion is satisfied: `_blast_radius_glob.py` contains all eight
named symbols, the only logic edit is the authorized Gap 2 disjuncts, and the import graph is
acyclic (verified: `glob`, `thresholds`, and `extraction` are all leaves). The criterion's
descriptive parenthetical — "`validation` imports `extraction` and `glob`" — is now incomplete,
because the later `_blast_radius_thresholds.py` relief added a `validation -> thresholds` edge.
That edge does not create a cycle, so the operative requirement holds.

The item is graded **PASS and left checked**, because the delivered work fully satisfies what the
criterion requires; the inaccuracy is in the criterion's own stale descriptive text, not in the
delivery. Unchecking would incorrectly signal undelivered work. The stale text is recorded
separately as **NB-4** with a recommendation to amend the AC in a follow-up.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md
- Total AC items: 39
- Checked off (delivered): 38
- Remaining (unchecked): 1
- Items remaining:
  - "Full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format`,
     `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` with
     `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, with zero PSScriptAnalyzer
     findings." (spec.md:668)
```

### Check-off actions taken by this review

- **Newly checked off: none.** All 39 items were already checked by the executor, and 38 were
  independently confirmed as genuinely delivered.
- **Unchecked: 1.** `spec.md:668` was changed from `[x]` to `[ ]` because the criterion as
  literally written ("passes in a single pass") is not satisfied — the Pester stage exits 2. The
  criterion text was not modified. This follows the acceptance-criteria-tracking rule that
  PARTIAL/FAIL/UNVERIFIED items are left unchecked and the gap documented.
- **No AC item was added, removed, or reworded.**

### AC honesty assessment

The caller asked specifically whether any checked item was not actually delivered, and stated that
such a case would be Blocking. **No such case was found.** 38 of 39 items are genuinely satisfied
by the diff and by reviewer-executed verification. The single exception (item 36) is not an
overstatement of delivered work: the executor disclosed the exact qualification in its own
evidence artifact (`evidence/qa-gates/final-powershell-pester-coverage.2026-08-08T16-32.md`)
rather than concealing it, and the shortfall is caused entirely by two pre-existing failures in
suites this branch does not touch. It is graded PARTIAL and unchecked for literal accuracy, not
because work was claimed but not done.

## Adjudication of the Two Known Conditions

### Condition 1 — two failing Pester tests

**Adjudication: pre-existing test-isolation defect, out of scope for issue #452, Non-blocking
(NB-2).** Reasoning, in three independent strands:

1. **Temporal.** Both failed identically at the Phase 0 baseline
   (`evidence/baseline/phase0-powershell-pester-coverage.2026-08-08T10-42.md`, `Failed | 2`),
   captured before any change on this branch. The post-change failure count is unchanged at 2 while
   the passing count rose 1984 -> 2020.
2. **Causal.** Neither test file, nor the hook scripts they exercise
   (`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`,
   `enforce-epic-wave-barrier.ps1`), appears anywhere in the 108-file branch diff. The reviewer
   reproduced both failures and confirmed the cause is the live orchestration session's own
   checkpoint: the failure message reads `EPIC_WAVE_BARRIER_BLOCKED: '452' cannot mutate until
   every depends_on edge is merged or worktree_removed in the epic checkpoint.` The tests read the
   real on-disk `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam.
3. **CI-neutral.** `artifacts/` is gitignored (`git check-ignore -v` -> `.gitignore:6:/artifacts`)
   and `git ls-files artifacts/` returns 0 files. On a clean checkout or a CI runner neither file
   exists and both tests pass. The condition cannot reach the merge gate.

It is nonetheless a genuine violation of `.claude/rules/general-unit-test.md` ("Tests must not rely
on mutable global state or external configuration that can change between runs"). The correct
disposition is a **separate follow-up issue** to introduce a mocked seam, not a Blocking finding
against #452. Holding an unrelated bug fix responsible for a defect it neither caused nor can
reach would be incorrect.

### Condition 2 — spec.md line 668

**Adjudication: PARTIAL, unchecked, Non-blocking (NB-1).** The criterion's literal text is not
satisfied because the Pester stage exits 2. The shortfall is entirely attributable to Condition 1;
zero blast-radius tests fail (reviewer-executed scoped run: **320 passed, 0 failed**), and the
format and analyze stages both pass with zero PSScriptAnalyzer findings. The executor flagged the
qualification explicitly rather than checking the item silently, which is the correct behaviour.
This review unchecks the item for literal accuracy. It may be re-checked once Condition 1 is
remediated, or the criterion re-scoped to exclude the two out-of-scope suites.

## Requirements Traceability Beyond the AC List

| `issue.md` requirement | Delivered | Evidence |
|---|---|---|
| Candidate resolution 1 — extend classification from `shared_surfaces` itself, not a second hardcoded list | Yes | `config_root_surfaces` / `Get-ConfigRootSurface`; grep for hardcoded names returns no hits |
| Candidate resolution 2 — align `conflicts` with `is_path_subsumed`, preserving fail-closed semantics | Yes | Exhaustive check: `is_path_subsumed` now implies `_entries_overlap` in 100% of 164,025 pairs; 0 monotonicity violations |
| Candidate resolution 3 — update F1 spec and parity corpus in the same change | Yes | `...-447/spec.md` amended at 4 locations; 5 fixtures added |
| "Must keep the two implementations byte-equivalent in behaviour" | Yes | 164,025-pair cross-language comparison: **0 mismatches** |
| "Must extend `tests/fixtures/blast_radius/` rather than weakening existing expectations" | Yes | 5 `A`, 0 `M`, 0 `D`; both anti-vacuity floors raised |
| Timing — resolve before F4 (`parallel-planner`, #443) is executed | Yes | Delivered ahead of F4; `derive_blast_radius` now reaches the configured root surfaces at plan time, so F4's declared radius will not inherit the blindness |

The primary consumer risk the issue identified — F4 computing the authoritative declared radius by
calling `derive_blast_radius` and thereby inheriting plan-time blindness — is closed at the source.

## Scope Confirmation

The audit covered the full branch diff against `epic/parallel-orchestration-integration`, not the
scope of any plan, task, or phase. The caller's "out of scope" directives named only files with
zero changed lines in the diff and therefore narrowed nothing; no scope narrowing required
rejection. Details in `policy-audit.2026-08-08T13-26.md`, section "Scope Confirmation and Rejected
Scope Narrowing".

The diff touches no workflow file, so `modified-workflow-needs-green-run` does not apply and no
green workflow run is required.

## Verdict

**PASS with one PARTIAL acceptance criterion. 0 Blocking findings, 6 Non-blocking findings.**

Both defects described in issue #452 are genuinely fixed, in both language implementations, in the
fail-closed direction, with a verified superset relation and verified cross-language equivalence.
The fixture corpus was extended and never weakened, and exactly the two authorized assertion
inversions were made. 38 of 39 acceptance criteria are confirmed delivered; the one exception is a
literal-accuracy qualification caused entirely by a pre-existing, environment-induced test-isolation
defect in two suites this branch does not touch, which cannot reproduce on a clean checkout.

No remediation is required before merge. Two follow-up issues are recommended: mocked seams for the
two hook suites (NB-2), and Pester coverage instrumentation for `Import-Module`-loaded modules
(NB-3).
