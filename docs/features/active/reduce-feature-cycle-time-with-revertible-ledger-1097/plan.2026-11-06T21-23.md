# reduce-feature-cycle-time-with-revertible-ledger - Plan (Stage A)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T21-23
- **Status:** Draft
- **Version:** 0.3

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Python (test file only): [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Stage A of `spec.md` only: the ledger, its helpers and tests, and the review-side standing rule. The criteria tagged `[A]`, decision D1, clarifications K2 and K3, and `research/research.2026-11-06.md` section 1 define it. Stage A delivers no reduction, so it adds no ledger entry, and the ledger folder holds only `README.md`.

Stage A also carries one test fix, [P1-T5]. The `[A]` criterion that `pytest -n auto` passes with zero failures cannot be met from a checkout under a `worktrees` folder while `test_execution_environment_fact_is_unchanged_across_copies` filters on absolute path parts.

Out of scope: `execution-environment` and `atomic-plan-contract` (they wait on #1094), every other stage, and every Epic #1019 feature folder.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launcher scripts live there, and artifacts record the token, never a host path.
- Tool routes come from the `execution-environment` skill and are not restated here.
- Commits: executor commits are per task. Commit and push after each task with a conventional message and the session attribution lines supplied at execution.
- Testing rule (owner's standing instruction, `spec.md` `## Testing Rule`, overriding contract text that requires otherwise): tests run in parallel only, with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. There are no single-process, seeded-shuffle, reversed-order, or comparison runs. A run of one Pester file is a single-process run, so Phase 1 and Phase 2 tasks do not run tests: their acceptance names the tests they add or change, and [P3-T2] and [P3-T3] prove those tests pass. A failure of one of those tests is a failure on the branch, as defined below.
- A task never runs an unqualified `poetry install` from the worktree. If the worktree environment cannot run a gate, stop and report. No task pushes a git tag.
- Contract modules, all under `tests/scripts/dev_tools/`: `test_push_down_issue_824_follow_ups.py`, `test_ci_gate_epic_child_contracts.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_orchestrator_state_remediation_docs.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py`.
- Reading a Pester gate: `Invoke-PoshQCParallelTest` never calls `exit`, so a launcher's process status proves nothing. `EXIT_CODE:` records the `ExitCode` property of the object it returns. `Invoke-PoshQCParallelMerge` writes the merged `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` only when every shard exits 0, so with a non-zero `ExitCode` those two files are stale or absent and are not read.
- Failure outside the branch: a failing test whose test file and subject are both absent from the branch diff from the merge base of `origin/main` and `HEAD`. The subject is the production file or state the test exercises, for example a Pester suite that reads the gitignored live checkpoint. The gate artifact names the test, its file, and its subject, and lists the paths of that diff as the proof. `EXIT_CODE:` stays non-zero, the task stays unchecked, and it is not recorded as a pass. The test is not edited and the gate is not repeated: the executor stops and returns these facts to the caller, whose decision settles the gate.
- Failure on the branch: a failing test whose test file or subject is in that diff, or whose subject cannot be shown to be outside it. It stays a failure: it is fixed, and the loop restarts from [P3-T1].

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md` for PowerShell and Python test scope, and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [x] [P0-T2] Capture the PowerShell baseline with one `Invoke-PoshQCParallelTest` run and write `FEATURE/evidence/baseline/powershell-test.<timestamp>.md`.
  - Output Summary: total and failed test counts from `artifacts/pester/pester-junit.xml`, and the repo-wide line percentage from `Get-PoshQCCoverageLineSummary` over `artifacts/pester/powershell-coverage.xml`.
  - When `ExitCode` is non-zero: read counts from `artifacts/pester/parallel/shard-<i>/pester-junit.xml`, or that directory's `shard.log` when a JUnit file is absent or truncated, take the percentage from `Merge-PoshQCCoverageReport` over the shard coverage files, and name each failing test in the artifact. The run is not repeated.
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric counts and a numeric percentage, read from files and not from MCP output.
- [x] [P0-T3] Capture the Python contract baseline with one `pytest -n auto` run over the contract modules in `tests/scripts/dev_tools/` and write `FEATURE/evidence/baseline/python-contract-tests.<timestamp>.md`.
  - Acceptance: the artifact carries the four fields, with the passed and failed counts of the run's summary in `Output Summary:`. No Python production file changes, so this baseline carries no coverage figure.

### Phase 1 — Ledger, Helpers, and Tests

- [x] [P1-T1] Create `docs/engineering/process-reductions/README.md`, documenting the entry format for agents writing entries later, with an empty index and one worked example.
  - `## Index` holds the table header `| ID | Title | Date | Issue | Status |`, its separator row, and no data rows. A data row's ID cell is a link such as `[0001](0001-short-name.md)`.
  - `## Entry Format` states the file name `NNNN-<short-name>.md`; the sections `## Summary`, `## Reason and Evidence`, `## Files Changed`, `## Prior Text` or `## Stored Patch`, `## Revert Steps`, and `## Revert Signals`; the `### Revert Block: <repository-relative path>` subsection, one per canonical file and one per non-identical copy (K2), with byte-identical mirrors re-copied instead; `Current` and `Prior` fences, labeled by the fence info string, using a fence longer than any backtick run in the text; `patches/NNNN-<short-name>.patch` for `## Stored Patch`; and the `## Summary` lines `reduction: NNNN` and `Merge commit: pending (PR #N)`, back-filled by the next stage or a final records commit.
  - `## Entry Format` also states the six `## Revert Steps` labels in order: `Apply the blocks`, `Re-copy mirrors and bundles`, `Regenerate Codex variants`, `Restore pinned hashes`, `Restore contract-test literals`, and `Run the contract tests`. The `Regenerate Codex variants` step includes running the generator `--check`, as `spec.md` `## Behavior` states. A label that does not apply stays and states "not applicable". It also states K3 (a commit that lands deferred wording updates that entry), that one-off waivers for a single item are not entries, and that a revert does not depend on `git revert`.
  - `## Worked Example` holds one complete sample entry for a hypothetical `0000-example-reduction.md` inside a single outer fence, longer than its inner fences. It is a sample, not an entry: no `0000-*.md` file is created.
  - Acceptance: the folder holds only `README.md`, and the file has the three headings above. [P1-T4] proves the index and the example against the parser.
- [x] [P1-T2] Create `scripts/dev-tools/ProcessReductionLedger.psm1` with `Get-ProcessReductionSection`, `Get-ProcessReductionRevertBlock`, and `Invoke-ProcessReductionRevert`, and add their tests to `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.
  - Module shape follows `HostBootstrapWorkspace.psm1`: comment-based help, `Set-StrictMode -Version Latest`, advanced functions, one trailing `Export-ModuleMember`, and no entry block. Pure functions take text and do no I/O. The test file imports the module with `Import-Module -Force` and removes it in `AfterAll`.
  - `Get-ProcessReductionSection -Text -Heading` returns the body of a level-two section, or `$null` when absent. It is fence-aware: a backtick fence closes only on a fence at least as long as its opener, so a `## ` line inside verbatim prior text never ends a section.
  - `Get-ProcessReductionRevertBlock -Text` returns one object per `### Revert Block:` subsection with `Path`, `Current`, and `Prior`. A fence that is absent gives `$null`, and an empty fence gives an empty string.
  - `Invoke-ProcessReductionRevert -Text -Block` converts CRLF and lone CR to LF in the live text and in both block values before comparing, because `.gitattributes` applies `* text=auto eol=lf` on checkout and an entry and its target can differ in line endings. It returns the LF text with `Current` replaced by `Prior`. It throws when `Current` is `$null`, empty, not found, or found more than once.
  - Tests, as `It` names: `PRL-SECTION-FOUND`, `PRL-SECTION-ABSENT`, `PRL-SECTION-IGNORES-FENCED-HEADING`, `PRL-BLOCK-PARSES-VERBATIM-MARKDOWN` (a four-backtick fence holding a triple-backtick fence and a `## ` line), `PRL-BLOCK-MISSING-FENCE`, `PRL-REVERT-RESTORES-PRIOR`, `PRL-REVERT-CRLF-LIVE-TEXT`, `PRL-REVERT-CRLF-BLOCK`, `PRL-REVERT-LONE-CR`, `PRL-REVERT-THROWS-WHEN-CURRENT-ABSENT`, `PRL-REVERT-THROWS-WHEN-CURRENT-EMPTY`, and `PRL-REVERT-THROWS-WHEN-CURRENT-REPEATS`.
  - CRLF inputs are built in memory from `` `r`n `` strings, not from fixture files.
  - Acceptance: the module exports the three functions, the test file holds the twelve `It` names, and [P3-T2] reports them passing.
- [x] [P1-T3] Add `Test-ProcessReductionEntry` to `scripts/dev-tools/ProcessReductionLedger.psm1` and its tests to `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.
  - `Test-ProcessReductionEntry -Name -Text` returns `IsValid`, `Errors`, and `PatchPath`. It requires each named section to be present and non-blank, and either `## Prior Text` or `## Stored Patch`.
  - `## Prior Text` needs at least one revert block, and every block needs a non-empty `Current` and a present `Prior`. An empty `Prior` is valid, because a reduction may add text. `## Stored Patch` must name `patches/<entry stem>.patch`, returned as `PatchPath`.
  - `## Summary` must carry `reduction: NNNN` with the number of `-Name`, and exactly one line beginning `Merge commit:` that matches either `Merge commit: pending (PR #N)` with `N` a positive integer, or a 7-to-40-character lowercase hexadecimal commit identifier.
  - `## Revert Steps` must name the six labels of [P1-T1] in order, compared case-insensitively.
  - Tests, as `It` names: `PRL-ENTRY-COMPLETE`; `PRL-ENTRY-MISSING-SECTION` and `PRL-ENTRY-EMPTY-SECTION`, each driven over every required section; `PRL-ENTRY-NO-PRIOR-TEXT` (neither section); `PRL-ENTRY-PRIOR-TEXT-WITHOUT-BLOCK`; `PRL-ENTRY-BLOCK-WITHOUT-PRIOR`; `PRL-ENTRY-EMPTY-PRIOR-ACCEPTED`; `PRL-ENTRY-STORED-PATCH-ACCEPTED`; `PRL-ENTRY-STORED-PATCH-WRONG-NAME`; `PRL-ENTRY-TOKEN-MISMATCH`; `PRL-ENTRY-MERGE-PENDING-ACCEPTED`; `PRL-ENTRY-MERGE-RESOLVED-ACCEPTED`; `PRL-ENTRY-MERGE-MALFORMED-REJECTED`; `PRL-ENTRY-REVERT-STEP-MISSING`; and `PRL-ENTRY-REVERT-STEP-ORDER`.
  - `PRL-ENTRY-MERGE-MALFORMED-REJECTED` is driven over at least these values: `pending`, `Pending (PR #12)`, `pending (PR 12)`, `pending (#12)`, `pending (PR #N)`, `pending (PR #12) later`, and an absent line.
  - Acceptance: the module exports the function, the test file holds the fifteen `It` names, and [P3-T2] reports them passing.
- [x] [P1-T4] Add `Test-ProcessReductionIndex`, `Read-ProcessReductionLedger`, and `Test-ProcessReductionLedger` to `scripts/dev-tools/ProcessReductionLedger.psm1`, with the index and real-ledger tests in `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.
  - `Test-ProcessReductionIndex -IndexText -EntryName` returns `IsValid`, `Errors`, and `RowCount`. It accepts an empty `-EntryName`, reads only `## Index`, and fails when that section or its exact header row is absent. It also fails on a malformed row, a row with no entry file, an entry file with no row, an entry name outside `NNNN-<short-name>.md`, a link label that differs from the file number, and a repeated number.
  - `Read-ProcessReductionLedger -LedgerPath` is the one read seam. It returns `IndexText`, `Entries` (each with `Name` and `Text`, for every top-level `*.md` file except `README.md`), and `PatchNames` (from `patches/`, empty when that folder is absent). It throws when the folder or `README.md` is absent, and it writes nothing.
  - `Test-ProcessReductionLedger -Ledger` is pure. It returns `IsValid`, `Errors`, and `RowCount`, runs the index check, runs the entry check on every entry, and reports a `PatchPath` absent from `PatchNames`. The real ledger and the in-memory failing cases go through this one function, so the iteration is proven even while the ledger is empty.
  - Tests, as `It` names: `PRL-INDEX-EMPTY-AGREES`, `PRL-INDEX-AGREES`, `PRL-INDEX-ROW-WITHOUT-FILE`, `PRL-INDEX-FILE-WITHOUT-ROW`, `PRL-INDEX-MISSING-TABLE`, `PRL-INDEX-MALFORMED-ROW`, `PRL-INDEX-BAD-ENTRY-NAME`, `PRL-INDEX-LABEL-MISMATCH`, `PRL-INDEX-REPEATED-NUMBER`, `PRL-LEDGER-INCOMPLETE-ENTRY-FAILS`, `PRL-LEDGER-MISSING-PATCH-FAILS`, `PRL-LEDGER-COMPLETE-PASSES`, `PRL-READ-THROWS-ON-MISSING-FOLDER`, `PRL-REAL-LEDGER-AGREES`, and `PRL-README-EXAMPLE-IS-VALID`.
  - `PRL-REAL-LEDGER-AGREES` reads the committed folder read-only, passes it to `Test-ProcessReductionLedger`, and asserts `IsValid` true and `RowCount` equal to the number of entries, which holds at zero. It cannot pass vacuously: `PRL-INDEX-MISSING-TABLE` proves a README without the table fails, and `PRL-LEDGER-INCOMPLETE-ENTRY-FAILS` proves in memory that an incomplete entry fails the same function.
  - `PRL-README-EXAMPLE-IS-VALID` takes `## Worked Example` from the real README, removes the outer fence, passes the text to `Test-ProcessReductionEntry` as `0000-example-reduction.md`, and replays its first revert block through `Invoke-ProcessReductionRevert` on an in-memory string holding `Current`.
  - In-memory fixtures only: no test creates a file. Repository paths use `Join-Path` with forward-slash relative segments.
  - Acceptance: the module exports all seven functions, the test file holds the fifteen `It` names, and [P3-T2] reports them passing.
- [x] [P1-T5] Change the copy filter of `test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` to test `path.relative_to(REPO_ROOT).parts` in place of `path.parts`.
  - Behavior: the excluded names apply only below the repository root, so a checkout under a `worktrees` folder keeps its six copies, while a worktree nested inside a checkout stays excluded. The excluded name set, the existing comment, and both assertions stay as they are.
  - The longer expression exceeds the 88-column limit, so the edit is written in Black's wrapped form.
  - This is the only test that asserts the filter, and no other test file reads it. No other Python test in `tests/` filters absolute path parts on `worktrees`.
  - Acceptance: the test still asserts six byte-identical copies, and [P3-T3] reports it passing.

### Phase 2 — Review-Side Standing Rule

- [x] [P2-T1] Add a `### Process-reduction ledger` subsection to `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, and their three bundled copies under `extensions/drm-copilot/resources/`, and pin it in `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.
  - Bundled copies: `claude-customizations/.claude/skills/...`, `codex-and-agents-customizations/.agents/skills/...`, and `customizations/.github/skills/...`.
  - Placement: under `## Workflow Contract`, immediately after `### No silent fixes` and before `### Work-mode acceptance-criteria contract`. That anchor is the same in all six copies, it stays outside step 8, and it stays before `## Policy Rules`, which only the `.claude` and `.agents` copies have.
  - Text, identical in all six: the rule applies only when `docs/engineering/process-reductions/` exists, so a repository without that folder is unaffected. A change that reduces evidence, plan tasks, gates, or review process adds its ledger entry in the same commit, in the format of that folder's `README.md`. A branch diff that makes such a reduction with no entry is a Blocking finding. The reviewer confirms from the branch log that each reduction is its own commit, with the `reduction: NNNN` token in its subject. `One-off waivers for a single item are not entries.`
  - The three `.claude`, `.agents`, and `.github` copies differ from each other, so each takes a hand edit. Each bundled copy stays byte-identical to its source.
  - New tests: `PRL-RULE-STATED-IN-EVERY-COPY`, driven over the six paths with an inline `-ForEach` table because Pester evaluates that data at discovery. Over whitespace-normalized text it asserts `` `docs/engineering/process-reductions/` exists ``, `One-off waivers for a single item are not entries.`, and `reduction: NNNN`. `PRL-RULE-BUNDLE-PARITY` is driven over the three source and bundle pairs; the `.github` pair has no other parity test.
  - Existing pins of these copies, all unchanged because the insertion alters no pinned fragment, count, or heading order:
    - `test_push_down_issue_824_follow_ups.py`: `test_review_workflow_step_eight_uses_governing_thresholds`, `test_feature_review_texts_name_claude_md_floor_source`, `test_precedence_copy_states_per_metric_fallback`, `test_every_follow_up_copy_exists`, and `test_pushed_rule_and_skill_files_match_pinned_name_counts`.
    - `test_ci_gate_epic_child_contracts.py`: `test_review_rule_defines_satisfiable_qualifying_run`, `test_review_rule_drops_sha_exact_definition`, `test_agents_review_rule_sits_before_ordered_procedure`, and `test_agents_review_rule_carries_codex_bullets`.
    - `test_push_down_tier_rule_adoption_gate.py`: `test_feature_review_copy_gates_tier_finding` and `test_every_scanned_copy_exists`.
    - `test_orchestrator_state_remediation_docs.py`: `test_docs_documents_classify_mcp_contract_lag`.
    - `test_push_down_claude_resource_contracts.py`: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. `test_push_down_codex_and_agents_resource_contracts.py`: `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`. Both pass only if the bundled copies change with their sources.
    - The two pack-manifest completeness modules are unchanged: no file is added to the bundle.
  - Acceptance: all six copies carry the subsection, the test file holds both `It` names, and [P3-T2] and [P3-T3] report these tests passing.

### Phase 3 — Final QA

- [x] [P3-T1] Run the PowerShell format and lint stages over `scripts/dev-tools/ProcessReductionLedger.psm1` and `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` and write `FEATURE/evidence/qa-gates/powershell-format-lint.<timestamp>.md`, then run the Python format, lint, and type stages over `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` and write `FEATURE/evidence/qa-gates/python-format-lint-type.<timestamp>.md`.
  - Format runs `Invoke-PoshQCFormat` check-only, with a no-op `-WriteFile`, over `scripts/dev-tools` and `tests/scripts/dev-tools`. Lint runs `Invoke-ScriptAnalyzer` directly on the two files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Type checking does not apply to PowerShell.
  - The Python stages run Black in check mode, Ruff without fixing, and Pyright on that one test file. All three are read-only, so each one's exit status distinguishes a clean file from a defective one.
  - Acceptance: the PowerShell log holds an `Already formatted: ` line and no `Formatted: ` line for each of the two files, and analyzer findings number zero. Black, Ruff, and Pyright each exit 0 on the Python test file. `EXIT_CODE:` in each artifact is non-zero when any of its conditions fails. A failure is repaired and this task restarts.
- [ ] [P3-T2] Run one `Invoke-PoshQCParallelTest` gate and write `FEATURE/evidence/qa-gates/powershell-test.<timestamp>.md`, with the coverage comparison read from `artifacts/pester/powershell-coverage.xml`.
  - Output Summary: total and failed counts from `artifacts/pester/pester-junit.xml`; the test count of the `ProcessReductionLedger.Tests.ps1` suite; baseline and post-change repo-wide line percentages from `Get-PoshQCCoverageLineSummary`; and the covered and missed figures of the `LINE` counter of the `sourcefile` element named `ProcessReductionLedger.psm1`, with the percentage derived from them. The merged report holds no `class` element, because `Merge-PoshQCCoverageReport` removes them.
  - The presence of that `sourcefile` element confirms the module joined the coverage population: `Get-PoshQCCoverageFileSet` derives it from the `scripts` root in `config/poshqc-coverage.json`, with no hand-maintained list.
  - When `ExitCode` is non-zero: the merged files are not read. Counts, the suite count, and failing test names come from `artifacts/pester/parallel/shard-<i>/pester-junit.xml`, or that directory's `shard.log` when a JUnit file is absent or truncated. The repo-wide percentage and the `sourcefile` figures come from `Merge-PoshQCCoverageReport` over the shard coverage files, held in memory. A figure that no shard file can supply is stated as unavailable.
  - Acceptance: the returned `ExitCode` is 0, failed tests number zero, the suite count is above zero, module line coverage is at least 85%, and the repo-wide percentage is at least 85% and is stated beside the [P0-T2] figure. No existing PowerShell file changes, so changed-line regression does not apply, and a new file above the threshold can still move the total slightly. `EXIT_CODE:` is non-zero when any condition fails. No figure comes from MCP output. Each failing test is classified under Execution Terms as a failure on the branch or a failure outside the branch, and is handled as that term states.
- [ ] [P3-T3] Run one full `pytest -n auto` gate from the worktree root over `tests/` and write `FEATURE/evidence/qa-gates/python-test.<timestamp>.md`.
  - Acceptance: the process exit is 0 and the artifact records the passed and failed counts of the summary, with failed at zero. `test_execution_environment_fact_is_unchanged_across_copies` is absent from the run's failure list, and the artifact states that outcome. `EXIT_CODE:` records the process exit. Each failing test is classified under Execution Terms as a failure on the branch or a failure outside the branch, and is handled as that term states.
- [ ] [P3-T4] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - This task starts only when [P3-T2] and [P3-T3] are checked or the caller has directed it to continue past a failure outside the branch. In that case the row for the `[A]` test-gate criterion is N/A, not PASS, and names the failing test and the caller's decision.
  - Scope rows: the diff is limited to `docs/engineering/process-reductions/README.md`, the module, its test file, `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, the six skill copies, and `FEATURE`. It holds no `execution-environment` or `atomic-plan-contract` file, no Epic #1019 feature folder, and no ledger entry file.
  - Acceptance: every `[A]` criterion in `spec.md` has a row naming its proving test or artifact, and no row is FAIL. A FAIL row is fixed, the QA loop re-runs from [P3-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a spec rule with no falsifying test, the class recorded in research section 7. Each `[A]` criterion and each D1 rule maps to named tests, including the revert-step order and the exact pending form, and [P3-T4] walks all three templates. The `modified-workflow-needs-green-run` rule does not fire because no workflow path changes.
- Coverage: `ProcessReductionLedger.psm1` is a new file, so all of it counts as changed. It has no entry block, and the read seam is exercised by the real read and by the missing-folder throw. [P3-T2] reads the `sourcefile`-level `LINE` counter from the Pester coverage file, because MCP output carries no counts. Branch coverage does not apply to PowerShell. No Python or TypeScript production file changes: [P1-T5] edits a test file, which is outside the coverage denominator, so it adds no Python coverage task.
- Mirror parity: all six `feature-review-workflow` copies change in [P2-T1], with `PRL-RULE-BUNDLE-PARITY` covering the `.github` pair that no existing test covers; no `.claude-variants` or `.agents-variants` copy of this skill exists. Stage A alters no fact the `execution-environment` brief states, so no brief task is needed. Under K6, the brief's `## Test Isolation Checks` still lists serial runs while this plan runs parallel only; that brief update is deferred to stage E, after #1094 merges.
- File size: the module is expected near 300 lines and the test file near 450, both under the 500-line guidance tier. If the test file reaches 500, the index and real-ledger tests move to `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, and that file then joins every later reference to the test file, including [P3-T1], the [P3-T2] suite count, and the [P3-T4] scope row. [P1-T5] adds about two lines to a 460-line test file, which stays under 500. Markdown is exempt.
- Test isolation: by the owner's standing instruction, recorded in the `spec.md` `## Testing Rule` and overriding the seeded and reversed runs the contract lists (#1094 is changing that contract text), the isolation runs are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run. The tests create no temporary files, set no global state, and remove the module in `AfterAll`. The real-ledger and skill-text reads are read-only. [P1-T5] removes a dependence on the checkout's parent path, and its test adds no state. A failure outside the branch, such as a suite that reads gitignored state, is reported under Execution Terms and is neither hidden nor counted as a pass.
- CI-only behavior: `.gitattributes` rewrites a committed CRLF fixture, so CRLF inputs are built in memory. [P1-T5] keeps the same six copies on a CI checkout, whose parent path holds none of the excluded names, and on a local worktree. The suite runs on the Windows `poshqc` shards, the new test file is assigned to a shard automatically, and no test reads `artifacts/`. `docs/engineering/` is outside `config/ci-docs-only-paths.json`, so the PR takes a full run. The evidence-only final commit does not narrow that run: `ci.yml` has no feature-branch push trigger, so the first PR run compares against the merge base and finds code changes.
- Evidence: artifacts live under `FEATURE/evidence/baseline/` and `FEATURE/evidence/qa-gates/`, carry the four required fields, name files with write-time stamps, and record no host path. The merged coverage XML holds absolute package names, so figures are copied and the XML is not. `EXIT_CODE:` carries each acceptance value, including the returned `ExitCode` of the parallel run.

## Test Plan

- Unit: `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, with in-memory fixtures for every behavior named in [P1-T2], [P1-T3], and [P1-T4].
- Integration: `PRL-REAL-LEDGER-AGREES` and `PRL-README-EXAMPLE-IS-VALID` read the committed ledger, and `PRL-RULE-STATED-IN-EVERY-COPY` and `PRL-RULE-BUNDLE-PARITY` read the six copies. All are read-only.
- Changed test: `test_execution_environment_fact_is_unchanged_across_copies`, proven by [P3-T3].
- Manual/CLI: none.
- Coverage evidence: baseline `FEATURE/evidence/baseline/powershell-test.<timestamp>.md`; post-change and comparison `FEATURE/evidence/qa-gates/powershell-test.<timestamp>.md`. Python carries no coverage task because no Python production file changes.

## Open Questions / Notes

These are design choices this plan makes where the spec is silent. A reviewer should confirm them.

- `Read-ProcessReductionLedger` is the read seam named in research section 1, and `Test-ProcessReductionLedger` is added to the five functions the spec lists, so the real-entry iteration has a failing case on an empty ledger.
- `Current` and `Prior` fences are labeled by the fence info string.
- `Invoke-ProcessReductionRevert` also throws on an empty or repeated `Current`, because replacing an arbitrary match would be a silent wrong revert. It returns LF text.
- An empty `Prior` is valid, so a reduction that added text can be reverted.
- The six `## Revert Steps` labels are enforced, because the spec says the section names those steps in order.
- The review rule adds a Blocking finding and the branch-log check, which D1 assigns to the reviewer.
- Task [P1-T5] edits a test outside the spec's Stage A file set, because the `[A]` test-gate criterion is otherwise unsatisfiable from a worktree.
