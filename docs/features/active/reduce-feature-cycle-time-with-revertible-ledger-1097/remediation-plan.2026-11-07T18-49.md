# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage R, F1, RN1, RN2)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T18-49
- **Status:** Authored by `atomic-planner`; awaiting executor preflight
- **Version:** 0.2
- **Inputs:** `remediation-inputs.2026-11-07T18-49.md` (primary), `code-review.2026-11-07T18-49.md` (detail)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Three changes, in the order of the inputs:

- **F1 (blocking).** Step 1 of `## Revert Steps` in entry `0001` names `0006` as the one entry to revert first, which contradicts README `## Revert Order`. Reword it to defer to that section and name no entry, and regenerate the one `0006` stored patch hunk that adds the step, in one commit whose subject carries `reduction: 0001` and `reduction: 0006`. The `PRL-PARTIAL-REVERT-LINKED` targets (the `0001` index row, the `0001` `## Partial Revert` section, the `0006` `## Summary` sentence naming `0001`) are not edited.
- **RN1.** One README sentence in `## Revert Order` stating the route for reverting an older reduction while keeping later ones. It is stated as a route, not a requirement.
- **RN2.** The created-path half of `Get-ProcessReductionEndStateError` cannot fail. Decision: remove it, with its unreachable error line and the `Created` plumbing that only it reads. Reason: `Invoke-ProcessReductionPatchStep` sets a created path to `$null` immediately before it records the touch, and no later step of `Invoke-ProcessReductionChain` writes that path, so the condition `Created` with a non-null final text is unreachable. Making it fail would need a new rule that a created file still holds its recorded text, which contradicts the chosen design that a create hunk reverts to absent whatever the file holds (pinned by `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT`). A create hunk has an empty `Prior`, so an unrecorded edit to a created file loses no restore text. The git-level chain gate ([P1-T10] of the stage R plan) already compares created files at git level with `git apply -R --check`. The pre-image half stays and can fail, as `PRC-CHAIN-END-STATE-PREIMAGES` shows; AC R3's evidence rests on that half.

Out of scope and left alone: RN3, RN4, N2, N3; `spec.md`; Epic #1019 folders; `plan.2026-11-07T12-43.md`; every skill, agent, mirror, bundle, and the `execution-environment` brief.

Premise correction: the README `## Entry Format` partial-revert paragraph states that step 1 of the earlier entry "states that the new entry is reverted first". After F1 that clause is false for `0001`, which is the same defect class as F1. [P1-T2] rewords that one clause in the same README edit.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`. `SCRATCH` resolves to `<session scratchpad>/issue-1097/`; artifacts record the token, never a host path. Evidence names carry the prefix `stage-r-cycle2-`; a consumer selects the greatest `<name>.*.md`.
- Tool routes, launchers, command-text restrictions, the batch budget, hook context, and CI shape come from the `execution-environment` skill and are not restated. One production PowerShell file is edited, so direct mode applies.
- Testing (owner's standing instruction, overriding any contract text): one `Invoke-PoshQCParallelTest` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison run. No Python file changes, so no pytest run is owed. No unqualified `poetry install` from the worktree.
- Commits: commit and push after each task. No tag, no history rewrite, no forced push. The F1 commit is the only one carrying `reduction:` tokens.
- Failure outside the branch: a failing test whose file and subject are both absent from the diff between the merge base of `origin/main` and `HEAD`. The artifact names the test, file, and subject, `EXIT_CODE:` stays non-zero, the test is not edited, and the executor returns these facts. Any other failure is fixed and the loop restarts from [P2-T1].

## Test Dispositions

Found by searching `tests/` for `Add-ProcessReductionTouch`, `Get-ProcessReductionEndStateError`, `Created`, the message `the end state holds a file that the entry created`, `0001-parallel-only-test-gates`, `Revert Order`, and `reverted first`.

- `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` (`tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`): unchanged. It asserts `IsValid` and a `$null` final text for a created file edited later, both unaffected by removing the unreachable branch.
- `PRC-CHAIN-END-STATE-PREIMAGES` (same file): unchanged. It asserts the pre-image message, which stays.
- `PRC-LEDGER-END-STATE-RECORDED` (`tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`): unchanged. Its filter `*the end state*` matches only the pre-image message after the removal, and its absent-final-text assertion is a property of the revert step.
- `PRC-LEDGER-CHAIN-HOLDS`, `PRL-REAL-LEDGER-AGREES`, `PRL-PARTIAL-REVERT-LINKED`: unchanged; they must pass with the new step 1 and its regenerated `0006` hunk.
- `PRC-README-REVERT-ORDER-STATED` and `PRL-README-EXAMPLE-IS-VALID`: unchanged; the README edit keeps the tokens `newest-first` and `ProcessReductionChain.Ledger.Tests.ps1` and leaves `## Worked Example` and `## Index` as they are.
- No test asserts the partial-revert clause of the README or the text of step 1; no test is added or edited.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Write `FEATURE/evidence/baseline/stage-r-cycle2-baseline-reference.<timestamp>.md`, recording the Phase 0 baseline figures read from the stage R artifacts under `FEATURE/evidence/baseline/` and `FEATURE/evidence/qa-gates/`. No suite is run.
  - Sources: the greatest `stage-r-powershell-test-baseline.*.md` (pass and fail counts, repo-wide line coverage, `scripts/dev-tools/ProcessReductionLedger.psm1` coverage); the greatest `stage-r-powershell-static.*.md` (static state of the ledger files); the greatest `stage-r-powershell-format-lint.*.md` and `stage-r-powershell-test.*.md` under `qa-gates/` (static state and coverage of `scripts/dev-tools/ProcessReductionChain.psm1` and its two test files, the file this cycle edits, which has no earlier baseline run); the greatest `stage-r-patch-chain-gate.*.md` under `evidence/other/` (the git-level chain gate result). The python baseline is cited as not owed because no Python file changes.
  - Output Summary: each figure with its source artifact name; the chain gate result (both checks exit 0, equal and attributed path counts, unattributed 0).
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and every figure is numeric and traced to a named artifact.

### Phase 1 — Fixes

- [x] [P1-T1] Fix F1 in one commit: reword step 1 of `## Revert Steps` in `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` and regenerate the matching hunk in `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`.
  - The new step 1 reads: "1. Apply the blocks: revert every later entry that names any path in `## Files Changed`, newest-first, as README `## Revert Order` states; then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text." It names no entry.
  - In the `0006` patch, edit only the added line of the section for `0001-parallel-only-test-gates.md` (its `+1. Apply the blocks:` line) so that it carries the same text as the entry's new step 1. The hunk header, its removed line, its context, the section's `index` line, and every other section stay unchanged. Edit with the Edit tool on that one line; do not reformat the patch file.
  - Commit subject carries `reduction: 0001` and `reduction: 0006`. The `PRL-PARTIAL-REVERT-LINKED` targets are not touched.
  - Acceptance: a `git apply -R --check` of the `0006` patch on the live tree exits 0; and the search for `000[2-6]` inside the `## Revert Steps` section of the entry (extracted with `Get-ProcessReductionSection`, from a script file under `SCRATCH`) returns no match, where the pre-change text contained `0006`. `git log` of the commit shows both tokens.
- [x] [P1-T2] Edit `docs/engineering/process-reductions/README.md`: add the RN1 sentence to `## Revert Order` and reword the partial-revert clause of `## Entry Format`.
  - RN1 sentence, added as its own paragraph after the first paragraph of `## Revert Order`: "To revert an older reduction while keeping the later ones, write a new entry that restores the older entry's stored prior text over the current tree, as entry `0006` did for entry `0001`; this is a route, not a requirement, and the new entry is itself revertible."
  - Reword in the partial-revert paragraph of `## Entry Format`: "step 1 of its `## Revert Steps` states that the new entry is reverted first" becomes "step 1 of its `## Revert Steps` defers to `## Revert Order`, which reverts the new entry first". No other README text changes; the index rows and `## Worked Example` are untouched.
  - Acceptance: `PRC-README-REVERT-ORDER-STATED` and `PRL-README-EXAMPLE-IS-VALID` pass in [P2-T1]; the README carries the token `keeping the later ones` once.
- [x] [P1-T3] Fix RN2 in `scripts/dev-tools/ProcessReductionChain.psm1` by removing the unreachable created-path check.
  - In `Get-ProcessReductionEndStateError`, delete the `Created` branch and its error line, keep the pre-image loop, and reword its help text to describe the pre-image check only. Remove the `-Created` switch and the `Created` property from `Add-ProcessReductionTouch`, and drop `-Created` from the create call in `Invoke-ProcessReductionPatchStep`. In the `.DESCRIPTION` of `Invoke-ProcessReductionChain`, reword the end-state sentence to state that each pre-image of the oldest touching entry is present.
  - Behavior outside the removed branch is unchanged. Dispositions are in `## Test Dispositions`; no test is edited.
  - Acceptance: `git grep -n -e "entry created" -e "-Created" -- scripts/dev-tools/ProcessReductionChain.psm1` returns no match; the file stays under 500 logical lines; the recorded gates in Phase 2 pass.

### Phase 2 — Final QA

- [x] [P2-T1] Run the PowerShell QA loop and write `FEATURE/evidence/qa-gates/stage-r-cycle2-powershell-format-lint.<timestamp>.md` and `FEATURE/evidence/qa-gates/stage-r-cycle2-powershell-test.<timestamp>.md`.
  - Format and lint: PoshQC format in check mode (writer recorded, not applied) and the direct analyzer with the repository settings over `scripts/dev-tools/ProcessReductionChain.psm1`. Observation beyond the exit code: the formatter reports the file already formatted with nothing to write, `git status --porcelain` over the file is empty after it, and the analyzer reports 0 findings. A formatter change is committed and the loop restarts.
  - Test: one `Invoke-PoshQCParallelTest`; counts from `artifacts/pester/pester-junit.xml` (from `artifacts/pester/parallel/shard-<i>/` when `ExitCode` is non-zero), line coverage from `artifacts/pester/powershell-coverage.xml`, compared with the P0-T1 artifact.
  - Output Summary: total, passed, and failed counts; counts of the two `ProcessReductionChain` suites and the three `ProcessReductionLedger` suites; repo-wide line percentage; per-file line percentage of `ProcessReductionChain.psm1` and `ProcessReductionLedger.psm1`; the comparison.
  - Acceptance: zero analyzer findings and no formatter change; zero test failures; `PRC-LEDGER-CHAIN-HOLDS`, `PRL-REAL-LEDGER-AGREES`, and `PRL-PARTIAL-REVERT-LINKED` passed; repo-wide coverage not below the Phase 0 baseline; `ProcessReductionChain.psm1` not below its P0-T1 figure; `ProcessReductionLedger.psm1` at 100%; no new failing test.
- [x] [P2-T2] Run the ledger gates from scripts under `SCRATCH` and write `FEATURE/evidence/other/stage-r-cycle2-ledger-gates.<timestamp>.md`.
  - Gates: (a) `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` reports `IsValid` true with 0 errors; (b) `git apply -R --check` of the `0006` patch on the live tree exits 0; (c) the git-level chain gate of [P1-T10] in `plan.2026-11-07T12-03.md`, rebuilt from that task's text and the Command field of the greatest `stage-r-patch-chain-gate.*.md` (both checks exit 0 on the scratch index, end-state comparison with 0 unattributed); (d) the search for `000[2-6]` in `## Revert Steps` of the `0001` entry returns no match.
  - Output Summary: each gate's result; the equal, attributed, and unattributed counts compared with the P0-T1 figures (119, 18, 0).
  - Acceptance: `EXIT_CODE:` is 0 only when all four gates pass and the unattributed count is 0; the counts show no regression against the baseline.
- [x] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Rows include: the F1 commit carries both `reduction: 0001` and `reduction: 0006`; the `PRL-PARTIAL-REVERT-LINKED` targets are unedited; the only `0006` patch change is the one added line; RN2 is recorded as removal with its reason, and AC R3's evidence rests on the pre-image half; no Epic #1019 folder, `plan.2026-11-07T12-43.md`, `spec.md`, skill, mirror, or brief is in the diff; no tag pushed; no baseline task or comparison was reduced; the Phase 0 baseline was read from artifacts with no suite re-run.
  - Acceptance: no FAIL row; a FAIL is fixed and the loop restarts from [P2-T1].

## Pre-Mortem

- Review checklists: [P2-T3] walks all three templates against the merge-base diff and names the token, scope-boundary, and baseline rows explicitly.
- Coverage: the only changed production file is `ProcessReductionChain.psm1`; the removal takes out its one uncovered line, and [P2-T1] reads per-file and repo-wide coverage from the single gate run against the P0-T1 figures, so a drop fails the task.
- Mirror parity: not applicable. No skill, agent, template, bundle, or the `execution-environment` brief is edited; no CI job, required context, tool route, or batch-budget rule changes, so no brief-update task is owed. The README and entries under `docs/engineering/process-reductions/` have no mirror.
- File size: `ProcessReductionChain.psm1` shrinks from about 500 lines; entries, the README, and the patch are Markdown or patch text and exempt.
- Test isolation: no test is added or edited, no test creates a file, and the gate is one `Invoke-PoshQCParallelTest` run, re-run only after a fix. No pytest run (no Python change) and no Jest run.
- CI-only behavior: the patch file is edited on one line and never reformatted, so single-space context lines survive; the edit keeps LF endings under the `eol=lf` rule; the chain suites run in the Windows PowerShell shards and `docs/engineering/` changes always get a full CI run.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with write-time stamps and the four required fields; `SCRATCH` appears as a token only; the baseline is read from existing artifacts, and the chain, reverse-apply, and git-level gates are compared with the recorded stage R results.
