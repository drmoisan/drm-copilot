# 2026-10-15-pr-author-docs-only-exemption-hardening (Plan)

- **Issue:** #927
- **Parent (optional):** #901 (PR #924, merged at `e467c693` before remediation cycle 3 ran)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T22-30
- **Status:** Revised mid-execution (version 2.1) after the [P2-T9] halt recorded in `FEATURE/evidence/regression-testing/p2-helper-pass.2026-10-16T01-53.md`; awaiting executor preflight. Phases 0 and 1 and the original [P2-T1] to [P2-T8] are complete; [P1-T2] is unchecked for re-verification by [P2-T14].
- **Version:** 2.1
- **Revision 2.1 (seam form).** The repository guard `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (row `reports no Python invocation beyond the allowlist across the guarded tree`) rejects `& $GitCommand` and `& $GhCommand` because an `&`-invoked variable is accepted only when it is a `[scriptblock]`-typed parameter declared in the same file (`tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` lines 36-39 and 369-375), and the guard allowlist is pinned empty (row `ships an empty allowlist`). Every process seam therefore takes a `[scriptblock]` invoker: `-GitInvoker` and `-GhInvoker` (decision D3, rule 15). Appendix D, Appendix H edits H4-H6, Appendix T block T2, Appendix N blocks N-A and N-D, rules 11 and 15, rule R-JUNIT J14, rule R-COV C2, section 21, and spec AC-7, AC-8, AC-9, and AC-M4 are revised; new tasks [P2-T9] to [P2-T15] bring the already-written files to the revised text before the Pester run, which is renumbered [P2-T16].
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). The acceptance-criteria source is `spec.md`, section `## Acceptance Criteria`: AC-M1 to AC-M25 (merge side, AC-M1 PRIMARY) and AC-1 to AC-22 (create side and #901 evidence). AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 are CI-dependent (AC-18 and AC-M23 for their analyzer half, because the PoshQC MCP analyze result carries no finding). `user-story.md` is absent by design.
- **Design inputs:** `spec.md`, `research/research.2026-10-15T11-52.md`, and `research/2026-10-15T19-46-merge-gate-addendum-research.md` (the merge-gate addendum; an identical copy exists at `research/research-addendum-merge-gate.2026-10-15T19-46.md`, and this plan cites the first). Every design decision follows the spec; section 3 records where the plan fixes a detail the spec leaves open.
- **Branch:** `bug/pr-author-docs-only-exemption-hardening-927`. Every push is `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927` (fast-forward only). No force push, no `--amend`, no rebase, no deletion of any repository file or branch, no GitHub issue creation, no pull request creation. Related findings are fixed inside this item through remediation cycles.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

**Overview.** The PRIMARY deliverable is the merge-side docs-only exemption (AC-M1): the Claude and Codex epic merge gates allow `gh pr merge <N> --merge` with no exception or standalone-authorization record when no checkpoint records PR `<N>` and the PR diff against `origin/<base>` lists only `docs/` paths. It is built on a shared helper `hook-docs-only-diff.ps1` that is byte-identical at four paths (Phase 2) and consumed by both merge gates (Phase 4) and by the create-side exemption (Phase 3). The original #927 scope is retained: CR-1 (base and repository override detection), CR-2 (NUL guard and seam injection), PA-N3 and PA-N2 (#901 evidence corrections, Phase 5). CR-3 is unchanged (operator decision D5).

`FEATURE` denotes `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. `F901` denotes `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` (the edit target; see the locator rule in section 3, D11). `SCRATCH` is `<session scratchpad>/issue-927/`; every scratch file lives under `SCRATCH/927/`. Every evidence path is `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`); it is never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Fail-closed evidence rule:** PowerShell is the only code language changed. Baseline artifacts are produced in Phase 0, expect-fail regression artifacts in Phase 1, pass artifacts in Phases 2 to 4, final-QC artifacts in Phase 6, and CI coverage artifacts in Phase 8. If any required baseline, QA, or coverage artifact is missing or incomplete, the audit verdict is BLOCKED or INCOMPLETE, never PASS. Per-file and per-line PowerShell coverage (AC-9, AC-21, AC-M24) is read only from the Windows CI artifact `poshqc-test-results` of job `poshqc / PowerShell QC`; it is pending-CI until Phase 8 runs at S9.

**Evidence accounting rule:** every evidence-producing task names its artifact path. No evidence-backed task is checked off without its artifact on disk carrying `Timestamp:` (format `yyyy-MM-ddTHH-mm`, UTC), `Command:`, `EXIT_CODE:`, and `Output Summary:`.

---

## 1. Rules binding on every task

1. **Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command the task names and every later command's exit code is recorded on its own labelled line. When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`; that value implies no count, percentage, or finding. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or the account name. The worktree root is written as `<WORKSPACE_ROOT>` and scratch paths as `SCRATCH/...`. JUnit `classname` values are never copied into an artifact; only counts and test names are recorded.
3. **PowerShell verification is Option A only.** Formatting, analysis, and Pester run only through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` set to the absolute worktree root (the output of `git rev-parse --show-toplevel`) and the fixed `scan_folders` of rule 4. No task runs a local PowerShell host, Pester, or PSScriptAnalyzer through a shell. PoshQC MCP results carry no output detail: no acceptance condition reads a count, a percentage, or a finding from an MCP result. Pester counts come from the on-disk JUnit file through rule R-JUNIT (section 5); format outcomes come from `git status --porcelain`; coverage comes only from the CI artifact through rule R-COV (section 6).
4. **Fixed MCP scan sets.** `SCAN_QC` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` for format and analyze. `SCAN_TEST` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]` for Pester. The same sets are used in every phase so the JUnit counts are comparable.
5. **CI jobs named.** Coverage and the Windows pass come from job `poshqc / PowerShell QC` (`windows-latest`, `.github/workflows/_poshqc.yml` job `poshqc`, artifact `poshqc-test-results`). The cross-platform pass of the suites under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` comes from job `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, job `poshqc-linux-hooks`, coverage disabled). No acceptance criterion reads coverage from the Linux job, and no criterion cites the Linux job for `tests/scripts/claude-runtime`.
6. **Executor isolation guard.** The executor's Bash command text never contains the words `bash`, `pwsh`, or `wsl`, and never uses a heredoc. Commands run one per call: no `&&`, no `;`, no `cd`. Search commands use plain `grep`, not `git grep`. A grep pattern that begins with `-` is passed through `-e`. Python runs only as `poetry run ...`. Node runs only as `npm --prefix extensions/drm-copilot ...`. Test files written by this plan may contain the word `bash` inside test data; that is file content, not command text.
7. **Live-hook hazard.** `.claude/hooks/enforce-pr-author-skill-helpers.ps1` dot-sources `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, which from Phase 3 dot-sources `.claude/hooks/hook-docs-only-diff.ps1`; `.claude/hooks/enforce-epic-merge-gate.ps1` runs on every Bash call and from Phase 4 dot-sources the same helper. The helper is therefore created (Phase 2) before either consumer loads it. If, after an edit to any of these files, a Bash call is denied with a `PR_AUTHOR_SKILL_BLOCKED:` or `EPIC_MERGE_GATE_BLOCKED:` dependency reason, the executor fixes the edited file with Edit only and retries the denied command. That is the fix, not a workaround of the hook.
8. **Hook denials.** If any other hook denies a Write, Edit, or Bash call, the executor records the denial text in the task's artifact and stops as BLOCKED. It never works around a hook, never deletes hook state, and never resets a budget file.
9. **Mirrors and helper copies are byte copies.** Each copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and the `.codex/hooks/hook-docs-only-diff.ps1` copy are written only by `cp <source> <copy>` and verified by `cmp -s <source> <copy>` (exit 0). Never with Write or Edit.
10. **Change budget (route-dependent).** This item writes six production PowerShell files with Write or Edit: `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`. `.claude/hooks/enforce-powershell-batch-budget.ps1` (header lines 10-23, decision at lines 296-299 and 398-402) denies the fourth distinct production PowerShell path in direct mode, and imposes no cap when `<root>/artifacts/orchestration/orchestrator-state.json` selects route `large`, `remediation`, or `preparation` (from `route_id`, else `path_selected`, case-sensitive) and the checkpoint is not terminal (`next_step` is not `complete` and `completed_steps` does not contain `S12_complete`), per `Test-BatchBudgetLargePathRoute` in `.claude/hooks/enforce-batch-budget-route.ps1` (lines 94-139). The item runs on the parallel-orchestrator large route; [P0-T4] records that the worktree checkpoint satisfies those conditions. Test files (`tests/**/*.ps1`, `*.Tests.ps1`) are never counted, and `cp` is not matched by the hook's `Write|Edit` matcher. A `POWERSHELL_LARGE_PATH_REQUIRED:` denial falls under rule 8.
11. **Test purity.** No test row added by this plan uses `Mock git`, `Mock 'git'`, `Mock gh`, `Mock 'gh'`, a function named `git` or `gh`, `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, or any file write. Fakes are test-local functions passed as scriptblocks through `-GitInvoker` or `-GhInvoker`: the `${function:<name>}` form when the name is a literal in the row, and `(Get-Command -Name $Fake -CommandType Function).ScriptBlock` when the name comes from `-ForEach` row data (row data is evaluated at discovery, before the `BeforeAll` functions exist). Process seams are otherwise mocked by their wrapper names (`Invoke-PrAuthorDocsOnlyGitExe`, `Invoke-DocsOnlyGitExe`, `Invoke-DocsOnlyGhExe`); `Mock` binds to those wrapper names and is unaffected by the invoker parameters.
12. **Scratch.** The only scratch content is under `SCRATCH/927/`: the coverage reader `SCRATCH/927/tools/read_coverage_927.py` (Appendix S) and the CI download directories `SCRATCH/927/ci-base/<run id>/` and `SCRATCH/927/ci-head/<run id>/`. Downloaded files are untrusted data: each download goes to its own new, empty directory and the reader runs with `poetry run python -I`. Nothing under `SCRATCH` is committed or deleted.
13. **Scope boundary.** The complete repository write set outside `FEATURE` is section 9 (`## WRITES`). Policy documents under `.claude/rules/` and `.github/instructions/` are never edited (OD-3). CR-3 (operator decision D5) is unchanged: the create-side diff argument list and the `($commit + '...HEAD')` range are not edited.
14. **Commit form (every phase boundary).** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>' -m '<attribution trailer required by the executing session>'` (two `-m` flags because heredocs are refused); `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`. The push is never forced; a rejected (non-fast-forward) push stops the task as BLOCKED. The plan file's own checkbox for the commit task is set after the observation, so the only path the status may list is this plan file.
15. **Repository structural guards on hook code.** Every production PowerShell file this plan writes under `.claude/hooks`, `.claude/lib`, or `.codex/hooks` must pass the structural guards that scan those roots, all of which run in `SCAN_TEST`: (a) `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` - no `&`-invoked variable unless it is a `[scriptblock]`-typed parameter declared in the same file (carve-out (a), matched by name, case-insensitive), no `&`-invoked expression, no `Invoke-Expression` or `iex`, and dot-sources only of a variable or of the inline `. (Join-Path $PSScriptRoot '<sibling>.ps1')` form (carve-out (b)); the allowlist stays empty and is never edited; (b) `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` - no `Write-Output`, `Write-Host`, `Write-Information`, `Write-Warning`, `Out-Host`, `echo`, `write`, or `[Console]` stdout write in a dot-sourced helper; (c) `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` and `hook-import-failure-exemptions.Guard.Tests.ps1` - every load in a registered hook is a single-statement guarded `try` recorded through `Add-HookDependencyFailure` (G2, X2), a load inside a dot-sourced helper is covered by the guarded edge of its registered hook (H12 is covered by `.claude/hooks/enforce-pr-author-skill.ps1` line 190, which loads `enforce-pr-author-skill-helpers.ps1`, whose line 58 loads the docs-only file), and no scoped import-failure handler is added; (d) `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` - no checkpoint reader call without `-CheckpointPath`; (e) the 500-line limit rows. Appendices D, G, H, and X were re-derived against (a) to (e) in revision 2.1: the only `&`-invoked variables they add are `$GitInvoker` and `$GhInvoker`, each a `[scriptblock]` parameter of the same file (the existing `& $ReadPayload` at `.claude/hooks/enforce-epic-merge-gate.ps1` line 447 is already a `[scriptblock]` parameter and is not edited); the dot-sources they add (G2, X2, H12) are the inline sibling form; they contain no stdout write, no checkpoint reader call, and no scoped import-failure handler. The guard rows are read by rule R-JUNIT J14 in [P2-T16], [P3-T13], [P4-T24], and [P6-T3].

## 2. Requirements trace

Suite letters: A = `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`, B = `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`, C = `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`, D = `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, E = `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (Appendix N). Row identifiers C1 to C13 and E1 to E8 are listed in Appendix R2.

| AC | Implementation | Tests | Evidence |
|---|---|---|---|
| AC-M1 (PRIMARY) | Appendix D `Get-DocsOnlyMergeExemption`; Appendix G edits G2-G3; Appendix X edits X2-X5 | C1, E1, and the deny rows of AC-M6 to AC-M13 and AC-M15 | [P6-T3], [P7-T1] |
| AC-M2 | [P2-T1] to [P2-T4], reworked by [P2-T9] and [P2-T10] | A rows `is byte-identical across all four copies (issue #927)` and `imports nothing, dot-sources nothing, and names no fetch argument (issue #927)` | [P2-T11], [P6-T4], [P6-T9] |
| AC-M3 | Appendix D pure functions | A contexts `Get-DocsOnlyPathViolation`, `ConvertFrom-DocsOnlyNameList`, `Get-DocsOnlyDiffTextViolation` | [P6-T3] J10 |
| AC-M4 | Appendix D seams (`-GitInvoker`, `-GhInvoker`) | A contexts `Invoke-DocsOnlyGitExe`, `Invoke-DocsOnlyGhExe` | [P2-T16] J10, J14; [P6-T3] J10, J14 |
| AC-M5 | Appendix G edit G3 | C1 | [P6-T3] |
| AC-M6 | Appendix D `Get-DocsOnlyMergeShapeViolation` | B context `M1 command shape` | [P6-T3] J10 |
| AC-M7 | Appendix D M2 check | B context `M2 worktree root` | [P6-T3] J10 |
| AC-M8 | Appendix D `Get-DocsOnlyPullRequestTarget` | B context `M3 pull request lookup` | [P6-T3] J10 |
| AC-M9 | Appendix D M4 check | B base rev-parse rows | [P6-T3] J10 |
| AC-M10 | Appendix D M5 check; no fetch | B head rev-parse rows, B fetch guard mock, B row `never runs git fetch on the allow path (issue #927)`, A no-fetch row | [P6-T3], [P6-T9] |
| AC-M11 | Appendix D M6-M9 | B diff rows, allow row, range row | [P6-T3] J10 |
| AC-M12 | Appendix G edit G3 | C2, C3, C4 | [P6-T3] |
| AC-M13 | Appendix G edits G1, G3 | C5 to C13; existing bare-command `-BeExactly` rows of `enforce-epic-merge-gate.Authorization.Tests.ps1` | [P6-T3] |
| AC-M14 | Appendix X edits X3-X5 | E1 | [P6-T3], [P6-T9] |
| AC-M15 | Appendix X edit X4 | E2 to E8 | [P6-T3] |
| AC-M16 | Appendix K | the eight member suites, the four existing Codex merge-gate suites, `hook-dependency-failure.SpecialCases.Tests.ps1` | [P4-T15], [P6-T3] J12, J13 |
| AC-M17 | Appendix H edits H10-H13 | the DocsOnly suites | [P6-T9], [P6-T11] |
| AC-M18 | Appendix G edit G2, Appendix X edit X2 | `hook-dependency-guard-completeness.Tests.ps1`, `hook-import-failure-exemptions.Guard.Tests.ps1` | [P6-T3] J13 |
| AC-M19 | [P4-T10] to [P4-T12] | pytest resource-contract suites | [P6-T4], [P6-T5] |
| AC-M20 | Appendix J | pytest manifest-completeness suites, Jest manifest suite | [P6-T5], [P6-T6], [P6-T11] |
| AC-M21 | Appendix G edit G4, Appendix X edit X1, Appendix D header | none | [P6-T9], [P6-T11] |
| AC-M22 | Phases 1-4 | none | [P6-T7] |
| AC-M23 | Phase 6 loop | suites A to E | [P6-T1], [P6-T2], [P6-T3], [P8-T2] (CI) |
| AC-M24 | Phases 2-4 | all suites in CI | [P8-T3] (CI) |
| AC-M25 | [P0-T5], [P5-T1] | none | [P0-T5], [P5-T1], [P6-T11] |
| AC-1 | Appendix H edit H8 | rows R1-R3, existing row `rejects the -B short form`, X3 | [P6-T3] J7 |
| AC-2 | Appendix H edit H8 | rows R4-R11, X2 | [P6-T3] J7 |
| AC-3 | Appendix H edit H8 | row D1 | [P6-T3] J7 |
| AC-4 | Appendix H edit H8 | rows A1-A4, all pre-existing rows, the relocated rows in suite A | [P6-T3] J5, J6, J7, J10 |
| AC-5 | Appendix H edit H9 | row X4 | [P6-T3] J7, [P6-T9] |
| AC-6 | Appendix H edit H10, Appendix D `Get-DocsOnlyDiffTextViolation` | row X1, existing row `denies an empty diff` | [P6-T3] J7, [P6-T9] |
| AC-7 | Appendix H edits H4-H6 | rows S1-S4 | [P6-T9] |
| AC-8 | Appendix T, block T2 (converted by [P2-T14]) | rows S1-S4 | [P2-T15], [P6-T3] J7, [P6-T8] |
| AC-9 | Appendix H edit H6 | rows S1-S4 | [P8-T3] (CI) |
| AC-10 | none (pinned) | existing row `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` | [P6-T3] J7, [P6-T10] |
| AC-11 | Appendix H edits H1-H3, H7; Appendix M | none | [P6-T9] |
| AC-12 | [P3-T11], [P3-T12] | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in the pytest resource-contract suite | [P6-T4], [P6-T5] |
| AC-13 | [P5-T2], [P5-T3] | none | `FEATURE/evidence/other/pa-n3-commit-confirmation.<timestamp>.md`, `pa-n3-bounds.<timestamp>.md` |
| AC-14 | [P5-T4] to [P5-T16] | none | per-file greps in those tasks |
| AC-15 | [P5-T17], [P5-T18] | none | greps in those tasks |
| AC-16 | Phase 5 edits | none | [P5-T20] |
| AC-17 | [P5-T19] | none | grep in that task |
| AC-18 | Phase 6 loop | the DocsOnly suites | [P6-T1], [P6-T2], [P6-T3], [P8-T2] (CI) |
| AC-19 | none | all suites in CI | [P8-T2] (CI) |
| AC-20 | Phase 3 edits | none | [P6-T7] |
| AC-21 | Phase 3 edits | all suites in CI | [P8-T3] (CI) |
| AC-22 | section 9 | none | [P6-T11] |

## 3. Decisions fixed by this plan

- **D1 - token rule (create side).** `Get-PrAuthorDocsOnlyBaseName` returns `$null` for a single-dash token (length at least 2, first character `-`, second character not `-`) whose text after the dash contains `B` or `R` (ordinal, case-sensitive), for a token equal to `--repo` or beginning with `--repo=`, and for a token beginning with `GH_REPO=` (both ordinal-ignore-case). The checks sit in the existing token loop, before the `--base` count and before any git call (Appendix H, edit H8). Verified prerequisite: `$match.Segment.Tokens` includes `VAR=value` prefixes and gh global options (`.claude/hooks/hook-command-payload.ps1` line 188 skips `VAR=value` prefixes when walking; `.claude/hooks/hook-command-invocation.ps1` lines 47-51 model `-R` and `--repo` as gh `WithArgument` options, so `gh -R o/r pr create ...` and `gh -R o/r pr merge ...` are Structural matches).
- **D2 - NUL guard (both sides).** The NUL check lives in the shared pure function `Get-DocsOnlyDiffTextViolation` (Appendix D). On the create side it replaces the single classification statement directly after the existing `if ($null -eq $diff -or $diff.ExitCode -ne 0)` block (Appendix H, edit H10); empty output passes the guard and still reaches `DOCS_ONLY_EXEMPTION_EMPTY_DIFF`.
- **D3 - seam injection (revised in 2.1).** `Invoke-PrAuthorDocsOnlyGitExe` gains `[ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }` and its capture statement becomes `& $GitInvoker -C $WorktreeRoot @GitArgs 2>$null`; the two production call sites pass nothing (Appendix H, edits H4-H6). The shared seams carry `[ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }` (`Invoke-DocsOnlyGitExe`) and `[ValidateNotNull()][scriptblock] $GhInvoker = { gh @args 2>$null }` (`Invoke-DocsOnlyGhExe`) the same way (Appendix D). Tests pass the scriptblock of a test-local PowerShell function (rule 11). Rationale: `.claude/rules/powershell.md` line 51 sanctions a narrowly scoped `ScriptBlock` parameter with a safe default, and the guard of rule 15 (a) accepts an `&`-invoked variable only in that form; the string command-name form of version 2.0 (precedent `scripts/dev-tools/run-actionlint.ps1`, which sits outside the guarded roots) failed the guard at the original [P2-T9]. Hook precedent for the form: `.claude/hooks/enforce-completion-helpers.ps1` line 85 (`[scriptblock] $FolderExistsCheck = { ... }`) and line 109 (`& $FolderExistsCheck $normalized`). Within the default scriptblock, a plain scriptblock with no `param()` block receives `-C` and every following argument in `$args`, and `git @args` passes them to the executable unchanged; the inner `2>$null` discards native standard error inside the scriptblock and the outer `2>$null` is kept from the version 2.0 statement. A test-local function invoked through its scriptblock receives the same `$args` sequence as it did when invoked by name, so the expected outputs of rows S1-S4 and of the suite A and suite D seam rows are unchanged.
- **D4 - test placement.** New create-side rows are inserted after the last existing row of their block or as a new `Context`. The only edits to existing lines of the three DocsOnly suites are in `enforce-pr-author-skill.DocsOnly.Tests.ps1`: removal of the two pure-helper contexts (current lines 35-128, relocated under the shared names to suite A, Appendix T block T5) and the four `.DESCRIPTION` lines 9-12 (block T6). [P6-T10] verifies that the Exemption and Decision suites remove no line and that the DocsOnly suite removes at most 98 lines.
- **D5 - expect-fail prediction (derived, fixed).** Against the unchanged hooks, these new create-side rows fail: R1, R4 to R11, S1 to S4, X1 to X4, and D1 (13 + 4 + 1 = 18). R2, R3, and A1 to A4 pass. All 13 non-probe rows of suite C and all 8 non-probe rows of suite E fail because the docs-only seams, `Test-EpicMergeGateNoRecordingTarget`, and the Codex `-RepositoryRoot` parameter do not exist yet; both probe rows pass. Phase 1 therefore expects 39 new failing rows (Appendix R and Appendix R2).
- **D6 - PA-N3 bounds.** Bounds follow spec Design item 6. A commit-dependent upper bound is the confirmed committer time of the named commit, converted to UTC and truncated to the minute. A commit-dependent file is left unchanged only when its original value is neither earlier than its recorded lower bound nor later than the confirmed upper bound; the reason is then recorded in the bounds artifact. Files without a commit dependency apply the spec table as written.
- **D7 - CI-dependent criteria.** AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 are CI-dependent (AC-18 and AC-M23 for their analyzer half, because the PoshQC MCP analyze result carries no finding). They are listed as pending-CI in the AC verification artifact ([P7-T1]) and are checked off only by Phase 8, which the item's orchestrator run executes at S9 after the pull request exists.
- **D8 - helper internals.** Besides the six functions spec Design item 8 names, the helper defines two private functions that keep each function small: `Get-DocsOnlyMergeShapeViolation` (M1, pure) and `Get-DocsOnlyPullRequestTarget` (M3). The helper contains no `Get-Content`, no `(Get-Location).Path`, no `Import-Module`, no dot-source, and no quoted `'fetch'` argument (Appendix D). The M5 reason names `git fetch origin pull/<N>/head` as text for the operator; the hook never runs it.
- **D9 - merge-side test ordering.** Suites C and E are written in Phase 1 (expect-fail, D5). They load the helper only through the gate they dot-source, and the gates load it only after [P4-T2] and [P4-T6]. Their docs-only seam mocks in `BeforeAll` are guarded by `Get-Command`, so until Phase 4 every docs-only row fails on its own `Mock`, `Should -Invoke`, or parameter binding rather than failing the whole container; all 21 rows of Appendix R2 therefore fail in [P1-T7], [P2-T16], and [P3-T13] and pass from [P4-T24]. Suites A, B, and D test the new helper and are written in Phase 2 with the helper. Existing merge-gate suites receive their baseline seam mocks in Phase 4 (Appendix K), after the gates load the helper, so earlier phases do not break them.
- **D10 - session root in suite C.** Suite C mocks `Get-EpicMergeGateSessionWorktreeRoot` to the suite's own directory (an existing directory, so M2 passes without touching a checkpoint) and mocks the two target resolvers; no row reads repository state.
- **D11 - #901 folder locator.** [P0-T5] and again [P5-T1] record which of `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` and `docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901` exists. Either is accepted for locating and reading. Both present or neither present is `F901_LOCATOR: BLOCKED`, which stops Phase 5. Every #901 edit stays at the active path; when only the archive path exists, Phase 5 stops as BLOCKED and no archive copy is edited. Phases 1 to 4 never read `F901`. Historical pathspecs in `git show` commands ([P5-T2]) keep the active path regardless of the locator result.
- **OD-1 (Codex eligibility).** The Codex docs-only branch runs only when both raw checkpoint strings are blank (no checkpoint present at the repository root). No per-PR scan of present checkpoints is implemented.
- **OD-2 (`--match-head-commit`).** Optional equality check in M3; not an eligibility precondition.
- **OD-3 (documentation location).** Hook headers only (Appendix D header, edits G4 and X1). No edit under `.claude/rules/`.

---

## 4. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `FEATURE/evidence/baseline/p0-ac-source.<timestamp>.md` (requirements-source check). Commands: `grep -c '^## Acceptance Criteria' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-M[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -F -e '- Work Mode: full-bug' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/issue.md`; `ls docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Acceptance: the four counts print `1`, `22`, `25`, and `1`; the `ls` output lists `spec.md` and does not list `user-story.md`. Any other result stops the plan as BLOCKED.
- [x] [P0-T2] Write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` after reading, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `FEATURE/issue.md`, `FEATURE/spec.md`, `FEATURE/research/research.2026-10-15T11-52.md`, `FEATURE/research/2026-10-15T19-46-merge-gate-addendum-research.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (15 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: '` on the new artifact prints `15` and `grep -c '^Policy Order:'` on it prints `1`.
- [x] [P0-T3] Write `FEATURE/evidence/baseline/p0-branch-state.<timestamp>.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin main`; `git merge-base HEAD origin/main`; `git rev-parse HEAD`; `git rev-parse --show-toplevel`. Acceptance: the first prints `bug/pr-author-docs-only-exemption-hardening-927`; the status lists no path outside `FEATURE/` (the [P0-T1] and [P0-T2] artifacts and this plan file are expected); the fetch exits 0; the merge base is recorded as `MERGE_BASE: <40-hex>` and `HEAD` as `BASE_HEAD: <40-hex>`; the top-level output is used as the MCP `workspace_root` and recorded only as `WORKSPACE_ROOT: <WORKSPACE_ROOT>` (rule 2). A different branch or a status line outside `FEATURE/` stops the plan as BLOCKED.
- [x] [P0-T4] Write `FEATURE/evidence/baseline/p0-route.<timestamp>.md` (rule 10). Commands: `grep -o -E '"(route_id|path_selected|next_step)"[[:space:]]*:[[:space:]]*"[^"]*"' artifacts/orchestration/orchestrator-state.json`; `grep -c -F -e 'S12_complete' artifacts/orchestration/orchestrator-state.json`. Acceptance: the selected route (the `route_id` value when that key is printed, otherwise the `path_selected` value) is exactly `large`, `remediation`, or `preparation`, recorded as `ROUTE_SELECTED: <value>`; no printed `next_step` value is `complete`; the second command prints `0` (grep exits 1; recorded as `S12_COMPLETE_COUNT: 0`). Any other result is recorded as `ROUTE_NOT_UNCAPPED` and stops the plan as BLOCKED before any production file is written, because Phases 2 to 4 write six production PowerShell files.
- [x] [P0-T5] Write `FEATURE/evidence/baseline/p0-f901-locator.<timestamp>.md` (AC-M25, decision D11). Commands: `test -d docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `test -d docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901`. Acceptance: each exit code is recorded (`0` present, `1` absent) as `F901_ACTIVE:` and `F901_ARCHIVE:`; the artifact records `F901_LOCATOR: active` when only the active path exists, `F901_LOCATOR: archive-only` when only the archive path exists (Phase 5 then stops as BLOCKED at [P5-T1]), or `F901_LOCATOR: BLOCKED` when both or neither exist (Phase 5 stops as BLOCKED). Phases 1 to 4 proceed in every case because they do not read `F901`.
- [x] [P0-T6] Write `FEATURE/evidence/baseline/p0-line-counts-parity.<timestamp>.md`. Commands: `grep -c '^' .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`; `cmp -s` of each canonical file with its mirror for these five pairs: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` against the same name under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `.codex/hooks/enforce-epic-merge-gate.ps1` against `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; `git hash-object` on each of the ten files; `test -f` on each of the four helper paths of Appendix D. Acceptance: the counts print `265`, `355`, `472`, `243`, `385`, `218`, `209`, and `149` in that order; all five `cmp -s` calls exit 0; each canonical/mirror hash pair is equal; all four `test -f` calls exit 1 (the helper does not exist yet). A different count stops the plan for re-derivation of the Appendix H, G, X, and T anchors; a `cmp` difference stops the plan as BLOCKED (pre-existing mirror drift).
- [x] [P0-T7] Write `FEATURE/evidence/baseline/p0-poshqc-format.<timestamp>.md` (baseline format; write-mode tool observed by tree state). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: the MCP disposition is recorded; the status command prints nothing, meaning the formatter rewrote no PowerShell file. If it lists any path, the plan stops as BLOCKED with the paths recorded as `BASELINE_FORMAT_DRIFT:` lines; the executor does not revert them.
- [x] [P0-T8] Write `FEATURE/evidence/baseline/p0-poshqc-analyze.<timestamp>.md`. Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `BASELINE_ANALYZE_DISPOSITION: returned` is recorded and the status command prints nothing. `MCP_CALL: error` stops the plan as BLOCKED, because a pre-existing analyzer failure would make the final analyze step unobservable. The `Output Summary:` states that the MCP result carries no finding count and that the CI `Analyze PowerShell` step of `poshqc / PowerShell QC` is the authoritative finding source ([P8-T2]).
- [x] [P0-T9] Write `FEATURE/evidence/baseline/p0-poshqc-test.<timestamp>.md` (baseline Pester). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J6, J10, J12, and J13. Acceptance: J1 shows the JUnit file was rewritten by this run; J2 is recorded as `BASELINE_TESTSUITES: tests=<n> failures=<n> errors=<n>` and its failures value as `FAIL_BASE: <n>`; the J3 lines are recorded verbatim as `B_FAILED:` lines (or `B_FAILED: none`), and their count equals `FAIL_BASE`; J4 is recorded as `FAM_BASE: <n>` and is greater than 0; J5 prints `0`; J6 prints `28`, `15`, and `8`; J10 prints `0` for all five new suites (they do not exist yet); J12 prints `0`, recorded as `MERGE_FAM_FAILED_BASE: 0`, and a non-zero J12 stops the plan as BLOCKED (the merge family fails before any change); every J13 count is greater than 0. J1 without a rewrite stops the plan as BLOCKED with `POSHQC_JUNIT_NOT_WRITTEN`; a non-zero J5 stops the plan as BLOCKED (the family fails before any change); different J6 values stop the plan for re-derivation of decision D5 and the later J6 values.
- [x] [P0-T10] Write `FEATURE/evidence/baseline/p0-pytest-contracts.<timestamp>.md`. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`. Acceptance: exit 0 and the final summary line reports `passed` with no `failed` or `error` count; the summary line is recorded verbatim. A failure is recorded with its first assertion message and stops the plan as BLOCKED.
- [x] [P0-T11] Write `FEATURE/evidence/baseline/p0-jest-manifest.<timestamp>.md`. Commands: `test -d extensions/drm-copilot/node_modules/jest`; when that exits 1 (this task authorizes the branch), `npm --prefix extensions/drm-copilot ci`, which writes only the git-ignored `node_modules`; then `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Acceptance: the Jest command exits 0 and its `Tests:` summary line, recorded verbatim, contains `passed` and does not contain `failed`. A failure stops the plan as BLOCKED.
- [x] [P0-T12] Write the coverage reader `SCRATCH/927/tools/read_coverage_927.py` with the exact content of Appendix S (Write tool; the file is outside the repository and is not committed), then write `FEATURE/evidence/baseline/p0-ci-coverage-baseline.<timestamp>.md`. Commands: `gh run list --workflow ci.yml --commit <MERGE_BASE> --json databaseId,event,status,conclusion,headSha --limit 10` with the [P0-T3] value substituted; for each listed run in printed order, `gh run download <databaseId> -n poshqc-test-results -D SCRATCH/927/ci-base/<databaseId>` until one download exits 0; then `poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-base/<databaseId>/powershell-coverage.xml .claude/hooks/enforce-pr-author-skill.docs-only.ps1:64,65,68,70 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the run used is recorded as `BASELINE_CI_RUN_ID:` with its `headSha` equal to `MERGE_BASE`; the reader exits 0 and its five `COVERAGE_RESULT:` lines and four `LINE_RESULT:` lines are copied verbatim, giving numeric `covered`, `missed`, and `line_pct` for each file. When no listed run yields the artifact, the artifact records `BASELINE_COVERAGE: UNAVAILABLE` with the run list output (this task authorizes that branch); [P8-T4] then reports the coverage delta as remediation-required rather than PASS.
- [x] [P0-T13] Commit and push Phase 0 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record phase 0 baseline evidence`. Acceptance: the push exits 0; `git status --porcelain` lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 1 — Regression Tests (expect-fail)

- [x] [P1-T1] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: insert Appendix T block T1 (rows R1-R11 and A1-A4) directly before the unique line `        It 'returns null for gh pr edit' {`. Acceptance: `grep -c -F -e "It 'denies the base or repository override <Name>' -ForEach" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e "It 'still resolves main for <Name>' -ForEach" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; the Edit is not denied by `.claude/hooks/check-powershell-test-purity.ps1`.
- [x] [P1-T2] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: insert Appendix T block T2 (the new `Context` with rows S1-S4) after the closing brace of the existing `Context 'Invoke-PrAuthorDocsOnlyGitExe'` and before the final closing brace of the `Describe`, as Appendix T specifies. Acceptance: `grep -c -F -e "Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e '-GitInvoker' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `4`; `grep -c -F -e 'GitCommand' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `0`; the Edit is not denied by the purity hook. (Revision 2.1: the block was inserted in its version 2.0 form at commit `c87fc34a8`; this task is unchecked because its acceptance tokens changed, and [P2-T14] converts the block and re-verifies this acceptance, after which this box is checked. The insertion is not repeated: resuming execution skips this task and starts at [P2-T9].)
- [x] [P1-T3] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`: insert Appendix T block T3 (rows X1-X4) after the last existing `It` of `Context 'predicate rows'`, as Appendix T specifies. Acceptance: `grep -c -F -e '(issue #927)' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` prints `4`.
- [x] [P1-T4] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`: insert Appendix T block T4 (row D1) after the last existing `It` of `Context 'non-epic preflight failure'`, as Appendix T specifies. Acceptance: `grep -c -F -e "It 'denies a --repo override before the diff (issue #927)'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` prints `1`.
- [x] [P1-T5] Write the new suite `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (suite C) with the exact content of Appendix N block N-C (Write tool). Acceptance: `grep -c -F -e "Describe 'enforce-epic-merge-gate docs-only branch (issue #927)'" tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e '(issue #927)' tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` prints `13` (the `.SYNOPSIS` line, the `Describe` line, the two target-resolver `Mock` lines, the `$resolved` line of the target-status row, and the eight `It` lines that carry the suffix); the Write is not denied by the purity hook.
- [x] [P1-T6] Write the new suite `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (suite E) with the exact content of Appendix N block N-E (Write tool). Acceptance: `grep -c -F -e "Describe 'Codex enforce-epic-merge-gate docs-only branch (issue #927)'" tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `1`; `grep -c -F -e '(codex, issue #927)' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `7` (the seven `It` lines; the two checkpoint rows share one `It`); the Write is not denied by the purity hook.
- [x] [P1-T7] [expect-fail] Write `FEATURE/evidence/regression-testing/p1-expect-fail.<timestamp>.md` (fail-before run against the unchanged hooks). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J11. The artifact's first `Command:` is the J5 command and its `EXIT_CODE:` is the J5 exit code; the MCP disposition is recorded as `MCP_CALL:` (either disposition is accepted for this run). Acceptance: J1 shows a rewrite; J5 prints `18`; J8 prints `13`, `4`, and `1`; J6 prints `34`, `15`, and `8`; J9 prints `1` for each of the 18 expect-fail tokens of Appendix R and each of the 21 tokens of Appendix R2 (decision D5); J10 prints `0`, `0`, `1`, `0`, and `1`; J11 prints `0`, `0`, `13`, `0`, and `8`; the J2 failures value equals `FAIL_BASE + 39`; every `B_FAILED` line of [P0-T9] is still present in J3. Any other failing row is a test-authoring defect: the executor corrects the test text only (never a hook) and reruns this task.
- [x] [P1-T8] Write `FEATURE/evidence/regression-testing/p1-test-purity.<timestamp>.md`. Command: `grep -c -E -e 'Mock[[:space:]]+.?(git|gh)\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|function[[:space:]]+(global:|script:)?(git|gh)\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`. Acceptance: the five printed counts are each `0` (grep exits 1 because nothing matched; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`).
- [x] [P1-T9] Commit and push Phase 1 (rule 14). Paths: the three DocsOnly suites, suites C and E, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `test(927): add expect-fail rows for docs-only exemption hardening and the merge-gate docs-only branch`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 2 — Shared Helper

Revision 2.1 rework ([P2-T9] to [P2-T15]): the files written by [P2-T1] to [P2-T8] and the block written by [P1-T2] carry the version 2.0 string seam form, which the guard of rule 15 (a) rejects. Those tasks bring them to the revised Appendix D, N, and T text before the Pester run [P2-T16]. The acceptance tokens of [P2-T1] to [P2-T8] are unchanged, so those boxes stay checked; [P2-T9] and [P2-T12] to [P2-T14] rerun their greps against the reworked files. Execution resumes at [P2-T9].

- [x] [P2-T1] Write `.claude/hooks/hook-docs-only-diff.ps1` with the exact content of Appendix D (Write tool). Acceptance: `grep -c '^function ' .claude/hooks/hook-docs-only-diff.ps1` prints `8`; `grep -c -E '^function (ConvertFrom-DocsOnlyNameList|Get-DocsOnlyPathViolation|Get-DocsOnlyDiffTextViolation|Invoke-DocsOnlyGitExe|Invoke-DocsOnlyGhExe|Get-DocsOnlyMergeExemption) \{' .claude/hooks/hook-docs-only-diff.ps1` prints `6`; `grep -c -F -e 'did not return NUL-terminated output' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'EndsWith([char]0)' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e "'fetch'" .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -F -e 'Get-Content' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -F -e 'Import-Module' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -E -e '^[[:space:]]*\. ' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1` prints a value below `500`, recorded as `HELPER_LINES:`. The next Bash call is not denied (rule 7).
- [x] [P2-T2] Copy the helper to the Codex runtime (rule 9). Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P2-T3] Copy the helper to the Claude bundle (rule 9). Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P2-T4] Copy the helper to the Codex bundle (rule 9). Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P2-T5] Write `FEATURE/evidence/qa-gates/p2-helper-identity.<timestamp>.md` (AC-M2 hash half). Commands: `git hash-object` on each of the four helper paths of Appendix D. Acceptance: the four printed hashes are equal and are recorded as `HELPER_HASH: <40-hex>` once with the four paths listed.
- [x] [P2-T6] Write the new suite `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (suite A) with the exact content of Appendix N block N-A (Write tool). Acceptance: `grep -c -F -e "Context 'Get-DocsOnlyPathViolation'" tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e "Context 'ConvertFrom-DocsOnlyNameList'" tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e 'PrAuthorDocsOnly' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; the Write is not denied by the purity hook.
- [x] [P2-T7] Write the new suite `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (suite B) with the exact content of Appendix N block N-B (Write tool). Acceptance: `grep -c -F -e "Describe 'Get-DocsOnlyMergeExemption (issue #927)'" tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `1`; `grep -c -F -e "a docs-only exemption row reached git fetch" tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `1`; the Write is not denied by the purity hook.
- [x] [P2-T8] Write the new suite `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (suite D) with the exact content of Appendix N block N-D (Write tool). Acceptance: `grep -c -F -e ".codex/hooks/hook-docs-only-diff.ps1" tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `2` (the `.SYNOPSIS` line and the dot-source line); `grep -c -F -e '.claude/hooks' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; the Write is not denied by the purity hook.
- [x] [P2-T9] Rewrite `.claude/hooks/hook-docs-only-diff.ps1` with the exact content of Appendix D as revised in version 2.1 (Read the file, then Write; the helper is not yet loaded by any consumer, so rule 7 does not apply until [P3-T1]). Acceptance: `grep -c -F -e '[ValidateNotNull()][scriptblock] $GitInvoker = { git @args' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '[ValidateNotNull()][scriptblock] $GhInvoker = { gh @args' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '& $GhInvoker @GhArgs' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '.PARAMETER GitInvoker' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '.PARAMETER GhInvoker' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'GitCommand' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -F -e 'GhCommand' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; every grep of the [P2-T1] acceptance prints its stated value again (`8`, `6`, `1`, `1`, `0`, `0`, `0`, `0`) and `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1` prints `397`, the `HELPER_LINES:` value recorded for [P2-T1] in `FEATURE/evidence/qa-gates/p2-helper-identity.2026-10-16T01-26.md` (revision 2.1 changes no line count). The executor records these values in the [P2-T11] artifact under `REWORK_HELPER:` lines.
- [x] [P2-T10] Re-copy the helper to its three other paths (rule 9). Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`; then `cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`. Acceptance: the three `cp` calls exit 0 and the three `cmp -s` calls exit 0.
- [x] [P2-T11] Write `FEATURE/evidence/qa-gates/p2-helper-identity.<timestamp>.md` (AC-M2 hash half, after the rework). Commands: `git hash-object` on each of the four helper paths of Appendix D. Acceptance: the four printed hashes are equal and are recorded once as `HELPER_HASH: <40-hex>` with the four paths listed; the value differs from `d140874bb42ba07c8eb1fbd0a3dccba0e16fffda`, the version 2.0 hash recorded by [P2-T5] in `FEATURE/evidence/qa-gates/p2-helper-identity.2026-10-16T01-26.md`, which is recorded as `PRIOR_HELPER_HASH: d140874bb42ba07c8eb1fbd0a3dccba0e16fffda` (the rewrite changed the file); the [P2-T9] values are recorded as `REWORK_HELPER:` lines.
- [x] [P2-T12] Edit suite A `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` to the revised Appendix N block N-A: apply Appendix N edits NA-1 to NA-4 with Edit. Acceptance: `grep -c -F -e '-GitInvoker' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `4`; `grep -c -F -e '-GhInvoker' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `4`; `grep -c -F -e 'GitCommand' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; `grep -c -F -e 'GhCommand' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; `grep -c -F -e 'passed by name' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; the three [P2-T6] greps print `1`, `1`, and `0` again; the Edit is not denied by the purity hook.
- [x] [P2-T13] Edit suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` to the revised Appendix N block N-D: apply Appendix N edits ND-1 and ND-2 with Edit. Acceptance: `grep -c -F -e '-GitInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e '-GhInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e 'GitCommand' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; `grep -c -F -e 'GhCommand' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `0`; the two [P2-T8] greps print `2` and `0` again; the Edit is not denied by the purity hook.
- [x] [P2-T14] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: convert the committed block T2 to the revised Appendix T block T2 by applying Appendix T edits T2-1 to T2-5 with Edit. Acceptance: the three greps of the [P1-T2] acceptance print `1`, `4`, and `0`; `grep -c -F -e 'Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `4`; the Edit is not denied by the purity hook. On success the executor checks both this task and [P1-T2].
- [x] [P2-T15] Write `FEATURE/evidence/regression-testing/p2-test-purity.<timestamp>.md` (rule 11 after the rework). Command: the [P1-T8] grep command with suites A, B, and D appended to its file list (the same command as [P6-T8]). Acceptance: the eight printed counts are each `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [x] [P2-T16] Write `FEATURE/evidence/regression-testing/p2-helper-pass.<timestamp>.md` (replaces the BLOCKED record `p2-helper-pass.2026-10-16T01-53.md` as the lexicographically greatest match). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J11 and J14. Acceptance: J1 shows a rewrite; J10 prints `30`, `36`, `1`, `32`, and `1`; J11 prints `0`, `0`, `13`, `0`, and `8` (decision D9: suites C and E do not load the helper until Phase 4); J5 prints `18` and J8 prints `13`, `4`, and `1` (create side unchanged; S1 to S4 still fail because `Invoke-PrAuthorDocsOnlyGitExe` has no `-GitInvoker` parameter until [P3-T2]); J14 prints `1` and `1` (rule 15 (a)); the J2 failures value equals `FAIL_BASE + 39`; every J3 line is either a token of Appendix R or R2 or a `B_FAILED` line. A failure in suite A, B, or D is fixed in the helper (Appendix D) or, for a defect in test text, in the test, and this task reruns; any helper fix is followed by rerunning [P2-T10] and [P2-T11]. A J14 value of `0` is fixed in the helper text only, never by an allowlist entry.
- [x] [P2-T17] Commit and push Phase 2 (rule 14). Paths: the four helper paths of Appendix D, suites A, B, and D, `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `feat(927): add the shared docs-only diff helper for the create and merge gates`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 3 — Create-Side Hardening

- [x] [P3-T1] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edits H11 (`.NOTES` sentence) and H12 (dot-source of the helper directly after `param()`). Acceptance: `grep -A 1 -x -F -e 'param()' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `param()` followed by the line `. (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1')`; `grep -c -F -e 'hook-docs-only-diff.ps1' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `2`; the next Bash call is not denied (rule 7).
- [x] [P3-T2] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edits H4 and H5 (the `.PARAMETER GitInvoker` help block and the `$GitInvoker` parameter). Acceptance: `grep -c -F -e '[ValidateNotNull()][scriptblock] $GitInvoker = { git @args' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e '.PARAMETER GitInvoker' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`.
- [x] [P3-T3] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H6 (the capture statement). Acceptance: `grep -c -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e '& git -C' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e '-GitInvoker' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0` (no call site passes the parameter, AC-7); `grep -c -F -e 'GitCommand' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`.
- [x] [P3-T4] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H8 (the override checks in the token loop of `Get-PrAuthorDocsOnlyBaseName`). Acceptance: `grep -c -F -e "StartsWith('-B'" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e "StartsWith('GH_REPO='" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e "StartsWith('--repo='" .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`.
- [x] [P3-T5] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H9 (the E3 Reason text). Acceptance: `grep -c -F -e 'shorthand cluster containing B or R, and an inline GH_REPO= prefix are not accepted' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'the -B short form is not read' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`.
- [x] [P3-T6] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H10 (classification through the shared NUL guard). Acceptance: `grep -c -F -e 'Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'Get-PrAuthorDocsOnlyPathViolation -Path' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`.
- [x] [P3-T7] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edit H13 (remove the two local pure functions now provided by the helper). Acceptance: `grep -c -F -e 'function ConvertFrom-PrAuthorDocsOnlyNameList' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e 'function Get-PrAuthorDocsOnlyPathViolation' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e 'function Invoke-PrAuthorDocsOnlyGitExe' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `2`; `grep -c -F -e 'Invoke-DocsOnlyGitExe' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -F -e 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0` (AC-M17).
- [x] [P3-T8] Edit `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: apply Appendix H edits H1, H2, H3, and H7 (file header E3 and E5 rows, residual-limit paragraph, and the `Get-PrAuthorDocsOnlyBaseName` `.DESCRIPTION`). Acceptance: `grep -c -F -e 'no inline GH_REPO= prefix.' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'and non-empty output ends with NUL.' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'Residual limit:' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'token has B or R among its letters' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `1`; `grep -c -F -e 'no -B token' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c '^' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `224`.
- [x] [P3-T9] Edit `.claude/hooks/enforce-pr-author-skill.ps1`: replace the `Docs-only` header block (current lines 26-41) with Appendix M. Acceptance: `grep -c -F -e 'no inline GH_REPO= prefix);' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'single-dash token whose letters include B or R' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'repository override is present, or' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'returns output not ending with NUL.' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F -e 'and no -B token;' .claude/hooks/enforce-pr-author-skill.ps1` prints `0`; `grep -c '^' .claude/hooks/enforce-pr-author-skill.ps1` prints `359`.
- [x] [P3-T10] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: apply Appendix T blocks T5 (remove the two relocated contexts) and T6 (`.DESCRIPTION` text). Acceptance: `grep -c -F -e "Context 'Get-PrAuthorDocsOnlyPathViolation'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `0`; `grep -c -F -e "Context 'ConvertFrom-PrAuthorDocsOnlyNameList'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `0`; `grep -c -F -e "Context 'Get-PrAuthorDocsOnlyBaseName'" tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e 'moved with their rows to' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`.
- [x] [P3-T11] Copy the docs-only hook to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P3-T12] Copy the main pr-author hook to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`; `cmp -s .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P3-T13] Write `FEATURE/evidence/regression-testing/p3-create-side-pass.<timestamp>.md` (pass-after run for the create side). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J11 and J14. Acceptance: J1 shows a rewrite; J14 prints `1` and `1` (rule 15 (a), after H6 and H12); J5 prints `0`; J8 prints `0`, `0`, and `0`; J6 prints `34`, `19`, and `9`; J4 equals `FAM_BASE + 11` (24 new rows, 13 rows relocated to suite A); J7 prints `1` for every token of Appendix R; J10 prints `30`, `36`, `1`, `32`, and `1`; J11 prints `0`, `0`, `13`, `0`, and `8`; the J2 failures value equals `FAIL_BASE + 21`; every J3 line is an Appendix R2 token or a `B_FAILED` line. A failure here is fixed in the hook (Appendix H) or, for a defect in test text, in the test, then this task reruns (a hook fix is followed by rerunning [P3-T11]).
- [x] [P3-T14] Commit and push Phase 3 (rule 14). Paths: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, the two mirror paths of [P3-T11] and [P3-T12], `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `fix(927): deny base and repository overrides and non-NUL diff output in the docs-only exemption`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 4 — Merge Gates (PRIMARY)

- [x] [P4-T1] Edit `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: apply Appendix G edits G1a (header bullet) and G1b (append `Test-EpicMergeGateNoRecordingTarget`). Acceptance: `grep -c -F -e 'function Test-EpicMergeGateNoRecordingTarget' .claude/hooks/enforce-epic-merge-gate-resolution.ps1` prints `1`; `grep -c -F -e 'Test-EpicMergeGateNoRecordingTarget, the precondition' .claude/hooks/enforce-epic-merge-gate-resolution.ps1` prints `1`; `grep -c '^' .claude/hooks/enforce-epic-merge-gate-resolution.ps1` prints `278`.
- [x] [P4-T2] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: apply Appendix G edit G2 (guarded dot-source of the helper after the resolution sibling). Acceptance: `grep -c -F -e "Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1'" .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; the next Bash call is not denied (rule 7).
- [x] [P4-T3] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: apply Appendix G edit G3 (the docs-only branch in the explicit-number block of `Invoke-EpicMergeGateDecision`). Acceptance: `grep -c -F -e 'Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'Get-DocsOnlyMergeExemption -CommandText $commandText -PrNumber $commandPrNumber -WorktreeRoot $sessionRoot' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e '$standalone.Message + $docsOnlySuffix)' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e "' (docs-only exemption not applied: '" .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`.
- [x] [P4-T4] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: apply Appendix G edit G4 (replace the design-decision paragraph, current lines 36-39). Acceptance: `grep -c -F -e 'rather than shelling out live' .claude/hooks/enforce-epic-merge-gate.ps1` prints `0`; `grep -c -F -e 'conditions M1-M9' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'The hook never fetches' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c '^' .claude/hooks/enforce-epic-merge-gate.ps1` prints `490`.
- [x] [P4-T5] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix X edit X1 (header `.DESCRIPTION`). Acceptance: `grep -c -F -e 'operator decision OD-1' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'conditions M1-M9' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`.
- [x] [P4-T6] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix X edit X2 (guarded dot-source after the `hook-command-invocation.ps1` dot-source). Acceptance: `grep -c -F -e "Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1'" .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`.
- [x] [P4-T7] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix X edit X3 (the `RepositoryRoot` parameter). Acceptance: `grep -c -F -e '[AllowNull()][AllowEmptyString()][string] $RepositoryRoot' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`.
- [x] [P4-T8] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix X edit X4 (the docs-only branch and the appended suffix). Acceptance: `grep -c -F -e '-WorktreeRoot $RepositoryRoot' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e '$verdict.Message + $docsOnlySuffix' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c -F -e 'IsNullOrWhiteSpace($ChildCheckpointRaw) -and' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`.
- [x] [P4-T9] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix X edit X5 (the entry point passes the repository root). Acceptance: `grep -c -F -e '-RepositoryRoot $repositoryRoot' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1` (AC-M14 source half); `grep -c '^' .codex/hooks/enforce-epic-merge-gate.ps1` prints `410`.
- [x] [P4-T10] Copy the Claude gate to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P4-T11] Copy the resolution sibling to its mirror (rule 9). Commands: `cp .claude/hooks/enforce-epic-merge-gate-resolution.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1`; `cmp -s .claude/hooks/enforce-epic-merge-gate-resolution.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P4-T12] Copy the Codex gate to its mirror (rule 9). Commands: `cp .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: `cp` exits 0 and `cmp -s` exits 0.
- [x] [P4-T13] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: apply Appendix J edit J-C. Commands after the edit: `git add -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `git diff --cached --numstat -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Acceptance: `grep -c -F -e '".claude/hooks/hook-docs-only-diff.ps1",' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints `1`; the numstat line begins with `1` then a tab then `0` (one line added, none removed).
- [x] [P4-T14] Edit `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: apply Appendix J edit J-X. Commands after the edit: `git add -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; `git diff --cached --numstat -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. Acceptance: `grep -c -F -e '".codex/hooks/hook-docs-only-diff.ps1",' extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` prints `1`; the numstat line begins with `1` then a tab then `0`.
- [x] [P4-T15] Write `FEATURE/evidence/other/p4-merge-gate-suite-set.<timestamp>.md` (AC-M16 derivation, two independent searches). Commands: `grep -r -l -F -e 'enforce-epic-merge-gate.ps1' --include='*.Tests.ps1' tests`; `grep -r -l -E -e 'Invoke-EpicMergeGateDecision|Get-EpicMergeGateCommandPrNumber' --include='*.Tests.ps1' tests`. Derivation (fixed): the member set is every file listed by the first search whose text dot-sources `.claude/hooks/enforce-epic-merge-gate.ps1` (a statement beginning `. ` that names the file directly, through `$script:UnderTest` or `$script:Hook` assigned to the Claude path, or through a `$HookRoot` row whose value is `.claude/hooks`), excluding suite C; files that only name the Codex copy, only spawn the hook as a process, or only list the path as data or in a comment are recorded as non-members with the reason. The second search is the comparison set: every file in it other than suite C must be a member, and every member absent from it is recorded with the reason (it loads the gate without calling the decision function). Acceptance: the member set equals exactly these eight files, recorded as `MEMBER:` lines: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`. A different member set stops the plan for re-derivation of Appendix K.
- [x] [P4-T16] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`: apply Appendix K row K1. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`. Acceptance: `grep -c -F -e "Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }" tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` prints `1`; the same grep with `Invoke-DocsOnlyGitExe` in place of `Invoke-DocsOnlyGhExe` prints `1`; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T17] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`: apply Appendix K row K2. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T18] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`: apply Appendix K row K3. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T19] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`: apply Appendix K row K4. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T20] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`: apply Appendix K row K5. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T21] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`: apply Appendix K row K6. Commands after the edit: `git add -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T22] Edit `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`: apply Appendix K row K7. Commands after the edit: `git add -- tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T23] Edit `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`: apply Appendix K row K8. Commands after the edit: `git add -- tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`; `git diff --cached --numstat -- tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`. Acceptance: the two Appendix K mock greps each print `1` on this file; the numstat line begins with `2` then a tab then `0`.
- [x] [P4-T24] Write `FEATURE/evidence/regression-testing/p4-merge-gate-pass.<timestamp>.md` (pass-after run for the merge side). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J14. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `34`, `19`, and `9`; J7 prints `1` for every token of Appendix R; J10 prints `30`, `36`, `14`, `32`, and `9`; J11 prints `0` for all five suites; J12 prints `0`; every J13 count is greater than 0; J14 prints `1` and `1` (rule 15 (a), after G2 and X2); the J2 failures value equals `FAIL_BASE`; every J3 line is a `B_FAILED` line. A failure in an existing member suite caused only by the appended docs-only suffix is fixed by editing that assertion line, and each such edit is recorded as `SUFFIX_EDIT: <suite> <line>` (AC-M16); any other failure is fixed in the gate edits (Appendix G or X, followed by the matching mirror task) or, for a defect in new test text, in the test, and this task reruns.
- [x] [P4-T25] Write `FEATURE/evidence/qa-gates/p4-pytest-contracts.<timestamp>.md` (AC-M19, AC-M20 pytest half, AC-12). Command: the [P0-T10] pytest command, unchanged. Acceptance: exit 0 and the final summary line reports `passed` with no `failed` or `error` count; the summary line is recorded verbatim.
- [x] [P4-T26] Write `FEATURE/evidence/qa-gates/p4-jest-manifest.<timestamp>.md` (AC-M20 Jest half). Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Acceptance: exit 0 and the `Tests:` summary line, recorded verbatim, contains `passed` and does not contain `failed`.
- [x] [P4-T27] Commit and push Phase 4 (rule 14). Paths: the three canonical gate files edited by [P4-T1] to [P4-T9] (`.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`) and their three mirrors of [P4-T10] to [P4-T12], both manifests, the eight Appendix K suites, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `feat(927): allow docs-only merges of unrecorded PRs in the Claude and Codex epic merge gates`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 5 — #901 Evidence Corrections (PA-N3, PA-N2)

- [x] [P5-T1] Write `FEATURE/evidence/other/p5-f901-locator.<timestamp>.md` (AC-M25 re-check before any `F901` read). Commands: `test -d docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `test -d docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901`. Acceptance: the first exits 0 and the second exits 1, recorded as `F901_LOCATOR: active`. Archive-only, both, or neither is recorded as `F901_LOCATOR: archive-only` or `F901_LOCATOR: BLOCKED` and stops Phase 5 as BLOCKED with no `F901` edit; Phases 6 to 8 then report AC-13 to AC-17 as BLOCKED.
- [x] [P5-T2] Write `FEATURE/evidence/other/pa-n3-commit-confirmation.<timestamp>.md` before any `F901` file is edited. Commands: `git cat-file -t ff1b7cbd4`; `git cat-file -t 70e58ca84`; `git show -s --format=%cI ff1b7cbd4 70e58ca84`; `git show --name-status --format=%H ff1b7cbd4 70e58ca84 -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence`. Fallback (authorized only when a `git cat-file -t` call does not print `commit`): `gh api repos/drmoisan/drm-copilot/commits/<sha> --jq .commit.committer.date` and `gh api repos/drmoisan/drm-copilot/commits/<sha> --jq '.files[].filename'` for that sha. Acceptance: both committer times are recorded verbatim and as UTC minutes `C1_UTC_MINUTE:` (ff1b7cbd4) and `C2_UTC_MINUTE:` (70e58ca84) in `yyyy-MM-ddTHH-mm` form; the file listing of each commit is recorded verbatim; every file of Appendix P marked with a commit dependency appears in that commit's listing. A missing commit (both routes fail) or a file absent from its commit's listing (`MEMBERSHIP_MISMATCH: <file>`) stops the plan as BLOCKED.
- [x] [P5-T3] Write `FEATURE/evidence/other/pa-n3-bounds.<timestamp>.md`: one row per Appendix P file with `FILE`, `ORIGINAL`, `LO`, `HI`, `COMMIT_DEPENDENCY`, `CONTRADICTED`, and `ACTION` (`EDIT` or `UNCHANGED: <reason>`), derived by decision D6 from the [P5-T2] values. Command recorded: `Derivation per plan decision D6 from pa-n3-commit-confirmation`. Acceptance: 13 rows; every `HI` of a commit-dependent row equals the confirmed `C1_UTC_MINUTE` or `C2_UTC_MINUTE` of its commit; when the confirmed minutes are `2026-10-13T11-17` and `2026-10-13T11-34`, every row's `ACTION` is `EDIT` and the `HI` values equal Appendix P.
- [x] [P5-T4] Edit `F901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` per Appendix P row P1 (skip with the bounds-artifact reason if its `ACTION` is `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T00-00`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T5] Edit `F901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` per Appendix P row P2. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T10-51`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T10-51'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`.
- [x] [P5-T6] Edit `F901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` per Appendix P row P3. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T00-00'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`.
- [x] [P5-T7] Edit the `Timestamp:` row of `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` per Appendix P row P4. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T11-14`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-30'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-14'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`.
- [x] [P5-T8] Edit `F901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` per Appendix P row P5 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-32'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-32`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T9] Edit `F901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` per Appendix P row P6 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-34'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-34`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T10] Edit `F901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` per Appendix P row P7 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-36'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-36`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T11] Edit `F901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` per Appendix P row P8 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-38'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-38`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T12] Edit `F901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` per Appendix P row P9 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-39'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-39`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T13] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` per Appendix P row P10. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` prints `Timestamp: 2026-10-13T11-28`; `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-32'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-28'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`.
- [x] [P5-T14] Edit `F901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` per Appendix P row P11 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-34` under confirmed C2); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-36'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-36`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T15] Edit `F901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` per Appendix P row P12 (skip with the bounds-artifact reason if `UNCHANGED`). Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-34` under confirmed C2); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T11-37'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`. When the row's `ACTION` is `UNCHANGED`, the acceptance is instead: `grep -m 1 '^Timestamp:'` on the file prints the row's `ORIGINAL` value (`Timestamp: 2026-10-13T11-37`), `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `0`, and `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `0`.
- [x] [P5-T16] Edit `F901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` per Appendix P row P13. Acceptance: `grep -m 1 '^Timestamp:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` prints the row's `HI` (`Timestamp: 2026-10-13T11-17` under confirmed C1); `grep -c '^TIMESTAMP_RECONSTRUCTED: true$'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_ORIGINAL: 2026-10-13T06-55'` on the file prints `1`; `grep -c -F -e 'TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17'` on the file prints `1`; `grep -c '^TIMESTAMP_DERIVATION: '` on the file prints `1`.
- [x] [P5-T17] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md`: replace the line `EXIT_CODE: 0` with the two lines `EXIT_CODE: NOT_OBSERVED` and `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`. Acceptance: `grep -c '^EXIT_CODE: NOT_OBSERVED$'` on the file prints `1`; `grep -c -F -e 'EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md'` on the file prints `1`; `grep -c '^EXIT_CODE: 0$'` on the file prints `0`.
- [x] [P5-T18] Edit `F901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md`: replace the whole `Output Summary:` line with the Appendix P replacement line P4b. Acceptance: `grep -c -F -e 'Exit code 0 means' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `0`; `grep -c -F -e 'The process exit code of this run was not observed' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` prints `1`.
- [x] [P5-T19] Edit `F901/issue.md`: replace the three lines under `## Evidence Checklist` (current lines 49-51) with the three Appendix P lines P-N2. Acceptance: `grep -c -F -e '- [x] baseline (evidence/baseline/)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -F -e '- [x] targeted verification (evidence/qa-gates/ and evidence/regression-testing/)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -F -e '- [x] end-state (evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md and the PR #924 merge at e467c693)' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -E '^- \[ \] (baseline|targeted verification|end-state)$' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `0`.
- [x] [P5-T20] Write `FEATURE/evidence/qa-gates/p5-no-rename.<timestamp>.md` (AC-16). Commands: `git add -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git status --porcelain -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git diff --cached --name-status <MERGE_BASE> -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` with the [P0-T3] value substituted. Acceptance: every status line begins with `M ` (staged modification); every diff line begins with `M` followed by a tab; the diff lists exactly `F901/issue.md` plus every Appendix P file whose bounds-artifact `ACTION` is `EDIT` (14 lines when all 13 rows are `EDIT`); no line begins with `A`, `D`, or `R`; `p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` is not listed.
- [x] [P5-T21] Commit and push Phase 5 (rule 14). Paths: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): correct #901 evidence timestamps, exit code, and checklist`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 6 — Final QC Loop

Restart rule: run [P6-T1] to [P6-T11] in order. If any task fails, or [P6-T1] or [P6-T2] rewrites any file, apply the fix (a rewritten or fixed canonical hook requires rerunning its copy task: [P2-T10], [P3-T11], [P3-T12], or [P4-T10] to [P4-T12]), then commit and push the fix per rule 14 (paths: each fixed file, its copy targets, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`; subject `fix(927): final QC loop pass <n> corrections`), and only then restart at [P6-T1]. Each pass writes new artifacts with new write-time stamps. The loop ends only when one pass completes [P6-T1] to [P6-T11] with no failure and no file change; [P6-T13] records that pass. Type checking does not apply to PowerShell.

- [x] [P6-T1] Write `FEATURE/evidence/qa-gates/p6-poshqc-format.<timestamp>.md` (QC step 1, formatting; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: the MCP disposition is `returned`; both status commands print nothing, meaning the formatter rewrote no PowerShell file in this pass (AC-18 and AC-M23 format half).
- [x] [P6-T2] Write `FEATURE/evidence/qa-gates/p6-poshqc-analyze.<timestamp>.md` (QC step 2, linting). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`, matching the [P0-T8] baseline disposition; the status command prints nothing (MCP route compliance only; the analyzer half of AC-18 and AC-M23 is verified at [P8-T2]).
- [x] [P6-T3] Write `FEATURE/evidence/qa-gates/p6-pester.<timestamp>.md` (QC step 3, tests). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J14. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `34`, `19`, and `9`; J4 equals `FAM_BASE + 11`; J7 prints `1` for every token of Appendix R; J10 prints `30`, `36`, `14`, `32`, and `9`; J11 prints `0` for all five suites; J12 prints `0`; every J13 count is greater than 0; J14 prints `1` and `1`; the J2 failures value equals `FAIL_BASE`; every J3 line is a `B_FAILED` line from [P0-T9] (AC-M1 to AC-M18 test halves, AC-M23 test half, AC-1 to AC-6, AC-8 test half, AC-10 test half, AC-18 test half). Coverage is not read from this run (rule 3); the `Output Summary:` names [P8-T3] as the coverage source.
- [x] [P6-T4] Write `FEATURE/evidence/qa-gates/p6-mirror-parity.<timestamp>.md` (AC-12, AC-M2, AC-M19). Commands: `cmp -s` for each of these pairs: the five canonical/mirror pairs of [P0-T6]; `.claude/hooks/hook-docs-only-diff.ps1` against each of the three other helper paths of Appendix D; then `git hash-object` on all fourteen files. Acceptance: all eight `cmp -s` calls exit 0; each pair's hashes are equal; the five canonical hashes differ from their [P0-T6] values.
- [x] [P6-T5] Write `FEATURE/evidence/qa-gates/p6-pytest-contracts.<timestamp>.md` (AC-12, AC-M19, AC-M20). Command: the [P0-T10] pytest command, unchanged. Acceptance: exit 0 and the final summary line reports `passed` with no `failed` or `error` count.
- [x] [P6-T6] Write `FEATURE/evidence/qa-gates/p6-jest-manifest.<timestamp>.md` (AC-M20). Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Acceptance: exit 0 and the `Tests:` summary line contains `passed` and does not contain `failed`.
- [x] [P6-T7] Write `FEATURE/evidence/qa-gates/p6-line-counts.<timestamp>.md` (AC-20, AC-M22). Commands: `grep -c '^'` on the ten canonical and mirror hook files of [P0-T6], on the four helper paths, on the three DocsOnly suites, on suites A to E, and on the eight Appendix K suites. Acceptance: the docs-only hook and mirror print `224`, the pr-author hook and mirror print `359`, the Claude gate and mirror print `490`, the resolution sibling and mirror print `278`, the Codex gate and mirror print `410`; every other printed count is less than `500`; all values are recorded.
- [x] [P6-T8] Write `FEATURE/evidence/qa-gates/p6-test-purity.<timestamp>.md` (AC-8 text half). Command: the [P1-T8] grep command with suites A, B, and D appended to its file list. Acceptance: the eight printed counts are each `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [x] [P6-T9] Write `FEATURE/evidence/qa-gates/p6-source-tokens.<timestamp>.md` (AC-5, AC-6, AC-7, AC-11, AC-M2, AC-M10, AC-M14, AC-M17, AC-M21 source halves). Commands: every grep of the acceptance conditions of [P2-T1], [P2-T9], [P3-T1] to [P3-T9], [P4-T1] to [P4-T9], [P4-T13], and [P4-T14], rerun unchanged against the current tree. Acceptance: every count and printed line equals the value its task states.
- [x] [P6-T10] Write `FEATURE/evidence/qa-gates/p6-cr3-pin.<timestamp>.md` (AC-10 source half and decision D4). Commands: `git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `git diff --numstat origin/main...HEAD -- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`; `git status --porcelain`. Acceptance: in the first diff, no removed or added line contains `'--no-ext-diff'` (with its single quotes, as written in the `-GitArgs` array) and no removed or added line contains `($commit + '...HEAD')`; in the numstat output the deletions column is `0` for the Exemption and Decision suites and at most `98` for the DocsOnly suite; every status line either names this plan file or begins with `?? docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/p6-`.
- [x] [P6-T11] Write `FEATURE/evidence/qa-gates/p6-scope.<timestamp>.md` (AC-22, AC-M17 helpers half, AC-M20 path-only half, AC-M21 diff half, AC-M25 diff half). Commands: `git status --porcelain`; `git diff --name-only origin/main...HEAD`; `git diff --numstat origin/main...HEAD -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. Acceptance: every path listed by the name diff is either under `FEATURE/` or a member of section 9 (`## WRITES`); no listed path contains `hook-command-invocation`, ends with `enforce-pr-author-skill-helpers.ps1`, ends with `enforce-epic-merge-gate-authorization.ps1`, begins with `.claude/rules/`, or begins with `docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901/`; every listed path beginning with `.codex/` is `.codex/hooks/enforce-epic-merge-gate.ps1` or `.codex/hooks/hook-docs-only-diff.ps1`; every listed path ending with `pack-manifests/core.json` is one of the two manifests named in section 9; each manifest numstat line begins with `1` then a tab then `0`; every status line either names this plan file or begins with `?? docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/p6-`.
- [x] [P6-T12] Write `FEATURE/evidence/qa-gates/p6-coverage-pending-ci.<timestamp>.md` (final-QC coverage record). Command recorded: `Coverage source per rule R-COV: CI artifact poshqc-test-results of job poshqc / PowerShell QC (pending PR)`; `EXIT_CODE: 0`. Content: the [P0-T12] baseline `COVERAGE_RESULT:` lines (or `BASELINE_COVERAGE: UNAVAILABLE`); `COVERAGE_STATUS: PENDING_CI`; the post-change statement lines for AC-9 derived now by rule R-COV step C2 and recorded as `AC9_LINES: <n>,<n>,<n>,<n>`; the changed-line lists derived now by rule R-COV step C3 for the five edited canonical hook files, each recorded as `CHANGED_LINES <path>: <list>`. Acceptance: the artifact carries numeric baseline values or the authorized `UNAVAILABLE` marker, `COVERAGE_STATUS: PENDING_CI`, an `AC9_LINES:` value of four line numbers (`78,79,82,84` when Appendix H is applied verbatim), and five `CHANGED_LINES` lines.
- [x] [P6-T13] Write `FEATURE/evidence/qa-gates/p6-loop-record.<timestamp>.md`. Command recorded: `Final QC loop per Phase 6 restart rule`. Acceptance: the artifact lists each pass as `LOOP_PASS: <n> RESULT: <clean|restarted at P6-T1 because ...>`, and its last pass is `clean` with the artifact names of [P6-T1] to [P6-T11] from that pass.

### Phase 7 — Acceptance Criteria Verification and Check-off

- [x] [P7-T1] Write `FEATURE/evidence/qa-gates/p7-ac-verification.<timestamp>.md`. Command recorded: `AC verification against Phase 0 to Phase 6 evidence`; `EXIT_CODE: 0`. Content: one line per AC, `AC-<id>: VERIFIED <artifact names>` for AC-M1 to AC-M22, AC-M25, AC-1 to AC-8, AC-10 to AC-17, AC-20, and AC-22, and `AC-<id>: PENDING_CI <job name>` for AC-9, AC-18, AC-21, AC-M23, and AC-M24 (`poshqc / PowerShell QC`; for AC-18 and AC-M23 the lines read `AC-18: PENDING_CI poshqc / PowerShell QC` and `AC-M23: PENDING_CI poshqc / PowerShell QC`) and AC-19 (`poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`). Acceptance: `grep -c -E '^AC-M?[0-9]+: VERIFIED '` on the artifact prints `41` and `grep -c -E '^AC-M?[0-9]+: PENDING_CI '` on it prints `6`. When [P5-T1] stopped Phase 5, AC-13 to AC-17 are recorded as `BLOCKED` instead and this task fails.
- [x] [P7-T2] Check off AC-M1 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M1 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T3] Check off AC-M2 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M2 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T4] Check off AC-M3 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M3 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T5] Check off AC-M4 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M4 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T6] Check off AC-M5 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M5 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T7] Check off AC-M6 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M6 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T8] Check off AC-M7 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M7 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T9] Check off AC-M8 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M8 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T10] Check off AC-M9 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M9 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T11] Check off AC-M10 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M10 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T12] Check off AC-M11 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M11 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T13] Check off AC-M12 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M12 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T14] Check off AC-M13 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M13 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T15] Check off AC-M14 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M14 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T16] Check off AC-M15 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M15 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T17] Check off AC-M16 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M16 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T18] Check off AC-M17 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M17 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T19] Check off AC-M18 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M18 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T20] Check off AC-M19 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M19 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T21] Check off AC-M20 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M20 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T22] Check off AC-M21 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M21 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T23] Check off AC-M22 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M22 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T24] Confirm AC-M23 stays unchecked pending CI (its analyzer half is verified at [P8-T2] and checked off at [P8-T10]). Acceptance: `grep -c -F -e '- [ ] AC-M23 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T25] Check off AC-M25 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-M25 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T26] Check off AC-1 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-1 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T27] Check off AC-2 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-2 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T28] Check off AC-3 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-3 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T29] Check off AC-4 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-4 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T30] Check off AC-5 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-5 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T31] Check off AC-6 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-6 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T32] Check off AC-7 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-7 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T33] Check off AC-8 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-8 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T34] Check off AC-10 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-10 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T35] Check off AC-11 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-11 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T36] Check off AC-12 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-12 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T37] Check off AC-13 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-13 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T38] Check off AC-14 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-14 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T39] Check off AC-15 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-15 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T40] Check off AC-16 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-16 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T41] Check off AC-17 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-17 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T42] Confirm AC-18 stays unchecked pending CI (its analyzer half is verified at [P8-T2] and checked off at [P8-T9]). Acceptance: `grep -c -F -e '- [ ] AC-18 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T43] Check off AC-20 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-20 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T44] Check off AC-22 in `FEATURE/spec.md`. Acceptance: `grep -c -F -e '- [x] AC-22 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P7-T45] Write `FEATURE/evidence/qa-gates/p7-ac-state.<timestamp>.md`. Commands: `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`. Acceptance: the counts print `41` and `6`.
- [x] [P7-T46] Commit and push Phase 7 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record final QC and acceptance-criteria evidence`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal. The executor run ends after this task with AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 pending-CI.

### Phase 8 — S9 CI Quality Gate Verification

Phase 8 is executed by the item's orchestrator run at S9, after the pull request for `bug/pr-author-docs-only-exemption-hardening-927` exists. When [P8-T1] finds no open pull request, the run records `CI_STATUS: PENDING_PR` and stops without failing; the remaining Phase 8 tasks stay unchecked.

- [x] [P8-T1] Write `FEATURE/evidence/qa-gates/p8-ci-run.<timestamp>.md`. Commands: `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state open --json number,headRefOid`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --json databaseId,event,status,conclusion,headSha --limit 10`. Acceptance: one open pull request whose `headRefOid` equals the branch head; the newest listed run with `event` `pull_request` and `headSha` equal to that head is recorded as `HEAD_CI_RUN_ID:`. When none exists yet, the run records `CI_STATUS: NOT_STARTED` and reruns this task later.
- [x] [P8-T2] Write `FEATURE/evidence/qa-gates/p8-ci-jobs.<timestamp>.md` (AC-19; AC-18 and AC-M23 analyzer half). Commands: `gh run watch <HEAD_CI_RUN_ID> --interval 60`; `gh run view <HEAD_CI_RUN_ID> --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`; `gh run view <HEAD_CI_RUN_ID> --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'`. Acceptance: the job `poshqc / PowerShell QC` and the job `poshqc / PowerShell hook suites (Linux)` each report `success`; both rows are recorded verbatim; among the rows whose first field is `poshqc / PowerShell QC`, the rows for steps `Format PowerShell` and `Analyze PowerShell` (`.github/workflows/_poshqc.yml` lines 22 and 32) each read `success` and are recorded verbatim (AC-18 and AC-M23 analyzer half). A failure is recorded with the failing step name and the item returns to remediation.
- [x] [P8-T3] Write `FEATURE/evidence/qa-gates/p8-ci-coverage.<timestamp>.md` (AC-9, AC-21, AC-M24). Commands: `gh run download <HEAD_CI_RUN_ID> -n poshqc-test-results -D SCRATCH/927/ci-head/<HEAD_CI_RUN_ID>`; rule R-COV step C1 with the `AC9_LINES` and `CHANGED_LINES` values re-derived by steps C2 and C3 at the PR head. Acceptance: the reader exits 0; `COVERAGE_RESULT:` for `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and `.claude/hooks/enforce-pr-author-skill.ps1` each shows `result=PASS` (AC-21); `COVERAGE_RESULT:` for `.claude/hooks/hook-docs-only-diff.ps1` and `.codex/hooks/hook-docs-only-diff.ps1` each shows `result=PASS` (AC-M24); each of the four `AC9_LINES` statements prints `LINE_RESULT:` with `ci` greater than `0` (AC-9); every `CHANGED_LINES` entry of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1` prints either `NOT_EXECUTABLE_OR_ABSENT` or `ci` greater than `0`, except the Codex gate entry-point statement that begins `$decision = Invoke-CodexEpicMergeDecision -PayloadRaw`, which may print `ci=0` and is then recorded as `UNCOVERED_CHANGED_LINE:` with the AC-M24 reason (AC-M24, spec revision 1.3); the run ID, line numbers, and counters are recorded.
- [x] [P8-T4] Write `FEATURE/evidence/qa-gates/p8-coverage-delta.<timestamp>.md`. Command recorded: `Coverage delta from p0-ci-coverage-baseline and p8-ci-coverage`. Content: baseline and post-change `covered`, `missed`, and `line_pct` for the five files of [P0-T12], post-change values for the two helper copies, and the changed-line coverage `covered changed lines / executable changed lines` for each of the five edited canonical hook files from the [P8-T3] results. Acceptance: post-change line coverage of each of the five files is at least its baseline value or at least 85%, and each file's changed-line coverage is at least 85%; when the baseline is `UNAVAILABLE`, the artifact states `COVERAGE_DELTA: REMEDIATION_REQUIRED` and this task fails. A file whose requested changed lines all report `NOT_EXECUTABLE_OR_ABSENT` records `CHANGED_LINE_COVERAGE: N/A (0 executable changed lines)` and meets the changed-line condition.
- [x] [P8-T5] Check off AC-9 in `FEATURE/spec.md` (evidence [P8-T3]). Acceptance: `grep -c -F -e '- [x] AC-9 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T6] Check off AC-19 in `FEATURE/spec.md` (evidence [P8-T2]). Acceptance: `grep -c -F -e '- [x] AC-19 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T7] Check off AC-21 in `FEATURE/spec.md` (evidence [P8-T3], [P8-T4]). Acceptance: `grep -c -F -e '- [x] AC-21 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T8] Check off AC-M24 in `FEATURE/spec.md` (evidence [P8-T3], [P8-T4]). Acceptance: `grep -c -F -e '- [x] AC-M24 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T9] Check off AC-18 in `FEATURE/spec.md` (evidence [P6-T1], [P6-T3], [P8-T2]). Acceptance: `grep -c -F -e '- [x] AC-18 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T10] Check off AC-M23 in `FEATURE/spec.md` (evidence [P6-T1], [P6-T3], [P8-T2]). Acceptance: `grep -c -F -e '- [x] AC-M23 (' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P8-T11] Commit and push Phase 8 (rule 14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record CI coverage and job evidence`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal; `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `47`. After the push, the item's orchestrator run re-runs the S9 CI green gate: `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --json databaseId,event,conclusion,headSha --limit 10` lists a `pull_request` run whose `headSha` equals the output of `git rev-parse HEAD` with conclusion `success`; the run ID and head are recorded in the orchestrator checkpoint `ci_gate` (not in a repository file).

---

## 5. Rule R-JUNIT (reading the Pester JUnit file)

The PoshQC test run writes `artifacts/pester/pester-junit.xml` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 15, `TestResult.OutputPath`). Observed shape (recorded in `docs/features/completed/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/regression-testing/junit-task-post.xml`): one `<testsuites ...>` element with `tests`, `failures`, and `errors` attributes, and one `<testcase name="<Describe>.<Context>.<It>" status="Passed|Failed|Skipped" classname="<absolute suite path>" .../>` line per test case. The classname separator is host-dependent, so suite patterns below match it with `.`.

- **J0** before the MCP call: `stat -c %Y artifacts/pester/pester-junit.xml`; record `JUNIT_MTIME_BEFORE:` or `JUNIT_MTIME_BEFORE: absent` when `stat` exits non-zero.
- **J1** after the call: `stat -c %Y artifacts/pester/pester-junit.xml` exits 0 and prints a value greater than `JUNIT_MTIME_BEFORE` (any value when it was `absent`); record `JUNIT_MTIME_AFTER:`. Otherwise the file was not rewritten by this run and the task fails.
- **J2** `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; record only the `tests`, `failures`, and `errors` values.
- **J3** `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`; record each printed line (no output means no failed case).
- **J4** `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count.
- **J5** `grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count.
- **J6** passed count per DocsOnly suite, in this order: `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill\.DocsOnly\.Tests\.ps1"' artifacts/pester/pester-junit.xml`, then the same with `DocsOnly\.Exemption\.Tests\.ps1` and `DocsOnly\.Decision\.Tests\.ps1`. A zero count for any suite is a failure.
- **J7** for each token of Appendix R: `grep -c -F -e '<token>" status="Passed"' artifacts/pester/pester-junit.xml` with the token substituted; each must print `1`. A `0` (renamed, missing, failed, or skipped row) is a failure.
- **J8** failed count per DocsOnly suite, in the J6 order, with `status="Failed"` in place of `status="Passed"`.
- **J9** for each Appendix R token marked `expect-fail` and each Appendix R2 token: `grep -c -F -e '<token>" status="Failed"' artifacts/pester/pester-junit.xml` with the token substituted; each must print `1`.
- **J10** passed count per new suite, in the order A, B, C, D, E: `grep -c -E 'status="Passed" classname="[^"]*claude-hooks.hook-docs-only-diff\.Tests\.ps1"' artifacts/pester/pester-junit.xml`; the same with `hook-docs-only-diff\.MergeExemption\.Tests\.ps1"`, `enforce-epic-merge-gate\.DocsOnly\.Tests\.ps1"`, `codex-hooks.hook-docs-only-diff\.Tests\.ps1"`, and `enforce-epic-merge-gate-docs-only\.Tests\.ps1"` in place of the first suite pattern.
- **J11** failed count per new suite, in the J10 order, with `status="Failed"` in place of `status="Passed"`.
- **J12** merge-family failed count: `grep -c -E 'status="Failed" classname="[^"]*(enforce-epic-merge-gate|epic-execution-gates|hook-command-parser\.AcceptanceCases|hook-command-consumers\.Issue824|hook-dependency-failure\.SpecialCases|hook-dependency-guard-completeness|hook-import-failure-exemptions\.Guard)' artifacts/pester/pester-junit.xml`; record the count.
- **J13** passed count per named existing suite (each must be greater than 0): one `grep -c -E 'status="Passed" classname="[^"]*<suite pattern>"' artifacts/pester/pester-junit.xml` per pattern, with these patterns: `enforce-epic-merge-gate\.Tests\.ps1`, `enforce-epic-merge-gate\.Authorization\.Tests\.ps1`, `enforce-epic-merge-gate\.ItemResolution\.Tests\.ps1`, `enforce-epic-merge-gate\.WorktreeResolution\.Tests\.ps1`, `enforce-epic-merge-gate\.TriggerScoping\.Tests\.ps1`, `enforce-epic-merge-gate\.Coverage\.Tests\.ps1`, `hook-command-parser\.AcceptanceCases\.Tests\.ps1`, `hook-command-consumers\.Issue824\.Tests\.ps1`, `enforce-epic-merge-gate-authorization\.Tests\.ps1`, `enforce-epic-merge-gate-decision-surface\.Tests\.ps1`, `enforce-epic-merge-gate-trigger-scoping\.Tests\.ps1`, `epic-execution-gates\.Tests\.ps1`, `hook-dependency-failure\.SpecialCases\.Tests\.ps1`, `hook-dependency-guard-completeness\.Tests\.ps1`, `hook-import-failure-exemptions\.Guard\.Tests\.ps1`.
- **J14** structural-guard rows of rule 15 (a), in this order: `grep -c -F -e 'across the guarded tree" status="Passed"' artifacts/pester/pester-junit.xml`; `grep -c -F -e 'ships an empty allowlist" status="Passed"' artifacts/pester/pester-junit.xml`. Each must print `1`. The tokens are the tails of the `testcase name` values of the rows `reports no Python invocation beyond the allowlist across the guarded tree` and `ships an empty allowlist` of `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (lines 62 and 433); no other test name in the tree ends with either tail.

## 6. Rule R-COV (reading the CI coverage XML)

- **C1** `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <xml> .claude/hooks/enforce-pr-author-skill.docs-only.ps1:<AC9_LINES>,<docs-only CHANGED_LINES> .claude/hooks/enforce-pr-author-skill.ps1:<pr-author CHANGED_LINES> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1:<gate CHANGED_LINES> .claude/hooks/enforce-epic-merge-gate-resolution.ps1:<resolution CHANGED_LINES> .codex/hooks/enforce-epic-merge-gate.ps1:<Codex gate CHANGED_LINES>`, where `<xml>` is `powershell-coverage.xml` inside the download directory. The reader prints one `COVERAGE_RESULT:` line per file and one `LINE_RESULT:` line per requested line number (Appendix S).
- **C2** `AC9_LINES` derivation (fixed): `grep -n -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e '$code = $LASTEXITCODE' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e 'return $failure' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` (take the larger of the two printed line numbers: the catch-block return); `grep -n -F -e 'ExitCode = [int]$code' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`. With Appendix H applied verbatim the four numbers are `78`, `79`, `82`, and `84`.
- **C3** `CHANGED_LINES` derivation (fixed), per edited canonical hook file (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`): `git diff -U0 origin/main...HEAD -- <file>`; for each hunk header `@@ -a,b +c,d @@` (or `+c` meaning `d = 1`) with `d > 0`, the lines `c` to `c + d - 1`. A requested line that the reader reports as `NOT_EXECUTABLE_OR_ABSENT` is a comment or non-statement line and is excluded from the changed-line denominator. The two helper copies are new files and are measured by whole-file line coverage.

## 7. Appendix H — edits to `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`

Line numbers refer to the file as it stands at [P0-T6] (265 lines). Each edit is applied with Edit using the quoted whole lines as `old_string`.

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

**H3 - residual limit.** Directly after the line `    configuration cannot change the listing.` (line 24) insert

```text

    Residual limit: a GH_REPO value exported by an earlier shell command or inherited from the
    session environment is not visible in the command text, so this file cannot detect it.
```

**H11 - `.NOTES` sentence.** Directly after the line `    byte-identically under extensions/drm-copilot/resources/claude-customizations/.` (line 31) insert

```text
    Dot-sources hook-docs-only-diff.ps1 (issue #927), whose Get-DocsOnlyDiffTextViolation
    performs the E5 NUL check and the E6 and E7 path classification.
```

**H12 - helper dot-source.** Directly after the line `param()` (line 34) insert the single line

```powershell
. (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1')
```

The dot-source is unguarded, matching `.claude/hooks/enforce-pr-author-skill-helpers.ps1` line 58, which loads this file unguarded; both are covered by the guarded edge at `.claude/hooks/enforce-pr-author-skill.ps1` line 190 (addendum section 3.3).

**H4 - seam help (revised in 2.1).** Directly after the two lines `    .PARAMETER GitArgs` and `        The git arguments that follow -C <root>.` insert

```text
    .PARAMETER GitInvoker
        The scriptblock that runs git; a unit test passes a test-local stand-in so that this
        body runs without starting a process.
```

**H5 - seam parameter (revised in 2.1).** Replace the line `        [Parameter(Mandatory)][string[]] $GitArgs` (inside `Invoke-PrAuthorDocsOnlyGitExe`) with

```powershell
        [Parameter(Mandatory)][string[]] $GitArgs,
        [ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }
```

**H6 - capture statement (revised in 2.1).** Replace the line `        $lines = @(& git -C $WorktreeRoot @GitArgs 2>$null)` with

```powershell
        $lines = @(& $GitInvoker -C $WorktreeRoot @GitArgs 2>$null)
```

After H4-H6 the only `&`-invoked variable in the file is `$GitInvoker`, a `[scriptblock]` parameter of the same file, and the H12 dot-source is the inline sibling form, so the file satisfies rule 15 (a). Before H6 the capture statement is the constant command `& git -C`, which the guard accepts; after H6 the word `git` appears as a command only inside the default scriptblock, again a constant command.

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

**H10 - shared NUL guard and classification.** Replace the line `    $violation = Get-PrAuthorDocsOnlyPathViolation -Path @(ConvertFrom-PrAuthorDocsOnlyNameList -Text ([string]$diff.Output))` (line 260) with

```powershell
    $violation = Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base
```

**H13 - remove the relocated pure functions.** Remove the contiguous block that begins with the line `function ConvertFrom-PrAuthorDocsOnlyNameList {` (line 141) and ends with the blank line that follows the closing `}` of `Get-PrAuthorDocsOnlyPathViolation` (line 199), so that the blank line 140 is directly followed by `function Get-PrAuthorDocsOnlyExemption {`. These two functions now exist in the helper under the names `ConvertFrom-DocsOnlyNameList` and `Get-DocsOnlyPathViolation` with unchanged bodies (Appendix D).

Net line change: H1 +3, H2 +1, H3 +3, H11 +2, H12 +1, H4 +3, H5 +1, H6 0, H7 +1, H8 +3, H9 0, H10 0, H13 -59; total -41, so the post-edit file is 224 lines. The four AC-9 statements move from lines 64, 65, 68, and 70 to 78, 79, 82, and 84 (H1, H2, H3, H11, H12, H4, and H5 precede them: +14).

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

Every repository file this plan creates or edits outside `FEATURE`. Nothing is deleted. Created files are marked (create); every other entry is an edit.

Production hook files (Write or Edit; rule 10):

1. `.claude/hooks/hook-docs-only-diff.ps1` (create; [P2-T1]; rewritten by [P2-T9])
2. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` ([P3-T1] to [P3-T8])
3. `.claude/hooks/enforce-pr-author-skill.ps1` ([P3-T9], header comment only)
4. `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` ([P4-T1])
5. `.claude/hooks/enforce-epic-merge-gate.ps1` ([P4-T2] to [P4-T4])
6. `.codex/hooks/enforce-epic-merge-gate.ps1` ([P4-T5] to [P4-T9])

Helper copies and bundled mirrors (`cp` only, rule 9):

7. `.codex/hooks/hook-docs-only-diff.ps1` (create; [P2-T2]; re-copied by [P2-T10])
8. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1` (create; [P2-T3]; re-copied by [P2-T10])
9. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (create; [P2-T4]; re-copied by [P2-T10])
10. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` ([P3-T11])
11. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` ([P3-T12])
12. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` ([P4-T10])
13. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1` ([P4-T11])
14. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` ([P4-T12])

Pack manifests (Edit, one path line added each):

15. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` ([P4-T13])
16. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` ([P4-T14])

New test suites (Write):

17. `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (create; suite C; [P1-T5])
18. `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (create; suite E; [P1-T6])
19. `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (create; suite A; [P2-T6]; edited by [P2-T12])
20. `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (create; suite B; [P2-T7])
21. `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (create; suite D; [P2-T8]; edited by [P2-T13])

Existing test suites (Edit):

22. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` ([P1-T1], [P1-T2], [P2-T14], [P3-T10])
23. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` ([P1-T3], insertion only)
24. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` ([P1-T4], insertion only)
25. `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` ([P4-T16])
26. `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` ([P4-T17])
27. `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` ([P4-T18])
28. `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` ([P4-T19])
29. `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` ([P4-T20])
30. `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1` ([P4-T21])
31. `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` ([P4-T22])
32. `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` ([P4-T23])

#901 record (Edit, no rename; active path only, D11):

33. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` ([P5-T19])
34. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md` ([P5-T4])
35. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` ([P5-T5])
36. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` ([P5-T6])
37. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` ([P5-T7], [P5-T17], [P5-T18])
38. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` ([P5-T8])
39. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` ([P5-T9])
40. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` ([P5-T10])
41. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md` ([P5-T11])
42. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` ([P5-T12])
43. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` ([P5-T13])
44. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` ([P5-T14])
45. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` ([P5-T15])
46. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` ([P5-T16])

Inside `FEATURE` (not counted above): this plan file (checkbox state only during execution), `spec.md` (AC checkboxes only during execution; the version 1.2 wording revision of AC-7, AC-8, AC-9, AC-M4 and the matching design lines was made by the planner with this plan revision 2.1, before execution resumes), and the evidence artifacts each task names.

Outside the repository: `SCRATCH/927/tools/read_coverage_927.py`, `SCRATCH/927/ci-base/`, `SCRATCH/927/ci-head/` (never committed, never deleted). Git-ignored `extensions/drm-copilot/node_modules` may be populated by the authorized branch of [P0-T11].

Never written: `.claude/hooks/enforce-pr-author-skill-helpers.ps1` and its mirror; every `hook-command-invocation*.ps1` file in every tree; `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` and its mirror (the design does not require a guidance change); `.claude/settings.json`; `.codex/config.toml`; anything under `.claude/rules/`, `.github/`, or `docs/features/archive/`; `F901/evidence/qa-gates/p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md`; every `F901/evidence/remediation-baseline/` file; the #927 `issue.md` and research artifacts.

## 10. Appendix T — create-side test text

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
            # Test-local stand-ins for the git executable, passed as scriptblocks to the seam's
            # GitInvoker parameter, so the seam body runs without starting a process.
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
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitEcho}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly $expected -Because 'the seam passes -C, the root, then the arguments'
            $result.Output.EndsWith([char]0) | Should -BeTrue -Because 'NUL-terminated output is preserved'
        }

        It 'joins multi-line output with a line feed' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitMultiLine}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly "docs/a.md`ndocs/b.md"
        }

        It 'returns the non-zero exit code of the injected command' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitExit128}

            # Assert
            $result.ExitCode | Should -Be 128
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object when the injected command throws' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }
    }
```

**T2 conversion edits (revision 2.1, [P2-T14]).** Block T2 was committed at `c87fc34a8` in its version 2.0 form. [P2-T14] converts it to the text above with these five Edit replacements, covering six lines, in `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`; no line is added or removed, and no other line changes:

- **T2-1** (two comment lines): `            # Test-local stand-ins for the git executable, passed by name to the seam's` and `            # GitCommand parameter, so the seam body runs without starting a process.` become `            # Test-local stand-ins for the git executable, passed as scriptblocks to the seam's` and `            # GitInvoker parameter, so the seam body runs without starting a process.`
- **T2-2**: in the line ending `-GitCommand 'Invoke-DocsOnlyFakeGitEcho'`, replace that ending with `-GitInvoker ${function:Invoke-DocsOnlyFakeGitEcho}`.
- **T2-3**: in the line ending `-GitCommand 'Invoke-DocsOnlyFakeGitMultiLine'`, replace that ending with `-GitInvoker ${function:Invoke-DocsOnlyFakeGitMultiLine}`.
- **T2-4**: in the line ending `-GitCommand 'Invoke-DocsOnlyFakeGitExit128'`, replace that ending with `-GitInvoker ${function:Invoke-DocsOnlyFakeGitExit128}`.
- **T2-5**: in the line ending `-GitCommand 'Invoke-DocsOnlyFakeGitThrow'`, replace that ending with `-GitInvoker ${function:Invoke-DocsOnlyFakeGitThrow}`.

The four fakes stay defined in the `Context` `BeforeAll`, which runs once before the rows of that `Context` in a parent scope of each `It`, so `${function:<name>}` resolves inside the `It` body. Rows S1 to S4 keep their names and assertions; they fail until [P3-T2] adds `-GitInvoker` to `Invoke-PrAuthorDocsOnlyGitExe` (parameter-binding failure, as decision D5 predicts for the version 2.0 form) and pass from [P3-T13].

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

**T5** — relocation removal in `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` ([P3-T10]). Remove the contiguous block from the line `    Context 'Get-PrAuthorDocsOnlyPathViolation' {` (line 35) through the blank line that follows the closing `    }` of `Context 'ConvertFrom-PrAuthorDocsOnlyNameList'` (line 128), so that the probe `It` line, its following blank line, and `    Context 'Get-PrAuthorDocsOnlyBaseName' {` become consecutive. Blocks T1 and T2 are inserted after this region, so the line numbers are unchanged when T5 runs. The removed rows exist in suite A (Appendix N block N-A) under the shared names.

**T6** — `.DESCRIPTION` of the same file ([P3-T10]). Replace the four lines 9-12 (beginning `    Exercises the pure helpers of enforce-pr-author-skill.docs-only.ps1 directly: the path-set` and ending `    deletes a file, starts a process, or runs the git executable.`) with

```text
    Exercises the helpers of enforce-pr-author-skill.docs-only.ps1 directly: the --base
    extraction, the checkpoint-presence seam, and the git seam (failure object and command
    injection). The path-set classifier and the NUL-list parser moved with their rows to
    hook-docs-only-diff.Tests.ps1 (issue #927). No row creates, writes, or deletes a file,
    starts a process, or runs the git executable.
```

## 11. Appendix R — create-side JUnit row tokens (J7, J9)

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
| V1 | DocsOnly | `rejects the -B short form` | no (pre-existing, AC-1) |
| V2 | Exemption | `denies an empty diff` | no (pre-existing, AC-6) |
| V3 | Exemption | `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` | no (pre-existing, AC-10) |

Because J7 and J9 append `" status="` to the token, `override long --repo` (R7) and `override long --repo=` (R8) match distinct rows. The new suites use distinct test names (Appendix R2 and N), so no Appendix R token matches a new-suite row.

## 12. Appendix R2 — merge-side expect-fail tokens (J9) and phase expectations

All 21 tokens below fail in [P1-T7], [P2-T16], and [P3-T13], and every token passes from [P4-T24] onward (decisions D5 and D9).

| ID | Suite | Token |
|---|---|---|
| C1 | C | `allows a docs-only merge with no checkpoint record (issue #927)` |
| C2 | C | `denies a non-docs diff with the docs-only reason after the standalone reasons (issue #927)` |
| C3 | C | `denies a failed gh lookup with the PR_UNRESOLVED docs-only reason (issue #927)` |
| C4 | C | `denies a -R override with the PR_UNRESOLVED docs-only reason and no process call (issue #927)` |
| C5 | C | `makes no docs-only call when the item target is SessionRoot (issue #927)` |
| C6 | C | `makes no docs-only call when the item target is OtherWorktree (issue #927)` |
| C7 | C | `makes no docs-only call when the epic target is Ambiguous (issue #927)` |
| C8 | C | `makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)` |
| C9 | C | `reports true for item NoTarget, epic NoTarget, parallel NoTarget (issue #927)` |
| C10 | C | `reports false for item Ambiguous, epic NoTarget, parallel NoTarget (issue #927)` |
| C11 | C | `reports false for item NoTarget, epic SessionRoot, parallel NoTarget (issue #927)` |
| C12 | C | `reports false for item NoTarget, epic NoTarget, parallel OtherWorktree (issue #927)` |
| C13 | C | `reports false for a bare command with no targets (issue #927)` |
| E1 | E | `allows a docs-only merge when no checkpoint is present (codex, issue #927)` |
| E2 | E | `appends the NON_DOCS_PATH docs-only reason to the standalone deny (codex, issue #927)` |
| E3 | E | `makes no docs-only call when the child checkpoint is present (codex, issue #927)` |
| E4 | E | `makes no docs-only call when the epic checkpoint is present (codex, issue #927)` |
| E5 | E | `denies a blank repository root with PR_UNRESOLVED and no process call (codex, issue #927)` |
| E6 | E | `denies a -R override with PR_UNRESOLVED and no process call (codex, issue #927)` |
| E7 | E | `denies a failed gh lookup with PR_UNRESOLVED (codex, issue #927)` |
| E8 | E | `keeps the bare-merge deny text unchanged (codex, issue #927)` |

Derivation: suites C and E reach `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and `Get-DocsOnlyMergeExemption` only through the gate they dot-source, which loads the helper from [P4-T2] (Claude) and [P4-T6] (Codex). Until then the guarded `BeforeAll` mocks do not register, so C1, C2, E1, and E2 fail on `Mock` of an undefined command; C3 to C8 fail on `Should -Invoke` of an unmocked command or on the missing appended text; C9 to C13 fail because `Test-EpicMergeGateNoRecordingTarget` does not exist before [P4-T1]; E3 to E8 fail on binding `-RepositoryRoot`, which the Codex gate declares only from [P4-T7]. A J9 value other than `1` for any token in [P1-T7] is a test-authoring defect corrected in test text only.

## 13. Appendix P — #901 evidence corrections

Each `EDIT` row replaces the file's first `Timestamp:` line (the `Line` column, re-verified against the current tree in this revision) with the five lines below, with `<HI>`, `<ORIGINAL>`, `<LO>`, and `<DERIVATION>` taken from the row and from `pa-n3-bounds` ([P5-T3]); nothing else in the file changes except where [P5-T17] and [P5-T18] apply:

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

**P4b** — replacement `Output Summary:` line for `p1-poshqc-direct-run.2026-10-12T19-50.md` ([P5-T18]):

```text
Output Summary: The run used the CI form from .github/workflows/_poshqc.yml lines 41-42. The process exit code of this run was not observed because the executing agent exited before the run completed; the observed exit code of the re-run is recorded in p1-poshqc-direct-run-rerun.2026-10-12T19-50.md. No figure was taken from console output.
```

**P-N2** — replacement lines under `## Evidence Checklist` in `F901/issue.md` ([P5-T19]):

```text
- [x] baseline (evidence/baseline/)
- [x] targeted verification (evidence/qa-gates/ and evidence/regression-testing/)
- [x] end-state (evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md and the PR #924 merge at e467c693)
```

## 14. Appendix S — `SCRATCH/927/tools/read_coverage_927.py`

Each argument after the XML path is `<directory>/<file name>[:<line>,<line>...]`, where `<directory>` is `.claude/hooks` or `.codex/hooks`. Bundle mirrors (`customizations` in the package path) are excluded.

```python
"""Issue 927 scratch helper: read JaCoCo LINE counters and per-line hits from a PoshQC coverage XML."""

import sys
import xml.etree.ElementTree as ET


def find_classes(root, directory, name):
    """Return (package, class) pairs for NAME under the canonical DIRECTORY package."""
    matches = []
    for package in root.iter("package"):
        package_name = package.get("name", "").replace("\\", "/")
        if not package_name.endswith(directory) or "customizations" in package_name:
            continue
        for cls in package.findall("class"):
            if cls.get("sourcefilename") == name:
                matches.append((package, cls))
    return matches


def report(root, spec):
    """Print the COVERAGE_RESULT and LINE_RESULT lines for one spec; return 0 or 1."""
    path, _, line_text = spec.partition(":")
    directory, _, name = path.rpartition("/")
    matches = find_classes(root, directory, name)
    if len(matches) != 1:
        print(f"COVERAGE_RESULT: {path} CLASS_COUNT={len(matches)}")
        return 1
    package, cls = matches[0]
    counters = [c for c in cls.findall("counter") if c.get("type") == "LINE"]
    if len(counters) != 1:
        print(f"COVERAGE_RESULT: {path} LINE_COUNTER_COUNT={len(counters)}")
        return 1
    covered = int(counters[0].get("covered"))
    missed = int(counters[0].get("missed"))
    total = covered + missed
    pct = round(100.0 * covered / total, 2) if total else 0.0
    verdict = "PASS" if total and 100 * covered >= 85 * total else "FAIL"
    print(f"COVERAGE_RESULT: {path} covered={covered} missed={missed} line_pct={pct} threshold=85.00 result={verdict}")
    sources = [s for s in package.findall("sourcefile") if s.get("name") == name]
    lines = {}
    if len(sources) == 1:
        lines = {line.get("nr"): line for line in sources[0].findall("line")}
    for number in [n for n in line_text.split(",") if n]:
        line = lines.get(number)
        if line is None:
            print(f"LINE_RESULT: {path} nr={number} NOT_EXECUTABLE_OR_ABSENT")
        else:
            print(f"LINE_RESULT: {path} nr={number} ci={line.get('ci')} mi={line.get('mi')}")
    return 0


def main(argv):
    """Print results for every spec; return 0 when every file is found exactly once."""
    if len(argv) < 3:
        print("USAGE: read_coverage_927.py XML DIR/NAME[:LINE,LINE...] [DIR/NAME...]")
        return 2
    root = ET.parse(argv[1]).getroot()
    status = 0
    for spec in argv[2:]:
        status = max(status, report(root, spec))
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

## 15. Appendix D — `hook-docs-only-diff.ps1` (four byte-identical paths)

Paths: `.claude/hooks/hook-docs-only-diff.ps1` (Write, [P2-T1]; rewritten to this revision 2.1 text by [P2-T9]); `.codex/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (`cp`, [P2-T2] to [P2-T4]; re-copied by [P2-T10]). Revision 2.1 changes twelve lines relative to the version 2.0 text written at [P2-T1], with no line added or removed (397 lines): the last two `.NOTES` lines (seam parameter names), the two `.SYNOPSIS` lines of the seams, the two `.PARAMETER` names and their description lines, the two parameter declarations (`[ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }` and `[ValidateNotNull()][scriptblock] $GhInvoker = { gh @args 2>$null }`), and the two capture statements (`& $GitInvoker -C $WorktreeRoot @GitArgs 2>$null` and `& $GhInvoker @GhArgs 2>$null`). The bodies of `ConvertFrom-DocsOnlyNameList` and `Get-DocsOnlyPathViolation` are the current bodies of `ConvertFrom-PrAuthorDocsOnlyNameList` and `Get-PrAuthorDocsOnlyPathViolation` (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1` lines 141-198) with only the function names changed.

```powershell
<#
.SYNOPSIS
    Docs-only diff classification and the merge-side docs-only exemption (issue #927).

.DESCRIPTION
    Shared by enforce-pr-author-skill.docs-only.ps1 (create side) and by the Claude and Codex
    copies of enforce-epic-merge-gate.ps1 (merge side). The file defines functions only: it
    imports nothing, dot-sources nothing, and has no entry point. At call time
    Get-DocsOnlyMergeExemption uses Read-CommandLineSegment, Test-CommandLineSegmentRawScan,
    Get-CommandLineStructuralMatch, Test-CommandLineFlag, and Get-CommandLineFlagValue from
    the command parsers every consumer already loads.

    Docs-only merge branch: a merge gate calls Get-DocsOnlyMergeExemption only for an explicit
    pull request number that no checkpoint records. The exemption fails closed; conditions
    are evaluated in order and the first failure returns its code:

      M1 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - a positive number; exactly one segment that is
                                               not wrapper-led, has no live substitution, and
                                               is balanced; a structural gh pr merge; no inline
                                               VAR= prefix token (GH_REPO=, GH_HOST=); no
                                               single-dash token containing R; no --repo or
                                               --repo= token; no --auto token.
      M2 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - the worktree root is an existing directory.
      M3 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - gh pr view <N> --json baseRefName,headRefOid
                                               exits 0 and returns a JSON object; headRefOid
                                               is 40 or 64 lowercase hex; a --match-head-commit
                                               value, when present, equals headRefOid (OD-2).
         DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED - baseRefName is a conservative branch spelling
                                               without '..'.
      M4 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED - refs/remotes/origin/<base> resolves to a commit.
      M5 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - headRefOid is present in the local repository.
      M6 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - git diff --name-only -z --no-renames --no-color
                                               --no-ext-diff --no-relative <base>...<head>
                                               exits 0.
      M7 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - non-empty diff output ends with NUL.
      M8 DOCS_ONLY_EXEMPTION_EMPTY_DIFF      - the diff lists at least one path.
      M9 DOCS_ONLY_EXEMPTION_NON_DOCS_PATH   - every listed path starts with docs/ (ordinal).

    No-fetch policy: no function here fetches or writes a ref. A missing origin/<base> ref or
    a head commit that is not present locally denies, and the M5 reason names the command
    the operator can run before retrying.

    Residual limits: a GH_REPO or GH_HOST value exported by an earlier shell command or
    inherited from the session environment is not visible in the command text; a push
    between the gh pr view lookup and the merge can change the head, which only
    --match-head-commit closes; the control is policy-level, not cryptographic.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors.
    git and gh run only through Invoke-DocsOnlyGitExe and Invoke-DocsOnlyGhExe, which never
    throw; unit tests pass a test-local scriptblock through -GitInvoker and -GhInvoker so
    the seam bodies run without starting a process.
#>

function ConvertFrom-DocsOnlyNameList {
    <#
    .SYNOPSIS
        Split NUL-separated git output into paths, discarding empty elements.
    .DESCRIPTION
        Callers wrap the result in @() so that an empty listing is an empty array. A path that
        contains a line feed stays one element, because only NUL separates entries.
    .PARAMETER Text
        The captured git output.
    .OUTPUTS
        System.String, one per path
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Text
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return
    }
    foreach ($entry in $Text.Split([char]0)) {
        if ($entry.Length -gt 0) {
            $entry
        }
    }
}

function Get-DocsOnlyPathViolation {
    <#
    .SYNOPSIS
        Return $null when every path is under docs/, else the denial sub-code text.
    .DESCRIPTION
        An empty set returns DOCS_ONLY_EXEMPTION_EMPTY_DIFF. Otherwise the first path that does
        not start with docs/ under ordinal comparison, or that is not longer than docs/ itself,
        returns DOCS_ONLY_EXEMPTION_NON_DOCS_PATH naming that path.
    .PARAMETER Path
        The changed paths, repository-relative, as git reports them.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyCollection()][string[]] $Path
    )

    $paths = @($Path | Where-Object { $null -ne $_ })
    if ($paths.Count -eq 0) {
        return 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF: the branch diff lists no path.'
    }
    foreach ($entry in $paths) {
        if ($entry.Length -le 5 -or -not $entry.StartsWith('docs/', [System.StringComparison]::Ordinal)) {
            return "DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: '$entry' is outside docs/."
        }
    }
    return $null
}

function Get-DocsOnlyDiffTextViolation {
    <#
    .SYNOPSIS
        Return $null when NUL-terminated diff output lists only docs/ paths, else the sub-code text.
    .DESCRIPTION
        Pure. Non-empty text that does not end with NUL returns DOCS_ONLY_EXEMPTION_DIFF_FAILED,
        because entries could otherwise run together into one path that starts with docs/.
        Otherwise the text is split on NUL and classified by Get-DocsOnlyPathViolation, so empty
        text reaches DOCS_ONLY_EXEMPTION_EMPTY_DIFF.
    .PARAMETER DiffText
        The captured output of git diff --name-only -z.
    .PARAMETER BaseName
        The base branch named in the denial text.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $DiffText,
        [AllowNull()][AllowEmptyString()][string] $BaseName
    )

    $text = [string]$DiffText
    if ($text.Length -gt 0 -and -not $text.EndsWith([char]0)) {
        return "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$BaseName did not return NUL-terminated output."
    }
    return (Get-DocsOnlyPathViolation -Path @(ConvertFrom-DocsOnlyNameList -Text $text))
}

function Invoke-DocsOnlyGitExe {
    <#
    .SYNOPSIS
        Run git -C <root> with the given arguments; the git seam of the merge exemption.
    .DESCRIPTION
        Never throws. A root that is not an existing directory returns ExitCode -1 without
        running the command, and so does a command that cannot start. Standard error is
        discarded so that it is never read as path data. Output lines are joined with a line
        feed.
    .PARAMETER WorktreeRoot
        The directory git runs in.
    .PARAMETER GitArgs
        The git arguments that follow -C <root>.
    .PARAMETER GitInvoker
        The scriptblock that runs git; a unit test passes a test-local stand-in instead.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][string[]] $GitArgs,
        [ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return $failure
    }
    try {
        $lines = @(& $GitInvoker -C $WorktreeRoot @GitArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Invoke-DocsOnlyGhExe {
    <#
    .SYNOPSIS
        Run gh with the given arguments inside a working root; the gh seam.
    .DESCRIPTION
        Never throws. gh has no -C option, so the seam pushes the working root and pops it in
        finally, restoring the caller's location after success and after a throw. A root that
        is not an existing directory returns ExitCode -1 without running the command.
        Standard error is discarded. Output lines are joined with a line feed.
    .PARAMETER WorkingRoot
        The directory gh runs in.
    .PARAMETER GhArgs
        The gh arguments.
    .PARAMETER GhInvoker
        The scriptblock that runs gh; a unit test passes a test-local stand-in instead.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorkingRoot,
        [Parameter(Mandatory)][string[]] $GhArgs,
        [ValidateNotNull()][scriptblock] $GhInvoker = { gh @args 2>$null }
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorkingRoot) -or -not (Test-Path -LiteralPath $WorkingRoot -PathType Container)) {
        return $failure
    }
    try {
        Push-Location -LiteralPath $WorkingRoot -ErrorAction Stop
    }
    catch {
        return $failure
    }
    try {
        $lines = @(& $GhInvoker @GhArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    finally {
        Pop-Location
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Get-DocsOnlyMergeShapeViolation {
    <#
    .SYNOPSIS
        Return $null when the merge command has the M1 shape, else the denial text.
    .DESCRIPTION
        Pure; runs before any process. See M1 in the file header.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER PrNumber
        The explicit pull request number the gate read, or $null.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $PrNumber
    )

    $prefix = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '
    if ($null -eq $PrNumber -or $PrNumber -le 0) {
        return $prefix + 'the command names no positive pull request number.'
    }
    $segments = @(Read-CommandLineSegment -CommandText $CommandText)
    if ($segments.Count -ne 1 -or (Test-CommandLineSegmentRawScan -Segment $segments[0])) {
        return $prefix + 'the command must be one gh pr merge segment with no chain, wrapper, or substitution.'
    }
    if ($null -eq (Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        return $prefix + 'the command is not a structural gh pr merge.'
    }
    foreach ($token in @($segments[0].Tokens)) {
        $text = [string]$token
        if ($text -cmatch '^[A-Za-z_][A-Za-z0-9_]*=') {
            return $prefix + "the inline environment prefix '$text' is not accepted."
        }
        if ($text.Length -ge 2 -and $text[0] -eq '-' -and $text[1] -ne '-' -and $text.Substring(1).Contains('R')) {
            return $prefix + "the repository override '$text' is not accepted."
        }
        if ($text -eq '--repo' -or $text.StartsWith('--repo=', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $prefix + "the repository override '$text' is not accepted."
        }
        if ($text -eq '--auto' -or $text.StartsWith('--auto=', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $prefix + 'auto-merge (--auto) is not eligible.'
        }
    }
    return $null
}

function Get-DocsOnlyPullRequestTarget {
    <#
    .SYNOPSIS
        Read the base branch and head commit of a pull request through the gh seam (M3).
    .DESCRIPTION
        Returns an object with Reason, Base, and Head. Reason is $null when the lookup
        succeeded and every M3 check passed; otherwise it carries the denial text.
    .PARAMETER CommandText
        The Bash command text, read for an optional --match-head-commit value.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Reason, Base, and Head.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][int] $PrNumber,
        [Parameter(Mandatory)][string] $WorktreeRoot
    )

    $unresolved = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '
    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'baseRefName,headRefOid')
    $pr = $null
    if ($null -ne $lookup -and $lookup.ExitCode -eq 0) {
        try {
            $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
        }
        catch {
            $pr = $null
        }
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) {
        return [pscustomobject]@{ Reason = $unresolved + "gh pr view $PrNumber did not return a readable pull request."; Base = $null; Head = $null }
    }
    $base = [string]$pr.baseRefName
    if ($base -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $base.Contains('..')) {
        return [pscustomobject]@{ Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: the base branch '$base' of pull request $PrNumber is not a conservative branch name."; Base = $null; Head = $null }
    }
    $head = [string]$pr.headRefOid
    if ($head -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [pscustomobject]@{ Reason = $unresolved + "the head commit of pull request $PrNumber is not a full lowercase object id."; Base = $null; Head = $null }
    }
    $subcommandPath = @('pr', 'merge')
    if (Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit') {
        $pinned = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit'
        if (-not [string]::Equals($pinned, $head, [System.StringComparison]::Ordinal)) {
            return [pscustomobject]@{ Reason = $unresolved + "--match-head-commit does not equal the head commit $head of pull request $PrNumber."; Base = $null; Head = $null }
        }
    }
    return [pscustomobject]@{ Reason = $null; Base = $base; Head = $head }
}

function Get-DocsOnlyMergeExemption {
    <#
    .SYNOPSIS
        Decide whether gh pr merge <N> --merge is exempt because the pull request changes only docs/.
    .DESCRIPTION
        Evaluates M1 to M9 of the file header in order and returns at the first failure. M1
        and M2 run before any process. Every seam failure denies.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER PrNumber
        The explicit pull request number the gate read from the command, or $null.
    .PARAMETER WorktreeRoot
        The directory gh and git run in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Exempt and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $shape = Get-DocsOnlyMergeShapeViolation -CommandText $CommandText -PrNumber $PrNumber
    if ($shape) {
        return [ordered]@{ Exempt = $false; Reason = $shape }
    }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the worktree root for the lookup is not an existing directory.' }
    }
    $target = Get-DocsOnlyPullRequestTarget -CommandText $CommandText -PrNumber ([int]$PrNumber) -WorktreeRoot $WorktreeRoot
    if ($target.Reason) {
        return [ordered]@{ Exempt = $false; Reason = $target.Reason }
    }
    $base = $target.Base
    $head = $target.Head

    $baseRev = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ('refs/remotes/origin/' + $base + '^{commit}'))
    $baseCommit = if ($null -ne $baseRev) { ([string]$baseRev.Output).Trim() } else { '' }
    if ($null -eq $baseRev -or $baseRev.ExitCode -ne 0 -or $baseCommit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: refs/remotes/origin/$base does not resolve to a commit in the worktree." }
    }

    $headRev = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ($head + '^{commit}'))
    $headCommit = if ($null -ne $headRev) { ([string]$headRev.Output).Trim() } else { '' }
    if ($null -eq $headRev -or $headRev.ExitCode -ne 0 -or -not [string]::Equals($headCommit, $head, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: the head commit $head of pull request $PrNumber is not present locally; run git fetch origin pull/$PrNumber/head, then retry. This hook does not fetch." }
    }

    $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($baseCommit + '...' + $head))
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base could not be computed." }
    }
    $violation = Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base
    if ($violation) {
        return [ordered]@{ Exempt = $false; Reason = $violation }
    }
    return [ordered]@{ Exempt = $true; Reason = $null }
}
```

## 16. Appendix G — Claude merge gate and resolution sibling

Line numbers refer to the files at [P0-T6] (`.claude/hooks/enforce-epic-merge-gate.ps1` 472 lines, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` 243 lines). Each edit uses the quoted whole lines as `old_string` or anchor.

**G1a - resolution header bullet.** In `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, directly after the line `      target nor either run branch resolves.` (line 26) insert

```text
    - Test-EpicMergeGateNoRecordingTarget, the precondition of the docs-only merge branch:
      the item, epic, and parallel targets all resolve NoTarget (issue #927).
```

**G1b - new function.** Append to the end of the same file (after the closing `}` of `Get-EpicMergeGateUnresolvedReason`, line 243) one blank line followed by

```powershell
function Test-EpicMergeGateNoRecordingTarget {
    <#
    .SYNOPSIS
        True only when the item, epic, and parallel targets all have status NoTarget (issue #927).
    .DESCRIPTION
        Pure. That combination means no checkpoint records the command's pull request number,
        which is the only case the docs-only merge branch evaluates. A $null target (a bare
        command), an Ambiguous target, and any resolved target return $false.
    .PARAMETER ItemTarget
        The item target, or $null.
    .PARAMETER EpicTarget
        The epic run target, or $null.
    .PARAMETER ParallelTarget
        The parallel run target, or $null.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] $ItemTarget,
        [AllowNull()] $EpicTarget,
        [AllowNull()] $ParallelTarget
    )

    foreach ($target in @($ItemTarget, $EpicTarget, $ParallelTarget)) {
        if ($null -eq $target -or [string]$target.Status -cne 'NoTarget') {
            return $false
        }
    }
    return $true
}
```

Net: G1a +2, G1b +33 (one blank line and 32 function lines); total 278.

**G2 - guarded dot-source.** In `.claude/hooks/enforce-epic-merge-gate.ps1`, directly after the line beginning `try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-resolution.ps1') }` (line 72) insert

```powershell
# Shared docs-only diff classification and the merge-side docs-only exemption (issue #927).
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }
```

**G3 - docs-only branch.** Replace the five lines 408-412

```powershell
        # When neither the item target nor a run branch resolved, the reason code and the
        # three details precede the standalone reason (issue #850).
        $unresolved = Get-EpicMergeGateUnresolvedReason -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget
        $prefix = if ($unresolved) { $unresolved + '; ' } else { '' }
        return Get-EpicMergeGateBlockDecision -Reason ('EPIC_MERGE_GATE_BLOCKED: ' + $prefix + $standalone.ReasonCode + ': ' + $standalone.Message)
```

with

```powershell
        # Docs-only branch (issue #927): evaluated only when no checkpoint records the PR.
        $docsOnlySuffix = ''
        if (Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget) {
            $docsOnly = Get-DocsOnlyMergeExemption -CommandText $commandText -PrNumber $commandPrNumber -WorktreeRoot $sessionRoot
            if ($docsOnly.Exempt) {
                return Get-EpicMergeGateAllowDecision
            }
            $docsOnlySuffix = ' (docs-only exemption not applied: ' + $docsOnly.Reason + ')'
        }
        # When neither the item target nor a run branch resolved, the reason code and the
        # three details precede the standalone reason (issue #850).
        $unresolved = Get-EpicMergeGateUnresolvedReason -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget
        $prefix = if ($unresolved) { $unresolved + '; ' } else { '' }
        return Get-EpicMergeGateBlockDecision -Reason ('EPIC_MERGE_GATE_BLOCKED: ' + $prefix + $standalone.ReasonCode + ': ' + $standalone.Message + $docsOnlySuffix)
```

**G4 - header design-decision paragraph.** Replace the four lines 36-39 (beginning `    Design decision: this gate trusts the on-disk checkpoint rather than shelling out live` and ending `    enforce-pr-author-skill.ps1's own receipt mechanism. It is not a cryptographic control.`) with

```text
    Design decision: branches 1-4 trust the on-disk checkpoint and never call gh. Issue #927
    adds a docs-only branch after branch 4 fails, only for an explicit PR number whose item,
    epic, and parallel targets are all NoTarget (no checkpoint records the PR): it calls
    Get-DocsOnlyMergeExemption (hook-docs-only-diff.ps1), which runs gh pr view and git in the
    session worktree and allows the merge when conditions M1-M9 of that file hold. Otherwise
    the deny gains " (docs-only exemption not applied: <Reason>)", where the reason may be
    DOCS_ONLY_EXEMPTION_PR_UNRESOLVED. The hook never fetches; --match-head-commit, when
    present, must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is
    not visible in the command text, and a push after the lookup can change the head unless
    --match-head-commit is passed. Like the receipt mechanism of enforce-pr-author-skill.ps1,
    this is a policy-level control, not a cryptographic one.
```

Net: G2 +2, G3 +9, G4 +7; total 490.

## 17. Appendix X — Codex merge gate `.codex/hooks/enforce-epic-merge-gate.ps1`

Line numbers refer to the file at [P0-T6] (385 lines).

**X1 - header.** Replace the four lines 1-4 (`<#`, `.SYNOPSIS`, `    Gates epic child and integration PR merges behind checkpointed green state.`, `#>`) with

```text
<#
.SYNOPSIS
    Gates epic child and integration PR merges behind checkpointed green state.

.DESCRIPTION
    Docs-only branch (issue #927): after the standalone branch denies an explicit PR number,
    and only when no checkpoint is present at the repository root (both checkpoint texts are
    blank; operator decision OD-1, stricter than the Claude per-PR rule), the gate calls
    Get-DocsOnlyMergeExemption from hook-docs-only-diff.ps1 with the repository root. That
    function runs gh pr view and git there and allows the merge when its conditions M1-M9
    hold; otherwise the deny gains " (docs-only exemption not applied: <Reason>)", where the
    reason may be DOCS_ONLY_EXEMPTION_PR_UNRESOLVED. A blank RepositoryRoot denies at M2
    before any process starts. The hook never fetches; --match-head-commit, when present,
    must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is not
    visible in the command text, a push after the lookup can change the head unless
    --match-head-commit is passed, and the control is policy-level, not cryptographic.
#>
```

**X2 - guarded dot-source.** Directly after the line beginning `try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') }` (line 13 before X1; line 26 after X1) insert

```powershell
# Shared docs-only diff classification and the merge-side docs-only exemption (issue #927).
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }
```

**X3 - parameter.** Inside `Invoke-CodexEpicMergeDecision`, replace the line `        [AllowNull()][AllowEmptyString()][string] $EpicCheckpointRaw` with

```powershell
        [AllowNull()][AllowEmptyString()][string] $EpicCheckpointRaw,
        [AllowNull()][AllowEmptyString()][string] $RepositoryRoot
```

**X4 - docs-only branch and suffix.** Two edits inside `Invoke-CodexEpicMergeDecision`. First, replace the three lines (original lines 175-177)

```powershell
        if ($verdict.Allowed) {
            return $null
        }
```

with

```powershell
        if ($verdict.Allowed) {
            return $null
        }
        # Docs-only branch (issue #927, OD-1): only when no checkpoint is present at the root.
        $docsOnlySuffix = ''
        if ([string]::IsNullOrWhiteSpace($ChildCheckpointRaw) -and [string]::IsNullOrWhiteSpace($EpicCheckpointRaw)) {
            $docsOnly = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber $prNumber -WorktreeRoot $RepositoryRoot
            if ($docsOnly.Exempt) {
                return $null
            }
            $docsOnlySuffix = ' (docs-only exemption not applied: ' + $docsOnly.Reason + ')'
        }
```

Second, replace the line `                permissionDecisionReason = 'EPIC_MERGE_GATE_BLOCKED: ' + $verdict.ReasonCode + ': ' + $verdict.Message` (original line 182) with

```powershell
                permissionDecisionReason = 'EPIC_MERGE_GATE_BLOCKED: ' + $verdict.ReasonCode + ': ' + $verdict.Message + $docsOnlySuffix
```

**X5 - entry point.** Replace the line `    $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payloadRaw -ChildCheckpointRaw $childRaw -EpicCheckpointRaw $epicRaw` with

```powershell
    $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payloadRaw -ChildCheckpointRaw $childRaw -EpicCheckpointRaw $epicRaw -RepositoryRoot $repositoryRoot
```

Net: X1 +13, X2 +2, X3 +1, X4 +9, X5 0; total 410. Existing Codex suites never pass `-RepositoryRoot`, so their explicit-number rows deny at M2 with no process call and only gain the appended suffix; their reason assertions use `-Match` or trailing-wildcard `-BeLike` (for example `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` lines 106 and 119-120), and the bare-command `-BeExactly` row (line 127) is unchanged. The in-process entry-point rows of `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` (lines 153-171) execute the X5 line with a non-Bash or malformed payload.

## 18. Appendix J — pack-manifest path additions

**J-C.** In `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, directly after the line `    ".claude/hooks/hook-dependency-guard.ps1",` (line 67) insert the line

```text
    ".claude/hooks/hook-docs-only-diff.ps1",
```

**J-X.** In `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, directly after the line `    ".codex/hooks/hook-dependency-guard.ps1",` (line 50) insert the line

```text
    ".codex/hooks/hook-docs-only-diff.ps1",
```

## 19. Appendix K — baseline seam mocks in the existing Claude merge-gate suites (AC-M16)

For each row, insert the two lines below directly after the anchor line, with the anchor line's leading whitespace prefixed to each inserted line. The anchor is the statement that dot-sources `.claude/hooks/enforce-epic-merge-gate.ps1`, so both mocked functions exist when `Mock` runs. No other line of these suites is edited unless [P4-T24] records a `SUFFIX_EDIT:`.

```powershell
Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
```

| Row | Suite (under `tests/scripts/claude-hooks/`) | Anchor line (current line number) | Indent |
|---|---|---|---|
| K1 | `enforce-epic-merge-gate.Tests.ps1` | `        . $script:UnderTest` (11) | 8 spaces |
| K2 | `enforce-epic-merge-gate.Authorization.Tests.ps1` | `        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path` (26) | 8 spaces |
| K3 | `enforce-epic-merge-gate.ItemResolution.Tests.ps1` | `    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path` (23) | 4 spaces |
| K4 | `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` | `    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path` (27) | 4 spaces |
| K5 | `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `        . $script:UnderTest` (26) | 8 spaces |
| K6 | `enforce-epic-merge-gate.Coverage.Tests.ps1` | `        . $script:Hook` (15) | 8 spaces |
| K7 | `hook-command-parser.AcceptanceCases.Tests.ps1` | `        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')` (49) | 8 spaces |
| K8 | `hook-command-consumers.Issue824.Tests.ps1` | `        . (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")` (90; the `Describe` runs for both runtimes, and both gate copies load the helper) | 8 spaces |

## 20. Appendix N — new Pester suites

Every row follows Arrange-Act-Assert. No row starts a process, runs git or gh, or writes a file. Suites C and E copy the epic-state isolation block of their sibling suites (`enforce-epic-merge-gate.TriggerScoping.Tests.ps1` lines 25-35 and `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` lines 21-33) and the interception probe, which `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` requires of every discovered suite whose loaded closure holds checkpoint read seams. Suites A, B, and D load only the helper and the command parsers, whose closure holds no checkpoint read seam.

**N-A** — `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (30 test cases):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for the shared docs-only helper .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Exercises the pure classifiers (relocated from the issue #901 suite under their shared
    names), the NUL guard, and the bodies of both process seams through test-local functions
    passed as scriptblocks, so no row starts a process. No row creates, writes, or deletes a file.
#>

Describe 'hook-docs-only-diff shared helper (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')

        # Test-local stand-ins for git and gh, passed as scriptblocks to the seams' invoker parameters.
        function Invoke-DocsOnlyFakeEcho {
            $global:LASTEXITCODE = 0
            ($args -join '|') + "`0"
        }
        function Invoke-DocsOnlyFakeLocation {
            $global:LASTEXITCODE = 0
            (Split-Path -Leaf -Path (Get-Location).Path) + '|' + ($args -join '|')
        }
        function Invoke-DocsOnlyFakeExit2 {
            $global:LASTEXITCODE = 2
        }
        function Invoke-DocsOnlyFakeThrow {
            throw 'simulated process start failure'
        }
        function Invoke-DocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    Context 'Get-DocsOnlyPathViolation' {
        It 'returns null for an all-docs set' {
            # Arrange
            $paths = @('docs/a.md', 'docs/features/x/plan.md')

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeNullOrEmpty -Because 'every path is under docs/'
        }

        It 'returns NON_DOCS_PATH for <Path>' -ForEach @(
            @{ Path = '.claude/hooks/x.ps1' }
            @{ Path = '.github/workflows/ci.yml' }
            @{ Path = 'README.md' }
            @{ Path = 'docsx/a.md' }
            @{ Path = 'doc/a.md' }
            @{ Path = 'Docs/a.md' }
            @{ Path = 'docs' }
        ) {
            # Arrange
            $paths = @($Path)

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Contains($Path) | Should -BeTrue -Because 'the denial names the offending path'
        }

        It 'names the first offending path of a mixed set' {
            # Arrange
            $paths = @('docs/a.md', 'src/b.ps1', '.github/c.yml')

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result.Contains('src/b.ps1') | Should -BeTrue -Because 'the first non-docs path is reported'
            $result.Contains('.github/c.yml') | Should -BeFalse -Because 'evaluation stops at the first violation'
        }

        It 'returns EMPTY_DIFF for an empty set' {
            # Arrange
            $paths = @()

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }
    }

    Context 'ConvertFrom-DocsOnlyNameList' {
        It 'splits a NUL list with spaces and non-ASCII names' {
            # Arrange
            $accented = 'docs/' + [char]0x00E9 + '.md'
            $text = "docs/a b.md`0" + $accented + "`0"

            # Act
            $result = @(ConvertFrom-DocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 2
            $result[0] | Should -BeExactly 'docs/a b.md'
            $result[1] | Should -BeExactly $accented
        }

        It 'keeps a line feed inside a name as one element' {
            # Arrange
            $text = "docs/line`nbreak.md`0"

            # Act
            $result = @(ConvertFrom-DocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 1 -Because 'only NUL separates entries'
            $result[0].Contains("`n") | Should -BeTrue
        }

        It 'returns no element for empty and null text' {
            # Arrange and Act
            $fromEmpty = @(ConvertFrom-DocsOnlyNameList -Text '')
            $fromNull = @(ConvertFrom-DocsOnlyNameList -Text $null)

            # Assert
            $fromEmpty.Count | Should -Be 0
            $fromNull.Count | Should -Be 0
        }
    }

    Context 'Get-DocsOnlyDiffTextViolation' {
        It 'denies non-empty output that lacks the trailing NUL (issue #927)' {
            # Arrange
            $text = 'docs/a.md'

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result | Should -Match 'NUL-terminated'
            $result.Contains('origin/main') | Should -BeTrue -Because 'the denial names the base'
        }

        It 'returns EMPTY_DIFF for <Name> (issue #927)' -ForEach @(
            @{ Name = 'empty diff text'; Text = '' }
            @{ Name = 'null diff text'; Text = $null }
        ) {
            # Arrange: the row supplies the text.

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }

        It 'returns NON_DOCS_PATH for a NUL-terminated list with a path outside docs (issue #927)' {
            # Arrange
            $text = "docs/a.md`0src/b.ps1`0"

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Contains('src/b.ps1') | Should -BeTrue
        }

        It 'returns null for a NUL-terminated list of docs paths (issue #927)' {
            # Arrange
            $text = "docs/a.md`0docs/b.md`0"

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Invoke-DocsOnlyGitExe' {
        It 'passes -C, the root, and the arguments in order and keeps the trailing NUL (issue #927)' {
            # Arrange
            $gitArgs = @('diff', '--name-only', '-z')
            $expected = '-C|' + $PSScriptRoot + '|diff|--name-only|-z' + "`0"

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeEcho}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly $expected
        }

        It 'returns the non-zero exit code of the injected git command (issue #927)' {
            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeExit2}

            # Assert
            $result.ExitCode | Should -Be 2
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object when the injected git command throws (issue #927)' {
            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object without running git for <Name> (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $Root -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeMarker}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            $global:LASTEXITCODE | Should -Be 0 -Because 'the injected command never ran'
        }
    }

    Context 'Invoke-DocsOnlyGhExe' {
        It 'runs inside the working root with the arguments in order and restores the location (issue #927)' {
            # Arrange
            $before = (Get-Location).Path

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeLocation}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'claude-hooks|pr|view|5'
            (Get-Location).Path | Should -Be $before
        }

        It 'returns the non-zero exit code of the injected gh command (issue #927)' {
            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeExit2}

            # Assert
            $result.ExitCode | Should -Be 2
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object and restores the location when the injected gh command throws (issue #927)' {
            # Arrange
            $before = (Get-Location).Path

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            (Get-Location).Path | Should -Be $before
        }

        It 'returns the failure object without running gh for <Name> (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $Root -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeMarker}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            $global:LASTEXITCODE | Should -Be 0 -Because 'the injected command never ran'
        }
    }

    Context 'shared copies' {
        It 'is byte-identical across all four copies (issue #927)' {
            # Arrange
            $paths = @('.claude/hooks/hook-docs-only-diff.ps1', '.codex/hooks/hook-docs-only-diff.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1')

            # Act
            $hashes = @($paths | ForEach-Object { (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $script:RepoRoot $_)).Hash })

            # Assert
            @($hashes | Sort-Object -Unique).Count | Should -Be 1 -Because "all four copies must be byte-identical ($($hashes -join ', '))"
        }

        It 'imports nothing, dot-sources nothing, and names no fetch argument (issue #927)' {
            # Arrange
            $path = Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1'
            $tokens = $null
            $parseErrors = $null

            # Act
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
            $loads = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and ($node.GetCommandName() -eq 'Import-Module' -or $node.InvocationOperator -eq 'Dot') }, $true))
            $fetchArguments = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $node.Value -ceq 'fetch' }, $true))

            # Assert
            @($parseErrors) | Should -BeNullOrEmpty
            $loads | Should -BeNullOrEmpty
            $fetchArguments | Should -BeNullOrEmpty
        }
    }
}
```

**N-A conversion edits (revision 2.1, [P2-T12]).** Suite A was written at [P2-T6] in its version 2.0 form. [P2-T12] converts it to the text above with these Edit replacements; no line is added or removed, and no other line changes:

- **NA-1**: the `.DESCRIPTION` line `    passed by name, so no row starts a process. No row creates, writes, or deletes a file.` becomes `    passed as scriptblocks, so no row starts a process. No row creates, writes, or deletes a file.`
- **NA-2**: the comment line `        # Test-local stand-ins for git and gh, passed by name to the seams' command parameters.` becomes `        # Test-local stand-ins for git and gh, passed as scriptblocks to the seams' invoker parameters.`
- **NA-3**: in each of the four `Invoke-DocsOnlyGitExe` call lines, the ending `-GitCommand '<name>'` becomes `-GitInvoker ${function:<name>}` with the same `<name>` (`Invoke-DocsOnlyFakeEcho`, `Invoke-DocsOnlyFakeExit2`, `Invoke-DocsOnlyFakeThrow`, `Invoke-DocsOnlyFakeMarker`).
- **NA-4**: in each of the four `Invoke-DocsOnlyGhExe` call lines, the ending `-GhCommand '<name>'` becomes `-GhInvoker ${function:<name>}` with the same `<name>` (`Invoke-DocsOnlyFakeLocation`, `Invoke-DocsOnlyFakeExit2`, `Invoke-DocsOnlyFakeThrow`, `Invoke-DocsOnlyFakeMarker`).

Each `${function:<name>}` is evaluated inside an `It` body, after the `Describe` `BeforeAll` has defined the function, including in the two `-ForEach` rows whose data carries only `Name` and `Root`. Expected outputs are unchanged: the fakes receive the same `$args` sequence through their scriptblocks, and the `Invoke-DocsOnlyFakeLocation` row still observes the pushed working root because the seam invokes the scriptblock after `Push-Location`.

**N-B** — `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (36 test cases):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Conditions M1 to M9 of Get-DocsOnlyMergeExemption in .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Both process seams are mocked by name; no row starts a process, runs git or gh, or writes
    a file. A guard mock makes any git call whose first argument is fetch throw, so a row that
    reached a fetch would fail.
#>

Describe 'Get-DocsOnlyMergeExemption (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-command-invocation.ps1')
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')
        $script:Merge = 'gh pr merge 5 --merge'
    }

    BeforeEach {
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "docs/a.md`0" } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'fetch' } -MockWith { throw 'a docs-only exemption row reached git fetch' }
    }

    Context 'M1 command shape' {
        It 'denies <Name> before any process (issue #927)' -ForEach @(
            @{ Name = 'a missing PR number'; Command = 'gh pr merge --merge'; Pr = $null }
            @{ Name = 'a non-positive PR number'; Command = 'gh pr merge 0 --merge'; Pr = 0 }
            @{ Name = 'a separate -R override'; Command = 'gh pr merge 5 --merge -R o/r'; Pr = 5 }
            @{ Name = 'a -dR cluster'; Command = 'gh pr merge 5 --merge -dR o/r'; Pr = 5 }
            @{ Name = 'a long --repo override'; Command = 'gh pr merge 5 --merge --repo o/r'; Pr = 5 }
            @{ Name = 'a --repo= override'; Command = 'gh pr merge 5 --merge --repo=o/r'; Pr = 5 }
            @{ Name = 'a global -R before pr merge'; Command = 'gh -R o/r pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'an inline GH_REPO prefix'; Command = 'GH_REPO=o/r gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'an inline GH_HOST prefix'; Command = 'GH_HOST=h gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'a cd chain'; Command = 'cd x && gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'two merges in one command'; Command = 'gh pr merge 5 --merge; gh pr merge 6 --merge'; Pr = 5 }
            @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5 }
            @{ Name = 'a bash -c wrapper'; Command = 'bash -c "gh pr merge 5 --merge"'; Pr = 5 }
        ) {
            # Arrange: the row supplies the command and the number the gate read.

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber $Pr -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'M2 worktree root' {
        It 'denies <Name> with no process call (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $Root

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'M3 pull request lookup' {
        It 'denies <Name> with PR_UNRESOLVED and no git call (issue #927)' -ForEach @(
            @{ Name = 'a failing gh lookup'; Command = 'gh pr merge 5 --merge'; GhExit = 1; GhOutput = '' }
            @{ Name = 'unparseable lookup output'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = 'not json' }
            @{ Name = 'a short head oid'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"abc123"}' }
            @{ Name = 'an uppercase head oid'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789ABCDEF0123456789ABCDEF01234567"}' }
            @{ Name = 'a mismatched --match-head-commit'; Command = 'gh pr merge 5 --merge --match-head-commit 1111111111111111111111111111111111111111'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a --match-head-commit with no value'; Command = 'gh pr merge 5 --merge --match-head-commit'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
        ) {
            # Arrange
            $exitCode = $GhExit
            $output = $GhOutput
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies <Name> with BASE_UNRESOLVED and no git call (issue #927)' -ForEach @(
            @{ Name = 'a base containing two dots'; GhOutput = '{"baseRefName":"a..b","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a dash-leading base'; GhOutput = '{"baseRefName":"-x","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
        ) {
            # Arrange
            $output = $GhOutput
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'does not deny a matching --match-head-commit (issue #927)' {
            # Arrange
            $command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567'

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "a matching head pin is accepted (OD-2); reason: $($result.Reason)"
        }

        It 'calls gh pr view with the number and the two JSON fields in the root (issue #927)' {
            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' -and $WorkingRoot -like '*claude-hooks' }
        }
    }

    Context 'M4 to M9 git checks' {
        It 'denies <Name> with BASE_UNRESOLVED and no diff call (issue #927)' -ForEach @(
            @{ Name = 'a failing base rev-parse'; RevExit = 128; RevOutput = '' }
            @{ Name = 'a non-hex base rev-parse'; RevExit = 0; RevOutput = 'main' }
        ) {
            # Arrange
            $exitCode = $RevExit
            $output = $RevOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' }
        }

        It 'denies <Name> with DIFF_FAILED naming the head and no diff call (issue #927)' -ForEach @(
            @{ Name = 'a failing head rev-parse'; RevExit = 128; RevOutput = '' }
            @{ Name = 'a different head rev-parse value'; RevExit = 0; RevOutput = 'ffffffffffffffffffffffffffffffffffffffff' }
        ) {
            # Arrange
            $exitCode = $RevExit
            $output = $RevOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result.Reason.Contains('0123456789abcdef0123456789abcdef01234567') | Should -BeTrue -Because 'the reason names the missing head commit'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' }
        }

        It 'denies <Name> (issue #927)' -ForEach @(
            @{ Name = 'a failing merge diff'; DiffExit = 1; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*could not be computed*' }
            @{ Name = 'merge diff output without a trailing NUL'; DiffExit = 0; DiffOutput = 'docs/a.md'; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*NUL-terminated*' }
            @{ Name = 'an empty merge diff'; DiffExit = 0; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*' }
            @{ Name = 'a merge diff with a path outside docs'; DiffExit = 0; DiffOutput = "docs/a.md`0src/b.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        ) {
            # Arrange
            $exitCode = $DiffExit
            $output = $DiffOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike $Expected
        }

        It 'allows a NUL-terminated docs-only diff (issue #927)' {
            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "reason: $($result.Reason)"
            $result.Reason | Should -BeNullOrEmpty
        }

        It 'runs the diff with -z, --no-renames, and the base...head range (issue #927)' {
            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative fedcba9876543210fedcba9876543210fedcba98...0123456789abcdef0123456789abcdef01234567' }
        }

        It 'never runs git fetch on the allow path (issue #927)' {
            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'fetch' }
        }
    }
}
```

**N-C** — `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (14 test cases):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end rows for the docs-only branch of .claude/hooks/enforce-epic-merge-gate.ps1 (issue #927).

.DESCRIPTION
    Drives Invoke-EpicMergeGateDecision with mocked target resolvers, checkpoint read seams,
    and docs-only process seams. No row starts a process, runs git or gh, or writes a file.
    The docs-only seam mocks in BeforeAll are registered only when the shared helper is
    loaded, so before the helper exists every docs-only row fails on its own Mock or
    Should -Invoke call rather than failing the container.
#>

Describe 'enforce-epic-merge-gate docs-only branch (issue #927)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        if (Get-Command Invoke-DocsOnlyGhExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        if (Get-Command Invoke-DocsOnlyGitExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        $sessionRoot = $PSScriptRoot
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRoot }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (issue #927)' } }
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #927)' } }

        function ConvertTo-DocsOnlyMergeEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse envelope the gate reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-927'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-DocsOnlyMergeSeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams for one pull request and one diff listing.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)

            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        $script:BareDenyText = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'no checkpoint records the pull request' {
        It 'allows a docs-only merge with no checkpoint record (issue #927)' {
            # Arrange
            Set-DocsOnlyMergeSeam -DiffOutput "docs/a.md`0docs/b.md`0"
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative fedcba9876543210fedcba9876543210fedcba98...0123456789abcdef0123456789abcdef01234567' }
        }

        It 'denies a non-docs diff with the docs-only reason after the standalone reasons (issue #927)' {
            # Arrange
            Set-DocsOnlyMergeSeam -DiffOutput "docs/a.md`0.claude/hooks/x.ps1`0"
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED:*'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH'
        }

        It 'denies a failed gh lookup with the PR_UNRESOLVED docs-only reason (issue #927)' {
            # Arrange: the BeforeAll seam mocks report a failed lookup.
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a -R override with the PR_UNRESOLVED docs-only reason and no process call (issue #927)' {
            # Arrange
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge -R o/r'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'a checkpoint target resolves or the command is bare' {
        It 'makes no docs-only call when the <Name> target is <Status> (issue #927)' -ForEach @(
            @{ Name = 'item'; Status = 'SessionRoot' }
            @{ Name = 'item'; Status = 'OtherWorktree' }
            @{ Name = 'epic'; Status = 'Ambiguous' }
        ) {
            # Arrange
            $root = if ($Status -eq 'Ambiguous') { $null } else { '/synthetic-worktrees/item-927' }
            $code = if ($Status -eq 'Ambiguous') { 'TARGET_WORKTREE_AMBIGUOUS' } else { $null }
            $resolved = [pscustomobject]@{ Status = $Status; WorktreeRoot = $root; ReasonCode = $code; Detail = "$Name $Status (issue #927)" }
            if ($Name -eq 'item') {
                Mock Resolve-EpicMergeGateItemTarget -MockWith ({ $resolved }.GetNewClosure())
            }
            else {
                Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -eq 'epic' } -MockWith ({ $resolved }.GetNewClosure())
            }
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains('docs-only exemption not applied') | Should -BeFalse
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)' {
            # Arrange
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:BareDenyText
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'Test-EpicMergeGateNoRecordingTarget' {
        It 'reports <Result> for item <Item>, epic <Epic>, parallel <Parallel> (issue #927)' -ForEach @(
            @{ Item = 'NoTarget'; Epic = 'NoTarget'; Parallel = 'NoTarget'; Result = 'true' }
            @{ Item = 'Ambiguous'; Epic = 'NoTarget'; Parallel = 'NoTarget'; Result = 'false' }
            @{ Item = 'NoTarget'; Epic = 'SessionRoot'; Parallel = 'NoTarget'; Result = 'false' }
            @{ Item = 'NoTarget'; Epic = 'NoTarget'; Parallel = 'OtherWorktree'; Result = 'false' }
        ) {
            # Arrange
            $itemTarget = [pscustomobject]@{ Status = $Item }
            $epicTarget = [pscustomobject]@{ Status = $Epic }
            $parallelTarget = [pscustomobject]@{ Status = $Parallel }

            # Act
            $actual = Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget

            # Assert
            $actual | Should -Be ($Result -eq 'true')
        }

        It 'reports false for a bare command with no targets (issue #927)' {
            # Act
            $actual = Test-EpicMergeGateNoRecordingTarget -ItemTarget $null -EpicTarget $null -ParallelTarget $null

            # Assert
            $actual | Should -BeFalse
        }
    }
}
```

**N-D** — `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (32 test cases):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Drives the Codex copy .codex/hooks/hook-docs-only-diff.ps1 so that copy is covered (issue #927).

.DESCRIPTION
    Loads the Codex command parsers and the Codex copy of the helper. Process seams are mocked
    by name for the decision rows and driven through test-local functions for the seam rows;
    no row starts a process or writes a file.
#>

Describe 'Codex hook-docs-only-diff copy (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/hook-command-invocation.ps1')
        . (Join-Path $script:RepoRoot '.codex/hooks/hook-docs-only-diff.ps1')

        function Invoke-CodexDocsOnlyFakeDocs {
            $global:LASTEXITCODE = 0
            "docs/a.md`0"
        }
        function Invoke-CodexDocsOnlyFakeLocation {
            $global:LASTEXITCODE = 0
            (Split-Path -Leaf -Path (Get-Location).Path) + '|' + ($args -join '|')
        }
        function Invoke-CodexDocsOnlyFakeExit2 {
            $global:LASTEXITCODE = 2
        }
        function Invoke-CodexDocsOnlyFakeThrow {
            throw 'simulated process start failure'
        }
        function Invoke-CodexDocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }

        function Set-CodexDocsOnlySeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams; each argument overrides one default result.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [int] $GhExit = 0,
                [string] $GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}',
                [int] $BaseExit = 0,
                [string] $BaseOutput = 'fedcba9876543210fedcba9876543210fedcba98',
                [int] $HeadExit = 0,
                [string] $HeadOutput = '0123456789abcdef0123456789abcdef01234567',
                [int] $DiffExit = 0,
                [string] $DiffOutput = "docs/a.md`0"
            )

            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = $GhExit; Output = $GhOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $BaseExit; Output = $BaseOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $HeadExit; Output = $HeadOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput } }.GetNewClosure())
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    It 'classifies <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'output without a trailing NUL'; Text = 'docs/a.md'; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'empty output'; Text = ''; Expected = 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*' }
        @{ Name = 'a path outside docs'; Text = "src/a.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'the bare docs directory'; Text = "docs`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'docs-only paths'; Text = "docs/a.md`0docs/b.md`0"; Expected = 'NONE' }
    ) {
        # Act
        $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'

        # Assert
        if ($Expected -eq 'NONE') {
            $result | Should -BeNullOrEmpty
        }
        else {
            $result | Should -BeLike $Expected
        }
    }

    It 'runs the git seam for <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'a success'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeDocs'; ExitCode = 0; Output = "docs/a.md`0" }
        @{ Name = 'a non-zero exit'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeExit2'; ExitCode = 2; Output = '' }
        @{ Name = 'a throw'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeThrow'; ExitCode = -1; Output = '' }
        @{ Name = 'a blank root'; Root = ''; Fake = 'Invoke-CodexDocsOnlyFakeMarker'; ExitCode = -1; Output = '' }
    ) {
        # Arrange
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }

        # Act
        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $workingRoot -GitArgs @('status') -GitInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock

        # Assert
        $result.ExitCode | Should -Be $ExitCode
        $result.Output | Should -BeExactly $Output
    }

    It 'runs the gh seam for <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'a success'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeLocation'; ExitCode = 0; Output = 'codex-hooks|pr|view|5' }
        @{ Name = 'a non-zero exit'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeExit2'; ExitCode = 2; Output = '' }
        @{ Name = 'a throw'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeThrow'; ExitCode = -1; Output = '' }
        @{ Name = 'a blank root'; Root = ''; Fake = 'Invoke-CodexDocsOnlyFakeMarker'; ExitCode = -1; Output = '' }
    ) {
        # Arrange
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }
        $before = (Get-Location).Path

        # Act
        $result = Invoke-DocsOnlyGhExe -WorkingRoot $workingRoot -GhArgs @('pr', 'view', '5') -GhInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock

        # Assert
        $result.ExitCode | Should -Be $ExitCode
        $result.Output | Should -BeExactly $Output
        (Get-Location).Path | Should -Be $before
    }

    It 'decides <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'no PR number'; Command = 'gh pr merge --merge'; Pr = $null; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a single-dash R token'; Command = 'gh pr merge 5 --merge -R o/r'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a --repo token'; Command = 'gh pr merge 5 --merge --repo o/r'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an inline prefix'; Command = 'GH_HOST=h gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a chained command'; Command = 'gh pr merge 5 --merge; echo x'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a non-merge command'; Command = 'gh pr view 5'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a blank root'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = ''; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a failing lookup'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhExit = 1; GhOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an unparseable lookup'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = 'not json' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an invalid base'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = '{"baseRefName":"a..b","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }; Expected = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*' }
        @{ Name = 'an invalid head'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = '{"baseRefName":"main","headRefOid":"abc"}' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a mismatched head pin'; Command = 'gh pr merge 5 --merge --match-head-commit 1111111111111111111111111111111111111111'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a missing base ref'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ BaseExit = 128; BaseOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*' }
        @{ Name = 'a missing head commit'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ HeadExit = 128; HeadOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'a failing diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ DiffExit = 1; DiffOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'a non-docs diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ DiffOutput = "src/a.ps1`0" }; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'a docs-only diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'EXEMPT' }
        @{ Name = 'a matching head pin'; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'EXEMPT' }
    ) {
        # Arrange
        Set-CodexDocsOnlySeam @Seam
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }

        # Act
        $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber $Pr -WorktreeRoot $workingRoot

        # Assert
        if ($Expected -eq 'EXEMPT') {
            $result.Exempt | Should -BeTrue -Because "reason: $($result.Reason)"
        }
        else {
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike $Expected
        }
    }
}
```

**N-D conversion edits (revision 2.1, [P2-T13]).** Suite D was written at [P2-T8] in its version 2.0 form. [P2-T13] converts it to the text above with these two Edit replacements; no line is added or removed, and no other line changes (the `-ForEach` row data keeps the fake names as strings because row data is evaluated at discovery, before the `BeforeAll` functions exist):

- **ND-1**: `        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $workingRoot -GitArgs @('status') -GitCommand $Fake` becomes `        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $workingRoot -GitArgs @('status') -GitInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock`.
- **ND-2**: `        $result = Invoke-DocsOnlyGhExe -WorkingRoot $workingRoot -GhArgs @('pr', 'view', '5') -GhCommand $Fake` becomes `        $result = Invoke-DocsOnlyGhExe -WorkingRoot $workingRoot -GhArgs @('pr', 'view', '5') -GhInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock`.

**N-E** — `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (9 test cases):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Docs-only branch of the Codex epic merge gate .codex/hooks/enforce-epic-merge-gate.ps1 (issue #927).

.DESCRIPTION
    Drives Invoke-CodexEpicMergeDecision with literal checkpoint texts and mocked docs-only
    seams. An allow is asserted as $null, the Codex allow representation. No row starts a
    process, runs git or gh, or writes a file. The BeforeAll seam mocks are registered only
    when the shared helper is loaded, so before it exists every docs-only row fails.
#>

Describe 'Codex enforce-epic-merge-gate docs-only branch (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        . $script:CodexHook
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        if (Get-Command Invoke-DocsOnlyGhExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        if (Get-Command Invoke-DocsOnlyGitExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }

        function ConvertTo-CodexDocsOnlyPayload {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse payload the Codex gate reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-927'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-CodexGateDocsOnlySeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams for one pull request and one diff listing.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)

            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        $script:CodexBareDenyText = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows a docs-only merge when no checkpoint is present (codex, issue #927)' {
        # Arrange
        Set-CodexGateDocsOnlySeam -DiffOutput "docs/a.md`0"
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        $decision | Should -BeNullOrEmpty -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' -and $WorkingRoot -like '*codex-hooks' }
    }

    It 'appends the NON_DOCS_PATH docs-only reason to the standalone deny (codex, issue #927)' {
        # Arrange
        Set-CodexGateDocsOnlySeam -DiffOutput "docs/a.md`0src/a.ps1`0"
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_ABSENT: *'
        $reason.Contains(' (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH') | Should -BeTrue
    }

    It 'makes no docs-only call when the <Name> checkpoint is present (codex, issue #927)' -ForEach @(
        @{ Name = 'child'; Child = '{"note":"present"}'; Epic = '' }
        @{ Name = 'epic'; Child = ''; Epic = '{"note":"present"}' }
    ) {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Child -EpicCheckpointRaw $Epic -RepositoryRoot $PSScriptRoot
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.Contains('docs-only exemption not applied') | Should -BeFalse
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a blank repository root with PR_UNRESOLVED and no process call (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot ''

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a -R override with PR_UNRESOLVED and no process call (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge -R o/r'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a failed gh lookup with PR_UNRESOLVED (codex, issue #927)' {
        # Arrange: the BeforeAll seam mocks report a failed lookup.
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
    }

    It 'keeps the bare-merge deny text unchanged (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:CodexBareDenyText
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
    }
}
```

## 21. Quoted literals created by this plan

Revision 2.1 note: the version 2.0 literals `[ValidateNotNullOrEmpty()][string] $GitCommand`, `.PARAMETER GitCommand`, and `& $GitCommand -C $WorktreeRoot @GitArgs` are withdrawn; the seam literals below replace them. Tokens asserted to print `0` after the rework (`GitCommand`, `GhCommand`, `passed by name`) exist in the tree before [P2-T9] to [P2-T14] run, so those assertions can fail.

The following tokens do not exist in the tree before this plan runs; the tasks above create them verbatim: `TIMESTAMP_RECONSTRUCTED: true`, `TIMESTAMP_DERIVATION: `, `TIMESTAMP_ORIGINAL: 2026-10-13T00-00`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T10-51`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-14`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: UNRECORDED .. 2026-10-13T11-17`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-28`, `TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-28 .. 2026-10-13T11-34`, `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`, `The process exit code of this run was not observed`, `- [x] baseline (evidence/baseline/)`, `[ValidateNotNull()][scriptblock] $GitInvoker = { git @args`, `[ValidateNotNull()][scriptblock] $GhInvoker = { gh @args`, `.PARAMETER GitInvoker`, `.PARAMETER GhInvoker`, `& $GitInvoker -C $WorktreeRoot @GitArgs`, `& $GhInvoker @GhArgs`, `-GitInvoker`, `-GhInvoker`, `Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker`, `-GitInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock`, `-GhInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock`, `PRIOR_HELPER_HASH: d140874bb42ba07c8eb1fbd0a3dccba0e16fffda`, `REWORK_HELPER:`, `shorthand cluster containing B or R, and an inline GH_REPO= prefix are not accepted`, `did not return NUL-terminated output`, `EndsWith([char]0)`, `Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base`, `hook-docs-only-diff.ps1`, `no inline GH_REPO= prefix.`, `and non-empty output ends with NUL.`, `Residual limit:`, `token has B or R among its letters`, `no inline GH_REPO= prefix);`, `single-dash token whose letters include B or R`, `repository override is present, or`, `returns output not ending with NUL.`, `Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)'`, `It 'denies a --repo override before the diff (issue #927)'`, `moved with their rows to`, `function Test-EpicMergeGateNoRecordingTarget`, `Test-EpicMergeGateNoRecordingTarget, the precondition`, `Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1'`, `Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget`, `Get-DocsOnlyMergeExemption -CommandText $commandText -PrNumber $commandPrNumber -WorktreeRoot $sessionRoot`, `$standalone.Message + $docsOnlySuffix)`, `' (docs-only exemption not applied: '`, `conditions M1-M9`, `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED`, `The hook never fetches`, `operator decision OD-1`, `[AllowNull()][AllowEmptyString()][string] $RepositoryRoot`, `-WorktreeRoot $RepositoryRoot`, `$verdict.Message + $docsOnlySuffix`, `IsNullOrWhiteSpace($ChildCheckpointRaw) -and`, `-RepositoryRoot $repositoryRoot`, `".claude/hooks/hook-docs-only-diff.ps1",`, `".codex/hooks/hook-docs-only-diff.ps1",`, `Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }`, `Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }`, `Describe 'enforce-epic-merge-gate docs-only branch (issue #927)'`, `Describe 'Codex enforce-epic-merge-gate docs-only branch (issue #927)'`, `(codex, issue #927)`, `Context 'Get-DocsOnlyPathViolation'`, `Context 'ConvertFrom-DocsOnlyNameList'`, `Describe 'Get-DocsOnlyMergeExemption (issue #927)'`, `a docs-only exemption row reached git fetch`, `.codex/hooks/hook-docs-only-diff.ps1`.
