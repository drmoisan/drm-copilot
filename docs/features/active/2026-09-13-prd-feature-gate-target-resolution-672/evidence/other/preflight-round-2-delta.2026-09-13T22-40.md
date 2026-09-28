# Preflight Round 2 — Revision Delta (issue #672)

Timestamp: 2026-09-13T22-40
Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
Plan under review: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md`

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED — every defect below carries exact replacement text and a verified citation; none requires a new design ruling that would introduce citations no pass has observed. B1 is the only defect requiring a mechanism the planner has not yet modelled, and its mechanism is fully stated here with the source lines.

---

## Priority 1 — adjudication of the three disputed citations

**All three: the planner is correct; round 1 was wrong. The plan already cites what the files say. Do NOT change these.**

1. **Checkpoint fallback.** `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 366 `$prompt = Get-ClaudeHookToolInputString ...`, **367** `$folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt`, **368** `if (-not $folder) {`, **369** `$folder = Get-PrdFeatureCheckpointFolder`, **370** `}`, 371 blank. The block is **368-370**. Round 1's "367-369" would have deleted the prompt-resolution assignment. `[P4-T6]`'s revised text is correct.
2. **Pattern literal.** Line **251** is the comment `# Allow forward or backslash separators inside the matched path token.`, **252** is the `$pattern = 'docs[\\/]+features[\\/]+active[\\/]+...'` assignment, **253** is `$matchList = [regex]::Matches($Prompt, $pattern)`. Preamble ruling 1's "252 / 253" is correct.
3. **`spec.md` retention clause.** Line **352** = "Candidate selection: a single distinct candidate is used directly; multiple candidates are"; **353** = "disambiguated against the derived target; an unresolved tie denies with the ambiguity code rather". Retention is at 352; removal at 353. `[P4-T8]`'s revised citation is correct.

---

## Priority 2 and 3 — verified, no further action

- **D7 / ruling 8.** The planner's claim is correct. Counted directly: **ten** `Should -Be` exact equalities on `Find-PrdFeatureFolderFromPrompt`'s return value — `...Tests.ps1` lines 205 and 208 (inside `Context 'Find-PrdFeatureFolderFromPrompt'` 197-210), and `...FolderResolution.Tests.ps1` lines 33, 40, 47, 53, 77, 94, 102, 110. Lines 94/102/110 are re-specified by `[P4-T14]`/`[P4-T15]`; the other seven are covered by `[P4-T7]` and the new `[P4-T12]`. Reason-string assertions confirmed all substring forms and therefore non-binding: `...Tests.ps1` 132-133, 152-153, 391. The ambiguity deny is reachable only on state C; `[P4-T5]` restates the prohibition on the unbound path, so the three-way distinction holds. One residual gap: M1 below.
- **D5 / batch budget.** Both corrections verified. `$Root = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)` at lines **210, 269, 315**; state dir joined at **352**; file composed at **366**; rehydrate **369-376**; deny **297**; reset instruction **296**; `prodCap = 3` at **426**; `.psd1` production at **273**; test classification at **284**; repeat-path no-slot at **289**; cap-full deny at **293**; session id from three sources at **139-173**. Registration: `.claude/settings.json` matcher `"Write|Edit"` at line 128, this hook's command at line **144**. Prior art `2026-08-07-parallel-enforcement-hooks-440/evidence/other/powershell-batch-reset.2026-08-08T21-46.md` exists and states the claimed enumeration command, `EXIT_CODE: 1`, and the `$?`-based attribution. Halt branch survives in `[P2-T1]`, inherited by `[P2-T4]`, `[P4-T1]`, `[P5-T1]`. Six-path sequence re-derived: without the boundaries the production list reaches 3 at `[P2-T3]` and every later production write is denied — the boundaries are load-bearing. Test list peaks at exactly 3 in Phase 4, within cap.
- **D12 / coverage denominator.** All five citations verified: `PoshQC.psm1:3`, `PoshQC.psm1:143`, `PoshQC.Testing.psm1:156`, `PoshQC.Testing.psm1:305-318`, `spec.md` 732-733. `spec.md` line 667 confirmed as the per-file 85 percent requirement; `[P2-T10]`, `[P6-T3]`, `[P6-T5]` retain it with no placeholder. The fallback command is fully specified and runnable verbatim. Micro-gap, non-blocking: the plan does not name the execution route for the fallback command (PowerShell tool vs Bash), which `[P2-T1]` does state for its own command.
- **N1** — real and adequately closed by `[P4-T12]`, which additionally covers the path-capture cases at 118-134, 136-154, 156-164 and the line-133 discriminator.
- **N2** — real and closed. The moved range 219-308 contains exactly one `param(`, at hook line 241, indented. The assertion fails on zero and on two.
- **N3** — real and closed. `[P2-T2]`, `[P2-T3]`, `[P5-T2]`, `[P5-T3]` require zero `Compare-Object` difference objects; `[P6-T1]` requires the two porcelain captures to be identical.
- **N4** — real and correctly recorded. `Set-Location` appears in no `.ps1`/`.psm1`/`.psd1` in this tree. The substitute control `docs/features/completed/2026-06-16-pre-claude-session-script-189/spec.md` contains it twice.

---

## Blocking defects

### B1 — `[P2-T9]`, `[P5-T4]`, `[P6-T4]` and `[P2-T2]`'s pytest clause become unsatisfiable once the batch-budget hook creates `.claude/state/`

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` lines 51-60 enumerate `.claude` with `rglob("*")`; lines 130-134 exclude only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/` is gitignored (`.gitignore` line 68) but the test does not consult gitignore, so any file under `.claude/state/` triggers `Repo file missing from bundle:`. `enforce-powershell-batch-budget.ps1` creates `<root>/.claude/state` at lines 362-363 and writes `powershell-batch-budget.<id>.json` at line 366 on the first production write, which is `[P0-T12]`. Verified today: `.claude/state` is absent and the three delivery tests pass (`17 passed in 0.27s`). From `[P0-T12]` onward they will not.

**Delta — append to `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` (identical text in each):**

> Immediately before the pytest invocation, remove any runtime state files under `.claude/state` using the same enumeration and removal pipeline as `[P2-T1]`, and record the removal in this task's artifact. This is required, not optional: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and reports `Repo file missing from bundle:` for the batch-budget state file once the hook has written it. This removal is safe at this point because no production PowerShell write follows it inside the same batch.

**Delta — append to the preamble's "Intermediate parity window" section:**

> A second, unrelated mechanism can also fail the bundled-payload parity test: the batch-budget hook writes its state file under `<root>/.claude/state/` (hook lines 362-366), and `test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring `.gitignore`. Every task that asserts that test green removes the state files first.

### B2 — `[P2-T2]`'s pytest node assertion cannot pass at its position

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` is a single test function asserting over every repo `.claude` file; it exposes no per-path outcome. At `[P2-T2]` the repo file `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` (created by `[P0-T12]`) still has no bundled counterpart — `[P2-T3]` creates it — so the test fails.

**Delta — `[P2-T2]` acceptance:** delete the clause ``and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes for this path`` and replace with: `That test is not asserted here: it asserts over every repo .claude file in one function and exposes no per-path outcome, and the bundled sibling it also requires is created by [P2-T3]. It is asserted at [P2-T9], after [P2-T3] closes the window.`

### B3 — `[P4-T6]` asserts an `It` that does not exist until `[P4-T13]`

`[P4-T6]`'s second acceptance clause requires the `It` named `allows the session-root fallback when the derived target is the session root` to pass. That name is created seven tasks later by `[P4-T13]`, which renames `falls back to orchestrator-state.json when prompt has no folder reference`. At `[P4-T6]` the name does not exist, and the pre-rename case is failing because `[P4-T6]` has just removed the fallback it pins.

**Delta — `[P4-T6]` acceptance:** replace ``and the `It` named `allows the session-root fallback when the derived target is the session root` passes, so the single-worktree topology is not converted from allow to deny`` with:

> The single-worktree topology is not converted from allow to deny; that property is asserted by the `It` named `allows the session-root fallback when the derived target is the session root`, which `[P4-T13]` creates by renaming the existing case, so it is verified at `[P4-T13]` and not here. Until `[P4-T13]` runs, the pre-rename case `falls back to orchestrator-state.json when prompt has no folder reference` is expected to fail; record that observation in this task rather than treating it as a regression.

### B4 — `[P4-T15]`'s zero-match control is not captured by the task it cites

`[P4-T15]` requires the control count for `uses the earliest candidate` to be "taken from the pre-change file recorded by `[P0-T3]` (2 occurrences)". `[P0-T3]` records only the `return $candidates[0]` control. By the time `[P4-T15]` runs, the pre-change text is gone and the control cannot be produced. Verified: the token occurs twice pre-change, at `...FolderResolution.Tests.ps1` lines 97 and 105.

**Delta — `[P0-T3]`:** after the `return $candidates[0]` control sentence, add:

> In the same artifact record a second pre-change control count, for the token `uses the earliest candidate`, measured as `Select-String -SimpleMatch -Pattern 'uses the earliest candidate' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'`, which `[P4-T15]` compares against. Its acceptance accordingly requires 6 measured integers and **two** control counts.

### B5 — `[P3-T3]`'s required outcome contradicts `[P3-T9]`'s blanket statement

`[P3-T3]` specifies "the same payload and the same resolved target as the `[P3-T2]` row"; `[P3-T2]` supplies its target "through the injection parameter", which `[P4-T3]` adds. `[P3-T9]` states that "the injection parameter that the Phase 3 rows bind is added by `[P4-T3]`, so a row binding it against the Phase 3 hook fails with a parameter-binding error". If `[P3-T3]` binds it, its acceptance ("passes against the current hook") is unsatisfiable; if it does not, `[P3-T9]`'s statement is false for that row. The plan does not say which.

**Delta — `[P3-T3]`:** after "rather than to a different worktree", insert: `This row deliberately omits the injection parameter: it models preamble ruling 8's state B, in which the composition emits the bare repo-relative spelling and the current hook already allows. It is therefore excluded from [P3-T9]'s parameter-binding-error accounting as well as from its fail count.`

**Delta — `[P3-T9]`:** change "the Phase 3 rows bind" to `the Phase 3 rows that bind it`, and add `[P3-T3]` to the sentence naming the rows excluded from that accounting.

---

## Moderate defects

### M1 — ruling 8's state-B/state-C discriminator has an unhandled third outcome

`[P0-T8]` records `F1-DISTINGUISHES: YES` or `NO`; on `NO`, the plan falls back to the envelope field recorded by `[P0-T9]`, which is itself permitted to record `ENVELOPE-ROOT-FIELD: NONE`. With both negative there is no discriminator at all: state B's definition becomes universally true, state C is unreachable in production, and `[P4-T5]`'s ambiguity branch is reachable only through the test-only injection parameter. The plan states no ruling for that combination. This is a live possibility: `.claude/lib/` currently holds `bash`, `blast-radius`, `cleanup-manifest`, `codex-routing`, `discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, `orchestrator-state`, `project-file-merge`, `requirements` and no target-resolution module, so neither field can be predicted now.

**Delta — `[P0-T8]`, append to the halt gate:**

> Second halt arm: if the discriminator field records `F1-DISTINGUISHES: NO` and `[P0-T9]` records `ENVELOPE-ROOT-FIELD: NONE`, no production discriminator between preamble ruling 8's state B and state C exists, the ambiguity deny would be reachable only through the test-only injection parameter, and `spec.md` line 610 could not be satisfied in production. Halt and report blocked rather than proceeding; do not substitute the unbound-parameter path, which preamble ruling 8 prohibits.

### M2 — `[P2-T1]`'s stated expectation is inverted and contradicts `[P2-T4]`

`[P2-T1]` states "`.claude/state` does not exist in this worktree at planning time, so the zero-file branch is the expected one." `.claude/state` is indeed absent today, but `[P0-T12]` and Phase 1 write two production PowerShell files through `Write`/`Edit`, and the budget hook creates the directory and the state file on the first of them. At `[P2-T1]` the enumeration will name the repository hook and its sibling and exit 0, not 1. `[P2-T4]` states the opposite expectation for the identical mechanism.

**Delta — `[P2-T1]`:** replace that sentence with:

> The pre-reset `prodFiles` list recorded here is expected to name `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, written by `[P0-T12]` and Phase 1, and the expected exit code is therefore 0. `.claude/state` did not exist at planning time, so the zero-file branch remains a tolerated alternative; record whichever case applied.

### M3 — citation drift in `[P1-T1]`

The two comment-based-help occurrences of `user-story.md` inside `Get-PrdFeatureRequiredFile` are at lines **162 and 169**, not 163 and 170. The switch-arm occurrence at 182 is correct, and the asserted count of three is correct.

**Delta — `[P1-T1]`:** change `(pre-move lines 163 and 170)` to `(pre-move lines 162 and 169)`.

---

## Low defects

### L1 — `[P3-T8]`'s acceptance wording does not match its `[expect-fail]` tag

It requires only that "its outcome against the current hook is recorded", while `[P3-T9]` counts it among the eight rows required to fail.

**Delta:** change to `the named It exists and fails against the current hook, and its failure message is recorded in the [P3-T9] artifact`, matching `[P3-T2]` and `[P3-T5]`.

### L2 — `[P4-T13]`'s first acceptance clause names no observable

"the suite contains no `It` asserting an allow on an unconditional session-root checkpoint fallback" is a judgment over prose.

**Delta:** replace with a `Select-String -SimpleMatch -Pattern 'falls back to orchestrator-state.json'` search over that suite returning zero matches, with the pre-change control count recorded by `[P0-T3]` (1 occurrence, at line 107).

### L3 — the 500-line AC is measured on five of the delivered files

`spec.md` line 653 requires every production and test file in the change set to be at or under 500 lines. `[P4-T20]` measures the two repository production files and the three suites; the two bundled mirrors and the two `pester.runsettings.psd1` copies are unmeasured post-change. Measured today: both `.psd1` files are 293 lines and the bundled hook is 448, so no breach is possible, but the AC coverage is nominally incomplete.

**Delta (optional but recommended):** add the four paths to `[P4-T20]`.

### L4 — batch A1 has no boundary task

`[P0-T10]` records whatever state files exist at Phase 0 but no task acts on a non-empty enumeration, and A1 is opened by nothing. `.claude/state` is absent today so the present risk is nil; if the executor session has prior PowerShell writes, `[P0-T12]` can be denied with no halt path.

**Delta (optional but recommended):** give `[P0-T10]` the same halt branch the other boundaries carry when its enumeration is non-empty.

---

## Sweep results recorded by the reviewer

- **Acceptance conditions that cannot fail:** round 1's three (D1, D13, D15) are closed. A sweep over all 73 tasks, including the eleven inserted in round 1's revision, found one further instance of the class (L2) plus the four ordering/control failures above. `[P0-T11]` and `[P3-T4]` have non-failing outcome clauses but their task text explicitly authorises them, which the contract permits.
- **Search-assertion form:** every `Select-String` acceptance condition uses `-SimpleMatch`; the only two bare occurrences are prose in the preamble at lines 102 and 112. Every zero-match discriminator carries a named control, all verified non-zero, except `[P4-T15]`'s (B4). `[P1-T3]`'s control-free assertion is subsumed by `[P1-T1]`'s count-of-three.
- **Renumbering integrity:** IDs sequential and phase-matched — P0 T1-T13, P1 T1-T7, P2 T1-T10, P3 T1-T9, P4 T1-T21, P5 T1-T6, P6 T1-T8. Every referenced ID exists. Two cross-references are stale in substance rather than number: `[P4-T6]`→`[P4-T13]` (B3) and `[P4-T15]`→`[P0-T3]` (B4).
- **AC traceability:** count re-derived independently — exactly **38** criteria between line 600 and line 671. All 38 map to a task; every named test node, `Context`, `It`, and evidence path checked is real and reachable. Round 1's three gaps are closed: line 627 → `[P3-T3]`; line 639's second `Context` → `[P4-T7]`; line 637's two epic-merge-gate suites → `[P0-T6]` and `[P5-T5]`.
- **Ordering vs satisfiability:** Phase 0 baselines `[P0-T2]`-`[P0-T7]` still precede the `[P0-T12]` production write; no formatter runs in Phase 0. No gate runs the Phase 3 rows before Phase 4 — `[P4-T11]` and `[P4-T12]` are scoped to `Context` blocks excluding the cases `[P4-T8]` invalidates. The four batch-boundary tasks each sit immediately before their batch's first production write and write only `.md` evidence. The delivery-test assertions are the defective ones (B1, B2).
- **Unchanged hard constraints:** all evidence paths resolve under `evidence/baseline|other|qa-gates|regression-testing/`; the only `artifacts/` occurrences are the preamble's prohibition list (lines 27-28) and `artifacts/pester/` as a declared tool-output input. `phase0-instructions-read.md` present; every baseline and final-QC command step has its own artifact with all four required fields; `[P6-T3]` records numeric post-change per-file coverage and `[P6-T5]` is the delta task; no branch-coverage figure is demanded; `[P6-T6]` forbids `SKIPPED`; the 500-line cap is asserted at `[P1-T6]` and `[P4-T20]` (see L3); no Python in the enforcement path; the no-temp-file pattern is stated in the preamble and enforced by `[P3-T1]`, `[P4-T18]`, `[P4-T19]`; no F1 identifier literal is searched or quoted anywhere.

## Execution-readiness observation (not a plan defect)

`.claude/lib/` on this branch contains no target-worktree-resolution module, so F1 has not yet merged. `[P0-T8]`'s halt gate handles this correctly and fail-closed; execution must not begin until F1 lands on `epic/worktree-scoped-state-resolution-integration`.
