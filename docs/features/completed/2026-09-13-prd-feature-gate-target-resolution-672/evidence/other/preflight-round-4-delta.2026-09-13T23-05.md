# Preflight Round 4 — Revision Delta (issue #672)

Timestamp: 2026-09-13T23-05
Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
Plan under review: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md`

Clock note: the reviewing machine's local clock read `2026-09-13T23-05` when this artifact was written. The
plan's `Last Updated` value of `2026-09-13T23-45` is 40 minutes ahead of that reading. The filename's
`round-4` element, not the timestamp, carries the round ordering.

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED — the single blocking defect carries exact replacement text and a
mechanism verified against the tree; it requires no new design ruling. The two low findings are wording
corrections inside already-agreed text.

---

## Priority 1 — B6 and L5-L8 are closed

| # | status | verification performed in this pass |
|---|---|---|
| B6 delta 1 | closed | `[P2-T1]` (plan line 343) defines the unfiltered pipeline in a separate paragraph, scopes its own acceptance to the filtered reset, and states the assignment: `[P0-T10]`, `[P2-T4]`, `[P4-T1]`, `[P5-T1]` filtered; `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, `[P6-T4]` unfiltered. |
| B6 delta 2 | closed | `[P2-T9]` (369), `[P5-T4]` (449), `[P6-T4]` (465) each name the unfiltered pipeline, require the post-removal verification count of `0` in their acceptance, and cite the `SessionStart` writer at `.claude/settings.json` line 84 and `persist-session-id.ps1` line 161. |
| B6 delta 3 | closed | `[P0-T7]` (309) carries the removal "Immediately before the pytest invocation" and its acceptance requires the pre-removal names and the post-removal count of `0`. |
| B6 delta 4 | closed with one wording defect | Preamble (100-108) names `enforce-powershell-batch-budget.ps1` and `persist-session-id.ps1` and separates parity clearing from batch-boundary resets. See **L9**. |
| L5 | closed | `[P2-T2]` (349) names `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Function verified present at that file's line 118. |
| L6 | closed | `[P0-T9]` (313) carries the evaluation instruction and halts "before starting `[P0-T10]`". |
| L7 | closed | `[P3-T3]` (381) reads "the existence mock answering true only for the bare repo-relative path the hook composes in state B, the modelled session root and the target root coinciding so that no prefix is applied". |
| L8 | closed | `[P3-T9]` (395) reads "Additionally, for each row that failed:". |

Mechanism re-derived independently rather than taken from the record:

- `.claude/settings.json` line 84 registers `persist-session-id.ps1` as a `SessionStart` command; line 128 is
  the `Write|Edit` matcher; 136 and 144 register the Python and PowerShell batch-budget hooks.
- `persist-session-id.ps1` line 161 composes `(Get-Location).Path` + `.claude/state/current-session-id`.
- `.gitignore` line 68 is `.claude/state/`.
- `test_push_down_claude_resource_contracts.py`: line 21 `REPO_ROOT = Path(__file__).resolve().parents[3]`;
  25 `SCOPED_ROOTS`; 51-60 `list_scoped_files` with `rglob("*")`; 118 the test function; 130-134 the two
  exclusions; 136-139 `Repo file missing from bundle:`. No gitignore consultation anywhere in the file.
- A repository-wide search of `.claude/hooks`, `.claude/lib`, and `scripts` returns exactly three writers of
  `.claude/state`, all writing flat files: `persist-session-id.ps1` 161,
  `enforce-powershell-batch-budget.ps1` 366, `enforce-python-batch-budget.ps1` 363.

## Priority 1 — adjudication of the `[P2-T1]` placement deviation

**Upheld.** The delta directed the unfiltered-pipeline block to be appended after the sentence ending
"...a worktree-derived identifier.", which sits before the filtered pipeline's own verification sentence and
before the `Acceptance:` line that governs it. Placing a second pipeline definition there would leave the
acceptance clause "the verification enumeration reports a count of `0`" with two candidate antecedents. The
planner's placement at the end of the task, combined with the added clause "this task's acceptance governs
that filtered reset only", removes the ambiguity. The delta's placement would have reproduced the
stated-scope-versus-bound-pipeline disagreement that B6 was written to close.

**The widened clause is upheld.** "reports `Repo file missing from bundle:` for any file it finds there" is
accurate: the assertion at lines 136-139 fires for every enumerated repo file with no bundled counterpart,
not only for the batch-budget file. The narrower prior wording understated the test's behaviour.

## Priority 2 — adjudication of the `current-session-id` safety finding

**SAFE. No denial path exists.** Verified independently against the hook source rather than against the
planner's statement.

1. Session-id resolution in `enforce-powershell-batch-budget.ps1` is three-step, at lines 139-173:
   `$SessionId` (bound at the entry point, line 424, from `$env:CLAUDE_SESSION_ID` only — not from the
   payload), then the contents of `.claude/state/current-session-id` at 150-160, then
   `worktree-<leaf>-<sha-prefix>` at 162-173. Losing the file changes only which of the three branches is
   taken, and therefore only the state-file NAME composed at line 366.
2. The hook's only deny is at lines 293-297: `if ($targetList.Count -ge $cap)`, reached only for a path not
   already in the rehydrated list (line 289 returns allow for a repeat path). A list that starts empty
   cannot deny. `prodCap` and `testCap` are both set to 3 at the entry point, lines 426-427.
3. The one theoretical denial vector is the inverse of the permissive one: if the worktree-derived name
   collided with a state file left at cap by an earlier session in the same worktree, the fresh resolution
   would rehydrate a full list and deny. That vector is closed by the same instruction that creates the
   naming switch — the unfiltered removal deletes **every** file under `.claude/state`, including any stale
   `powershell-batch-budget.worktree-*.json`, so no at-cap list survives to be rehydrated.
4. No boundary task's verification reads a different file than the budget hook writes. The boundary
   enumeration is the glob `powershell-batch-budget.*.json`, which matches both the session-id-named and the
   worktree-named form.
5. Ordering: every unfiltered removal is followed by no production PowerShell write before the next reset.
   `[P0-T7]` precedes `[P0-T10]` and `[P0-T12]`; `[P2-T9]` is followed by `[P2-T10]` (no write) and by
   Phase 3, which writes one test path into a fresh list, then by `[P4-T1]`; `[P5-T4]` and `[P6-T4]` are
   followed by no source write. Evidence `.md` writes cannot recreate the file: both budget hooks early-return
   on a non-matching extension (PowerShell line 348, Python line 345) before the state directory is composed
   (lines 352 and 349 respectively).
6. No other consumer exists. A search of `.claude/hooks`, `.claude/lib`, and `scripts` finds
   `current-session-id` read only by the two batch-budget hooks. No gate denies on an unresolvable session id.

The consequence is permissive-only: a fresh, empty slot list. No batch boundary in this plan depends on a
count being non-zero as a gate; `[P2-T1]`'s pre-reset expectation is stated as an expectation with the
zero-file branch tolerated, and its acceptance is the post-reset count of `0`.

## Priority 3 — adjudication of N7-N11

| # | verdict | basis |
|---|---|---|
| N7 | **upheld, closed** | The divergence was real. `[P0-T8]` now ends "this arm is evaluated as soon as `[P0-T9]` records its determination and before `[P0-T10]` starts", matching `[P0-T9]`'s "before starting `[P0-T10]`". Sibling region checked: `[P0-T10]` is the next task and carries no conflicting precondition. |
| N8 | **upheld, closed; qualification is complete** | Every `[P2-T1]` reference in task text was enumerated (plan lines 80, 309, 315, 341, 353, 363, 369, 399, 443, 449, 465). All four boundary tasks carry **filtered**; all four delivery tasks carry **unfiltered**. Line 80 is the batch table's "opened by" cell and line 363 is a reference to `[P2-T1]`'s execution-route precedent, neither of which points at a pipeline. No unqualified pointer remains. |
| N9 | **upheld, closed** | `[P0-T7]` states the consequence and `[P0-T10]` states the interaction. `[P0-T10]`'s acceptance disjunction covers "the directory does not exist or holds no matching file", so `none` remains a satisfying observation. The batch table's A1 row carries the same note. Batch A1 still starts with a cleared budget because `[P0-T7]` clears it and no production write intervenes. |
| N10 | **upheld, closed; independently re-derived** | Verified at lines 139-173 and 289-297 of the batch-budget hook as set out in Priority 2. `[P2-T1]`'s paragraph at plan line 347 states the effect correctly and identifies no acceptance condition that depends on the pre-reset list's contents. |
| N11 | **upheld, closed** | `REPO_ROOT` is computed from the test file's own location at line 21, so the removal must run from the worktree root; `[P2-T1]` line 345 states that. The three-writer enumeration is complete against the tree as searched, and all three write flat files, so `-File` without `-Recurse` is sufficient. The stated `-Recurse` diagnostic keeps the count-of-`0` from being read as proof against a case it cannot observe. |

No new inconsistency was introduced in the sibling regions of N7-N11, with the single exception recorded at
**L9**, which sits in the region N10 and N11 describe.

---

## Blocking defect

### B7 — `[P5-T6]`'s change-set enumeration cannot fail once any part of the change set is committed

`[P5-T6]` derives the full changed-file set from `git status --porcelain --untracked-files=all` alone, and
declines the `git add --dry-run` companion for a correct reason: the pre-implementation gate classifies both
`add` and `commit` as staging commands at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
line 140 and denies them for a pathspec outside the orchestration-bookkeeping trees.

Porcelain status reports only uncommitted work. If any phase of this plan is committed before `[P5-T6]` runs
— which per-phase commit by the orchestrator produces — the enumerated set omits the committed paths, and in
the fully committed case it is empty. `[P5-T6]`'s four acceptance clauses are all negative ("no path in the
set matches ...", "none lies under `.codex/`"), so an empty set satisfies every one of them without the
constraint having been checked. `[P4-T4]`'s second acceptance clause reads the same set and inherits the same
vacuity, and AC17, AC18, and AC34 all map to `[P5-T6]` as their verifying task.

The task's own premise is also inaccurate in that state: it asserts the command "enumerates tracked
modifications and untracked files in one command" and yields "the full changed-file set", which holds only
while nothing has been committed.

The two mechanisms are complementary: an anchored name-listing diff is blind to untracked files, and
porcelain status goes empty once the change is committed. `[P0-T2]` already records the 40-character
pre-change HEAD, which is the correct anchor and needs no new ref knowledge.

**Delta — `[P5-T6]`.** Replace the first sentence:

> Verify the must-not-regress file-set constraints by enumerating the full changed-file set from two
> commands run from the worktree root, neither of them chained after a `cd`: `git status --porcelain
> --untracked-files=all`, which reports uncommitted modifications and untracked files, and
> `git diff --name-only $baselineHead`, binding `$baselineHead` to the 40-character commit identifier
> recorded in the `[P0-T2]` artifact, which reports every path changed since the pre-change baseline whether
> or not it has since been committed. The union of the two outputs is the changed-file set this task
> enumerates. Both are required: porcelain status reports nothing once a phase has been committed, and a
> name-listing diff cannot report an untracked file.

Then replace the acceptance sentence:

> Acceptance: the enumerated union is non-empty and names at least
> `.claude/hooks/enforce-prd-feature-before-planner.ps1`,
> `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, and
> `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, which is what
> distinguishes a genuine enumeration from an empty one; and within that union, no path matches
> `enforce-orchestration-preimplementation-gate`, none matches `enforce-epic-merge-gate`, none is
> `.claude/lib/hook-payload/HookPayload.psm1`, and none lies under `.codex/`.

Retain the existing `git add --dry-run` rationale sentence and the Codex-parity statement unchanged. Record
both commands and both exit codes in the artifact.

---

## Low defects

### L9 — the preamble says two hooks write under `.claude/state`; `[P2-T1]` says three

Preamble line 102 reads "Two hooks write there" and names `enforce-powershell-batch-budget.ps1` and
`persist-session-id.ps1`. `[P2-T1]` line 345 reads "all three writers place flat files directly under
`.claude/state`" and names `enforce-python-batch-budget.ps1` as the third. `[P2-T9]`, `[P5-T4]`, and
`[P6-T4]` each also cite the Python hook as a possible writer. The tree has three writers. The preamble's
count is the only statement in the plan that disagrees.

The error is descriptive rather than operative, because the preamble's operative instruction is
name-agnostic ("removes **every** file under `.claude/state`"). It is corrected so a reader does not derive a
two-name filter from it.

**Delta — preamble, "Intermediate parity window".** Replace "Two hooks write there — " with "Three hooks
write there — " and insert, after the `persist-session-id.ps1` clause and before the closing dash,
", and `enforce-python-batch-budget.ps1` composes `python-batch-budget.<session-id>.json` at line 363".

### L10 — four tasks now run two commands into one `Command:`/`EXIT_CODE:` pair

`[P0-T7]`, `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` each now execute a `.claude/state` removal and then a pytest
invocation, while their artifacts carry a single `Command:` and a single `EXIT_CODE:` and their acceptance
requires `EXIT_CODE: 0`. `[P2-T1]`'s exit-code attribution establishes that the enumeration leg legitimately
returns 1 when `.claude/state` does not exist, which is the current state of this worktree: the directory is
absent. An executor that records the removal leg's exit code in the single `EXIT_CODE:` field fails the
acceptance on a correct run.

**Delta — `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, `[P6-T4]` (identical in each).** Append to the removal paragraph:

> The artifact's `Command:` and `EXIT_CODE:` fields record the pytest invocation. The removal and
> verification commands and their own exit codes are recorded separately in `Output Summary:`, under
> `[P2-T1]`'s exit-code attribution, so a `1` from an enumeration against an absent `.claude/state`
> accompanied by a verified count of `0` is not read as a failure of this task.

---

## Sweep results recorded by the reviewer

- **Acceptance conditions that cannot fail:** one found, reported as B7. Every other condition was read
  against the state its task will be in. The non-failing outcome clauses at `[P0-T9]`, `[P0-T10]`,
  `[P0-T11]`, `[P2-T1]`, `[P2-T8]`, and `[P3-T4]` are each explicitly authorised by their own task text and
  each is accompanied by at least one clause that can fail, which the contract permits.
- **Search-assertion form:** 25 `Select-String` occurrences; every command-form occurrence carries
  `-SimpleMatch`. The two bare occurrences are preamble prose at plan lines 112 and 122. Every zero-match
  discriminator carries a named control. All thirteen control-table rows were re-measured in this pass:
  `git worktree` 5 in `enforce-epic-worktree-removal-gate.ps1`; `Get-Location` 1 at
  `persist-session-id.ps1` 161; `$PWD` at `PoshQC.Testing.psm1` 75 and 291; `Resolve-Path` at
  `...Tests.ps1` 6; `New-Item` at `persist-session-id.ps1` 96; `Push-Location` at
  `Publish-DrmCopilotExtension.ps1` 259, 281, 309; `GetTempPath` and `$env:TEMP` at
  `check-powershell-test-purity.ps1` 107 and 108; `Set-Location` 0 across every `.ps1`/`.psm1`/`.psd1` in the
  tree, confirming the Markdown substitute control is necessary, and 2 in the named Markdown file;
  `-MockWith { $true }` 4 at `...FolderResolution.Tests.ps1` 293, 306, 319, 332;
  `return $candidates[0]` 2 at hook 290 and 307; `uses the earliest candidate` 2 at 97 and 105;
  `falls back to orchestrator-state.json` 1 at `...Tests.ps1` 107.
- **Cross-reference integrity:** ID shape confirmed by enumeration — P0 T1-T13, P1 T1-T7, P2 T1-T10,
  P3 T1-T9, P4 T1-T21, P5 T1-T6, P6 T1-T8, 74 tasks, each sequential within its phase, seven phase headings
  in canonical form. Set difference between referenced IDs and defined IDs is empty in both directions. The
  batch table's six rows name existing boundary tasks and their occupancies are within the 3/3 caps. The
  control table, the eighteen-name fixed-`It` list, and the AC-MAPPING all point where they mean; each of the
  eighteen names is created by a named task and asserted passing at `[P4-T21]`.
- **AC traceability:** re-derived independently — exactly 38 `- [` lines strictly between `spec.md` line 600
  and line 671, at 608, 609, 610, 614, 615, 616, 620, 621, 622, 626-631, 635-642, 646, 647, 651-655, 659-662,
  666-669, with no intervening heading and no indented checkbox. This matches the in-artifact AC-INVENTORY
  key line for line. AC-MAPPING carries 38 rows with 38 unique IDs, one per inventory ID. Each row was read
  against the criterion text and against the task as written; all 38 map to a task that makes them pass.
  Three evidence or implementation pointers remain imprecise without being wrong, and were adjudicated in
  round 3 as needing no plan change: AC12, AC33, and AC26's `param()` narrowing. AC23 additionally names
  `[P1-T2]` where the entrypoint-guard half of the criterion is verified by `[P1-T4]`; the criterion is still
  covered by the plan.
- **Ordering vs satisfiability:** Phase 0 baselines `[P0-T2]`-`[P0-T7]` precede the `[P0-T12]` production
  write; `[P0-T4]` explicitly forbids the formatter in Phase 0. Delivery tests are asserted green only at
  `[P0-T7]` (pre-change), `[P2-T9]` (after `[P2-T3]`), `[P5-T4]` (after `[P5-T3]`), and `[P6-T4]`. No gate
  runs the Phase 3 rows before Phase 4: `[P1-T7]` and `[P2-T10]` both precede Phase 3, and `[P4-T11]` and
  `[P4-T12]` are scoped to `Context` blocks that exclude the cases `[P4-T8]` invalidates — re-verified, the
  three invalidated cases sit at `...FolderResolution.Tests.ps1` 89, 97, 105 inside
  `Context 'deterministic selection among two feature folders'` at line 82, and `[P4-T11]` names only the
  blocks at 114-201, 203-282, 284-372, 374-418; the pre-rename checkpoint case at `...Tests.ps1` 107 is
  outside `[P4-T12]`'s named ranges of 118-164 and 197-210. Batch boundaries each sit immediately before
  their batch's first production write and write only `.md` evidence. No `.claude/state` removal is followed
  by a production write that recreates the file before its pytest runs. The three PowerShell suites named on
  the must-not-regress list were checked for enumeration-style assertions that a new hook file would break:
  `enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks` and `.claude/lib`, ships an empty
  allowlist, and excludes the bundled mirror by construction; `PreToolUseSchema.Contract.Tests.ps1` carries
  fifteen hardcoded per-hook assertions and no count or directory enumeration;
  `ClaudeLibModuleConvention.Tests.ps1` scans `.claude/lib` only. `[P1-T7]`'s green gate is therefore
  achievable before the bundled mirrors exist.
- **Hard constraints:** every evidence path resolves under `evidence/baseline|other|qa-gates|
  regression-testing/`; the only `artifacts/` occurrences are the preamble prohibition list at plan lines
  27-28 and `artifacts/pester/` as a declared tool-output input at 36, 305, 307, 361, 371, 451, 463, 467.
  `[P0-T1]` writes `phase0-instructions-read.md` with all three required fields and seven paths. Each
  baseline and final-QC command step has its own artifact carrying `Timestamp:`, `Command:`, `EXIT_CODE:`,
  and `Output Summary:`. `[P6-T3]` records numeric post-change per-file line coverage and `[P6-T5]` is the
  delta task, reporting baseline, post-change, and new-and-changed-line coverage. No branch-coverage figure
  is demanded anywhere; `[P6-T3]` and `[P6-T5]` forbid one explicitly. `[P6-T6]` forbids `SKIPPED`. The
  500-line cap is asserted at `[P1-T6]` (2 files) and `[P4-T20]` (9 files); `core.json`, the one remaining
  changed file, is 176 lines and is a manifest rather than production or test code. No Python enters the
  enforcement path. The no-temp-file pattern is stated in the preamble and enforced by `[P3-T1]`,
  `[P4-T18]`, `[P4-T19]`. No F1 identifier literal is quoted or searched anywhere.
- **Citations re-derived in this pass:** `enforce-prd-feature-before-planner.ps1` 78, 107, 120, 153, 155,
  162, 169, 182, 185, 187, 219, 251, 252, 253, 272, 277, 308, 310, 329, 335, 367, 368, 369, 370, 398, 410,
  426, 440, 448, and 448 lines total; `...Tests.ps1` 5, 8, 107, 109, 116, 118, 133, 136, 156, 164, 197, 205,
  208, 210, 212, 267, 271, 274, and 431 lines; `...FolderResolution.Tests.ps1` 20, 23, 25, 80, 82, 89, 97,
  105, 111, 114, 124, 156, 187, 201, 203, 282, 284, 341, 342, 360, 372, 374, 389, 418, and 419 lines;
  `enforce-powershell-batch-budget.ps1` 139-173, 210, 269, 273, 284, 289, 293, 296, 297, 315, 348, 352,
  362-363, 366, 424, 426; `enforce-python-batch-budget.ps1` 345, 349, 356, 363; `persist-session-id.ps1` 96,
  161; `.claude/settings.json` 84, 128, 136, 144; `.gitignore` 68;
  `test_push_down_claude_resource_contracts.py` 21, 25, 51-60, 118, 130-134, 136-139; `HookPayload.psm1` 481;
  `PoshQC.psm1` 3, 143; `PoshQC.Testing.psm1` 75, 156, 291, 305-318; `pester.runsettings.psd1` 15, 18, 22,
  237, 293 lines, both copies; bundled hook 448 lines; preimplementation gate 140, 346, 360, 412;
  `...gate-helpers.ps1` 1-18; `...gate-absolute-paths.Tests.ps1` 25-34;
  `enforce-epic-worktree-removal-gate.ps1`; `Publish-DrmCopilotExtension.ps1` 259, 281, 309;
  `check-powershell-test-purity.ps1` 107, 108; `spec.md` 600, 610, 622, 628, 639, 651, 671, and the 38
  criterion lines. All correct as written. No incorrect citation was found in this pass.

## Caller-side item — `Last Updated`

The plan's `Last Updated` value is `2026-09-13T23-45`, carrying an explicit note that no shell tool was
available in the planning session and that the value is a monotonic successor rather than a measured
reading. The date component is today's date and the format matches `yyyy-MM-ddTHH-mm`. The measured clock in
this reviewing session reads `2026-09-13T23-05`, so the stamp is 40 minutes ahead of the machine clock
rather than merely unmeasured.

Verdict: acceptable as written and not blocking. No gate, acceptance condition, or artifact name in this
plan reads the field, and the plan discloses the value's provenance. A caller-side correction to a measured
reading is preferable when the caller has a clock, and can be applied at the same time as the B7 revision.

## Execution-readiness observation (not a plan defect)

`.claude/lib/` on this branch holds no target-worktree-resolution module, so F1 has not merged. `[P0-T8]`'s
halt gate handles this fail-closed. This is expected for a wave-1 feature.
