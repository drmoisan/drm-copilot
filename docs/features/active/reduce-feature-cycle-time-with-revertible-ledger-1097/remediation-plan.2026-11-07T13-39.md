# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage E, first review)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T13-39
- **Status:** Planned by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Remediation-Mode:** proportionate
- **Inputs:** `remediation-inputs.2026-11-07T13-39.md` (primary)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Blocking finding F1 and non-remediation item N1, as two commits. F1 removes the `phase0-instructions-read.md` bullet from the Copilot review prompt and its bundle and updates entry `0005`. N1 adds one corpus row and raises the three corpus count pins, and updates entry `0003`. No production source file changes. No baseline, coverage-comparison, or `N/A - no pre-change run` text changes anywhere: restoring the test baseline is the next stage. No acceptance-criterion text or checkbox changes, no Epic #1019 folder, no `execution-environment` brief change, no tags. The `Merge commit:` lines of both entries stay as they are.

Premise corrections, each read against the tree:

- **No policy-read task is added.** The planner stop hook `.claude/hooks/validate-planner-output.ps1` now reports only `Phase 0 must include a baseline task.`; stage E's merged removal is on this branch. Phase 0 here holds one baseline task.
- **Entry `0005` has a stale paragraph.** Its `## Reason and Evidence` section says the removal is incomplete on the review prompt and held under the baseline hold. F1 makes that false, so [P1-T1] rewrites only the sentences about the prompt, keeps the time-saved sentence, and records the owner's 2026-11-07 ruling. The baseline-hold sentence about presuming no outcome is not a baseline-requirement wording and stays.
- **The new `PCW-SURFACE` row needs the existing forbidden list.** `$surfaceForbidden` in `planning-contract-wording.Tests.ps1` already holds `phase0-instructions-read`, so the row proves the bullet is gone. Its comment saying the prompt is "deliberately absent" becomes false and is updated.
- **Entry `0003` counts sixteen corpus files, twice.** The `## Files Changed` corpus bullet and `## Revert Steps` step 1 each say sixteen; N1 makes it seventeen in both, and step 5 keeps the floor of 41 as the pre-entry value.
- **The corpus is walked by name, not counted, outside the pins.** `test_orchestrator_state_light_cycle.py` (`test_corpus_expects_every_invariant_8_message`) globs the corpus and needs each invariant 8 message in some row; a row that expects only invariant 2 leaves it passing. `OrchestratorStateRemediationAccounting.Tests.ps1` and `orchestrator-state-remediation-accounting.test.ts` read one named row each and are unaffected.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launchers and helpers live there and artifacts record the token, never a host path.
- Tool routes come from the `execution-environment` skill and are not restated here.
- Commits: commit and push after each task with a conventional subject and the session attribution lines supplied at execution. [P1-T1] carries `reduction: 0005` in its subject and [P1-T2] carries `reduction: 0003`. No tags.
- Testing rule (owner's standing instruction): tests run in parallel only. The Pester gate is one `Invoke-PoshQCParallelTest` run, the pytest gate is one `pytest -n auto` run, and Jest runs through its normal workers; each is re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison run. A task never runs an unqualified `poetry install` from the worktree; if the worktree cannot run a gate, stop and report.
- Hold: no task changes baseline, coverage-comparison, or `N/A - no pre-change run` text.
- Reading the Pester gate: `EXIT_CODE:` records the `ExitCode` property of the object `Invoke-PoshQCParallelTest` returns; merged `artifacts/pester/pester-junit.xml` is valid only when it is 0.
- Failure outside the branch: a failing test whose file and subject are both absent from the diff from the merge base of `origin/main` and `HEAD`. The artifact names it, `EXIT_CODE:` stays non-zero, the task stays unchecked, and the executor returns the facts. Any other failure is fixed and the loop restarts from [P2-T1].

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read the recorded stage E gates under `FEATURE/evidence/qa-gates/` alone, with no suite run, and write `FEATURE/evidence/baseline/stage-e-review-recorded-gates.<timestamp>.md` as the baseline.
  - Sources: the lexicographically greatest `FEATURE/evidence/qa-gates/stage-e-powershell-test.*.md`, `stage-e-powershell-format-lint.*.md`, and `stage-e-python-typescript-gates.*.md`. `Command:` records that the artifact is a read of those files, and `EXIT_CODE:` is 0 when all three were read.
  - Output Summary: the Pester total and failed counts and the repo-wide PowerShell line percentage; the format and analyzer totals; the pytest passed and failed counts with the line and branch totals; and the Jest suite and test counts with the line and branch totals, each copied from its source.
  - Acceptance: the artifact exists and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric values. It edits no existing baseline artifact.

### Phase 1 — Remediation Edits

- [ ] [P1-T1] Close F1 in one commit with `reduction: 0005` in its subject, editing `.github/prompts/review-feature.prompt.md`, its bundle copy, `docs/engineering/process-reductions/0005-policy-read-removal.md`, and `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
  - Prompt: remove the bullet naming `phase0-instructions-read.md` as existing in the canonical baseline location from `.github/prompts/review-feature.prompt.md` and from its bundle `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md`. Every other bullet stays, including the bullet requiring each baseline command-step artifact.
  - Entry `docs/engineering/process-reductions/0005-policy-read-removal.md`: add a `### Revert Block: .github/prompts/review-feature.prompt.md` after the last existing block, with `Current` holding the removed bullet's neighbors without the bullet and `Prior` holding them with it, each with enough adjacent bullets to be unique; add a `## Files Changed` line for the prompt and one for its byte-identical bundle copy; remove the sentence beginning "Not changed, and held"; rewrite the prompt sentences of `## Reason and Evidence` per the premise correction; add the prompt to the bundle re-copy list in step 2 of `## Revert Steps`. `Prior` text of other blocks is untouched.
  - Test: add `PCW-SURFACE` row `REVIEW-PROMPT` for `.github/prompts/review-feature.prompt.md` to `$script:PolicyReadSurface` in `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` with `$surfaceForbidden`, and update the comment above the list. Asserting tests found by searching `tests` for the prompt name: `test_minor_audit_acceptance_criteria_contracts.py` names the prompt and its bundle only as paths and asserts no `phase0` text, so it is unchanged; `test_validation.py` and `test_rewrites.py` under `codex_native_converter` name the prompt as converter input and are unchanged because they assert no bullet text. The existing `PCW-SURFACE-<Id>` rows are unchanged.
  - Acceptance: `git hash-object` returns the same value for the prompt and its bundle; the token `phase0-instructions-read` appears in neither prompt copy; the new revert block exists in the entry; and [P2-T1] reports the ledger valid and the new block replaying to the parent text.
- [ ] [P1-T2] Close N1 in one commit with `reduction: 0003` in its subject, adding `tests/fixtures/orchestrator_state_remediation_loop/light_design_path_key_case_variant.json`, raising the three corpus pins, and editing `docs/engineering/process-reductions/0003-light-remediation.md`.
  - Corpus row: new `tests/fixtures/orchestrator_state_remediation_loop/light_design_path_key_case_variant.json`, a copy of `light_path_key_case_variant.json` with `name` and `notes` changed to describe the case, the cycle key `Remediation_Path` kept mis-cased, and the one finding's `scope` set to `design`. `expected_errors` holds only the invariant 2 message the sibling row holds. The row proves that a mis-cased path key makes the cycle not light in the Python, PowerShell, and TypeScript runtimes, so invariant 8 reads neither the cycle nor its design finding, and its `name` equals the file stem.
  - Pins: raise `MINIMUM_CORPUS_COUNT` from 57 to 58 in `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` and in `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts`, and `$MinimumCorpusCount` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1`.
  - Entry `docs/engineering/process-reductions/0003-light-remediation.md`: add the new file to the corpus bullet of `## Files Changed` and change "sixteen" to "seventeen" there and in step 1 of `## Revert Steps`; leave the floor of 41 in step 5. No revert block changes, because the entry's blocks hold no corpus text.
  - Asserting tests, found by searching the test tree for the corpus directory name: the three parity suites assert the floor and are updated as above; `test_orchestrator_state_light_cycle.py` is unchanged because its message coverage still holds; the two accounting suites read one named row and are unchanged.
  - Acceptance: the row file exists and parses; its `name` equals its stem; the three pins read 58; the entry names seventeen files in both places; and [P2-T2] shows the row and its stem row passing in all three suites.

### Phase 2 — Final QA

- [ ] [P2-T1] Run format and lint over the changed files, compare the mirror, replay the ledger, and write `FEATURE/evidence/qa-gates/stage-e-review-format-lint-ledger.<timestamp>.md`.
  - PowerShell: `Invoke-PoshQCFormat` check-only with a no-op `-WriteFile`, then `Invoke-ScriptAnalyzer` directly with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, over `planning-contract-wording.Tests.ps1` and `OrchestratorStateRemediationLoop.Parity.Tests.ps1`. Acceptance: an `Already formatted: ` line and no `Formatted: ` line per file, and findings number zero.
  - Python and TypeScript: Black check, Ruff check without fixing, and Pyright on `test_orchestrator_state_remediation_loop_parity.py`; Prettier check, ESLint, and `tsc` with the test project on `orchestrator-state-remediation-loop-parity.test.ts`. Acceptance: Black reports the file unchanged and every other exit is 0.
  - Mirror: one `git hash-object` value for the prompt and its bundle.
  - Ledger: `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger` is valid, and the new block of entry `0005` applied with `Invoke-ProcessReductionRevert` gives the text of `.github/prompts/review-feature.prompt.md` at the parent of the [P1-T1] commit, after line-ending normalization. The artifact states that reference and the differing-path count, which is 0.
  - `EXIT_CODE:` is non-zero when any condition fails. A failure is repaired and this task restarts.
- [ ] [P2-T2] Run the three test gates once each and write `FEATURE/evidence/qa-gates/stage-e-review-test-gates.<timestamp>.md`, leaving the coverage files on disk.
  - Pester: one `Invoke-PoshQCParallelTest` from the worktree root. Acceptance: the returned `ExitCode` is 0; the failed count in `artifacts/pester/pester-junit.xml` is zero; `PCW-SURFACE-REVIEW-PROMPT`, `ProcessReductionLedger.Tests.ps1`, the two `light_*_key_case_variant` stem and error rows, and the new row's stem and error rows pass; the repo-wide percentage from `artifacts/pester/powershell-coverage.xml` is at least 85%.
  - pytest: from the worktree root with `PYTHONPATH` set to the worktree's `packages/discovery-runtime/src`, one `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-f-coverage.json`. Acceptance: exit 0 with zero failed; `test_orchestrator_state_remediation_loop_parity.py` passes the new row; line total at least 85% and branch total at least 75%, read from the JSON totals.
  - Jest: in `extensions/drm-copilot`, one `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, leaving `extensions/drm-copilot/coverage/lcov.info` and the pytest `artifacts/python/lcov.info` on disk. Acceptance: exit 0 with zero failed; the parity suite passes the new row; line total at least 85% and branch total at least 75%.
  - No production file changed, so the per-file coverage statement is that the diff holds only test, fixture, prompt, and documentation files; figures are read from this run alone and from files, not MCP output. A failure is classified under Execution Terms; a fix restarts from [P2-T1].
- [ ] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Scope rows: this cycle touches only the two prompt copies, entries `0005` and `0003`, the `PCW-SURFACE` row, the one corpus row, the three pins, and `FEATURE`; no production source, `execution-environment` or `atomic-plan-contract` file, Epic #1019 folder, acceptance-criterion text, baseline text, or coverage-comparison text changes.
  - Acceptance: F1 and N1 each have a row naming the proving test or artifact; no row is FAIL. A FAIL row is fixed, the loop re-runs from [P2-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a half-removed requirement. [P1-T1] removes both prompt copies, adds the `PCW-SURFACE` row that fails if the token returns, and [P2-T3] maps F1 and N1 to evidence. The stale paragraph in entry `0005` is rewritten in the same commit.
- Coverage: no production file changes. The new row runs through the Python, PowerShell, and TypeScript parity suites, and [P2-T2] reads repo-wide and total figures from the single run of each gate against 85% line and 75% branch. Pester measures no branch coverage.
- Mirror parity: the prompt and its bundle are edited together in [P1-T1] and compared by hash in [P2-T1]; the contract tests in `tests/scripts/dev_tools/` that compare bundles run in CI, because the pytest gate covers them here. The cycle alters no fact the `execution-environment` brief states, so no brief-update task is needed.
- File size: the edited test files grow by a few logical lines each and stay well under 500; the new fixture is JSON; Markdown is exempt.
- Test isolation: the gates are one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, and Jest through its normal workers, each re-run only after a fix. The new row is a committed fixture read in memory; no test creates a file or sets global state.
- CI-only behavior: the fixture uses no path or drive letter and `.gitattributes` normalizes its endings. The hook-suite job runs no new row. A prompt edit is a full CI run.
- Evidence: artifacts live under `FEATURE/evidence/baseline/` and `qa-gates/` with write-time stamps and the four required fields, and record `SCRATCH`, never a host path. No artifact compares coverage with an earlier figure, and none edits a baseline.

## Test Plan

- Contract: `PCW-SURFACE-REVIEW-PROMPT` for F1; the existing ledger suites for the new block.
- Corpus, three runtimes: the new row through the Python, PowerShell, and TypeScript parity suites, and the three floors at 58.
- Gates: [P2-T2] with the single parallel run of each suite.

## Open Questions / Notes

- The reviewed head and merge base are named in `remediation-inputs.2026-11-07T13-39.md`. Any commit stales that review, so a re-review follows, and the `[E]` criterion is re-checked only after it.
