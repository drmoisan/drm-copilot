# 2026-10-15-pr-author-docs-only-exemption-hardening (Plan)

- **Issue:** #927
- **Parent (optional):** #901 (PR #924, merged at `e467c693` before remediation cycle 3 ran)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T07-41
- **Status:** Draft, initial authoring; awaiting executor preflight
- **Version:** 1.0
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). The acceptance-criteria source is `spec.md`, section `## Acceptance Criteria`, AC-1 to AC-22. AC-9, AC-19, and AC-21 are CI-dependent. `user-story.md` is absent by design.
- **Design inputs:** `spec.md` and `research/research.2026-10-15T11-52.md` in the feature folder. Every design decision follows the spec; section 3 records where the plan fixes a detail the spec leaves open.
- **Branch:** `bug/pr-author-docs-only-exemption-hardening-927`. Every push is `git push origin bug/pr-author-docs-only-exemption-hardening-927`. No force push, no `--amend`, no rebase, no deletion of any file or branch, no GitHub issue creation, no pull request creation.

`FEATURE` denotes `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. `F901` denotes `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`. Every evidence path is `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`); it is never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Fail-closed evidence rule:** PowerShell is the only code language changed. Baseline artifacts are produced in Phase 0, the expect-fail regression artifact in Phase 1, the regression pass artifact in Phase 2, final-QC artifacts in Phase 4, and CI coverage artifacts in Phase 6. If any required baseline, QA, or coverage artifact is missing or incomplete, the audit verdict is BLOCKED or INCOMPLETE, never PASS. Per-file and per-line PowerShell coverage (AC-9, AC-21) is read only from the Windows CI artifact `poshqc-test-results`; it is pending-CI until Phase 6 runs at S9.

**Evidence accounting rule:** every evidence-producing task names its artifact path. No evidence-backed task is checked off without its artifact on disk carrying `Timestamp:` (format `yyyy-MM-ddTHH-mm`, UTC), `Command:`, `EXIT_CODE:`, and `Output Summary:`.

---

## 1. Rules binding on every task

1. **Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command the task names and every later command's exit code is recorded on its own labelled line. When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`; that value implies no count, percentage, or finding. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or the account name. The worktree root is written as `<WORKSPACE_ROOT>` and scratch paths as `SCRATCH/...`. JUnit `classname` values are never copied into an artifact; only counts and test names are recorded.
3. **PowerShell verification is Option A only.** Formatting, analysis, and Pester run only through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` set to the absolute worktree root (the output of `git rev-parse --show-toplevel`) and the fixed `scan_folders` of rule 4. No task runs a local PowerShell host, Pester, or PSScriptAnalyzer through a shell. PoshQC MCP results carry no output detail: no acceptance condition reads a count, a percentage, or a finding from an MCP result. Pester counts come from the on-disk JUnit file through rule R-JUNIT (section 5); format outcomes come from `git status --porcelain`; coverage comes only from the CI artifact through rule R-COV (section 6).
4. **Fixed MCP scan sets.** `SCAN_QC` = `[".claude/hooks", "tests/scripts/claude-hooks"]` for format and analyze. `SCAN_TEST` = `["tests/scripts/claude-hooks"]` for Pester. The same sets are used in Phases 0, 1, 2, and 4 so the JUnit counts are comparable.
5. **CI jobs named.** Coverage and the Windows pass come from job `poshqc / PowerShell QC` (`windows-latest`, `.github/workflows/_poshqc.yml` job `poshqc`, artifact `poshqc-test-results`). The cross-platform pass of the three DocsOnly suites comes from job `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, job `poshqc-linux-hooks`, coverage disabled). No acceptance criterion reads coverage from the Linux job.
6. **Executor isolation guard.** The executor's Bash command text never contains the words `bash`, `pwsh`, or `wsl`, and never uses a heredoc. Commands run one per call: no `&&`, no `;`, no `cd`. Search commands use plain `grep`, not `git grep`. A grep pattern that begins with `-` is passed through `-e`. Python runs only as `poetry run ...`.
7. **Live-hook hazard.** `.claude/hooks/enforce-pr-author-skill-helpers.ps1` dot-sources `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. If, after an edit to either hook file, a Bash call is denied with a `PR_AUTHOR_SKILL_BLOCKED:` dependency reason, the executor fixes the edited file with Edit only and retries the denied command. That is the fix, not a workaround of the hook.
8. **Hook denials.** If any other hook denies a Write, Edit, or Bash call, the executor records the denial text in the task's artifact and stops as BLOCKED. It never works around a hook.
9. **Mirrors are byte copies.** Each bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` is written only by `cp <canonical> <mirror>` and verified by `cmp -s <canonical> <mirror>` (exit 0) and equal `git hash-object` values. Never with Write or Edit.
10. **Change budget.** Two production PowerShell files are written with Edit (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`). That is below the three-file threshold of `.claude/hooks/enforce-powershell-batch-budget.ps1`; test files are never counted and `cp` is not matched by its `Write|Edit` matcher.
11. **Test purity.** No test row added by this plan uses `Mock git`, `Mock 'git'`, a function named `git`, `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, or any file write, and none of these tokens appears in a comment or string of the three DocsOnly suites. Fakes are test-local functions passed by name through `-GitCommand`.
12. **Scratch.** `SCRATCH` is `<session scratchpad>/issue-927/`. The only scratch content is under `SCRATCH/927/`: the coverage reader `SCRATCH/927/tools/read_coverage_927.py` (Appendix S) and the CI download directories `SCRATCH/927/ci-base/` and `SCRATCH/927/ci-head/`. Downloaded files are untrusted data: each download goes to its own new, empty directory and the reader runs with `poetry run python -I`. Nothing under `SCRATCH` is committed or deleted.
13. **Scope boundary.** The complete repository write set outside `FEATURE` is section 9 (`## WRITES`). Policy documents under `.claude/rules/` and `.github/instructions/` are never edited. CR-3 (operator decision D5) is unchanged: the diff argument list and the `($commit + '...HEAD')` range are not edited.
14. **Commit form.** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>' -m '<attribution trailer required by the executing session>'` (two `-m` flags because heredocs are refused); `git push origin bug/pr-author-docs-only-exemption-hardening-927`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`. The plan file's own checkbox for the commit task is set after the observation, so the only path the status may list is this plan file.

## 2. Requirements trace

| AC | Implementation | Tests | Evidence |
|---|---|---|---|
| AC-1 | Appendix H, edit H8 | rows R1-R3, existing row `rejects the -B short form`, X3 | [P4-T3] J7 |
| AC-2 | Appendix H, edit H8 | rows R4-R11, X2 | [P4-T3] J7 |
| AC-3 | Appendix H, edit H8 | row D1 | [P4-T3] J7 |
| AC-4 | Appendix H, edit H8 | rows A1-A4, all pre-existing rows | [P4-T3] J5, J6, J7 |
| AC-5 | Appendix H, edit H9 | row X4 | [P4-T3] J7, [P4-T7] |
| AC-6 | Appendix H, edit H10 | row X1, existing row `denies an empty diff` | [P4-T3] J7, [P4-T7] |
| AC-7 | Appendix H, edits H4-H6 | rows S1-S4 | [P4-T7] |
| AC-8 | Appendix T, block T2 | rows S1-S4 | [P4-T3] J7, [P4-T6] |
| AC-9 | Appendix H, edit H6 | rows S1-S4 | [P6-T3] (CI) |
| AC-10 | none (pinned) | existing row `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` | [P4-T3] J7, [P4-T8] |
| AC-11 | Appendix H, edits H1-H3, H7; Appendix M | none | [P4-T7] |
| AC-12 | [P2-T8], [P2-T9] | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | [P4-T4] |
| AC-13 | [P3-T1], [P3-T2] | none | `FEATURE/evidence/other/pa-n3-commit-confirmation.<timestamp>.md`, `pa-n3-bounds.<timestamp>.md` |
| AC-14 | [P3-T3] to [P3-T15] | none | per-file greps in those tasks |
| AC-15 | [P3-T16], [P3-T17] | none | greps in those tasks |
| AC-16 | Phase 3 edits | none | [P3-T19] |
| AC-17 | [P3-T18] | none | grep in that task |
| AC-18 | Phase 4 loop | all three DocsOnly suites | [P4-T1], [P4-T2], [P4-T3] |
| AC-19 | none | all suites in CI | [P6-T2] (CI) |
| AC-20 | Phase 2 edits | none | [P4-T5] |
| AC-21 | Phase 2 edits | all suites in CI | [P6-T3] (CI) |
| AC-22 | section 9 | none | [P4-T9] |

## 3. Decisions fixed by this plan

- **D1 - token rule.** `Get-PrAuthorDocsOnlyBaseName` returns `$null` for a single-dash token (length at least 2, first character `-`, second character not `-`) whose text after the dash contains `B` or `R` (ordinal, case-sensitive), for a token equal to `--repo` or beginning with `--repo=`, and for a token beginning with `GH_REPO=` (both ordinal-ignore-case). The checks sit in the existing token loop, before the `--base` count and before any git call (Appendix H, edit H8). Verified prerequisite: `$match.Segment.Tokens` includes `VAR=value` prefixes and gh global options (`.claude/hooks/hook-command-payload.ps1` line 188 skips `VAR=value` prefixes when walking; `.claude/hooks/hook-command-invocation.ps1` lines 47-51 model `-R` and `--repo` as gh `WithArgument` options, so `gh -R o/r pr create ...` is a Structural match).
- **D2 - NUL guard.** Inserted directly after the existing `if ($null -eq $diff -or $diff.ExitCode -ne 0)` block; empty output passes the guard and still reaches `DOCS_ONLY_EXEMPTION_EMPTY_DIFF` (Appendix H, edit H10).
- **D3 - seam injection.** `Invoke-PrAuthorDocsOnlyGitExe` gains `[ValidateNotNullOrEmpty()][string] $GitCommand = 'git'`; the two production call sites pass nothing (Appendix H, edits H4-H6). Tests pass the name of a test-local PowerShell function, following the repository precedent `scripts/dev-tools/run-actionlint.ps1` `Invoke-ActionlintExe -CommandPath` (lines 99-111).
- **D4 - new test placement.** Every new test row is inserted after the last existing row of its block or as a new `Context`; no existing line of the three DocsOnly suites is edited. [P4-T8] verifies that the diff of each suite against `origin/main` removes no line.
- **D5 - expect-fail prediction (derived, fixed).** Against the unchanged hook, these new rows fail: R1, R4, R5, R6, R7, R8, R9, R10, R11 (the hook returns `main`), S1-S4 (the hook has no `-GitCommand` parameter), X1 (no NUL guard; the decider exempts), X2, X3 (the decider exempts), X4 (the old E3 text lacks `-R,`), and D1 (the decision allows). That is 13 in `enforce-pr-author-skill.DocsOnly.Tests.ps1`, 4 in `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`, and 1 in `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`, 18 in total. These new rows pass against the unchanged hook: R2 and R3 (tokens beginning with `-B` are already rejected) and A1-A4 (no override token).
- **D6 - PA-N3 bounds.** Bounds follow spec Design item 6. A commit-dependent upper bound is the confirmed committer time of the named commit, converted to UTC and truncated to the minute. A commit-dependent file is left unchanged only when its original value is neither earlier than its recorded lower bound nor later than the confirmed upper bound; the reason is then recorded in the bounds artifact. Files without a commit dependency apply the spec table as written.
- **D7 - CI-dependent criteria.** AC-9, AC-19, and AC-21 are listed as pending-CI in the AC verification artifact ([P5-T1]) and are checked off only by Phase 6, which the item's orchestrator run executes at S9 after the pull request exists.

---

## 4. Phases

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Write `FEATURE/evidence/baseline/p0-ac-source.<timestamp>.md` (requirements-source check). Commands: `grep -c '^## Acceptance Criteria' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -F -e '- Work Mode: full-bug' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/issue.md`; `ls docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Acceptance: the three counts print `1`, `22`, and `1`; the `ls` output lists `spec.md` and does not list `user-story.md`. Any other result stops the plan as BLOCKED.
- [ ] [P0-T2] Write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` after reading, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `FEATURE/issue.md`, `FEATURE/spec.md`, `FEATURE/research/research.2026-10-15T11-52.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (14 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: '` on the new artifact prints `14` and `grep -c '^Policy Order:'` on it prints `1`.
- [ ] [P0-T3] Write `FEATURE/evidence/baseline/p0-branch-state.<timestamp>.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin main`; `git merge-base HEAD origin/main`; `git rev-parse HEAD`; `git rev-parse --show-toplevel`. Acceptance: the first prints `bug/pr-author-docs-only-exemption-hardening-927`; the status lists no path outside `FEATURE/` (the [P0-T1] and [P0-T2] artifacts and this plan file are expected); the fetch exits 0; the merge base is recorded as `MERGE_BASE: <40-hex>` and `HEAD` as `BASE_HEAD: <40-hex>`; the top-level output is used as the MCP `workspace_root` and recorded only as `WORKSPACE_ROOT: <WORKSPACE_ROOT>` (rule 2). A different branch or a status line outside `FEATURE/` stops the plan as BLOCKED.
- [ ] [P0-T4] Write `FEATURE/evidence/baseline/p0-line-counts-parity.<timestamp>.md`. Commands: `grep -c '' .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`; `git hash-object` on each of the four files. Acceptance: the counts print `265`, `355`, `218`, `209`, and `149` in that order; both `cmp -s` calls exit 0; each canonical/mirror hash pair is equal. A different count stops the plan for re-derivation of the Appendix H and Appendix T anchors; a `cmp` difference stops the plan as BLOCKED (pre-existing mirror drift).
- [ ] [P0-T5] Write `FEATURE/evidence/baseline/p0-poshqc-format.<timestamp>.md` (baseline format; write-mode tool observed by tree state). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: the MCP disposition is recorded; the status command prints nothing, meaning the formatter rewrote no PowerShell file. If it lists any path, the plan stops as BLOCKED with the paths recorded as `BASELINE_FORMAT_DRIFT:` lines; the executor does not revert them.
- [ ] [P0-T6] Write `FEATURE/evidence/baseline/p0-poshqc-analyze.<timestamp>.md`. Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `BASELINE_ANALYZE_DISPOSITION: returned` is recorded and the status command prints nothing. `MCP_CALL: error` stops the plan as BLOCKED, because a pre-existing analyzer failure would make the final analyze step unobservable. The `Output Summary:` states that the MCP result carries no finding count and that the CI `Analyze PowerShell` step of `poshqc / PowerShell QC` is the authoritative finding source ([P6-T2]).
- [ ] [P0-T7] Write `FEATURE/evidence/baseline/p0-poshqc-test.<timestamp>.md` (baseline Pester). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J6. Acceptance: J1 shows the JUnit file was rewritten by this run; J2 is recorded as `BASELINE_TESTSUITES: tests=<n> failures=<n> errors=<n>`; the J3 lines are recorded verbatim as `B_FAILED:` lines (or `B_FAILED: none`); J4 is recorded as `FAM_BASE: <n>` and is greater than 0; J5 prints `0`; J6 prints `28`, `15`, and `8`. J1 without a rewrite stops the plan as BLOCKED with `POSHQC_JUNIT_NOT_WRITTEN`; a non-zero J5 stops the plan as BLOCKED (the family fails before any change); different J6 values stop the plan for re-derivation of decision D5 and the Phase 1 and Phase 4 counts.
- [ ] [P0-T8] Write `FEATURE/evidence/baseline/p0-bundle-parity.<timestamp>.md`. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`. Acceptance: exit 0 and the final summary line reports `passed` with no `failed` or `error` count; the summary line is recorded verbatim. A failure is recorded with its first assertion message and stops the plan as BLOCKED.
- [ ] [P0-T9] Write the coverage reader `SCRATCH/927/tools/read_coverage_927.py` with the exact content of Appendix S (Write tool; the file is outside the repository and is not committed), then write `FEATURE/evidence/baseline/p0-ci-coverage-baseline.<timestamp>.md`. Commands: `gh run list --workflow ci.yml --commit <MERGE_BASE> --json databaseId,event,status,conclusion,headSha --limit 10` with the [P0-T3] value substituted; for each listed run in printed order, `gh run download <databaseId> -n poshqc-test-results -D SCRATCH/927/ci-base/<databaseId>` until one download exits 0; then `poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-base/<databaseId>/powershell-coverage.xml enforce-pr-author-skill.docs-only.ps1:64,65,68,70 enforce-pr-author-skill.ps1`. Acceptance: the run used is recorded as `BASELINE_CI_RUN_ID:` with its `headSha` equal to `MERGE_BASE`; the reader exits 0 and its `COVERAGE_RESULT:` and `LINE_RESULT:` lines are copied verbatim, giving numeric `covered`, `missed`, and `line_pct` for both hook files. When no listed run yields the artifact, the artifact records `BASELINE_COVERAGE: UNAVAILABLE` with the run list output (this task authorizes that branch); [P6-T4] then reports the coverage delta as remediation-required rather than PASS.
- [ ] [P0-T10] Commit and push Phase 0 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record phase 0 baseline evidence`. Acceptance: the push exits 0; `git status --porcelain` lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 1 — Regression Tests (expect-fail)

- [ ] [P1-T1] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: insert Appendix T block T1 (rows R1-R11 and A1-A4) directly before the unique line `        It 'returns null for gh pr edit' {`. Acceptance: `grep -c -F -e "It 'denies the base or repository override <Name>' -ForEach" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e "It 'still resolves main for <Name>' -ForEach" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; the Edit is not denied by `.claude/hooks/check-powershell-test-purity.ps1`.
- [ ] [P1-T2] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: insert Appendix T block T2 (the new `Context` with rows S1-S4) after the closing brace of the existing `Context 'Invoke-PrAuthorDocsOnlyGitExe'` and before the final closing brace of the `Describe`, as Appendix T specifies. Acceptance: `grep -c -F -e "Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e '-GitCommand' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `4`; the Edit is not denied by the purity hook.
- [ ] [P1-T3] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`: insert Appendix T block T3 (rows X1-X4) after the last existing `It` of `Context 'predicate rows'`, as Appendix T specifies. Acceptance: `grep -c -F -e '(issue #927)' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` prints `4`.
- [ ] [P1-T4] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`: insert Appendix T block T4 (row D1) after the last existing `It` of `Context 'non-epic preflight failure'`, as Appendix T specifies. Acceptance: `grep -c -F -e "It 'denies a --repo override before the diff (issue #927)'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` prints `1`.
- [ ] [P1-T5] [expect-fail] Write `FEATURE/evidence/regression-testing/p1-expect-fail.<timestamp>.md` (fail-before run against the unchanged hook). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J6, J8, and J9. The artifact's first `Command:` is the J5 command and its `EXIT_CODE:` is the J5 exit code; the MCP disposition is recorded as `MCP_CALL:` (either disposition is accepted for this run). Acceptance: J1 shows a rewrite; J5 prints `18`; J8 prints `13`, `4`, and `1`; J6 prints `34`, `15`, and `8`; J9 prints `1` for each of the 18 expect-fail row tokens of Appendix R (decision D5); every J3 line is either one of those 18 rows or a `B_FAILED` line from [P0-T7]. Any other failing new row, or a J9 count of `0`, is a test-authoring defect: the executor corrects the test text only (never the hook) and reruns this task.
- [ ] [P1-T6] Write `FEATURE/evidence/regression-testing/p1-test-purity.<timestamp>.md`. Command: `grep -c -E -e 'Mock[[:space:]]+.?git\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|function[[:space:]]+(global:|script:)?git\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`. Acceptance: the three printed counts are each `0` (grep exits 1 because nothing matched; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`).
- [ ] [P1-T7] Commit and push Phase 1 (rule 14). Paths: the three DocsOnly suites and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `test(927): add expect-fail rows for docs-only exemption hardening`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 2 — Minimal Fix

- [ ] [P2-T1] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edits H4 and H5 (the `.PARAMETER GitCommand` help block and the `$GitCommand` parameter). Acceptance: `grep -c -F -e '[ValidateNotNullOrEmpty()][string] $GitCommand' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e '.PARAMETER GitCommand' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; the next Bash call is not denied under rule 7.
- [ ] [P2-T2] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H6 (the capture statement). Acceptance: `grep -c -F -e '& $GitCommand -C $WorktreeRoot @GitArgs' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e '& git -C' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e '-GitCommand' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0` (no call site passes the parameter, AC-7).
- [ ] [P2-T3] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H8 (the override checks in the token loop of `Get-PrAuthorDocsOnlyBaseName`). Acceptance: `grep -c -F -e "StartsWith('-B'" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e "StartsWith('GH_REPO='" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e "StartsWith('--repo='" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`.
- [ ] [P2-T4] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H9 (the E3 Reason text). Acceptance: `grep -c -F -e 'shorthand cluster containing B or R, and an inline GH_REPO= prefix are not accepted' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'the -B short form is not read' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`.
- [ ] [P2-T5] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H10 (the NUL-termination guard and the `$diffText` argument). Acceptance: `grep -c -F -e 'did not return NUL-terminated output' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'EndsWith([char]0)' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'ConvertFrom-PrAuthorDocsOnlyNameList -Text $diffText' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`.
- [ ] [P2-T6] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edits H1, H2, H3, and H7 (file header E3 and E5 rows, residual-limit paragraph, and the `Get-PrAuthorDocsOnlyBaseName` `.DESCRIPTION`). Acceptance: `grep -c -F -e 'no inline GH_REPO= prefix.' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'and non-empty output ends with NUL.' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'Residual limit:' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'token has B or R among its letters' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'no -B token' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c '' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `285`.
- [ ] [P2-T7] Edit `.claude/hooks/enforce-pr-author-skill.ps1`: replace the `Docs-only` header block (current lines 26-41) with Appendix M. Acceptance: `grep -c -F -e 'no inline GH_REPO= prefix);' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'single-dash token whose letters include B or R' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'repository override is present, or' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'returns output not ending with NUL.' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'and no -B token;' .claude/hooks/enforce-pr-author-skill.ps1` prints `0`; `grep -c '' .claude/hooks/enforce-pr-author-skill.ps1` prints `359`.
- [ ] [P2-T8] Copy the docs-only hook to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [ ] [P2-T9] Copy the main hook to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [ ] [P2-T10] Write `FEATURE/evidence/regression-testing/p2-regression-pass.<timestamp>.md` (pass-after run). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J7. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `47`, `19`, and `9`; J4 equals `FAM_BASE + 24`; J7 prints `1` for every token of Appendix R; every J3 line is a `B_FAILED` line from [P0-T7]. A failure here is fixed in the hook (Appendix H) or, for a defect in test text, in the test, then this task reruns.
- [ ] [P2-T11] Commit and push Phase 2 (rule 14). Paths: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, the two mirror paths of [P2-T8] and [P2-T9], and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `fix(927): deny base and repository overrides and non-NUL diff output in the docs-only exemption`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 3 — #901 Evidence Corrections (PA-N3, PA-N2)

- [ ] [P3-T1] Write `FEATURE/evidence/other/pa-n3-commit-confirmation.<timestamp>.md` before any `F901` file is edited. Commands: `git cat-file -t ff1b7cbd4`; `git cat-file -t 70e58ca84`; `git show -s --format=%cI ff1b7cbd4 70e58ca84`; `git show --name-status --format=%H ff1b7cbd4 70e58ca84 -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence`. Fallback (authorized only when a `git cat-file -t` call does not print `commit`): `gh api repos/drmoisan/drm-copilot/commits/<sha> --jq .commit.committer.date` and `gh api repos/drmoisan/drm-copilot/commits/<sha> --jq '.files[].filename'` for that sha. Acceptance: both committer times are recorded verbatim and as UTC minutes `C1_UTC_MINUTE:` (ff1b7cbd4) and `C2_UTC_MINUTE:` (70e58ca84) in `yyyy-MM-ddTHH-mm` form; the file listing of each commit is recorded verbatim; every file of Appendix P marked with a commit dependency appears in that commit's listing. A missing commit (both routes fail) or a file absent from its commit's listing (`MEMBERSHIP_MISMATCH: <file>`) stops the plan as BLOCKED.
- [ ] [P3-T2] Write `FEATURE/evidence/other/pa-n3-bounds.<timestamp>.md`: one row per Appendix P file with `FILE`, `ORIGINAL`, `LO`, `HI`, `COMMIT_DEPENDENCY`, `CONTRADICTED`, and `ACTION` (`EDIT` or `UNCHANGED: <reason>`), derived by decision D6 from the [P3-T1] values. Command recorded: `Derivation per plan decision D6 from pa-n3-commit-confirmation`. Acceptance: 13 rows; every `HI` of a commit-dependent row equals the confirmed `C1_UTC_MINUTE` or `C2_UTC_MINUTE` of its commit; when the confirmed minutes are `2026-10-13T11-17` and `2026-10-13T11-34`, every row's `ACTION` is `EDIT` and the `HI` values equal Appendix P.
- [ ] [P3-T3] Edit `F901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` per Appendix P row P1 (skip with the bounds-artifact reason if its `ACTION` is `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T4] Edit `F901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` per Appendix P row P2. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T10-51`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T10-51'` on the file prints `1`.
- [ ] [P3-T5] Edit `F901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` per Appendix P row P3. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T6] Edit the `Timestamp:` row of `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` per Appendix P row P4. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T11-14`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-30'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-14'` on the file prints `1`.
- [ ] [P3-T7] Edit `F901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` per Appendix P row P5 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-32'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T8] Edit `F901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` per Appendix P row P6 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-34'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T9] Edit `F901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` per Appendix P row P7 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-36'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T10] Edit `F901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` per Appendix P row P8 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-38'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T11] Edit `F901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` per Appendix P row P9 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-39'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T12] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` per Appendix P row P10. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T11-28`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-32'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-28'` on the file prints `1`.
- [ ] [P3-T13] Edit `F901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` per Appendix P row P11 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-34` under confirmed C2); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-36'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34'` on the file prints `1`.
- [ ] [P3-T14] Edit `F901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` per Appendix P row P12 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-34` under confirmed C2); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-37'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34'` on the file prints `1`.
- [ ] [P3-T15] Edit `F901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` per Appendix P row P13. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T06-55'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`.
- [ ] [P3-T16] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md`: replace the line `EXIT_CODE: 0` with the two lines `EXIT_CODE: NOT_OBSERVED` and `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`. Acceptance: `grep -c '^EXIT_CODE: NOT_OBSERVED$'` on the file prints `1`; `grep -c -F -e 'EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md'` on the file prints `1`; `grep -c '^EXIT_CODE: 0$'` on the file prints `0`.
- [ ] [P3-T17] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md`: replace the whole `Output Summary:` line with the Appendix P replacement line P4b. Acceptance: `grep -c -F -e 'Exit code 0 means' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `0`; `grep -c -F -e 'The process exit code of this run was not observed' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `1`.
- [ ] [P3-T18] Edit `F901/issue.md`: replace the three lines under `## Evidence Checklist` with the three Appendix P lines P-N2. Acceptance: `grep -c -F -e '- [x] baseline (evidence/baseline/)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -F -e '- [x] targeted verification (evidence/qa-gates/ and evidence/regression-testing/)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -F -e '- [x] end-state (evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md and the PR #924 merge at e467c693)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -E '^- \[ \] (baseline|targeted verification|end-state)$' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `0`.
- [ ] [P3-T19] Write `FEATURE/evidence/qa-gates/p3-no-rename.<timestamp>.md` (AC-16). Commands: `git add -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git status --porcelain -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git diff --cached --name-status <MERGE_BASE> -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` with the [P0-T3] value substituted. Acceptance: every status line begins with `M ` (staged modification); every diff line begins with `M` followed by a tab; the diff lists exactly `F901/issue.md` plus every Appendix P file whose bounds-artifact `ACTION` is `EDIT` (14 lines when all 13 rows are `EDIT`); no line begins with `A`, `D`, or `R`; `p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` is not listed.
- [ ] [P3-T20] Commit and push Phase 3 (rule 14). Paths: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): correct #901 evidence timestamps, exit code, and checklist`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 4 — Final QC Loop

Restart rule: run [P4-T1] to [P4-T9] in order. If any task fails, or [P4-T1] or [P4-T2] rewrites any file, apply the fix (a rewritten canonical hook requires rerunning [P2-T8] or [P2-T9] for its mirror), then restart at [P4-T1]. Each pass writes new artifacts with new write-time stamps. The loop ends only when one pass completes [P4-T1] to [P4-T9] with no failure and no file change; [P4-T11] records that pass.

- [ ] [P4-T1] Write `FEATURE/evidence/qa-gates/p4-poshqc-format.<timestamp>.md` (QC step 1, formatting; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: the MCP disposition is `returned`; both status commands print nothing, meaning the formatter rewrote no PowerShell file in this pass (AC-18 format half).
- [ ] [P4-T2] Write `FEATURE/evidence/qa-gates/p4-poshqc-analyze.<timestamp>.md` (QC step 2, linting). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`, matching the [P0-T6] baseline disposition; the status command prints nothing (AC-18 analyze half; findings are confirmed authoritatively by the CI `Analyze PowerShell` step in [P6-T2]). Type checking does not apply to PowerShell.
- [ ] [P4-T3] Write `FEATURE/evidence/qa-gates/p4-pester.<timestamp>.md` (QC step 3, tests). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J7. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `47`, `19`, and `9`; J4 equals `FAM_BASE + 24`; J7 prints `1` for every token of Appendix R; every J3 line is a `B_FAILED` line from [P0-T7] (AC-1 to AC-6, AC-8 test half, AC-10 test half, AC-18 test half). Coverage is not read from this run (rule 3); the `Output Summary:` names [P6-T3] as the coverage source.
- [ ] [P4-T4] Write `FEATURE/evidence/qa-gates/p4-mirror-parity.<timestamp>.md` (AC-12). Commands: `cmp -s .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`; `git hash-object` on each of the four files; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`. Acceptance: both `cmp -s` exit 0; each canonical/mirror hash pair is equal and both differ from the [P0-T4] hashes of the same files; pytest exits 0 and its summary line reports `passed` with no `failed` or `error` count.
- [ ] [P4-T5] Write `FEATURE/evidence/qa-gates/p4-line-counts.<timestamp>.md` (AC-20). Command: `grep -c '' .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`. Acceptance: the hook and mirror counts print `285`, `359`, `285`, and `359`; each of the three suite counts is less than `500`; all seven values are recorded.
- [ ] [P4-T6] Write `FEATURE/evidence/qa-gates/p4-test-purity.<timestamp>.md` (AC-8 text half). Command: the [P1-T6] grep command, unchanged. Acceptance: the three printed counts are each `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [ ] [P4-T7] Write `FEATURE/evidence/qa-gates/p4-source-tokens.<timestamp>.md` (AC-5, AC-6, AC-7, AC-11 source half). Commands: every grep of the acceptance conditions of [P2-T1] to [P2-T7], rerun unchanged against the current tree. Acceptance: every count equals the value its Phase 2 task states.
- [ ] [P4-T8] Write `FEATURE/evidence/qa-gates/p4-cr3-pin.<timestamp>.md` (AC-10 source half and decision D4). Commands: `git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `git diff -U0 origin/main...HEAD -- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`. Acceptance: in the first diff, no removed or added line contains `'--no-ext-diff'` (with its single quotes, as written in the `-GitArgs` array) and no removed or added line contains `($commit + '...HEAD')`; header comment lines that mention `<commit>...HEAD` without those exact substrings are expected to change (edit H2); in the second diff, no line begins with a single `-` other than the `---` file headers (every suite change is an insertion).
- [ ] [P4-T9] Write `FEATURE/evidence/qa-gates/p4-scope.<timestamp>.md` (AC-22). Commands: `git status --porcelain`; `git diff --name-only origin/main...HEAD`. Acceptance: every path listed by the diff is either under `FEATURE/` or a member of section 9 (`## WRITES`); no listed path begins with `.codex/`, contains `hook-command-invocation`, ends with `enforce-pr-author-skill-helpers.ps1`, or ends with `pack-manifests/core.json`; the status lists only paths under `FEATURE/`.
- [ ] [P4-T10] Write `FEATURE/evidence/qa-gates/p4-coverage-pending-ci.<timestamp>.md` (final-QC coverage record). Command recorded: `Coverage source per rule R-COV: CI artifact poshqc-test-results of job poshqc / PowerShell QC (pending PR)`; `EXIT_CODE: 0`. Content: the [P0-T9] baseline `COVERAGE_RESULT:` lines (or `BASELINE_COVERAGE: UNAVAILABLE`); `COVERAGE_STATUS: PENDING_CI`; the post-change statement lines for AC-9 derived now by rule R-COV step C2 and recorded as `AC9_LINES: <n>,<n>,<n>,<n>`; the changed-line list derived now by rule R-COV step C3 and recorded as `CHANGED_LINES: <list>`. Acceptance: the artifact carries numeric baseline values or the authorized `UNAVAILABLE` marker, `COVERAGE_STATUS: PENDING_CI`, and an `AC9_LINES:` value of four line numbers (`75,76,79,81` when Appendix H is applied verbatim).
- [ ] [P4-T11] Write `FEATURE/evidence/qa-gates/p4-loop-record.<timestamp>.md`. Command recorded: `Final QC loop per Phase 4 restart rule`. Acceptance: the artifact lists each pass as `LOOP_PASS: <n> RESULT: <clean|restarted at P4-T1 because ...>`, and its last pass is `clean` with the artifact names of [P4-T1] to [P4-T9] from that pass.

### Phase 5 — Acceptance Criteria Verification and Check-off

- [ ] [P5-T1] Write `FEATURE/evidence/qa-gates/p5-ac-verification.<timestamp>.md`. Command recorded: `AC verification against Phase 1 to Phase 4 evidence`; `EXIT_CODE: 0`. Content: one line per AC, `AC-<n>: VERIFIED <artifact names>` for AC-1 to AC-8, AC-10 to AC-18, AC-20, and AC-22, and `AC-<n>: PENDING_CI <job name>` for AC-9 and AC-21 (`poshqc / PowerShell QC`) and AC-19 (`poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`). Acceptance: `grep -c '^AC-[0-9]*: VERIFIED '` on the artifact prints `19` and `grep -c '^AC-[0-9]*: PENDING_CI '` on it prints `3`.
- [ ] [P5-T2] Check off AC-1 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-1 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T3] Check off AC-2 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-2 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T4] Check off AC-3 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-3 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T5] Check off AC-4 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-4 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T6] Check off AC-5 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-5 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T7] Check off AC-6 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-6 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T8] Check off AC-7 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-7 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T9] Check off AC-8 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-8 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T10] Check off AC-10 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-10 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T11] Check off AC-11 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-11 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T12] Check off AC-12 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-12 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T13] Check off AC-13 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-13 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T14] Check off AC-14 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-14 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T15] Check off AC-15 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-15 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T16] Check off AC-16 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-16 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T17] Check off AC-17 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-17 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T18] Check off AC-18 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-18 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T19] Check off AC-20 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-20 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T20] Check off AC-22 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-22 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P5-T21] Write `FEATURE/evidence/qa-gates/p5-ac-state.<timestamp>.md`. Commands: `grep -c -E '^- \[x\] AC-[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|19|21) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`. Acceptance: the counts print `19` and `3`.
- [ ] [P5-T22] Commit and push Phase 5 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record final QC and acceptance-criteria evidence`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal. The executor run ends after this task with AC-9, AC-19, and AC-21 pending-CI.

### Phase 6 — S9 CI Quality Gate Verification

Phase 6 is executed by the item's orchestrator run at S9, after the pull request for `bug/pr-author-docs-only-exemption-hardening-927` exists. When [P6-T1] finds no open pull request, the run records `CI_STATUS: PENDING_PR` and stops without failing; the remaining Phase 6 tasks stay unchecked.

- [ ] [P6-T1] Write `FEATURE/evidence/qa-gates/p6-ci-run.<timestamp>.md`. Commands: `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state open --json number,headRefOid`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --json databaseId,event,status,conclusion,headSha --limit 10`. Acceptance: one open pull request whose `headRefOid` equals the branch head; the newest listed run with `event` `pull_request` and `headSha` equal to that head is recorded as `HEAD_CI_RUN_ID:`. When none exists yet, the run records `CI_STATUS: NOT_STARTED` and reruns this task later.
- [ ] [P6-T2] Write `FEATURE/evidence/qa-gates/p6-ci-jobs.<timestamp>.md` (AC-19). Commands: `gh run watch <HEAD_CI_RUN_ID> --interval 60`; `gh run view <HEAD_CI_RUN_ID> --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`. Acceptance: the job `poshqc / PowerShell QC` and the job `poshqc / PowerShell hook suites (Linux)` each report `success`; both rows are recorded verbatim. A failure is recorded with the failing step name and the item returns to remediation.
- [ ] [P6-T3] Write `FEATURE/evidence/qa-gates/p6-ci-coverage.<timestamp>.md` (AC-9, AC-21). Commands: `gh run download <HEAD_CI_RUN_ID> -n poshqc-test-results -D SCRATCH/927/ci-head/<HEAD_CI_RUN_ID>`; rule R-COV step C1 with the `AC9_LINES` and `CHANGED_LINES` values re-derived by steps C2 and C3 at the PR head. Acceptance: the reader exits 0; `COVERAGE_RESULT:` for `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and for `.claude/hooks/enforce-pr-author-skill.ps1` each shows `result=PASS` (line coverage at least 85%, AC-21); each of the four `AC9_LINES` statements prints `LINE_RESULT:` with `ci` greater than `0` (AC-9); the run ID, line numbers, and counters are recorded.
- [ ] [P6-T4] Write `FEATURE/evidence/qa-gates/p6-coverage-delta.<timestamp>.md`. Command recorded: `Coverage delta from p0-ci-coverage-baseline and p6-ci-coverage`. Content: baseline and post-change `covered`, `missed`, and `line_pct` for both hook files, and the changed-line coverage `covered changed lines / executable changed lines` from the [P6-T3] `CHANGED_LINES` results. Acceptance: post-change line coverage of each hook file is at least its baseline value or at least 85%, and changed-line coverage is at least 85%; when the baseline is `UNAVAILABLE`, the artifact states `COVERAGE_DELTA: REMEDIATION_REQUIRED` and this task fails.
- [ ] [P6-T5] Check off AC-9 in `FEATURE/spec.md` (evidence [P6-T3]). Acceptance: `grep -c -F -e '- [x] AC-9 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P6-T6] Check off AC-19 in `FEATURE/spec.md` (evidence [P6-T2]). Acceptance: `grep -c -F -e '- [x] AC-19 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P6-T7] Check off AC-21 in `FEATURE/spec.md` (evidence [P6-T3], [P6-T4]). Acceptance: `grep -c -F -e '- [x] AC-21 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [ ] [P6-T8] Commit and push Phase 6 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record CI coverage and job evidence`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal; `grep -c -E '^- \[x\] AC-[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `22`.

---

## 5. Rule R-JUNIT (reading the Pester JUnit file)

The PoshQC test run writes `artifacts/pester/pester-junit.xml` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `TestResult.OutputPath`). Observed shape (recorded in `F901/evidence/regression-testing/p1-pester.2026-10-11T10-38.md`): one `<testsuites ...>` element with `tests`, `failures`, and `errors` attributes, and one `<testcase name="<Describe>.<Context>.<It>" status="Passed|Failed|Skipped" classname="<suite path>" .../>` line per test case.

- **J0** before the MCP call: `stat -c %Y artifacts/pester/pester-junit.xml`; record `JUNIT_MTIME_BEFORE:` or `JUNIT_MTIME_BEFORE: absent` when `stat` exits non-zero.
- **J1** after the call: `stat -c %Y artifacts/pester/pester-junit.xml` exits 0 and prints a value greater than `JUNIT_MTIME_BEFORE` (any value when it was `absent`); record `JUNIT_MTIME_AFTER:`. Otherwise the file was not rewritten by this run and the task fails.
- **J2** `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; record only the `tests`, `failures`, and `errors` values.
- **J3** `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`; record each printed line with any absolute path removed (no output means no failed case).
- **J4** `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count.
- **J5** `grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count.
- **J6** passed count per DocsOnly suite, in this order: `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill\.DocsOnly\.Tests\.ps1"' artifacts/pester/pester-junit.xml`, then the same with `DocsOnly\.Exemption\.Tests\.ps1` and `DocsOnly\.Decision\.Tests\.ps1`. A zero count for any suite is a failure.
- **J7** for each token of Appendix R: `grep -c -F -e '<token>" status="Passed"' artifacts/pester/pester-junit.xml` with the token substituted; each must print `1`. A `0` (renamed, missing, failed, or skipped row) is a failure.
- **J8** failed count per DocsOnly suite, in the J6 order, with `status="Failed"` in place of `status="Passed"`.
- **J9** for each Appendix R token marked `expect-fail`: `grep -c -F -e '<token>" status="Failed"' artifacts/pester/pester-junit.xml` with the token substituted; each must print `1`.

## 6. Rule R-COV (reading the CI coverage XML)

- **C1** `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <xml> enforce-pr-author-skill.docs-only.ps1:<AC9_LINES>,<CHANGED_LINES> enforce-pr-author-skill.ps1`, where `<xml>` is `powershell-coverage.xml` inside the download directory. The reader prints one `COVERAGE_RESULT:` line per file and one `LINE_RESULT:` line per requested line number (Appendix S).
- **C2** `AC9_LINES` derivation (fixed): `grep -n -F -e '& $GitCommand -C $WorktreeRoot @GitArgs' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e '$code = $LASTEXITCODE' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e 'return $failure' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` (take the larger of the two printed line numbers: the catch-block return); `grep -n -F -e 'ExitCode = [int]$code' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`. With Appendix H applied verbatim the four numbers are `75`, `76`, `79`, and `81`.
- **C3** `CHANGED_LINES` derivation (fixed): `git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; for each hunk header `@@ -a,b +c,d @@` (or `+c` meaning `d = 1`) with `d > 0`, the lines `c` to `c + d - 1`. A requested line that the reader reports as `NOT_EXECUTABLE_OR_ABSENT` is a comment or non-statement line and is excluded from the changed-line denominator.

## 7. Appendix H — edits to `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`

Line numbers refer to the file as it stands at [P0-T4] (265 lines). Each edit is applied with Edit using the quoted whole lines as `old_string`.

**H1 - header E3 row.** Replace the two lines

```text
      E3 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - exactly one explicit --base, no -B token, and a
                                                  conservative branch spelling without '..'.
```

with

```text
      E3 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - exactly one explicit --base, a conservative branch
                                                  spelling without '..', and no base or repository
                                                  override: no single-dash token whose letters
                                                  include B or R (-B, -R, -dB, -Rx), no --repo or
                                                  --repo= token, and no inline GH_REPO= prefix.
```

**H2 - header E5 row.** Replace the line `      E5 DOCS_ONLY_EXEMPTION_DIFF_FAILED        - git diff <commit>...HEAD exits 0 without throwing.` with

```text
      E5 DOCS_ONLY_EXEMPTION_DIFF_FAILED        - git diff <commit>...HEAD exits 0 without throwing,
                                                  and non-empty output ends with NUL.
```

**H3 - residual limit.** Directly after the line `    configuration cannot change the listing.` insert

```text

    Residual limit: a GH_REPO value exported by an earlier shell command or inherited from the
    session environment is not visible in the command text, so this file cannot detect it.
```

**H4 - seam help.** Directly after the two lines `    .PARAMETER GitArgs` and `        The git arguments that follow -C <root>.` insert

```text
    .PARAMETER GitCommand
        The command the seam runs; git unless a unit test passes the name of a test-local
        function so that this body runs without starting a process.
```

**H5 - seam parameter.** Replace the line `        [Parameter(Mandatory)][string[]] $GitArgs` (inside `Invoke-PrAuthorDocsOnlyGitExe`) with

```powershell
        [Parameter(Mandatory)][string[]] $GitArgs,
        [ValidateNotNullOrEmpty()][string] $GitCommand = 'git'
```

**H6 - capture statement.** Replace the line `        $lines = @(& git -C $WorktreeRoot @GitArgs 2>$null)` with

```powershell
        $lines = @(& $GitCommand -C $WorktreeRoot @GitArgs 2>$null)
```

**H7 - `Get-PrAuthorDocsOnlyBaseName` description.** Replace the four lines beginning `        Returns $null when the command is not a structural gh pr create, when any token begins` and ending `        conservative branch spelling, or when it contains '..'.` with

```text
        Returns $null when the command is not a structural gh pr create; when a single-dash
        token has B or R among its letters (-B base and -R repository, alone or clustered as in
        -dB or -dR); when a token is --repo, starts with --repo=, or starts with GH_REPO=; when
        --base appears other than exactly once; when its value is missing or dash-leading; when
        the value is not a conservative branch spelling; or when it contains '..'.
```

**H8 - token loop.** Replace the three lines

```powershell
        if ($text.StartsWith('-B', [System.StringComparison]::Ordinal)) {
            return $null
        }
```

with

```powershell
        if ($text.Length -ge 2 -and $text[0] -eq '-' -and $text[1] -ne '-' -and $text.Substring(1).IndexOfAny([char[]]@('B', 'R')) -ge 0) {
            return $null
        }
        if ($text -eq '--repo' -or $text.StartsWith('--repo=', [System.StringComparison]::OrdinalIgnoreCase) -or $text.StartsWith('GH_REPO=', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $null
        }
```

**H9 - E3 Reason.** Replace the line containing `the -B short form is not read.` with

```powershell
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: pass exactly one explicit --base <branch>; -B, -R, --repo, a single-dash shorthand cluster containing B or R, and an inline GH_REPO= prefix are not accepted.' }
```

**H10 - NUL guard.** Replace the line `    $violation = Get-PrAuthorDocsOnlyPathViolation -Path @(ConvertFrom-PrAuthorDocsOnlyNameList -Text ([string]$diff.Output))` with

```powershell
    $diffText = [string]$diff.Output
    if ($diffText.Length -gt 0 -and -not $diffText.EndsWith([char]0)) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base did not return NUL-terminated output." }
    }

    $violation = Get-PrAuthorDocsOnlyPathViolation -Path @(ConvertFrom-PrAuthorDocsOnlyNameList -Text $diffText)
```

Net line change: H1 +3, H2 +1, H3 +3, H4 +3, H5 +1, H6 0, H7 +1, H8 +3, H9 0, H10 +5 (the replaced line becomes six lines); total +20, so the post-edit file is 285 lines. The four AC-9 statements move from lines 64, 65, 68, and 70 to 75, 76, 79, and 81 (H1, H2, H3, H4, and H5 precede them: +11).

## 8. Appendix M — replacement `Docs-only` block of `.claude/hooks/enforce-pr-author-skill.ps1`

Replace the sixteen lines from `      Docs-only - issue #901: when the preflight fails, gh pr create proceeds to receipt` through `                  The exemption never applies under epic scope.` (current lines 26-41) with these twenty lines (net +4, total 359):

```text
      Docs-only - issue #901: when the preflight fails, gh pr create proceeds to receipt
                  verification only when every condition holds: no checkpoint file exists
                  beneath the resolved worktree; the command carries exactly one explicit
                  --base <branch> and no base or repository override (issue #927: no
                  single-dash token whose letters include B or R, such as -B, -R, or -dB; no
                  --repo or --repo= token; no inline GH_REPO= prefix); refs/remotes/origin/<branch>
                  resolves to a commit; git diff --name-only -z --no-renames <commit>...HEAD
                  exits 0, ends its non-empty output with NUL, and lists at least one path; and
                  every listed path starts with docs/ (ordinal, case-sensitive). Otherwise the
                  deny keeps ORCHESTRATOR_STATE_PREFLIGHT_FAILED and appends one sub-code:
                    DOCS_ONLY_EXEMPTION_NOT_CREATE         - gh pr edit is never exempt.
                    DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT - a checkpoint file exists.
                    DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - no single explicit --base, a base or
                                                             repository override is present, or
                                                             the base does not resolve on origin.
                    DOCS_ONLY_EXEMPTION_DIFF_FAILED        - the diff exits non-zero, throws, or
                                                             returns output not ending with NUL.
                    DOCS_ONLY_EXEMPTION_EMPTY_DIFF         - the diff lists no path.
                    DOCS_ONLY_EXEMPTION_NON_DOCS_PATH      - a listed path is outside docs/.
                  The exemption never applies under epic scope.
```

## 9. WRITES

Every repository file this plan creates, edits, or deletes outside `FEATURE`. Nothing is created or deleted outside `FEATURE`; every entry below is an edit.

Production hook files (Edit):

1. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` ([P2-T1] to [P2-T6])
2. `.claude/hooks/enforce-pr-author-skill.ps1` ([P2-T7], header comment only)

Bundled mirrors (`cp` only, rule 9):

3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` ([P2-T8])
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` ([P2-T9])

Test suites (Edit, insertion only):

5. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` ([P1-T1], [P1-T2])
6. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` ([P1-T3])
7. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` ([P1-T4])

#901 record (Edit, no rename):

8. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` ([P3-T18])
9. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` ([P3-T3])
10. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` ([P3-T4])
11. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` ([P3-T5])
12. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` ([P3-T6], [P3-T16], [P3-T17])
13. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` ([P3-T7])
14. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` ([P3-T8])
15. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` ([P3-T9])
16. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` ([P3-T10])
17. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` ([P3-T11])
18. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` ([P3-T12])
19. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` ([P3-T13])
20. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` ([P3-T14])
21. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` ([P3-T15])

Inside `FEATURE` (not counted above): this plan file (checkbox state only), `spec.md` (AC checkboxes only), and the evidence artifacts each task names.

Outside the repository: `SCRATCH/927/tools/read_coverage_927.py`, `SCRATCH/927/ci-base/`, `SCRATCH/927/ci-head/` (never committed, never deleted).

Never written: `.claude/hooks/enforce-pr-author-skill-helpers.ps1` and its mirror; `.claude/hooks/hook-command-invocation*.ps1` and their mirrors; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; anything under `.codex/`, `.claude/rules/`, `.github/`; `F901/evidence/qa-gates/p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md`; every `F901/evidence/remediation-baseline/` file; the #927 `issue.md` and research artifact.

## 10. Appendix T — test text

Every row follows Arrange-Act-Assert. No row starts a process, runs git, or writes a file.

**T1** — insert into `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, inside `Context 'Get-PrAuthorDocsOnlyBaseName'`, directly before the line `        It 'returns null for gh pr edit' {`:

```powershell
        It 'denies the base or repository override <Name>' -ForEach @(
            @{ Name = 'B cluster -dB'; Command = 'gh pr create --base main -dB other --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B attached -Bother'; Command = 'gh pr create --base main -Bother --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B equals -B=main'; Command = 'gh pr create -B=main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R separate -R'; Command = 'gh pr create --base main -R o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R attached -Ro/r'; Command = 'gh pr create --base main -Ro/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R cluster -dR'; Command = 'gh pr create --base main -dR o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'long --repo'; Command = 'gh pr create --base main --repo o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'long --repo='; Command = 'gh pr create --base main --repo=o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'global -R before pr create'; Command = 'gh -R o/r pr create --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'global --repo before pr create'; Command = 'gh --repo o/r pr create --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'inline GH_REPO prefix'; Command = 'GH_REPO=o/r gh pr create --base main --body-file artifacts/pr_body_1.md' }
        ) {
            # Arrange: the row supplies a command that retargets the base or the repository.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeNullOrEmpty -Because "$Name retargets gh away from the diffed base"
        }

        It 'still resolves main for <Name>' -ForEach @(
            @{ Name = 'boolean -d'; Command = 'gh pr create -d --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'head shorthand -H'; Command = 'gh pr create --base main -H feature/x --body-file artifacts/pr_body_1.md' }
            @{ Name = 'title shorthand -t'; Command = 'gh pr create --base main -t Docs --body-file artifacts/pr_body_1.md' }
            @{ Name = 'pr-author long-flag shape'; Command = 'gh pr create --title "docs: x" --body-file artifacts/pr_body_927.md --head bug/x --base main' }
        ) {
            # Arrange: the row supplies a command whose single-dash tokens carry neither B nor R.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeExactly 'main' -Because "$Name does not retarget the base or the repository"
        }

```

**T2** — insert into `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`. Apply with Edit using as `old_string` the five final lines of the file (`            $result.ExitCode | Should -Be -1`, `            $result.Output | Should -BeExactly ''`, `        }`, `    }`, `}`) and as `new_string` those same five lines with the block below inserted between the fourth line (`    }`, closing the existing `Context 'Invoke-PrAuthorDocsOnlyGitExe'`) and the fifth line (`}`, closing the `Describe`):

```powershell

    Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)' {
        BeforeAll {
            # Test-local stand-ins for the git executable, passed by name to the seam's
            # GitCommand parameter, so the seam body runs without starting a process.
            function Invoke-DocsOnlyFakeGitEcho {
                $global:LASTEXITCODE = 0
                ($args -join '|') + "`0"
            }
            function Invoke-DocsOnlyFakeGitMultiLine {
                $global:LASTEXITCODE = 0
                'docs/a.md'
                'docs/b.md'
            }
            function Invoke-DocsOnlyFakeGitExit128 {
                $global:LASTEXITCODE = 128
            }
            function Invoke-DocsOnlyFakeGitThrow {
                throw 'simulated git start failure'
            }
        }

        BeforeEach {
            $global:LASTEXITCODE = 0
        }

        AfterEach {
            $global:LASTEXITCODE = 0
        }

        It 'returns exit code 0 and NUL-terminated output with -C, the root, and the arguments in order' {
            # Arrange
            $gitArgs = @('diff', '--name-only', '-z')
            $expected = '-C|' + $PSScriptRoot + '|diff|--name-only|-z' + "`0"

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitCommand 'Invoke-DocsOnlyFakeGitEcho'

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly $expected -Because 'the seam passes -C, the root, then the arguments'
            $result.Output.EndsWith([char]0) | Should -BeTrue -Because 'NUL-terminated output is preserved'
        }

        It 'joins multi-line output with a line feed' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitCommand 'Invoke-DocsOnlyFakeGitMultiLine'

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly "docs/a.md`ndocs/b.md"
        }

        It 'returns the non-zero exit code of the injected command' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitCommand 'Invoke-DocsOnlyFakeGitExit128'

            # Assert
            $result.ExitCode | Should -Be 128
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object when the injected command throws' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitCommand 'Invoke-DocsOnlyFakeGitThrow'

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }
    }
```

**T3** — insert into `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`. Apply with Edit using as `old_string` the four final lines of the file (the line beginning `            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'rev-parse'`, then `        }`, `    }`, `}`) and as `new_string` those lines with the block below inserted after the second line (`        }`, closing the last `It`):

```powershell

        It 'denies diff output that is not NUL-terminated (issue #927)' {
            # Arrange: the diff exits 0 but its output lacks the trailing NUL.
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'docs/a.md' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result.Reason | Should -Match 'NUL'
        }

        It 'denies a -R repository override before any git call (issue #927)' {
            # Arrange
            $command = 'gh pr create --base main -R o/r --title "Docs" --body-file artifacts/pr_body_1.md'

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $command

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a -dB shorthand cluster before any git call (issue #927)' {
            # Arrange
            $command = 'gh pr create --base main -dB other --title "Docs" --body-file artifacts/pr_body_1.md'

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $command

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'names every rejected override form in the E3 reason (issue #927)' {
            # Arrange: the create command carries no --base.

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:CreateWithoutBase

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            foreach ($form in @('--base <branch>', '-B,', '-R,', '--repo,', 'shorthand cluster containing B or R', 'GH_REPO=')) {
                $result.Reason.Contains($form) | Should -BeTrue -Because "the reason names $form"
            }
        }
```

**T4** — insert into `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`. Apply with Edit using as `old_string` the four final lines of the file (`            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED'`, `        }`, `    }`, `}`) and as `new_string` those lines with the block below inserted after the second line:

```powershell

        It 'denies a --repo override before the diff (issue #927)' {
            # Arrange
            $payload = ConvertTo-DocsOnlyPayload -Command 'gh pr create --title "Docs" --body-file artifacts/pr_body_1.md --repo o/r --base main'

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }
```

## 11. Appendix R — JUnit row tokens (J7, J9)

Each token is the tail of a JUnit `testcase name` value. `expect-fail` marks the 18 rows of decision D5.

| ID | Suite | Token | expect-fail |
|---|---|---|---|
| R1 | DocsOnly | `override B cluster -dB` | yes |
| R2 | DocsOnly | `override B attached -Bother` | no |
| R3 | DocsOnly | `override B equals -B=main` | no |
| R4 | DocsOnly | `override R separate -R` | yes |
| R5 | DocsOnly | `override R attached -Ro/r` | yes |
| R6 | DocsOnly | `override R cluster -dR` | yes |
| R7 | DocsOnly | `override long --repo` | yes |
| R8 | DocsOnly | `override long --repo=` | yes |
| R9 | DocsOnly | `override global -R before pr create` | yes |
| R10 | DocsOnly | `override global --repo before pr create` | yes |
| R11 | DocsOnly | `override inline GH_REPO prefix` | yes |
| A1 | DocsOnly | `still resolves main for boolean -d` | no |
| A2 | DocsOnly | `still resolves main for head shorthand -H` | no |
| A3 | DocsOnly | `still resolves main for title shorthand -t` | no |
| A4 | DocsOnly | `still resolves main for pr-author long-flag shape` | no |
| S1 | DocsOnly | `returns exit code 0 and NUL-terminated output with -C, the root, and the arguments in order` | yes |
| S2 | DocsOnly | `joins multi-line output with a line feed` | yes |
| S3 | DocsOnly | `returns the non-zero exit code of the injected command` | yes |
| S4 | DocsOnly | `returns the failure object when the injected command throws` | yes |
| X1 | Exemption | `denies diff output that is not NUL-terminated (issue #927)` | yes |
| X2 | Exemption | `denies a -R repository override before any git call (issue #927)` | yes |
| X3 | Exemption | `denies a -dB shorthand cluster before any git call (issue #927)` | yes |
| X4 | Exemption | `names every rejected override form in the E3 reason (issue #927)` | yes |
| D1 | Decision | `denies a --repo override before the diff (issue #927)` | yes |
| E1 | DocsOnly | `rejects the -B short form` | no (pre-existing, AC-1) |
| E2 | Exemption | `denies an empty diff` | no (pre-existing, AC-6) |
| E3 | Exemption | `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` | no (pre-existing, AC-10) |

Because J7 and J9 append `" status="` to the token, `override long --repo` (R7) and `override long --repo=` (R8) match distinct rows.

## 12. Appendix P — #901 evidence corrections

Each `EDIT` row replaces the file's first `Timestamp:` line (the `Line` column) with the five lines below, with `<HI>`, `<ORIGINAL>`, `<LO>`, and `<DERIVATION>` taken from the row and from `pa-n3-bounds` ([P3-T2]); nothing else in the file changes except where [P3-T16] and [P3-T17] apply:

```text
Timestamp: <HI>
TIMESTAMP_RECONSTRUCTED: true
TIMESTAMP_ORIGINAL: <ORIGINAL>
TIMESTAMP_BOUNDS_UTC: <LO> .. <HI>
TIMESTAMP_DERIVATION: <DERIVATION>
```

Epoch conversions (verified arithmetic: 2026-10-13T00:00:00Z is epoch 1791849600): `1791888677` is 2026-10-13T10:51:17Z (`XML_MTIME_AFTER_EPOCH` in `p1-xml-regenerated`, `XML_MTIME_MCP_RUN_EPOCH` in `remediation-baseline/p1-direct-run-before`); `1791890071` is 2026-10-13T11:14:31Z (`XML_MTIME_AFTER_EPOCH` in `p1-direct-xml-regenerated`); `1791890931` is 2026-10-13T11:28:51Z (`XML_MTIME_AFTER_EPOCH` in `p1-direct-xml-regenerated-rerun`). `C1` is the confirmed UTC minute of `ff1b7cbd4` (cited `2026-10-13T11-17`); `C2` is that of `70e58ca84` (cited `2026-10-13T11-34`).

| Row | File (under `F901/evidence/qa-gates/`) | Line | ORIGINAL | LO | HI | Commit | DERIVATION |
|---|---|---|---|---|---|---|---|
| P1 | `p1-pester-junit.2026-10-12T19-50.md` | 1 | `2026-10-13T00-00` | `2026-10-13T10-51` | C1 | ff1b7cbd4 | `lower: MCP-run coverage XML mtime epoch 1791888677 (2026-10-13T10:51:17Z); upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P2 | `p1-poshqc-test-invocation.2026-10-12T19-50.md` | 1 | `2026-10-13T00-00` | `UNRECORDED` | `2026-10-13T10-51` | none | `upper: MCP-run coverage XML mtime epoch 1791888677 (2026-10-13T10:51:17Z); lower: no source records the call start` |
| P3 | `p1-xml-regenerated.2026-10-12T19-50.md` | 1 | `2026-10-13T00-00` | `2026-10-13T10-51` | C1 | ff1b7cbd4 | `lower: XML_MTIME_AFTER_EPOCH 1791888677 (2026-10-13T10:51:17Z) recorded in this file; upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P4 | `p1-poshqc-direct-run.2026-10-12T19-50.md` | 3 | `2026-10-13T11-30` | `2026-10-13T10-51` | `2026-10-13T11-14` | none | `lower: MCP-run coverage XML mtime epoch 1791888677 (2026-10-13T10:51:17Z); upper: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z) recorded in p1-direct-xml-regenerated.2026-10-12T19-50.md` |
| P5 | `p1-direct-xml-regenerated.2026-10-12T19-50.md` | 3 | `2026-10-13T11-32` | `2026-10-13T11-14` | C1 | ff1b7cbd4 | `lower: XML_MTIME_AFTER_EPOCH 1791890071 (2026-10-13T11:14:31Z) recorded in this file; upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P6 | `p1-pester-junit-direct.2026-10-12T19-50.md` | 3 | `2026-10-13T11-34` | `2026-10-13T11-14` | C1 | ff1b7cbd4 | `lower: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z); upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P7 | `local-powershell-coverage-direct.2026-10-12T19-50.md` | 3 | `2026-10-13T11-36` | `2026-10-13T11-14` | C1 | ff1b7cbd4 | `lower: COVERAGE_XML_MTIME_EPOCH 1791890071 (2026-10-13T11:14:31Z) recorded in this file; upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P8 | `p2-ac-state.2026-10-12T19-50.md` | 3 | `2026-10-13T11-38` | `UNRECORDED` | C1 | ff1b7cbd4 | `upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence; lower: no source records it` |
| P9 | `p2-scope-before-stage.2026-10-12T19-50.md` | 3 | `2026-10-13T11-39` | `UNRECORDED` | C1 | ff1b7cbd4 | `upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence; lower: no source records it` |
| P10 | `p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` | 3 | `2026-10-13T11-32` | `2026-10-13T11-14` | `2026-10-13T11-28` | none | `lower: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z); upper: re-run XML mtime epoch 1791890931 (2026-10-13T11:28:51Z) recorded in p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` |
| P11 | `p1-pester-junit-direct-rerun.2026-10-12T19-50.md` | 3 | `2026-10-13T11-36` | `2026-10-13T11-28` | C2 | 70e58ca84 | `lower: re-run XML mtime epoch 1791890931 (2026-10-13T11:28:51Z); upper: committer time of 70e58ca84 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P12 | `local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` | 3 | `2026-10-13T11-37` | `2026-10-13T11-28` | C2 | 70e58ca84 | `lower: COVERAGE_XML_MTIME_EPOCH 1791890931 (2026-10-13T11:28:51Z) recorded in this file; upper: committer time of 70e58ca84 confirmed in the #927 pa-n3-commit-confirmation evidence` |
| P13 | `local-powershell-coverage.2026-10-12T19-50.md` | 1 | `2026-10-13T06-55` | `2026-10-13T10-51` | C1 | ff1b7cbd4 | `lower: MCP-run coverage XML mtime epoch 1791888677 (2026-10-13T10:51:17Z); upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence; the original value matches America/New_York local time, not UTC` |

`p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` (original `2026-10-13T11-34`) is not edited: its value is not contradicted at minute resolution.

**P4b** — replacement `Output Summary:` line for `p1-poshqc-direct-run.2026-10-12T19-50.md` ([P3-T17]):

```text
Output Summary: The run used the CI form from .github/workflows/_poshqc.yml lines 41-42. The process exit code of this run was not observed because the executing agent exited before the run completed; the observed exit code of the re-run is recorded in p1-poshqc-direct-run-rerun.2026-10-12T19-50.md. No figure was taken from console output.
```

**P-N2** — replacement lines under `## Evidence Checklist` in `F901/issue.md` ([P3-T18]):

```text
- [x] baseline (evidence/baseline/)
- [x] targeted verification (evidence/qa-gates/ and evidence/regression-testing/)
- [x] end-state (evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md and the PR #924 merge at e467c693)
```

## 13. Appendix S — `SCRATCH/927/tools/read_coverage_927.py`

```python
"""Issue 927 scratch helper: read JaCoCo LINE counters and per-line hits from a PoshQC coverage XML."""

import sys
import xml.etree.ElementTree as ET


def find_hook_classes(root, name):
    """Return (package, class) pairs for NAME under the canonical .claude/hooks package."""
    matches = []
    for package in root.iter("package"):
        package_name = package.get("name", "").replace("\\", "/")
        if not package_name.endswith(".claude/hooks") or "claude-customizations" in package_name:
            continue
        for cls in package.findall("class"):
            if cls.get("sourcefilename") == name:
                matches.append((package, cls))
    return matches


def main(argv):
    """Print COVERAGE_RESULT and LINE_RESULT lines; return 0 when every file is found once."""
    if len(argv) < 3:
        print("USAGE: read_coverage_927.py XML NAME[:LINE,LINE...] [NAME...]")
        return 2
    root = ET.parse(argv[1]).getroot()
    status = 0
    for spec in argv[2:]:
        name, _, line_text = spec.partition(":")
        matches = find_hook_classes(root, name)
        if len(matches) != 1:
            print(f"COVERAGE_RESULT: .claude/hooks/{name} CLASS_COUNT={len(matches)}")
            status = 1
            continue
        package, cls = matches[0]
        counters = [c for c in cls.findall("counter") if c.get("type") == "LINE"]
        if len(counters) != 1:
            print(f"COVERAGE_RESULT: .claude/hooks/{name} LINE_COUNTER_COUNT={len(counters)}")
            status = 1
            continue
        covered = int(counters[0].get("covered"))
        missed = int(counters[0].get("missed"))
        total = covered + missed
        pct = round(100.0 * covered / total, 2) if total else 0.0
        verdict = "PASS" if total and 100 * covered >= 85 * total else "FAIL"
        print(f"COVERAGE_RESULT: .claude/hooks/{name} covered={covered} missed={missed} line_pct={pct} threshold=85.00 result={verdict}")
        if not line_text:
            continue
        sources = [s for s in package.findall("sourcefile") if s.get("name") == name]
        lines = {}
        if len(sources) == 1:
            lines = {line.get("nr"): line for line in sources[0].findall("line")}
        for number in [n for n in line_text.split(",") if n]:
            line = lines.get(number)
            if line is None:
                print(f"LINE_RESULT: .claude/hooks/{name} nr={number} NOT_EXECUTABLE_OR_ABSENT")
            else:
                print(f"LINE_RESULT: .claude/hooks/{name} nr={number} ci={line.get('ci')} mi={line.get('mi')}")
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

## 14. Quoted literals created by this plan

The following tokens do not exist in the tree before this plan runs; the tasks above create them verbatim: `TIMESTAMP_RECONSTRUCTED: true`, `TIMESTAMP_ORIGINAL: 2026-10-13T00-00`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T10-51`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-14`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-28`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34`, `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`, `The process exit code of this run was not observed`, `- [x] baseline (evidence/baseline/)`, `[ValidateNotNullOrEmpty()][string] $GitCommand`, `.PARAMETER GitCommand`, `& $GitCommand -C $WorktreeRoot @GitArgs`, `shorthand cluster containing B or R, and an inline GH_REPO= prefix are not accepted`, `did not return NUL-terminated output`, `EndsWith([char]0)`, `ConvertFrom-PrAuthorDocsOnlyNameList -Text $diffText`, `no inline GH_REPO= prefix.`, `and non-empty output ends with NUL.`, `Residual limit:`, `token has B or R among its letters`, `no inline GH_REPO= prefix);`, `single-dash token whose letters include B or R`, `repository override is present, or`, `returns output not ending with NUL.`, `Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)'`, `It 'denies a --repo override before the diff (issue #927)'`.
