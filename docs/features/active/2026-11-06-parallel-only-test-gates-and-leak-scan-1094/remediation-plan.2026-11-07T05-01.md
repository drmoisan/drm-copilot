# parallel-only-test-gates-and-leak-scan - Remediation Plan

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T05-01
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Remediation-Mode:** design
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094
- **Inputs:** `remediation-inputs.2026-11-07T05-01.md` in this folder (RF-6)

## Required References

- Policy order: `policy-compliance-order`. PowerShell is the changed language in this cycle. `.claude/rules/python.md` applies to the Python gate.
- Requirements: `spec.md`, and the `policy-audit`, `code-review`, and `feature-audit` artifacts stamped `2026-11-07T05-01` in this folder.
- Tool routes, launchers, command-text restrictions, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`. `SCRATCH` resolves to `<session scratchpad>/issue-1094/`, and every helper, JUnit file, JSON report, log, and saved file lives under it. Evidence records the token, never a host path. The merge base is the merge base of `origin/main` and `HEAD`. The record is the text `N/A - no pre-change run`. The Claude hook is `.claude/hooks/validate-feature-review-coverage.ps1`, which dot-sources `.claude/hooks/validate-feature-review-coverage-rules.ps1`. The Codex hook is `.codex/hooks/validate-feature-review-coverage.ps1`. The Claude bundle copy is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-rules.ps1`. The Codex bundle copy is `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1`.

- **Working directory.** Every `poetry` and `git` command, every PoshQC call, and every hook run starts from the item worktree root. A launcher changes into that folder before its first command, because the Bash working directory resets to the main checkout.
- **Commit and push.** Each task ends with one commit and one push to `feature/parallel-only-test-gates-and-leak-scan-1094`. The executor stages only the paths the task names, plus the evidence it writes and this plan. `.claude/agent-memory` is never staged.
- **`testResults.xml`.** Pester runs rewrite this tracked file. Restore it with `git checkout -- testResults.xml` before staging.
- **Poetry.** Do not run an unqualified `poetry install` from the item worktree.
- **New code.** Hook code and helpers are PowerShell. Helpers are step scripts under `SCRATCH`. No new Python file is written, and no enforcement hook invokes Python.
- **Parallel gates only (owner directive).** The gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix. No task performs a test run of any other form, and a task that adds a test is accepted on the test's content. Phase 2 proves the pass result.
- **Gate failures.** A failure is fixed, the static stages re-run, and the failed gate re-runs. Another gate re-runs only when the fix changes a file it exercises. A fix that changes a hook file also re-runs P2-T3. A failure whose test file and subject are both absent from the diff from the merge base is named, with that diff as proof; `EXIT_CODE:` stays non-zero, the task stays unchecked, and the executor stops for the caller. No condition waives a failure.
- **Hook mirrors.** A task that edits a hook copies it to its bundle in the same task, so each bundle copy equals its source when the task ends.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and `EXIT_CODE:` goes non-zero when the task's asserted value fails. Evidence prose does not use the tokens P2-T6 scans for.
- **Scope.** Do not edit the policy-audit template or its bundle copy, any `feature-review-workflow` skill copy, criterion 9 or any other acceptance criterion, `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, `scripts/dev_tools/validate_policy_audit_artifact.py`, `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, `.github/workflows/`, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, `pyproject.toml`, or the Python tools in spec `### 2. Out of scope`. Do not remove a tool-permission entry. Do not add a leak scan. This plan contains no PR, CI-monitoring, or merge task.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Static Baseline

No test suite runs in this phase.

- [x] [P0-T1] Read the policy files in the `policy-compliance-order` order, including `.claude/rules/powershell.md` and `.claude/rules/python.md`, then the inputs and the three audit artifacts, and write `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - The artifact also carries `Cycle-Start:` with the `HEAD` value at this task's start. P2-T6 uses it.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, `Cycle-Start:`, and the list of files read.
- [x] [P0-T2] Capture the PowerShell static baseline for `.claude/hooks/validate-feature-review-coverage-rules.ps1` and `.codex/hooks/validate-feature-review-coverage.ps1` in `<FEATURE>/evidence/remediation-baseline/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/remediation-baseline/powershell-analyze.<timestamp>.md`.
  - Format runs check-only through the no-op `-WriteFile` seam on the branch-current module. Analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `Output Summary:` states the would-format count and the finding count as numbers, and `git status --porcelain` shows no tracked file changed by the step.

### Phase 1 — Hook Fix and Spec Note

- [x] [P1-T1] Add the function `Get-CoverageNarrowingLine` to `.claude/hooks/validate-feature-review-coverage-rules.ps1`, call it from `Test-LanguageCoverageRow`, copy the file to the Claude bundle copy, and add the function to the rules-file `Functions` row of `E4-ST4` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
  - The function takes `-Lines`, `-LabelPattern`, and `-Language`, and returns the original text of each narrowing line. `-Lines` accepts empty strings, because audit text holds blank lines. It holds the current `$narrowingPattern` loop, with the pattern text unchanged, so `\bN/A\b` stays. It keeps the `## Rejected Scope Narrowing` section tracking and the PowerShell branch-line exception.
  - The label and coverage tests read the original line. The narrowing test reads the line after the removals below, each case-sensitive:
    - The record is removed only in these three positions, an allow-list, and stays everywhere else:
      - After `Baseline:` or `baseline coverage artifact:`, by `(?<=(?:\bBaseline|\bbaseline coverage artifact):\s*)N/A - no pre-change run`.
      - As the fifth table cell, by `(?<=^\s*\|(?:[^|]*\|){4}\s*)N/A - no pre-change run(?=\s*\|)`.
      - As a backticked quotation not directly after a colon, by ``(?<!:\s*)`N/A - no pre-change run` ``.
    - Only on a line that carries `Baseline: N/A - no pre-change run`, the text `Change: N/A` is removed where no word character, `-`, or `/` precedes it, and the text `New/changed-code coverage: N/A - no production file changed` is removed.
  - The condition of the second bullet is tested on the original line, because the first bullet strips the record it names. Nothing else is removed, so `Post-change: N/A`, `Disposition: N/A`, and every other narrowing form still match. `## Open Questions / Notes` records why the `New/changed-code coverage` removal is here.
  - The function uses no call operator, which the enforcement-hook invocation scan rejects, and it holds none of the retired floor figures that `E4-ST7` rejects in the Codex twin. The file's synopsis and description name the new function.
  - Existing tests, each unchanged because none of its inputs holds the removed text: `E4-CORPUS-1` to `E4-CORPUS-4` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, `fails when a coverage row narrows scope` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, `F824-6 rejects a coverage row that narrows scope` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, and `E4-PX1` in `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1`.
  - Existing test, updated: `E4-ST4: <File> defines exactly its assigned functions` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, because the rules file gains a function and that row pins the file to exactly its assigned functions.
  - Acceptance: the file defines `Get-CoverageNarrowingLine`, `Test-LanguageCoverageRow` holds no narrowing loop of its own, the file still holds the unchanged pattern text, the rules-file `E4-ST4` row lists `Get-CoverageNarrowingLine`, and the bundle copy equals its source by hash.
- [x] [P1-T2] Add a byte-identical `Get-CoverageNarrowingLine` to `.codex/hooks/validate-feature-review-coverage.ps1`, call it from `Test-LanguageCoverageRow`, correct the `.NET` label, update the description, and copy the file to the Codex bundle copy.
  - The call replaces the `$coverageLines | Where-Object` narrowing filter. The Codex hook therefore gains the `## Rejected Scope Narrowing` skip and the PowerShell branch-line exception, so both hooks behave the same. `feature-review-workflow` requires that section to quote caller text verbatim, so an audit that follows the skill would otherwise pass one hook and fail the other.
  - In the Codex `$languageLabelMap`, the `CSharp` entry `'\.NET'` becomes `'.NET'`, the value the Claude map holds. The map passes each label through `[regex]::Escape`, so the current value matches a literal backslash and the Codex hook does not read a `.NET` line that the Claude hook reads.
  - The `.DESCRIPTION` narrowing paragraph states that the record in the three positions of P1-T1, and `Change: N/A` on a line carrying `Baseline: N/A - no pre-change run`, are not narrowing.
  - Existing tests, each unchanged: the `reports <Case>` row `a narrowing row`, `E4-ST7`, and the entry-point cases in `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`. Their inputs hold no rejected-section heading, no removed text, and no `.NET` text.
  - Acceptance: the function's definition text is equal in `.claude/hooks/validate-feature-review-coverage-rules.ps1` and the Codex hook, the Codex `CSharp` labels equal the Claude `CSharp` labels, and the bundle copy equals its source by hash.
- [x] [P1-T3] Create `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`, which runs one case table against both hooks.
  - The suite follows `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1`: the same `BeforeAll` baseline mocks, and each hook dot-sourced in its own child scope. It creates no temporary file, so it also runs in the Linux hook-suite job.
  - `FRN-ACCEPT`, one `It` per surface and case, 16 in all. The audit text is the case line plus `<Language> coverage PASS`, and `Test-LanguageCoverageRow` returns `Ok` true. Cases:
    - `- PowerShell baseline coverage artifact: N/A - no pre-change run` and the TypeScript form.
    - The template comparison line filled for PowerShell, TypeScript, and Python: `- <Language>: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: <path>.`
    - The Python comparison line with `New/changed-code coverage: N/A - no production file changed`.
    - A table row whose fifth cell is the record, with `Pester` in the row so the coverage test reads it.
    - The Python row `| **Comprehensive Coverage** | ✅ PASS | Both validators are pinned for the `N/A - no pre-change run` record: two Python tests. |`. The suite builds the check mark with `[char]0x2705`, so the test file stays ASCII and the analyzer's encoding rule does not fire.
  - `FRN-REJECT`, one `It` per surface and case, 22 cases and 44 `It` blocks in all. `Ok` is false and `Reason` matches `narrows scope`. Cases:
    - `Python coverage N/A`, `Python coverage N/A - out of scope`, `- PowerShell post-change coverage artifact: N/A - out of scope`, `TypeScript coverage PASS (not applicable)`, `Python coverage UNVERIFIED`, and `Python coverage PASS (informational only)`.
    - `Change: N/A` on a comparison line with a numeric baseline.
    - A line carrying the record with `Post-change: N/A`, with `Disposition: N/A`, and with `New/changed-code coverage: N/A - out of scope`.
    - `python coverage baseline: n/a - no pre-change run`, `- Python post-change coverage artifact: N/A - no pre-change run`, and a comparison line with `Post-change: N/A - no pre-change run`.
    - `New/changed-code coverage: N/A - no production file changed` on a line with a numeric baseline.
    - `Python coverage N/A - no pre-change run`.
    - `Change: N/A - no pre-change run` on a Python comparison line with a numeric baseline.
    - The Python comparison line carrying the record at `Baseline:`, once with `New/changed-code coverage: N/A - no pre-change run` and once with `Disposition: N/A - no pre-change run`.
    - `- Python Post-change coverage: N/A - no pre-change run` and `- Python coverage **Post-change:** N/A - no pre-change run`.
    - A table row whose sixth cell is the record, with `Pester` in the row so the coverage test reads it.
    - For `CSharp`, the audit text `.NET coverage N/A` with `C# coverage PASS`. Before the P1-T2 label correction the Codex hook accepts this text.
  - `FRN-SECTION`, 4 in all. Per surface, a narrowing line under `## Rejected Scope Narrowing` and a PowerShell branch line are not reported as narrowing.
  - `FRN-PARITY`, one `It`. An AST read of both hook files shows equal `Get-CoverageNarrowingLine` definition text after line-ending normalization.
  - Acceptance: the file holds the four test groups with these counts, 65 `It` blocks in all. P2-T4 proves the pass result.
- [x] [P1-T4] Add one bullet at the end of `## Constraints & Risks` in `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md`.
  - The bullet states that a narrow hook change was required, that this item is therefore no longer text and contract tests only, and that this statement supersedes the text-only wording in `## Overview`, `### 2. Out of scope`, and `## Implementation Strategy`. It names both hooks, their bundle copies, and RF-6, and it states that the validators stay unchanged.
  - Acceptance: `git diff HEAD -- <FEATURE>/spec.md`, taken before this task's commit, shows one added line and no removed line, and no line under `## Acceptance Criteria` changes.

### Phase 2 — Hook Proof, Final QA Toolchain, and Self-Review

Static stages and the hook proof run first, so that a suite is not re-run for a formatting or rule change. Each pass writes new artifacts.

- [x] [P2-T1] Run format and analyze for `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, and `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` on the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`, and write `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md`, `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md`, and `<FEATURE>/evidence/qa-gates/codex-generator.<timestamp>.md`.
  - Format output carries `Already formatted:` and `Formatted:` lines. A `Formatted:` line means a file changed: copy any changed hook to its bundle, commit, and repeat this task.
  - Acceptance: zero `Formatted:` lines, a non-zero `Already formatted:` count, zero analyzer findings, and generator exit 0, with `EXIT_CODE:` carrying each.
- [x] [P2-T2] Fill the template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` by the table below into `<FEATURE>/evidence/qa-gates/hook-proof-audit.<timestamp>.md`, validate it, and write `<FEATURE>/evidence/qa-gates/hook-proof-validators.<timestamp>.md`.
  - A step script applies the table in order, so a third party obtains the same text. The file is committed.

    | Template text | Filled text |
    |---|---|
    | The instruction block, from the first `>` line to the line before the first `---` | Removed |
    | The `Bash` and `JSON` rows of the metrics table | Removed |
    | The `Python` row of the metrics table | Kept, and a copy with the first cell `TypeScript` follows it |
    | `[Component Name]` | `hook proof` |
    | The comparison bullet beginning `- [Language]:` | Three bullets, for `Python`, `PowerShell`, and `TypeScript` |
    | `[N]% or` plus the backticked out-of-scope text | `90%` |
    | `[N]% [unit]` | `90% lines` |
    | The post-change artifact placeholders | `coverage/lcov.info` for TypeScript, `artifacts/pester/powershell-coverage.xml` for PowerShell |
    | `[section reference or artifact path]` | `Section 1.2.1` |
    | `[artifact path(s)]` | `artifacts/python/lcov.info` for Python, `artifacts/pester/powershell-coverage.xml` for PowerShell, `coverage/lcov.info` for TypeScript |
    | A status pair such as `[✅/❌/N/A] [PASS/FAIL/N/A]` | `✅ PASS` |
    | Any other bracket holding `✅` | `✅` |
    | `[PASS/FAIL/N/A]` | `PASS` |
    | `[N]%`, `[X]%`, and `[Y]%` | `90%` |
    | `[N]` and `[N/A]` | `1` |
    | Every remaining bracketed placeholder | `filled` |

  - The retained record lines stay as the template wrote them.
  - Validation is the branch-current `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <path>`, with `PYTHONPATH` set as in P2-T5, and the `mcp__drm-copilot__validate_orchestration_artifacts` tool with `artifact_type` `policy-audit` for the TypeScript twin. The artifact records the tool result in `MCP-Validator:`.
  - Acceptance: the filled file holds `N/A - no pre-change run` and no `[N]`, the Python command exits 0, the MCP tool reports no error, and `EXIT_CODE: 0` carries both.
- [x] [P2-T3] Run the real Claude hook and the real Codex hook from the item worktree on three fixed cases, and write `<FEATURE>/evidence/qa-gates/hook-proof.<timestamp>.md`.
  - Run each hook as its own PowerShell 7 process with the registered form, `pwsh -NoProfile -File <repository-relative hook path>`, and the payload on standard input.
  - The step script saves `artifacts/pr_context.summary.txt` under `SCRATCH`, replaces it, and restores it in a `finally` block, so both hooks evaluate all three languages. Without this file each hook exits 0 before reading a coverage row. The content is:
    - `- .claude/hooks/validate-feature-review-coverage-rules.ps1 (+1/-0)`
    - `- scripts/dev_tools/validate_policy_audit_artifact.py (+1/-0)`
    - `- extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts (+1/-0)`
  - Each case writes `policy-audit`, `code-review`, and `feature-audit` files, sharing one stamp, under `<FEATURE>/hook-proof/`, and replaces the previous case. Each file gets a new write time, because the Codex hook selects the newest `policy-audit.*.md` under `docs/features/active`. The step asserts that the case file is that newest file. The step removes `<FEATURE>/hook-proof/` in the same `finally` block.
    - Case A, stamp `2026-11-07T00-00`: the audit is the latest `hook-proof-audit.*.md`. `code-review` and `feature-audit` hold the text `stub`.
    - Case B, stamp `2026-11-07T04-20`: byte copies of the three review artifacts with that stamp, the audit the inputs report as exiting 2.
    - Case C, stamp `2026-11-07T00-00`: Case A with the final line `- Python coverage N/A`. This is the rejection control: it shows that each hook reads the case file and that its pass result can fail.
  - The payload is one JSON object: `session_id` `issue-1094-hook-proof`, `hook_event_name` `SubagentStop`, `agent_type` `feature-review`, `stop_hook_active` false, and `last_assistant_message` with one `policy-audit-path:`, `code-review-path:`, and `feature-audit-path:` line per case, each a repository-relative path.
  - The Codex hook blocks with exit 0 and a JSON object on stdout, so the step reads both exit code and stdout for each run:

    | Case | Claude hook | Codex hook |
    |---|---|---|
    | A | exit 0, empty stderr | exit 0, empty stdout |
    | B | exit 0, empty stderr | exit 0, empty stdout |
    | C | exit 2, stderr holds `narrows scope` | exit 0, stdout `decision` is `block`, and its `reason` holds `narrows scope` |

  - The artifact records one row per run, the payload, the summary lines, the SHA-256 of the two hooks and of `.claude/hooks/validate-feature-review-coverage-rules.ps1`, and the hash of each case audit. For the Codex hook it records the `decision` value and the `narrows scope` result, never the `reason` text, because that text carries an absolute path.
  - Acceptance: `EXIT_CODE: 0` from a step that exits non-zero on any cell that differs, and `git status --porcelain` lists neither `<FEATURE>/hook-proof/` nor any tracked change from the step.
- [ ] [P2-T4] Run the Pester gate with one background `Invoke-PoshQCParallelTest` run and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`.
  - The launcher exits with `.ExitCode`, which is read first. Counts come from the merged `artifacts/pester/pester-junit.xml`, and coverage from `artifacts/pester/powershell-coverage.xml`. A failed run can leave older merged files, so each file's write time must not precede the run start. On a non-zero `ExitCode`, failure detail comes from `artifacts/pester/parallel/shard-<i>/`.
  - Per-file line coverage comes from the `LINE` counter of each `sourcefile` element: `validate-feature-review-coverage-rules.ps1` under the package ending `.claude/hooks`, and `validate-feature-review-coverage.ps1` under the package ending `.codex/hooks`. Two sourcefiles share the second name, so the package selects the file.
  - Acceptance: `EXIT_CODE: 0`, zero failed tests, 65 `FRN-` testcases, each hook file at or above 85% line coverage, and repo-wide line coverage at or above 85%. `Output Summary:` states the counts and the three percentages. If a hook file is below 85%, the step exits non-zero, a test is added for the uncovered lines, and this task repeats.
- [ ] [P2-T5] Run the pytest gate with one background `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov` run, with `PYTHONPATH` set for that run to the worktree `packages/discovery-runtime/src`, JSON coverage and JUnit output under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`.
  - This run covers the bundle parity tests that read the hook files, including `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`.
  - The launcher computes the worktree path at run time in the host's native absolute form, sets `PYTHONPATH` for this one command, and records the value as `<worktree>/packages/discovery-runtime/src`.
  - A PowerShell step script under `SCRATCH` reads the JSON `totals` and sums `LH`/`LF` and `BRH`/`BRF` from `artifacts/python/lcov.info`, whose write time must not precede the run start.
  - Acceptance: `EXIT_CODE: 0`, zero failures and errors, and JSON and lcov totals at or above 85% line and 75% branch. If a total is below, the step exits non-zero, and the executor stops and returns to the orchestrator. Nothing is excluded.
- [ ] [P2-T6] Check cycle scope, hook equality, proof currency, and evidence content, and write `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`.
  - Cycle scope: `git diff --name-only` from `Cycle-Start` to `HEAD`, with `git status --porcelain` as its companion, lists only the two hook files named in P1-T1 and P1-T2, their two bundle copies, `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`, and paths under `<FEATURE>/`. No listed path lies in `<FEATURE>/hook-proof/`.
  - Branch scope: `git diff --name-only` from the merge base lists no path under `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, `.github/workflows/`, or `scripts/powershell/PoshQC/`, and none of `scripts/dev_tools/validate_policy_audit_artifact.py`, `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, `.vscode/tasks.json`, `pyproject.toml`, and the Python tools in spec `### 2. Out of scope`. Every `tools:` entry is unchanged against the merge base.
  - Equality: a hash comparison shows each hook equals its bundle copy, and the hook hashes in the latest `hook-proof.*.md` equal the current files.
  - Evidence: a case-insensitive scan of `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/qa-gates/`, with tokens assembled at run time so the artifact cannot match itself, finds no host path and none of `single-process`, `seeded`, `shuffled`, `reversed-order`, `comparison run`, and `focused run`. A folder that is absent is skipped.
  - Acceptance: `EXIT_CODE: 0`, from a step that exits non-zero on any match or inequality.
- [ ] [P2-T7] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, and write the QA self-review to `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`.
  - The walk includes this plan's own text under `.claude/rules/tonality.md`, and the items in `## Open Questions / Notes`.
  - The artifact has one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed, the QA loop re-runs from P2-T1, and the self-review is rewritten.
  - Acceptance: the artifact holds no FAIL row.

## Acceptance Criteria Traceability

| ID | Finding | Tasks | Proof |
|---|---|---|---|
| RF-6a | The record in its three allow-list positions, and `Change: N/A` on a line carrying it, are not narrowing | P1-T1, P1-T2, P1-T3 | `FRN-ACCEPT`, `pester-parallel` |
| RF-6b | Every other narrowing form stays rejected | P1-T1, P1-T2, P1-T3 | `FRN-REJECT`, `pester-parallel` |
| RF-6c | Both hooks behave the same, and each bundle copy equals its source | P1-T1, P1-T2, P1-T3 | `FRN-PARITY`, `FRN-SECTION`, the `.NET` case of `FRN-REJECT`, `scope-check`, `pytest-parallel` |
| RF-6d | Spec records the hook change | P1-T4 | `spec.md` `## Constraints & Risks` |
| V-1 | Real hooks exit 0 on a filled audit | P2-T2, P2-T3 | `hook-proof-audit`, `hook-proof` |
| V-2 | Both validators accept the same audit | P2-T2 | `hook-proof-validators` |
| V-3 | Gates describe the final head | P2-T4, P2-T5 | `pester-parallel`, `pytest-parallel` |
| V-4 | Per-file line coverage of each changed hook | P2-T4 | `pester-parallel` |

## Pre-Mortem

- Review checklists: P2-T7 walks all three templates against the diff from the merge base. RF-6 escaped two cycles because hook behavior was inferred, so this cycle proves it with real hook processes on fixed inputs.
- Coverage: At planning time the merged report held 88 of 89 lines for the rules file and 146 of 146 for the Codex hook. P2-T4 reads both files against 85%, and `FRN-` cases execute each branch of the new function on both surfaces. Nothing is excluded.
- Mirror parity: Each of P1-T1 and P1-T2 copies its hook to the bundle, and P2-T6 compares both pairs by hash. `FRN-PARITY` pins the shared function text. The brief states no fact this cycle changes, so no brief-update task applies.
- File size: The rules file holds about 195 lines and the Codex hook about 316. Each gains under 50, below the 500 guidance tier. The new suite is a new file of about 170 lines. The `E4-ST4` edit changes one row and adds no line.
- Test isolation: The gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix. The new suite holds in-memory strings and creates no temporary files. The hook proof is not a test-suite run.
- CI-only behavior: The new suite runs in the Windows shards and in `poshqc / PowerShell hook suites (Linux)`, so it uses `Join-Path`, exact file-name case, and no drive letters. The proof depends on gitignored state, so it stays out of every test.
- Evidence: Gate values come from run output, JUnit and JSON files, and coverage files, never MCP summaries. Runner output stays under `SCRATCH`. The Codex `reason` text is not recorded because it holds an absolute path, and P2-T6 scans the evidence folders.

## Open Questions / Notes

Consumers read for this cycle. An entry below covers the bundle copy of a file.

Needs a change:

- `.claude/hooks/validate-feature-review-coverage-rules.ps1`: P1-T1.
- `.codex/hooks/validate-feature-review-coverage.ps1`: P1-T2.

Checked, no change, with reasons:

- `.claude/hooks/validate-feature-review-coverage.ps1`: reads the three artifacts for path, folder, and stamp, and calls the rule. It has no narrowing test of its own.
- `.claude/hooks/validate-feature-review-coverage-metrics.ps1` and `feature-review-coverage-thresholds.ps1` in both hook folders: read coverage reports and `CLAUDE.md`, not audit text.
- `.claude/hooks/enforce-parallel-drift-gate.ps1`: tests for review and `remediation-inputs` files by name and stamp. It reads no coverage line.
- `.claude/hooks/enforce-model-routing-receipt.ps1`, `.codex/hooks/enforce-codex-model-routing.ps1`, `.codex/hooks/validate-codex-subagent-routing.ps1`, and `.codex/hooks/codex-agent-profile-attestation.ps1`: name `feature-review` as an agent only.
- `enforce-completion-helpers.ps1` in both hook folders: its `n/a` sentinel judges checkpoint values, not audit text.
- A search of every other file under `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `.github/hooks`, and the scripts under `.claude/skills` found no reader of a review artifact.
- `scripts/dev_tools/validate_policy_audit_artifact.py` and `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`: `_is_na_value` and `isNaValue` accept the record in a table cell. The placeholder markers do not match it. The `Baseline:` percentage search on a comparison line matches the post-change figure, and `Change:` only needs to be present. The existing tests pin this, and P2-T2 proves it on a filled audit.
- `scripts/dev_tools/validate_orchestration_review_artifacts.py`, `extensions/drm-copilot/src/lib/validate/review-artifacts.ts`, and `orchestration-artifacts.ts` in that folder: headings and routing only.
- `scripts/dev_tools/pr_context/feature_docs.py` and `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`: read the readiness value of `feature-audit` files only.
- `extensions/drm-copilot/src/policy-audit-template-assets.ts`: serves the template and does not parse an audit.

Decisions for the reviewer:

- `New/changed-code coverage: N/A - no production file changed` is exempted beyond the inputs' list. Each audit on this branch writes it for a language that changed only test files, and the Python and TypeScript rows will still do so. Without the exemption, `policy-audit.2026-11-07T04-20.md`, the case the inputs report, still exits 2. The exemption applies only on a line carrying the record, and `N/A - out of scope` in the same field stays rejected, as the inputs require. If the owner rejects it, remove that one removal, its two `FRN-` rows, and Case B.
- `Python coverage N/A - no pre-change run` is rejected. The inputs call the record not narrowing without naming positions, and the allow-list in P1-T1 admits it in three positions only, so this line, which is in none of them, stays rejected. Every line the template prescribes is in an allow-list position: the fifth cell of the metrics table rows, the two `baseline coverage artifact:` lines, and the `Baseline:` field of the comparison line, whose `Change: N/A` the second removal covers. Every record in `policy-audit.2026-11-07T04-20.md` on a line with a language label and a coverage word is in one of the positions too. If the owner wants this line accepted, add a fourth position and move its `FRN-REJECT` case.
- The template still offers `` `N/A - out of scope` `` for new or changed-code coverage, and the hook rejects it for a changed language. The inputs require both, so the filled audit uses a figure.
- The Codex hook gains the rejected-section skip, the PowerShell branch exception, and the `.NET` label correction, which the inputs do not name. They follow from `Both hooks behave the same`.
- Prose in a future audit that puts a bare `N/A` on one line with a language name and a coverage word is still rejected, as `policy-audit.2026-11-07T05-01.md` does in its RF-6 text. The reaudit keeps such text under `## Rejected Scope Narrowing` or words it another way.
- Isolated subagents run `main`'s hook copies, so the reaudit's own stop hook does not exercise this change until it merges. P2-T3 is the proof.
- Jest: no TypeScript file changes, so no Jest gate runs. `coverage/lcov.info` is present in the worktree from the cycle 2 Jest gate, so the inputs' single reaudit run applies only if the file is absent at reaudit. P2-T3 reads this file for the TypeScript row.
- The rejection control in P2-T3 is one hook process on a fixed file, not a test-suite run of a removed form.
- Batch budget: the worktree checkpoint selects the `large` route, so the budget hooks do not cap these edits.
