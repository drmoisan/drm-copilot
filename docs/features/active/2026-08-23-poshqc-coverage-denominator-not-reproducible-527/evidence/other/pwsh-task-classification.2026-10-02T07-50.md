# PowerShell Task Classification (Operator Decision 2026-10-01, Option A)

Timestamp: 2026-10-02T07-50
Command: none (classification record; authored by the orchestrator before Phase 0)
EXIT_CODE: 0
Output Summary: every plan task whose command or acceptance runs `pwsh` (directly or through a D10 rule body) is classified as MCP-satisfiable, CI-evidence deviation, git/static-equivalent deviation, orchestrator-performed deviation, or operator-run blocker. 4 acceptance criteria (AC-01, AC-11, AC-12, AC-13) depend on operator-run blockers and cannot be checked off in this run.

## Binding constraints

- The worktree isolation guard refuses command text containing `bash`, `pwsh`, or `wsl`. Per the operator decision, no `sh` wrapper or other route around the guard is used. Plan D10's `sh <scratchpad>/<name>.sh` fallback is therefore withdrawn for this execution (deviation DEV-D10).
- PoshQC format, analyze, and test run through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`. These tools execute the installed extension's PoshQC copy, which does not contain this change, and return a fixed summary string with no counts (plan D10). Branch behaviour is established only by CI.
- CI source of record: the `poshqc / PowerShell QC` job of workflow `CI` (`.github/workflows/_poshqc.yml`), which imports the branch copy `scripts/powershell/PoshQC/PoshQC.psm1` and runs `Invoke-PoshQCTest -Root <workspace>` with coverage and uploads `pester-junit.xml` and `powershell-coverage.xml` as artifact `poshqc-test-results` on success. Pre-PR runs are dispatched by the orchestrator with `gh workflow run _poshqc.yml --ref bug/poshqc-coverage-denominator-not-reproducible-527`; post-PR runs are the PR's own CI.
- CI artifacts are downloaded by the orchestrator into the git-ignored `artifacts/ci/run-<id>/` directory and reduced with a Python port of rules JX, CX, CL and a JUnit filter equivalent to TR (`artifacts/ci/ci_evidence.py`, git-ignored, not part of the write set). Evidence cites the run URL and job URL.
- Baseline CI run: https://github.com/drmoisan/drm-copilot/actions/runs/36978425380 (push to `main` at 71f8dcb4; job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219, conclusion success). The branch base 8f0483ec differs from 71f8dcb4 only under `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/`, so the PowerShell tree measured is identical.

## Classification

| Task(s) | pwsh element | Class | Replacement / disposition |
| --- | --- | --- | --- |
| P0-T3, P2-T2 (LL), P2-T3 (LL), P4-T5 (LL), P6-T28 | LL rule | git/static-equivalent deviation | `git grep --untracked -c '' -- <file>` (or the Read tool's last line number) gives the line count. |
| P0-T4 | FR + JX baseline full suite | CI-evidence deviation | Baseline CI run 36978425380 JUnit reduced with JX. |
| P0-T5 | CX baseline coverage | CI-evidence deviation | Baseline CI run 36978425380 coverage XML reduced with CX (root `D:/a/drm-copilot/drm-copilot`). |
| P0-T6 | non-writing format baseline | CI-evidence deviation | CI step `Format PowerShell` (runs `Invoke-PoshQCFormat` over the whole repository and fails on any rewrite) succeeded in run 36978425380; WOULD_FORMAT=0 is inferred from that step. |
| P0-T7 | analyzer baseline | CI-evidence deviation | CI step `Analyze PowerShell` succeeded in run 36978425380 (`Invoke-PoshQCAnalyze` throws on any finding). |
| P0-T8 | TR on `tests/scripts/powershell/PoshQC` | CI-evidence deviation | Baseline JUnit filtered to test cases under `tests/scripts/powershell/PoshQC`. |
| P1-T1, P2-T1, P3-T1, P3-T5, P4-T3, and every remediation reset | Rule BR | orchestrator-performed deviation | The orchestrator deletes `.claude/state/powershell-batch-budget.*.json` between executor segments without `pwsh` and records each reset line in `evidence/other/batch-budget-resets.<ts>.md`. |
| P1-T2, P1-T3 | import-and-call / TR on the fixture test | MCP-satisfiable | `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the fixture directory and `scan_folders` `["scripts","tests/scripts"]`; the passing `returns a greeting for the supplied name` test case in the fixture's `artifacts/pester/pester-junit.xml` (read with the Read tool) proves `Get-SampleGreeting -Name 'Ada'` returns `Hello, Ada.`. |
| P1-T4 (acceptance only) | dot-source and call the stand-in hook | operator-run blocker | File creation proceeds. Command: `pwsh -NoProfile -Command ". ./tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1; Test-StandInHookPayload"` (expected `True`). |
| P1-T5 | fixture inventory | git/static-equivalent deviation | `git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer`, `git ls-files -- tests/fixtures/poshqc-consumer`, Glob for `tests/fixtures/poshqc-consumer/config`, and the plan's `git check-ignore` command. |
| P1-T7 | CR scan | git/static-equivalent deviation | `git ls-files --eol -- <three fixture files>` after staging (expects `i/lf` and `w/lf`). |
| P2-T4, P2-T5 | TR fail-first on the new suites | CI-evidence deviation | `_poshqc.yml` dispatched on the pushed Phase 2 head (tests present, fix absent); failing test names and messages are taken from the job log. The full suite fails by design on that head. |
| P2-T6, P2-T7 | pre-fix consumer fixture run + FX | MCP-satisfiable | `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the fixture directory runs the installed (pre-fix) PoshQC copy with its bundled allow-list, which is the #623 item 1 configuration. FX is evaluated by reading the fixture's `artifacts/pester/powershell-coverage.xml` and `pester-junit.xml` with the Read tool. |
| P3-T2 | parse check | CI-evidence deviation | Any parse error in `PoshQC.Coverage.psm1` fails module import and therefore every PoshQC test in the CI run; a CI run with the PoshQC suites passing proves `PARSE_ERRORS=0`. |
| P3-T3, P3-T4, P5-T1, P5-T8, P5-T10, P6-T26, P6-T29, P6-T31 to P6-T48 (Select-String counts) | Select-String | git/static-equivalent deviation | `git grep --untracked -c -F -e '<literal>' -- <file>`. |
| P3-T6, P6-T24 | `Import-PowerShellDataFile` shape check | git/static-equivalent + CI-evidence deviation | Read the `CodeCoverage` block and confirm the key set; the CI run loading the settings file is the parse proof. |
| P3-T7, P6-T25 | JSON parse | git/static-equivalent deviation | Read the file and compare with the exact D6 document; `git hash-object` recorded. |
| P3-T8 | module surface | git/static-equivalent + CI-evidence deviation | `git grep` shows the four names absent from `Export-ModuleMember` and `FunctionsToExport`; the new suites reaching all four through `InModuleScope PoshQC` in CI prove `DEFINED=4`. |
| P4-T1, P4-T2, P4-T4 (TR), P4-T5 (TR), P4-T6 | TR runs | CI-evidence deviation | P4-T2 uses the CI run dispatched on the pushed Phase 3 head (before Phase 4 edits); P4-T1, P4-T4, P4-T5, P4-T6 use the CI run on the pushed Phase 4/5 head. |
| P5-T2 to P5-T6 | `Copy-Item` mirrors + HS | git/static-equivalent deviation | `git show HEAD:<source> > <mirror>` after the source is committed (byte copy of the blob), then `git hash-object` on both paths. |
| P5-T11 | HS around the MCP format call | git/static-equivalent deviation | `git hash-object` replaces HS. |
| P6-T1 | write-mode format of CHANGED_PS | MCP-satisfiable + CI-evidence | `mcp__drm-copilot__run_poshqc_format` over the CHANGED_PS folders with `git hash-object`/porcelain before and after (no `Already formatted:` lines are returned by MCP); the CI `Format PowerShell` step on the pushed head is the gate. |
| P6-T2 | HS on mirror pairs | git/static-equivalent deviation | `git hash-object` on both sides of the six pairs. |
| P6-T3 | analyze CHANGED_PS | CI-evidence deviation (MCP call also made) | CI step `Analyze PowerShell` on the pushed head. |
| P6-T4, P6-T5, P6-T6 | run A | CI-evidence deviation | Run A = the first CI `poshqc` run on the final pushed head; artifact downloaded; JX, CX, and the named-test JUnit check applied. |
| P6-T7, P6-T8 | run B | CI-evidence deviation | Run B = a second, independent CI `poshqc` run on the same head (re-run or dispatch). |
| P6-T9, P6-T10 | run C from a different current directory | operator-run blocker | Save the plan's FR, JX, and CX bodies as `fr.ps1`, `jx.ps1`, `cx.ps1` outside the repository and run from the repository root: `pwsh -NoProfile -File fr.ps1 -RunRoot . -LogName final-run-c.log -WorkingSubdirectory artifacts`, then `pwsh -NoProfile -File jx.ps1 -RunRoot .`, then `pwsh -NoProfile -File cx.ps1 -RunRoot . -XmlRelativePath artifacts/pester/powershell-coverage.xml`. |
| P6-T11 | compare A, B, C | CI-evidence deviation (A, B) + operator-run blocker (C) | A versus B is recorded; the C comparison waits for P6-T9/T10. AC-01 stays unchecked. |
| P6-T12 | population line in run logs | CI-evidence deviation (A, B) + operator-run blocker (C) | The `Code coverage population: source=config; files=` line is read from the CI job logs of runs A and B. |
| P6-T13, P6-T14 | CL changed-line coverage, aggregate | CI-evidence deviation | Run A coverage XML with the Python CL port anchored at BASE_SHA. |
| P6-T15 to P6-T19 | post-fix consumer fixture run, FX, hygiene | operator-run blocker | Save FR, JX, FX bodies as above and run from the repository root: `git status --porcelain --untracked-files=all -- . ':(exclude)docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527'`, `pwsh -NoProfile -File fr.ps1 -RunRoot tests/fixtures/poshqc-consumer -LogName fixture-run.log -ScanFolderList scripts,tests/scripts`, `pwsh -NoProfile -File jx.ps1 -RunRoot tests/fixtures/poshqc-consumer`, `pwsh -NoProfile -File fx.ps1 -RunRoot tests/fixtures/poshqc-consumer`, the same `git status` again, and `git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml`. AC-11, AC-12, AC-13 stay unchecked. |
| P6-T27 | PD rule (dot-sources `.claude/hooks/check-powershell-test-purity.ps1`) | git/static-equivalent deviation | The same hook ran as a PreToolUse hook on every Write/Edit of the six files and did not deny; the banned-token count uses `git grep --untracked -c -F`. Direct PD command for an operator who wants it: save the PD body as `pd.ps1` and run `pwsh -NoProfile -File pd.ps1 -FileList <six paths comma-separated>`. |

## Acceptance criteria affected

- AC-01 (Deterministic derivation): unchecked pending operator run C (P6-T9, P6-T10, P6-T11 third leg).
- AC-11 (Consumer fixture coverage), AC-12 (Consumer isolation), AC-13 (Fixture output hygiene): unchecked pending the operator post-fix fixture run (P6-T15 to P6-T19, P6-T41 to P6-T43).
- All other criteria are evaluated from CI, MCP, git, and static evidence as classified above.
