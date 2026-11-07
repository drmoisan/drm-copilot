# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Cycle 1)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T04-19
- **Status:** Planned by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Inputs:** `remediation-inputs.2026-11-07T04-19.md`, `policy-audit.2026-11-07T04-19.md`, `code-review.2026-11-07T04-19.md`, `feature-audit.2026-11-07T04-19.md`

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Blocking finding F1 (no Python coverage artifact) and non-blocking items NB-1 to NB-5, which harden the ledger parser before its first real entry at stage C. The three Nit items are not planned: none of their lines is touched. The orphan-patch report lives in `Test-ProcessReductionLedger`, the tilde-fence limitation in `Get-ProcessReductionFence` (the README already prescribes backtick fences), and the Index test-file items in `ProcessReductionLedger.Index.Tests.ps1`. No acceptance-criterion text or checkbox changes, no ledger entry is owed, and no `execution-environment`, `atomic-plan-contract`, or Epic #1019 file is edited.

Premise check: the review's Python finding is test-only (`test_discovery_documentation_contracts.py`), so no Python source changes here. `pyproject.toml` `addopts` carries `--cov-report=lcov:artifacts/python/lcov.info` without `--cov`, so only a run that passes `--cov` writes the artifact.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launcher scripts and helper scripts live there, and artifacts record the token, never a host path.
- Tool routes come from the `execution-environment` skill and are not restated here.
- Commits: commit and push after each task with a conventional message and the session attribution lines supplied at execution.
- Testing rule (owner's standing instruction, `spec.md` `## Testing Rule`): tests run in parallel only, with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. Phase 1 tasks run no tests; their acceptance names the tests they add, and [P2-T2] proves them.
- A task never runs an unqualified `poetry install` from the worktree. If the worktree environment cannot run a gate, stop and report.
- Reading a Pester gate: `Invoke-PoshQCParallelTest` never calls `exit`, so `EXIT_CODE:` records the `ExitCode` property of the object it returns. The merged `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` are valid only when that value is 0.
- Failure outside the branch: a failing test whose test file and subject are both absent from the diff from the merge base of `origin/main` and `HEAD`. The gate artifact names it, `EXIT_CODE:` stays non-zero, the task stays unchecked, and the executor returns the facts to the caller. Any other failure is on the branch: it is fixed and the loop restarts from [P2-T1].

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md` for PowerShell and Python test scope, and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [x] [P0-T2] Record the stage A final-gate results from the existing artifacts, with no suite run, in `FEATURE/evidence/baseline/stage-a-final-gate.<timestamp>.md`.
  - Sources: the lexicographically greatest `FEATURE/evidence/qa-gates/powershell-test.*.md` and `FEATURE/evidence/qa-gates/python-test.*.md`. `Command:` records that the artifact is a read of those two files. `EXIT_CODE:` is 0 when both were read.
  - Output Summary: the Pester total and failed counts, the module line coverage, the repo-wide PowerShell line percentage, and the Python passed and failed counts, each copied from the sources. The Python source records no coverage, which is finding F1.
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric values.

### Phase 1 — Parser Hardening

- [x] [P1-T1] Harden `scripts/dev-tools/ProcessReductionLedger.psm1` for NB-1, NB-2, and NB-3, and add the tests for those three to `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.
  - NB-1, `Get-ProcessReductionPriorTextError`: a `### Revert Block:` path that is rooted (leading `/` or `\`), carries a drive prefix (letter and colon), or holds a `..` segment adds an error that names the block path and states that it must be repository-relative. A name such as `..foo` is not a `..` segment. Test `PRL-ENTRY-BLOCK-PATH-NOT-RELATIVE`, driven with `-ForEach` over a rooted path, a drive-prefixed path, a leading `..` path, and an inner `..` path, each asserting `IsValid` false and the error text. Test `PRL-ENTRY-BLOCK-PATH-DOT-PREFIX-ACCEPTED` asserts that `.claude/skills/x/SKILL.md` and `docs/..foo/a.md` stay valid.
  - NB-2, `Get-ProcessReductionRevertStepError`: the six labels are searched only in the text outside fences, taken from `Get-ProcessReductionPlainLine`, so a section holding only a fenced list reports each label as missing. Test `PRL-ENTRY-REVERT-STEP-FENCED-LABELS-IGNORED` builds a Revert Steps section whose six labels sit inside a fence and asserts `IsValid` false with a `must name` error.
  - NB-3, `Test-ProcessReductionEntry`: the lookahead after the stored patch path accepts one trailing sentence period but still rejects a longer name (`.patch.bak`, `.patch/x`). Test `PRL-ENTRY-STORED-PATCH-TRAILING-PUNCTUATION` asserts that `Apply patches/0001-sample-entry.patch.` is accepted with the expected `PatchPath`, and that a `.patch.bak` suffix is rejected.
  - Asserting tests found by searching the test tree for the changed symbols and the asserted text: `PRL-ENTRY-COMPLETE`, `PRL-ENTRY-BLOCK-WITHOUT-PRIOR`, and the Prior Text fixtures use `docs/a.md`, so they are unchanged. `PRL-ENTRY-REVERT-STEP-MISSING` and `PRL-ENTRY-REVERT-STEP-ORDER` use unfenced labels, so they are unchanged. `PRL-ENTRY-STORED-PATCH-ACCEPTED` and `PRL-ENTRY-STORED-PATCH-WRONG-NAME` are unchanged, and `PRL-README-EXAMPLE-IS-VALID` in `ProcessReductionLedger.Index.Tests.ps1` is unchanged because its paths and labels are conforming.
  - Acceptance: the four new `It` names exist in the test file, and [P2-T2] reports them passing. The module stays under 700 lines and the test file under 500.
- [x] [P1-T2] Add the NB-5 falsifying tests to `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, with no module change.
  - `PRL-FENCE-INFO-LINE-DOES-NOT-CLOSE`, in the `Get-ProcessReductionRevertBlock` Describe: a `Current` fence holds a line that is a closing-length fence followed by an info string, then more body, then a bare closing fence. The assertion is that `Current` contains both the info-bearing line and the later body, so deleting the empty-info condition of the fence-closing branch of `Get-ProcessReductionLine` fails the test.
  - `PRL-BLOCK-FIRST-REPEATED-LABEL-WINS`, same Describe: a block carries two `Current` fences with different bodies, and the assertion is that `Current` equals the first body.
  - `PRL-SECTION-ENDS-AT-LEVEL-ONE-HEADING`, in the `Get-ProcessReductionSection` Describe: a level-one heading after the section body ends it, and the assertion is that the returned body excludes the text after that heading.
  - Acceptance: the three `It` names exist, and [P2-T2] reports them passing. The test file stays under 500 logical lines; if it would reach 500, the NB-5 tests move to a new `tests/scripts/dev-tools/ProcessReductionLedger.Parser.Tests.ps1` and that file joins [P2-T1].
- [ ] [P1-T3] Update `docs/engineering/process-reductions/README.md` for NB-4: the `## Entry Format` Summary bullet and the `## Worked Example` `## Summary` gain a `Date:` line (UTC, `yyyy-MM-dd`) and an `Issue:` line (`#N`), placed before the `Merge commit:` line.
  - Chosen option: README, not `spec.md`. The parser requires only the `reduction:` and `Merge commit:` lines, so the new lines are format guidance and are not enforced, and `spec.md` is not edited. The README also states that a revert-block path is repository-relative with no leading separator, drive prefix, or `..` segment (NB-1) and that a stored patch path is written in backticks or ends a sentence with at most one period (NB-3).
  - Acceptance: the README carries both new lines in the format and in the example, and `PRL-README-EXAMPLE-IS-VALID` stays valid against the updated example, as [P2-T2] proves. The README is Markdown, so the file-size tiers do not apply.

### Phase 2 — Final QA

- [ ] [P2-T1] Run the PowerShell format and lint stages over `scripts/dev-tools/ProcessReductionLedger.psm1` and `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, and write `FEATURE/evidence/qa-gates/powershell-format-lint.<timestamp>.md`.
  - Format runs `Invoke-PoshQCFormat` check-only, with a no-op `-WriteFile`, over `scripts/dev-tools` and `tests/scripts/dev-tools`. Lint runs `Invoke-ScriptAnalyzer` directly on the two files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: the log holds an `Already formatted: ` line and no `Formatted: ` line for each file, and analyzer findings number zero. `EXIT_CODE:` is non-zero when either condition fails. A failure is repaired and this task restarts. No Python file changes, so no Python format stage runs.
- [ ] [P2-T2] Run the two gates, once each, from the worktree root: one `Invoke-PoshQCParallelTest`, writing `FEATURE/evidence/qa-gates/powershell-test.<timestamp>.md`, then `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing`, writing `FEATURE/evidence/qa-gates/python-coverage.<timestamp>.md`. Neither run is repeated unless a fix follows a failure.
  - PowerShell artifact: the returned `ExitCode` is 0; the failed count from `artifacts/pester/pester-junit.xml` is zero; every `It` name added by [P1-T1] and [P1-T2] is present and passing in that file; the `LINE` counter of the `sourcefile` element named `ProcessReductionLedger.psm1` in `artifacts/pester/powershell-coverage.xml` is at least 85%; the repo-wide line percentage from `Get-PoshQCCoverageLineSummary` is at least 85% and is stated beside the [P0-T2] figure. `PRL-README-EXAMPLE-IS-VALID` is among the passing tests.
  - Python artifact: the process exit is 0 with zero failures, and `artifacts/python/lcov.info` exists afterwards. A helper script under `SCRATCH` sums the `LF` and `LH` records for the repo-wide line percentage and the `BRF` and `BRH` records for the repo-wide branch percentage, because the terminal table prints one combined column. The artifact states both against the 85% and 75% defaults and beside the merge-base CI figure of 96.67% lines recorded in `remediation-inputs.2026-11-07T04-19.md`. The file stays on disk, because `artifacts/` is gitignored and the re-review reads it there. Coverage is repo-wide because no Python production file changed.
  - Both artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, with figures read from files and not from MCP output. `EXIT_CODE:` is non-zero when any condition of its artifact fails. A failing test is classified under Execution Terms.
- [ ] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Scope rows: the diff is limited to the module, the two test files that exist plus any file created under the [P1-T2] split, the README, and `FEATURE`. It holds no `execution-environment` or `atomic-plan-contract` file, no Epic #1019 folder, no ledger entry, and no `spec.md` change. The coverage row names the Python artifact by its `python-coverage` evidence file and covers PowerShell and Python.
  - Acceptance: every finding in `remediation-inputs.2026-11-07T04-19.md` (F1, NB-1 to NB-5) has a row naming its proving test or artifact, and no row is FAIL. A FAIL row is fixed, the loop re-runs from [P2-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a parser rule with no falsifying test, the class this cycle closes. NB-1, NB-2, NB-3, and NB-5 each map to a named test that fails if the rule is removed, and [P2-T3] maps all six inputs to evidence rows. The review's test-only Python exemption gap (F1) is closed by an artifact, not by an argument.
- Coverage: F1 is closed by the `--cov` run in [P2-T2], whose lcov file supplies line and branch totals; no second Python run is made. The module stays at 100% line coverage in the Pester coverage file, and the new tests execute every new branch. Branch coverage does not apply to PowerShell. No Python production file changes.
- Mirror parity: no skill, rule, agent, hook, or bundled file changes, so no mirror or bundle copy changes. The cycle alters no fact the `execution-environment` brief states, so no brief-update task is needed.
- File size: the module is 547 lines and gains roughly 15, far below 700. The main test file is near 400 lines and gains roughly 80, under 500; [P1-T2] names the split file if it would reach 500.
- Test isolation: by the owner's standing instruction, recorded in `spec.md` `## Testing Rule`, the isolation runs are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, repeated only after a fix. There are no single-process, seeded-shuffle, reversed-order, or comparison runs. The new tests build in-memory fixtures, create no file, and set no global state.
- CI-only behavior: fixtures are in-memory strings, so the `eol=lf` rule of `.gitattributes` cannot alter them, and the added paths use forward slashes with no drive-letter literal as an expected-valid value. The new test is assigned to a `poshqc` shard automatically. `docs/engineering/` is outside the docs-only allowlist, so the PR takes a full run.
- Evidence: artifacts live under `FEATURE/evidence/baseline/` and `FEATURE/evidence/qa-gates/` with write-time stamps and the four required fields, and record no host path. `artifacts/python/lcov.info` is gitignored and is therefore left on disk, not committed. `EXIT_CODE:` carries each acceptance value.

## Test Plan

- Unit: `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` gains `PRL-ENTRY-BLOCK-PATH-NOT-RELATIVE`, `PRL-ENTRY-BLOCK-PATH-DOT-PREFIX-ACCEPTED`, `PRL-ENTRY-REVERT-STEP-FENCED-LABELS-IGNORED`, `PRL-ENTRY-STORED-PATCH-TRAILING-PUNCTUATION`, `PRL-FENCE-INFO-LINE-DOES-NOT-CLOSE`, `PRL-BLOCK-FIRST-REPEATED-LABEL-WINS`, and `PRL-SECTION-ENDS-AT-LEVEL-ONE-HEADING`.
- Integration: `PRL-README-EXAMPLE-IS-VALID` and `PRL-REAL-LEDGER-AGREES` stay unchanged and re-prove the updated README and the empty ledger.
- Coverage evidence: baseline in `FEATURE/evidence/baseline/stage-a-final-gate.<timestamp>.md`; post-change in the [P2-T2] artifacts.

## Open Questions / Notes

- The reviewed head is the one named in `remediation-inputs.2026-11-07T04-19.md`.
- NB-3 takes the code option with a README note; NB-4 takes the README option and does not enforce the new lines.
- The three Nit items stay unplanned and unrecorded as findings; they remain in the code review for a later stage.
