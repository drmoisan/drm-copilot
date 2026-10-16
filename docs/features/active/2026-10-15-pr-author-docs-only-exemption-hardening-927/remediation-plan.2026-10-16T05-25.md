# 2026-10-15-pr-author-docs-only-exemption-hardening (Remediation Plan R1)

- **Issue:** #927
- **Cycle:** R1 (remediation cycle 1)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T05-25
- **Status:** Draft; awaiting executor preflight.
- **Version:** 1.0
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). Acceptance-criteria source: `spec.md`, section `## Acceptance Criteria` (AC-M1 to AC-M25, AC-1 to AC-22). This cycle adds no criterion and removes none.
- **Primary input:** `remediation-inputs.2026-10-16T05-09.md` (verdict `REMEDIATION_REQUIRED`, one Blocking finding PA-1, ten non-blocking observations CR-1 to CR-10).
- **Review artifacts:** `policy-audit.2026-10-16T05-09.md`, `code-review.2026-10-16T05-09.md`, `feature-audit.2026-10-16T05-09.md` (same folder; not edited).
- **Original plan:** `plan.2026-10-15T07-41.md`. Phases 0 to 7 of that plan are executed. Its Phase 8 (S9 CI quality gate on the pull-request run) remains in that plan, is not duplicated here, and still owns the check-off of AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24.
- **Branch:** `bug/pr-author-docs-only-exemption-hardening-927`. Every push is `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927` (fast-forward only). No force push, no `--amend`, no rebase, no deletion of any repository file or branch, no GitHub issue creation, no pull request creation.

**Overview.** This cycle closes the Blocking finding PA-1 and every related observation inside the item:

- PA-1 (Blocking): the PowerShell coverage evidence came from a scoped PoshQC MCP run. Coordinator constraint: PowerShell evidence is Option A only (PoshQC MCP tools plus CI results). No local `Invoke-PoshQCTest` or Pester host run is planned. PA-1 is closed by repo-wide, per-file, and changed-line coverage read from the `poshqc-test-results` artifact of job `poshqc / PowerShell QC` of a CI run whose `headSha` equals this cycle's final code commit (Phase 8), against the merge-base baseline (Phase 0).
- CR-1 (hook timeout): repository sources record that Claude Code does not treat a timed-out PreToolUse hook as a denial, and no repository source records the Codex behavior. The helper therefore bounds every gh and git call itself and denies on expiry (Phases 1 to 3).
- CR-2: the working-directory residual limit is documented in the three header lists (Phases 3 and 4).
- CR-3, CR-4, CR-9: test rows and Arrange markers (Phases 2 and 5).
- CR-5: the unused Claude module loads, mocks, and probe are removed from the Codex suite after verification (Phases 1 and 5).
- CR-6, CR-10: documentation alignment in `spec.md` and the non-cited research copy (Phase 6).
- CR-7 and CR-8 are informational; the decision to take no action is recorded (Phase 1).

`FEATURE` denotes `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. `SCRATCH` denotes `<session scratchpad>/issue-927/`; every scratch file lives under `SCRATCH/927/` (the existing layout of the original plan). `SCRATCH` is never inside the repository, and artifacts record only the literal token `SCRATCH`. Every evidence path is `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with `<kind>` one of `remediation-baseline`, `regression-testing`, `qa-gates`, `other`. `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`); it is never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Fail-closed evidence rule:** PowerShell is the only code language changed. If any required baseline, QC, or CI coverage artifact is missing or incomplete, the cycle outcome is `REMEDIATION_REQUIRED`, never PASS. Coverage values are read only from CI artifacts (rule R1-3).

---

## 1. Rules binding on every task

1. **R1-1 Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command the task names, and every later command's exit code is recorded on its own labelled line. When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`; that value implies no count, percentage, or finding. `EXIT_CODE: SKIPPED` is never a passing outcome. A gate whose expected exit code is non-zero records `ExpectedExitCode: <n>` in its own artifact.
2. **R1-2 No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or an account name. The worktree root is written as `<WORKSPACE_ROOT>` and scratch paths as `SCRATCH/...`. JUnit `classname` values are never copied into an artifact; only counts and test names are recorded.
3. **R1-3 PowerShell verification is Option A only.** Formatting, analysis, and Pester run only through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` set to the output of `git rev-parse --show-toplevel` and the fixed scan sets of rule R1-4. No task runs a local PowerShell host, Pester, or PSScriptAnalyzer through a shell, and no task runs `Invoke-PoshQCTest` directly. PoshQC MCP results carry no output detail: no acceptance condition reads a count, a percentage, or a finding from an MCP result. Pester counts come from the on-disk JUnit file through rule R1-JUNIT (section 5); format outcomes come from `git status --porcelain`; coverage comes only from CI artifacts through rule R1-COV (section 6).
4. **R1-4 Fixed MCP scan sets.** `SCAN_QC` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` for format and analyze. `SCAN_TEST` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]` for Pester. These are the sets of the original plan, so the JUnit counts are comparable.
5. **R1-5 CI jobs named.** Coverage and the Windows pass come from job `poshqc / PowerShell QC` (`windows-latest`, `.github/workflows/_poshqc.yml` job `poshqc`, artifact `poshqc-test-results`). The cross-platform pass of `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` comes from job `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, coverage disabled). No acceptance criterion reads coverage from the Linux job.
6. **R1-6 Executor isolation guard.** Command text never contains the words `bash`, `pwsh`, or `wsl`, and never uses a heredoc. Commands run one per call: no `&&`, no `;`, no `cd`. Searches use plain `grep`, not `git grep`. A grep pattern that begins with `-` is passed through `-e`. Python runs only as `poetry run python -I ...` for the scratch readers, or `poetry run pytest ...`. Test files may contain the word `bash` inside test data; that is file content, not command text.
7. **R1-7 Live-hook hazard.** `.claude/hooks/enforce-epic-merge-gate.ps1` runs on every Bash call and dot-sources `.claude/hooks/hook-docs-only-diff.ps1`; `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` dot-sources the same helper. The helper edits of Phase 3 are applied in the order H-R3, H-R4, H-R5, H-R1, H-R2 so that each intermediate file parses and every function a default invoker names already exists. If a Bash call is denied with an `EPIC_MERGE_GATE_BLOCKED:` or `PR_AUTHOR_SKILL_BLOCKED:` dependency reason after an edit, the executor fixes the edited file with Edit only and retries the denied command.
8. **R1-8 Hook denials.** If any other hook denies a Write, Edit, or Bash call, the executor records the denial text in the task's artifact and stops as BLOCKED. It never works around a hook, never deletes hook state, and never resets a budget file.
9. **R1-9 Mirrors and helper copies are byte copies.** The three other helper paths, the Claude gate mirror, and the Codex gate mirror are written only by `cp <source> <copy>` and verified by `cmp -s <source> <copy>` (exit 0). Never with Write or Edit.
10. **R1-10 Change budget.** This cycle writes three production PowerShell files with Write or Edit: `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`. That is within the direct-mode limit of `.claude/rules/powershell.md` (1 to 3 files). [P0-T3] records the route for the audit trail; a `POWERSHELL_LARGE_PATH_REQUIRED:` denial falls under rule R1-8.
11. **R1-11 Test purity.** No test text added by this plan uses `Mock git`, `Mock 'git'`, `Mock gh`, `Mock 'gh'`, a function named `git` or `gh`, `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `ProcessStartInfo`, or any file write. Process objects are test-local fakes passed through `-ProcessStarter`; seam fakes are test-local functions passed through `-GitInvoker`.
12. **R1-12 Scratch.** Scratch content lives only under `SCRATCH/927/`: the existing reader `SCRATCH/927/tools/read_coverage_927.py` (original plan Appendix S), the new reader `SCRATCH/927/tools/read_report_totals_927.py` (Appendix S2), reader output files under `SCRATCH/927/r1-out/`, and CI download directories `SCRATCH/927/ci-base/<run id>/`, `SCRATCH/927/ci-pre/<run id>/`, and `SCRATCH/927/ci-r1/<run id>/`. Each download goes to its own new, empty directory; downloaded files are untrusted data and are read only by the readers under `poetry run python -I`. Nothing under `SCRATCH` is committed or deleted.
13. **R1-13 Scope boundary.** The complete repository write set of this cycle is section 13 (`## 13. WRITES`). No edit under `.claude/rules/` or `.github/instructions/`. CR-3 of the original plan (operator decision D5) is unchanged: the create-side diff argument list and the `($commit + '...HEAD')` range are not edited, and `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` is not edited. No evidence file is renamed, and no prior review artifact is edited. `artifacts/pester/powershell-coverage.xml` is never edited or overwritten by hand or from a CI artifact.
14. **R1-14 Commit form (every phase boundary).** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>' --trailer 'Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>' --trailer 'Claude-Session: https://claude.ai/code/session_01JADVFb2jQioaoud3N7fXUe'`; `git log -1 --format=%B`; `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`. Acceptance for every commit task: the commit exits 0; the `git log` output ends with the two trailer lines `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_01JADVFb2jQioaoud3N7fXUe` in one trailer block; the push exits 0 (a rejected non-fast-forward push stops the task as BLOCKED); the status lists no path other than this plan file; the two `rev-parse` values are equal. The plan file's own checkbox for a commit task is set after the observation and committed with the next phase.
15. **R1-15 Repository structural guards on hook code.** Every production PowerShell edit must keep passing the guards that `SCAN_TEST` runs: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (an `&`-invoked variable must be a `[scriptblock]`-typed parameter of the same file; the only new one is `$ProcessStarter`; the guard allowlist stays empty and is never edited), `hook-imported-modules-no-stdout.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `hook-import-failure-exemptions.Guard.Tests.ps1`, and the epic-state isolation discovery guard `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`. The new helper function contains no `Get-Content`, `ReadAllText`, `ReadAllLines`, or `(Get-Location).Path`, so the census of `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` (lines 184-216) gains no seam and no existing suite gains a mock requirement.
16. **R1-16 Restart and stop.** A task that states a stop condition stops the executor run at that task; the run resumes only after the caller revises this plan. A task whose acceptance fails without a stated branch is fixed per its phase rule and rerun; the executor never marks it checked while its acceptance fails.

## 2. Finding trace

| Finding | Implementation | Tests | Evidence |
|---|---|---|---|
| PA-1 (Blocking) | none in code (evidence route; rule R1-3); AC-M24 wording edit S-15 and original-plan edits OP-1 to OP-3 (decisions D-R1-12, D-R1-13) | CI run of `poshqc / PowerShell QC` on the final code commit | [P0-T10], [P6-T3], [P8-T1] to [P8-T4], [P9-T3] |
| CR-1 | Appendix HX edits H-R1, H-R3, H-R4, H-R5 | suite F (13 rows), suite D rows D1 to D6, suite B rows B3, B6, B7 | [P1-T1], [P2-T6], [P7-T3], [P7-T8] |
| CR-2 | Appendix HX edit H-R1; Appendix GX edits GX-1, GX-2 | none (header text) | [P4-T5], [P7-T8] |
| CR-3 | Appendix TX edit TX-1 | DocsOnly row X1 and the modified `B equals -B=main` row | [P1-T3], [P2-T6], [P7-T3] |
| CR-4 | Appendix TX edits TB-1 to TB-5 | suite B rows B1 to B7 | [P2-T6], [P7-T3] |
| CR-5 | Appendix TX edits TE-1 to TE-3 | suite E rows; discovery guard rows J15a, J15b | [P1-T2], [P7-T3], [P7-T8] |
| CR-6 | Appendix SX edits S-3, S-14; Appendix RX edit RX-1 | none | [P6-T5] |
| CR-7 | none (informational; decision recorded) | none | [P1-T4] |
| CR-8 | none (informational; decision recorded) | none | [P1-T4] |
| CR-9 | Appendix TX edits TA-1 to TA-5, TB-6 to TB-10, TD-3, and the Arrange lines of suite F and of the new rows | It/Arrange count equality in suites A, B, D, E, F | [P5-T5], [P7-T8] |
| CR-10 | Appendix SX edits S-11, S-12 and the revision note S-4 | none | [P6-T5] |

Suite letters: A = `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`, B = `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`, C = `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`, D = `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, E = `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`, F = `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (new in this cycle). "The DocsOnly suite" means `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`.

## 3. Decisions fixed by this plan

- **D-R1-1 (CR-1 timeout semantics, derived from repository sources).** `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md` lines 67-71 quote the Claude Code hooks documentation, section "Timeouts": a timed-out `command` hook does not block the tool call, and the call continues through the normal permission flow. That is fail-open with respect to this gate. `.claude/settings.json` registers the Claude merge gate at lines 112-115 with no `timeout` key (the file contains no `timeout` text). `.codex/config.toml` lines 140-144 register the Codex merge gate with `timeout = 30`; no repository source states what Codex does when that limit expires (`docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` contains no `timed` text). The Codex behavior is therefore treated as fail-open as well. Decision: add a bounded, fail-closed time limit to the helper's git and gh seams.
- **D-R1-2 (bound design).** A new helper function `Invoke-DocsOnlyBoundedNative` (Appendix HX, H-R3) starts the executable from a `ProcessStartInfo` with redirected standard output and standard error, waits at most `-TimeoutMilliseconds` for the exit and at most 1000 ms more for the output task, and on expiry stops the process tree (`Kill($true)`), emits nothing, and sets `$LASTEXITCODE` to 124. The seams keep the `[scriptblock]` invoker form and their capture statements (`& $GitInvoker -C $WorktreeRoot @GitArgs 2>$null`, `& $GhInvoker @GhArgs 2>$null`); only the default invokers change, to `{ Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 3000 }` and `{ Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList $args -TimeoutMilliseconds 7000 }`. Every caller already treats a non-zero exit as a denial (M3, M4, M5, M6), so exit code 124 denies. Worst case for one gh call and three git calls: (7 + 1) + 3 x (3 + 1) = 20 s, below the 30 s Codex registration timeout. Process start uses an injectable `[scriptblock] $ProcessStarter` (default `{ param($StartInfo) [System.Diagnostics.Process]::Start($StartInfo) }`), the narrow ScriptBlock seam that `.claude/rules/powershell.md` line 51 sanctions; it is the only new `&`-invoked variable and is a `[scriptblock]` parameter of the same file (rule R1-15). The function sets `$LASTEXITCODE` with `Set-Variable -Scope Global` because the seams read `$LASTEXITCODE` after the invoker, as they do after a native command; this reproduces the existing seam contract rather than adding new shared state. The function contains no clock read; the waits are the .NET `WaitForExit(int)` and `Task.Wait(int)` limits. A defect in the runner can only produce a seam failure or unreadable output, both of which deny; it cannot widen the allow path, because every allow still requires a hex head, a resolved base commit, a NUL-terminated listing, and only `docs/` paths.
- **D-R1-3 (create side out of scope for the bound).** `Invoke-PrAuthorDocsOnlyGitExe` in `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` runs local git only (no network call), predates this item (#901), is a separate seam by spec Design item 3, and is not named by CR-1. It is not edited (rule R1-13).
- **D-R1-4 (CR-2 option).** The review offered documenting the limit or comparing an envelope working directory. No hook under `.claude/hooks` reads an envelope `cwd` field (code review CR-2 evidence), so the documentation option is taken: Appendix HX edit H-R1 and Appendix GX edits GX-1 and GX-2.
- **D-R1-5 (CR-3 discrimination).** The row named `B equals -B=main` keeps its name and its value and gains `--base main`, so it is decided by the token loop instead of the missing-base rule, and AC-1's `-B=main` row stays accurate. The pre-#927 `StartsWith('-B')` rule also denies it, so a new row `B cluster with equals -dB=other` is added; that row returns `main` under the pre-#927 rule (the token does not begin with `-B`) and therefore fails against the old code. [P1-T3] records the pre-#927 rule from the merge-base blob.
- **D-R1-6 (CR-5 verification and fallback).** [P1-T2] shows that the Codex gate and its dot-sourced siblings contain none of the Claude seam names and no `Import-Module`, so the Claude module imports, the three guarded `Get-*OrchestratorCheckpointContent` mocks, the three Claude-module mocks, the helper dot-source, and the probe row are removed from suite E. The discovery guard then computes a closure with no seam for suite E (rule R1-15). Fallback (authorized): if [P7-T3] reports J15a `0`, the executor applies the reverse edits TE-R (Appendix TX), records `CR5_DECISION: RETAINED` with the failing guard finding in the [P7-T3] artifact, and restarts the Phase 7 loop.
- **D-R1-7 (CR-6 canonical copy).** `research/2026-10-15T19-46-merge-gate-addendum-research.md` is the canonical copy: its line 8 states it is the convention-compliant copy that `.claude/hooks/validate-task-researcher-output.ps1` requires, and the original plan (line 11) and the Phase 0 read list already cite it. `spec.md` lines 12 and 384 are edited to cite it. `research/research-addendum-merge-gate.2026-10-15T19-46.md` is retained (operator constraint: no deletion) and gains a superseded-duplicate line in its header.
- **D-R1-8 (CR-7, CR-8).** No action. CR-7 records 10 lines of headroom in `.claude/hooks/enforce-epic-merge-gate.ps1`; this cycle adds 1 line (491). CR-8 is the deliberate duplication of spec Design item 3.
- **D-R1-9 (CR-10).** AC-18 and AC-M23 gain the `**[CI-dependent]**` marker and the qualifier `(analyzer half)`; criterion text, prefix (`- [ ] AC-18 (`, `- [ ] AC-M23 (`), and checkbox state are unchanged. Check-off ownership stays with the original plan [P8-T9] and [P8-T10].
- **D-R1-10 (PA-1 route).** Under the coordinator constraint, `artifacts/pester/powershell-coverage.xml` is not regenerated by a direct `Invoke-PoshQCTest` run and is not copied from CI (remediation-inputs "Do Not Do"). The CI artifact of the final code commit is the coverage evidence. The MCP runs of this cycle rewrite `artifacts/pester/*` with scoped results again, so the `validate-feature-review-coverage` stop hook may still read a scoped file at the next review; [P9-T3] records this for the coordinator.
- **D-R1-11 (supersession of original-plan tokens).** After Phase 3 the helper defines nine functions and its default invokers no longer contain `git @args` or `gh @args`; the original-plan acceptance tokens of [P2-T1] (function count `8`) and [P2-T9] (the `{ git @args` and `{ gh @args` defaults) and the line counts of [P6-T7] describe the pre-R1 tree and are superseded for the files this cycle edits by [P7-T6] and [P7-T8]. Those original tasks stay checked as historical records; no original-plan task reruns them.
- **D-R1-12 (AC-M24 entry-point line).** `.codex/hooks/enforce-epic-merge-gate.ps1` line 403 after GX-2 (402 before), the entry-point statement that begins `$decision = Invoke-CodexEpicMergeDecision -PayloadRaw`, is a changed executable line that runs only when the hook executes as a process; CI run 38855083321 reports it `ci=0`. It is recorded with its line number and reason instead of a covered count. Spec edit S-15 revises the AC-M24 wording (revision 1.3), and edit OP-1 aligns the original plan [P8-T3]. No criterion is added or removed, and the AC-M24 checkbox is unchanged.
- **D-R1-13 (original plan step-list command).** The original plan [P8-T2] reads the `poshqc / PowerShell QC` step rows with a `select(.name == ...)` jq filter, a command shape the executor isolation guard refuses. Edits OP-2 and OP-3 replace it with the job-labelled step listing that this plan's [P8-T2] uses, so S9 can run that task. The acceptance intent (the `Format PowerShell` and `Analyze PowerShell` steps of `poshqc / PowerShell QC` read `success`) is unchanged.

---

## 4. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `FEATURE/evidence/remediation-baseline/r1-phase0-instructions-read.<timestamp>.md` after reading, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `FEATURE/remediation-inputs.2026-10-16T05-09.md`, `FEATURE/policy-audit.2026-10-16T05-09.md`, `FEATURE/code-review.2026-10-16T05-09.md`, `FEATURE/feature-audit.2026-10-16T05-09.md`, `FEATURE/spec.md`, `FEATURE/remediation-plan.2026-10-16T05-25.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (17 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: '` on the new artifact prints `17` and `grep -c '^Policy Order:'` on it prints `1`; `grep -c -E '^[[:space:]]*DIRECTIVE:[[:space:]]*PREFLIGHT VALIDATION ONLY[[:space:]]*$' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T05-25.md` prints `0` (exit 1), recorded on the labelled lines `DIRECTIVE_LINE_COUNT: 0` and `DIRECTIVE_GREP_EXIT_CODE: 1` (no `ExpectedExitCode:` field is written, because this artifact's `EXIT_CODE:` describes the Read command, rule R1-1); a count of `1` stops the plan before [P0-T12]. The anchored pattern does not match the task line that quotes it, because that line begins with `- [ ]`.
- [x] [P0-T2] Write `FEATURE/evidence/remediation-baseline/r1-branch-state.<timestamp>.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin main`; `git fetch origin bug/pr-author-docs-only-exemption-hardening-927`; `git merge-base HEAD origin/main`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `git rev-parse --show-toplevel`. Acceptance: the first prints `bug/pr-author-docs-only-exemption-hardening-927`; every status line either begins with `?? docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/` or is exactly ` M docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T05-25.md` (this plan's checkbox state); both fetches exit 0; the merge base is recorded as `MERGE_BASE: <40-hex>`; `HEAD` is recorded as `R1_START_HEAD: <40-hex>` and equals the origin branch value; the top-level output is used as the MCP `workspace_root` and recorded only as `WORKSPACE_ROOT: <WORKSPACE_ROOT>` (rule R1-2). A different branch, a status line outside `FEATURE/`, or a local head that differs from the origin head stops the plan as BLOCKED.
- [x] [P0-T3] Write `FEATURE/evidence/remediation-baseline/r1-route.<timestamp>.md` (rule R1-10, audit record only). Commands: `grep -o -E '"(route_id|path_selected|next_step)"[[:space:]]*:[[:space:]]*"[^"]*"' artifacts/orchestration/orchestrator-state.json`; `grep -c -F -e 'S12_complete' artifacts/orchestration/orchestrator-state.json`. Acceptance: the printed values are recorded verbatim as `ROUTE_RECORD:` lines and the count as `S12_COMPLETE_COUNT: <n>`; when the first command exits non-zero (file absent or no key), the artifact records `ROUTE_RECORD: none` (this task authorizes that branch). This task does not stop the plan, because this cycle writes three production PowerShell files (rule R1-10).
- [x] [P0-T4] Write `FEATURE/evidence/remediation-baseline/r1-line-counts-parity.<timestamp>.md`. Commands: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`; `cmp -s` of `.claude/hooks/hook-docs-only-diff.ps1` against each of the three other helper paths above; `cmp -s` of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, and `.claude/hooks/enforce-pr-author-skill.ps1` against the same name under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; `cmp -s .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; `test -f tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`. Acceptance: the counts print `397` four times, `490` twice, `410` twice, then `318`, `218`, `169`, `159`, and `242`; all eight `cmp -s` calls exit 0; `test -f` exits 1. A different count stops the plan for re-derivation of the line-count expectations of [P3-T4], [P4-T1], [P4-T3], and [P7-T6]; a `cmp` difference stops the plan as BLOCKED (pre-existing mirror drift).
- [x] [P0-T5] Write `FEATURE/evidence/remediation-baseline/r1-poshqc-format.<timestamp>.md` (write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `workspace_root` and `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: the MCP disposition is recorded; both status commands print nothing, meaning the formatter rewrote no PowerShell file. Any listed path stops the plan as BLOCKED with the paths recorded as `BASELINE_FORMAT_DRIFT:` lines; the executor does not revert them.
- [x] [P0-T6] Write `FEATURE/evidence/remediation-baseline/r1-poshqc-analyze.<timestamp>.md`. Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` and `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned` and the status command prints nothing. `MCP_CALL: error` stops the plan as BLOCKED. The `Output Summary:` states that the MCP result carries no finding count and that the CI `Analyze PowerShell` step is the finding source ([P8-T2]).
- [x] [P0-T7] Write `FEATURE/evidence/remediation-baseline/r1-poshqc-test.<timestamp>.md` (baseline Pester). Commands: R1-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` and `scan_folders` = `SCAN_TEST`; R1-JUNIT J1 to J3, J5, J6, J10 to J15. Acceptance: J1 shows the JUnit file was rewritten by this run; J2 is recorded as `R1_BASE_TESTSUITES: tests=<n> failures=<n> errors=<n>` and its failures value as `R1_FAIL_BASE: <n>`; the J3 lines are recorded verbatim as `R1_B_FAILED:` lines (or `R1_B_FAILED: none`) and their count equals `R1_FAIL_BASE`; J5 prints `0`; J6 prints three values recorded as `R1_J6_BASE: <docs-only> <exemption> <decision>`; J10 prints six values recorded as `R1_J10_BASE: <A> <B> <C> <D> <E> <F>`, with F equal to `0` and each of A to E greater than `0`; every J11 value is `0`; J12 prints `0`; every J13 count is greater than `0`; J14 prints `1` and `1`; J15a prints `1`, J15b prints `1`, and J15c prints `0`. J1 without a rewrite stops the plan as BLOCKED with `POSHQC_JUNIT_NOT_WRITTEN`; a non-zero J5, J11, or J12 stops the plan as BLOCKED (the item's suites fail before this cycle).
- [x] [P0-T8] Write `FEATURE/evidence/remediation-baseline/r1-pytest-contracts.<timestamp>.md`. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`. Acceptance: exit 0 and the final summary line, recorded verbatim, reports `passed` with no `failed` or `error` count. A failure stops the plan as BLOCKED.
- [x] [P0-T9] Prepare the scratch readers (rule R1-12; files outside the repository, not committed) and write `FEATURE/evidence/remediation-baseline/r1-scratch-readers.<timestamp>.md`. Commands: `grep -c -F -e 'def find_classes' SCRATCH/927/tools/read_coverage_927.py`; Write `SCRATCH/927/tools/read_report_totals_927.py` with the exact content of Appendix S2 (Write tool); `grep -c -F -e 'def report_line' SCRATCH/927/tools/read_report_totals_927.py`; `mkdir -p SCRATCH/927/r1-out`. Acceptance: the two greps print `1` and `1`; `mkdir` exits 0. When the first grep does not print `1`, the executor writes `SCRATCH/927/tools/read_coverage_927.py` with the exact content of Appendix S of the original plan (`plan.2026-10-15T07-41.md`, section 14) and reruns the grep (this task authorizes that branch).
- [x] [P0-T10] Write `FEATURE/evidence/remediation-baseline/r1-ci-coverage-baseline.<timestamp>.md` (merge-base coverage baseline; PA-1 baseline values). Commands: `gh run view 38852748136 --json headSha,status,conclusion,event`; `gh run download 38852748136 -n poshqc-test-results -D SCRATCH/927/ci-base/38852748136`; `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-base/38852748136/powershell-coverage.xml SCRATCH/927/ci-base/38852748136/pester-junit.xml`; `poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-base/38852748136/powershell-coverage.xml .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the run's `headSha` equals `MERGE_BASE` from [P0-T2] and its status is `completed`, recorded as `BASELINE_CI_RUN_ID: 38852748136`; the download exits 0; both readers exit 0; the `REPORT_LINE:` line, the `JUNIT_TOTALS:` line, and the five `COVERAGE_RESULT:` lines are copied verbatim, giving numeric `covered`, `missed`, and `line_pct` values. When the `headSha` differs from `MERGE_BASE` or the download fails, the executor runs `gh run list --workflow ci.yml --commit <MERGE_BASE> --json databaseId,headSha,status,conclusion --limit 10` and repeats the download and readers for the first listed completed run into `SCRATCH/927/ci-base/<databaseId>`; when no run yields the artifact, the artifact records `BASELINE_COVERAGE: UNAVAILABLE` with the list output (this task authorizes both branches), and [P8-T4] then reports `REMEDIATION_REQUIRED`.
- [x] [P0-T11] Write `FEATURE/evidence/remediation-baseline/r1-ci-pre-run.<timestamp>.md` (supporting snapshot of the reviewed code; non-blocking). Command: `gh run view 38855083321 --json headSha,status,conclusion,event`. Acceptance: the output is recorded verbatim as `PRE_RUN:`. When `status` is `completed`, the executor also runs `gh run download 38855083321 -n poshqc-test-results -D SCRATCH/927/ci-pre/38855083321`, then `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-pre/38855083321/powershell-coverage.xml SCRATCH/927/ci-pre/38855083321/pester-junit.xml` and `poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-pre/38855083321/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`, and copies their output lines verbatim; otherwise it records `PRE_RUN_READ: not completed at <timestamp>` and continues without waiting (this task authorizes that branch). This snapshot is supporting data only; PA-1 is closed only by [P8-T3].
- [x] [P0-T12] Commit and push Phase 0 (rule R1-14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R1 remediation baseline evidence`.

### Phase 1 — Research and Decisions

- [x] [P1-T1] Write `FEATURE/evidence/other/r1-cr1-timeout-research.<timestamp>.md` (CR-1, decision D-R1-1). Commands: `grep -n -i -e 'timed-out' docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md`; `grep -c -F -e "doesn't block the tool call" docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md`; `grep -c -F -e 'timeout' .claude/settings.json`; `grep -n -F -e 'enforce-epic-merge-gate.ps1' .claude/settings.json`; `grep -n -F -e 'enforce-epic-merge-gate.ps1' .codex/config.toml`; `grep -n -F -e 'timeout = 30' .codex/config.toml`; `grep -c -i -e 'timed' docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`. Acceptance: the first prints three lines numbered `67`, `71`, and `119`; the second prints `1`; the third prints `0` (exit 1, recorded on its labelled line); the fourth prints one line numbered `114`; the fifth prints lines `142` and `143`; the sixth output includes a line numbered `144` (the timeout of the registration whose command lines are `142` and `143`); the seventh prints `0` (exit 1). The artifact records `CLAUDE_TIMEOUT_SEMANTICS: fail-open (the tool call continues through the permission flow)`, `CODEX_TIMEOUT_SEMANTICS: not recorded in repository sources; treated as fail-open`, `CLAUDE_GATE_TIMEOUT: none registered`, `CODEX_GATE_TIMEOUT: 30 s`, and `CR1_DECISION: BOUND_ADDED`.
- [x] [P1-T2] Write `FEATURE/evidence/other/r1-cr5-verification.<timestamp>.md` (CR-5, decision D-R1-6). Commands: `grep -c -E -e 'Get-WorktreeItemCheckpointText|Get-WorktreeItemLiveRoot|Get-WorktreeRunCheckpointText|WorktreeItemResolution|WorktreeRunResolution|Get-ChildOrchestratorCheckpointContent|Get-EpicOrchestratorCheckpointContent|Get-ParallelOrchestratorCheckpointContent|Import-Module' .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/hook-dependency-guard.ps1 .codex/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-heredoc.ps1 .codex/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-payload.ps1 .codex/hooks/hook-command-payload-powershell.ps1 .codex/hooks/hook-command-invocation-operands.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `grep -n -F -e "-Surface 'Claude'" tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`. Acceptance: the first prints nine lines, each ending in `:0` (exit 1, recorded with `ExpectedExitCode: 1` in this artifact); the second prints one line numbered `62`. The artifact records `CR5_DECISION: REMOVE`. Any non-zero count records `CR5_DECISION: RETAIN` with the matching file, and Phase 5 then skips [P5-T1] (this task authorizes that branch; [P9-T3] reports CR-5 as retained with the reason).
- [x] [P1-T3] Write `FEATURE/evidence/other/r1-cr3-discrimination.<timestamp>.md` (CR-3, decision D-R1-5). Commands: `git show afa951ac0207eae934ac695e7340f18b3cf77522:.claude/hooks/enforce-pr-author-skill.docs-only.ps1 > SCRATCH/927/r1-out/docs-only-merge-base.ps1`; `grep -n -F -e "StartsWith('-B'" SCRATCH/927/r1-out/docs-only-merge-base.ps1`; `grep -c -F -e 'IndexOfAny' SCRATCH/927/r1-out/docs-only-merge-base.ps1`; `grep -c -F -e 'IndexOfAny' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`. Acceptance: `git show` exits 0; the second prints exactly one line, recorded verbatim; the third prints `0`; the fourth prints `1`. The artifact records `OLD_RULE: StartsWith('-B')`, `OLD_RESULT --base main -B=main: denied (row passes under old and new code)`, and `OLD_RESULT -dB=other: base main resolved (row fails under old code)`. Any other result stops the plan for revision of decision D-R1-5.
- [x] [P1-T4] Write `FEATURE/evidence/other/r1-decisions.<timestamp>.md`. Command recorded: `Decision record for R1`; `EXIT_CODE: 0`. Content: one line each `DECISION D-R1-2: bound gh 7000 ms, git 3000 ms, output 1000 ms, expiry exit 124, worst case 20 s`, `DECISION D-R1-3: create-side seam not bounded (local git only; not edited)`, `DECISION D-R1-4: CR-2 documented in three headers; no envelope cwd comparison`, `DECISION D-R1-7: canonical research copy research/2026-10-15T19-46-merge-gate-addendum-research.md`, `DECISION D-R1-8: CR-7 no action (491 of 500 lines after R1)`, `DECISION D-R1-8: CR-8 no action (spec Design item 3)`, `DECISION D-R1-10: PA-1 closed from CI artifact (Option A); artifacts/pester not regenerated`. Acceptance: `grep -c '^DECISION D-R1-' ` on the new artifact prints `7`.
- [x] [P1-T5] Commit and push Phase 1 (rule R1-14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R1 timeout research and remediation decisions`.

### Phase 2 — Regression Rows (expect-fail for the bound)

- [x] [P2-T1] Write the new suite F `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` with the exact content of Appendix F (Write tool). Acceptance: `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `188`; `grep -c -E "^[[:space:]]+It '" tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `8`; `grep -c -E '^[[:space:]]+# Arrange' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `8`; the Write is not denied by the purity hook.
- [x] [P2-T2] Edit suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`: apply Appendix TX edits TD-1 and TD-2 with Edit. Acceptance: `grep -c -F -e 'Get-CodexDocsOnlyFakeProcess' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `2`; `grep -c -F -e '(codex copy, issue #927)' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `7`; `grep -c '^' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `237`; the Edit is not denied by the purity hook.
- [x] [P2-T3] Edit suite B `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`: apply Appendix TX edits TB-1 to TB-5 with Edit. Acceptance: `grep -c -F -e 'exit 124' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `3`; `grep -c -F -e '--match-head-commit=' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `3`; `grep -c -F -e "GhOutput = '[]'" tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `1`; `grep -c -F -e '--auto=true' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `1`; `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `235`.
- [x] [P2-T4] Edit the DocsOnly suite `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`: apply Appendix TX edit TX-1 with Edit (CR-3). Acceptance: `grep -c -F -e '--base main -B=main' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e '-dB=other' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `1`; `grep -c -F -e 'gh pr create -B=main' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `0`; `grep -c '^' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints `243`.
- [x] [P2-T5] Write `FEATURE/evidence/regression-testing/r1-test-purity.<timestamp>.md` (rule R1-11). Command: `grep -c -E -e 'Mock[[:space:]]+.?(git|gh)\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|ProcessStartInfo|function[[:space:]]+(global:|script:)?(git|gh)\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`. Acceptance: the nine printed counts are each `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [x] [P2-T6] [expect-fail] Write `FEATURE/evidence/regression-testing/r1-expect-fail.<timestamp>.md` (fail-before run against the unchanged helper). Commands: R1-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` and `scan_folders` = `SCAN_TEST`; R1-JUNIT J1 to J3, J5, J6, J10, J11, J16. The artifact's first `Command:` is the J5 command and its `EXIT_CODE:` is the J5 exit code; the MCP disposition is recorded as `MCP_CALL:` (either disposition is accepted for this run). Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `R1_J6_BASE` with the docs-only value plus 1; J10 prints A = base, B = base + 7, C = base, D = base, E = base, F = `0` (bases from `R1_J10_BASE`); J11 prints `0`, `0`, `0`, `6`, `0`, and `13`; J16 prints `1` with `status="Failed"` for each token F1 to F13 and D1 to D6 of Appendix R1-T, and `1` with `status="Passed"` for each token B1 to B7, X0, and X1; the J2 failures value equals `R1_FAIL_BASE + 19`; every `R1_B_FAILED` line of [P0-T7] is still present in J3. Any other failing row is a test-authoring defect: the executor corrects the test text only (never a hook) and reruns this task.
- [x] [P2-T7] Commit and push Phase 2 (rule R1-14). Paths: `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `test(927): add bounded-runner, lookup, and override rows (expect-fail)`.

### Phase 3 — Bounded gh and git Calls in the Shared Helper (CR-1, CR-2)

- [x] [P3-T1] Edit `.claude/hooks/hook-docs-only-diff.ps1`: apply Appendix HX edit H-R3 (insert `Invoke-DocsOnlyBoundedNative` before `Invoke-DocsOnlyGitExe`) with Edit. Acceptance: `grep -c -F -e 'function Invoke-DocsOnlyBoundedNative {' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c '^function ' .claude/hooks/hook-docs-only-diff.ps1` prints `9`; `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; the next Bash call is not denied (rule R1-7).
- [x] [P3-T2] Edit `.claude/hooks/hook-docs-only-diff.ps1`: apply Appendix HX edits H-R4 and H-R5 (default invokers) with Edit. Acceptance: `grep -c -F -e 'git @args' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -F -e 'gh @args' .claude/hooks/hook-docs-only-diff.ps1` prints `0`; `grep -c -F -e '-TimeoutMilliseconds 3000 }' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '-TimeoutMilliseconds 7000 }' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '& $GhInvoker @GhArgs' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; the next Bash call is not denied (rule R1-7).
- [x] [P3-T3] Edit `.claude/hooks/hook-docs-only-diff.ps1`: apply Appendix HX edits H-R1 (residual limits and time limit) and H-R2 (`.NOTES`) with Edit. Acceptance: `grep -c -F -e 'Time limit:' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'working directory set by an earlier shell call' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'reports exit code 124, which denies' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'through the -ProcessStarter parameter' .claude/hooks/hook-docs-only-diff.ps1` prints `1`.
- [x] [P3-T4] Write `FEATURE/evidence/qa-gates/r1-helper-structure.<timestamp>.md`. Commands: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e "'fetch'" .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e 'Import-Module' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e 'Get-Content' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e '(Get-Location).Path' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -E -e 'ReadAllText|ReadAllLines|Invoke-Expression' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -E -e '^[[:space:]]*\. ' .claude/hooks/hook-docs-only-diff.ps1`. Acceptance: the first prints `478`; every other command prints `0` (each exits 1, recorded on its labelled line).
- [x] [P3-T5] Copy the helper to its three other paths (rule R1-9). Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`; then `cmp -s` of the canonical file against each of the three copies. Acceptance: the three `cp` calls exit 0 and the three `cmp -s` calls exit 0.
- [x] [P3-T6] Write `FEATURE/evidence/qa-gates/r1-helper-identity.<timestamp>.md` (AC-M2 hash half). Commands: `git hash-object` on each of the four helper paths; `grep -m 1 -o -E '^HELPER_HASH: [0-9a-f]{40}' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/p2-helper-identity.2026-10-16T02-37.md`. Acceptance: the four printed hashes are equal and recorded once as `R1_HELPER_HASH: <40-hex>` with the four paths listed; the value differs from the prior hash printed by the grep, which is recorded as `PRIOR_HELPER_HASH: <40-hex>`.
- [x] [P3-T7] Commit and push Phase 3 (rule R1-14). Paths: the four helper paths and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `fix(927): bound the docs-only gh and git calls and deny on expiry`.

### Phase 4 — Merge-Gate Header Residual Limits (CR-2)

- [x] [P4-T1] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: apply Appendix GX edit GX-1 with Edit. Acceptance: `grep -c -F -e 'made by an earlier Bash call' .claude/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c '^' .claude/hooks/enforce-epic-merge-gate.ps1` prints `491`; the next Bash call is not denied (rule R1-7).
- [x] [P4-T2] Copy the Claude gate to its mirror (rule R1-9). Commands: `cp .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`. Acceptance: both exit 0.
- [x] [P4-T3] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: apply Appendix GX edit GX-2 with Edit. Acceptance: `grep -c -F -e 'earlier shell call is not visible either' .codex/hooks/enforce-epic-merge-gate.ps1` prints `1`; `grep -c '^' .codex/hooks/enforce-epic-merge-gate.ps1` prints `411`.
- [x] [P4-T4] Copy the Codex gate to its mirror (rule R1-9). Commands: `cp .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: both exit 0.
- [x] [P4-T5] Write `FEATURE/evidence/qa-gates/r1-gate-headers.<timestamp>.md` (CR-2, AC-M21 continuity). Commands: `grep -c -F -e 'GH_REPO or GH_HOST' .claude/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`; `grep -c -F -e 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`; `grep -c -F -e '--match-head-commit' .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the first prints `1` for each of the three files; the second and third print a value of at least `1` for each file; all values are recorded.
- [x] [P4-T6] Commit and push Phase 4 (rule R1-14). Paths: `.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record the working-directory residual limit in the merge gates`.

### Phase 5 — Test Hygiene (CR-5, CR-9)

- [x] [P5-T1] Edit suite E `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`: apply Appendix TX edits TE-1, TE-2, and TE-3 with Edit (CR-5; skipped only when [P1-T2] recorded `CR5_DECISION: RETAIN`). Acceptance: `grep -c -F -e 'Invoke-EpicStateInterceptionProbe' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `0`; `grep -c -F -e 'EpicStateIsolation' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `0`; `grep -c -F -e 'Import-Module' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `0`; `grep -c -F -e 'Mock Invoke-DocsOnlyGhExe' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `2`; `grep -c '^' tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` prints `149`.
- [x] [P5-T2] Edit suite A `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`: apply Appendix TX edits TA-1 to TA-5 with Edit (CR-9). Acceptance: `grep -c -E '^[[:space:]]+# Arrange' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `21`; `grep -c -E "^[[:space:]]+It '" tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `21`; `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` prints `328`.
- [x] [P5-T3] Edit suite B `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`: apply Appendix TX edits TB-6 to TB-10 with Edit (CR-9). Acceptance: `grep -c -E '^[[:space:]]+# Arrange' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `13`; `grep -c -E "^[[:space:]]+It '" tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `13`; `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` prints `245`.
- [x] [P5-T4] Edit suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`: apply Appendix TX edit TD-3 with Edit (CR-9). Acceptance: `grep -c -E '^[[:space:]]+# Arrange' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `7`; `grep -c -E "^[[:space:]]+It '" tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `7`; `grep -c '^' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `239`.
- [x] [P5-T5] Write `FEATURE/evidence/regression-testing/r1-arrange-markers.<timestamp>.md` (CR-9). Commands: for each of suites A, B, D, E, and F, `grep -c -E "^[[:space:]]+It '" <suite>` and `grep -c -E '^[[:space:]]+# Arrange' <suite>`. Acceptance: the pairs are `21 21`, `13 13`, `7 7`, `7 7`, and `8 8` in that order (for E, `8 7` when [P1-T2] recorded `CR5_DECISION: RETAIN` or the CR-5 fallback of decision D-R1-6 has run, because the probe row is retained); all values are recorded.
- [x] [P5-T6] Commit and push Phase 5 (rule R1-14). Paths: suites A, B, D, E and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `test(927): remove unused Claude seams from the Codex suite and add Arrange markers`.

### Phase 6 — Documentation Alignment (CR-6, CR-10, spec revision 1.3)

- [x] [P6-T1] Edit `FEATURE/spec.md`: apply Appendix SX edits S-3 and S-14 with Edit (CR-6 citations). Acceptance: `grep -c -F -e 'research-addendum-merge-gate.2026-10-15T19-46.md' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `0`; `grep -c -F -e '2026-10-15T19-46-merge-gate-addendum-research.md' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `2`.
- [x] [P6-T2] Edit `FEATURE/research/research-addendum-merge-gate.2026-10-15T19-46.md`: apply Appendix RX edit RX-1 with Edit (CR-6 superseded-duplicate line; no deletion, no rename). Acceptance: `grep -c -F -e 'Superseded duplicate' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research-addendum-merge-gate.2026-10-15T19-46.md` prints `1`; `grep -c -F -e 'Superseded duplicate' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/2026-10-15T19-46-merge-gate-addendum-research.md` prints `0`.
- [x] [P6-T3] Edit `FEATURE/spec.md` and `FEATURE/plan.2026-10-15T07-41.md`: apply Appendix SX edits S-11, S-12, and S-15 and Appendix OX edits OP-1, OP-2, and OP-3 with Edit (CR-10; decisions D-R1-12 and D-R1-13). Acceptance: `grep -c -F -e 'except the Codex gate entry-point statement' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`; `grep -c -F -e 'except the Codex gate entry-point statement' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md` prints `1`; `grep -c -F -e '.name as $j' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md` prints `1`; `grep -c -F -e 'select(.name ==' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md` prints `0` (exit 1, expected); `grep -c -F -e 'among the rows whose first field is' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md` prints `1`; `grep -c -F -e '**[CI-dependent]**' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `7`; `grep -c -F -e '- [ ] AC-18 (toolchain) **[CI-dependent]** (analyzer half):' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`; `grep -c -F -e '- [ ] AC-M23 (toolchain, merge side) **[CI-dependent]** (analyzer half):' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`.
- [x] [P6-T4] Edit `FEATURE/spec.md`: apply Appendix SX edits S-1, S-2, S-4 to S-10, and S-13 with Edit (revision 1.3 record of the CR-1 and CR-2 design changes). Acceptance: `grep -c -F -e 'Revision note (version 1.3' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`; `grep -c -F -e '- **Version:** 1.3' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1`; `grep -c -F -e 'Invoke-DocsOnlyBoundedNative' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `6`; `grep -c -F -e '{ git @args 2>$null }]' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `1` (the create-side technical specification, which is unchanged); `grep -c -F -e '{ gh @args 2>$null }' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` prints `0`.
- [x] [P6-T5] Write `FEATURE/evidence/qa-gates/r1-doc-edits.<timestamp>.md` (CR-6, CR-10; checkbox state unchanged). Commands: `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[[ x]\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `git diff --name-status R1_START_HEAD -- docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research` with the [P0-T2] value substituted for `R1_START_HEAD`; `git status --porcelain -- docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research`. Acceptance: the counts print `41`, `6`, and `47`; the diff prints exactly one line, `M` followed by the path of `research-addendum-merge-gate.2026-10-15T19-46.md`; the status prints that same file as modified and nothing else.
- [x] [P6-T6] Commit and push Phase 6 (rule R1-14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): align research citation and mark CI-dependent criteria (spec 1.3)`.

### Phase 7 — Final QC Loop

Restart rule: run [P7-T1] to [P7-T11] in order. If any task fails, or [P7-T1] or [P7-T2] rewrites any file, apply the fix (a rewritten or fixed helper requires rerunning [P3-T5]; a rewritten or fixed gate requires rerunning [P4-T2] or [P4-T4]), then commit and push the fix per rule R1-14 (paths: each fixed file, its copy targets, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`; subject `fix(927): R1 final QC loop pass <n> corrections`), and only then restart at [P7-T1]. The CR-5 fallback of decision D-R1-6 is applied the same way. Each pass writes new artifacts with new write-time stamps. The loop ends only when one pass completes [P7-T1] to [P7-T11] with no failure and no file change. Type checking does not apply to PowerShell.

- [x] [P7-T1] Write `FEATURE/evidence/qa-gates/r1-qc-format.<timestamp>.md` (QC step 1; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `workspace_root` and `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: the MCP disposition is `returned`; both status commands print nothing, meaning the formatter rewrote no PowerShell file in this pass. When the after-status lists a path, the executor records, for each listed path, `FORMAT_REWRITE: <path>`, the output of `git diff HEAD -- <path>` verbatim (the formatter diff), and `POST_FORMAT_COUNT: <path> <n>` from `grep -c '^' <path>`; the task then fails and the Phase 7 restart rule applies, with the formatter output kept as the fix (it is never reverted).
- [x] [P7-T2] Write `FEATURE/evidence/qa-gates/r1-qc-analyze.<timestamp>.md` (QC step 2). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` and `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status command prints nothing. The analyzer finding count is read from CI at [P8-T2].
- [x] [P7-T3] Write `FEATURE/evidence/qa-gates/r1-qc-pester.<timestamp>.md` (QC step 3). Commands: R1-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` and `scan_folders` = `SCAN_TEST`; R1-JUNIT J1 to J3, J5, J6, J10 to J16. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints the `R1_J6_BASE` values with the docs-only value plus 1 and the other two unchanged; J10 prints A = base, B = base + 7, C = base, D = base + 6, E = base - 1, F = `13` (E = base when [P1-T2] recorded `CR5_DECISION: RETAIN` or the CR-5 fallback of decision D-R1-6 has run); every J11 value is `0`; J12 prints `0`; every J13 count is greater than `0`; J14 prints `1` and `1`; J15a prints `1`, J15b prints `0` (J15b prints `1` when CR-5 is retained), and J15c prints `1`; J16 prints `1` with `status="Passed"` for every token of Appendix R1-T; the J2 failures value equals `R1_FAIL_BASE`; every J3 line is an `R1_B_FAILED` line of [P0-T7]. Coverage is not read from this run (rule R1-3).
- [x] [P7-T4] Write `FEATURE/evidence/qa-gates/r1-qc-parity.<timestamp>.md` (AC-M2, AC-M19, AC-12). Commands: `cmp -s` of `.claude/hooks/hook-docs-only-diff.ps1` against its three other paths; `cmp -s` of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, and `.claude/hooks/enforce-pr-author-skill.ps1` against the same name under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; `cmp -s .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; `git hash-object` on the four helper paths. Acceptance: all eight `cmp -s` calls exit 0; the four helper hashes are equal and equal `R1_HELPER_HASH` of [P3-T6] unless a loop pass rewrote the helper, in which case the new value is recorded as `R1_HELPER_HASH_FINAL:`.
- [x] [P7-T5] Write `FEATURE/evidence/qa-gates/r1-qc-pytest-contracts.<timestamp>.md` (AC-12, AC-M19, AC-M20). Command: the [P0-T8] pytest command, unchanged. Acceptance: exit 0 and the final summary line reports `passed` with no `failed` or `error` count.
- [x] [P7-T6] Write `FEATURE/evidence/qa-gates/r1-qc-line-counts.<timestamp>.md` (AC-20, AC-M22; 500-line limit). Command: `grep -c '^'` on the four helper paths, the Claude gate and its mirror, the Codex gate and its mirror, suites A, B, D, E, F, and the DocsOnly suite. Acceptance: the helper paths print `478`, the Claude gate and mirror print `491`, the Codex gate and mirror print `411`, suite A prints `328`, B `245`, D `239`, E `149` (`159` when CR-5 is retained), F `188`, and the DocsOnly suite `243`; every value is below `500`. Authorized branch (formatter line-count change): when a [P7-T1] artifact of an earlier pass of this loop records `POST_FORMAT_COUNT: <path> <n>` for a file named here, the expected value for that file and for each byte copy of it (the three other helper paths, or the gate's mirror) is the `<n>` of the most recent such record instead of the value above, and the artifact records `LINE_COUNT_SOURCE: <path> post-format <n> <r1-qc-format artifact name>`, which names the artifact that holds the formatter diff. The 500-line limit still applies to every value; a post-format count of `500` or more fails this task and stops the plan for revision.
- [x] [P7-T7] Write `FEATURE/evidence/qa-gates/r1-qc-test-purity.<timestamp>.md` (AC-8 text half, rule R1-11). Command: the [P2-T5] command, unchanged. Acceptance: the nine printed counts are each `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [x] [P7-T8] Write `FEATURE/evidence/qa-gates/r1-qc-source-tokens.<timestamp>.md` (CR-1, CR-2, CR-3, CR-4, CR-5, CR-9 source halves). Commands: every grep of the acceptance conditions of [P2-T3] except its `grep -c '^'` line count (superseded by [P5-T3] and [P7-T6]: `245`), [P2-T4], [P3-T1] to [P3-T4], [P4-T1], [P4-T3], [P4-T5], [P5-T1] (only when [P1-T2] recorded `CR5_DECISION: REMOVE` and the CR-5 fallback of decision D-R1-6 has not run), and [P5-T5], rerun unchanged against the current tree. Acceptance: every count and printed line equals the value its task states, except that a `grep -c '^'` line count of a file for which the [P7-T6] formatter branch applies equals the post-format count that [P7-T6] uses.
- [x] [P7-T9] Write `FEATURE/evidence/qa-gates/r1-qc-pinned.<timestamp>.md` (AC-10, AC-M17, D5 pin; rule R1-13). Commands: `git diff --stat R1_START_HEAD HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .claude/hooks/enforce-epic-merge-gate-authorization.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` with the [P0-T2] value substituted for `R1_START_HEAD`; `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the diff prints nothing; every status line names a file of section 13 or nothing is printed.
- [x] [P7-T10] Write `FEATURE/evidence/qa-gates/r1-qc-scope.<timestamp>.md` (AC-22, AC-M21 diff half, AC-M25 diff half, rule R1-13). Commands: `git status --porcelain`; `git diff --name-only R1_START_HEAD HEAD` with the [P0-T2] value substituted; `git fetch origin main`; `git diff --name-only origin/main...HEAD`. Acceptance: every path listed by the first diff and every status line is a member of section 13 (`## 13. WRITES`) or is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`; in the second diff no path contains `hook-command-invocation`, ends with `enforce-pr-author-skill-helpers.ps1`, begins with `.claude/rules/`, begins with `.github/instructions/`, or begins with `docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901/`; every listed path beginning with `.codex/` is `.codex/hooks/enforce-epic-merge-gate.ps1` or `.codex/hooks/hook-docs-only-diff.ps1`; every listed path ending with `pack-manifests/core.json` is one of the two manifests named by spec Design item 13.
- [x] [P7-T11] Write `FEATURE/evidence/qa-gates/r1-qc-loop-record.<timestamp>.md`. Command recorded: `R1 final QC loop per Phase 7 restart rule`; `EXIT_CODE: 0`. Acceptance: the artifact lists each pass as `LOOP_PASS: <n> RESULT: <clean|restarted at P7-T1 because ...>`; its last pass is `clean` and names the artifacts of [P7-T1] to [P7-T10] from that pass; when the CR-5 fallback ran, the artifact records `CR5_DECISION: RETAINED` with the J15a finding.
- [x] [P7-T12] Commit and push Phase 7 (rule R1-14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `chore(927): record R1 final QC loop`. The commit this task pushes is `R1_FINAL_CODE_COMMIT`: [P8-T1] records its value, Phase 8 reads the CI run of that commit, and no later commit of this cycle changes a path outside `FEATURE` ([P9-T4]).

### Phase 8 — CI Coverage on the Final Code Commit (PA-1)

- [x] [P8-T1] Write `FEATURE/evidence/qa-gates/r1-ci-run.<timestamp>.md`. Commands: `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927`; `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10`. Acceptance: the two `rev-parse` values are equal and are recorded as `R1_FINAL_CODE_COMMIT: <40-hex>` (the head pushed by [P7-T12]; the only uncommitted change at this point is this plan file's checkbox state); the dispatch exits 0; the newest listed run whose `headSha` equals `R1_FINAL_CODE_COMMIT` is recorded as `R1_CI_RUN_ID: <databaseId>` with its `headSha`. When no listed run matches yet, the executor reruns only the list command until one appears (this task authorizes that repetition; it never dispatches a second time while a matching run is queued or in progress). Run `38855083321` (head `620a2e966`) is not used for PA-1, because its head is not the final code commit.
- [x] [P8-T2] Write `FEATURE/evidence/qa-gates/r1-ci-jobs.<timestamp>.md` (AC-19 supporting; AC-18 and AC-M23 analyzer half supporting). Commands: `gh run watch R1_CI_RUN_ID --interval 60 --exit-status` with the [P8-T1] value substituted; `gh run view R1_CI_RUN_ID --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`; `gh run view R1_CI_RUN_ID --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'` (the [P8-T1] value substituted in each command). Acceptance: the watch exits 0; every job row reads `success` or `skipped`, and the rows `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` each read `success`; among the rows whose first field is `poshqc / PowerShell QC`, the rows for steps `Format PowerShell`, `Analyze PowerShell`, and `Test PowerShell` each read `success`; all rows are recorded verbatim. A failure is recorded with the failing job and step names, the artifact records `R1_CI: REMEDIATION_REQUIRED`, and the executor run stops (the item returns to remediation; no PASS).
- [x] [P8-T3] Write `FEATURE/evidence/qa-gates/r1-ci-coverage.<timestamp>.md` (PA-1; AC-9, AC-21, AC-M24 supporting values). Commands: `gh run download R1_CI_RUN_ID -n poshqc-test-results -D SCRATCH/927/ci-r1/R1_CI_RUN_ID`; `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-r1/R1_CI_RUN_ID/powershell-coverage.xml SCRATCH/927/ci-r1/R1_CI_RUN_ID/pester-junit.xml`; rule R1-COV steps C1 to C5. Acceptance: the download exits 0 into a new, empty directory; every reader call exits 0; `REPORT_LINE:` shows `result=PASS` (repo-wide line coverage at or above 85.00%); `JUNIT_TOTALS:` shows `failures=0` and `errors=0`; `COVERAGE_RESULT:` shows `result=PASS` for each of the seven files of step C1 (`.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`); each of the four `AC9_LINES` statements prints `LINE_RESULT:` with `ci` greater than `0`; the step C5 tallies show `UNCOVERED 0` for `.claude/hooks/enforce-epic-merge-gate.ps1` and `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`; for `.codex/hooks/enforce-epic-merge-gate.ps1` they show `UNCOVERED 0`, or `UNCOVERED 1` where the single `ci=0` line equals the line number printed by `grep -n -F -e '$decision = Invoke-CodexEpicMergeDecision -PayloadRaw' .codex/hooks/enforce-epic-merge-gate.ps1` (`403` after GX-2), recorded as `UNCOVERED_CHANGED_LINE: .codex/hooks/enforce-epic-merge-gate.ps1:403 REASON: entry-point statement after the dot-source guard; runs only when the hook executes as a process (D-R1-12)` with the printed line number in place of `403` if a Phase 7 formatter pass moved the statement; for `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and `.claude/hooks/enforce-pr-author-skill.ps1` the changed-line coverage `COVERED / (COVERED + UNCOVERED)` is at least 85% or the file has `0` executable changed lines (`CHANGED_LINE_COVERAGE: N/A`), and every `ci=0` changed line is recorded as `UNCOVERED_CHANGED_LINE: <path>:<nr> REASON: <statement text at that line and why no row reaches it>`. The run ID, `headSha`, every reader output line (copied verbatim from the `SCRATCH/927/r1-out/` files), and the tallies are recorded. Any failed condition records `R1_CI_COVERAGE: REMEDIATION_REQUIRED` and stops the executor run.
- [x] [P8-T4] Write `FEATURE/evidence/qa-gates/r1-coverage-delta.<timestamp>.md` (PA-1 baseline vs post-change vs changed code). Command recorded: `Coverage delta from r1-ci-coverage-baseline and r1-ci-coverage`; `EXIT_CODE: 0`. Content: `REPO_LINE_BASELINE:` and `REPO_LINE_POST:` (covered, missed, line_pct); for each of the five pre-existing files, `FILE_BASELINE:` and `FILE_POST:`; for the two helper copies, `FILE_POST:` with `FILE_BASELINE: N/A (new file)`; for each of the five edited canonical hook files, `CHANGED_CODE: <path> covered=<n> executable=<n> pct=<x>` from the [P8-T3] tallies; for the two helper copies, `CHANGED_CODE: <path> whole-file pct=<x>` (new files are measured by whole-file line coverage). Acceptance: `REPO_LINE_POST` is at least 85.00%; each `FILE_POST` is at least 85.00%; each pre-existing file's `FILE_POST` is at least its `FILE_BASELINE` or at least 85.00%; each `CHANGED_CODE` percentage is at least 85.00% or N/A per [P8-T3]. When [P0-T10] recorded `BASELINE_COVERAGE: UNAVAILABLE`, the artifact states `COVERAGE_DELTA: REMEDIATION_REQUIRED` and this task fails.
- [x] [P8-T5] Commit and push Phase 8 (rule R1-14). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R1 CI coverage evidence`.

### Phase 9 — Acceptance Re-verification and Remediation Closure

- [x] [P9-T1] Write `FEATURE/evidence/qa-gates/r1-ac-reverification.<timestamp>.md`. Command recorded: `AC re-verification against R1 Phase 7 and Phase 8 evidence`; `EXIT_CODE: 0`. Content: one line per criterion: `AC-<id>: REVERIFIED <artifact names>` for AC-M1 to AC-M22 and AC-1 to AC-8, AC-10, AC-11, AC-12, AC-20, AC-22 (each citing [P7-T3] and the other Phase 7 artifact that carries its source or parity half); `AC-<id>: UNAFFECTED <reason>` for AC-M25 and AC-13 to AC-17 (no file in their scope changed in R1, shown by [P7-T10]); `AC-<id>: PENDING_CI_SUPPORTED R1_CI_RUN_ID=<id> <values>` for AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 (values from [P8-T2] and [P8-T3]; check-off stays with the original plan [P8-T5] to [P8-T10] on the pull-request run). Acceptance: `grep -c -E '^AC-M?[0-9]+: REVERIFIED '` on the artifact prints `35`; `grep -c -E '^AC-M?[0-9]+: UNAFFECTED '` prints `6`; `grep -c -E '^AC-M?[0-9]+: PENDING_CI_SUPPORTED '` prints `6`.
- [x] [P9-T2] Write `FEATURE/evidence/qa-gates/r1-ac-state.<timestamp>.md` (checkbox state unchanged by R1). Commands: `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`. Acceptance: the counts print `41` and `6`.
- [x] [P9-T3] Write `FEATURE/evidence/qa-gates/r1-remediation-closure.<timestamp>.md`. Command recorded: `R1 remediation closure`; `EXIT_CODE: 0`. Content: one line per finding: `PA-1: CLOSED r1-ci-coverage r1-coverage-delta`; `CR-1: CLOSED r1-cr1-timeout-research r1-qc-pester`; `CR-2: CLOSED r1-gate-headers r1-qc-source-tokens`; `CR-3: CLOSED r1-cr3-discrimination r1-qc-pester`; `CR-4: CLOSED r1-qc-pester`; `CR-5: CLOSED r1-cr5-verification r1-qc-pester` (or `CR-5: RETAINED <reason>` under decision D-R1-6); `CR-6: CLOSED r1-doc-edits`; `CR-7: NO_ACTION r1-decisions`; `CR-8: NO_ACTION r1-decisions`; `CR-9: CLOSED r1-arrange-markers`; `CR-10: CLOSED r1-doc-edits`; and one line `NOTE_FOR_COORDINATOR: artifacts/pester/powershell-coverage.xml holds the scoped PoshQC MCP result of [P7-T3]; PA-1 coverage evidence is the CI artifact of R1_CI_RUN_ID (decision D-R1-10)`. Acceptance: `grep -c -E '^(PA-1|CR-[0-9]+): '` on the artifact prints `11`; `grep -c -F -e 'NOTE_FOR_COORDINATOR:'` on it prints `1`.
- [x] [P9-T4] Verify that no code changed after the final code commit, then commit and push Phase 9 (rule R1-14). Commands before the commit: `git diff --name-only R1_FINAL_CODE_COMMIT HEAD` with the value recorded by [P8-T1] substituted; `git status --porcelain`. Acceptance (in addition to rule R1-14): every path listed by the diff and every status line is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`. Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R1 acceptance re-verification and remediation closure`.

---

## 5. Rule R1-JUNIT (reading the Pester JUnit file)

The PoshQC test run writes `artifacts/pester/pester-junit.xml`. Each test case is one `<testcase name="<Describe>.<Context>.<It>" status="Passed|Failed|Skipped" classname="<suite path>" .../>` element (original plan section 5). Suite patterns match the classname separator with `.`.

- **J0** before the MCP call: `stat -c %Y artifacts/pester/pester-junit.xml`; record `JUNIT_MTIME_BEFORE:` or `JUNIT_MTIME_BEFORE: absent` when `stat` exits non-zero.
- **J1** after the call: `stat -c %Y artifacts/pester/pester-junit.xml` exits 0 and prints a value greater than `JUNIT_MTIME_BEFORE` (any value when it was `absent`); record `JUNIT_MTIME_AFTER:`. Otherwise the file was not rewritten and the task fails.
- **J2** `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; record only the `tests`, `failures`, and `errors` values.
- **J3** `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`; record each printed line.
- **J5** `grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`.
- **J6** passed count per DocsOnly suite, in this order: `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill\.DocsOnly\.Tests\.ps1"' artifacts/pester/pester-junit.xml`, then the same with `DocsOnly\.Exemption\.Tests\.ps1"` and `DocsOnly\.Decision\.Tests\.ps1"`.
- **J10** passed count per suite, in the order A, B, C, D, E, F: `grep -c -E 'status="Passed" classname="[^"]*<pattern>' artifacts/pester/pester-junit.xml` with the patterns `claude-hooks.hook-docs-only-diff\.Tests\.ps1"`, `hook-docs-only-diff\.MergeExemption\.Tests\.ps1"`, `enforce-epic-merge-gate\.DocsOnly\.Tests\.ps1"`, `codex-hooks.hook-docs-only-diff\.Tests\.ps1"`, `enforce-epic-merge-gate-docs-only\.Tests\.ps1"`, and `hook-docs-only-diff\.BoundedNative\.Tests\.ps1"`.
- **J11** failed count per suite, in the J10 order, with `status="Failed"` in place of `status="Passed"`.
- **J12** merge-family failed count: `grep -c -E 'status="Failed" classname="[^"]*(enforce-epic-merge-gate|epic-execution-gates|hook-command-parser\.AcceptanceCases|hook-command-consumers\.Issue824|hook-dependency-failure\.SpecialCases|hook-dependency-guard-completeness|hook-import-failure-exemptions\.Guard)' artifacts/pester/pester-junit.xml`.
- **J13** passed count per named existing suite (each must be greater than 0), one `grep -c -E 'status="Passed" classname="[^"]*<pattern>"' artifacts/pester/pester-junit.xml` per pattern: `enforce-epic-merge-gate\.Tests\.ps1`, `enforce-epic-merge-gate\.Authorization\.Tests\.ps1`, `enforce-epic-merge-gate\.ItemResolution\.Tests\.ps1`, `enforce-epic-merge-gate\.WorktreeResolution\.Tests\.ps1`, `enforce-epic-merge-gate\.TriggerScoping\.Tests\.ps1`, `enforce-epic-merge-gate\.Coverage\.Tests\.ps1`, `hook-command-parser\.AcceptanceCases\.Tests\.ps1`, `hook-command-consumers\.Issue824\.Tests\.ps1`, `enforce-epic-merge-gate-authorization\.Tests\.ps1`, `enforce-epic-merge-gate-decision-surface\.Tests\.ps1`, `enforce-epic-merge-gate-trigger-scoping\.Tests\.ps1`, `epic-execution-gates\.Tests\.ps1`, `hook-dependency-failure\.SpecialCases\.Tests\.ps1`, `hook-dependency-guard-completeness\.Tests\.ps1`, `hook-import-failure-exemptions\.Guard\.Tests\.ps1`, `enforce-gate-suites\.EpicStateIsolation\.Discovery\.Tests\.ps1`.
- **J14** no-python guard rows: `grep -c -F -e 'across the guarded tree" status="Passed"' artifacts/pester/pester-junit.xml`; `grep -c -F -e 'ships an empty allowlist" status="Passed"' artifacts/pester/pester-junit.xml`. Each must print `1`.
- **J15** epic-state isolation discovery rows: J15a `grep -c -F -e 'enforce-epic-merge-gate-docs-only.Tests.ps1 complies with the baseline isolation form for every closure seam" status="Passed"' artifacts/pester/pester-junit.xml`; J15b `grep -c -F -e 'enforce-epic-merge-gate-docs-only.Tests.ps1 calls the interception probe from inside an It" status=' artifacts/pester/pester-junit.xml`; J15c `grep -c -F -e 'hook-docs-only-diff.BoundedNative.Tests.ps1 complies with the baseline isolation form for every closure seam" status="Passed"' artifacts/pester/pester-junit.xml`. The tokens are the tails of the `AC-4 <Path> complies ...` and `AC-6 <Path> calls ...` rows of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (lines 113 and 121); they start at the file name, so they do not depend on the path separator.
- **J16** for each token of Appendix R1-T: `grep -c -F -e '<token>" status="<Passed|Failed>"' artifacts/pester/pester-junit.xml` with the token and the status the task names substituted; each must print `1`.

## 6. Rule R1-COV (reading the CI coverage XML of the final code commit)

`<RUN>` is `R1_CI_RUN_ID`; `<XML>` is `SCRATCH/927/ci-r1/<RUN>/powershell-coverage.xml`. All reader output is written to `SCRATCH/927/r1-out/` by redirection and then copied verbatim into the [P8-T3] artifact.

- **C1 (whole-file).** `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 > SCRATCH/927/r1-out/files-<RUN>.txt`; it prints one `COVERAGE_RESULT:` line per file.
- **C2 (AC9_LINES, fixed derivation).** `grep -n -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e '$code = $LASTEXITCODE' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `grep -n -F -e 'return $failure' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` (take the larger printed line number: the catch-block return); `grep -n -F -e 'ExitCode = [int]$code' .claude/hooks/enforce-pr-author-skill.docs-only.ps1`. The file is not edited in R1, so the four numbers are `78`, `79`, `82`, and `84` (as recorded in `p6-coverage-pending-ci.2026-10-16T04-52.md`). Then `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> .claude/hooks/enforce-pr-author-skill.docs-only.ps1:<AC9_LINES> > SCRATCH/927/r1-out/ac9-<RUN>.txt`.
- **C3 (CHANGED_LINES, fixed derivation).** After `git fetch origin main`, for each edited canonical hook file (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`): `git diff -U0 origin/main...HEAD -- <file>`; for each hunk header `@@ -a,b +c,d @@` (or `+c`, meaning `d = 1`) with `d > 0`, the lines `c` to `c + d - 1`. Record each list as `CHANGED_LINES <path>: <list>`. The two helper copies are new files and are measured by whole-file coverage (C1).
- **C4 (changed-line read).** `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> .claude/hooks/enforce-pr-author-skill.docs-only.ps1:<list> .claude/hooks/enforce-pr-author-skill.ps1:<list> .claude/hooks/enforce-epic-merge-gate.ps1:<list> .claude/hooks/enforce-epic-merge-gate-resolution.ps1:<list> .codex/hooks/enforce-epic-merge-gate.ps1:<list> > SCRATCH/927/r1-out/changed-<RUN>.txt`, with each C3 list substituted.
- **C5 (tallies).** For each of the five files, with `<p>` the file path with every `.` escaped as `\.`: `grep -c -E '^LINE_RESULT: <p> nr=[0-9]+ ci=[1-9]' SCRATCH/927/r1-out/changed-<RUN>.txt` (recorded as `COVERED`), `grep -c -E '^LINE_RESULT: <p> nr=[0-9]+ ci=0 ' SCRATCH/927/r1-out/changed-<RUN>.txt` (`UNCOVERED`), and `grep -c -E '^LINE_RESULT: <p> nr=[0-9]+ NOT_EXECUTABLE_OR_ABSENT' SCRATCH/927/r1-out/changed-<RUN>.txt` (`NOT_EXECUTABLE`). A line reported `NOT_EXECUTABLE_OR_ABSENT` is a comment or non-statement line and is excluded from the denominator. Each `grep -c` that prints `0` exits 1; that exit is recorded on its labelled line and is expected.

---

## 7. Appendix F — `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (new; 188 lines)

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for Invoke-DocsOnlyBoundedNative in .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Exercises the time-bounded runner behind the default git and gh invokers through a
    test-local process starter that returns a fake process object, so no row starts a process,
    runs git or gh, waits on a clock, or writes a file. An expired wait stops the process tree
    and reports exit code 124, which the seams return and the docs-only exemption denies.
#>

Describe 'hook-docs-only-diff bounded runner (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')

        # Test-local stand-ins for the process object and the starter of Invoke-DocsOnlyBoundedNative.
        function Get-DocsOnlyFakeProcess {
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '')
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0 }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
            $process.StandardOutput | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process.StandardError | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { param([int] $Milliseconds) $this.WaitLimit = $Milliseconds; $this.Exits }
            $process | Add-Member -MemberType ScriptMethod -Name Kill -Value {
                param([bool] $EntireTree)
                if ($this.KillThrows) {
                    throw 'simulated stop failure'
                }
                $this.Killed = $EntireTree
            }
            return $process
        }
        function Invoke-DocsOnlyFakeStart {
            param($StartInfo)
            $script:DocsOnlyStartInfo = $StartInfo
            $script:DocsOnlyFakeProcess
        }
        function Invoke-DocsOnlyFakeStartThrow {
            $script:DocsOnlyStartAttempted = $true
            throw 'simulated process start failure'
        }
        function Invoke-DocsOnlyFakeBoundedGit {
            Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 2500 -ProcessStarter $script:DocsOnlyStarter
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
        $script:DocsOnlyStartInfo = $null
        $script:DocsOnlyStartAttempted = $false
        $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess
        $script:DocsOnlyStarter = ${function:Invoke-DocsOnlyFakeStart}
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    Context 'Invoke-DocsOnlyBoundedNative' {
        It 'starts the executable in the current location with each argument and redirected streams (issue #927)' {
            # Arrange
            $arguments = @('-C', 'root with space', 'status')

            # Act
            $null = Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $arguments -TimeoutMilliseconds 2500 -ProcessStarter ${function:Invoke-DocsOnlyFakeStart}

            # Assert
            $info = $script:DocsOnlyStartInfo
            $info.FileName | Should -BeExactly 'git'
            (@($info.ArgumentList) -join '|') | Should -BeExactly '-C|root with space|status'
            $info.WorkingDirectory | Should -Be (Get-Location).ProviderPath
            $info.UseShellExecute | Should -BeFalse
            $info.RedirectStandardOutput | Should -BeTrue
            $info.RedirectStandardError | Should -BeTrue
            $info.StandardOutputEncoding.WebName | Should -Be 'utf-8'
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 2500
            $script:DocsOnlyFakeProcess.StandardOutput.Task.Limit | Should -Be 1000
        }

        It 'emits <Name> as output lines (issue #927)' -ForEach @(
            @{ Name = 'two LF-terminated lines'; Text = "a`nb`n"; Expected = 'a|b' }
            @{ Name = 'CRLF-terminated lines'; Text = "a`r`nb`r`n"; Expected = 'a|b' }
            @{ Name = 'NUL-terminated diff output'; Text = "docs/a.md`0docs/b.md`0"; Expected = "docs/a.md`0docs/b.md`0" }
            @{ Name = 'empty output'; Text = ''; Expected = '' }
        ) {
            # Arrange: the row supplies the output text of a process that exits 0 in time.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Text $Text

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList @('status') -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            ($lines -join '|') | Should -BeExactly $Expected
            $global:LASTEXITCODE | Should -Be 0
            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse
        }

        It 'reports the non-zero exit code of a process that exits in time (issue #927)' {
            # Arrange
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -ExitCode 2

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList @('pr', 'view', '5') -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            $lines.Count | Should -Be 0
            $global:LASTEXITCODE | Should -Be 2
            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse
        }

        It 'stops the process tree, emits nothing, and reports 124 when <Name> (issue #927)' -ForEach @(
            @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; Killed = $true }
            @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; Killed = $true }
            @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; Killed = $false }
        ) {
            # Arrange: the row supplies which wait expires and whether stopping the process throws.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text 'docs/a.md'

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList @('pr', 'view', '5') -TimeoutMilliseconds 7000 -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            $lines.Count | Should -Be 0 -Because 'an expired wait emits no output'
            $global:LASTEXITCODE | Should -Be 124
            $script:DocsOnlyFakeProcess.Killed | Should -Be $Killed
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 7000
        }

        It 'returns the seam failure object when the process cannot start (issue #927)' {
            # Arrange
            $script:DocsOnlyStarter = ${function:Invoke-DocsOnlyFakeStartThrow}

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeBoundedGit}

            # Assert
            $script:DocsOnlyStartAttempted | Should -BeTrue -Because 'the bounded runner reached the process starter'
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }

        It 'returns exit code 124 through the git seam when the bounded call expires (issue #927)' {
            # Arrange
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $false -Text "docs/a.md`0"

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('diff', '--name-only', '-z') -GitInvoker ${function:Invoke-DocsOnlyFakeBoundedGit}

            # Assert
            $result.ExitCode | Should -Be 124
            $result.Output | Should -BeExactly ''
            (@($script:DocsOnlyStartInfo.ArgumentList) -join '|') | Should -BeExactly ('-C|' + $PSScriptRoot + '|diff|--name-only|-z')
            $script:DocsOnlyFakeProcess.Killed | Should -BeTrue
        }

        It 'routes the default git invoker through the bounded runner with a 3000 ms limit (issue #927)' {
            # Arrange
            Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status')

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'routed'
            Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'git' -and $TimeoutMilliseconds -eq 3000 -and $ArgumentList[0] -ceq '-C' -and $ArgumentList[-1] -ceq 'status' }
        }

        It 'routes the default gh invoker through the bounded runner with a 7000 ms limit (issue #927)' {
            # Arrange
            Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5')

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'routed'
            Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'gh' -and $TimeoutMilliseconds -eq 7000 -and ($ArgumentList -join ' ') -ceq 'pr view 5' }
        }
    }
}
```

## 8. Appendix HX — edits to `.claude/hooks/hook-docs-only-diff.ps1` (397 lines before, 478 after)

Apply in the order H-R3, H-R4, H-R5, H-R1, H-R2 (rule R1-7). Each Old text is unique in the file.

**H-R3** (insert the bounded runner; +70 lines). Old text:

```powershell
function Invoke-DocsOnlyGitExe {
```

New text:

```powershell
function Invoke-DocsOnlyBoundedNative {
    <#
    .SYNOPSIS
        Run git or gh with a fail-closed time limit; the body of the default seam invokers.
    .DESCRIPTION
        Starts FileName in the current file-system location with each argument passed
        unchanged and standard output and standard error redirected, then waits at most
        TimeoutMilliseconds for the exit and at most 1000 ms more for the output. When a
        wait expires, the process tree is stopped, nothing is emitted, and $LASTEXITCODE is
        set to 124, so the calling seam reports a non-zero exit and the exemption denies.
        Otherwise the output lines are emitted and $LASTEXITCODE is set to the exit code.
        Standard error is drained and discarded. A start failure throws to the calling
        seam, which returns its failure object. $LASTEXITCODE is set in the global scope
        because the seams read it after the invoker, as they do after a native command.
    .PARAMETER FileName
        The executable, git or gh, resolved from PATH.
    .PARAMETER ArgumentList
        The arguments, one element per argument.
    .PARAMETER TimeoutMilliseconds
        The longest wait for the process to exit.
    .PARAMETER ProcessStarter
        The scriptblock that starts the process from its start description; a unit test
        passes a test-local stand-in that returns a fake process object.
    .OUTPUTS
        System.String, one per output line
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $FileName,
        [AllowEmptyCollection()][string[]] $ArgumentList = @(),
        [ValidateRange(1, 10000)][int] $TimeoutMilliseconds = 3000,
        [ValidateNotNull()][scriptblock] $ProcessStarter = { param($StartInfo) [System.Diagnostics.Process]::Start($StartInfo) }
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new($FileName)
    foreach ($argument in $ArgumentList) {
        $startInfo.ArgumentList.Add($argument)
    }
    $startInfo.WorkingDirectory = $ExecutionContext.SessionState.Path.CurrentFileSystemLocation.ProviderPath
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $process = & $ProcessStarter $startInfo
    $output = $process.StandardOutput.ReadToEndAsync()
    $null = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutMilliseconds) -or -not $output.Wait(1000)) {
        try {
            $process.Kill($true)
        }
        catch {
            $null = $_
        }
        Set-Variable -Name LASTEXITCODE -Value 124 -Scope Global
        return
    }
    Set-Variable -Name LASTEXITCODE -Value ([int]$process.ExitCode) -Scope Global
    $text = [string]$output.Result
    if ($text.EndsWith("`n")) {
        $text = $text.Substring(0, $text.Length - 1)
    }
    if ($text.Length -eq 0) {
        return
    }
    foreach ($line in $text.Split("`n")) {
        $line.TrimEnd("`r")
    }
}

function Invoke-DocsOnlyGitExe {
```

**H-R4** (default git invoker; line count unchanged). Old text:

```powershell
        [ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }
```

New text:

```powershell
        [ValidateNotNull()][scriptblock] $GitInvoker = { Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 3000 }
```

**H-R5** (default gh invoker; line count unchanged). Old text:

```powershell
        [ValidateNotNull()][scriptblock] $GhInvoker = { gh @args 2>$null }
```

New text:

```powershell
        [ValidateNotNull()][scriptblock] $GhInvoker = { Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList $args -TimeoutMilliseconds 7000 }
```

**H-R1** (header residual limits and time limit; 4 lines become 14, +10). Old text:

```text
    Residual limits: a GH_REPO or GH_HOST value exported by an earlier shell command or
    inherited from the session environment is not visible in the command text; a push
    between the gh pr view lookup and the merge can change the head, which only
    --match-head-commit closes; the control is policy-level, not cryptographic.
```

New text:

```text
    Residual limits: a GH_REPO or GH_HOST value exported by an earlier shell command or
    inherited from the session environment is not visible in the command text; gh and git
    run in the WorktreeRoot the gate passes (the Claude session worktree root or the Codex
    repository root), so a working directory set by an earlier shell call is not visible
    either; a push between the gh pr view lookup and the merge can change the head, which
    only --match-head-commit closes; the control is policy-level, not cryptographic.

    Time limit: Claude Code lets a tool call continue through the permission flow when a
    PreToolUse hook exceeds its timeout, and the repository records no Codex behavior for
    that case, so this file bounds every gh and git call itself. The default invokers run
    the executable through Invoke-DocsOnlyBoundedNative: at most 7000 ms for gh and 3000 ms
    for each git call, plus at most 1000 ms for the output. An expired wait stops the
    process tree and reports exit code 124, which denies. The worst case for one gh and
    three git calls is 20 s, below the 30 s Codex registration timeout.
```

**H-R2** (`.NOTES`; 3 lines become 4, +1). Old text:

```text
    git and gh run only through Invoke-DocsOnlyGitExe and Invoke-DocsOnlyGhExe, which never
    throw; unit tests pass a test-local scriptblock through -GitInvoker and -GhInvoker so
    the seam bodies run without starting a process.
```

New text:

```text
    git and gh run only through Invoke-DocsOnlyGitExe and Invoke-DocsOnlyGhExe, which never
    throw; unit tests pass a test-local scriptblock through -GitInvoker and -GhInvoker so
    the seam bodies run without starting a process, and pass a test-local process starter
    through the -ProcessStarter parameter of Invoke-DocsOnlyBoundedNative.
```

Line arithmetic: 397 + 70 (H-R3) + 0 + 0 + 10 (H-R1) + 1 (H-R2) = 478.

## 9. Appendix GX — merge-gate header edits

**GX-1** `.claude/hooks/enforce-epic-merge-gate.ps1` (lines 43-46; 4 lines become 5, 490 to 491). Old text:

```text
    present, must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is
    not visible in the command text, and a push after the lookup can change the head unless
    --match-head-commit is passed. Like the receipt mechanism of enforce-pr-author-skill.ps1,
    this is a policy-level control, not a cryptographic one.
```

New text:

```text
    present, must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is
    not visible in the command text; gh and git run in the session worktree root, so a cd
    made by an earlier Bash call is not visible either; and a push after the lookup can
    change the head unless --match-head-commit is passed. Like the receipt mechanism of
    enforce-pr-author-skill.ps1, this is a policy-level control, not a cryptographic one.
```

**GX-2** `.codex/hooks/enforce-epic-merge-gate.ps1` (lines 14-16; 3 lines become 4, 410 to 411). Old text:

```text
    must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is not
    visible in the command text, a push after the lookup can change the head unless
    --match-head-commit is passed, and the control is policy-level, not cryptographic.
```

New text:

```text
    must equal headRefOid (OD-2). Residual limits: an ambient GH_REPO or GH_HOST is not
    visible in the command text; gh and git run in the repository root, so a cd made by an
    earlier shell call is not visible either; a push after the lookup can change the head
    unless --match-head-commit is passed; and the control is policy-level, not cryptographic.
```

## 10. Appendix TX — test edits

Each Old text below is unique in its file. Indentation is literal.

### Suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (169 lines; 237 after TD-1 and TD-2; 239 after TD-3)

**TD-1** (fakes; +25). Old text:

```powershell
        function Invoke-CodexDocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }
```

New text:

```powershell
        function Invoke-CodexDocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }

        # Test-local stand-ins for the process object and the starter of Invoke-DocsOnlyBoundedNative.
        function Get-CodexDocsOnlyFakeProcess {
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '')
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0 }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
            $process.StandardOutput | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process.StandardError | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { param([int] $Milliseconds) $this.WaitLimit = $Milliseconds; $this.Exits }
            $process | Add-Member -MemberType ScriptMethod -Name Kill -Value {
                param([bool] $EntireTree)
                if ($this.KillThrows) {
                    throw 'simulated stop failure'
                }
                $this.Killed = $EntireTree
            }
            return $process
        }
        function Invoke-CodexDocsOnlyFakeStart {
            param($StartInfo)
            $script:CodexDocsOnlyStartInfo = $StartInfo
            $script:CodexDocsOnlyFakeProcess
        }
```

**TD-2** (rows D1 to D6 at the end of the Describe; +43). Old text:

```powershell
            $result.Reason | Should -BeLike $Expected
        }
    }
}
```

New text:

```powershell
            $result.Reason | Should -BeLike $Expected
        }
    }

    It 'runs the bounded runner when <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'the process exits in time'; Exits = $true; OutputCompletes = $true; KillThrows = $false; ExitCode = 0; Output = "docs/a.md`0"; Killed = $false }
        @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; ExitCode = 124; Output = ''; Killed = $false }
    ) {
        # Arrange: the row supplies which wait expires and whether stopping the process throws.
        $script:CodexDocsOnlyFakeProcess = Get-CodexDocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text "docs/a.md`0"

        # Act
        $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList @('-C', $PSScriptRoot, 'status') -ProcessStarter ${function:Invoke-CodexDocsOnlyFakeStart})

        # Assert
        ($lines -join '|') | Should -BeExactly $Output
        $global:LASTEXITCODE | Should -Be $ExitCode
        $script:CodexDocsOnlyFakeProcess.Killed | Should -Be $Killed
        $script:CodexDocsOnlyStartInfo.FileName | Should -BeExactly 'git'
    }

    It 'routes the default git invoker through the bounded runner (codex copy, issue #927)' {
        # Arrange
        Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

        # Act
        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status')

        # Assert
        $result.Output | Should -BeExactly 'routed'
        Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'git' -and $TimeoutMilliseconds -eq 3000 }
    }

    It 'routes the default gh invoker through the bounded runner (codex copy, issue #927)' {
        # Arrange
        Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

        # Act
        $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5')

        # Assert
        $result.Output | Should -BeExactly 'routed'
        Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'gh' -and $TimeoutMilliseconds -eq 7000 }
    }
}
```

**TD-3** (CR-9; +2). Old text:

```powershell
    ) {
        # Act
        $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'
```

New text:

```powershell
    ) {
        # Arrange: the row supplies the diff text and the expected result.

        # Act
        $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'
```

### Suite B `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (218 lines; 235 after TB-1 to TB-5; 245 after TB-6 to TB-10)

**TB-1** (row B1; +1). Old text:

```powershell
            @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5 }
```

New text:

```powershell
            @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5 }
            @{ Name = 'an --auto= value'; Command = 'gh pr merge 5 --merge --auto=true'; Pr = 5 }
```

**TB-2** (rows B2 to B4; +3). Old text:

```powershell
            @{ Name = 'a --match-head-commit with no value'; Command = 'gh pr merge 5 --merge --match-head-commit'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
```

New text:

```powershell
            @{ Name = 'a --match-head-commit with no value'; Command = 'gh pr merge 5 --merge --match-head-commit'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a mismatched --match-head-commit= value'; Command = 'gh pr merge 5 --merge --match-head-commit=1111111111111111111111111111111111111111'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a timed-out gh lookup (exit 124)'; Command = 'gh pr merge 5 --merge'; GhExit = 124; GhOutput = '' }
            @{ Name = 'a JSON array lookup result'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '[]' }
```

**TB-3** (row B5; +11). Old text:

```powershell
            $result.Exempt | Should -BeTrue -Because "a matching head pin is accepted (OD-2); reason: $($result.Reason)"
        }
```

New text:

```powershell
            $result.Exempt | Should -BeTrue -Because "a matching head pin is accepted (OD-2); reason: $($result.Reason)"
        }

        It 'does not deny a matching --match-head-commit= value (issue #927)' {
            # Arrange
            $command = 'gh pr merge 5 --merge --match-head-commit=0123456789abcdef0123456789abcdef01234567'

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "a matching head pin in the equals form is accepted (OD-2); reason: $($result.Reason)"
        }
```

**TB-4** (row B6; +1). Old text:

```powershell
            @{ Name = 'a non-hex base rev-parse'; RevExit = 0; RevOutput = 'main' }
```

New text:

```powershell
            @{ Name = 'a non-hex base rev-parse'; RevExit = 0; RevOutput = 'main' }
            @{ Name = 'a timed-out base rev-parse (exit 124)'; RevExit = 124; RevOutput = '' }
```

**TB-5** (row B7; +1). Old text:

```powershell
            @{ Name = 'a merge diff with a path outside docs'; DiffExit = 0; DiffOutput = "docs/a.md`0src/b.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
```

New text:

```powershell
            @{ Name = 'a merge diff with a path outside docs'; DiffExit = 0; DiffOutput = "docs/a.md`0src/b.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
            @{ Name = 'a timed-out merge diff (exit 124)'; DiffExit = 124; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*could not be computed*' }
```

**TB-6** (CR-9; +2). Old text:

```powershell
        ) {
            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $Root
```

New text:

```powershell
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $Root
```

**TB-7** (CR-9; +2). Old text:

```powershell
        It 'calls gh pr view with the number and the two JSON fields in the root (issue #927)' {
            # Act
```

New text:

```powershell
        It 'calls gh pr view with the number and the two JSON fields in the root (issue #927)' {
            # Arrange: the BeforeEach mocks return a valid pull request.

            # Act
```

**TB-8** (CR-9; +2). Old text:

```powershell
        It 'allows a NUL-terminated docs-only diff (issue #927)' {
            # Act
```

New text:

```powershell
        It 'allows a NUL-terminated docs-only diff (issue #927)' {
            # Arrange: the BeforeEach mocks resolve both commits and return a NUL-terminated docs-only diff.

            # Act
```

**TB-9** (CR-9; +2). Old text:

```powershell
        It 'runs the diff with -z, --no-renames, and the base...head range (issue #927)' {
            # Act
```

New text:

```powershell
        It 'runs the diff with -z, --no-renames, and the base...head range (issue #927)' {
            # Arrange: the BeforeEach mocks resolve the base commit and the head commit.

            # Act
```

**TB-10** (CR-9; +2). Old text:

```powershell
        It 'never runs git fetch on the allow path (issue #927)' {
            # Act
```

New text:

```powershell
        It 'never runs git fetch on the allow path (issue #927)' {
            # Arrange: the BeforeEach mocks include a fetch guard that throws.

            # Act
```

### Suite A `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (318 lines; 328 after TA-1 to TA-5)

**TA-1** (+2). Old text:

```powershell
        It 'returns the non-zero exit code of the injected git command (issue #927)' {
            # Act
```

New text:

```powershell
        It 'returns the non-zero exit code of the injected git command (issue #927)' {
            # Arrange: the injected stand-in sets exit code 2 and emits nothing.

            # Act
```

**TA-2** (+2). Old text:

```powershell
        It 'returns the failure object when the injected git command throws (issue #927)' {
            # Act
```

New text:

```powershell
        It 'returns the failure object when the injected git command throws (issue #927)' {
            # Arrange: the injected stand-in throws.

            # Act
```

**TA-3** (+2). Old text:

```powershell
        ) {
            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $Root
```

New text:

```powershell
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $Root
```

**TA-4** (+2). Old text:

```powershell
        It 'returns the non-zero exit code of the injected gh command (issue #927)' {
            # Act
```

New text:

```powershell
        It 'returns the non-zero exit code of the injected gh command (issue #927)' {
            # Arrange: the injected stand-in sets exit code 2 and emits nothing.

            # Act
```

**TA-5** (+2). Old text:

```powershell
        ) {
            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $Root
```

New text:

```powershell
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $Root
```

### Suite E `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (159 lines; 149 after TE-1 to TE-3)

**TE-1** (remove the Claude module loads and mocks; 10 lines become 1, -9). Old text:

```powershell
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
```

New text:

```powershell
        if (Get-Command Invoke-DocsOnlyGhExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
```

**TE-2** (remove the Claude-surface probe row; 3 lines become 1, -2). Old text:

```powershell
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows a docs-only merge when no checkpoint is present (codex, issue #927)' {
```

New text:

```powershell
    It 'allows a docs-only merge when no checkpoint is present (codex, issue #927)' {
```

**TE-3** (description; 3 lines become 4, +1). Old text:

```text
    process, runs git or gh, or writes a file. The BeforeAll seam mocks are registered only
    when the shared helper is loaded, so before it exists every docs-only row fails.
#>
```

New text:

```text
    process, runs git or gh, or writes a file. The BeforeAll seam mocks are registered only
    when the shared helper is loaded, so before it exists every docs-only row fails. The
    Codex gate reads checkpoint text from parameters, so no epic-state baseline mock applies.
#>
```

**TE-R** (CR-5 fallback of decision D-R1-6, used only when [P7-T3] reports J15a `0`): apply TE-1, TE-2, and TE-3 with Old text and New text exchanged, restoring the 159-line file.

### DocsOnly suite `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (242 lines; 243 after TX-1)

**TX-1** (CR-3; +1). Old text:

```powershell
            @{ Name = 'B equals -B=main'; Command = 'gh pr create -B=main --body-file artifacts/pr_body_1.md' }
```

New text:

```powershell
            @{ Name = 'B equals -B=main'; Command = 'gh pr create --base main -B=main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B cluster with equals -dB=other'; Command = 'gh pr create --base main -dB=other --body-file artifacts/pr_body_1.md' }
```

## 11. Appendix SX, RX, and OX — documentation edits

Each Old text is unique in `FEATURE/spec.md` (SX), in `FEATURE/research/research-addendum-merge-gate.2026-10-15T19-46.md` (RX), or in `FEATURE/plan.2026-10-15T07-41.md` (OX).

- **S-1.** Old `- **Last Updated:** 2026-10-15` ; New `- **Last Updated:** 2026-10-16`.
- **S-2.** Old `- **Version:** 1.2` ; New `- **Version:** 1.3`.
Every Old and New text below is given in its own fenced block; the fence lines are not part of the text. S-1, S-2, S-5, S-6, S-11, S-12, S-13, S-14, and S-15 replace a substring of one line; S-3, S-4, S-7, S-8, S-9, S-10, and RX-1 replace or extend a whole line as stated.

**S-1.** Old / New:

```text
- **Last Updated:** 2026-10-15
```

```text
- **Last Updated:** 2026-10-16
```

**S-2.** Old / New:

```text
- **Version:** 1.2
```

```text
- **Version:** 1.3
```

**S-3** (line 12, whole line). Old / New:

```text
- **Research addendum:** `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research-addendum-merge-gate.2026-10-15T19-46.md`
```

```text
- **Research addendum:** `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/2026-10-15T19-46-merge-gate-addendum-research.md`
```

**S-4** (end of the version 1.2 revision note, line 16; adds one blank line and one note line). Old / New:

```text
AC-7, AC-8, AC-9, and AC-M4 were revised in wording only; their intent is unchanged.
```

```text
AC-7, AC-8, AC-9, and AC-M4 were revised in wording only; their intent is unchanged.

> **Revision note (version 1.3, remediation cycle R1).** Review finding CR-1: Claude Code does not treat a PreToolUse hook that exceeds its timeout as a denial, and the repository records no Codex behavior for that case. The default invokers of `Invoke-DocsOnlyGitExe` and `Invoke-DocsOnlyGhExe` therefore run the executable through the new helper function `Invoke-DocsOnlyBoundedNative`, which waits at most 7000 ms for gh and 3000 ms for each git call (plus at most 1000 ms for output) and reports exit code 124 on expiry, so a stalled call denies. Its rows are in `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` and `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. CR-2: the helper and merge-gate headers record the working-directory residual limit. CR-10: AC-18 and AC-M23 are marked CI-dependent for their analyzer half; their wording and checkbox state are otherwise unchanged. CR-6: the research addendum citation names the convention-compliant copy. AC-M24: the Codex gate entry-point statement, which runs only when the hook executes as a process, is recorded with its line number and reason instead of a covered count (D-R1-12). No acceptance criterion was added or removed.
```

**S-5** (Design item 8 table, line 129). Old / New:

```text
-GitArgs [-GitInvoker { git @args 2>$null }]
```

```text
-GitArgs [-GitInvoker { Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 3000 }]
```

**S-6** (line 130). Old / New:

```text
-GhArgs [-GhInvoker { gh @args 2>$null }]
```

```text
-GhArgs [-GhInvoker { Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList $args -TimeoutMilliseconds 7000 }]
```

**S-7** (end of the line-130 table row; appends one table row). Old / New:

```text
`Pop-Location` in `finally`; returns `ExitCode` and `Output`; never throws. |
```

```text
`Pop-Location` in `finally`; returns `ExitCode` and `Output`; never throws. |
   | `Invoke-DocsOnlyBoundedNative -FileName -ArgumentList [-TimeoutMilliseconds 3000] [-ProcessStarter]` | seam body | Starts the executable in the current location with redirected streams, waits at most the limit for the exit and 1000 ms for the output, and on expiry stops the process tree, emits nothing, and sets `$LASTEXITCODE` to 124 (revision 1.3). |
```

**S-8** (line 170; appends one bullet line). Old / New:

```text
- On the merge side, a push between the `gh pr view` lookup and the merge can change the PR head. This window is closed only when the operator passes `--match-head-commit`.
```

```text
- On the merge side, a push between the `gh pr view` lookup and the merge can change the PR head. This window is closed only when the operator passes `--match-head-commit`.
- On the merge side, gh and git run in the root the gate passes (the Claude session worktree root or the Codex repository root); a working directory set by an earlier shell call is not visible (revision 1.3).
```

**S-9** (line 243). Old / New:

```text
`Get-DocsOnlyMergeExemption`, `Test-EpicMergeGateNoRecordingTarget`.
```

```text
`Get-DocsOnlyMergeExemption`, `Test-EpicMergeGateNoRecordingTarget`, `Invoke-DocsOnlyBoundedNative` (revision 1.3).
```

**S-10** (line 258, whole line). Old / New:

```text
- `Invoke-DocsOnlyGitExe` has the same signature and return shape. `Invoke-DocsOnlyGhExe -WorkingRoot <string> -GhArgs <string[]> [-GhInvoker <scriptblock> = { gh @args 2>$null }]` returns the same shape.
```

```text
- `Invoke-DocsOnlyGitExe` has the same return shape; its default invoker is `{ Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 3000 }`. `Invoke-DocsOnlyGhExe -WorkingRoot <string> -GhArgs <string[]> [-GhInvoker <scriptblock> = { Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList $args -TimeoutMilliseconds 7000 }]` returns the same shape. `Invoke-DocsOnlyBoundedNative -FileName <string> -ArgumentList <string[]> [-TimeoutMilliseconds <int> = 3000] [-ProcessStarter <scriptblock>]` emits the output lines and sets `$LASTEXITCODE`; an expired wait stops the process tree, emits nothing, and sets `$LASTEXITCODE` to 124 (revision 1.3).
```

**S-11** (line 337). Old / New. Post-execution note (R1 executor): the leading `> ` of the S-11 and S-12 lines below is not part of the substring; it was added after [P6-T3] applied and verified these edits, so the executor completion hook does not read the quoted spec checkboxes as plan tasks.

```text
> - [ ] AC-M23 (toolchain, merge side): PoshQC
```

```text
> - [ ] AC-M23 (toolchain, merge side) **[CI-dependent]** (analyzer half): PoshQC
```

**S-12** (line 360). Old / New:

```text
> - [ ] AC-18 (toolchain): PoshQC
```

```text
> - [ ] AC-18 (toolchain) **[CI-dependent]** (analyzer half): PoshQC
```

**S-13** (line 373). Old / New:

```text
Mitigation: the branch runs only when no checkpoint records the PR; Codex registration keeps its 30 s timeout.
```

```text
Mitigation: the branch runs only when no checkpoint records the PR; Codex registration keeps its 30 s timeout. Revision 1.3: each gh and git call on that branch is time-bounded inside the helper (worst case 20 s), and an expired call denies.
```

**S-14** (line 384). Old / New:

```text
addendum `research/research-addendum-merge-gate.2026-10-15T19-46.md`.
```

```text
addendum `research/2026-10-15T19-46-merge-gate-addendum-research.md`.
```

**S-15** (AC-M24, line 338; decision D-R1-12). Old / New:

```text
by this change has a covered-instruction count greater than 0, with the run ID, counters, and line numbers recorded in evidence.
```

```text
by this change has a covered-instruction count greater than 0, except the Codex gate entry-point statement that begins `$decision = Invoke-CodexEpicMergeDecision -PayloadRaw`, which runs only when the hook executes as a process and is recorded with its line number and that reason (revision 1.3), with the run ID, counters, and line numbers recorded in evidence.
```

**RX-1** (`FEATURE/research/research-addendum-merge-gate.2026-10-15T19-46.md`, line 7; appends one line). Old / New:

```text
- **Method:** every citation below was read from the current tree with the Read and Grep tools. No command was executed (no git, gh, or pwsh), so no runtime behavior is claimed as observed. Statements about PR #939 are taken from the delegation prompt and were not verified here.
```

```text
- **Method:** every citation below was read from the current tree with the Read and Grep tools. No command was executed (no git, gh, or pwsh), so no runtime behavior is claimed as observed. Statements about PR #939 are taken from the delegation prompt and were not verified here.
- **Superseded duplicate (remediation cycle R1, CR-6):** this file duplicates `research/2026-10-15T19-46-merge-gate-addendum-research.md`, the convention-compliant copy that `spec.md` and the plan cite. It is retained and is not a design input.
```

Token counts after Phase 6 (used by [P6-T1], [P6-T3], [P6-T4]): `Invoke-DocsOnlyBoundedNative` appears in `spec.md` on six lines (the S-4 note line, lines 129 and 130 after S-5 and S-6, the S-7 table row, line 243 after S-9, and line 258 after S-10). `**[CI-dependent]**` appears on seven lines (lines 311, 338, 351, 361, and 363 before the edit, plus the S-11 and S-12 lines; the S-4 note uses the unbolded word `CI-dependent`). `{ git @args 2>$null }]` remains only on line 257 (the create-side technical specification, unchanged). `2026-10-15T19-46-merge-gate-addendum-research.md` appears on the S-3 and S-14 lines only. `except the Codex gate entry-point statement` appears on the S-15 line only (the S-4 note sentence does not contain `except the`); S-15 adds no `**[CI-dependent]**` marker and keeps the `- [ ] AC-M24 (` prefix, so the [P6-T3], [P6-T5], and [P9-T2] counts are unchanged.

### Appendix OX — edits to `FEATURE/plan.2026-10-15T07-41.md` (original plan; decisions D-R1-12 and D-R1-13)

Each edit replaces a substring of one line. The Old texts were each found exactly once in the original plan.

**OP-1** ([P8-T3], line 313). Old / New:

```text
prints either `NOT_EXECUTABLE_OR_ABSENT` or `ci` greater than `0` (AC-M24);
```

```text
prints either `NOT_EXECUTABLE_OR_ABSENT` or `ci` greater than `0`, except the Codex gate entry-point statement that begins `$decision = Invoke-CodexEpicMergeDecision -PayloadRaw`, which may print `ci=0` and is then recorded as `UNCOVERED_CHANGED_LINE:` with the AC-M24 reason (AC-M24, spec revision 1.3);
```

**OP-2** ([P8-T2], line 312, third command). Old / New:

```text
--jq '.jobs[] | select(.name == "poshqc / PowerShell QC") | .steps[] | [.name, .conclusion] | @tsv'
```

```text
--jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'
```

**OP-3** ([P8-T2], line 312, step acceptance). Old / New:

```text
the rows for steps `Format PowerShell` and `Analyze PowerShell` (
```

```text
among the rows whose first field is `poshqc / PowerShell QC`, the rows for steps `Format PowerShell` and `Analyze PowerShell` (
```

## 12. Appendix S2 — `SCRATCH/927/tools/read_report_totals_927.py`

```python
"""Issue 927 scratch helper: print the report-level JaCoCo LINE counter and the JUnit totals."""

import sys
import xml.etree.ElementTree as ET


def report_line(path):
    """Print REPORT_LINE for the report-level LINE counter; return 0 or 1."""
    root = ET.parse(path).getroot()
    counters = [c for c in root.findall("counter") if c.get("type") == "LINE"]
    if len(counters) != 1:
        print(f"REPORT_LINE: LINE_COUNTER_COUNT={len(counters)}")
        return 1
    covered = int(counters[0].get("covered"))
    missed = int(counters[0].get("missed"))
    total = covered + missed
    pct = round(100.0 * covered / total, 2) if total else 0.0
    verdict = "PASS" if total and 100 * covered >= 85 * total else "FAIL"
    print(f"REPORT_LINE: covered={covered} missed={missed} line_pct={pct} threshold=85.00 result={verdict}")
    return 0


def junit_totals(path):
    """Print JUNIT_TOTALS from the testsuites root element; return 0 or 1."""
    root = ET.parse(path).getroot()
    if root.tag != "testsuites":
        print(f"JUNIT_TOTALS: ROOT={root.tag}")
        return 1
    print(f"JUNIT_TOTALS: tests={root.get('tests')} failures={root.get('failures')} errors={root.get('errors')}")
    return 0


def main(argv):
    """Print both lines; return the larger status."""
    if len(argv) != 3:
        print("USAGE: read_report_totals_927.py COVERAGE_XML JUNIT_XML")
        return 2
    return max(report_line(argv[1]), junit_totals(argv[2]))


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

## Appendix R1-T — JUnit row tokens (rule R1-JUNIT J16)

Each token is the tail of a `testcase name` value; the J16 command appends `" status="Passed"` or `" status="Failed"`.

- F1 `starts the executable in the current location with each argument and redirected streams (issue #927)`
- F2 `emits two LF-terminated lines as output lines (issue #927)`
- F3 `emits CRLF-terminated lines as output lines (issue #927)`
- F4 `emits NUL-terminated diff output as output lines (issue #927)`
- F5 `emits empty output as output lines (issue #927)`
- F6 `reports the non-zero exit code of a process that exits in time (issue #927)`
- F7 `stops the process tree, emits nothing, and reports 124 when the exit wait expires (issue #927)`
- F8 `stops the process tree, emits nothing, and reports 124 when the output wait expires (issue #927)`
- F9 `stops the process tree, emits nothing, and reports 124 when stopping the process throws (issue #927)`
- F10 `returns the seam failure object when the process cannot start (issue #927)`
- F11 `returns exit code 124 through the git seam when the bounded call expires (issue #927)`
- F12 `routes the default git invoker through the bounded runner with a 3000 ms limit (issue #927)`
- F13 `routes the default gh invoker through the bounded runner with a 7000 ms limit (issue #927)`
- D1 `runs the bounded runner when the process exits in time (codex copy, issue #927)`
- D2 `runs the bounded runner when the exit wait expires (codex copy, issue #927)`
- D3 `runs the bounded runner when the output wait expires (codex copy, issue #927)`
- D4 `runs the bounded runner when stopping the process throws (codex copy, issue #927)`
- D5 `routes the default git invoker through the bounded runner (codex copy, issue #927)`
- D6 `routes the default gh invoker through the bounded runner (codex copy, issue #927)`
- B1 `denies an --auto= value before any process (issue #927)`
- B2 `denies a mismatched --match-head-commit= value with PR_UNRESOLVED and no git call (issue #927)`
- B3 `denies a timed-out gh lookup (exit 124) with PR_UNRESOLVED and no git call (issue #927)`
- B4 `denies a JSON array lookup result with PR_UNRESOLVED and no git call (issue #927)`
- B5 `does not deny a matching --match-head-commit= value (issue #927)`
- B6 `denies a timed-out base rev-parse (exit 124) with BASE_UNRESOLVED and no diff call (issue #927)`
- B7 `denies a timed-out merge diff (exit 124) (issue #927)`
- X0 `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` (existing AC-10 row; unchanged)
- X1 `denies the base or repository override B cluster with equals -dB=other`

## 13. WRITES

Repository paths this cycle may change (every other change is out of scope, rule R1-13):

- `.claude/hooks/hook-docs-only-diff.ps1` (Edit)
- `.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (Edit)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` (cp)
- `.codex/hooks/enforce-epic-merge-gate.ps1` (Edit)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` (cp)
- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (Write, new)
- `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (Edit)
- `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (Edit)
- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (Edit)
- `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (Edit)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (Edit)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` (Edit)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research-addendum-merge-gate.2026-10-15T19-46.md` (Edit)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md` (Edit; OP-1, OP-2, and OP-3 only)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T05-25.md` (this plan; checkbox updates)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/**` (new artifacts only)

## 14. Quoted literals created by this plan

Literals that acceptance conditions assert and that do not exist before their task runs: `function Invoke-DocsOnlyBoundedNative {`, `& $ProcessStarter $startInfo`, `-TimeoutMilliseconds 3000 }`, `-TimeoutMilliseconds 7000 }`, `Time limit:`, `working directory set by an earlier shell call`, `reports exit code 124, which denies`, `through the -ProcessStarter parameter`, `made by an earlier Bash call`, `earlier shell call is not visible either`, `Get-CodexDocsOnlyFakeProcess`, `exit 124`, `--match-head-commit=`, `GhOutput = '[]'`, `--auto=true`, `--base main -B=main`, `-dB=other`, `Superseded duplicate`, `except the Codex gate entry-point statement` (created by S-15 and OP-1), `.name as $j` (created by OP-2), `among the rows whose first field is` (created by OP-3), `**[CI-dependent]** (analyzer half):`, `Revision note (version 1.3`, `- **Version:** 1.3`, `Invoke-DocsOnlyBoundedNative` (in `spec.md`), and every token of Appendix R1-T except X0. Each is quoted verbatim in the appendix that creates it.
