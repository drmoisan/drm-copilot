# subagentstop-artifact-gates-review-notes-929 (Plan)

- **Issue:** #929
- **Branch:** bug/subagentstop-artifact-gates-review-notes-929
- **Parent (optional):** none (follow-up to epic #904 child E3, issue #905, PR #908)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T15-44
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`, section `## Acceptance Criteria` (27 items, AC-01 to AC-27; the sole acceptance-criteria source).
- **Inputs read:** `docs/features/active/subagentstop-artifact-gates-review-notes-929/issue.md`; `docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md`.

## Preflight Note

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above is present for the planner and executor preflight rounds. It is removed when the plan is approved for execution.

## Governing Rules

**Fail-closed evidence rule:** Every baseline, regression, targeted-verification, final-QA, and coverage-comparison step has its own artifact under `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/<kind>/`. If any required artifact is missing or lacks a required field, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact. A task is not checked off until that artifact exists. Every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose gate is expected to exit non-zero also carries `ExpectedExitCode: <int>` and records only that one gate.

**Evidence filenames:** Artifacts are named `<name>.<timestamp>.md`. The stamp is the UTC write time read from the host clock immediately before the write (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`). A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md` in the named folder. Evidence locations are limited to `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/` under the feature folder. No evidence is written under `artifacts/`. Tool output that PoshQC writes under `artifacts/pester/` is tool output, not evidence.

**No host paths:** Artifacts never record a host absolute path. The executor worktree root is recorded as the literal token `WORKTREE_ROOT`. Coverage XML package names (which carry absolute paths) are never copied into evidence; only `counter` and `line` elements are copied.

**Scratch location:** `SCRATCH` means `<session scratchpad>/issue-929/`, the child-unique directory for this issue. The caller's instruction "scratch files go under SCRATCH/929/" is implemented as this directory. The executor creates `SCRATCH` before the first scratch write. The only scratch files this plan names are `SCRATCH/powershell-coverage.baseline.xml` and `SCRATCH/powershell-coverage.final.xml`. Nothing under `SCRATCH` is committed. Artifacts record the literal token `SCRATCH`, never a host path.

**Commit and push:** Every phase ends with a commit and `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Never force-push, never rebase pushed history, never delete a file. If a repository hook denies a staging, commit, or push command, record the denial text verbatim beside the affected task, leave the task unchecked, and do not bypass the hook.

**Process runner and fallback:** Pester and coverage commands below run in a child process through `pwsh -NoProfile -Command { ... }`, issued from the PowerShell tool so the scriptblock is passed without re-quoting. If a hook refuses a command because it contains the text `pwsh`, run the identical scriptblock through `& (Get-Process -Id $PID).Path -NoProfile -Command { ... }`, which starts the same executable, and record which form ran. Read-only commands with no `pwsh` prefix run directly in the PowerShell tool session. All commands run from the worktree root.

**Verification policy (Option A):** Local verification uses the PoshQC MCP tools `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, plus CI evidence. A PoshQC MCP result carries no per-test output, count, percentage, or finding, so no acceptance condition in this plan reads any of those from an MCP result; only the call disposition (`EXIT_CODE: 0` when the call returned, non-zero when it raised) is recorded. Counts, named-test results, analyzer findings, and coverage come from (a) the child-process Pester runner, which prints its own `Passed | <name>` lines and `FAILED=`/`PASSED=` totals, (b) direct `Invoke-ScriptAnalyzer` per file, and (c) the self-hosted PoshQC module's `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`.

**Self-hosted coverage run:** `Invoke-PoshQCTest` from `scripts/powershell/PoshQC/PoshQC.psd1` reads `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, where `Run.Exit = $true` (line 4), so the child process exit code equals the failed-test count, and it writes JUnit to `artifacts/pester/pester-junit.xml` and JaCoCo-shaped coverage to `artifacts/pester/powershell-coverage.xml` (lines 12-22). Coverage roots come from `config/poshqc-coverage.json` (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`); `tests/` and `extensions/` are outside the denominator. The baseline and the final run use the same scan folders (`tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`) so the counters are comparable. Per-file counters are read by keying on the enclosing `package` element whose name, with `\` replaced by `/`, ends with `/.claude/hooks`, never on the bare `sourcefile` name. This closes NB-10 (process only; no code change).

**Coverage policy:** PowerShell line coverage >= 85% applies (root `CLAUDE.md` states no threshold, so the default governs); PowerShell has no branch-coverage gate. `quality-tiers.yml` classifies `.claude/hooks` as T3, so no property-test or mutation obligation applies. The only production file whose lines change is `.claude/hooks/validate-task-researcher-output.ps1`; its `sourcefile` LINE counters and the `line` elements of the changed lines are recorded verbatim at baseline and final. Python is not edited, so no Python coverage obligation applies; the two Python contract modules are run for mirror parity and pinned strings.

**Known local failure (issue #510):** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally on gitignored `.claude/state/**` files while passing in CI. The #510 signature is: that node fails and every assertion message it prints names a path beginning `.claude/state/` or `.claude\state\`. A failure with that signature is pre-existing; any other failure of that node is a regression.

**No expect-fail task (AC-25):** Every new test in this plan is a characterization test against unchanged behavior, and NB-5 preserves behavior. No regression test can fail before the change, so this plan contains no expect-fail task. P1-T1 records the fail-before exception dossier instead.

**NB-9 placement decision (resolved here; not left to the executor):** The sibling suite `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` IS created. Computation: research section 6 records the current line count of `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` as 358 (re-derived in this pass: 358). The concrete NB-3 insertion in Appendix B is 70 lines, giving 428 after Phase 2. The NB-9 cases written in place would be 43 lines (one blank line, the Context line, a five-line `BeforeAll` holding two comment lines, the message, and the envelope built with the suite's existing `ConvertTo-DiscoveryEnvelopeJson`, one blank line, the 15-line and 17-line `It` blocks of Appendix C separated by one blank line, and the Context's closing brace), giving 471 at the time of insertion, above the 470-line rule. Research section 6 projected about 435 because it assumed about 40 NB-3 lines and netted out the NB-4 builder removal, which this plan performs last. A second reason: issue #928 is expected to add an exit-2 case to the same suite, which would reduce the remaining headroom below 500 further. The decision holds for any observed Phase 2 line count above 427 (427 + 43 = 470); P2-T3 verifies this premise.

**NB-10 (process only):** No code change. The plan records the per-file coverage counters verbatim in `evidence/baseline/` and `evidence/qa-gates/` (P0-T24, P9-T5, P9-T6) so a reviewer in another worktree does not depend on the gitignored XML.

**Concurrency with issue #928 and overlap:** Issue #928 (branch `bug/subagentstop-hook-uncaught-error-exits-1-928`) edits the SubagentStop validators and `.claude/hooks/subagentstop-envelope.ps1`. This plan's only production edits are the NB-5 hunk in `.claude/hooks/validate-task-researcher-output.ps1` (lines 244, 245, 249, 266, inside `Invoke-TaskResearcherOutputValidation`) and the same hunk in its bundle mirror. That hunk conflicts with #928 only if #928 wraps the function body. `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, and `.claude/hooks/hook-dependency-guard.ps1` are not edited. Test-side overlap is the seven E3 suites; the NB-4 conversion is therefore the last implementation phase (Phase 8), preceded by the #928 sequencing check and merge (Phase 7). Planner observation at authoring (2026-10-15, file-system read only; the planner has no shell tool): the local remote-tracking ref `refs/remotes/origin/bug/subagentstop-hook-uncaught-error-exits-1-928` exists; whether #928 is merged into `main` was not determinable without git. P0-T15 and P7-T1 run the git checks the spec requires and record the result.

**Correction to the spec's suite grouping:** `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.SpecialCases.Tests.ps1` are under `tests/scripts/claude-hooks/`, not `tests/scripts/claude-runtime/` (re-derived in this pass). `hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` are under `tests/scripts/claude-runtime/`.

**E3 folder location:** The E3 feature folder `subagentstop-envelope-artifact-gates-905` is resolved at execution time (P0-T16) to exactly one of `docs/features/active/subagentstop-envelope-artifact-gates-905/` or `docs/features/archive/subagentstop-envelope-artifact-gates-905/`. Every task that names the E3 spec writes the active path and substitutes the archive path when P0-T16 recorded the archive location. If the folder is in neither location, the task stops and reports.

**500-line limit:** No touched `.ps1` file may exceed 500 lines. Expected counts are stated in the tasks.

**Fixed names used below:**
- FEATURE: `docs/features/active/subagentstop-artifact-gates-review-notes-929`
- Production file and mirror: `.claude/hooks/validate-task-researcher-output.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`
- The seven E3 suites (all under `tests/scripts/claude-hooks/`): `validate-prd-feature-output.Tests.ps1`, `validate-prd-feature-output.Coverage.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, `validate-task-researcher-output.Coverage.Tests.ps1`, `validate-pr-author-output.Tests.ps1`, `validate-pr-author-output.Coverage.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`
- New files: `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` (Appendix C), `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` (Appendix F)
- Registration suites: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
- Python contract modules: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md` (repository root) in full. Acceptance: read in full; the policy reading order, the four-layer architecture, and the orchestration checkpoint path are noted for `evidence/baseline/phase0-instructions-read.<timestamp>.md` (P0-T13).
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full. Acceptance: read in full; the 500-line limit, the toolchain loop order, and the no-temporary-files rule for tests are noted.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full. Acceptance: read in full; the 85% line default, the PowerShell branch-coverage exemption, the coverage exclusion policy, and the test-location rule are noted.
- [ ] [P0-T4] Read `.claude/rules/powershell.md` in full. Acceptance: read in full; the format, analyze, test order through PoshQC and the 500-line limit are noted.
- [ ] [P0-T5] Read `.claude/rules/quality-tiers.md` in full and the `.claude/hooks` entry of `quality-tiers.yml`. Acceptance: the entry reads `tier: T3`; no property-test or mutation obligation applies to the changed production file.
- [ ] [P0-T6] Read `.github/copilot-instructions.md` in full. Acceptance: read in full.
- [ ] [P0-T7] Read `.github/instructions/general-code-change.instructions.md` in full. Acceptance: read in full.
- [ ] [P0-T8] Read `.github/instructions/general-unit-test.instructions.md` in full. Acceptance: read in full.
- [ ] [P0-T9] Read `.github/instructions/powershell-code-change.instructions.md` in full. Acceptance: read in full.
- [ ] [P0-T10] Read `.github/instructions/powershell-unit-test.instructions.md` in full. Acceptance: read in full.
- [ ] [P0-T11] Read `.claude/rules/tonality.md` and `.github/instructions/tonality.instructions.md` in full. Acceptance: read in full; evidence and documentation text written by this plan uses the professional tone they require.
- [ ] [P0-T12] Read `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`, `docs/features/active/subagentstop-artifact-gates-review-notes-929/issue.md`, and `docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md` in full. Acceptance: `issue.md` carries `- Work Mode: full-bug`; `spec.md` `## Acceptance Criteria` holds 27 unchecked items AC-01 to AC-27.
- [ ] [P0-T13] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/phase0-instructions-read.<timestamp>.md` containing `Timestamp:`, `Policy Order:` (the files of P0-T1 to P0-T11 in the order read), and an explicit list of every file read in P0-T1 to P0-T12. Acceptance: the artifact exists and lists all 16 files.
- [ ] [P0-T14] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/branch-commit-baseline.<timestamp>.md` from `git branch --show-current`, `git rev-parse HEAD`, `git fetch origin main`, and `git merge-base origin/main HEAD`, one `Command:`/`EXIT_CODE:` pair per command. Acceptance: each `EXIT_CODE: 0`; `Output Summary:` records the branch name `bug/subagentstop-artifact-gates-review-notes-929`, the HEAD hash, and the merge-base hash.
- [ ] [P0-T15] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/issue-928-status-baseline.<timestamp>.md` from `git ls-remote --heads origin bug/subagentstop-hook-uncaught-error-exits-1-928`, `git log origin/main --oneline -5 -- .claude/hooks`, and `git log origin/main --oneline --grep=subagentstop-hook-uncaught-error-exits-1-928`. Acceptance: each command's exit code and full output are recorded; `Output Summary:` states whether the remote branch exists (the `ls-remote` output has one line) and classifies #928 as `MERGED` when the `--grep` log prints at least one line, else `NOT-MERGED`.
- [ ] [P0-T16] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/e3-folder-location.<timestamp>.md` from `Test-Path -LiteralPath docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` and `Test-Path -LiteralPath docs/features/archive/subagentstop-envelope-artifact-gates-905/spec.md`, then `Select-String -Path <the existing spec> -Pattern '^- \[x\] AC-11:','^- \[x\] AC-20:'`. Acceptance: exactly one `Test-Path` prints `True`; `Output Summary:` records `E3_SPEC: docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` or the archive path, and the two matched line numbers (377 and 386 when the folder is unchanged since authoring). If neither or both print `True`, stop and report.
- [ ] [P0-T17] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/line-counts-baseline.<timestamp>.md` from `foreach ($f in @('.claude/hooks/validate-task-researcher-output.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1','tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1')) { if (Test-Path -LiteralPath $f) { '{0} | LINES={1}' -f $f, (Get-Content -LiteralPath $f).Count } else { '{0} | ABSENT' -f $f } }`. Acceptance: `EXIT_CODE: 0`; the eleven output lines are recorded; expected values are 290, 290, 223, 201, 418, 320, 114, 140, 358, `ABSENT`, `ABSENT`. A differing value is recorded and the affected later expected counts are adjusted by the same difference.
- [ ] [P0-T18] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/mirror-parity-baseline.<timestamp>.md` from `git hash-object --no-filters .claude/hooks/validate-task-researcher-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`. Acceptance: `EXIT_CODE: 0`; the two printed hashes are equal and are recorded labelled by path.
- [ ] [P0-T19] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/builder-census-baseline.<timestamp>.md` from `git grep -c New-SubagentStopEnvelopeJson -- tests` and `git grep -l "Builds and returns envelope JSON text only" -- tests`. Acceptance: both exit 0; the first lists exactly the seven E3 suites with counts summing to 68 (7 definitions, 61 call sites); the second lists the same seven paths.
- [ ] [P0-T20] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/poshqc-format-baseline.<timestamp>.md`: record `git status --porcelain` output, call `mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","extensions/drm-copilot/resources/claude-customizations/.claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, then record `git status --porcelain` output again. Acceptance: the MCP call disposition is recorded as `EXIT_CODE:`; the two porcelain outputs are identical, so every tracked file is unchanged by the formatter. If they differ, `Output Summary:` lists each path the formatter changed as `PRE-EXISTING-DRIFT: <path>`, those paths are restored with `git restore --source=HEAD --worktree -- <path>`, and P9-T1 treats exactly those paths as known drift.
- [ ] [P0-T21] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/poshqc-analyze-baseline.<timestamp>.md`: call `mcp__drm-copilot__run_poshqc_analyze workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","tests/scripts/claude-hooks"]` and record its disposition, then run `pwsh -NoProfile -Command { $n = 0; foreach ($f in @('.claude/hooks/validate-task-researcher-output.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1')) { $d = @(Invoke-ScriptAnalyzer -Path $f -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information); $n += $d.Count; '{0} | FINDINGS={1}' -f $f, $d.Count }; 'TOTAL_FINDINGS=' + $n }`. Acceptance: the MCP disposition is recorded (call-disposition only; no finding count is read from it); the direct run's exit code and its ten output lines are recorded; `Output Summary:` quotes the `TOTAL_FINDINGS=` line (expected `TOTAL_FINDINGS=0`; a non-zero value is recorded as pre-existing with each file's findings).
- [ ] [P0-T22] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/poshqc-test-mcp-baseline.<timestamp>.md` from one call to `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=["tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`. Acceptance: `Command:` records that form, `EXIT_CODE:` records the call disposition, and `Output Summary:` records only the disposition; no test count, percentage, or test name is recorded from it.
- [ ] [P0-T23] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/pester-selfhosted-baseline.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/claude-runtime') }` followed by `pwsh -NoProfile -Command { [xml]$j = Get-Content -LiteralPath artifacts/pester/pester-junit.xml -Raw; $s = $j.SelectSingleNode('/testsuites'); 'TESTS=' + $s.GetAttribute('tests') + ' FAILURES=' + $s.GetAttribute('failures') + ' ERRORS=' + $s.GetAttribute('errors'); $j.SelectNodes('//testcase[failure]') | ForEach-Object { 'FAILED_CASE | ' + $_.GetAttribute('name') } }`. Record the run start time before the first command and the `LastWriteTimeUtc` of `artifacts/pester/powershell-coverage.xml` after it. Acceptance: the first command's exit code (the failed-test count, because `Run.Exit = $true`) is recorded; the second command prints a `TESTS=` line and is recorded with every `FAILED_CASE |` line; the XML write time is later than the run start time. A non-zero failed count is recorded as the pre-existing local failure set, which P9-T4 compares against.
- [ ] [P0-T24] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/coverage-counters-baseline.<timestamp>.md` immediately after P0-T23, from `pwsh -NoProfile -Command { [xml]$x = Get-Content -LiteralPath artifacts/pester/powershell-coverage.xml -Raw; $m = @($x.SelectNodes('/report/package') | Where-Object { ($_.GetAttribute('name') -replace '\\', '/') -like '*/.claude/hooks' } | ForEach-Object { $_.SelectNodes('sourcefile') } | Where-Object { $_.GetAttribute('name') -eq 'validate-task-researcher-output.ps1' }); 'SOURCEFILE_MATCHES=' + $m.Count; $m | ForEach-Object { $_.SelectNodes('counter') } | Where-Object { $_.GetAttribute('type') -eq 'LINE' } | ForEach-Object { $_.OuterXml }; $nrs = @(Select-String -Path .claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern 'IsNullOrWhiteSpace($agentOutput)','-AgentOutput $agentOutput' | ForEach-Object { [string]$_.LineNumber }); 'CHANGED_LINES=' + ($nrs -join ','); $m | ForEach-Object { $_.SelectNodes('line') } | Where-Object { $_.GetAttribute('nr') -in $nrs } | ForEach-Object { $_.OuterXml } }`. Acceptance: `EXIT_CODE: 0`; the output prints `SOURCEFILE_MATCHES=1`, exactly one `<counter type="LINE" ... />` element, `CHANGED_LINES=245,249,266`, and three `<line nr=... />` elements; all are copied verbatim into the artifact (this is the NB-10 baseline record); `Output Summary:` states the baseline `missed` and `covered` values and the line percentage `covered / (covered + missed)`.
- [ ] [P0-T25] Create `SCRATCH` if absent, copy `artifacts/pester/powershell-coverage.xml` to `SCRATCH/powershell-coverage.baseline.xml` with `Copy-Item`, and record `(Get-FileHash -Algorithm SHA256 -LiteralPath artifacts/pester/powershell-coverage.xml).Hash` and the same for the copy in `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/coverage-xml-copy-baseline.<timestamp>.md`. Acceptance: both hashes are printed and equal; the artifact records the copy as `SCRATCH/powershell-coverage.baseline.xml`.
- [ ] [P0-T26] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/target-suites-baseline.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1','tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1','tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: this run is the success-case observation of the runner format used by every later runner task; the artifact records the exit code, the full list of `<Result> | <name>` lines, and the `FAILED=` and `PASSED=` lines; `Output Summary:` quotes those two lines and confirms that lines of the form `Passed | R3 accepts the exhaustive scope entire worktree` are printed. Expected `FAILED=0`; any failure is recorded by name as pre-existing.
- [ ] [P0-T27] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/python-contracts-baseline.<timestamp>.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -q`. Acceptance: the exit code and the pytest summary line (for example `N passed`) are recorded; when the exit code is non-zero, `Output Summary:` lists every failing node ID and classifies a failure of `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as `ISSUE-510 SIGNATURE` or `OTHER FAILURE` under the definition in Governing Rules.
- [ ] [P0-T28] Commit and push Phase 0 for `docs/features/active/subagentstop-artifact-gates-review-notes-929/`: run `git add docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "docs(929): record phase 0 baseline evidence"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain -- docs/features/active/subagentstop-artifact-gates-review-notes-929/` lists nothing other than this plan file, and `git rev-parse HEAD` and `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929` print the same hash; the commit hash is recorded beside this task.

### Phase 1 — R3 Characterization Rows (NB-1, NB-2)

All edits in this phase are insertions into existing `-ForEach` tables; no existing row, Arrange line, or assertion is changed. Rows use the indentation of their neighbouring rows (12 spaces in the prd-feature suite, 8 spaces in the task-researcher Coverage suite).

- [ ] [P1-T1] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/fail-before-exception.<timestamp>.md` with `Timestamp:`, `WhyFailingRunImpossible:` (every new test is a characterization test against unchanged behavior, and the NB-5 edit removes a redundant alias without changing behavior, so no test can fail before the change), an alternative-proof section (the R3 regular expression, R4 trimming, dispatch loop, and dependency-decision statement are unchanged, verified by P9-T8 and P9-T11; the new tests pass on first run, which P1-T6, P1-T7, P2-T2, P3-T2, and P4-T2 record), and `SearchScope: docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/`, `SearchPatterns: fail-before-exception.*.md`, `SearchResult: none` (recorded before the write). Acceptance: the artifact exists with all six fields and states that the plan contains no expect-fail task.
- [ ] [P1-T2] Edit `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`: in Context `Test-NumericDerivationEvidence rule R3 (issue #905)`, insert the nine lines of Appendix A1 immediately after the row `@{ Name = 'entire repository accepted before R3'; Value = 'entire repository' }` of `It 'R3 accepts the exhaustive scope <Name>'`. Acceptance: the accept table holds 10 rows and 2 comment lines; each comment line contains `E3 spec Risk 5a`.
- [ ] [P1-T3] Edit `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`: insert the six lines of Appendix A2 immediately after the row `@{ Name = 'the hooks folder'; Value = 'the hooks folder' }` of `It 'R3 rejects the exhaustive scope <Name>'`. Acceptance: the reject table holds 7 rows; the Arrange line and the exact message assertion of that `It` are unchanged.
- [ ] [P1-T4] Edit `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`: in Describe `Test-NumericDerivationEvidence rule R3 (issue #905)`, insert the nine lines of Appendix A1 (re-indented to 8 spaces) immediately after the row `@{ Name = 'entire repository accepted before R3'; Value = 'entire repository' }`. Acceptance: the accept table holds 10 rows and 2 comment lines containing `E3 spec Risk 5a`.
- [ ] [P1-T5] Edit `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`: insert the six lines of Appendix A2 (re-indented to 8 spaces) immediately after the row `@{ Name = 'the hooks folder'; Value = 'the hooks folder' }`. Acceptance: the reject table holds 7 rows; the message assertion `'task-researcher hook: numeric derivation evidence does not declare an exhaustive repository search scope.'` is unchanged.
- [ ] [P1-T6] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/r3-prd-feature.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0`; it contains `Passed | R3 accepts the exhaustive scope <n>` for each of the 10 accept names (the 3 existing names and the 7 Appendix A1 names) and `Passed | R3 rejects the exhaustive scope <n>` for each of the 7 reject names (`the hooks folder` and the 6 Appendix A2 names); `Output Summary:` lists the 17 lines (AC-01, AC-03).
- [ ] [P1-T7] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/r3-task-researcher.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0` and the same 17 `Passed | R3 ...` lines as P1-T6 (AC-02, AC-03).
- [ ] [P1-T8] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/r3-line-counts.<timestamp>.md` from `(Get-Content -LiteralPath tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1).Count` and `(Get-Content -LiteralPath tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1).Count`. Acceptance: the values are 238 and 335 (P0-T17 baseline plus 15 each).
- [ ] [P1-T9] Commit and push Phase 1: run `git add tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "test(929): add R3 characterization rows (NB-1, NB-2)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 2 — R4 Trim-Only Token Cases (NB-3)

- [ ] [P2-T1] Edit `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`: insert the 70 lines of Appendix B inside Context `Find-DiscoveryArtifactReference rule R4 (issue #905)`, immediately after the closing brace of `It 'R4 skips a token that is empty after trimming'` and before the Context's closing brace. Acceptance: the Context holds 6 `It` blocks; the existing `It` is unchanged.
- [ ] [P2-T2] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/r4-discovery.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0` and these `Passed |` lines: `R4 returns no reference for a lone backtick token`, `R4 returns no reference for an empty-after-trim token`, `R4 skips a lone backtick token and returns the following discovery reference`, `R4 skips the trim-only token () and returns the discovery reference`, `R4 skips the trim-only token [] and returns the discovery reference`, `R4 skips the trim-only token '' and returns the discovery reference`, `R4 skips the trim-only token , and returns the discovery reference`, `R4 skips the trim-only token ; and returns the discovery reference`, `R4 gate allows a message containing only a lone backtick without invoking the validator` (AC-05, AC-06).
- [ ] [P2-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/nb9-placement-decision.<timestamp>.md` from `(Get-Content -LiteralPath tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1).Count`. Acceptance: the value is 428; the artifact quotes the NB-9 placement decision from Governing Rules and records that the observed count plus 43 exceeds 470, so the sibling suite is created. If the observed count is 427 or lower, stop and report for plan revision.
- [ ] [P2-T4] Commit and push Phase 2: run `git add tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "test(929): add R4 trim-only token cases (NB-3)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 3 — Validator Dispatch Suite (NB-9)

- [ ] [P3-T1] Create `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` with exactly the content of Appendix C (file name case exactly as written, for the Linux CI job). Acceptance: the file exists and its content equals Appendix C.
- [ ] [P3-T2] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb9-dispatch.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0`, `PASSED=2`, `Passed | dispatches each distinct discovery reference exactly once`, and `Passed | stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED` (AC-16, AC-17).
- [ ] [P3-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb9-checks.<timestamp>.md` from `@(Select-String -Path tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1 -SimpleMatch -Pattern 'profile_cli').Count` and `(Get-Content -LiteralPath tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1).Count`. Acceptance: the first value is 0 (no `profile_cli.py` reference in the suite or its input); the second is 66.
- [ ] [P3-T4] Commit and push Phase 3: run `git add tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1 docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "test(929): add discovery validator dispatch suite (NB-9)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 4 — In-Process Dependency-Decision Test (NB-11)

- [ ] [P4-T1] Edit `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`: append the 23 lines of Appendix D after the file's last line (the closing brace of Describe `Test-NumericDerivationEvidence rule R3 (issue #905)`). Acceptance: the file ends with the new Describe `Invoke-TaskResearcherOutputValidation dependency decision in process (issue #929)`; no earlier line changes.
- [ ] [P4-T2] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb11-dependency-decision.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0`, `Passed | returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)`, and the 17 `Passed | R3 ...` lines of P1-T7 (AC-19).
- [ ] [P4-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb11-line-count.<timestamp>.md` from `(Get-Content -LiteralPath tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1).Count`. Acceptance: the value is 358.
- [ ] [P4-T4] Commit and push Phase 4: run `git add tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "test(929): pin in-process dependency-decision return (NB-11)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 5 — Alias Removal (NB-5, Only Production Edit)

This is the only production change. It is behavior-preserving: `$agentOutput` is assigned from `$assistantMessage` and never reassigned, so each read returns the same value.

- [ ] [P5-T1] Edit `.claude/hooks/validate-task-researcher-output.ps1` inside `Invoke-TaskResearcherOutputValidation`: delete the line `    $agentOutput = $assistantMessage`; replace `if ([string]::IsNullOrWhiteSpace($agentOutput)) {` with `if ([string]::IsNullOrWhiteSpace($assistantMessage)) {`; replace `Get-ResearchPathFromOutput -AgentOutput $agentOutput` with `Get-ResearchPathFromOutput -AgentOutput $assistantMessage`; replace `-ResearchFilePath $researchPath -AgentOutput $agentOutput` with `-ResearchFilePath $researchPath -AgentOutput $assistantMessage`. Acceptance: no other line changes; the first two statements of the function are unchanged.
- [ ] [P5-T2] Apply the identical four edits from P5-T1 to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`. Acceptance: the same four edits are present and no other line changes.
- [ ] [P5-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb5-alias-removal.<timestamp>.md` from `@(Select-String -CaseSensitive -Pattern '\$agentOutput\b' -Path .claude/hooks/validate-task-researcher-output.ps1,extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1).Count` and `Select-String -SimpleMatch -Pattern 'IsNullOrWhiteSpace($assistantMessage)','-AgentOutput $assistantMessage' -Path .claude/hooks/validate-task-researcher-output.ps1,extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | ForEach-Object { '{0}:{1}' -f (Resolve-Path -Relative -LiteralPath $_.Path), $_.LineNumber }`. Acceptance: the first value is 0; the second prints three relative-path lines per file, at lines 244, 248, and 265 in each, so `Invoke-TaskResearcherOutputValidation` reads `$assistantMessage` at the former alias sites (AC-11).
- [ ] [P5-T4] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb5-mirror-parity.<timestamp>.md` from `git hash-object --no-filters .claude/hooks/validate-task-researcher-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` and `(Get-Content -LiteralPath .claude/hooks/validate-task-researcher-output.ps1).Count`. Acceptance: the two hashes are equal and differ from the P0-T18 hash; the line count is 289.
- [ ] [P5-T5] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb5-python-contracts.<timestamp>.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -q`. Acceptance: `EXIT_CODE: 0` with a summary line reporting zero failed; or, only when the sole failing node is `test_bundled_claude_payload_contains_all_repo_runtime_contracts` with the `ISSUE-510 SIGNATURE`, the artifact carries `ExpectedExitCode: 1`, quotes every assertion message, and records a second run of the same command with `--deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` that exits 0. `test_numeric_provenance_contract_requires_full_family_and_cross_check` passes in both cases (AC-12).
- [ ] [P5-T6] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb5-task-researcher-suites.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0` and `Passed | has no S1, S2, S3 or S6 guard-shape finding`.
- [ ] [P5-T7] Commit and push Phase 5: run `git add .claude/hooks/validate-task-researcher-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "fix(929): remove redundant agentOutput alias (NB-5)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 6 — E3 Post-Review Clarifications (NB-7, NB-8)

These are cross-folder documentation edits in the E3 feature folder `subagentstop-envelope-artifact-gates-905`, at the location recorded in P0-T16. Each edit inserts one line; no checkbox state changes. The #929 spec already records both resolutions under "Data flow and validation changes".

- [ ] [P6-T1] Edit `docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` (or `docs/features/archive/subagentstop-envelope-artifact-gates-905/spec.md` per P0-T16): insert the line of Appendix E1 immediately after the line beginning `- [x] AC-20:`. Acceptance: the AC-20 line is unchanged and is followed directly by the inserted line.
- [ ] [P6-T2] Edit the same E3 spec (`docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` or the archive path per P0-T16): insert the line of Appendix E2 immediately after the line beginning `- [x] AC-11:`. Acceptance: the AC-11 line is unchanged and is followed directly by the inserted line.
- [ ] [P6-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/e3-clarifications.<timestamp>.md` from `Select-String -Path docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md -Pattern '^- \[x\] AC-11:','^- \[x\] AC-20:','^  Post-review clarification \(2026-10-15, issue #929\):' | ForEach-Object { '{0} | {1}' -f $_.LineNumber, $_.Line.Substring(0, [Math]::Min(60, $_.Line.Length)) }` and `git diff --numstat origin/main -- docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` (archive path per P0-T16 in both). Acceptance: four lines are printed; each clarification line number is its AC line number plus 1; both AC lines still begin `- [x]`; the numstat row reads `2` added and `0` deleted (AC-14, AC-15).
- [ ] [P6-T4] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/spec-decision-records.<timestamp>.md` from `Select-String -Path docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md -SimpleMatch -Pattern 'Candidate rule','NB-7 resolution','NB-8 resolution','NB-10 resolution','NB-11: no production change','NB-2: no R3 production rule change' | ForEach-Object { '{0} | {1}' -f $_.LineNumber, $_.Pattern }`. Acceptance: each of the six patterns is reported at least once, confirming the spec records the NB-2 decision with its candidate-rule table and the NB-7, NB-8, NB-10, and NB-11 resolutions (AC-04 spec record, AC-15 spec record).
- [ ] [P6-T5] Commit and push Phase 6: run `git add docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md docs/features/active/subagentstop-artifact-gates-review-notes-929/` (archive path per P0-T16), then `git commit -m "docs(929): add E3 post-review clarifications (NB-7, NB-8)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.

### Phase 7 — Concurrent Issue #928 Sequencing Check

This phase runs immediately before the NB-4 conversion. It brings the branch up to date with `main` by merge only (no rebase, no force-push), so any #928 call site is present before conversion.

- [ ] [P7-T1] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/issue-928-sequencing.<timestamp>.md` from `git fetch origin main`, `git ls-remote --heads origin bug/subagentstop-hook-uncaught-error-exits-1-928`, `git log origin/main --oneline --grep=subagentstop-hook-uncaught-error-exits-1-928`, `git log origin/main --oneline -5 -- .claude/hooks tests/scripts/claude-hooks`, and `git merge-base --is-ancestor origin/main HEAD`; when the `ls-remote` output is non-empty, also `git fetch origin bug/subagentstop-hook-uncaught-error-exits-1-928` and `git merge-base --is-ancestor FETCH_HEAD origin/main`. Acceptance: every command's exit code and output are recorded; `Output Summary:` classifies #928 as `MERGED` when the `--grep` log prints at least one line or the branch is-ancestor check exits 0, else `NOT-MERGED`, and records `BRANCH-CONTAINS-MAIN: yes` when `git merge-base --is-ancestor origin/main HEAD` exits 0, else `no`.
- [ ] [P7-T2] When P7-T1 recorded `BRANCH-CONTAINS-MAIN: no` (whether #928 is `MERGED` or `NOT-MERGED`), run `git merge --no-edit origin/main` on `bug/subagentstop-artifact-gates-review-notes-929`; when it recorded `yes`, run no merge and record `NO-MERGE-NEEDED`. Conflict rules: in the seven E3 suites keep both sides' additions; in `.claude/hooks/validate-task-researcher-output.ps1` and its mirror take the `origin/main` text and re-apply the four P5-T1 edits so both copies stay text-identical; in any other file take the `origin/main` text; then `git add` the resolved paths and `git commit --no-edit`. Record the outcome in `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/merge-main.<timestamp>.md`. Acceptance: the artifact records the merge command's exit code, every conflicted path with the rule applied, and the resulting HEAD hash; afterwards `git merge-base --is-ancestor origin/main HEAD` exits 0. If a conflict cannot be resolved by these rules, stop and report.
- [ ] [P7-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/post-merge-verification.<timestamp>.md` from `@(Select-String -CaseSensitive -Pattern '\$agentOutput\b' -Path .claude/hooks/validate-task-researcher-output.ps1,extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1).Count`, `git hash-object --no-filters .claude/hooks/validate-task-researcher-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`, and `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: the alias count is 0; the two hashes are equal; the runner prints `FAILED=0`; the `PASSED=` value is recorded as the pre-conversion total for P8-T12.
- [ ] [P7-T4] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/conversion-set.<timestamp>.md` from `git grep -c New-SubagentStopEnvelopeJson -- tests`. Acceptance: the output is recorded; `Output Summary:` lists the conversion set, defined mechanically as every path the command prints; paths other than the seven E3 suites are listed as `ADDITIONAL: <path> | <count>` (expected none when #928 is `NOT-MERGED`).
- [ ] [P7-T5] Commit and push Phase 7: run `git add docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "docs(929): record issue 928 sequencing check"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the merge commit hash (if any) and this commit hash are recorded beside this task.

### Phase 8 — Shared Envelope Helper Extraction (NB-4)

This is the last implementation phase. Each suite conversion: (a) replace the nine-line local `function New-SubagentStopEnvelopeJson { ... }` block (definition line through its closing brace) with the single line `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation, in the same `BeforeAll`; (b) replace every remaining occurrence of `New-SubagentStopEnvelopeJson` in that suite with `ConvertTo-SubagentStopEnvelopeJson -AgentType '<agent>'`, where `<agent>` is the `agent_type` value the removed block carried (`general-purpose` suites omit `-AgentType`). No assertion or other line changes. Every count check below uses `Select-String -SimpleMatch`, which counts matching lines. The expected `ConvertTo-` count for a suite is its P7-T4 `git grep -c` count minus 1 (the removed definition line); the figures in the tasks are those values for the authoring tree.

- [ ] [P8-T1] Create `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` with exactly the content of Appendix F (file name case exactly as written). Acceptance: the file exists, its content equals Appendix F, and `@(Select-String -Path tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1 -SimpleMatch -Pattern 'SuppressMessageAttribute').Count` prints 0 (AC-07).
- [ ] [P8-T2] Convert `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` (block at lines 32-40 at authoring, file-level `BeforeAll`; agent `prd-feature`). Acceptance: `@(Select-String -Path tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count` prints 0; `-Pattern 'SubagentStopEnvelope.Helpers.ps1'` matches exactly one line, which contains `Join-Path $PSScriptRoot`; `-Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature'"` matches 7 times (the P7-T4 count minus 1).
- [ ] [P8-T3] Convert `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1` (block at lines 24-32; agent `prd-feature`). Acceptance: the same three checks as P8-T2 against this file; the `ConvertTo-` count is 10.
- [ ] [P8-T4] Convert `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (block at lines 41-49, file-level `BeforeAll`; agent `task-researcher`). Acceptance: the same three checks against this file; the `ConvertTo-` count is 12.
- [ ] [P8-T5] Convert `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (block at lines 24-32, first Describe `BeforeAll`; agent `task-researcher`). Acceptance: the same three checks against this file; the `ConvertTo-` count is 10; the Appendix D Describe is unchanged.
- [ ] [P8-T6] Convert `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` (block at lines 15-23; agent `pr-author`). Acceptance: the same three checks against this file; the `ConvertTo-` count is 8.
- [ ] [P8-T7] Convert `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1` (block at lines 18-26; agent `pr-author`). Acceptance: the same three checks against this file; the `ConvertTo-` count is 6.
- [ ] [P8-T8] Convert `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` (block at lines 180-188 at authoring, inside Context `script entrypoint (stdin envelope, issue #905)` `BeforeAll`; agent `general-purpose`, so call sites are renamed without `-AgentType`). Acceptance: the `New-` count is 0; the helper line matches once and contains `Join-Path $PSScriptRoot`; `-Pattern 'ConvertTo-SubagentStopEnvelopeJson'` matches 8 times; `ConvertTo-DiscoveryEnvelopeJson` is unchanged.
- [ ] [P8-T9] Edit `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1`: replace the single line beginning `        $script:DispatchEnvelope = [ordered]@{` with the two lines of Appendix C2. Acceptance: the file has 67 lines; `-Pattern 'SubagentStopEnvelope.Helpers.ps1'` matches once.
- [ ] [P8-T10] For each `ADDITIONAL:` path recorded in P7-T4 (the #928-added call sites under `tests/`), apply the conversion rule of this phase: when the file defines its own `New-SubagentStopEnvelopeJson`, replace that block with the helper dot-source line; when it calls a builder defined elsewhere, rename its call sites and ensure the helper is dot-sourced in a `BeforeAll` that encloses them. Record each path and its edit in `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-additional-sites.<timestamp>.md`. Acceptance: the artifact lists every `ADDITIONAL:` path with its edit, or states `NO-ADDITIONAL-SITES` when P7-T4 recorded none; each listed file has a `New-SubagentStopEnvelopeJson` count of 0.
- [ ] [P8-T11] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-census.<timestamp>.md` from `@(Get-ChildItem -Path tests -Recurse -Include *.ps1 | Select-String -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count` and `@(Get-ChildItem -Path tests -Recurse -Include *.ps1 | Select-String -SimpleMatch -Pattern 'Builds and returns envelope JSON text only').Count` (these see untracked files, unlike `git grep`). Acceptance: both values are 0.
- [ ] [P8-T12] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-suites.<timestamp>.md` from the P7-T3 runner command (the same eight suite paths). Acceptance: output contains `FAILED=0`; the `PASSED=` value equals the P7-T3 `PASSED=` value (conversion adds and removes no test); every `Passed |` name recorded in P7-T3 is present (AC-08).
- [ ] [P8-T13] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-envelope-identity.<timestamp>.md` from `pwsh -NoProfile -Command { . ./tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1; 'HAS_AGENTTYPE=' + (Get-Command ConvertTo-SubagentStopEnvelopeJson).Parameters.ContainsKey('AgentType'); 'A=' + ((ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'x') -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"prd-feature","stop_hook_active":false,"last_assistant_message":"x"}'); 'B=' + ((ConvertTo-SubagentStopEnvelopeJson -OmitAssistantMessage -OutputField 'y') -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"general-purpose","stop_hook_active":false,"output":"y"}'); 'C=' + ((ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -StopHookActive) -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"task-researcher","stop_hook_active":true,"last_assistant_message":""}') }`. The three expected strings are the outputs of the removed local builder for the same inputs (key order `session_id`, `hook_event_name`, `agent_type`, `stop_hook_active`, `last_assistant_message`, `output`; `ConvertTo-Json -Compress`). Acceptance: the output is `HAS_AGENTTYPE=True`, `A=True`, `B=True`, `C=True` (B also shows the `general-purpose` default; AC-07).
- [ ] [P8-T14] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-line-counts.<timestamp>.md` from the P0-T17 line-count command. Acceptance: every value is at or below 500; with #928 `NOT-MERGED`, the values are 289, 289, 230, 193, 410, 350, 106, 132, 420, 67, 35; with #928 `MERGED`, each value is recorded and any difference from these figures is attributed to a merged path named in P7-T2.
- [ ] [P8-T15] Commit and push Phase 8: run `git add tests/scripts/claude-hooks/ docs/features/active/subagentstop-artifact-gates-review-notes-929/` (plus any P8-T10 path outside `tests/scripts/claude-hooks/`), then `git commit -m "test(929): extract shared SubagentStop envelope helper (NB-4)"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task as the NB-4 commit.

### Phase 9 — Final QA Loop, Coverage Comparison, and Acceptance Check-Off

QA loop: P9-T1 (format), P9-T2 (lint), type checking (not applicable to PowerShell; no Python file is edited), P9-T3 and P9-T4 (tests with coverage). If any of P9-T1 to P9-T4 fails or changes a file, fix the cause, commit, and restart from P9-T1; each pass writes new artifacts with new stamps, and later tasks consume the lexicographically greatest file per name.

- [ ] [P9-T1] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-format.<timestamp>.md`: record `git status --porcelain`, call `mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","extensions/drm-copilot/resources/claude-customizations/.claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`, then record `git status --porcelain` again. Acceptance: the MCP disposition is recorded; the two porcelain outputs are identical apart from paths recorded as `PRE-EXISTING-DRIFT` in P0-T20, so every file this item touched is unchanged by the formatter (AC-21).
- [ ] [P9-T2] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-analyze.<timestamp>.md`: call `mcp__drm-copilot__run_poshqc_analyze workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","tests/scripts/claude-hooks"]` and record its disposition, then run the P0-T21 direct analyzer command with `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` and `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` added to its file list (plus any P8-T10 path). Acceptance: the MCP disposition is recorded and is not worse than P0-T21; the direct run prints one `FINDINGS=0` line per file and `TOTAL_FINDINGS=0` (AC-21).
- [ ] [P9-T3] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-poshqc-test-mcp.<timestamp>.md` from one call to `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=["tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`. Acceptance: the call disposition is recorded as `EXIT_CODE: 0`; no count or test name is read from the result (AC-22 route compliance).
- [ ] [P9-T4] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-pester-selfhosted.<timestamp>.md` from the two P0-T23 commands, with the run start time and the XML write time recorded. Acceptance: the coverage XML write time is later than the run start; the self-hosted exit code is 0 and the JUnit line reads `FAILURES=0`, or every `FAILED_CASE |` name is also listed in P0-T23 and none belongs to a suite this item touched; the run includes `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, and `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` (AC-22).
- [ ] [P9-T5] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-counters-final.<timestamp>.md` immediately after P9-T4 from the P0-T24 command with its `Select-String` patterns changed to `'IsNullOrWhiteSpace($assistantMessage)','-AgentOutput $assistantMessage'`; then copy `artifacts/pester/powershell-coverage.xml` to `SCRATCH/powershell-coverage.final.xml` and record both SHA256 hashes. Acceptance: the output prints `SOURCEFILE_MATCHES=1`, one LINE `counter` element, `CHANGED_LINES=` with three line numbers (244,248,265 when #928 did not change the file), and three `line` elements, all copied verbatim; each of the three `line` elements has `ci` greater than 0; the two hashes are equal.
- [ ] [P9-T6] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-comparison.<timestamp>.md` quoting verbatim the baseline LINE `counter` element from the greatest `coverage-counters-baseline.*.md` in `evidence/baseline/` and the final LINE `counter` element from the greatest `coverage-counters-final.*.md` in `evidence/qa-gates/`. Acceptance: both elements are quoted verbatim (AC-18); the final `missed` value is not greater than the baseline `missed` value (AC-23); the final `covered / (covered + missed)` is at least 0.85; the changed-line `line` elements from P9-T5 each show `ci` greater than 0; `Output Summary:` states baseline missed, final missed, and both percentages.
- [ ] [P9-T7] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-registration-suites.<timestamp>.md` from `pwsh -NoProfile -Command { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1','tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'PASSED=' + $r.PassedCount }`. Acceptance: output contains `FAILED=0` (AC-20, AC-22).
- [ ] [P9-T8] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/ac20-statements.<timestamp>.md` from `Select-String -Path .claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern 'function Invoke-TaskResearcherOutputValidation','$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix','if ($null -ne $dependencyDecision) { return $dependencyDecision }' | ForEach-Object { '{0} | {1}' -f $_.LineNumber, $_.Pattern }` and `@(Select-String -Path .claude/hooks/validate-prd-feature-output.ps1,.claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern '(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b').Count`. Acceptance: inside the function, the assignment and the `if` statement are the two lines after its `param(...)` block (function at line 233, assignment at 239, `if` at 240 when #928 did not change the file); the assignment pattern also matches the script-tail line (286 at authoring), which is expected and outside the function; the R3 pattern count is 2 (AC-04, AC-20).
- [ ] [P9-T9] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-python-contracts.<timestamp>.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -q`. Acceptance: as P5-T5 (AC-12).
- [ ] [P9-T10] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-line-counts.<timestamp>.md` from the P0-T17 line-count command plus any P8-T10 path. Acceptance: every touched PowerShell file prints a `LINES=` value at or below 500 and none prints `ABSENT` (AC-24).
- [ ] [P9-T11] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/scope-diff.<timestamp>.md` from `git fetch origin main`, `git diff --name-only origin/main...HEAD -- .claude .codex extensions scripts`, `git status --porcelain -- .claude .codex extensions scripts`, `git diff origin/main...HEAD -- .claude/hooks/validate-prd-feature-output.ps1`, and `git status --porcelain -- .claude/hooks/validate-prd-feature-output.ps1`. Acceptance: the name-only diff lists exactly `.claude/hooks/validate-task-researcher-output.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`; both porcelain commands print nothing; the prd-feature diff prints nothing (AC-04, AC-13).
- [ ] [P9-T12] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/ac09-census.<timestamp>.md` from `git grep -n New-SubagentStopEnvelopeJson -- tests` and `git grep -n "Builds and returns envelope JSON text only" -- tests`, run after the Phase 8 commit. Acceptance: both print nothing and exit 1; the artifact carries `ExpectedExitCode: 1` (AC-09).
- [ ] [P9-T13] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/commit-order.<timestamp>.md` from `git log --reverse --format=%H%x20%s origin/main..HEAD`, `git log --format=%H --fixed-strings --grep='(NB-4)' origin/main..HEAD`, then `git diff --name-only <NB-4 hash>..HEAD` and `git status --porcelain -- tests .claude extensions`. Acceptance: exactly one commit carries `(NB-4)`; it equals the hash recorded at P8-T15; every implementation commit of Phases 1 to 6 precedes it in the reverse log; the name-only diff lists only paths under `docs/features/active/subagentstop-artifact-gates-review-notes-929/`; the porcelain command prints nothing; the artifact restates the P7-T1 #928 classification (AC-10).
- [ ] [P9-T14] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/plan-expect-fail-check.<timestamp>.md` from `@(Select-String -Path docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md -Pattern '^- \[[ xX]\] \[P\d+-T\d+\] \[expect-fail\]').Count` and `@(Select-String -Path docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md -SimpleMatch -Pattern 'characterization test against unchanged behavior').Count`. Acceptance: the first value is 0; the second is at least 1 (AC-25).
- [ ] [P9-T15] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: change AC-01, AC-02, AC-03, and AC-04 from `- [ ]` to `- [x]` only after the greatest `r3-prd-feature.*.md`, `r3-task-researcher.*.md`, `spec-decision-records.*.md`, `ac20-statements.*.md`, and `scope-diff.*.md` meet their acceptance. Acceptance: the four boxes are checked and their text is unchanged.
- [ ] [P9-T16] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-05 and AC-06 only after the greatest `r4-discovery.*.md` meets its acceptance and `nb4-suites.*.md` shows the R4 names still `Passed`. Acceptance: the two boxes are checked and their text is unchanged.
- [ ] [P9-T17] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-07, AC-08, AC-09, and AC-10 only after the greatest `nb4-envelope-identity.*.md`, `nb4-census.*.md`, `nb4-suites.*.md`, `ac09-census.*.md`, and `commit-order.*.md` meet their acceptance. Acceptance: the four boxes are checked and their text is unchanged.
- [ ] [P9-T18] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-11, AC-12, and AC-13 only after the greatest `nb5-alias-removal.*.md`, `post-merge-verification.*.md`, `final-python-contracts.*.md`, and `scope-diff.*.md` meet their acceptance. Acceptance: the three boxes are checked and their text is unchanged.
- [ ] [P9-T19] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-14, AC-15, AC-16, and AC-17 only after the greatest `e3-clarifications.*.md`, `spec-decision-records.*.md`, `nb9-dispatch.*.md`, and `nb9-checks.*.md` meet their acceptance and `nb4-suites.*.md` shows both dispatch names `Passed`. Acceptance: the four boxes are checked and their text is unchanged.
- [ ] [P9-T20] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-18, AC-19, and AC-20 only after the greatest `coverage-comparison.*.md`, `nb11-dependency-decision.*.md`, `final-registration-suites.*.md`, and `ac20-statements.*.md` meet their acceptance. Acceptance: the three boxes are checked and their text is unchanged.
- [ ] [P9-T21] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-21, AC-22, AC-23, AC-24, and AC-25 only after the greatest `final-format.*.md`, `final-analyze.*.md`, `final-poshqc-test-mcp.*.md`, `final-pester-selfhosted.*.md`, `coverage-comparison.*.md`, `final-line-counts.*.md`, and `plan-expect-fail-check.*.md` meet their acceptance. Acceptance: the five boxes are checked and their text is unchanged; AC-26 and AC-27 stay unchecked.
- [ ] [P9-T22] Commit and push the final QA evidence: run `git add docs/features/active/subagentstop-artifact-gates-review-notes-929/`, then `git commit -m "docs(929): record final QA evidence and acceptance check-off"`, then `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929`; the commit hash is recorded beside this task.
- [ ] [P9-T23] Create `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/ci-status.<timestamp>.md` from `gh pr list --head bug/subagentstop-artifact-gates-review-notes-929 --json number,headRefOid` and, when a PR exists, `gh pr checks <number>` after the checks complete. Acceptance: when a PR exists and its `headRefOid` equals the P9-T22 hash, the artifact records the conclusion of `poshqc / PowerShell QC` (windows-latest, every suite with coverage) and of `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest, `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, no coverage). When no PR exists, the artifact records `PENDING-CI: no pull request is open for the branch`; this skip branch is explicitly authorized because PR creation belongs to the orchestrator's PR stage, and AC-26 and AC-27 then stay unchecked for the CI gate.
- [ ] [P9-T24] Edit `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`: check AC-26 only when the greatest `ci-status.*.md` records `poshqc / PowerShell QC` as `success` on the PR head SHA, and check AC-27 only when it records `poshqc / PowerShell hook suites (Linux)` as `success` on the same SHA; then run `git add docs/features/active/subagentstop-artifact-gates-review-notes-929/`, `git commit -m "docs(929): record CI status"`, and `git push origin bug/subagentstop-artifact-gates-review-notes-929`. Acceptance: each box is checked only on its recorded `success`; `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-artifact-gates-review-notes-929` after the push.

## Appendix A1 — R3 Accept Rows (NB-1 alternation members and NB-2 characterization)

Inserted in P1-T2 (12-space indentation) and P1-T4 (8-space indentation). Shown here at 12 spaces.

```powershell
            @{ Name = 'complete source tree'; Value = 'the complete source tree' }
            @{ Name = 'whole repo'; Value = 'the whole repo' }
            @{ Name = 'upper-case entire worktree'; Value = 'ENTIRE WORKTREE' }
            @{ Name = 'entire worktree root'; Value = 'entire worktree root.' }
            @{ Name = 'whole repository excluding docs'; Value = 'the whole repository excluding `docs/`' }
            # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; a whole-worktree value that lists a narrower covered set is accepted.
            @{ Name = 'NB-2 whole worktree restricted to code'; Value = 'the whole worktree with ripgrep, restricted to code by excluding `docs/`; covers `.claude/hooks`, `.claude/lib`, `.codex/hooks`, and both bundle roots.' }
            # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; an entire-repository value with an exclusion is accepted.
            @{ Name = 'NB-2 entire repository excluding docs'; Value = 'entire repository excluding docs/**' }
```

The NB-2 row value is quoted verbatim from `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md` line 323. Backticks inside single-quoted PowerShell strings are literal characters.

## Appendix A2 — R3 Reject Rows (NB-1)

Inserted in P1-T3 (12-space indentation) and P1-T5 (8-space indentation). Shown here at 12 spaces.

```powershell
            @{ Name = 'noun without a quantifier'; Value = 'those four files on the current worktree.' }
            @{ Name = 'quantifier without a noun'; Value = 'the whole file, lines 1-335.' }
            @{ Name = 'path-shaped value'; Value = '`.claude/hooks/`' }
            @{ Name = 'all inside allocated'; Value = 'the allocated repository subset' }
            @{ Name = 'tree inside subtree'; Value = 'the entire subtree' }
            @{ Name = 'worktree inside worktrees'; Value = 'the whole worktrees folder' }
```

## Appendix B — R4 Trim-Only Token Cases (NB-3)

Inserted in P2-T1. The block starts with one blank line and is 70 lines long.

```powershell

        It 'R4 returns no reference for a lone backtick token' {
            # Arrange: the only punctuation token is a lone backtick, which is empty after trimming; no discovery path is present.
            $text = 'Wrote ` and finished the task'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 0
        }

        It 'R4 returns no reference for an empty-after-trim token' {
            # Arrange: two double-quote characters form one token that is empty after trimming; no discovery path is present.
            $text = 'Wrote "" and finished the task'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 0
        }

        It 'R4 skips a lone backtick token and returns the following discovery reference' {
            # Arrange: a lone backtick token precedes a discovery reference.
            $text = 'Wrote ` and discovery/coverage-ledger/coverage-ledger.json'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 1
            $references[0] | Should -BeExactly 'discovery/coverage-ledger/coverage-ledger.json'
        }

        It 'R4 skips the trim-only token <Name> and returns the discovery reference' -ForEach @(
            @{ Name = '()'; Token = '()' }
            @{ Name = '[]'; Token = '[]' }
            @{ Name = ''''''; Token = '''''' }
            @{ Name = ','; Token = ',' }
            @{ Name = ';'; Token = ';' }
        ) {
            # Arrange: the trim-only token precedes a discovery reference.
            $text = 'Wrote ' + $Token + ' and discovery/coverage-ledger/coverage-ledger.json'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 1
            $references[0] | Should -BeExactly 'discovery/coverage-ledger/coverage-ledger.json'
        }

        It 'R4 gate allows a message containing only a lone backtick without invoking the validator' {
            # Arrange: a present declaration and a failing validator mock, so any dispatch would block.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage '`'
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
```

The `''''''` literal is a single-quoted PowerShell string whose content is two single-quote characters.

## Appendix C — Validator Dispatch Suite (NB-9)

Full content of `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` (66 lines). The message yields three distinct references in this order: `discovery/coverage-ledger/coverage-ledger.json` (backtick-wrapped, then repeated bare at the end), `discovery/parity-matrix/parity-matrix.json` (trailing comma), and `discovery/feature-contract/feature-contract.json` (parenthesized); `""` and the lone backtick are empty after trimming.

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Validator-dispatch suite for `.claude/hooks/validate-discovery-artifact-gate.ps1`
    (issue #929, review note NB-9).

    The E3 discovery corpus used the default declaration reader, which reports the
    declaration absent, so the gate allowed before its dispatch loop. These cases inject a
    present-declaration reader and mock the Invoke-DiscoveryValidatorExe seam so the loop
    runs. They live in a sibling container because validate-discovery-artifact-gate.Tests.ps1
    would exceed 470 lines with them. The message carries no scripts/dev_tools path: the
    profile prefix match in Get-DiscoveryArtifactType is an existing out-of-scope follow-up
    owned by #9002. No test creates, writes, or deletes a file.
#>

Describe 'validate-discovery-artifact-gate.ps1 validator dispatch (issue #929)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # A required-artifact reader stub that reports the declaration as present.
        $script:PresentReader = { @{ Present = $true; Declaration = @{ types = @('coverage-ledger', 'parity-matrix', 'feature-contract') } } }

        # Corpus-shaped message: three discovery types, one duplicated reference, backtick-wrapped,
        # trailing-comma and parenthesized references, and two empty-after-trim tokens.
        $script:DispatchMessage = 'Wrote `discovery/coverage-ledger/coverage-ledger.json` and "" then discovery/parity-matrix/parity-matrix.json, plus ` (discovery/feature-contract/feature-contract.json) and re-checked discovery/coverage-ledger/coverage-ledger.json'
        $script:DispatchEnvelope = [ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; agent_type = 'general-purpose'; stop_hook_active = $false; last_assistant_message = $script:DispatchMessage } | ConvertTo-Json -Compress
    }

    Context 'validator dispatch with a present declaration (issue #929)' {
        It 'dispatches each distinct discovery reference exactly once' {
            # Arrange: every reference validates.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $script:DispatchEnvelope -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'coverage-ledger' -and $ValidatorArgs[1] -eq 'discovery/coverage-ledger/coverage-ledger.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' -and $ValidatorArgs[1] -eq 'discovery/parity-matrix/parity-matrix.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'feature-contract' -and $ValidatorArgs[1] -eq 'discovery/feature-contract/feature-contract.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 3 -Exactly
        }

        It 'stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED' {
            # Arrange: the second distinct reference (parity-matrix) fails; the others validate.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: parity-matrix' } } -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' }
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $script:DispatchEnvelope -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $false
            $result.Message.StartsWith('DISCOVERY_ARTIFACT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'coverage-ledger' -and $ValidatorArgs[1] -eq 'discovery/coverage-ledger/coverage-ledger.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' -and $ValidatorArgs[1] -eq 'discovery/parity-matrix/parity-matrix.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'feature-contract' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 2 -Exactly
        }
    }
}
```

### Appendix C2 — NB-4 conversion lines for the dispatch suite

Replaces the single `$script:DispatchEnvelope = [ordered]@{ ... } | ConvertTo-Json -Compress` line in P8-T9. The produced JSON is identical (same keys, order, and values; `general-purpose` is the helper default).

```powershell
        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
        $script:DispatchEnvelope = ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:DispatchMessage
```

## Appendix D — In-Process Dependency-Decision Test (NB-11)

Appended in P4-T1 to `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`. The block starts with one blank line and is 23 lines long. The input text is a literal envelope because the leading dependency-decision statement returns before the envelope is read.

```powershell

Describe 'Invoke-TaskResearcherOutputValidation dependency decision in process (issue #929)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')
    }

    It 'returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)' {
        # Arrange: a failure recorded after the hook loaded; the leading dependency-decision statement returns the guard object unchanged (rule S6).
        $inputText = '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"task-researcher","stop_hook_active":false,"last_assistant_message":"Done. Findings recorded."}'
        try {
            Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'
            # Act
            $result = Invoke-TaskResearcherOutputValidation -InputText $inputText
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }
        # Assert
        $result.ExitCode | Should -Be 2 -Because $result.Reason
        $result.Reason.StartsWith('validate-task-researcher-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        $result.Reason.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Reason
    }
}
```

## Appendix E — E3 Spec Post-Review Clarifications (NB-7, NB-8)

Each line is inserted with two leading spaces so it renders as a continuation of the checklist item above it.

E1 (inserted after the AC-20 line in P6-T1):

```markdown
  Post-review clarification (2026-10-15, issue #929): the AC-20 pattern `\.output\b` is intended to detect reads of the envelope payload's `output` field. The discovery validator's result object exposes an `Output` key that is read through the hashtable indexer (`$validatorResult['Output']`) per plan RS-2 (`plan.2026-10-11T07-59.md`); that read is not an envelope read. No code change; the AC-20 checkbox state is unchanged.
```

E2 (inserted after the AC-11 line in P6-T2):

```markdown
  Post-review clarification (2026-10-15, issue #929): ordering is evaluated against the commit that first records the after-change zero count in the evidence file, which is the first commit returned by `git log --format=%H --reverse -S 'AFTER-FALSE-POSITIVES: 0' -- <evidence file>`; that commit must be an ancestor of the switch commit (`git merge-base --is-ancestor <that commit> <switch commit>` exits 0). The plan's `AC11:` lines record this property; the AC-11 checkbox state is unchanged.
```

## Appendix F — Shared Envelope Helper (NB-4)

Full content of `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` (35 lines). The `ConvertTo-` verb is outside PSScriptAnalyzer's state-changing verb set, so no analyzer suppression is needed (precedent: `ConvertTo-ClaudeEnvelope` in `tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1`).

```powershell
#Requires -Version 7.0
<#
.SYNOPSIS
    Shared SubagentStop envelope builder for the artifact-gate validator suites (issue #929, review note NB-4).

.DESCRIPTION
    Suites dot-source this file from a BeforeAll block with
    . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
    It defines one function, holds no state, and writes no file.
#>

function ConvertTo-SubagentStopEnvelopeJson {
    <#
    .SYNOPSIS
        Returns compressed SubagentStop envelope JSON text.
    .DESCRIPTION
        Keys, in order: session_id ('e3-905'), hook_event_name ('SubagentStop'), agent_type,
        stop_hook_active, then last_assistant_message unless -OmitAssistantMessage is set, then
        output only when -OutputField is bound.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()] [string] $AssistantMessage = '',
        [switch] $OmitAssistantMessage,
        [string] $OutputField,
        [switch] $StopHookActive,
        [string] $AgentType = 'general-purpose'
    )

    $envelope = [ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; agent_type = $AgentType; stop_hook_active = [bool]$StopHookActive }
    if (-not $OmitAssistantMessage) { $envelope['last_assistant_message'] = $AssistantMessage }
    if ($PSBoundParameters.ContainsKey('OutputField')) { $envelope['output'] = $OutputField }
    return ($envelope | ConvertTo-Json -Compress)
}
```

## Planner Self-Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Initial authoring pass (2026-10-15). Citations re-derived against the current tree in this pass, with sibling regions re-checked:

1. `.claude/hooks/validate-task-researcher-output.ps1`: 290 lines; R3 pattern at line 202; `Invoke-TaskResearcherOutputValidation` at line 233 with `param(...)` ending line 238, dependency-decision assignment line 239, `if ($null -ne $dependencyDecision) { return $dependencyDecision }` line 240; `$assistantMessage` line 243; alias line 244; alias reads at lines 245, 249, 266 (case-sensitive search finds no other `$agentOutput`); script tail lines 282-290.
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`: 290 lines; alias lines 244, 245, 249, 266 identical.
3. `.claude/hooks/validate-discovery-artifact-gate.ps1`: `Invoke-DiscoveryValidatorExe` lines 47-83 (`-ValidatorArgs [string[]]`); `Get-DiscoveryArtifactType` lines 85-128 with prefix map lines 110-119; `Get-RequiredDiscoveryArtifactDeclaration` default reader line 150; `Find-DiscoveryArtifactReference` trim set line 189, empty-text return lines 182-184; gate dispatch loop lines 231-238 with call `-ValidatorArgs @($artifactType, $reference)` at line 233 and `DISCOVERY_ARTIFACT_GATE_BLOCKED:` message at line 236.
4. `.claude/hooks/hook-dependency-guard.ps1`: `Add-HookDependencyFailure` lines 24-46 (`-Name` mandatory, `-ErrorRecord` optional); SubagentStop return `[pscustomobject]@{ ExitCode = 2; Reason = $reason }` line 105; reason format line 76.
5. `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`: 223 lines; builder lines 32-40 (`agent_type = 'prd-feature'`); R3 Context lines 196-222, accept rows 199-201, reject row 212, message assertion line 220.
6. `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`: 320 lines; builder lines 24-32 (`task-researcher`); guard-shape case lines 181-190 (`has no S1, S2, S3 or S6 guard-shape finding`); finally reset at line 171; R3 Describe lines 275-320, accept rows 297-299, reject row 310, message assertion line 318.
7. `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`: 358 lines; `ConvertTo-DiscoveryEnvelopeJson` lines 11-16; `$script:PresentReader` line 20; builder lines 180-188 (`general-purpose`); R4 Context lines 344-357.
8. `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (418 lines, builder 41-49), `validate-prd-feature-output.Coverage.Tests.ps1` (201 lines, builder 24-32), `validate-pr-author-output.Tests.ps1` (114 lines, builder 15-23), `validate-pr-author-output.Coverage.Tests.ps1` (140 lines, builder 18-26).
9. Builder census: `New-SubagentStopEnvelopeJson` occurs 68 times in 7 files outside `docs/` (per file 9, 11, 9, 13, 7, 11, 8), 7 definitions.
10. `tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` lines 1-37 (sibling-suite convention; 89 lines).
11. `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1` lines 109-117 (rule S6 exact second statement).
12. Registration suites located: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`.
13. `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` line 53 (`test_numeric_provenance_contract_requires_full_family_and_cross_check`, reads the hook at line 60); `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 89 (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
14. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 4 (`Exit = $true`), 12-22 (JUnit and coverage output paths), 26 (`CoveragePercentTarget = 0`); `scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 154-160 (`Invoke-PoshQCTest -Root -ScanFolders`), 297-303 (relative root resolution), 319-329 (explicit scan folders win); `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` lines 299-309 (config roots); `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 56-66 (format logs), 101 (analyzer severities), 183-185 (analyze outcome); `scripts/powershell/PoshQC/settings/pssa.settings.psd1` lines 1-52; `scripts/powershell/PoshQC/PoshQC.psd1` exists.
15. `config/poshqc-coverage.json` roots lines 3-9; `config/poshqc-scan.json` line 4; `quality-tiers.yml` lines 28-29 (`.claude/hooks` T3).
16. `.github/workflows/_poshqc.yml` lines 8-52 (`PowerShell QC`, windows-latest, format check via `git status --porcelain`, coverage artifacts) and 54-82 (`PowerShell hook suites (Linux)`, ubuntu-latest, `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled).
17. `docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md`: AC-11 line 377 and AC-20 line 386 both `- [x]`; Risk 5a line 408; folder present under `docs/features/active/` (no `archive/` copy found by Glob); `code-review.2026-10-12T04-58.md` present; E3 plan `plan.2026-10-11T07-59.md` line 79 carries RS-2.
18. `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md` line 323 (NB-2 example value, quoted verbatim in Appendix A1; contains no single quote).
19. `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md` lines 69-88 (decisions, NB-2 candidate-rule table at 71-76), 140-142 (NB-7, NB-8, NB-10 resolutions), 204-249 (27 acceptance criteria); `issue.md` line 9 (`- Work Mode: full-bug`).
20. `scripts/dev_tools/validate_orchestration_artifacts.py` lines 48-51 and 134-195 (phase and task patterns; every line starting `- [` with `[P` and `-T` must be a task); `.claude/hooks/validate-planner-output.ps1` lines 102 (path-token rule), 245-352 (Phase 0 and final-phase rules), 120-235 (bounded record rules); `scripts/dev_tools/plan_gate_observability.py` lines 184-199 (PoshQC write-mode markers `formatted`, `unchanged`).
21. Remote-tracking ref for #928 observed on disk: `refs/remotes/origin/bug/subagentstop-hook-uncaught-error-exits-1-928` (merge status into `main` not determinable without git; delegated to P0-T15 and P7-T1).

Sibling checks performed: the NB-2 value contains no single quote, so the single-quoted PowerShell literal needs no escaping; every R3 reject row was evaluated against the pattern at `.claude/hooks/validate-task-researcher-output.ps1` line 202 (no quantifier, no noun, path only, `allocated`, `subtree`, `worktrees` all fail the word-boundary match) and every accept row matches; the Appendix C message tokens were evaluated against the trim set at line 189 (the trailing-period form was avoided because `.` is not trimmed); Appendix B and Appendix C line counts (70 and 66), Appendix D (23), Appendix F (35), and the in-place NB-9 variant used by the placement decision (43) were counted line by line; the NB-5 edit lines 244, 245, 249, 266 sit after the S6 statements at lines 239-240, so S6 is unaffected; Appendix F contains neither `SuppressMessageAttribute` nor the phrase `Builds and returns envelope JSON text only`.

## Planner Internal Review Record

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-task-researcher-output.ps1 | lines 202, 233-244, 245, 249, 266, 282-290
CITATION: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | lines 244, 245, 249, 266
CITATION: .claude/hooks/validate-discovery-artifact-gate.ps1 | lines 47-83, 121-125, 182-197, 231-238
CITATION: .claude/hooks/hook-dependency-guard.ps1 | lines 24-46, 76, 104-106
CITATION: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | lines 32-40, 196-222
CITATION: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | lines 24-32, 181-190, 275-320
CITATION: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | lines 11-20, 180-188, 344-358
CITATION: tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1 | lines 109-117 rule S6
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | lines 4, 12-26
CITATION: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | lines 154-160, 319-329
CITATION: config/poshqc-coverage.json | lines 3-9 coverage roots
CITATION: .github/workflows/_poshqc.yml | lines 8-52 and 54-82 job names and scopes
CITATION: docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md | AC-11 line 377, AC-20 line 386, Risk 5a line 408
CITATION: docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md | acceptance criteria lines 204-249
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC-01, AC-02, AC-03, AC-04, AC-05, AC-06, AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-26, AC-27
AC-MAPPING: AC-01 | IMPLEMENTATION: P1-T2, P1-T3 | TESTS: P1-T6 | EVIDENCE: evidence/regression-testing/r3-prd-feature.<timestamp>.md
AC-MAPPING: AC-02 | IMPLEMENTATION: P1-T4, P1-T5 | TESTS: P1-T7 | EVIDENCE: evidence/regression-testing/r3-task-researcher.<timestamp>.md
AC-MAPPING: AC-03 | IMPLEMENTATION: P1-T2, P1-T4 | TESTS: P1-T6, P1-T7 | EVIDENCE: evidence/regression-testing/r3-prd-feature.<timestamp>.md and r3-task-researcher.<timestamp>.md
AC-MAPPING: AC-04 | IMPLEMENTATION: no R3 change by design (spec decision 1, verified P6-T4) | TESTS: P9-T8, P9-T11 | EVIDENCE: evidence/qa-gates/scope-diff.<timestamp>.md and ac20-statements.<timestamp>.md
AC-MAPPING: AC-05 | IMPLEMENTATION: P2-T1 | TESTS: P2-T2 | EVIDENCE: evidence/regression-testing/r4-discovery.<timestamp>.md
AC-MAPPING: AC-06 | IMPLEMENTATION: P2-T1 | TESTS: P2-T2 | EVIDENCE: evidence/regression-testing/r4-discovery.<timestamp>.md
AC-MAPPING: AC-07 | IMPLEMENTATION: P8-T1 | TESTS: P8-T1, P8-T13 | EVIDENCE: evidence/regression-testing/nb4-envelope-identity.<timestamp>.md
AC-MAPPING: AC-08 | IMPLEMENTATION: P8-T2 to P8-T8 | TESTS: P8-T12 | EVIDENCE: evidence/regression-testing/nb4-suites.<timestamp>.md
AC-MAPPING: AC-09 | IMPLEMENTATION: P7-T2, P8-T2 to P8-T10 | TESTS: P8-T11, P9-T12 | EVIDENCE: evidence/qa-gates/ac09-census.<timestamp>.md
AC-MAPPING: AC-10 | IMPLEMENTATION: P7-T1, P8-T15 | TESTS: P9-T13 | EVIDENCE: evidence/qa-gates/commit-order.<timestamp>.md
AC-MAPPING: AC-11 | IMPLEMENTATION: P5-T1, P5-T2 | TESTS: P5-T3, P7-T3 | EVIDENCE: evidence/regression-testing/nb5-alias-removal.<timestamp>.md
AC-MAPPING: AC-12 | IMPLEMENTATION: P5-T2 | TESTS: P5-T5, P9-T9 | EVIDENCE: evidence/qa-gates/final-python-contracts.<timestamp>.md
AC-MAPPING: AC-13 | IMPLEMENTATION: P5-T1, P5-T2 | TESTS: P9-T11 | EVIDENCE: evidence/qa-gates/scope-diff.<timestamp>.md
AC-MAPPING: AC-14 | IMPLEMENTATION: P6-T1 | TESTS: P6-T3 | EVIDENCE: evidence/regression-testing/e3-clarifications.<timestamp>.md
AC-MAPPING: AC-15 | IMPLEMENTATION: P6-T2 | TESTS: P6-T3, P6-T4 | EVIDENCE: evidence/regression-testing/e3-clarifications.<timestamp>.md and evidence/other/spec-decision-records.<timestamp>.md
AC-MAPPING: AC-16 | IMPLEMENTATION: P3-T1 | TESTS: P3-T2, P3-T3 | EVIDENCE: evidence/regression-testing/nb9-dispatch.<timestamp>.md
AC-MAPPING: AC-17 | IMPLEMENTATION: P3-T1 | TESTS: P3-T2 | EVIDENCE: evidence/regression-testing/nb9-dispatch.<timestamp>.md
AC-MAPPING: AC-18 | IMPLEMENTATION: P0-T24, P9-T5 | TESTS: P9-T6 | EVIDENCE: evidence/qa-gates/coverage-comparison.<timestamp>.md
AC-MAPPING: AC-19 | IMPLEMENTATION: P4-T1 | TESTS: P4-T2 | EVIDENCE: evidence/regression-testing/nb11-dependency-decision.<timestamp>.md
AC-MAPPING: AC-20 | IMPLEMENTATION: no change to the S6 statements (NB-5 edits lines after them) | TESTS: P5-T6, P9-T7, P9-T8 | EVIDENCE: evidence/qa-gates/ac20-statements.<timestamp>.md
AC-MAPPING: AC-21 | IMPLEMENTATION: P9-T1, P9-T2 | TESTS: P9-T1, P9-T2 | EVIDENCE: evidence/qa-gates/final-format.<timestamp>.md and final-analyze.<timestamp>.md
AC-MAPPING: AC-22 | IMPLEMENTATION: P9-T3, P9-T4 | TESTS: P9-T4, P9-T7 | EVIDENCE: evidence/qa-gates/final-pester-selfhosted.<timestamp>.md
AC-MAPPING: AC-23 | IMPLEMENTATION: P9-T5 | TESTS: P9-T6 | EVIDENCE: evidence/qa-gates/coverage-comparison.<timestamp>.md
AC-MAPPING: AC-24 | IMPLEMENTATION: P9-T10 | TESTS: P9-T10 | EVIDENCE: evidence/qa-gates/final-line-counts.<timestamp>.md
AC-MAPPING: AC-25 | IMPLEMENTATION: Governing Rules and P1-T1 | TESTS: P9-T14 | EVIDENCE: evidence/qa-gates/plan-expect-fail-check.<timestamp>.md
AC-MAPPING: AC-26 | IMPLEMENTATION: P9-T22 | TESTS: P9-T23 | EVIDENCE: evidence/qa-gates/ci-status.<timestamp>.md (pending-CI when no PR is open)
AC-MAPPING: AC-27 | IMPLEMENTATION: P9-T22 | TESTS: P9-T23 | EVIDENCE: evidence/qa-gates/ci-status.<timestamp>.md (pending-CI when no PR is open)
UNRESOLVED-GAPS: NONE
