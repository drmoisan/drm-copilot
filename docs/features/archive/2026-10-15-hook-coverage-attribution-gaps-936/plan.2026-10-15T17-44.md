# hook-coverage-attribution-gaps (Plan)

- **Issue:** #936
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15
- **Status:** Ready for preflight (revision 4)
- **Version:** 1.0
- **Work Mode:** minor-audit (`issue.md` `## Acceptance Criteria` AC-1 through AC-8 is the sole requirements source; `spec.md` and `user-story.md` are absent by design and must stay absent)
- **Branch:** `bug/hook-coverage-attribution-gaps-936`
- **Inputs:** `issue.md`; `research/2026-10-15T18-30-hook-coverage-attribution-research.md` (root cause and recommended fix). The byte-identical copy `research/hook-coverage-attribution-research.md` is ignored and is not deleted.

## Preflight Control Note

The executor stop hook (.claude/hooks/validate-executor-output.ps1, Test-IsPreflightPlan) treats this plan as a preflight plan while the whole-line directive below is present. The orchestrator deletes that directive line after PREFLIGHT: ALL CLEAR and before delegating execution, so the hook applies its completion checks to the execution run. It is a control line, not a task.


**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope

Decided fix (research `## Recommended Fix`; not reopened by this plan): document the likely Pester 5.x breakpoint-mode cause of the non-attribution in the `.DESCRIPTION` comment-help headers of the two Codex test files that already execute and assert the lines, and record attribution evidence from a coverage run scoped to `tests/scripts/codex-hooks`.

Repository files edited outside the feature folder (comment-help `.DESCRIPTION` text only; no test logic):

1. `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` (80 lines on the planning tree) — note for `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` line 41 (AC-1).
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (97 lines on the planning tree) — note for `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 183, 190, 191, 206, 207, and 209 (AC-2).

All other writes are evidence files, `issue.md` check-offs, and this plan, all inside the feature folder.

Out of scope and not touched by any task: every production hook (including both `.codex/hooks` files named above and their `.claude/hooks` and `extensions/drm-copilot/resources/` mirrors); `config/poshqc-coverage.json`; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; every file under `.github/workflows/`; every file under `.claude/rules/` and `.github/instructions/`; and every prior item's feature folder (no task reads or cites one, so the active-to-archive move of closed-issue folders does not affect this plan).

Concurrency. Item #884 edits `.claude/lib/bash/compute-concurrency-batches.sh` and `.codex/hooks/validate-feature-review-coverage.ps1`; this plan touches neither. Item #935 may later rename `-Surface` to `-Scope` in the same two test files, on the `Register-EpicStateBaselineMock` call lines (FailClosed lines 21-26, Decision lines 24-25 on the planning tree). This plan edits only the `.DESCRIPTION` blocks (FailClosed lines 8-14, Decision lines 8-16), which do not intersect those lines. Every diff in this plan is anchored to the merge base through `origin/main...HEAD`, so a concurrent update of `origin/main` does not change a result.

### Current-tree facts this plan relies on (re-derived 2026-10-15 on this worktree)

- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`: line 36 `$script:OrchestrationFeatureFolderResolutionImportFailure = $null`; line 38 dot-sources `feature-folder-resolution.ps1` inside `try`; line 40 `catch {`; line 41 `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'`. A search of `.codex` for an assignment to that variable finds only lines 36 and 41.
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: `Get-OrchestrationEpicScopeDecision` body lines 181-210; line 183 `return $null` (no command and no path); lines 190-191 reset the leg to the patch-marker paths; line 201 the readiness-failure scriptblock body; line 206 `if ($outcome.Outcome -eq 'deny') {`; line 207 `return Get-OrchestrationPreimplementationGateBlockDecision -Reason $outcome.Reason` (the only call of that constructor in the file); line 209 `return Get-OrchestrationPreimplementationGateAllowDecision`.
- `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` (80 lines): `.DESCRIPTION` at line 8, description text lines 9-13, closing `#>` at line 14; the H2 codex deny rows at lines 50-65 and 67-79 assert `$script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1'` at lines 55 and 71.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (97 lines): `.DESCRIPTION` at line 8, description text lines 9-15, closing `#>` at line 16; stand-in `Get-OrchestrationPreimplementationGateBlockDecision` at lines 30-40; ES-D1 at lines 74-85 with the exact-reason assertion at line 83; ES-D2 at lines 87-96.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` line 373 calls `Get-OrchestrationEpicScopeDecision -Command '' -FilePath ''`, which reaches epic-scope line 183.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: JUnit `OutputPath = 'artifacts/pester/pester-junit.xml'` at line 15; coverage `OutputFormat = 'CoverageGutters'` at line 21 and `OutputPath = 'artifacts/pester/powershell-coverage.xml'` at line 22.
- `config/poshqc-coverage.json` line 6 lists `.codex/hooks` in the coverage population.
- `.github/workflows/_poshqc.yml`: job `poshqc` named `PowerShell QC` on `windows-latest` (lines 8-10) runs `Invoke-PoshQCTest` (line 42) and uploads artifact `poshqc-test-results` holding `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (lines 44-52); job `poshqc-linux-hooks` named `PowerShell hook suites (Linux)` (lines 54-56) has coverage disabled. `.github/workflows/ci.yml` line 23-24 calls it as job `poshqc`, so the PR check is named `poshqc / PowerShell QC`.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` exist, so the coverage XML holds same-basename `sourcefile` entries in a `.claude/hooks` package. Every XML read in this plan selects the package whose name ends with `/.codex/hooks`.
- Orchestrator observation (2026-10-15T22:01Z, this worktree; recorded by the caller, not re-run by the planner): `run_poshqc_test` with `scan_folders: ["tests/scripts/codex-hooks"]` wrote both XML files; in the `.codex/hooks` package modes line 41 and epic-scope lines 183, 190, 191, 201, 206, 207, and 209 had `ci="1"`. The call returned exit code 2 because one row each in (JUnit failures="2"; the caller's console count was 4) `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` failed: `enforce-epic-planning-only.ps1` read the session's gitignored preparation-mode checkpoint and denied benign payloads. That is ambient state, not a #936 defect; Phase 0 records the exact failing set so later phases compare against it.

## Execution Conventions

### Terms

- FEATURE means `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936`. Commands spell the full path.
- FC means `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`; DEC means `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. Commands spell the full paths.
- SCRATCH means `<session scratchpad>/issue-936/`: the directory `issue-936` directly under the executing session's scratchpad (issue-number-namespaced; never the bare scratchpad root). Every scratch file, helper script, staged copy, and copied XML report this plan names lives under SCRATCH. Commands use the forward-slash form of the resolved path; evidence artifacts record the literal token `SCRATCH`, never a host path. If two runs for issue #936 can execute at once, SCRATCH is `<session scratchpad>/issue-936-<yyyy-MM-ddTHH-mm>/` instead.
- WORKTREE means the executing worktree root. MCP calls pass it as `workspace_root`; artifacts record the literal token `WORKTREE`.
- HELPER means the read-only scratch script `SCRATCH/cov936.py`, written verbatim from Appendix A. It prints the values the acceptance conditions assert and writes nothing.
- TS means the UTC write time read with `date -u +%Y-%m-%dT%H-%M` immediately before the artifact is written.
- "Latest `<name>`" means the lexicographically greatest file matching `<name>.*.md` in the stated evidence directory.

### Evidence

- Every evidence artifact is written to `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with kind `baseline`, `regression-testing`, `qa-gates`, or `other`; the timestamp is TS. No evidence is written under `artifacts/`. The caller supplied no non-canonical evidence path, so no override record is needed.
- Every command-step artifact carries, in this order, `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The first `Command:` and the first `EXIT_CODE:` in an artifact form its gate record (both evidence parsers read the first occurrence); supporting commands may be recorded after the gate record with their own `Command:` and `EXIT_CODE:` lines, which do not form the record. A task that names "the artifact's first `Command:`" fixes which command is the gate, regardless of the order in which the commands ran. An artifact whose expected exit code for its gate is not 0 also carries `ExpectedExitCode:`; P0-T5 and P0-T6 record only their single command step.
- MCP tool steps record `Command:` as the tool name followed by its arguments with `workspace_root=WORKTREE`. `EXIT_CODE:` is derived from the tool result: 0 when `ok` is true; when `ok` is false, the integer N from the `summary` text "Command exited with code N.", or 1 when the summary carries no such text. `Output Summary:` states the `ok` value and quotes the `summary` field.
- PoshQC MCP results carry no per-finding, per-line, or test-count output. No acceptance condition in this plan reads a finding count, a percentage, or a test count from MCP result text. Format and analyze are judged by the result's `ok` value (and the EXIT_CODE derived from it) plus a tree observation; tests are judged by HELPER output over the XML files the run writes to `artifacts/pester/`.
- The MCP test runner uses installed-extension settings (observed in prior sessions: a coverage entry added in the repository is not read by the MCP runner until the extension is rebuilt). Every test-run artifact records the line `RUNNER-SETTINGS: installed-extension`, and no task asserts a per-file coverage figure other than the `.codex/hooks` line elements named in Appendix A.

### Shell route

- Agent worktrees deny command text containing the words for the PowerShell executable, the POSIX shell named for Bourne-again, or the Windows Subsystem for Linux launcher. No task runs Pester or PowerShell directly. PowerShell format, analyze, and test run only through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` (Option A), plus CI evidence (Orchestrator S9 procedure).
- Every git, grep, cp, stat, date, ls, find, gh, and poetry command is one plain command with literal arguments. No commit message contains any of the three denied words.
- grep patterns are passed through `-e`, so a pattern that begins with a hyphen is not read as an option.

### Stop rules

- **SR-1 Hook denial.** If any hook denies a tool call, stop and report the verbatim denial text. Do not route around the hook.
- **SR-2 Failing rows.** A test run may fail rows that belong to its Phase 0 baseline failing set (P0-T11 for scoped runs, P0-T14 for full runs). Any `FAILED-TESTCASE:` line that is not in the matching baseline set stops the plan; report the line. No task adds a row to a baseline set after Phase 0.
- **SR-3 Out-of-scope change.** If a formatter or test run modifies, adds, or deletes any path outside FC, DEC, and FEATURE (observed through `git status --porcelain`), stop and report the porcelain output. Do not commit, revert, or delete it.
- **SR-4 Mechanism refuted.** If P0-T10 reports `REQUIRED-ATTRIBUTED=False`, the scoped run does not attribute the lines and the research mechanism is refuted for this environment. Stop with `MECHANISM-REFUTED` and return to the orchestrator before Phase 1; no header is written.
- **SR-5 Toolchain loop.** In Phase 2, if P2-T1 observes a changed hash or a non-empty porcelain, or P2-T2 returns `ok` false, correct the cause only inside the FC or DEC `.DESCRIPTION` block, commit it, and restart from P2-T1. A cause outside those blocks stops the plan.

### Commit rule

Each phase ends with a commit-and-push task; Phase 1 additionally commits the two test files before the branch-diff checks. `git add` names paths explicitly (`git add -A` and `git add .` are not used). Push is `git push origin bug/hook-coverage-attribution-gaps-936`. No force push, no history rewrite, and no task deletes a file. A commit task's own check-off is carried by the next commit; the P2-T9 check-off is left for the orchestrator to commit.

### Execution model

- One atomic-executor run executes P0-T1 through P2-T9 in order. The executor performs the P1-T1 comment-text insertion itself with its Edit tool.
- The orchestrator removes the whole-line preflight directive from this plan before that run (P0-T1 checks it).
- AC-5 is not an executor task. It is completed by the orchestrator under the "Orchestrator S9 procedure" section after Phase 2.

### Execution-run completion message requirements

This section is guidance, not a task. The executor stop hook `.claude/hooks/validate-executor-output.ps1` checks the final completion message of the execution run once the preflight directive line has been removed. That message must meet these requirements:

(a) It includes a `plan-path:` line naming this plan file (hook lines 73 and 233).

(b) It does not contain the word that the hook's line 252 matches with `-match`, which is case-insensitive, outside preflight. Any case of that word is rejected with `Repairable = $false` (line 253), so the run cannot be repaired after the message is written. A stop under a stop rule is reported as `STOPPED` with the reason, never with that word.

(c) It includes an `AC Status Summary` section (line 288).

(d) It includes one line each for Python, TypeScript, and PowerShell, and each line carries `PASS` or `FAIL` (lines 298-307; the line pattern is in `Test-OutputHasLanguageStatus`, lines 125-146). This is required because `Get-TouchedLanguagesFromPlan` (lines 99-123) detects path tokens ending in `.py`, `.ts`, and `.ps1` in this plan. Only PowerShell files change. The PowerShell line carries the Phase 2 result; the Python and TypeScript lines each state that no file in that language is in the change set (P2-T6) and carry `PASS` on that basis.

The same hook also requires the message to report the commands run (line 292) and requires every task line in this plan to be checked before the run ends (lines 256-286).

## Phases

### Phase 0 — Baseline capture

- [x] [P0-T1] Precondition: `grep -c -x -F -e "DIRECTIVE: PREFLIGHT VALIDATION ONLY" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md` prints `0`; if it prints `1`, stop and return to the orchestrator before any other P0-T1 command. Record branch state in `FEATURE/evidence/baseline/branch-state.<timestamp>.md`. Run `git rev-parse --abbrev-ref HEAD`, `git fetch origin main`, `git rev-parse HEAD`, and `git merge-base origin/main HEAD`, and record each command and its output. Acceptance: `git rev-parse --abbrev-ref HEAD` prints `bug/hook-coverage-attribution-gaps-936`; `git fetch origin main` exits 0; the artifact records the HEAD SHA and the merge-base SHA as two 40-character hex values.
- [x] [P0-T2] Verify the minor-audit inputs and record them in `FEATURE/evidence/baseline/minor-audit-inputs.<timestamp>.md`. Run `grep -c -F -e "- Work Mode: minor-audit" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md`, `grep -c -F -e "## Acceptance Criteria" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md`, `grep -c -F -e "- [ ] AC-" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md`, and `ls docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936`. Acceptance: the three counts print `1`, `1`, and `8`; the `ls` output lists neither `spec.md` nor `user-story.md` (if either is listed, stop: minor-audit fails closed).
- [x] [P0-T3] Read the policy files in this order and record them in `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`. Acceptance: the artifact carries `Timestamp:`, a `Policy Order:` line naming the four files in that order, and one line per file read; `grep -c -F -e "Policy Order:" <artifact>` prints `1` for the latest `phase0-instructions-read` artifact.
- [x] [P0-T4] Create SCRATCH and its subdirectories with `mkdir -p SCRATCH/old SCRATCH/p0-scoped SCRATCH/p0-full SCRATCH/p1-scoped SCRATCH/p2-full`, write HELPER with the Write tool byte-for-byte from Appendix A, and compile it with `poetry run python -I -m py_compile SCRATCH/cov936.py`. Acceptance: the compile command exits 0, and `poetry run python -I SCRATCH/cov936.py` with no arguments prints a line beginning `USAGE:` and exits 2. No artifact (scratch setup only).
- [x] [P0-T5] [expect-fail] Capture the FC header-token baseline in `FEATURE/evidence/regression-testing/header-tokens-failclosed-before.<timestamp>.md` with `ExpectedExitCode: 1`. Run `poetry run python -I SCRATCH/cov936.py header failclosed tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`. Acceptance: exit code 1; the output contains `HEADER-TOKENS=INCOMPLETE` and `FILE-LINES=80`; the artifact records every `TOKEN-` line verbatim.
- [x] [P0-T6] [expect-fail] Capture the DEC header-token baseline in `FEATURE/evidence/regression-testing/header-tokens-decision-before.<timestamp>.md` with `ExpectedExitCode: 1`. Run `poetry run python -I SCRATCH/cov936.py header decision tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. Acceptance: exit code 1; the output contains `HEADER-TOKENS=INCOMPLETE` and `FILE-LINES=97`; the artifact records every `TOKEN-` line verbatim.
- [x] [P0-T7] Capture the format baseline for `tests/scripts/codex-hooks` in `FEATURE/evidence/baseline/format-codex-hooks.<timestamp>.md`. Run `git hash-object tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`, then call `mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`, then repeat the same `git hash-object` command and run `git status --porcelain -- tests/scripts/codex-hooks`. Acceptance: the tool result reports `ok` true (EXIT_CODE: 0 under the derivation in Evidence); both hashes are unchanged between the two `git hash-object` runs; the porcelain command prints nothing (otherwise SR-3).
- [x] [P0-T8] Capture the analyzer baseline in `FEATURE/evidence/baseline/analyze-codex-hooks.<timestamp>.md`. Call `mcp__drm-copilot__run_poshqc_analyze workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`. Acceptance: the tool result reports `ok` true (EXIT_CODE: 0 under the derivation in Evidence). If it reports `ok` false, stop and return to the planner: AC-7 cannot be shown by a folder-scoped analyzer run that already fails before any change.
- [x] [P0-T9] Run the scoped coverage baseline and record it in `FEATURE/evidence/baseline/test-scoped.<timestamp>.md`. Run `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml` (an absent file prints a "No such file" message; record it), call `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`, run the same `stat` command again, then `cp artifacts/pester/powershell-coverage.xml SCRATCH/p0-scoped/powershell-coverage.xml` and `cp artifacts/pester/pester-junit.xml SCRATCH/p0-scoped/pester-junit.xml`, then `git status --porcelain`. Acceptance: each file's second `stat` value is greater than its first value, or the file was absent before and present after; both `cp` commands exit 0; the porcelain output lists no path outside FEATURE (otherwise SR-3). The artifact records the derived EXIT_CODE (the caller observed 2 on this worktree) and `RUNNER-SETTINGS: installed-extension`. The MCP call is the artifact's first `Command:`. When the derived EXIT_CODE is not 0, the artifact carries `ExpectedExitCode:` equal to it (the baseline definition). After the `cp` steps, run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-scoped/powershell-coverage.xml`; it exits 0 and its `REPORT-LINE` line is recorded verbatim in this artifact's `Output Summary:`.
- [x] [P0-T10] Record the scoped `.codex/hooks` line elements in `FEATURE/evidence/baseline/coverage-lines-scoped.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py lines SCRATCH/p0-scoped/powershell-coverage.xml`. Acceptance: exit code 0; the output contains `CODEX-PACKAGE-COUNT=1` and `REQUIRED-ATTRIBUTED=True`; the artifact records every `LINE` line verbatim. Exit code 1 (`REQUIRED-ATTRIBUTED=False`) triggers SR-4; exit code 2 (package, file, or line element missing) stops the plan.
- [x] [P0-T11] Record the scoped baseline failing set in `FEATURE/evidence/baseline/junit-scoped.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py junit SCRATCH/p0-scoped/pester-junit.xml`. Acceptance: exit code 0; the output contains `TARGETS-PASSED=True`; the artifact records every `FAILED-TESTCASE:` line verbatim under the heading `BASE-SCOPED-FAILS` (or the word `none`) and names, for each such row, its cause as observed in the row's failure (the caller's observation names the ambient preparation-mode checkpoint read by `enforce-epic-planning-only.ps1`). HELPER prints suite basenames only. This scoped run executes only `tests/scripts/codex-hooks`, so every row carrying FC's basename belongs to FC. Stop if any `FAILED-TESTCASE:` line begins with `FAILED-TESTCASE: enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ` or with `FAILED-TESTCASE: hook-import-failure-exemptions.FailClosed.Tests.ps1 | `.
- [x] [P0-T12] Run the full coverage baseline and record it in `FEATURE/evidence/baseline/test-full.<timestamp>.md`. Run `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`, call `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE` with no `scan_folders`, run the same `stat` command again, then `cp artifacts/pester/powershell-coverage.xml SCRATCH/p0-full/powershell-coverage.xml` and `cp artifacts/pester/pester-junit.xml SCRATCH/p0-full/pester-junit.xml`, then `git status --porcelain`. Acceptance: each file's second `stat` value is greater than its first; both `cp` commands exit 0; the porcelain output lists no path outside FEATURE (otherwise SR-3). The artifact records the derived EXIT_CODE and `RUNNER-SETTINGS: installed-extension`. The MCP call is the artifact's first `Command:`. When the derived EXIT_CODE is not 0, the artifact carries `ExpectedExitCode:` equal to it (the baseline definition). After the `cp` steps, run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-full/powershell-coverage.xml`; it exits 0 and its `REPORT-LINE` line is recorded verbatim in this artifact's `Output Summary:`.
- [x] [P0-T13] Record the baseline line coverage in `FEATURE/evidence/baseline/coverage-full.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-full/powershell-coverage.xml`. Acceptance: exit code 0; the output contains one line beginning `REPORT-LINE missed=`, and the artifact's `Output Summary:` records its numeric `missed=`, `covered=`, and `LinePercent=` values verbatim (no placeholder). PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`), so no branch value is recorded.
- [x] [P0-T14] Record the full-run baseline failing set in `FEATURE/evidence/baseline/junit-full.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py junit SCRATCH/p0-full/pester-junit.xml`. Acceptance: exit code 0; the output contains `TARGETS-PASSED=True`; the artifact records every `FAILED-TESTCASE:` line verbatim under the heading `BASE-FULL-FAILS` (or the word `none`). HELPER prints suite basenames only, and `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` shares FC's basename. Stop if any `FAILED-TESTCASE:` line begins with `FAILED-TESTCASE: enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ` or with `FAILED-TESTCASE: hook-import-failure-exemptions.FailClosed.Tests.ps1 | preimplementation gate modes handler proof on the codex surface.`; a line for the same basename with any other test name belongs to the Claude suite and is recorded in `BASE-FULL-FAILS` like any other row.
- [x] [P0-T15] Commit and push Phase 0. Run `git add docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md`, `git commit -m "docs(#936): record phase 0 baseline evidence"`, `git push origin bug/hook-coverage-attribution-gaps-936`, then `git status --porcelain -- docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936` and `git rev-parse HEAD origin/bug/hook-coverage-attribution-gaps-936`. Acceptance: the push exits 0; the porcelain command prints nothing; the two `rev-parse` values are equal.

### Phase 1 — Constrained implementation (header notes)

- [x] [P1-T1] Insert the two header notes with the Edit tool (executor-performed; comment text only, no logic). (a) In FC (`tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`), insert the ten lines of Appendix B1 byte-for-byte between line 13 (`    case reads orchestration state, and no test creates, renames, moves, or deletes a file.`) and line 14 (`#>`, the line that closes the `.DESCRIPTION` block): the Edit `old_string` is those two lines, and the `new_string` is line 13, the ten Appendix B1 lines, then `#>`. (b) In DEC (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`), insert the eleven lines of Appendix B2 byte-for-byte between line 15 (`    the only target is the session root. No row creates a file or starts a process.`) and line 16 (`#>`) in the same way. Each file's existing LF line endings are preserved (both files are LF on the planning tree; `.gitattributes` line 1 is `* text=auto eol=lf`), and nothing else in either file changes: no `It`, `Describe`, `BeforeAll`, `Mock`, assertion, `#Requires`, `.SYNOPSIS`, or existing `.DESCRIPTION` line is added, removed, or altered, and no other file is edited. Then run `git status --porcelain` and `git diff --numstat HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. Acceptance: the porcelain output lists FC and DEC as modified (` M`), and every other path it lists begins with `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/` (the plan file carries the uncommitted P0-T15 check-off; any other path triggers SR-3); the numstat prints `11`, `0`, DEC path and `10`, `0`, FC path. No artifact for this task; P1-T2, P1-T3, P1-T5, and P1-T6 are its verification.
- [x] [P1-T2] Verify the FC header note (AC-1) and record it in `FEATURE/evidence/regression-testing/header-tokens-failclosed-after.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py header failclosed tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`. Acceptance: exit code 0; the output contains `HEADER-TOKENS=ALL-PRESENT` and `FILE-LINES=90`; no `TOKEN-ABSENT` line is printed. The tokens are those listed for `failclosed` in Appendix A, each present on one line of Appendix B1.
- [x] [P1-T3] Verify the DEC header note (AC-2) and record it in `FEATURE/evidence/regression-testing/header-tokens-decision-after.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py header decision tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. Acceptance: exit code 0; the output contains `HEADER-TOKENS=ALL-PRESENT` and `FILE-LINES=108`; no `TOKEN-ABSENT` line is printed. The tokens are those listed for `decision` in Appendix A, each present on one line of Appendix B2.
- [x] [P1-T4] Commit and push the two test files. Run `git add tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md`, `git commit -m "test(#936): document coverage attribution cause in codex test headers"`, `git push origin bug/hook-coverage-attribution-gaps-936`, then `git status --porcelain -- tests/scripts/codex-hooks`. Acceptance: the push exits 0 and the porcelain command prints nothing.
- [x] [P1-T5] Verify that the FC branch diff changes only `.DESCRIPTION` text (AC-3) and record it in `FEATURE/evidence/regression-testing/diff-guard-failclosed.<timestamp>.md`. Run `git diff --numstat origin/main...HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, `git diff origin/main...HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` (record the full diff text), `git merge-base origin/main HEAD` (call its output MB), `git show MB:tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 > SCRATCH/old/failclosed.ps1` (MB replaced by the printed SHA), and `poetry run python -I SCRATCH/cov936.py descguard SCRATCH/old/failclosed.ps1 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`. Acceptance: the numstat line reads `10`, `0`, then the FC path (ten lines added, none removed); the `descguard` command exits 0 and prints `PREFIX-EQUAL=True SUFFIX-EQUAL=True`, `OLD-LINES=80 NEW-LINES=90 UNDER-500=True`, and `HEADER-ONLY=True`.
- [x] [P1-T6] Verify that the DEC branch diff changes only `.DESCRIPTION` text (AC-3) and record it in `FEATURE/evidence/regression-testing/diff-guard-decision.<timestamp>.md`. Run `git diff --numstat origin/main...HEAD -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`, `git diff origin/main...HEAD -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (record the full diff text), `git merge-base origin/main HEAD` (MB), `git show MB:tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 > SCRATCH/old/decision.ps1`, and `poetry run python -I SCRATCH/cov936.py descguard SCRATCH/old/decision.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. Acceptance: the numstat line reads `11`, `0`, then the DEC path; the `descguard` command exits 0 and prints `PREFIX-EQUAL=True SUFFIX-EQUAL=True`, `OLD-LINES=97 NEW-LINES=108 UNDER-500=True`, and `HEADER-ONLY=True`.
- [x] [P1-T7] Run the post-change scoped coverage run and record it in `FEATURE/evidence/qa-gates/test-scoped.<timestamp>.md`. Run `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`, call `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`, run the same `stat` command again, then `cp artifacts/pester/powershell-coverage.xml SCRATCH/p1-scoped/powershell-coverage.xml` and `cp artifacts/pester/pester-junit.xml SCRATCH/p1-scoped/pester-junit.xml`, then `git status --porcelain`. Acceptance: each file's second `stat` value is greater than its first; both `cp` commands exit 0; the porcelain output lists no path outside FEATURE (otherwise SR-3). The artifact records the derived EXIT_CODE and `RUNNER-SETTINGS: installed-extension`; the MCP exit code is not the pass criterion (SR-2 and P1-T9 judge the rows). The MCP call is the artifact's first `Command:`. The artifact carries `ExpectedExitCode:` equal to the EXIT_CODE of the latest baseline `test-scoped` artifact in `FEATURE/evidence/baseline/`; the row-level judgment remains SR-2. After the `cp` steps, run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p1-scoped/powershell-coverage.xml`; it exits 0 and its `REPORT-LINE` line is recorded verbatim in this artifact's `Output Summary:`.
- [x] [P1-T8] Record the AC-4 attribution evidence in `FEATURE/evidence/qa-gates/isolated-coverage-attribution.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py lines SCRATCH/p1-scoped/powershell-coverage.xml`. Acceptance: exit code 0; the output contains `CODEX-PACKAGE-COUNT=1`, `REQUIRED-ATTRIBUTED=True`, and `LINE` lines ending in " ci=1 ATTRIBUTED" or a higher ci value followed by " ATTRIBUTED" (not "UNATTRIBUTED") for `enforce-orchestration-preimplementation-gate-modes.ps1:41`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1:206`, and `enforce-orchestration-preimplementation-gate-epic-scope.ps1:207`. The artifact records every `LINE` line verbatim, states that the elements come from the package whose name ends with `/.codex/hooks` (not the `.claude/hooks` same-basename entries), and records the P1-T7 derived EXIT_CODE with the names of any failing rows and the P0-T11 explanation for them.
- [x] [P1-T9] Record the AC-6 row results in `FEATURE/evidence/qa-gates/scoped-junit.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py junit SCRATCH/p1-scoped/pester-junit.xml`. Acceptance: exit code 0; the output contains `TARGETS-PASSED=True` and the three `TARGET` lines with `count=2 passed=2` for the FC H2 deny rows and `count=1 passed=1` for each of ES-D1 and ES-D2; every printed `FAILED-TESTCASE:` line is in `BASE-SCOPED-FAILS` of the latest `FEATURE/evidence/baseline/junit-scoped` artifact (otherwise SR-2). The artifact records the comparison as `NEW-FAILURES: none`.
- [x] [P1-T10] Check off AC-1, AC-2, AC-3, AC-4, and AC-6 in `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` by changing each item's `- [ ] ` prefix to `- [x] ` only, each only when its mapped evidence (Planner Review Record) exists and met its acceptance. Acceptance: `grep -c -F -e "- [x] AC-" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` prints `5`, and `grep -c -F -e "- [ ] AC-5" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` prints `1`.
- [x] [P1-T11] Commit and push Phase 1. Run `git add docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md`, `git commit -m "docs(#936): record phase 1 attribution evidence"`, `git push origin bug/hook-coverage-attribution-gaps-936`, then `git status --porcelain -- docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936` and `git rev-parse HEAD origin/bug/hook-coverage-attribution-gaps-936`. Acceptance: the push exits 0; the porcelain command prints nothing; the two `rev-parse` values are equal.

### Phase 2 — Final QC

PowerShell loop order: format, analyze, test (PowerShell has no type-check stage per `.claude/rules/powershell.md`). Restart from P2-T1 under SR-5. Every command task below is unconditional; none has a skip branch.

- [x] [P2-T1] Run the final format check (AC-7) and record it in `FEATURE/evidence/qa-gates/final-format.<timestamp>.md`. Run `git hash-object tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`, call `mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`, repeat the same `git hash-object` command, and run `git status --porcelain -- tests/scripts/codex-hooks`. Acceptance: the tool result reports `ok` true (EXIT_CODE: 0 under the derivation in Evidence); both hashes are unchanged between the two runs (the formatter left FC and DEC unchanged); the porcelain command prints nothing. The artifact records both hash pairs and the line `FORMAT-RESULT: unchanged`.
- [x] [P2-T2] Run the final analyzer check (AC-7) and record it in `FEATURE/evidence/qa-gates/final-analyze.<timestamp>.md`. Call `mcp__drm-copilot__run_poshqc_analyze workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]`. Acceptance: the tool result reports `ok` true (EXIT_CODE: 0 under the derivation in Evidence).
- [x] [P2-T3] Run the final full coverage run and record it in `FEATURE/evidence/qa-gates/final-test-full.<timestamp>.md`. Run `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`, call `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE` with no `scan_folders`, run the same `stat` command again, then `cp artifacts/pester/powershell-coverage.xml SCRATCH/p2-full/powershell-coverage.xml` and `cp artifacts/pester/pester-junit.xml SCRATCH/p2-full/pester-junit.xml`, then `git status --porcelain`. Acceptance: each file's second `stat` value is greater than its first; both `cp` commands exit 0; the porcelain output lists no path outside FEATURE (otherwise SR-3). The artifact records the derived EXIT_CODE and `RUNNER-SETTINGS: installed-extension`. The MCP call is the artifact's first `Command:`. The artifact carries `ExpectedExitCode:` equal to the EXIT_CODE of the latest baseline `test-full` artifact in `FEATURE/evidence/baseline/`; the row-level judgment remains SR-2. After the `cp` steps, run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p2-full/powershell-coverage.xml`; it exits 0 and its `REPORT-LINE` line is recorded verbatim in this artifact's `Output Summary:`.
- [x] [P2-T4] Record the coverage comparison in `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py counter SCRATCH/p2-full/powershell-coverage.xml`. Acceptance: exit code 0; the artifact's `Output Summary:` records the baseline `missed=`, `covered=`, and `LinePercent=` values copied from the latest `FEATURE/evidence/baseline/coverage-full` artifact, the post-change values printed by this command, and `ChangedExecutableLines=0` with the derivation "P1-T5 and P1-T6 report `HEADER-ONLY=True`; every changed line is comment-help text in a test file under `tests/`, which is outside the coverage population"; the post-change `LinePercent=` is greater than or equal to the baseline `LinePercent=`. The artifact also records `Threshold85=MET` or `Threshold85=NOT-MET` for the post-change value against the 85% line default (the root `CLAUDE.md` states no threshold); `NOT-MET` with a baseline that was also below 85% is recorded as pre-existing. A post-change value below the baseline is remediation-required: stop and report both values.
- [x] [P2-T5] Record the final full-run row results (AC-6) in `FEATURE/evidence/qa-gates/final-junit-full.<timestamp>.md`. Run `poetry run python -I SCRATCH/cov936.py junit SCRATCH/p2-full/pester-junit.xml`. Acceptance: exit code 0; the output contains `TARGETS-PASSED=True`; every printed `FAILED-TESTCASE:` line is in `BASE-FULL-FAILS` of the latest `FEATURE/evidence/baseline/junit-full` artifact (otherwise SR-2). The artifact records the comparison as `NEW-FAILURES: none`.
- [x] [P2-T6] Verify the change set (AC-8) and record it in `FEATURE/evidence/qa-gates/scope-diff.<timestamp>.md`. Run `git diff --name-only origin/main...HEAD`, `git status --porcelain`, and `ls docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936`. Acceptance: every path printed by the diff and every path in the porcelain output (status columns removed) is either `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`, or begins with `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/`; in particular no path under `.codex/hooks/`, `.claude/`, `.github/workflows/`, `extensions/`, `config/poshqc-coverage.json`, or `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is printed; the `ls` output lists neither `spec.md` nor `user-story.md`.
- [x] [P2-T7] Write the reduced-audit handoff in `FEATURE/evidence/other/small-audit-handoff.<timestamp>.md`: one line per criterion, `AC-1:` through `AC-8:`, each followed by the evidence path that verifies it (Planner Review Record mapping), except `AC-5:`, which is followed by `PENDING-CI (Orchestrator S9 procedure)`; then a line `CHANGED-FILES:` naming FC and DEC. The orchestrator owns the post-implementation small-audit; this artifact is its input. Acceptance: `grep -c -E -e "^AC-[1-8]:" <artifact>` prints `8` for the latest `small-audit-handoff` artifact.
- [x] [P2-T8] Check off AC-7 and AC-8 in `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` (prefix change only), each only when its mapped evidence exists and met its acceptance. Acceptance: `grep -c -F -e "- [x] AC-" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` prints `7`, and `grep -c -F -e "- [ ] AC-5" docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md` prints `1`.
- [x] [P2-T9] Commit and push Phase 2. Run `git add docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md`, `git commit -m "docs(#936): record final QC evidence"`, `git push origin bug/hook-coverage-attribution-gaps-936`, then `git status --porcelain -- docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936` and `git rev-parse HEAD origin/bug/hook-coverage-attribution-gaps-936`. Acceptance: the push exits 0; the porcelain command prints nothing; the two `rev-parse` values are equal.

### Orchestrator S9 procedure (AC-5; not an executor task)

The orchestrator writes HELPER into its own SCRATCH from Appendix A if absent, then runs `gh pr view bug/hook-coverage-attribution-gaps-936 --json number,headRefOid`, `gh pr checks <PR number> --json name,state,link`, takes the run ID from the `/actions/runs/<run ID>/` segment of the `link` of the entry named `poshqc / PowerShell QC`, runs `gh run view <run ID> --json headSha,conclusion`, `gh run download <run ID> --name poshqc-test-results --dir SCRATCH/ci-936` (a new, empty directory), `find SCRATCH/ci-936 -name powershell-coverage.xml`, and `poetry run python -I SCRATCH/cov936.py lines <path printed by find>`, and records the result in `FEATURE/evidence/qa-gates/ci-coverage-attribution.<timestamp>.md`, with the `lines` command as the artifact's first `Command:`. Acceptance: the `poshqc / PowerShell QC` entry has state `SUCCESS`; the run's `headSha` equals the PR `headRefOid`; `find` prints exactly one path; the `lines` command exits 0 or 1 (exit 2 fails the task); the artifact records the `LINE` lines for modes `:41` and epic-scope `:206` and `:207` verbatim from the `/.codex/hooks` package. When the command exits 1, the artifact carries `ExpectedExitCode: 1` and the line `KNOWN-EXCEPTION: full-run breakpoint attribution (issue #936)`, documenting the `ci="0"` values as the known exception. The orchestrator then checks off AC-5 in `issue.md` and commits both files.

## Appendix A — HELPER (`SCRATCH/cov936.py`, written verbatim; read-only)

```python
"""Read-only evidence helper for the issue #936 plan.

Scratch file under SCRATCH; never committed. It reads XML and PowerShell text
files and prints the values the plan's acceptance conditions assert. It writes
nothing.
"""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

PACKAGE_SUFFIX = "/.codex/hooks"
MODES_FILE = "enforce-orchestration-preimplementation-gate-modes.ps1"
EPIC_FILE = "enforce-orchestration-preimplementation-gate-epic-scope.ps1"
FAILCLOSED_SUITE = "hook-import-failure-exemptions.FailClosed.Tests.ps1"
DECISION_SUITE = "enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1"
LINE_TARGETS = (
    (MODES_FILE, (41,)),
    (EPIC_FILE, (183, 190, 191, 201, 206, 207, 209)),
)
REQUIRED_ATTRIBUTED = ((MODES_FILE, 41), (EPIC_FILE, 206), (EPIC_FILE, 207))
JUNIT_TARGETS = (
    (FAILCLOSED_SUITE, "H2 codex preimplementation gate denies", 2),
    (DECISION_SUITE, "ES-D1 ", 1),
    (DECISION_SUITE, "ES-D2 ", 1),
)
HEADER_TOKENS = {
    "failclosed": (
        "#936",
        ".codex/hooks/" + MODES_FILE,
        "line 41",
        "H2",
        "OrchestrationFeatureFolderResolutionImportFailure",
        "Pester",
        "5.x",
        "breakpoint",
        "compiled",
        "recompilation",
    ),
    "decision": (
        "#936",
        ".codex/hooks/" + EPIC_FILE,
        "183",
        "190",
        "191",
        "206",
        "207",
        "209",
        "ES-D1",
        "ES-D2",
        "exact-reason",
        "Pester",
        "5.x",
        "breakpoint",
        "compiled",
        "recompilation",
    ),
}
USAGE = (
    "USAGE: cov936.py lines|counter|junit <xml> | "
    "header failclosed|decision <file> | descguard <old> <new>"
)


def _base(path_text):
    return path_text.replace("\\", "/").rsplit("/", 1)[-1]


def _read_lines(path):
    return Path(path).read_text(encoding="utf-8-sig").splitlines()


def _description_block(lines):
    start = next((i for i, text in enumerate(lines) if text.strip() == ".DESCRIPTION"), None)
    if start is None:
        return None, None
    end = next((i for i in range(start + 1, len(lines)) if lines[i].strip() == "#>"), None)
    return start, end


def cmd_lines(xml_path):
    root = ET.parse(xml_path).getroot()
    packages = [
        p for p in root.iter("package")
        if p.get("name", "").replace("\\", "/").rstrip("/").endswith(PACKAGE_SUFFIX)
    ]
    print(f"CODEX-PACKAGE-COUNT={len(packages)}")
    if len(packages) != 1:
        return 2
    missing = False
    attributed = set()
    for file_name, numbers in LINE_TARGETS:
        sources = [s for s in packages[0].findall("sourcefile") if s.get("name") == file_name]
        if len(sources) != 1:
            print(f"SOURCEFILE-COUNT {file_name}={len(sources)}")
            missing = True
            continue
        for number in numbers:
            elements = [e for e in sources[0].findall("line") if e.get("nr") == str(number)]
            if len(elements) != 1:
                print(f"LINE-MISSING {file_name}:{number}")
                missing = True
                continue
            hits = int(elements[0].get("ci", "0"))
            state = "ATTRIBUTED" if hits >= 1 else "UNATTRIBUTED"
            print(f"LINE {file_name}:{number} mi={elements[0].get('mi')} ci={hits} {state}")
            if hits >= 1:
                attributed.add((file_name, number))
    if missing:
        return 2
    required = all(target in attributed for target in REQUIRED_ATTRIBUTED)
    print(f"REQUIRED-ATTRIBUTED={required}")
    return 0 if required else 1


def cmd_counter(xml_path):
    root = ET.parse(xml_path).getroot()
    counters = [c for c in root.findall("counter") if c.get("type") == "LINE"]
    if len(counters) != 1:
        print(f"REPORT-LINE-COUNTER-COUNT={len(counters)}")
        return 2
    missed = int(counters[0].get("missed"))
    covered = int(counters[0].get("covered"))
    total = missed + covered
    percent = 100.0 * covered / total if total else 0.0
    print(f"REPORT-LINE missed={missed} covered={covered} LinePercent={percent:.2f}")
    return 0


def cmd_junit(xml_path):
    root = ET.parse(xml_path).getroot()
    rows = []
    for suite in root.iter("testsuite"):
        suite_file = _base(suite.get("name", ""))
        for case in suite.findall("testcase"):
            class_file = _base(case.get("classname", ""))
            source = class_file if class_file.endswith(".ps1") else suite_file
            failed = (
                case.get("status") == "Failed"
                or case.find("failure") is not None
                or case.find("error") is not None
            )
            rows.append((source, case.get("name", ""), case.get("status", ""), failed))
    failures = sorted(f"{source} | {name}" for source, name, _, failed in rows if failed)
    for failure in failures:
        print(f"FAILED-TESTCASE: {failure}")
    print(f"TOTAL={len(rows)} FAILED={len(failures)}")
    all_passed = True
    for suite_name, token, expected in JUNIT_TARGETS:
        matched = [r for r in rows if r[0] == suite_name and token in r[1]]
        passed = [r for r in matched if r[2] == "Passed" and not r[3]]
        print(
            f"TARGET {suite_name} | {token.strip()} "
            f"count={len(matched)} passed={len(passed)} expected={expected}"
        )
        if len(matched) != expected or len(passed) != expected:
            all_passed = False
    print(f"TARGETS-PASSED={all_passed}")
    return 0 if all_passed else 1


def cmd_header(key, path):
    if key not in HEADER_TOKENS:
        print(USAGE)
        return 2
    lines = _read_lines(path)
    print(f"FILE-LINES={len(lines)}")
    start, end = _description_block(lines)
    if start is None or end is None:
        print("DESCRIPTION-BLOCK=NOT-FOUND")
        return 2
    block = lines[start + 1:end]
    all_present = True
    for token in HEADER_TOKENS[key]:
        present = any(token in text for text in block)
        print(f"TOKEN-{'PRESENT' if present else 'ABSENT'} {token}")
        all_present = all_present and present
    print(f"HEADER-TOKENS={'ALL-PRESENT' if all_present else 'INCOMPLETE'}")
    return 0 if all_present else 1


def cmd_descguard(old_path, new_path):
    old_lines = _read_lines(old_path)
    new_lines = _read_lines(new_path)
    old_start, old_end = _description_block(old_lines)
    new_start, new_end = _description_block(new_lines)
    if None in (old_start, old_end, new_start, new_end):
        print("DESCRIPTION-BLOCK=NOT-FOUND")
        return 2
    prefix_equal = old_lines[: old_start + 1] == new_lines[: new_start + 1]
    suffix_equal = old_lines[old_end:] == new_lines[new_end:]
    under_cap = len(new_lines) < 500
    print(f"PREFIX-EQUAL={prefix_equal} SUFFIX-EQUAL={suffix_equal}")
    print(f"OLD-LINES={len(old_lines)} NEW-LINES={len(new_lines)} UNDER-500={under_cap}")
    header_only = prefix_equal and suffix_equal
    print(f"HEADER-ONLY={header_only}")
    return 0 if header_only and under_cap else 1


def main(argv):
    commands = {
        "lines": (cmd_lines, 1),
        "counter": (cmd_counter, 1),
        "junit": (cmd_junit, 1),
        "header": (cmd_header, 2),
        "descguard": (cmd_descguard, 2),
    }
    if len(argv) < 2 or argv[1] not in commands or len(argv) - 2 != commands[argv[1]][1]:
        print(USAGE)
        return 2
    handler = commands[argv[1]][0]
    return handler(*argv[2:])


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

`descguard` compares everything up to and including the `.DESCRIPTION` line and everything from the closing `#>` line to the end of the file; equality of both parts proves that every added or removed line lies inside the `.DESCRIPTION` text, so no `#Requires`, `.SYNOPSIS`, `Describe`, `BeforeAll`, `It`, `Mock`, or assertion line changed.

## Appendix B1 — FC header note (inserted verbatim before FC line 14 `#>`)

The block is ten lines: one empty line, then nine text lines with a four-space indent. After insertion FC has 90 lines.

```text

    Coverage attribution note (issue #936). The two H2 codex deny rows execute line 41 of
    .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, the catch body of
    the feature-folder-resolution.ps1 import guard. Their line-unique assertion checks that
    OrchestrationFeatureFolderResolutionImportFailure equals 'feature-folder-resolution.ps1';
    only line 41 assigns that value. A full-run CI coverage report can still show line 41
    with ci="0". The likely cause is Pester 5.x breakpoint mode: each line breakpoint binds
    to the first compiled instance of a script, and a later recompilation of the unchanged
    file leaves later executions of the line unattributed. A coverage run scoped to
    tests/scripts/codex-hooks attributes the line; the #936 evidence records both results.
```

## Appendix B2 — DEC header note (inserted verbatim before DEC line 16 `#>`)

The block is eleven lines: one empty line, then ten text lines with a four-space indent. After insertion DEC has 108 lines.

```text

    Coverage attribution note (issue #936). ES-D1 executes lines 206 and 207 of
    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, and ES-D2
    executes lines 206 and 209. ES-D1 makes the exact-reason assertion: its deny decision is
    built only by the stand-in block constructor, which only line 207 calls. A full-run CI
    coverage report can still show lines 183, 190, 191, 206, 207, and 209 of that function
    with ci="0"; other Codex suites reach lines 183, 190, and 191. The likely cause is
    Pester 5.x breakpoint mode: each line breakpoint binds to the first compiled instance of
    a script, and a later recompilation of the unchanged file leaves later executions of
    those lines unattributed. A coverage run scoped to tests/scripts/codex-hooks attributes
    lines 206 and 207; the #936 evidence records both results.
```

## Planner Review Record

The record below is the planner's preflight declaration. Its final `PREFLIGHT:` line is the signal the planner expects; it is not executor clearance, which only `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY` can grant.

SELF-REVIEW: RE-DERIVED THIS PASS
Revision 4 pass (executor preflight round 2: P1-T1 porcelain acceptance, P0-T14 and P0-T11 basename-qualified stop conditions, new completion-message section). The first four entries below are the citations this revision introduced or touched; each was re-derived against the current tree of this worktree in this pass. The remaining entries were carried from earlier passes; the sibling regions of the edited regions (P0-T11, P0-T14, P0-T15, P1-T1, P1-T9, P2-T5, SR-2, SR-3, the Execution model section, Appendix A `JUNIT_TARGETS` and `cmd_junit`) were re-read in this pass. P1-T9 and P2-T5 compare whole `FAILED-TESTCASE:` lines against a baseline set, and the HELPER `TARGET` token `H2 codex preimplementation gate denies` does not occur in any Claude-suite row (those rows read `H2 claude`), so neither carries the basename ambiguity.
- .claude/hooks/validate-executor-output.ps1 | plan-path pattern line 73 and rejection line 233; Test-IsPreflightPlan lines 88-97 (whole-line regex at line 96); Get-TouchedLanguagesFromPlan lines 99-123 (extension switch lines 113-118); Test-OutputHasLanguageStatus lines 125-146; preflight short-circuit lines 241-250; non-preflight case-insensitive `-match` rejection lines 252-254 (Repairable false at line 253); unchecked-checkbox rejection lines 256-286; `AC Status Summary` check line 288; command-evidence check line 292; per-language status loop lines 298-307
- tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | same basename as FC; Describe blocks at lines 19, 130, 202, 251, 300, 350, 400; no row named `H2 codex` (its H2 rows at lines 168 and 186 read `H2 claude preimplementation gate denies`)
- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | single Describe `preimplementation gate modes handler proof on the codex surface` at line 16; It rows at lines 36, 38, 44, 50, 67
- artifacts/pester/pester-junit.xml (gitignored run output) | lines 2304-2308: testcase `name` is `<Describe>.<It>`, for example `preimplementation gate modes handler proof on the codex surface.H2 codex preimplementation gate denies ...`; `classname` carries the full test-file path
- .claude/agents/atomic-executor.md | tools allowlist lines 5-24: `Edit` at line 9; no Agent or Task tool
- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 80 lines, LF only (no CR found); line 13 anchor text `case reads orchestration state, and no test creates, renames, moves, or deletes a file.`; line 14 `#>`
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | 97 lines, LF only (no CR found); line 15 anchor text `the only target is the session root. No row creates a file or starts a process.`; line 16 `#>`
- .gitattributes | line 1 `* text=auto eol=lf`
- docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md | Appendix B1 ten lines (FC 80 to 90), Appendix B2 eleven lines (DEC 97 to 108), consistent with P1-T1 numstat, P1-T2/P1-T3 FILE-LINES, and P1-T5/P1-T6 numstat and descguard values
- extensions/drm-copilot/src/mcp-tools.ts | RepoAutomationMcpToolResult lines 61-90: `ok`, `summary`, optional `stderr_excerpt`; no exit-code field
- extensions/drm-copilot/src/command-runtime.ts | CommandExecutionError message `Command exited with code ${input.exitCode ?? "unknown"}.` line 76
- artifacts/pester/pester-junit.xml (gitignored run output, 22:01Z scoped run) | testsuites line 2 failures="2"; codex-detached-head-transport suite line 156 failures="1"; codex-pretooluse-integration suite line 524 failures="1"
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | JUnit OutputPath line 15; CoverageGutters OutputFormat line 21; coverage OutputPath line 22 (re-read for the P0-T9, P0-T12, P1-T7, P2-T3 counter steps)
- .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | line 36 `$null` assignment, line 38 dot-source in `try`, line 40 `catch {`, line 41 the `'feature-folder-resolution.ps1'` assignment; only lines 36 and 41 assign the variable under `.codex`
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | lines 182-183 empty-leg return, 189-191 marker-path reset, 201 readiness scriptblock body, 203-204 `none` return, 206 deny test, 207 sole `Get-OrchestrationPreimplementationGateBlockDecision` call, 209 allow return
- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 80 lines; `.DESCRIPTION` line 8, text 9-13, `#>` line 14; `Register-EpicStateBaselineMock` lines 21-26; H2 deny rows 50-65 and 67-79; assertions at 55 and 71
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | 97 lines; `.DESCRIPTION` line 8, text 9-15, `#>` line 16; `Register-EpicStateBaselineMock` lines 24-25; stand-in constructor 30-40; ES-D1 74-85 with exact-reason assertion at 83; ES-D2 87-96
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | line 373 empty-leg call reaching epic-scope line 183
- config/poshqc-coverage.json | `.codex/hooks` population entry line 6
- .github/workflows/_poshqc.yml | job `poshqc` name `PowerShell QC` windows-latest lines 8-10; `Invoke-PoshQCTest` line 42; artifact `poshqc-test-results` lines 44-52; Linux hook job lines 54-56
- .github/workflows/ci.yml | `poshqc` job calling `_poshqc.yml` lines 23-24
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | file exists (same-basename `.claude/hooks` coverage entry)
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | file exists (same-basename `.claude/hooks` coverage entry)
- extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts | `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` accept `workspace_root` and `scan_folders` (lines 19-80)
- scripts/dev_tools/plan_gate_observability.py | `poshqc-format` register entry markers `formatted`, `unchanged` (lines 184-188)
- scripts/dev_tools/validate_orchestration_artifacts.py | PLAN_PHASE_RE line 48, PLAN_TASK_RE lines 49-51
- docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md | `- Work Mode: minor-audit` line 12; `## Acceptance Criteria` line 38; AC-1 through AC-8 lines 40-47, all unchecked; two pre-existing `- [x] ` boxes (lines 51, 59) that do not match the `- [x] AC-` count literal
- .claude/lib/bash/compute-concurrency-batches.sh | file exists (#884 scope; not touched)
- .codex/hooks/validate-feature-review-coverage.ps1 | file exists (#884 scope; not touched)
PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | catch-body assignment line 41
CITATION: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | Get-OrchestrationEpicScopeDecision lines 183, 190, 191, 201, 206, 207, 209
CITATION: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | .DESCRIPTION line 8, closing #> line 14, H2 assertions lines 55 and 71
CITATION: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | .DESCRIPTION line 8, closing #> line 16, ES-D1 exact-reason assertion line 83, ES-D2 line 87
CITATION: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | empty-leg decision call line 373
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | JUnit OutputPath line 15, coverage OutputPath line 22
CITATION: config/poshqc-coverage.json | .codex/hooks population entry line 6
CITATION: .github/workflows/_poshqc.yml | PowerShell QC job lines 8-10, artifact poshqc-test-results lines 44-52
CITATION: .github/workflows/ci.yml | poshqc job lines 23-24
CITATION: docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md | Work Mode line 12, Acceptance Criteria heading line 38, AC lines 40-47
CITATION: .claude/hooks/validate-executor-output.ps1 | plan-path pattern line 73, Test-IsPreflightPlan lines 88-97, Get-TouchedLanguagesFromPlan lines 99-123, Test-OutputHasLanguageStatus lines 125-146, preflight branch lines 241-250, non-preflight rejection lines 252-254, unchecked-checkbox rejection lines 256-286, AC Status Summary check line 288, language status loop lines 298-307
CITATION: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | same basename as FC; Describe blocks at lines 19, 130, 202, 251, 300, 350, 400; no row named `H2 codex`
CITATION: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | single Describe at line 16 (codex-surface prefix used by the P0-T14 stop condition)
CITATION: extensions/drm-copilot/src/mcp-tools.ts | RepoAutomationMcpToolResult lines 61-90
CITATION: extensions/drm-copilot/src/command-runtime.ts | CommandExecutionError message line 76
CITATION: .claude/agents/atomic-executor.md | tools allowlist lines 5-24, Edit line 9
CITATION: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | P1-T1 anchor lines 13-14, LF line endings (root .gitattributes line 1 eol=lf)
CITATION: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | P1-T1 anchor lines 15-16, LF line endings (root .gitattributes line 1 eol=lf)
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8
AC-MAPPING: AC-1 | IMPLEMENTATION: P1-T1 | TESTS: P0-T5, P1-T2 | EVIDENCE: P1-T2
AC-MAPPING: AC-2 | IMPLEMENTATION: P1-T1 | TESTS: P0-T6, P1-T3 | EVIDENCE: P1-T3
AC-MAPPING: AC-3 | IMPLEMENTATION: P1-T1 | TESTS: P1-T5, P1-T6, P2-T1 | EVIDENCE: P1-T5, P1-T6
AC-MAPPING: AC-4 | IMPLEMENTATION: P1-T1 | TESTS: P0-T10, P1-T7, P1-T8 | EVIDENCE: P1-T8
AC-MAPPING: AC-5 | IMPLEMENTATION: P1-T1 | TESTS: Orchestrator S9 procedure | EVIDENCE: Orchestrator S9 procedure (qa-gates/ci-coverage-attribution)
AC-MAPPING: AC-6 | IMPLEMENTATION: P1-T1 | TESTS: P0-T11, P1-T9, P2-T5 | EVIDENCE: P1-T9, P2-T5
AC-MAPPING: AC-7 | IMPLEMENTATION: P1-T1 | TESTS: P0-T7, P0-T8, P2-T1, P2-T2 | EVIDENCE: P2-T1, P2-T2
AC-MAPPING: AC-8 | IMPLEMENTATION: P1-T1, P1-T4, P1-T11, P2-T9 | TESTS: P2-T6 | EVIDENCE: P2-T6
UNRESOLVED-GAPS: NONE
PREFLIGHT: ALL CLEAR
