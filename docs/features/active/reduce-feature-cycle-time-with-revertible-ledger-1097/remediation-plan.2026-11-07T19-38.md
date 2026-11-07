# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage R, cycle 3, F1 merge with PR #1112)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T19-38
- **Status:** Authored by `atomic-planner`; awaiting executor preflight
- **Version:** 0.3
- **Inputs:** `remediation-inputs.2026-11-07T19-38.md` (primary)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

F1 only: merge `origin/main` (PR #1112, issue #1096) into the branch, keep both sides of entry `0001`, and make the revert order express the second landing that PR #1112 added to `0001`.

### Design Decision

The question was whether newest-first by entry number still reverts correctly now that part of `0001` landed after entries `0002` to `0006`. It was decided by reading `main`'s `0001` entry, the stored patches `patches/0001-parallel-only-test-gates.patch` and `patches/0006-test-suite-baseline-restored.patch`, the `.claude/skills/execution-environment/SKILL.md` blocks of `0002`, `0003`, and `0006`, and `Invoke-ProcessReductionChain`.

- No #1096 block's region overlaps a target-file region of `0002` to `0006`. The only #1096 path that any of `0002` to `0006` lists is `.claude/skills/execution-environment/SKILL.md`. The #1096 block there covers the `## Test Runtime` bullets from `Second, build an expensive immutable fixture` to `A candidate fix can be measured`. The `0006` hunk in that file ends at the `## Test Runtime` heading, four bullets above it. The `0002` and `0003` blocks in that file sit in `## Command-Text Restrictions`, `## Hook Execution Context`, `## MCP Surfaces Run the Installed Extension`, `## CI Shape and Required Checks`, and `## Contract Tests That Pin Mirrored Files`. The other twelve #1096 paths are in no `## Files Changed` of `0002` to `0006`.
- The #1096 brief block does overlap `0001`'s own stored patch. The `0001` patch hunk in `## Test Runtime` adds the pytest bullet that ends `and of the parallel VS Code tasks, never in addopts`, and the #1096 landing rewrote that same bullet to add the `fix_all` step and the atomic executor commands. Newest-first by number cannot order two landings of one entry. `Invoke-ProcessReductionChain` also only checks the blocks of a patch entry and never applies them. On the merged ledger it would therefore look for the patch hunk's `Current` in text that the #1096 landing has already changed, and fail. It would also report every non-empty #1096 `Prior` as absent after the patch, because the patch does not hold those edits. So the chain does not hold as it stands, and the order rule must change.
- The #1096 landing also edited `0001`'s own `## Revert Steps` step 1 and its first `## Revert Signals` bullet. Both sit inside the two hunks that `patches/0006-test-suite-baseline-restored.patch` holds for `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`. The README rule already covers this case (an edit inside a recorded region regenerates that hunk in both images under the entry's token), so those two `0006` hunks are rebased in the merge commit.
- `main` also added three `Invoke-PoshQCLeakScan` bullets to the brief with no block, and each one sits inside a `0001` patch hunk of the brief. The first is in `## PowerShell Route and PoshQC MCP Limits`, after the `Invoke-Pester` bullet. The second is in `## CI-Only Failure Classes`, after the bullet `Files in one shard share a process`. The third is at the end of `## Test Isolation Checks`. In the third case the `0001` hunk has no trailing context, so `git apply` anchors it at the end of the file. The same README rule applies: the six brief sections of the `0001` patch are regenerated so that both images carry those bullets. Stage R handled the `planning-contract-wording.Tests.ps1` line the same way.

Rule chosen, the smallest a reader can follow by hand: entries stay newest-first by number. A later landing to an older entry is recorded in that entry under a heading `### Later Landing: #N` at the end of `## Prior Text`. Within the entry's turn, its later landings are reverted first, the last heading first, before the entry's own blocks or stored patch. A later landing may not edit a region that a higher-numbered entry records; a change that would do so takes a new entry instead. As a result, number order is landing order wherever regions overlap. The chain test fails whenever this rule is broken: a higher-numbered entry's `Current` would not be found, or a patch hunk would not apply. The rule needs no exception list, no skip, and no new structure-checker rule. Because no #1096 region overlaps `0002` to `0006`, reverting #1096 at the start of `0001`'s turn restores the same text as reverting it at its true landing time.

Out of scope and left alone: `spec.md`; Epic #1019 folders; `plan.2026-11-07T12-43.md`; `scripts/dev-tools/ProcessReductionLedger.psm1`; every skill, agent, mirror, bundle, and the `execution-environment` brief (the merge brings `main`'s brief text and this plan edits none).

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`. `SCRATCH` resolves to `<session scratchpad>/issue-1097/`; artifacts record the token, never a host path. Evidence names carry the prefix `stage-r-cycle3-`. A consumer selects the greatest `<name>.*.md`.
- Tool routes, launchers, command-text restrictions, the batch budget, hook context, and CI shape come from the `execution-environment` skill. One production PowerShell file is edited (`scripts/dev-tools/ProcessReductionChain.psm1`), so direct mode applies.
- Testing (owner's standing instruction, which overrides any contract text): one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs. A focused run of one test file is debugging only and never evidence. No unqualified `poetry install` from the worktree.
- Commits: commit and push after each task. No tag, no history rewrite, no forced push. The resolution is a merge commit. Every commit that edits an entry carries that entry's `reduction:` token in its subject, and commit messages go through `git commit -F` with a file under `SCRATCH`.
- Failure outside the branch: a failing test whose file and subject are both absent from the diff between the merge base of `origin/main` and `HEAD`. After [P1-T2] that merge base is the merged `origin/main`, so files that only `main` changed fall here. The artifact names the test, file, and subject; `EXIT_CODE:` stays non-zero; the test is not edited; and the executor returns these facts. Any other failure is fixed, and the loop restarts from [P2-T1].

## Test Dispositions

These were found by searching `tests/` for `Invoke-ProcessReductionChain`, `Get-ProcessReductionRevertBlock`, `Revert Order`, `Later Landing`, `0001-parallel-only-test-gates`, and `process-reductions`.

- `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`: every existing `It` stays as it is. Their fixtures carry no `### Later Landing:` heading, and on such entries the new code gives the same result as the current code. New cases are added under a new `Describe` ([P1-T1]).
- `PRC-README-REVERT-ORDER-STATED` (`tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`): updated to also assert the token `Later Landing`, because the README now states the later-landing rule. `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-END-STATE-RECORDED`, and `PRC-LEDGER-NO-EXCEPTIONS`: unchanged. They must pass on the merged ledger. New variables in that file must not match the `PRC-LEDGER-NO-EXCEPTIONS` name filter (`allow`, `skip`, `ignore`, `exempt`, `except`, `known`).
- `PRL-REAL-LEDGER-AGREES`, `PRL-PARTIAL-REVERT-LINKED`, and `PRL-README-EXAMPLE-IS-VALID` (`tests/scripts/dev-tools/ProcessReductionLedger*.Tests.ps1`): unchanged. Neither the `0001` `## Partial Revert` section, the index rows, the `0006` `## Summary`, nor `## Worked Example` is edited.
- `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`: unchanged. It names the ledger folder, not README wording.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Write `FEATURE/evidence/baseline/stage-r-cycle3-baseline-reference.<timestamp>.md`, recording the Phase 0 baseline read from the stage R Phase 0 artifacts. No suite is run.
  - Sources: the greatest `stage-r-powershell-test-baseline.*.md` (15675 tests, 0 failed, repo-wide line coverage 94.01%); the greatest `stage-r-python-test-baseline.*.md` (16204 passed, 0 failed, total line coverage 96.99%, total branch coverage 94.17%); the greatest `stage-r-powershell-static.*.md`; and the greatest `stage-r-cycle2-baseline-reference.*.md`, all under `FEATURE/evidence/baseline/`. The last one supplies the static state of `scripts/dev-tools/ProcessReductionChain.psm1` and its two test files, the coverage of `ProcessReductionChain.psm1` (99.5%, 201 of 202 lines), and the git-level chain gate counts (equal 119, attributed 18, unattributed 0).
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Every figure is numeric and traced to a named artifact, and `Command:` states that no suite was run.

### Phase 1 — Design and Merge

- [x] [P1-T1] Express landing order in `scripts/dev-tools/ProcessReductionChain.psm1`, `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, and `docs/engineering/process-reductions/README.md`, in one commit before the merge. Write `FEATURE/evidence/other/stage-r-cycle3-landing-order.<timestamp>.md` with the overlap analysis of `## Design Decision`, read from `origin/main` through `git show` and from the stored patches.
  - Module: add the exported pure function `Get-ProcessReductionLanding -Text <entry text>`. It splits `## Prior Text` at headings `### Later Landing: <label>` that sit outside fences. It returns one object per landing with `Label` and `Block` (from `Get-ProcessReductionRevertBlock`), in revert order: the later landings last-heading-first, then the first landing (`Label` `first`, the blocks above the first heading). An entry with no `## Prior Text` returns only the first landing, with no blocks. A later landing with no block throws, naming the label.
  - In `Invoke-ProcessReductionChain`, each entry's turn (newest-first by name, unchanged) first reverts its later landings through `Invoke-ProcessReductionBlockStep`. Each landing gets its own touched map, and each error is prefixed `<entry> (later landing <label>): <path>:`. The turn then runs the first landing exactly as now: block entry, or patch entry with `Test-ProcessReductionBlockText` over the first-landing blocks only. Touched maps merge in processing order, so the end-state check still judges the oldest landing that touches a path.
  - Add the optional parameter `-StopBefore <entry name>`. The chain stops after that entry's later landings and before its first landing, then runs the end-state check over what it reverted. A name that matches no supplied entry throws. `Read-ProcessReductionChainInput` is unchanged, because later-landing blocks sit inside `## Prior Text`. Update the comment help of each changed function and add the new function to `Export-ModuleMember`.
  - Unit tests: add a new `Describe` to `ProcessReductionChain.Tests.ps1` with in-memory fixtures and no file:
    - `PRC-LANDING-SPLITS-PRIOR-TEXT`: two later landings come back last-heading-first, then `first`, and a heading inside a fence does not split.
    - `PRC-LANDING-EMPTY-THROWS`.
    - `PRC-CHAIN-LATER-LANDING-OVERLAPS-OWN-PATCH`, the overlapping case: a patch hunk changes `old` to `new`, a later-landing block changes `new` to `newer`, and the live text is `newer`. With the heading, `IsValid` is true and the final text is `old`. With the same block placed above the heading, `IsValid` is false and an error names `0001-a.md` and the path.
    - `PRC-CHAIN-LATER-LANDINGS-NEWEST-FIRST`.
    - `PRC-CHAIN-LATER-LANDING-ON-BLOCK-ENTRY`.
    - `PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS`: a later landing of `0001` edits a region recorded by `0002`, and an error names `0002-b.md`.
    - `PRC-CHAIN-STOP-BEFORE`: the state holds the later landing reverted and the patch not reverted, and an unknown name throws.
  - Ledger test: extend `PRC-README-REVERT-ORDER-STATED` with the token `Later Landing`. Add `PRC-LEDGER-SUBCHAIN-HOLDS`, which runs `Invoke-ProcessReductionChain -StopBefore` for each committed entry that has a `## Stored Patch` and expects `IsValid` true with 0 errors.
  - README: in `## Entry Format`, extend the `## Prior Text` paragraph to state that a later landing's blocks go at the end under `### Later Landing: #N`. In `## Revert Order`, add one paragraph stating: newest-first by number is unchanged; within an entry, its later landings are reverted first, the last heading first, then its own blocks or stored patch; a later landing may not edit a region a higher-numbered entry records, and a change that would do so takes a new entry; and the chain test fails on a violation. Also extend the stored-patch sentence so that the patch check runs after the entry's own later landings are reverted. The tokens `newest-first` and `ProcessReductionChain.Ledger.Tests.ps1` stay.
  - Acceptance: `git grep -n -e "Later Landing" -- docs/engineering/process-reductions/README.md scripts/dev-tools/ProcessReductionChain.psm1` lists both files. All seven new test names exist in the test file. On the pre-merge ledger, `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` (script under `SCRATCH`) still reports `IsValid` true with 0 errors, and its result is recorded in the evidence artifact. The module stays at or under 700 logical lines, and each test file stays under 500. The commit is pushed.
- [x] [P1-T2] Merge `origin/main` into the branch as one merge commit that resolves `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` and rebases the two `0001` hunks of `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`. Record the merge in `FEATURE/evidence/other/stage-r-cycle3-merge.<timestamp>.md`.
  - Resolve `0001`, keeping both sides:
    - `## Summary`, `## Reason and Evidence`, and `## Partial Revert` stay as they are (they are identical on both sides).
    - `## Files Changed` takes `main`'s two-part introduction and the #1096 path list.
    - `## Stored Patch` keeps this branch's `Rebased for stage R` paragraph and its check sentence, extended to say that the check also runs after this entry's later landings are reverted. It keeps `main`'s sentence that the patch does not hold the #1096 edits, ending with `under ### Later Landing: #1096` in code format.
    - `## Prior Text` keeps `main`'s first paragraph and all of `main`'s blocks. Insert the heading `### Later Landing: #1096` immediately before the second `### Revert Block: .claude/skills/execution-environment/SKILL.md`, and move `main`'s paragraph that begins `The #1096 landing adds the blocks` to sit under that heading.
    - `## Revert Steps` steps 2 to 4 are unchanged. Steps 5 and 6 take `main`'s #1096 additions. Step 1 reads: "1. Apply the blocks: revert every later entry that names any path in `## Files Changed`, newest-first, as README `## Revert Order` states; then revert this entry's later landing under `### Later Landing: #1096` by replacing each of its `Current` texts with its `Prior`, because the patch does not hold it; then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` above that heading with its `Prior`, which restores the core rule, and restore the other paths from the patch text."
    - `## Revert Signals` takes `main`'s bullets.
  - Rebase the `0006` hunks on that entry file, editing only these lines:
    - Hunk 1: the `+` line becomes the step 1 above, and the `-` line becomes the same text without the clause `revert every later entry that names any path in ## Files Changed, newest-first, as README ## Revert Order states; then ` (with its code formatting).
    - Hunk 2: its first bullet context line becomes `main`'s first `## Revert Signals` bullet.
    - Recompute both `@@` start numbers from the merged entry. The line counts are unchanged.
    - In `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md` `## Stored Patch`, add one paragraph: "Rebased over PR #1112 (issue #1096): the two hunks on `0001-parallel-only-test-gates.md` were regenerated so that both images carry that landing's `## Revert Steps` clause and `## Revert Signals` bullet; every other section is unchanged."
  - Regenerate the six `.claude/skills/execution-environment/SKILL.md`-family sections of `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch` so that both images carry `main`'s three `Invoke-PoshQCLeakScan` bullets (`## Design Decision`). The pre-image is each section's current pre-image with those bullets inserted at the same positions, and the post-image is the merged brief with the #1096 later landing reverted. The six sections stay identical apart from their paths. Add one paragraph to `0001` `## Stored Patch`: "Rebased over PR #1112 (issue #1096): the six brief sections were regenerated so that both images carry the three `Invoke-PoshQCLeakScan` bullets that PR #1112 added inside their hunks; their other hunks are unchanged apart from line numbers."
  - Run the chain check over the merged ledger (script under `SCRATCH`). If an error names any other block or hunk whose region `main` moved, in any entry, rebase it in the same commit under that entry's token and list it in the artifact. No exception list and no skip.
  - The merge-commit subject carries `reduction: 0001` and `reduction: 0006`.
  - Acceptance:
    - `git grep -n -e "^<<<<<<< " -e "^>>>>>>> " -- docs/engineering/process-reductions` returns no match.
    - `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger` reports valid.
    - The chain reports `IsValid` true with 0 errors, and `Get-ProcessReductionLanding` returns the label `#1096` for `0001`.
    - `git apply -R --check` of the `0006` patch on the live tree exits 0.
    - The six brief sections of the `0001` patch carry the token `is the static check` in context lines of both images. The end-of-file anchoring of the `## Test Isolation Checks` hunk is proven by gate (c) of [P2-T4].
    - `git log -1` shows two parents and both tokens.
    - The artifact records each check with its result, and the push succeeds.

### Phase 2 — Final QA

- [x] [P2-T1] Run format and lint on the changed PowerShell files and write `FEATURE/evidence/qa-gates/stage-r-cycle3-powershell-format-lint.<timestamp>.md`.
  - Scope: `scripts/dev-tools/ProcessReductionChain.psm1`, `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`, and `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`. Run PoshQC format in check mode (no-op writer) and the direct analyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Observation beyond the exit code: the formatter reports `Formatted: 0` for each file, `git status --porcelain` over the three files is empty afterwards, and the analyzer reports 0 findings. A needed format change is applied and committed, and the loop restarts here.
  - Acceptance: zero analyzer findings and no format change, compared with the P0-T1 static state.
- [x] [P2-T2] Run one `Invoke-PoshQCParallelTest` and write `FEATURE/evidence/qa-gates/stage-r-cycle3-powershell-test.<timestamp>.md`.
  - Read counts from `artifacts/pester/pester-junit.xml` (or from `artifacts/pester/parallel/shard-<i>/` when `ExitCode` is non-zero) and line coverage from `artifacts/pester/powershell-coverage.xml`, then compare with the P0-T1 artifact.
  - Output Summary: total, passed, and failed counts; the counts of the two `ProcessReductionChain` suites and the three `ProcessReductionLedger` suites; repo-wide line percentage; the per-file percentage of `ProcessReductionChain.psm1` and `ProcessReductionLedger.psm1`; and the comparison.
  - Acceptance:
    - `ExitCode` is 0 and there are zero failures.
    - The seven new `PRC-` tests, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-LEDGER-CHAIN-HOLDS`, `PRL-REAL-LEDGER-AGREES`, and `PRL-PARTIAL-REVERT-LINKED` passed.
    - `ProcessReductionChain.psm1` is at or above its 99.5% baseline, and every new line is at least 85% covered; `ProcessReductionLedger.psm1` stays at 100%.
    - Repo-wide coverage is not below 94.01%. A drop is attributed per file, and a drop in a file in the diff from the merge base fails the task.
- [ ] [P2-T3] Run `PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing` once from the worktree root and write `FEATURE/evidence/qa-gates/stage-r-cycle3-python-test.<timestamp>.md`.
  - Read total line coverage from the Stmts and Miss columns of the `TOTAL` row, and branch coverage from the summed BRF and BRH records of `artifacts/python/lcov.info`, as the baseline did.
  - Output Summary: passed, failed, and skipped counts; total line and branch percentages; the comparison with P0-T1 (16204 passed, 96.99%, 94.17%).
  - Acceptance: zero failures; line coverage at or above 85% and branch coverage at or above 75%; totals not below the baseline, or each drop attributed per file from the term-missing table to files that only `main` changed. Such a drop is returned as a finding, and a drop in a file in the diff from the merge base fails the task.
- [ ] [P2-T4] Run the ledger gates from scripts under `SCRATCH` and write `FEATURE/evidence/other/stage-r-cycle3-ledger-gates.<timestamp>.md`.
  - Gates:
    - (a) `Test-ProcessReductionLedger` is valid, and `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` reports `IsValid` true with 0 errors.
    - (b) `git apply -R --check` of the `0006` patch on the live tree exits 0.
    - (c) The git-level chain gate of [P1-T10] in `plan.2026-11-07T12-03.md`, rebuilt from that task's text and the `Command:` of the greatest `stage-r-patch-chain-gate.*.md`, with one change: each patch entry's scratch index is loaded from the `FinalText` of `Invoke-ProcessReductionChain -StopBefore <entry>` over all entries, so the `0001` check runs after `0006` to `0002` and the `#1096` later landing.
    - (d) The search for `000[2-6]` in `## Revert Steps` of `0001`, extracted with `Get-ProcessReductionSection`, returns no match.
  - Output Summary: each gate's result, and the equal, attributed, and unattributed counts compared with P0-T1 (119, 18, 0). Each count change is explained per path, for example the #1096 paths that the chain now reverts.
  - Acceptance: `EXIT_CODE:` is 0 only when all four gates pass and the unattributed count is 0.
- [ ] [P2-T5] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Rows include:
    - Both sides of `0001` are kept, with no conflict marker anywhere.
    - The README rule, the module, and the tests agree, and the overlapping fixture is present.
    - Every entry edit carries its token: the merge commit carries `reduction: 0001` and `reduction: 0006`.
    - `ProcessReductionLedger.psm1`, `spec.md`, Epic #1019 folders, `plan.2026-11-07T12-43.md`, and every skill, mirror, and brief are absent from the branch's own changes.
    - No tag was pushed and nothing was force-pushed.
    - The Phase 0 baseline was read from artifacts, and no baseline task, evidence, or comparison was reduced.
    - New PowerShell code is at or above 85%.
  - Acceptance: no FAIL row. A FAIL is fixed, and the loop restarts from [P2-T1].

## Pre-Mortem

- Review checklists: [P2-T5] walks all three templates against the merge-base diff and names the scope, token, conflict-marker, and baseline rows explicitly.
- Coverage: the only changed production file is `ProcessReductionChain.psm1`. [P1-T1] adds a fixture for each new branch (split, empty landing, own-patch overlap, newest-first, block entry, higher-entry violation, stop and unknown stop). [P2-T2] reads per-file and repo-wide coverage from the single gate run against P0-T1, and [P2-T3] does the same for the Python that the merge brings.
- Mirror parity: not applicable. The module, its tests, the README, and the entries have no mirror or bundle copy. No CI job, required context, tool route, or batch-budget rule changes, so no brief-update task is owed. The brief changes only through `main`'s merged text.
- File size: `ProcessReductionChain.psm1` grows from just under 500 logical lines into the 500-to-700 guidance band. That is guidance only, and [P1-T1] caps it at 700. `ProcessReductionChain.Tests.ps1` stays under 500. Entries, the README, and the patch are Markdown or patch text and are exempt.
- Test isolation: new tests use in-memory strings and create no file. The gates are one `Invoke-PoshQCParallelTest` run ([P2-T2]) and one `pytest -n auto` run ([P2-T3]), each re-run only after a fix. Jest is not run, because no TypeScript changes.
- CI-only behavior: the patch is edited only on the named lines and never reformatted, so single-space context lines and LF endings survive the `eol=lf` rule. The chain suites run in the Windows PowerShell shards, and a merge with code changes always gets a full CI run.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/`, with write-time stamps and the four required fields. `SCRATCH` appears only as a token. The baseline is read from the stage R artifacts with no suite re-run, and each gate is compared with it.
