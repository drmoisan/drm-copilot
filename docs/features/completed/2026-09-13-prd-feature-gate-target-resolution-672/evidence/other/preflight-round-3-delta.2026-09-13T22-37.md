# Preflight Round 3 — Revision Delta (issue #672)

Timestamp: 2026-09-13T22-37
Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
Plan under review: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md`

Clock note: the reviewing machine's local clock read `2026-09-13T22-37` when this artifact was written,
which is earlier than the round-2 delta's stamp (`22-40`) and the plan's `Last Updated` (`23-05`). The
filename's `round-3` element, not the timestamp, carries the round ordering.

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED — the single blocking defect below carries exact replacement text
and a mechanism verified against the tree and against observed on-disk state; it requires no new design
ruling. The four low findings are wording corrections inside already-agreed text.

---

## Priority 1 — status of the twelve round-2 defects

| # | status | verification |
|---|---|---|
| B1 | **partially closed** | The removal paragraph is present in `[P2-T9]` (plan line 358), `[P5-T4]` (438), `[P6-T4]` (454) and the preamble paragraph is present (100-103). Mechanism re-verified: `enforce-powershell-batch-budget.ps1` line 352 joins the state dir, 362-363 create it, 366 composes the file; `test_push_down_claude_resource_contracts.py` lines 51-60 `rglob("*")`, 130-134 exclude only `settings.local.json` and `agent-memory`, 136-139 raise `Repo file missing from bundle:`; `.gitignore` line 68. The removal is nonetheless bound to a filter that excludes a second, more common file class — see **B6**. |
| B2 | closed | `[P2-T2]`'s pytest clause is replaced by the deferral to `[P2-T9]`; `[P2-T9]` names the test. Wording nit at **L5**. |
| B3 | closed | `[P4-T6]`'s second clause is replaced; `[P4-T13]` creates `allows the session-root fallback when the derived target is the session root` by renaming the case at `...Tests.ps1` line 107 (verified present). |
| B4 | closed, superseded by N5 | `[P0-T3]` records three controls; see N5 adjudication below. |
| B5 | closed | `[P3-T3]` carries the state-B exclusion sentence; `[P3-T9]` reads "the Phase 3 rows that bind it" and excludes `[P3-T3]` from the parameter-binding-error accounting. Nits at **L7**, **L8**. |
| M1 | closed in substance | The second halt arm is present on `[P0-T8]` with its evaluation point stated. `[P0-T9]` does run after `[P0-T8]`, so the arm is not inert. Nit at **L6**. |
| M2 | closed | `[P2-T1]`'s expectation now names the two files written by `[P0-T12]` and Phase 1 and expects exit 0, with the zero-file branch tolerated. |
| M3 | confirmed | Re-derived independently: `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 162 = "full-feature requires spec.md and user-story.md; full-bug requires", line 169 = "not name user-story.md, because that document is required to be ABSENT". Switch arm at 182, `default` arm at 185, function span 155-187. The asserted count of three is correct. |
| L1 | closed | `[P3-T8]` now requires the named `It` to fail; reason citation `...ps1` 426-428 verified. |
| L2 | closed | `[P4-T13]`'s first clause is the `-SimpleMatch` zero-match search with the `[P0-T3]` control. |
| L3 | closed | `[P4-T20]` measures nine files. The four added are the two bundled mirrors and the two `pester.runsettings.psd1` copies. Measured today: bundled hook 448 lines, both `.psd1` 293 lines. |
| L4 | closed | `[P0-T10]` carries the conditional reset, the re-run verification, and the halt branch; the batch table's A1 row names it. |

## Priority 2 — adjudication of N5 and N6

**N5 — upheld.** The contradiction was real: B4's supplied text fixed `[P0-T3]`'s acceptance at "**two**
control counts" while L2 required a third pre-change control from the same task. The resolution is correct.
All three controls are genuinely pre-change-only and genuinely consumed, verified in the tree:
`return $candidates[0]` = 2 occurrences at hook lines 290 and 307, consumed by `[P4-T8]`, which removes one;
`uses the earliest candidate` = 2 occurrences at `...FolderResolution.Tests.ps1` lines 97 and 105, consumed
by `[P4-T15]`, which renames both; `falls back to orchestrator-state.json` = 1 occurrence at
`...Tests.ps1` line 107, consumed by `[P4-T13]`, which renames it. The preamble control table's three rows
match these counts and lines. No sibling inconsistency introduced.

**N6 — upheld.** The contradiction was real: `[P3-T2]` states its target is "supplied through the injection
parameter", so `[P3-T3]`'s original "the same resolved target as the `[P3-T2]` row" implied a binding that
B5's inserted sentence denies. "the same payload and the same intended target folder" removes the implication
without weakening the shared-fixture statement. Sibling region checked: `[P3-T9]`, preamble ruling 8's state
B, and the fixed-`It` list item 16 are all consistent with the new phrasing. One residual wording risk is
recorded at **L7**.

**B5's second question — the decision not to add `[P3-T4]` to the binding-error exclusion is correct.**
`[P3-T3]` had to be excluded because its required outcome is a pass, so it can contribute no failure mode.
`[P3-T4]` accepts either outcome and is already excluded from the fail count, so both readings of it remain
satisfiable. The only residue is `[P3-T9]`'s blanket "for each row", recorded at **L8**.

---

## Blocking defect

### B6 — the `.claude/state` removal inherits a filter that excludes the file class most likely to be present, and `[P0-T7]` carries no removal at all

`[P2-T1]`'s pipeline is filtered: `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json'`.
`[P2-T9]`, `[P5-T4]`, and `[P6-T4]` each say "remove any runtime state files under `.claude/state` using the
same enumeration and removal pipeline as `[P2-T1]`", so the stated scope ("any runtime state files") and the
pipeline it binds to disagree: the pipeline removes only the batch-budget file.

A second writer puts a different file in the same directory. `.claude/hooks/persist-session-id.ps1` is
registered as a `SessionStart` hook at `.claude/settings.json` line 84. Its line 161 composes
`(Get-Location).Path` + `.claude/state/current-session-id`, and `Invoke-PersistSessionIdHook` writes that file
on both the `env-file` and the `state-file` arm, creating the directory first. A third writer,
`enforce-python-batch-budget.ps1` (registered at `.claude/settings.json` line 136), leaves
`python-batch-budget.<id>.json`; it early-returns for non-`.py` writes at its line 345, so this plan will not
create one, but an earlier session in the same worktree can have.

Observed on disk today:

- `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-13T08-30\.claude\state\` contains exactly `current-session-id`.
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\state\` contains `current-session-id`.
- 22 of the `.claude/worktrees/agent-*` worktrees carry a `.claude/state/` directory; one sampled directory
  contains `python-batch-budget.default.json`.

`test_push_down_claude_resource_contracts.py` consults no gitignore — the only special case in the file is the
`agent-memory` exclusion at lines 130-134 — so `.claude/state/current-session-id` yields
`Repo file missing from bundle: .claude/state/current-session-id` and the filtered removal does not clear it.

Impact: four acceptance conditions become unsatisfiable whenever the state directory holds a non-budget file.
`[P2-T9]`, `[P5-T4]`, and `[P6-T4]` each require `EXIT_CODE: 0` with a failed count of 0. `[P0-T7]` requires
`EXIT_CODE: 0` at baseline and carries no removal instruction at all, so it is the earliest failure point —
before this feature has changed anything.

**Delta 1 — `[P2-T1]`, append after the sentence ending "...a worktree-derived identifier.":**

> The pipeline above is filtered and is the batch-budget reset: it removes only
> `powershell-batch-budget.*.json`, which is what a batch boundary needs. A second, **unfiltered** pipeline is
> defined here for the delivery-test tasks, which must clear every file under `.claude/state`:
> `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`,
> verified with
> `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`.
> Both pipelines run from the worktree root through the PowerShell tool, or through the Bash tool as a
> single-quoted `pwsh -NoProfile -Command '<the same pipeline>'`, and both carry the same exit-code
> attribution and the same halt branch. `[P0-T10]`, `[P2-T4]`, `[P4-T1]`, and `[P5-T1]` use the filtered
> pipeline. `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` use the unfiltered one.

**Delta 2 — `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` (identical in each).** Replace "using the same enumeration and
removal pipeline as `[P2-T1]`" with "using the **unfiltered** `.claude/state` pipeline defined in `[P2-T1]`,
recording the pre-removal file names and the post-removal verification count of `0`". Then append to the same
paragraph:

> The filtered batch-budget pipeline is not sufficient here. `.claude/hooks/persist-session-id.ps1` is
> registered as a `SessionStart` hook at `.claude/settings.json` line 84 and writes
> `<cwd>/.claude/state/current-session-id` at its line 161, and `enforce-python-batch-budget.ps1` can have
> left `python-batch-budget.<id>.json` from an earlier session in the same worktree. Neither file name matches
> `powershell-batch-budget.*.json`, and either one on its own produces `Repo file missing from bundle:`.

**Delta 3 — `[P0-T7]`, insert immediately before "Write `docs/features/active/...`":**

> Immediately before the pytest invocation, remove every file under `.claude/state` using the unfiltered
> pipeline defined in `[P2-T1]`, and record the pre-removal file names and the post-removal verification count
> of `0` in this task's artifact. This is required, not optional: the `SessionStart` hook
> `.claude/hooks/persist-session-id.ps1` (`.claude/settings.json` line 84) writes
> `<cwd>/.claude/state/current-session-id` at its line 161, and
> `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")`
> at lines 51-60 while excluding only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines
> 130-134, so a session-id state file already present at baseline reports `Repo file missing from bundle:` and
> makes this task's `EXIT_CODE: 0` acceptance unsatisfiable before this feature has modified anything. No
> production PowerShell write precedes this task, so the removal cannot mask a budget effect.

**Delta 4 — preamble, "Intermediate parity window".** Replace the paragraph beginning "A second, unrelated
mechanism can also fail the bundled-payload parity test:" with:

> A second, unrelated mechanism can also fail the bundled-payload parity test: the repository writes runtime
> state under `.claude/state/`, which `.gitignore` line 68 ignores and which has no bundled counterpart. Two
> hooks write there — `enforce-powershell-batch-budget.ps1` composes
> `powershell-batch-budget.<session-id>.json` at lines 362-366, and the `SessionStart` hook
> `persist-session-id.ps1` writes `current-session-id` at line 161 — and
> `test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring `.gitignore`. Every task
> that asserts that test green removes **every** file under `.claude/state` first, not only the batch-budget
> file. The batch-boundary tasks keep the narrower batch-budget filter, because a boundary reset is about
> budget slots rather than about payload parity.

---

## Low defects

### L5 — `[P2-T2]`'s "That test" has no antecedent

B2's replacement deleted the clause naming the test, so the surviving sentence opens "That test is not
asserted here" with nothing to refer back to.

**Delta — `[P2-T2]`:** change `That test is not asserted here:` to
``` `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` is not asserted here: ```

### L6 — `[P0-T9]` carries no pointer back to `[P0-T8]`'s second halt arm

The arm is stated on `[P0-T8]` but can only be evaluated after `[P0-T9]` records its determination, by which
time `[P0-T8]` is checked off. Nothing in `[P0-T9]` directs the executor back to it.

**Delta — `[P0-T9]`, append:**

> On recording the determination, immediately evaluate `[P0-T8]`'s second halt arm against it: if this
> artifact records `ENVELOPE-ROOT-FIELD: NONE` and the `[P0-T8]` artifact records `F1-DISTINGUISHES: NO`,
> halt and report blocked before starting `[P0-T10]`.

### L7 — `[P3-T3]`'s mock-keying phrase can be read as requiring a prefixed path

`[P3-T3]` says the existence mock answers "true only for the path composed against that root". Its row is
preamble ruling 8's state B, in which the composition emits the bare repo-relative spelling; an executor that
keys the mock on an absolute item-worktree path would see the row deny, contradicting its required pass.

**Delta — `[P3-T3]`:** replace "the existence mock answering true only for the path composed against that
root" with "the existence mock answering true only for the bare repo-relative path the hook composes in state
B, the modelled session root and the target root coinciding so that no prefix is applied".

### L8 — `[P3-T9]`'s failure-mode instruction is vacuous on a passing row

"Additionally, for each row: ... Record which of the two failure modes was observed" cannot be satisfied for
`[P3-T4]` when that row passes, which its own text permits.

**Delta — `[P3-T9]`:** change "Additionally, for each row:" to "Additionally, for each row that failed:".

---

## Sweep results recorded by the reviewer

- **Acceptance conditions that cannot fail:** none found beyond those already closed. Every condition edited
  in the round-2 pass was re-read against the state its task will run in. `[P2-T1]`'s revised sentence is an
  expectation statement, not an acceptance condition; the acceptance remains the verification count of `0`,
  which can fail. `[P0-T11]` and `[P3-T4]` retain non-failing outcome clauses that their task text explicitly
  authorises, which the contract permits.
- **Search-assertion form:** every `Select-String` acceptance condition carries `-SimpleMatch`; the only two
  bare occurrences are preamble prose at plan lines 107 and 117. Every zero-match discriminator carries a
  named control. The three controls added this round were measured directly: `return $candidates[0]` = 2,
  `uses the earliest candidate` = 2, `falls back to orchestrator-state.json` = 1. All ten control-table rows
  were re-verified in the tree, including the `Set-Location` substitute (no `.ps1`/`.psm1`/`.psd1` in this
  tree contains it; the named Markdown control contains it twice).
- **Cross-reference integrity:** ID shape confirmed exactly as reported — P0 T1-T13, P1 T1-T7, P2 T1-T10,
  P3 T1-T9, P4 T1-T21, P5 T1-T6, P6 T1-T8, 74 tasks. Every referenced ID exists. One stale-in-substance
  reference found: the `[P2-T9]`/`[P5-T4]`/`[P6-T4]` pointer to `[P2-T1]`'s pipeline (B6). One dangling
  antecedent (L5). The batch table, control table, fixed-`It` list (eighteen names, each created by a named
  task and each asserted passing at `[P4-T21]`), and AC-MAPPING otherwise point where they mean.
- **AC traceability:** count re-derived independently — exactly 38 `- [` lines between `spec.md` line 600 and
  line 671, at lines 608, 609, 610, 614, 615, 616, 620, 621, 622, 626-631, 635-642, 646, 647, 651-655,
  659-662, 666-669. This matches the in-artifact AC-INVENTORY key line for line. Each mapping row was checked
  against the criterion text and against the task as written; all 38 map to a task that makes them pass. Two
  evidence pointers are imprecise but not wrong in substance: AC12 names
  `evidence/other/absolute-path-reproduction.md` (the `[P0-T11]` investigation) where the It is asserted
  passing at `[P4-T21]`/`batch-d-gate.md`, and AC33 names `evidence/qa-gates/coverage-denominator-check.md`
  where `test_poshqc_bundled_parity.py` is recorded by the delivery-test artifacts. Neither needs a plan
  change. Separately, `spec.md` line 651 reads "contains no `param()` block"; `[P0-T12]` narrows this to
  file scope and records why, which is correct, but the AC26 mapping row does not carry the narrowing.
- **Ordering vs satisfiability:** Phase 0 baselines `[P0-T2]`-`[P0-T7]` precede the `[P0-T12]` production
  write; no formatter runs in Phase 0. No gate runs the Phase 3 rows before Phase 4: `[P4-T11]` and `[P4-T12]`
  are scoped to `Context` blocks that exclude the cases `[P4-T8]` invalidates (verified — the three
  re-specified cases sit in `Context 'deterministic selection among two feature folders'` at
  `...FolderResolution.Tests.ps1` lines 89, 97, 105, and the pre-rename checkpoint case at `...Tests.ps1`
  line 107 is outside `[P4-T12]`'s named ranges). Batch boundaries each sit immediately before their batch's
  first production write and write only `.md` evidence. Batch occupancy re-derived: A1/A2 2 production and
  3 test paths, B 2 production, C 2 production, D 2 production and 3 test paths, E 2 production — all within
  the 3/3 caps. The new `.claude/state` removals sit after their batch's last production write, and neither
  budget hook creates state for a `.md` write (PowerShell hook early-returns at line 348, Python hook at
  line 345), so no write between the removal and the pytest recreates the file.
- **Unchanged hard constraints:** every evidence path resolves under
  `evidence/baseline|other|qa-gates|regression-testing/`; the only `artifacts/` occurrences are the preamble's
  prohibition list and `artifacts/pester/` as a declared tool-output input. `phase0-instructions-read.md` is
  present with its three required fields and seven paths, and the seven policy files all exist. Every baseline
  and final-QC command step has its own artifact with `Timestamp:`, `Command:`, `EXIT_CODE:`, and
  `Output Summary:`. `[P6-T3]` records numeric post-change per-file coverage and `[P6-T5]` is the delta task.
  No branch-coverage figure is demanded anywhere. `[P6-T6]` forbids `SKIPPED`. The 500-line cap is asserted at
  `[P1-T6]` (2 files) and `[P4-T20]` (9 files); the bundled mirrors' final state is covered transitively by
  the `Compare-Object` zero-difference assertions at `[P5-T2]` and `[P5-T3]`. No Python in the enforcement
  path. The no-temp-file pattern is stated in the preamble and enforced by `[P3-T1]`, `[P4-T18]`, `[P4-T19]`.
  No F1 identifier literal is quoted or searched anywhere.
- **Citation spot-checks re-derived this pass:** hook lines 78, 107, 120, 155-187, 162, 169, 182, 185, 219,
  241, 251-253, 272-277, 290, 307, 310, 329, 367-370, 398-410, 426-428, 440, 448 (448 lines total);
  `...Tests.ps1` 1-2, 6, 5-8, 107, 109, 118-164, 133, 197-210, 205, 208, 212-274, 267, 271, 431 lines;
  `...FolderResolution.Tests.ps1` 20-23, 25-80, 82, 89, 97, 105, 114-201, 124, 156, 187, 203-282, 284-372,
  293, 306, 319, 332, 341-342, 360, 374-418, 389-390, 419 lines; batch-budget hook 210, 269, 273, 284, 289,
  293, 296, 297, 315, 347-350, 352, 362-363, 366, 369-376, 426; `.claude/settings.json` 128, 144;
  `.gitignore` 68; `pester.runsettings.psd1` 15, 18, 22, 237, 293 lines (both copies);
  `core.json` 36, 40, 42, 46, 47; `HookPayload.psm1` 481; `PoshQC.psm1` 3, 143; `PoshQC.Testing.psm1` 75, 156,
  291, 305-318; preimplementation gate 140, 344-360, 412; `...gate-helpers.ps1` 1-18;
  `...gate-absolute-paths.Tests.ps1` 25-34; `...gate-classifier.Tests.ps1` 34-42; `persist-session-id.ps1` 96,
  161; `enforce-epic-worktree-removal-gate.ps1` 3; `Publish-DrmCopilotExtension.ps1` 259, 281, 309;
  `check-powershell-test-purity.ps1` 99-117, 107, 108; `.claude/rules/powershell.md` 17, 39-40, 64;
  `spec.md` 70, 352, 353, 600, 610, 622, 627, 637, 639, 651, 653, 659, 667, 671, 732-733. All correct as
  written. No incorrect citation was found in this pass.

## Execution-readiness observation (not a plan defect)

`.claude/lib/` on this branch holds eleven module directories and no target-worktree-resolution module, so F1
has not merged. `[P0-T8]`'s halt gate handles this fail-closed. This is expected for a wave-1 feature.
