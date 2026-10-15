# 2026-10-11-pr-author-hook-docs-only-exemption (Plan)

- **Issue:** #901 (bundles the #850 review notes L19, L20, L21, L22, L23, and L25 collected in #903)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T10-38
- **Status:** Draft, revision round 2 applied (three preflight defects: P2-T6 expected exit code, rule 1 MCP and R-JUNIT exceptions, E4 row labels), after revision round 1 (nine preflight defects); awaiting executor preflight
- **Version:** 1.0
- **Work Mode:** minor-audit (`issue.md` marker `- Work Mode: minor-audit`). Sole requirements source: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`, section `## Acceptance Criteria`, AC-1 to AC-10. `spec.md` and `user-story.md` are intentionally absent and are not required.
- **Design input:** `research/research.2026-10-11T10-45.md` in the feature folder (read in [P0-T2]). Every design decision below follows that research except where section 3 states otherwise.
- **Branch:** `bug/pr-author-hook-docs-only-exemption-901`. Every push is `git push origin bug/pr-author-hook-docs-only-exemption-901`. No force push, no `--amend`, no rebase, no deletion, no GitHub issue creation, no pull request.
- **Structure:** three phases (minimal-audit contract): Phase 0 baseline capture, Phase 1 implementation and targeted verification, Phase 2 final QC loop. Each phase ends with a commit and a push.

`FEATURE` denotes `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`. Every evidence path is `FEATURE/evidence/<kind>/<name>` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`.

**Fail-closed evidence rule:** PowerShell is the only code language in scope (plus one JSON manifest line). Baseline artifacts are produced in Phase 0 ([P0-T5] to [P0-T9]), targeted-verification artifacts in Phase 1 ([P1-T17] to [P1-T19], [P1-T26], [P1-T27]), and end-state artifacts in Phase 2 ([P2-T1] to [P2-T7]). If any required baseline, QA, or coverage-pointer artifact is missing or incomplete, the audit verdict is BLOCKED or INCOMPLETE, never PASS. Per-file line coverage (AC-9) is CI-dependent: no local coverage number is recorded, and AC-9 stays unchecked as pending-CI until the CI artifact named in [P2-T7] is read.

**Evidence accounting rule:** every evidence-producing task names its artifact path. No evidence-backed task is checked off without its artifact on disk with the fields `Timestamp:` (format `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`.

---

## 1. Rules binding on every task

1. **Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command the task names, and every other command's exit code is recorded on its own labelled line, with two exceptions. (a) When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`; the value implies no count or finding. (b) When the command list begins with R-JUNIT J0, `Command:` and `EXIT_CODE:` describe the J1 `stat` command, and the J0 exit code is recorded as `J0_EXIT_CODE:`. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or the executing account name. The worktree root is written as `<WORKSPACE_ROOT>`. JUnit lines that carry a `classname` path are never copied into an artifact; only counts and test names are recorded. Test fixtures use only the synthetic roots `/synthetic-worktrees/docs-only-901`, `/synthetic-worktrees/item-901`, and `/synthetic-worktrees/no-such-root-901`.
3. **PowerShell verification is Option A only.** Formatting, analysis, and Pester run only through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` set to the absolute worktree root (the output of `git rev-parse --show-toplevel`) and an explicit `scan_folders` array. No task calls a shell wrapper, `sh`, `bash`, or a `pwsh` script to run Pester, PSScriptAnalyzer, bats, or kcov. The PoshQC MCP result is a summary composed before the child process runs and carries no count, coverage, or finding. Each MCP call is therefore recorded only by its disposition (`MCP_CALL: returned` or `MCP_CALL: error <message>`). Every count an acceptance condition reads comes from the on-disk JUnit file through rule R-JUNIT (section 6), and from the tree through `git status --porcelain`. No acceptance condition reads a count or a percentage from an MCP result.
4. **Fixed MCP scan sets.** `SCAN_QC` = `[".claude/hooks", "tests/scripts/claude-hooks"]` for format and analyze. `SCAN_TEST` = `["tests/scripts/claude-hooks", "tests/scripts/claude-runtime", "tests/scripts/claude-lib/orchestrator-state"]` for Pester. The same sets are used in Phase 0, Phase 1, and Phase 2 so the JUnit counts are comparable.
5. **Parse check (R-PARSE).** atomic-executor has no PowerShell tool, and the worktree-isolation guard refuses Bash command text containing pwsh, so no task runs a parser call. R-PARSE-LIVE: after an edit to .claude/hooks/enforce-pr-author-skill-helpers.ps1 or .claude/hooks/enforce-pr-author-skill.artifact-root.ps1, and from [P1-T2] onward for .claude/hooks/enforce-pr-author-skill.docs-only.ps1, the task's next Bash command is not denied with a PR_AUTHOR_SKILL_BLOCKED: reason naming enforce-pr-author-skill-helpers.ps1 (the live hook loads these files inside its dependency guard, enforce-pr-author-skill.ps1:169). R-PARSE-PESTER: .claude/hooks/enforce-pr-author-skill.ps1 and the four new test files are parse-checked by [P1-T19]; a parse error in the main hook fails every family suite (J5 greater than 0), and a parse error in a new test file leaves its J6 count at 0.
6. **Live-hook hazard.** Claude Code runs `.claude/hooks/enforce-pr-author-skill.ps1` from this worktree on every Bash call. A parse error in any file it dot-sources makes it deny every Bash command with a `PR_AUTHOR_SKILL_BLOCKED:` dependency reason. For that reason the new sibling is written ([P1-T1]) before the helpers file dot-sources it ([P1-T2]), so a defect in the sibling first surfaces through R-PARSE-LIVE at [P1-T2]. If a Bash call is denied with a `PR_AUTHOR_SKILL_BLOCKED:` dependency reason, the executor fixes the defective file with Edit only and retries the denied command (R-PARSE-LIVE). Editing the defective file is the fix, not a workaround of the hook.
7. **Hook denials.** If any other hook denies a Write, Edit, Bash, or PowerShell call, the executor records the denial text in the task's artifact and stops as BLOCKED. It never works around a hook.
8. **Change budget.** This plan authors four canonical production PowerShell files with Write or Edit: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (new), `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, and `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`. `.claude/hooks/enforce-powershell-batch-budget.ps1` denies the fourth distinct production file unless the worktree checkpoint selects the `large`, `remediation`, or `preparation` route and is not terminal; [P0-T4] verifies that. Bundle mirrors are written only with `cp` through the Bash tool (rule 9), which the `Write|Edit` matcher of that hook does not count. Test files are never counted.
9. **Mirrors are byte copies.** Each bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` is written only by `cp <source> <mirror>` and verified by `cmp <source> <mirror>` (exit 0, no output). Never with Write or Edit.
10. **Plain commands.** `git`, `gh`, `grep`, `stat`, `cmp`, `cp`, and `poetry` run directly in the Bash tool, one command per call: no `&&`, no `;`, no `cd`, no heredoc. Search commands use plain `grep`, not `git grep`, because files this plan creates are untracked until the phase commit. A grep pattern that begins with `-` is passed through `-e`.
11. **Scratch files.** This plan needs no scratch file. If the executor needs one, its name includes `901` and it lives under the session scratchpad as `<SCRATCHPAD>/901/<name>`, never in the repository.
12. **Scope boundary.** The complete write set is section 2. A path outside it is never written. Policy documents under `.claude/rules/` and `.github/instructions/` are never edited.
13. **No temporary files in tests.** No test file written by this plan uses `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `Set-Content`, `Out-File`, `New-Item`, `Start-Process`, `Start-Sleep`, or a direct `Mock git`, and none of these tokens appears in any comment or string of those files either. [P2-T6] verifies this mechanically.
14. **No interpreter tokens in hooks.** No line this plan adds under `.claude/hooks/` or its bundle mirror contains `python` or `poetry` in any case (enforcement hooks must not use Python).
15. **Commit form.** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>'` (with the attribution trailer the executing session's instructions require passed as a second `-m` flag, because the isolation guard refuses heredocs); `git push origin bug/pr-author-hook-docs-only-exemption-901`; then the observation commands its acceptance names. The plan file's own checkbox for the commit task is checked after the observation, so the only path `git status --porcelain` may list after a commit task is this plan file.

## 2. Write set (complete)

Production files (Write or Edit):

1. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (new, [P1-T1], Appendix A)
2. `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (Edit, [P1-T2] to [P1-T5], Appendix B)
3. `.claude/hooks/enforce-pr-author-skill.ps1` (Edit, [P1-T6] to [P1-T8], Appendix C)
4. `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (Edit, [P1-T9] to [P1-T11], Appendix D)

Byte copies (`cp`, rule 9): the four files above under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` with the same file names.

Manifest (Edit): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one added line, [P1-T24]).

New test files (Write, Appendix E): `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`; `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`; `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`; `tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1`.

Feature folder: evidence files named in their tasks; `issue.md` (AC checkboxes only, Phase 2); this plan file (checkbox state only).

Never written: the eleven existing `tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1` suites; `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` and its mirror; every out-of-family file named by the #850 notes (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`); `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/skills/orchestrate/SKILL.md` and their mirrors; anything under `.codex/`, `.claude/rules/`, `.github/`; the research artifact.

## 3. Decisions

- **D1 - insertion point.** The exemption is consulted only in the non-epic branch of `Get-PrAuthorBypassReason` (`.claude/hooks/enforce-pr-author-skill-helpers.ps1`, the `else` branch that calls `Invoke-OrchestratorStatePreflight`), and only after that preflight reports `HasErrors`. A branch with a passing checkpoint never reaches git, so AC-3 holds by construction. Target resolution, Case C, and receipt checks 1-6 stay in force: the receipt checks do not read the checkpoint (check 6 is a no-op when the checkpoint is absent), so the exemption replaces only the preflight denial.
- **D2 - eligibility order.** E1 `gh pr create` only (`gh pr edit` is never exempt); E2 no checkpoint file at the resolved checkpoint path (a present but failing checkpoint means the branch is orchestrated and its preflight governs); E3 exactly one explicit long-form `--base`, no token beginning `-B`, a conservative branch spelling, no `..`; E4 `refs/remotes/origin/<base>^{commit}` resolves to a 40- or 64-hex object id; E5 `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <oid>...HEAD` exits 0; E6 at least one path; E7 every path starts with `docs/` (ordinal, case-sensitive) and is longer than five characters. Each failure keeps the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix and appends one sub-code (Appendix A).
- **D3 - no default base.** A missing `--base` denies; `origin/HEAD` and `main` are not assumed, because a `-B` spelling is invisible to the parser and the PR could target a different base than the one diffed.
- **D4 - never-throwing seam.** All git access goes through `Invoke-PrAuthorDocsOnlyGitExe`, which returns `ExitCode = -1` instead of throwing, because an uncaught error ends the hook with exit 1, which PreToolUse treats as non-blocking. The caller additionally wraps each seam call in `try`/`catch` so a throwing mock denies. Tests mock the seam, never `git`.
- **D5 - residual risk not hardened.** The diff is computed against the resolved worktree's local `HEAD`; commits present only on the remote head branch are not seen. A `rev-parse HEAD` equals `refs/remotes/origin/<head>` check is not added in this item. A top-level `try`/`catch` around `Invoke-PrAuthorSkillDecision` is also not added; the L19 fix removes the known throw.
- **D6 - #850 L19 (AC-5).** Both `[int]$Matches[1]` casts in `Get-PrAuthorBodyPathBindingReason` are replaced by `ConvertTo-PrAuthorBodyNumber`, which uses `[int]::TryParse` with `NumberStyles.None` and the invariant culture and rejects any digit run whose canonical spelling differs from the input. A body number above Int32.MaxValue, a leading zero, and a non-ASCII decimal digit each return the generic `PR_BODY_PATH_NONCANONICAL` denial.
- **D7 - #850 L20 (AC-6).** Record only. The operator's scope boundary excludes the merge-gate files, which a concurrent epic may own. The research recommendation to add a row to `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` is not adopted; `issue.md` AC-6 requires an evidence record, which [P1-T28] writes.
- **D8 - #850 L21, L22, L23 (AC-7).** No change; rationale recorded by [P1-T29].
- **D9 - #850 L25 (AC-8).** The stale sentence is corrected in both the main hook and the helpers file.
- **D10 - existing suites unchanged (AC-3).** Re-derived against the current tree: the existing rows that reach the non-epic preflight failure (`tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` rows "blocks gh pr create --body-file when the checkpoint is missing" and "blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails"; `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` row "pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target"; the same file's rows "pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready", "pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready", "pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable", "pr-author R7 denies with the preflight reason when the resolved checkpoint is empty", and "pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions" (fixture checkpoint present; stop at E2; the appended sub-code contains neither resolution code; test-file lines 162, 193, 265, 281, and 342; fixtures `tests/fixtures/worktree-resolution/pr-author/item-own-not-ready`, `tests/fixtures/worktree-resolution/shared/item-own-invalid-json`, and `tests/fixtures/worktree-resolution/shared/item-own-empty` each carry `artifacts/orchestration/orchestrator-state.json`); out-of-family `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` row "blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED through the default path") all carry no `--base`. They stop at E2 or E3, before any git call, and still deny with the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix their `-Match`/`-BeLike` assertions check. No existing suite is edited. This refines research section 8, which proposed optional defensive mocks.
- **D11 - agent and skill documentation.** `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/agents/orchestrator.md`, and `.claude/skills/orchestrate/SKILL.md` are not edited; [P1-T30] records a follow-up note without creating an issue.
- **D12 - discovery-guard compatibility.** The new sibling contains none of the read primitives `Get-Content`, `ReadAllText`, or `ReadAllLines` and no `artifacts/` literal, so `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` finds no new read seam, and the existing suites that dot-source the hook remain compliant. Each new suite copies the baseline mock block and the interception-probe `It` of `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (Appendix E, block E0).

## 4. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `FEATURE/evidence/baseline/p0-ac-source.2026-10-11T10-38.md` (requirements-source check). Commands: `grep -c '^## Acceptance Criteria' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`; `grep -c -E '^- \[ \] AC-([1-9]|10):' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`; `grep -c -F -e '- Work Mode: minor-audit' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`; `ls docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`. Acceptance: the three counts print `1`, `10`, and `1`; the `ls` output lists neither `spec.md` nor `user-story.md`. Any other result stops the plan as BLOCKED (minor-audit fail-closed rule).
- [x] [P0-T2] Write `FEATURE/evidence/baseline/phase0-instructions-read.md` after reading, in this order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and the research artifact `FEATURE/research/research.2026-10-11T10-45.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (12 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/baseline/phase0-instructions-read.md` prints `12` and `grep -c '^Policy Order:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/baseline/phase0-instructions-read.md` prints `1`.
- [x] [P0-T3] Write `FEATURE/evidence/baseline/p0-branch-state.2026-10-11T10-38.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin main`; `git merge-base HEAD origin/main`; `git rev-parse HEAD`. Acceptance: the first prints `bug/pr-author-hook-docs-only-exemption-901`; the second lists no path outside docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/ (the [P0-T1] and [P0-T2] artifacts and this plan file's check-offs are expected); the fetch exits 0; the merge-base value is recorded as `MERGE_BASE: <sha>` and `HEAD` as `BASE_HEAD: <sha>`, each a 40-hex value. A different branch or a status line outside that folder stops the plan as BLOCKED. `MERGE_BASE` anchors every later `git diff` in this plan.
- [x] [P0-T4] Write `FEATURE/evidence/baseline/p0-route.2026-10-11T10-38.md` (change-budget precondition, rule 8). Commands: `grep -o -E '"(route_id|path_selected)" *: *"[A-Za-z_-]+"' artifacts/orchestration/orchestrator-state.json`; `grep -o -E '"next_step" *: *"[A-Za-z0-9_-]+"' artifacts/orchestration/orchestrator-state.json`; `grep -c -F '"S12_complete"' artifacts/orchestration/orchestrator-state.json`. Acceptance: the selected route (the `route_id` value when printed, otherwise `path_selected`) is one of `large`, `remediation`, or `preparation`, recorded as `ROUTE: <value>`; the `next_step` value is not `complete`; the `S12_complete` count prints `0` (the checkpoint is not terminal, `.claude/hooks/enforce-powershell-batch-budget.ps1` header lines 20-21). A missing checkpoint, another route, `next_step` `complete`, or a non-zero `S12_complete` count stops the plan as BLOCKED before any production edit, because the fourth production file would be denied.
- [x] [P0-T5] Write `FEATURE/evidence/baseline/p0-line-counts-parity.2026-10-11T10-38.md`. Commands: `grep -c '' .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`; then one `cmp <repo file> <mirror file>` per family file, the mirror being `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<same name>`. Acceptance: the counts print `334`, `429`, `200`, and `144` in that order; each of the four `cmp` calls exits 0 with no output. A different count stops the plan for re-derivation of the appendix anchors; a `cmp` difference stops the plan as BLOCKED (pre-existing mirror drift).
- [x] [P0-T6] Write `FEATURE/evidence/baseline/p0-poshqc-format.2026-10-11T10-38.md` (baseline format, write-mode tool observed by tree state). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the MCP disposition is recorded; the status command prints nothing (the formatter rewrote no file). If it lists any path, the plan stops as BLOCKED with the listed paths recorded as `BASELINE_FORMAT_DRIFT:` lines; the executor does not revert them.
- [x] [P0-T7] Write `FEATURE/evidence/baseline/p0-poshqc-analyze.2026-10-11T10-38.md`. Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the disposition is recorded as `BASELINE_ANALYZE_DISPOSITION: returned` or `BASELINE_ANALYZE_DISPOSITION: error <message>`; the status command prints nothing. The `Output Summary:` states that the MCP result carries no finding count and that analyzer findings are verified in CI ([P2-T7]).
- [x] [P0-T8] Write `FEATURE/evidence/baseline/p0-poshqc-test.2026-10-11T10-38.md` (baseline Pester). Commands: R-JUNIT step J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT steps J1 to J5. Acceptance: J1 shows the JUnit file was rewritten by this run; the J2 `<testsuites` attributes are recorded as `BASELINE_TESTSUITES: tests=<n> failures=<n> errors=<n>`; the J3 list is recorded verbatim as `B_FAILED:` lines (or `B_FAILED: none`); the J4 value is recorded as `FAM_BASE: <n>` and is greater than 0; J5 prints `0`. If J1 shows no rewrite, the plan stops as BLOCKED with `POSHQC_JUNIT_NOT_WRITTEN`. If J5 prints a non-zero value, the plan stops as BLOCKED (the family suites fail before any change). Coverage is not read locally; the `Output Summary:` names the CI coverage source of [P2-T7].
- [x] [P0-T9] Write `FEATURE/evidence/baseline/p0-ci-baseline.2026-10-11T10-38.md` (CI coverage reference for the base). Command: `gh run list --workflow ci.yml --branch main --commit <MERGE_BASE> --json databaseId,conclusion,headSha --limit 1`, with the [P0-T3] value substituted. Acceptance: the command exits 0; when it prints one element, its `headSha` equals `MERGE_BASE` and its `databaseId` and `conclusion` are recorded as `BASELINE_CI_RUN_ID:` and `BASELINE_CI_CONCLUSION:`; when it prints `[]`, the artifact records `BASELINE_CI_RUN_ID: none` (this task authorizes that branch; the AC-9 comparison then uses the base-branch run CI reports for the pull request).
- [x] [P0-T10] Commit and push Phase 0. Commands: `git add -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git commit -m 'docs(901): record phase 0 baseline evidence'`; `git push origin bug/pr-author-hook-docs-only-exemption-901`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-hook-docs-only-exemption-901`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal.

### Phase 1 — Implementation and Targeted Verification

- [x] [P1-T1] Create `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` with the exact content of Appendix A (one Write call). Acceptance: `grep -c -E '^function ' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `6`; `grep -c -E 'Get-Content|ReadAllText|ReadAllLines|artifacts/|orchestrator-state' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c -i -E 'python|poetry' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints `0`; `grep -c '' .claude/hooks/enforce-pr-author-skill.docs-only.ps1` prints a value of at most 500.
- [x] [P1-T2] Edit `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: apply Appendix B edit H1 (dot-source the new sibling directly after the artifact-root dot-source line). Acceptance: R-PARSE-LIVE holds for the helpers file and the docs-only sibling; `grep -c -F "'enforce-pr-author-skill.docs-only.ps1'" .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `1`; the next Bash call of this plan is not denied with a `PR_AUTHOR_SKILL_BLOCKED:` dependency reason (rule 6).
- [x] [P1-T3] Edit `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: apply Appendix B edit H2 (consult the exemption in the non-epic preflight-failure branch). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F 'Get-PrAuthorDocsOnlyExemption -CommandText' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `1`; `grep -c -F 'docs-only exemption not applied' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `1`; `grep -c -F 'return "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: $preflightSummary"' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `0`.
- [x] [P1-T4] Edit `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: apply Appendix B edit H3 (replace the stale `.NOTES` sentence, #850 note L25, AC-8). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F 'No external module dependencies' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `0`; `grep -c -F 'No PowerShell Gallery module is required.' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `1`.
- [x] [P1-T5] Edit `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: apply Appendix B edit H4 (`Get-PrAuthorBypassReason` `.DESCRIPTION` names the exemption step). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F 'unless Get-PrAuthorDocsOnlyExemption exempts a docs-only gh pr create' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints `1`; `grep -c '' .claude/hooks/enforce-pr-author-skill-helpers.ps1` prints a value of at most 500 (expected 438).
- [x] [P1-T6] Edit `.claude/hooks/enforce-pr-author-skill.ps1`: apply Appendix C edit M1 (insert the docs-only exemption block into `.DESCRIPTION`, AC-10). Acceptance: each of `grep -c -F 'DOCS_ONLY_EXEMPTION_NOT_CREATE' .claude/hooks/enforce-pr-author-skill.ps1`, `grep -c -F 'DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT' .claude/hooks/enforce-pr-author-skill.ps1`, `grep -c -F 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED' .claude/hooks/enforce-pr-author-skill.ps1`, `grep -c -F 'DOCS_ONLY_EXEMPTION_DIFF_FAILED' .claude/hooks/enforce-pr-author-skill.ps1`, `grep -c -F 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF' .claude/hooks/enforce-pr-author-skill.ps1`, and `grep -c -F 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F 'The exemption never applies under epic scope.' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`.
- [x] [P1-T7] Edit `.claude/hooks/enforce-pr-author-skill.ps1`: apply Appendix C edit M2 (the `Receipt` block-case line names the exemption). Acceptance: `grep -c -F 'Receipt - preflight passed or docs-only exemption applied:' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c -F 'Receipt - preflight passed: the SHA-256 receipt' .claude/hooks/enforce-pr-author-skill.ps1` prints `0`.
- [x] [P1-T8] Edit `.claude/hooks/enforce-pr-author-skill.ps1`: apply Appendix C edit M3 (replace the stale `.NOTES` sentence, #850 note L25, AC-8). Acceptance: `grep -c -F 'No external module dependencies' .claude/hooks/enforce-pr-author-skill.ps1` prints `0`; `grep -c -F 'No PowerShell Gallery module is required.' .claude/hooks/enforce-pr-author-skill.ps1` prints `1`; `grep -c '' .claude/hooks/enforce-pr-author-skill.ps1` prints a value of at most 500 (expected 355).
- [x] [P1-T9] Edit `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`: apply Appendix D edit D1 (header bullet and the new `ConvertTo-PrAuthorBodyNumber` function inserted before `function Get-PrAuthorBodyPathBindingReason {`). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F 'function ConvertTo-PrAuthorBodyNumber {' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints `1`; `grep -c -F '[System.Globalization.NumberStyles]::None' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints `1`.
- [x] [P1-T10] Edit `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`: apply Appendix D edit D2 (relative-form call site). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F '[int]$Matches[1]' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints `1` (only the absolute-form cast remains).
- [x] [P1-T11] Edit `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`: apply Appendix D edit D3 (absolute-form call site). Acceptance: R-PARSE-LIVE holds (the task's first grep is not denied); `grep -c -F '[int]$Matches[1]' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints `0`; `grep -c -F 'ConvertTo-PrAuthorBodyNumber' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints `4`; `grep -c '' .claude/hooks/enforce-pr-author-skill.artifact-root.ps1` prints a value of at most 500.
- [x] [P1-T12] Create `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` per Appendix E, block E1 (exactly the 28 test cases listed, including the probe). Acceptance: `grep -c '' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` prints a value of at most 500; the Write is not denied by the test-purity hook.
- [x] [P1-T13] Create `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` per Appendix E, block E2 (exactly 15 test cases). Acceptance: `grep -c '' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` prints a value of at most 500; the Write is not denied by the test-purity hook.
- [x] [P1-T14] Create `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` per Appendix E, block E3 (exactly 8 test cases). Acceptance: `grep -c '' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` prints a value of at most 500; the Write is not denied by the test-purity hook.
- [x] [P1-T15] Create `tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1` per Appendix E, block E4 (exactly 9 test cases). Acceptance: `grep -c '' tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1` prints a value of at most 500; the Write is not denied by the test-purity hook.
- [x] [P1-T16] Write `FEATURE/evidence/regression-testing/p1-tests-not-committed.2026-10-11T10-38.md` recording the pre-run tree. Commands: `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the output lists exactly these eight paths and no other: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, and the four new test files of section 2. The list is recorded as `P1_TREE:` lines and is the comparison base for [P1-T17].
- [x] [P1-T17] Write `FEATURE/evidence/qa-gates/p1-poshqc-format.2026-10-11T10-38.md` (targeted format). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the disposition is recorded; the status output lists exactly the eight `P1_TREE:` paths of [P1-T16] and no other path (formatting may change the content of those eight files but must not touch any other file). R-PARSE-LIVE holds for this task's status command; the main hook and the test files are parse-checked by [P1-T19].
- [x] [P1-T18] Write `FEATURE/evidence/qa-gates/p1-poshqc-analyze.2026-10-11T10-38.md` (targeted analysis). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the disposition is recorded as `P1_ANALYZE_DISPOSITION:`; when `BASELINE_ANALYZE_DISPOSITION` was `returned`, `P1_ANALYZE_DISPOSITION` must also be `returned`, and an `error` disposition sends the executor back to fix the edited files and restart at [P1-T17]; the status output lists exactly the eight `P1_TREE:` paths.
- [x] [P1-T19] Write `FEATURE/evidence/regression-testing/p1-pester.2026-10-11T10-38.md` (targeted Pester). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J6. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `28`, `15`, `8`, and `9` for the four new files; J4 equals `FAM_BASE + 60`; every J3 line is a member of the [P0-T8] `B_FAILED` list (when `B_FAILED: none`, J3 prints nothing). A failure sends the executor back to the defective production or test file, then to [P1-T17].
- [x] [P1-T20] Copy `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` with `cp .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. Acceptance: `cmp .claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` exits 0 with no output.
- [x] [P1-T21] Copy `.claude/hooks/enforce-pr-author-skill-helpers.ps1` to its mirror with `cp .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`. Acceptance: `cmp .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` exits 0 with no output.
- [x] [P1-T22] Copy `.claude/hooks/enforce-pr-author-skill.ps1` to its mirror with `cp .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`. Acceptance: `cmp .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` exits 0 with no output.
- [x] [P1-T23] Copy `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` to its mirror with `cp .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`. Acceptance: `cmp .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` exits 0 with no output.
- [x] [P1-T24] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert the line `    ".claude/hooks/enforce-pr-author-skill.docs-only.ps1",` directly after the line `    ".claude/hooks/enforce-pr-author-skill.artifact-root.ps1",` (sorted order; indentation copied from the neighbouring line). Acceptance: `grep -c -F '".claude/hooks/enforce-pr-author-skill.docs-only.ps1",' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints `1`; `grep -n -F 'enforce-pr-author-skill' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints five lines whose file names are, in order, `.artifact-root.ps1`, `.docs-only.ps1`, `.epic-base-branch.ps1`, `enforce-pr-author-skill.ps1`, and `enforce-pr-author-skill-helpers.ps1`.
- [x] [P1-T25] Write `FEATURE/evidence/qa-gates/p1-manifest-json.2026-10-11T10-38.md`. Command: `poetry run python -m json.tool extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Acceptance: exit 0 and the printed JSON contains the new path (the artifact records the matching line, not the full output).
- [x] [P1-T26] Write `FEATURE/evidence/regression-testing/p1-bundle-parity.2026-10-11T10-38.md` (AC-4 existing parity test). Command: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Acceptance: exit 0 and the summary line reads `1 passed`. Pre-declared exception (issue #510), authorized by this task: when the run exits 1 and its AssertionError names only paths under `.claude/state/` that `git status --porcelain --ignored --untracked-files=all -- .claude/state` lists with the `!!` prefix, the artifact records `KNOWN_ISSUE_510`, `ExpectedExitCode: 1`, and both outputs, and AC-4 rests on the `cmp` record of [P1-T27]; any other failure sends the executor back to [P1-T20].
- [x] [P1-T27] Write `FEATURE/evidence/qa-gates/ac4-mirror-parity.2026-10-11T10-38.md` (AC-4 recorded comparison). Commands: for each of the five family files (`enforce-pr-author-skill.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.artifact-root.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-pr-author-skill.docs-only.ps1`), `git hash-object .claude/hooks/<name> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<name>` and `cmp .claude/hooks/<name> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<name>`. Acceptance: each `hash-object` call prints two equal object ids, recorded as `PAIR: <name> <oid> <oid>`; each `cmp` exits 0; `grep -c '^PAIR: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/ac4-mirror-parity.2026-10-11T10-38.md` prints `5`.
- [x] [P1-T28] Write `FEATURE/evidence/other/note-850-L20-record.2026-10-11T10-38.md` (AC-6) with the content of Appendix F, block F1. Commands: `grep -n -F 'function Test-ChildCheckpointPrGateBinding {' .claude/hooks/enforce-epic-merge-gate-resolution.ps1`; `grep -n -F '[int]::TryParse([string]$Checkpoint.pr_gate.pr_number' .claude/hooks/enforce-epic-merge-gate-resolution.ps1`; `grep -n -F "Context 'child checkpoint pull request binding'" tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`; `grep -n -F "It 'returns the pr_gate equality result' -ForEach @(" tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`. Acceptance: each command prints exactly one line; the printed line numbers (expected 151, 186, 238, and 258) are the ones written into the artifact's `FILE-LINE:` fields; the artifact carries `DECISION: NO-CHANGE-IN-THIS-ITEM` and the scope rationale; `grep -c '^FILE-LINE: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/other/note-850-L20-record.2026-10-11T10-38.md` prints `4`.
- [x] [P1-T29] Write `FEATURE/evidence/other/notes-850-L21-L23-no-change.2026-10-11T10-38.md` (AC-7) with the content of Appendix F, block F2. Commands: `grep -n -F 'function Get-EpicWorktreeGateDenyDiagnostics {' .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`; `grep -n -F "SuppressMessageAttribute('PSUseSingularNouns'" .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`; `grep -n -F '($value -is [int] -or $value -is [long]) -and $value -gt 0' .claude/lib/worktree-resolution/WorktreeItemResolution.psm1`; `grep -n -F 'function Test-StandalonePositiveJsonInteger {' .claude/hooks/enforce-epic-merge-gate-authorization.ps1`; `grep -n -F '[long]::TryParse([string] $payload.pr_gate.pr_number' .claude/lib/worktree-resolution/WorktreeItemResolution.psm1`; `grep -n -F '[int]::TryParse([string]$Checkpoint.pr_gate.pr_number' .claude/hooks/enforce-epic-merge-gate-resolution.ps1`. Acceptance: each command prints exactly one line, and the printed line numbers (expected 179, 197, 424, 86, 417, and 186) are written into the artifact; `grep -c '^DECISION: NO-CHANGE' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/other/notes-850-L21-L23-no-change.2026-10-11T10-38.md` prints `3`.
- [x] [P1-T30] Write `FEATURE/evidence/other/follow-up-and-decisions.2026-10-11T10-38.md` with the content of Appendix F, block F3 (agent and skill documentation follow-up, decisions D1 to D12 by identifier, no issue created). Command: `grep -c '^FOLLOW-UP: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/other/follow-up-and-decisions.2026-10-11T10-38.md`. Acceptance: the count prints `3`, and the artifact carries `ISSUE-CREATED: none`.
- [x] [P1-T31] Write `FEATURE/evidence/qa-gates/p1-line-counts.2026-10-11T10-38.md`. Command: `grep -c '' .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1`. Acceptance: all eight values are at most 500 and are recorded as `LINES: <path> <n>`.
- [x] [P1-T32] Commit and push Phase 1. Commands: `git add -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1 docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git commit -m 'fix(901): exempt docs-only branches from the pr-author checkpoint preflight'`; `git push origin bug/pr-author-hook-docs-only-exemption-901`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-hook-docs-only-exemption-901`; `git show --name-only --format=%H HEAD`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal; the `show` file list contains all thirteen non-feature paths staged above.

### Phase 2 — Final QC Loop

Loop rule: the steps are [P2-T1] format, [P2-T2] analyze, [P2-T3] Pester (type checking does not apply to PowerShell). If any step fails or changes a file, the executor fixes the cause, re-copies every changed hook file to its mirror (rule 9), commits and pushes the change with `git commit -m 'fix(901): final QC remediation'` using the [P1-T32] git add -- <paths>, git commit, and git push commands; acceptance is the push exiting 0 and git rev-parse HEAD equal to git rev-parse origin/bug/pr-author-hook-docs-only-exemption-901 (the thirteen-path git show condition does not apply to a remediation commit); records the round in the step's artifact as `ROUND: <n>`, and restarts at [P2-T1]. The loop ends when all three steps pass in one round.

- [x] [P2-T1] Write `FEATURE/evidence/qa-gates/p2-poshqc-format.2026-10-11T10-38.md` (QC step 1, format). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations`. Acceptance: the disposition is recorded; the status command prints nothing (the formatter changed no file). A non-empty output triggers the loop rule.
- [x] [P2-T2] Write `FEATURE/evidence/qa-gates/p2-poshqc-analyze.2026-10-11T10-38.md` (QC step 2, analysis). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_QC`; then `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`. Acceptance: the disposition is recorded as `P2_ANALYZE_DISPOSITION:` and is `returned` whenever `BASELINE_ANALYZE_DISPOSITION` was `returned`; the status command prints nothing. Analyzer findings are confirmed by CI ([P2-T7]).
- [x] [P2-T3] Write `FEATURE/evidence/qa-gates/p2-pester.2026-10-11T10-38.md` (QC step 3, Pester). Commands: R-JUNIT J0; `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `SCAN_TEST`; R-JUNIT J1 to J6. Acceptance: J1 shows a rewrite; J5 prints `0`; J6 prints `28`, `15`, `8`, and `9`; J4 equals `FAM_BASE + 60`; every J3 line is a member of `B_FAILED`.
- [x] [P2-T4] Write `FEATURE/evidence/qa-gates/p2-mirror-parity.2026-10-11T10-38.md` (end-state AC-4). Commands: the five `cmp` calls of [P1-T27]. Acceptance: each exits 0 with no output; the artifact records `PARITY: 5/5`.
- [x] [P2-T5] Write `FEATURE/evidence/qa-gates/p2-scope.2026-10-11T10-38.md` (scope boundary). Commands: `git diff --name-only <MERGE_BASE>...HEAD`, with the [P0-T3] value substituted; `git status --porcelain`. Acceptance: every path the diff lists is either under `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/` or one of the thirteen non-feature paths of [P1-T32]; all thirteen are listed; no existing `tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1` suite and no out-of-family file of section 2 is listed; the status lists no path outside docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/ (Phase 2 artifacts are committed by [P2-T17]).
- [x] [P2-T6] Write `FEATURE/evidence/qa-gates/p2-test-purity.2026-10-11T10-38.md`. Command: `grep -c -E 'TestDrive|New-TemporaryFile|GetTempFileName|GetTempPath|env:TEMP|Set-Content|Out-File|New-Item|Start-Process|Start-Sleep|Mock git|Mock .git' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1`. Acceptance: each of the four files prints a count of `0`. The artifact records `ExpectedExitCode: 1`, because `grep -c` exits 1 when no line in any of the four files matches; an exit code of 0 means a forbidden token was found and fails this task.
- [x] [P2-T7] Write `FEATURE/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md` (AC-9 CI-dependent criteria; no local coverage number). The artifact carries `COVERAGE_STATUS: PENDING_CI`; `CI_WORKFLOW: .github/workflows/ci.yml job poshqc -> .github/workflows/_poshqc.yml job "PowerShell QC" (windows-latest)`; `CI_FORMAT_STEP: Format PowerShell (fails when Invoke-PoshQCFormat leaves git status non-empty)`; `CI_ANALYZE_STEP: Analyze PowerShell (Invoke-PoshQCAnalyze throws on any finding)`; `CI_TEST_STEP: Test PowerShell`; `CI_LINUX_JOB: "PowerShell hook suites (Linux)" artifact poshqc-linux-hook-test-results`; `CI_COVERAGE_ARTIFACT: poshqc-test-results / artifacts/pester/powershell-coverage.xml`; one `COVERAGE_TARGET: <path> threshold=85.00` line for each of `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, and `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`; `COVERAGE_READ_RULE: per file, the LINE counter of the class whose package name joined with its sourcefilename equals the repository-relative path; covered / (covered + missed) * 100 >= 85.00`; and `BASELINE_CI_RUN_ID:` copied from [P0-T9]. No line of the artifact, including `Output Summary:`, contains the percent-sign character; thresholds are written as `85.00` without a unit. Command: `grep -c '^COVERAGE_TARGET: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md`. Acceptance: the count prints `4`; `grep -c '^COVERAGE_STATUS: PENDING_CI' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md` prints `1`; `grep -c '%' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md` prints 0.
- [x] [P2-T8] Update `FEATURE/issue.md`: check off AC-1 only (evidence: [P2-T3] J6 for `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`, including the D1 allow row, and `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` row X1). Acceptance: `grep -c -F -e '- [x] AC-1:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T9] Update `FEATURE/issue.md`: check off AC-2 only (evidence: [P2-T3] J6 for the DocsOnly unit and Exemption suites, rows listed in Appendix E traceability). Acceptance: `grep -c -F -e '- [x] AC-2:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T10] Update `FEATURE/issue.md`: check off AC-3 only (evidence: [P2-T3] J4 equals `FAM_BASE + 60` and J5 prints `0`; [P2-T5] lists no existing suite). Acceptance: `grep -c -F -e '- [x] AC-3:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T11] Update `FEATURE/issue.md`: check off AC-4 only (evidence: [P1-T26] or its `KNOWN_ISSUE_510` record, [P1-T27], [P2-T4], and [P1-T24]). Acceptance: `grep -c -F -e '- [x] AC-4:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T12] Update `FEATURE/issue.md`: check off AC-5 only (evidence: [P2-T3] J6 prints `9` for `enforce-pr-author-skill.BodyNumber.Tests.ps1`). Acceptance: `grep -c -F -e '- [x] AC-5:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T13] Update `FEATURE/issue.md`: check off AC-6 only (evidence: [P1-T28] and the [P2-T5] scope record showing the merge-gate files unchanged). Acceptance: `grep -c -F -e '- [x] AC-6:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T14] Update `FEATURE/issue.md`: check off AC-7 only (evidence: [P1-T29]). Acceptance: `grep -c -F -e '- [x] AC-7:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T15] Update `FEATURE/issue.md`: check off AC-8 only (evidence: [P1-T4] and [P1-T8] acceptance results). Acceptance: `grep -c -F -e '- [x] AC-8:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`.
- [x] [P2-T16] Update `FEATURE/issue.md`: check off AC-10 only (evidence: [P1-T6] and [P1-T7] acceptance results). Acceptance: `grep -c -F -e '- [x] AC-10:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1`; `grep -c -F -e '- [ ] AC-9:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` prints `1` (AC-9 stays unchecked as pending-CI per [P2-T7]).
- [x] [P2-T17] Commit and push Phase 2. Commands: `git add -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901`; `git commit -m 'docs(901): record final QC evidence and acceptance-criteria state'`; `git push origin bug/pr-author-hook-docs-only-exemption-901`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-hook-docs-only-exemption-901`. Acceptance: the push exits 0; the status lists no path other than this plan file; the two `rev-parse` values are equal. The completion report states `AC-9: PENDING_CI` and names `FEATURE/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md` as the reading procedure.

## 5. Appendix A — `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (exact content)

The syntax stays compatible with the repository analyzer's `PSUseCompatibleSyntax` setting: no ternary operator, no null-coalescing operator, no pipeline-chain operator.

```powershell
<#
.SYNOPSIS
    Docs-only exemption from the checkpoint preflight of enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Dot-sourced by enforce-pr-author-skill-helpers.ps1. Get-PrAuthorBypassReason calls
    Get-PrAuthorDocsOnlyExemption only in its non-epic branch and only after
    Invoke-OrchestratorStatePreflight reports errors. The exemption lets a gh pr create call
    continue to the receipt checks when the branch changes nothing outside docs/. It fails
    closed: every condition below must hold, and the first that does not names the sub-code
    the caller appends to its ORCHESTRATOR_STATE_PREFLIGHT_FAILED denial.

      E1 DOCS_ONLY_EXEMPTION_NOT_CREATE         - the command is a structural gh pr create.
      E2 DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT - no checkpoint file exists at the resolved path.
      E3 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - exactly one explicit --base, no -B token, and a
                                                  conservative branch spelling without '..'.
      E4 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - refs/remotes/origin/<base> resolves to a commit.
      E5 DOCS_ONLY_EXEMPTION_DIFF_FAILED        - git diff <commit>...HEAD exits 0 without throwing.
      E6 DOCS_ONLY_EXEMPTION_EMPTY_DIFF         - the diff lists at least one path.
      E7 DOCS_ONLY_EXEMPTION_NON_DOCS_PATH      - every path starts with docs/ (ordinal).

    The diff runs with --no-renames so a rename from outside docs/ reports its old path, with -z
    so no path is quoted, and with --no-relative, --no-color, and --no-ext-diff so repository
    configuration cannot change the listing.

.NOTES
    PowerShell 7+. Depends, at call time, on Test-CommandLineInvocation,
    Get-CommandLineStructuralMatch, and Get-CommandLineFlagValue from the command parsers the
    helpers file loads. It reads no file content. The git executable runs only through
    Invoke-PrAuthorDocsOnlyGitExe, the single executable seam, which never throws. Mirrored
    byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>
[CmdletBinding()]
param()

function Invoke-PrAuthorDocsOnlyGitExe {
    <#
    .SYNOPSIS
        Run git -C <root> with the given arguments. The single executable seam; tests mock it.
    .DESCRIPTION
        Never throws: an uncaught error ends the hook with exit 1, which PreToolUse treats as
        non-blocking, so a throw here would allow the call. A root that is not an existing
        directory, or a git that cannot start, returns ExitCode -1. Standard error is discarded
        so that it is never read as path data.
    .PARAMETER WorktreeRoot
        The resolved worktree root git runs in.
    .PARAMETER GitArgs
        The git arguments that follow -C <root>.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][string[]] $GitArgs
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return $failure
    }
    try {
        $lines = @(& git -C $WorktreeRoot @GitArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Test-PrAuthorDocsOnlyCheckpointPresence {
    <#
    .SYNOPSIS
        Return $true when a checkpoint file exists at the path, and also for a blank path.
    .DESCRIPTION
        A blank path cannot prove that no checkpoint exists, so it reports presence (fail closed).
    .PARAMETER CheckpointPath
        The absolute checkpoint path identity resolution composed.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    if ([string]::IsNullOrWhiteSpace($CheckpointPath)) {
        return $true
    }
    return (Test-Path -LiteralPath $CheckpointPath -PathType Leaf)
}

function Get-PrAuthorDocsOnlyBaseName {
    <#
    .SYNOPSIS
        Return the single explicit --base value of a gh pr create command, or $null.
    .DESCRIPTION
        Returns $null when the command is not a structural gh pr create, when any token begins
        with -B (the short form the shared parser does not read), when --base appears other
        than exactly once, when its value is missing or dash-leading, when the value is not a
        conservative branch spelling, or when it contains '..'.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText
    )

    $subcommandPath = @('pr', 'create')
    $match = Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath
    if ($null -eq $match) {
        return $null
    }
    $baseTokenCount = 0
    foreach ($token in @($match.Segment.Tokens)) {
        $text = [string]$token
        if ($text.StartsWith('-B', [System.StringComparison]::Ordinal)) {
            return $null
        }
        if ($text -eq '--base' -or $text.StartsWith('--base=', [System.StringComparison]::OrdinalIgnoreCase)) {
            $baseTokenCount++
        }
    }
    if ($baseTokenCount -ne 1) {
        return $null
    }
    $base = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--base'
    if ($null -eq $base -or $base -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $base.Contains('..')) {
        return $null
    }
    return $base
}

function ConvertFrom-PrAuthorDocsOnlyNameList {
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

function Get-PrAuthorDocsOnlyPathViolation {
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

function Get-PrAuthorDocsOnlyExemption {
    <#
    .SYNOPSIS
        Decide whether a failed preflight is exempt because the branch changes only docs/.
    .DESCRIPTION
        Evaluates E1 to E7 of the file header in order and returns at the first failure.
        Each git call is wrapped so that a throwing seam denies rather than escapes.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER WorktreeRoot
        The resolved worktree root the diff is computed in.
    .PARAMETER CheckpointPath
        The resolved checkpoint path whose absence E2 requires.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Exempt and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $CommandText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    if (-not (Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create'))) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_NOT_CREATE: only gh pr create is eligible.' }
    }
    if (Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $CheckpointPath) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT: a checkpoint file exists at '$CheckpointPath', so its preflight governs." }
    }
    $base = Get-PrAuthorDocsOnlyBaseName -CommandText $CommandText
    if ($null -eq $base) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: pass exactly one explicit --base <branch>; the -B short form is not read.' }
    }

    $baseRef = 'refs/remotes/origin/' + $base + '^{commit}'
    try {
        $revParse = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', $baseRef)
    }
    catch {
        $revParse = $null
    }
    $commit = ''
    if ($null -ne $revParse) {
        $commit = ([string]$revParse.Output).Trim()
    }
    if ($null -eq $revParse -or $revParse.ExitCode -ne 0 -or $commit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: refs/remotes/origin/$base does not resolve to a commit in the target worktree." }
    }

    try {
        $diff = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD'))
    }
    catch {
        $diff = $null
    }
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base could not be computed." }
    }

    $violation = Get-PrAuthorDocsOnlyPathViolation -Path @(ConvertFrom-PrAuthorDocsOnlyNameList -Text ([string]$diff.Output))
    if ($violation) {
        return [ordered]@{ Exempt = $false; Reason = $violation }
    }
    return [ordered]@{ Exempt = $true; Reason = $null }
}
```

## 6. Rule R-JUNIT (reading the Pester JUnit file)

The PoshQC test run writes `artifacts/pester/pester-junit.xml` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `TestResult.OutputPath`). Its observed shape: one `<testsuites ... tests="<n>" errors="<n>" failures="<n>" ...>` element, and one `<testcase name="<Describe>.<Context>.<It>" status="Passed|Failed|Skipped" classname="<absolute suite path>" .../>` line per test case.

- **J0** before the MCP call: `stat -c %Y artifacts/pester/pester-junit.xml`; record the value as `JUNIT_MTIME_BEFORE:`, or `JUNIT_MTIME_BEFORE: absent` when `stat` exits non-zero.
- **J1** after the call: `stat -c %Y artifacts/pester/pester-junit.xml` exits 0 and prints a value greater than `JUNIT_MTIME_BEFORE` (any value when it was `absent`); record `JUNIT_MTIME_AFTER:`. Otherwise the file was not rewritten by this run and the task fails.
- **J2** `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; record only its `tests`, `failures`, and `errors` attribute values.
- **J3** `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`; record each printed line (no output means no failed case).
- **J4** `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count.
- **J5** `grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml`; record the count (`0` required).
- **J6** for each new suite, `grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill\.DocsOnly\.Tests\.ps1"' artifacts/pester/pester-junit.xml`, then the same with `DocsOnly\.Exemption\.Tests\.ps1`, `DocsOnly\.Decision\.Tests\.ps1`, and `BodyNumber\.Tests\.ps1`; record the four counts. A zero count for any suite is a failure (a renamed or missing suite must not read as clean).

## 7. Appendix B — helpers edits (`.claude/hooks/enforce-pr-author-skill-helpers.ps1`)

**H1 - dot-source.** Directly after the whole line `. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.artifact-root.ps1')` insert:

```powershell
# Docs-only exemption from the orchestrator-state preflight (issue #901).
. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.docs-only.ps1')
```

No `try`/`catch` wraps it (a scoped import-failure handler fails `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1`); a load failure is reported by the parent hook's dependency guard against `enforce-pr-author-skill-helpers.ps1`.

**H2 - non-epic branch.** Replace the single whole line `            return "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: $preflightSummary"` (inside `if ($preflightResult.HasErrors) {` in the `else` branch) with:

```powershell
            $exemption = Get-PrAuthorDocsOnlyExemption -CommandText $CommandText -WorktreeRoot $artifact.ArtifactRoot -CheckpointPath $checkpointPath
            if (-not $exemption.Exempt) {
                return "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: $preflightSummary (docs-only exemption not applied: $($exemption.Reason))"
            }
```

The epic branch is not changed. Net change: +3 lines.

**H3 - `.NOTES` (#850 L25).** Replace the whole line `    Compatible with PowerShell 7+. No external module dependencies.` with:

```text
    Compatible with PowerShell 7+. Dependencies are in-repository only: the command parsers
    and worktree-resolution modules loaded below, and the artifact-root and docs-only siblings.
    No PowerShell Gallery module is required.
    The docs-only sibling runs the git executable at call time (issue #901).
```

Net change: +3 lines.

**H4 - `Get-PrAuthorBypassReason` `.DESCRIPTION`.** Replace the three whole lines

```text
        context summary is absent beneath the resolved worktree, ORCHESTRATOR_STATE_PREFLIGHT_FAILED,
        then receipt checks 1-6 via Test-PrAuthorReceiptVerification. Returns $null for all
        allowed patterns.
```

with

```text
        context summary is absent beneath the resolved worktree, ORCHESTRATOR_STATE_PREFLIGHT_FAILED
        unless Get-PrAuthorDocsOnlyExemption exempts a docs-only gh pr create (issue #901), then
        receipt checks 1-6 via Test-PrAuthorReceiptVerification. Returns $null for all allowed
        patterns.
```

Net change: +1 line. Expected helpers total: 429 + 2 + 3 + 3 + 1 = 438 lines.

## 8. Appendix C — main hook header edits (`.claude/hooks/enforce-pr-author-skill.ps1`)

**M1 - `.DESCRIPTION` block case (AC-10).** Directly after the whole line `                  --require-pr-creation-ready before receipt verification runs, else blocked.` insert:

```text
      Docs-only - issue #901: when the preflight fails, gh pr create proceeds to receipt
                  verification only when every condition holds: no checkpoint file exists
                  beneath the resolved worktree; the command carries exactly one explicit
                  --base <branch> and no -B token; refs/remotes/origin/<branch> resolves to
                  a commit; git diff --name-only -z --no-renames <commit>...HEAD exits 0 and
                  lists at least one path; and every listed path starts with docs/ (ordinal,
                  case-sensitive). Otherwise the deny keeps ORCHESTRATOR_STATE_PREFLIGHT_FAILED
                  and appends one sub-code:
                    DOCS_ONLY_EXEMPTION_NOT_CREATE         - gh pr edit is never exempt.
                    DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT - a checkpoint file exists.
                    DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - no single explicit --base, or it
                                                             does not resolve on origin.
                    DOCS_ONLY_EXEMPTION_DIFF_FAILED        - the diff exits non-zero or throws.
                    DOCS_ONLY_EXEMPTION_EMPTY_DIFF         - the diff lists no path.
                    DOCS_ONLY_EXEMPTION_NON_DOCS_PATH      - a listed path is outside docs/.
                  The exemption never applies under epic scope.
```

**M2 - `Receipt` line.** Replace the two whole lines

```text
      Receipt - preflight passed: the SHA-256 receipt is verified in five ordered checks
                (Section below). The first failing check blocks.
```

with

```text
      Receipt - preflight passed or docs-only exemption applied: the SHA-256 receipt is
                verified in the ordered checks (Section below). The first failing check blocks.
```

**M3 - `.NOTES` (#850 L25, AC-8).** Replace the whole line `    Compatible with PowerShell 7+. No external module dependencies.` with:

```text
    Compatible with PowerShell 7+. Dependencies are in-repository only: hook-dependency-guard.ps1,
    the HookPayload, OrchestratorState, and OrchestratorStateUnconditional modules, and the
    epic-base-branch and helpers siblings; the helpers load the command parsers, the
    worktree-resolution modules, and the artifact-root and docs-only siblings.
    No PowerShell Gallery module is required.
    The docs-only exemption runs the git executable at call time (issue #901).
```

Expected main-hook total: 334 + 16 + 0 + 5 = 355 lines.

## 9. Appendix D — artifact-root edits (`.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`, #850 L19, AC-5)

**D1 - header bullet and function.** Directly after the whole line `    - Test-PrAuthorBodyPathEqual and Get-PrAuthorEpicArtifactRoot, the pure path helpers.` insert the line `    - ConvertTo-PrAuthorBodyNumber, the strict body-number parse (issue #901, #850 note L19).` Then, directly before the whole line `function Get-PrAuthorBodyPathBindingReason {`, insert:

```powershell
function ConvertTo-PrAuthorBodyNumber {
    <#
    .SYNOPSIS
        Parse the <N> of artifacts/pr_body_<N>.md, or return $null.
    .DESCRIPTION
        Accepts only ASCII digits that parse as an Int32 and whose canonical invariant spelling
        equals the input, so a value above Int32.MaxValue, a leading zero, and a non-ASCII
        decimal digit all return $null instead of throwing or naming a different file.
    .PARAMETER Digits
        The digit run captured from the body-file name.
    .OUTPUTS
        System.Int32 or $null
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Digits
    )

    $number = 0
    $parsed = [int]::TryParse($Digits, [System.Globalization.NumberStyles]::None, [System.Globalization.CultureInfo]::InvariantCulture, [ref] $number)
    if (-not $parsed -or $number.ToString([System.Globalization.CultureInfo]::InvariantCulture) -cne $Digits) {
        return $null
    }
    return $number
}

```

**D2 - relative form.** Replace the whole line `        $number = [int]$Matches[1]` that directly follows `    if ($value -cmatch '^artifacts/pr_body_(\d+)\.md$') {` with:

```powershell
        $number = ConvertTo-PrAuthorBodyNumber -Digits $Matches[1]
        if ($null -eq $number) {
            return [ordered]@{ Reason = $generic; BodyNumber = $null }
        }
```

**D3 - absolute form.** Replace the five whole lines from `        $number = [int]$Matches[1]` (the one directly after `    if ($value -match '/artifacts/pr_body_(\d+)\.md$') {`) through the closing `        }` of the inner `Test-PrAuthorBodyPathEqual` block with:

```powershell
        $number = ConvertTo-PrAuthorBodyNumber -Digits $Matches[1]
        if ($null -ne $number) {
            $canonical = Join-WorktreeResolutionPath -WorktreeRoot $ArtifactRoot -RepoRelativePath "artifacts/pr_body_$number.md"
            if (Test-PrAuthorBodyPathEqual -Left $value -Right $canonical) {
                return [ordered]@{ Reason = $null; BodyNumber = $number }
            }
        }
```

After D1 to D3, `ConvertTo-PrAuthorBodyNumber` appears on four lines (header bullet, definition, two calls).

## 10. Appendix E — test files

All four files start with `#Requires -Version 7.0`, `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`, and a comment-based `.SYNOPSIS` naming issue #901. Every `It` follows Arrange-Act-Assert with comments. No file creates, writes, or deletes a file, starts a process, sleeps, or mocks `git` (rule 13). The git seam is mocked as Invoke-PrAuthorDocsOnlyGitExe with a -ParameterFilter on $GitArgs[0] ('rev-parse' or 'diff'); no -MockWith script block declares a param() block, because Pester binds $GitArgs and $WorktreeRoot in -ParameterFilter automatically, and an unused declared parameter is a PSReviewUnusedParameter finding that CI's Analyze step rejects and the MCP analyze result cannot show. `OID` below is `('a' * 40)`. `CREATE` below is `gh pr create --base main --title "Docs" --body-file artifacts/pr_body_1.md`. No test command carries `--head`, because `Resolve-PrAuthorWorktreeTarget` is mocked and a head branch would only add epic-scope resolution work that the rows do not exercise.

**E0 - shared baseline block (all four files).** The outer `BeforeAll` contains these lines verbatim (copied from `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`), and the first `It` of the `Describe` is the probe line verbatim:

```powershell
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }
```

**E1 - `enforce-pr-author-skill.DocsOnly.Tests.ps1` (28 cases).** Describe `enforce-pr-author-skill docs-only helpers (issue #901)`.

| ID | Context / It | Assertion |
| --- | --- | --- |
| A0 | probe (E0) | passes |
| A1 | `Get-PrAuthorDocsOnlyPathViolation` returns null for an all-docs set | input `docs/a.md`, `docs/features/x/plan.md`; result `$null` |
| A2 | returns NON_DOCS_PATH for `<Path>` (`-ForEach`, 7 rows) | rows `.claude/hooks/x.ps1`, `.github/workflows/ci.yml`, `README.md`, `docsx/a.md`, `doc/a.md`, `Docs/a.md`, `docs`; result `-BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'` and contains the row path |
| A3 | names the first offending path of a mixed set | input `docs/a.md`, `src/b.ps1`, `.github/c.yml`; result contains `src/b.ps1` and not `.github/c.yml` |
| A4 | returns EMPTY_DIFF for an empty set | input `@()`; result `-BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'` |
| A5 | `ConvertFrom-PrAuthorDocsOnlyNameList` splits a NUL list with spaces and non-ASCII names | input `"docs/a b.md`0docs/" + [char]0x00E9 + ".md`0"`; `@(...)` has 2 elements equal to `docs/a b.md` and `"docs/" + [char]0x00E9 + ".md"` |
| A6 | keeps a line feed inside a name as one element | input `"docs/line`nbreak.md`0"`; 1 element containing `` `n `` |
| A7 | returns no element for empty and null text | `@(... -Text '')` and `@(... -Text $null)` both have count 0 |
| A8 | `Get-PrAuthorDocsOnlyBaseName` accepts `<Command>` (`-ForEach`, 3 rows) | `--base main` -> `main`; `--base=main` -> `main`; `--base epic/x-integration` -> `epic/x-integration` (each in a `gh pr create ... --body-file artifacts/pr_body_1.md` command) |
| A9 | rejects `<Name>` (`-ForEach`, 6 rows) | no `--base`; `-B main`; `--base -x`; `--base a..b`; `--base main --base dev`; trailing `--base` with no value; each returns `$null` |
| A10 | returns null for gh pr edit | `gh pr edit 12 --base main --body-file artifacts/pr_body_1.md` -> `$null` |
| A11 | `Test-PrAuthorDocsOnlyCheckpointPresence` reports an existing file | `-CheckpointPath $PSCommandPath` -> `$true` |
| A12 | reports a missing file as absent | `-CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint-901.json')` -> `$false` |
| A13 | reports a blank path as present (fail closed) | `-CheckpointPath ''` -> `$true` |
| A14 | `Invoke-PrAuthorDocsOnlyGitExe` returns the failure object for a nonexistent root | `-WorktreeRoot '/synthetic-worktrees/no-such-root-901' -GitArgs @('status')`; `ExitCode` is `-1` and `Output` is `''` |

**E2 - `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (15 cases).** Describe `Get-PrAuthorDocsOnlyExemption (issue #901)`. `BeforeEach`: presence mocked `$false`; rev-parse mocked `ExitCode 0, Output OID`; diff mocked `ExitCode 0, Output "docs/a.md`0"`. Each row calls `Get-PrAuthorDocsOnlyExemption -CommandText <command> -WorktreeRoot '/synthetic-worktrees/docs-only-901' -CheckpointPath '/synthetic-worktrees/docs-only-901/checkpoint-901.json'` and overrides one mock where stated.

| ID | It | Override | Assertion |
| --- | --- | --- | --- |
| X0 | probe (E0) | - | passes |
| X1 | exempts a docs-only create | none, command `CREATE` | `Exempt` `$true`, `Reason` `$null` |
| X2 | denies gh pr edit | command `gh pr edit 12 --base main --body-file artifacts/pr_body_1.md` | Reason `-BeLike 'DOCS_ONLY_EXEMPTION_NOT_CREATE*'`; git seam invoked 0 times |
| X3 | denies when a checkpoint file exists | presence `$true` | `DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT*`; git seam invoked 0 times |
| X4 | denies without an explicit --base | command `CREATE` without `--base main` | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*`; git seam invoked 0 times |
| X5 | denies when rev-parse fails | rev-parse `ExitCode 1, Output ''` | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*` |
| X6 | denies when rev-parse prints no object id | rev-parse `ExitCode 0, Output 'not-an-object-id'` | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*` |
| X7 | denies when rev-parse throws | rev-parse `throw 'simulated rev-parse failure'` | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*` |
| X8 | denies when the diff fails | diff `ExitCode 128, Output ''` | `DOCS_ONLY_EXEMPTION_DIFF_FAILED*` |
| X9 | denies when the diff throws | diff `throw 'simulated diff failure'` | `DOCS_ONLY_EXEMPTION_DIFF_FAILED*` |
| X10 | denies an empty diff | diff `ExitCode 0, Output ''` | `DOCS_ONLY_EXEMPTION_EMPTY_DIFF*` |
| X11 | denies a non-docs path | diff output `".claude/hooks/x.ps1`0"` | `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*` |
| X12 | denies a rename from outside docs reported as delete plus add | diff output `".claude/x.md`0docs/x.md`0"` | `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*` and contains `.claude/x.md` |
| X13 | runs the diff with -z, --no-renames, --no-relative, and the three-dot range | none | `Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' -and $GitArgs -contains '-z' -and $GitArgs -contains '--no-renames' -and $GitArgs -contains '--no-relative' -and $GitArgs[-1] -ceq (('a' * 40) + '...HEAD') }` |
| X14 | resolves the base on origin in the target worktree | none | `Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' -and $WorktreeRoot -eq '/synthetic-worktrees/docs-only-901' }` |

**E3 - `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (8 cases).** Describe `enforce-pr-author-skill.ps1 docs-only exemption decision (issue #901)`. `BeforeEach`: `Resolve-PrAuthorWorktreeTarget` -> `[pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/docs-only-901'; ReasonCode = $null; Detail = 'synthetic docs-only root' }`; `Get-PrContextArtifactExistence` -> `$true`; `Invoke-OrchestratorStatePreflight` -> `@{ HasErrors = $true; ErrorText = '' }`; `Test-PrAuthorDocsOnlyCheckpointPresence` -> `$false`; rev-parse -> `ExitCode 0, Output OID`; diff -> `ExitCode 0, Output "docs/a.md`0docs/b.md`0"`; `Get-PrBodyFileBytes` -> `[byte[]]@(0x41)`; `Get-PrAuthorReceiptContent` -> `'{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}'`; `Get-PrContextSummaryLastWriteUtc` -> `[DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime()`; `Get-PrAuthorCheckpointContent` -> `$null`. Each row calls `Invoke-PrAuthorSkillDecision -ToolInputRaw` with a payload built as `@{ tool_input = @{ command = <command> } } | ConvertTo-Json -Depth 5 -Compress`.

| ID | It | Override | Assertion |
| --- | --- | --- | --- |
| C0 | probe (E0) | - | passes |
| C1 | allows a docs-only gh pr create with no checkpoint (AC-1) | command `CREATE` | `permissionDecision` `allow` |
| C2 | denies a branch that changes a .claude path | diff output `".claude/hooks/x.ps1`0"` | `deny`; reason `-BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'` and contains `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH` |
| C3 | keeps the preflight verdict when a checkpoint file exists | presence `$true` | `deny`; reason contains `DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT`; git seam invoked 0 times |
| C4 | never consults the exemption when the preflight passes (AC-3) | preflight `@{ HasErrors = $false; ErrorText = '' }` | `allow`; git seam and presence seam each invoked 0 times |
| C5 | denies gh pr edit --body-file | command `gh pr edit 12 --base main --body-file artifacts/pr_body_1.md` | `deny`; reason contains `DOCS_ONLY_EXEMPTION_NOT_CREATE` |
| C6 | still runs the receipt checks on an exempt branch | body bytes `[byte[]]@(0x42)` | `deny`; reason `-BeLike 'PR_AUTHOR_RECEIPT_HASH_MISMATCH*'` |
| C7 | denies a create without --base | command `CREATE` without `--base main` | `deny`; reason contains `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` |

**E4 - `enforce-pr-author-skill.BodyNumber.Tests.ps1` (9 cases).** Describe `Get-PrAuthorBodyPathBindingReason body number (issue #901, #850 note L19)`. Rows N1 to N7 call `Get-PrAuthorBodyPathBindingReason -CommandText "gh pr create --body-file <value>" -ArtifactRoot '/synthetic-worktrees/item-901' -RelativeBodyAllowed <bool>` inside { $script:BindingResult = Get-PrAuthorBodyPathBindingReason ... } | Should -Not -Throw and then assert $script:BindingResult (a script-scoped capture, because the block runs in a child scope); row N8 captures $script:Decision the same way.

| ID | It | Value / RelativeBodyAllowed | Assertion |
| --- | --- | --- | --- |
| N0 | probe (E0) | - | passes |
| N1 | denies a relative number above Int32.MaxValue without throwing | `artifacts/pr_body_99999999999.md` / `$true` | Reason `-BeLike 'PR_BODY_PATH_NONCANONICAL*'`; BodyNumber `$null` |
| N2 | denies an absolute number above Int32.MaxValue without throwing | `/synthetic-worktrees/item-901/artifacts/pr_body_99999999999.md` / `$false` | `PR_BODY_PATH_NONCANONICAL*`; BodyNumber `$null` |
| N3 | denies a relative leading-zero number | `artifacts/pr_body_007.md` / `$true` | `PR_BODY_PATH_NONCANONICAL*`; BodyNumber `$null` |
| N4 | denies an absolute leading-zero number | `/synthetic-worktrees/item-901/artifacts/pr_body_007.md` / `$false` | `PR_BODY_PATH_NONCANONICAL*`; BodyNumber `$null` |
| N5 | denies non-ASCII decimal digits | `"artifacts/pr_body_" + [char]0x0661 + [char]0x0662 + ".md"` / `$true` | `PR_BODY_PATH_NONCANONICAL*`; BodyNumber `$null` |
| N6 | accepts a canonical relative number | `artifacts/pr_body_7.md` / `$true` | Reason `$null`; BodyNumber `7` |
| N7 | accepts a canonical absolute number | `/synthetic-worktrees/item-901/artifacts/pr_body_7.md` / `$false` | Reason `$null`; BodyNumber `7` |
| N8 | returns a deny decision end to end for an oversized number | `Resolve-PrAuthorWorktreeTarget` -> SessionRoot `/synthetic-worktrees/item-901`; `Get-PrContextArtifactExistence` -> `$true`; preflight -> `@{ HasErrors = $false; ErrorText = '' }`; command `gh pr create --title "B" --body-file artifacts/pr_body_99999999999.md` | the block `{ $script:Decision = Invoke-PrAuthorSkillDecision ... }` piped to `Should -Not -Throw`; `$script:Decision.hookSpecificOutput.permissionDecision` `deny`; reason `-BeLike 'PR_BODY_PATH_NONCANONICAL*'` |

**AC-2 traceability.** Outside `docs/` (`.claude/`, `.github/`, root file, `docsx/`, `doc/`, case): A2, X11, C2. Rename into `docs/`: X12, X13. Empty diff: A4, X10. No explicit `--base`: A9, X4, C7. Base not resolvable: X5, X6, X7. Diff fails or throws: X8, X9. Not create: X2, C5. Checkpoint present: X3, C3.

## 11. Appendix F — evidence record content

**F1 - `note-850-L20-record` (AC-6).** Fields: `Timestamp:`; `Command:` (the four [P1-T28] commands); `EXIT_CODE: 0`; `Output Summary:`; `NOTE: #850 L20`; `FILE-LINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1:<n> function Test-ChildCheckpointPrGateBinding`; `FILE-LINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1:<n> [int]::TryParse of pr_gate.pr_number; the branch that follows returns $false`; `FILE-LINE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:<n> Context 'child checkpoint pull request binding'`; `FILE-LINE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:<n> It 'returns the pr_gate equality result' -ForEach`; `COVERING-ROW: add a -ForEach row (or an It) with checkpoint '{"pr_gate":{"pr_number":"abc"}}' and -CommandPrNumber 812, expecting $false`; `DECISION: NO-CHANGE-IN-THIS-ITEM`; `RATIONALE: the branch is fail-closed and correct by inspection; only a covering row is missing; the file is outside the pr-author hook family, and the operator excluded it because a concurrent epic may own the merge-gate files.`

**F2 - `notes-850-L21-L23-no-change` (AC-7).** Three sections, each with `NOTE:`, `FILE-LINE:` lines filled from the [P1-T29] output, `DECISION: NO-CHANGE`, and `RATIONALE:`.
- L21: `Get-EpicWorktreeGateDenyDiagnostics` and its `PSUseSingularNouns` suppression in `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`. Rationale: the suppression is localized and justified, PSScriptAnalyzer reports no diagnostic, the review classified it as non-blocking, and a rename would edit four production files (two canonical, two bundle mirrors) and one test outside the pr-author family. Trigger: rename when the removal gate is next edited.
- L22: the positive-JSON-integer rule in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (`Test-WorktreeItemCheckpointRecordsPr`) and `Test-StandalonePositiveJsonInteger` in `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`. Rationale: the copies are equivalent today; a module cannot depend on a hook-scope function without inverting the dependency direction; a drift produces a deny, not an unbound allow, because the gate re-checks the checkpoint it reads; both files are outside the family. Trigger: consolidate into a shared module when either copy changes.
- L23: `[long]::TryParse` in `WorktreeItemResolution.psm1` versus `[int]::TryParse` in `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`. Rationale: the command PR number is an Int32 in both paths, so the observable result is identical for every input; both files are outside the family. Within the pr-author family, Int32 is used throughout after the L19 fix.

**F3 - `follow-up-and-decisions`.** `FOLLOW-UP: .claude/agents/pr-author.md (the missing-checkpoint deny statement) does not describe the docs-only exemption.` `FOLLOW-UP: .claude/skills/pr-author/SKILL.md (the hook-validates-the-checkpoint statement) does not describe the docs-only exemption.` `FOLLOW-UP: .claude/agents/orchestrator.md and .claude/skills/orchestrate/SKILL.md describe the orchestrated path, which is unchanged; their "subprocess seam" wording is already stale since issue #475.` `ISSUE-CREATED: none`. Then one line per decision `DECISION: D<n> <one-sentence summary>` for D1 to D12 of section 3.
