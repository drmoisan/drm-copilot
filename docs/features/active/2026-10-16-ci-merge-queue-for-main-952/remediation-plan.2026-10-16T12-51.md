# 2026-10-16-ci-merge-queue-for-main (Remediation Plan, cycle 1)

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above serves preflight rounds only. The orchestrator deletes the directive line and this paragraph (ORCH-R0) before delegating execution, because the executor stop hook `.claude/hooks/validate-executor-output.ps1` selects preflight mode from the plan file (`:97`).

- **Issue:** #952
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Draft (remediation cycle 1, initial authoring)
- **Work Mode:** full-bug (`issue.md` metadata `- Work Mode: full-bug`; `spec.md` `## Acceptance Criteria` is the acceptance-criteria source; `user-story.md` is intentionally absent)
- **Branch:** `bug/ci-merge-queue-for-main-952`
- **Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
- **Main plan:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md` (fully executed; not edited by this plan)
- **Remediation inputs:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-inputs.2026-10-16T12-51.md`; `policy-audit.2026-10-16T12-51.md`; `code-review.2026-10-16T12-51.md`; `feature-audit.2026-10-16T12-51.md`; `evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md` (all in the feature folder)

## Scope of This Cycle

- **R1 (Blocking, autonomous):** `.codex/hooks/enforce-epic-merge-gate-command.ps1` is at 75.47% line and changed-line coverage on R_final 38899600487 (uncovered lines 63, 64, 68, 160, 161, 166, 173, 176 to 180, 183). Phase 1 replaces the scoped diagnosis run of remediation-inputs R1 step 1 with a static diagnosis (no local Pester coverage run is possible in this session; see Conventions). Phase 2 adds Codex cases that run in-process against the Codex copy, a provenance case that fails unless the Codex suite resolves the helper functions from the Codex file, and a setup-parity edit. Phase 3 is not required by R1 but by CR-4.
- **CR-2 (Minor):** Claude B-4 cases for helper lines 68, 160, 161.
- **CR-3 (Minor):** parser cases for parser lines 98, 101, 108, 128.
- **CR-4 (Minor):** `Get-EpicMergeGateSelectorPrNumber` returns from the `--merge=<value>` branch only when the value converts to a number; fail-before case `gh pr merge --merge=true 5` on both runtimes; all four helper copies stay byte-identical.
- **CR-5 (Minor):** the file-supplied GraphQL mutation limitation is documented in the helper header (all four copies) and in `spec.md` `## Rollout & Follow-up` (no acceptance-criterion text is edited).
- **CR-7 (Info):** `evidence/other/scope-deviation-d10.<timestamp>.md`.
- **CR-8 (Nit):** `ruleset/runbook.md` capture step points to a scratch directory and states the capture file is not committed; the AC-24 runbook token check is re-run.
- **CR-6 and CR-9 (Info):** orchestrator-owned, recorded in `## Orchestrator-Owned Verification` (ORCH-R3).
- **R2 (AC-28, awaiting_ci):** no task. AC-28 is resolved at S9 by the main plan's ORCH-3 and ORCH-7.

## Conventions (binding for every task)

**FEATURE.** `FEATURE` = `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`. `REM_PLAN` = `FEATURE/remediation-plan.2026-10-16T12-51.md`. Every evidence artifact is written under `FEATURE/evidence/<kind>/` with `<kind>` one of `remediation-baseline`, `regression-testing`, `qa-gates`, `other`. No artifact is written under `artifacts/`. No artifact records an absolute host path; the worktree root is recorded as the literal token `WORKTREE_ROOT`.

**Evidence filenames and timestamps.** Each artifact is named `<name>.<timestamp>.md`. The `<timestamp>` in the filename and the `Timestamp:` field are host-clock UTC in `yyyy-MM-ddTHH-mm` form, read immediately before the write by the first of these that runs: `date -u +%Y-%m-%dT%H-%M`; `poetry run python -c "import datetime; print(datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H-%M'))"`; `git var GIT_COMMITTER_IDENT` (prints the current epoch seconds; the artifact then records `ClockSource: git var GIT_COMMITTER_IDENT`, the raw epoch value, and its UTC conversion). No stamp is composed or estimated. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.

**SCRATCH.** `SCRATCH` resolves to `<session scratchpad>/issue-952/`. The executor writes no scratch file. The only scratch files of this plan are the orchestrator's CI artifact downloads in `## Orchestrator-Owned Verification`, each under `SCRATCH/issue-952-ci-<runId>/`. Plans and evidence record the literal token `SCRATCH`, never a host path. Scratch files are not committed.

**Executor capability boundary.** The atomic-executor's tools are Read, Grep, Glob, Edit, Write, the Bash patterns `poetry run black *`, `poetry run ruff *`, `poetry run pyright *`, `poetry run pytest *`, `npx prettier *`, `npx eslint *`, `npx tsc *`, `npx jest *`, `pwsh *` and `git *` (`.claude/agents/atomic-executor.md:11-20`), and the PoshQC MCP tools (`:21-24`). The `pwsh` entry is not usable: the worktree-isolation guard (a runtime guard, not a file in this repository) refuses any command text containing `pwsh`, `bash` or `wsl`, a heredoc, a `cd ... &&` chain, or `git -C`. No task invokes Pester, `Invoke-Pester`, PSScriptAnalyzer or Invoke-Formatter directly, and no scoped Pester coverage run is performed by anyone in this session (the orchestrator has `gh` but no PowerShell tool either). The executor has no `gh`. Per-test results and coverage come only from CI artifacts that the orchestrator reads after a `gh workflow run ci.yml` dispatch (ORCH-R1 to ORCH-R3).

**Python environment precondition.** `poetry install` was run in this worktree by the orchestrator. The executor does not run it. If any `poetry run` command fails with a missing-module, missing-interpreter or environment error (as distinct from a test failure), the executor records the error text and halts for the caller.

**PowerShell verification (Option A).** Local PowerShell verification uses only `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze` and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` = the worktree root and an explicit `scan_folders` list. Folder keys:

| Key | `scan_folders` value |
|---|---|
| `src-claude-hooks` | `.claude/hooks` |
| `src-codex-hooks` | `.codex/hooks` |
| `t-claude-hooks` | `tests/scripts/claude-hooks` |
| `t-codex-hooks` | `tests/scripts/codex-hooks` |
| `t-ci-gate` | `tests/scripts/claude-lib/ci-gate` |
| `t-claude-runtime` | `tests/scripts/claude-runtime` |

`R-FSET` (format and analyze) is the five keys other than `t-claude-runtime`. `R-TSET` (test) is the four `t-` keys.

**MCP observation rule (fixed).** A PoshQC MCP result carries only a pre-composed summary string and no count, finding, test name or coverage value. The only observables are: (1) call disposition — the call returned (record `EXIT_CODE: 0`, `Disposition: RETURNED`) or the call raised (record `EXIT_CODE: 1`, `Disposition: RAISED`, and the error text verbatim); and (2) for `run_poshqc_format`, the tree comparison `git status --porcelain -- <the scan folders of the call>` recorded immediately before and after the call. No acceptance condition reads a count, percentage, finding or test name from an MCP result. The `Command:` field of an MCP artifact is written `mcp__drm-copilot__<tool> workspace_root=WORKTREE_ROOT scan_folders=[<folders>]`.

**Baseline disposition rule.** P0-T7 and P0-T8 record each folder's baseline disposition as `GREEN` (returned) or `RED` (raised). For a later analyze or test call on a `GREEN` folder, the acceptance is the stated disposition. For a `RED` folder, the later call is recorded `LOCAL-NONDISCRIMINATING (baseline RED)`, it is not counted as evidence, and the CI job of `R_final_2` (ORCH-R1, ORCH-R2) is the only gate; an `[expect-fail]` task on a `RED` folder writes the fail-before exception dossier named in that task instead of expecting a raised call.

**Expect-fail artifacts.** Every `[expect-fail]` artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, `Output Summary:` (the error text), and a `RowAttribution:` section listing each row the task names with its expected pre-change outcome and its code-path reason, because an MCP result names no row. A returned call on a `GREEN` folder fails the task and halts execution for the caller.

**Mirror mechanism (same as the main plan).** The Claude helper `.claude/hooks/enforce-epic-merge-gate-command.ps1` is the edited source. The Codex helper `.codex/hooks/enforce-epic-merge-gate-command.ps1` is written with the Write tool from the Claude file's exact text as read with the Read tool, and verified by equal `git hash-object` hashes. Bundle mirrors are produced from the git index: `git add <source>` and then `git checkout-index -f --prefix=<bundle>/ -- <source>`, with `<bundle>` = `extensions/drm-copilot/resources/claude-customizations` for the `.claude/` source and `extensions/drm-copilot/resources/codex-and-agents-customizations` for the `.codex/` source (the trailing `/` is part of the prefix). `git checkout-index` prints nothing on success; the observation is `git hash-object` printing four equal hashes for the four copies.

**Search and count rule.** Searches use `git grep` over tracked paths; a created or edited file is staged with `git add` before any `git grep` that must see the new text. Patterns are passed with `-e`. Line counts use `git grep -c -e "^" -- <paths>`. No search literal contains a backslash.

**Commit rule.** At the end of each executor phase: `git add` of the named paths plus `FEATURE/evidence/` and `REM_PLAN`, `git commit -m "<message>"`, `git push origin bug/ci-merge-queue-for-main-952`. Never `git add -A`, never force-push, never merge or rebase. If a hook refuses a staging, commit or push command, the executor records the refusal text and halts; it does not bypass hooks.

**Edit order and cited lines.** Edits within one file run bottom-up, so the cited line numbers stay valid at each step. Every cited line number was derived against the tree at commit `8f3c1c6f5` (branch head at authoring), whose per-file line counts P0-T5 asserts. A mismatch the executor observes is recorded and halts execution for the caller; the executor does not adjust a cited line number itself.

**Acceptance criteria check-offs.** The executor checks off no acceptance criterion. AC-1, AC-2, AC-5 to AC-15 and AC-27 are checked off by the orchestrator in ORCH-R3 after ORCH-R1 to ORCH-R3 pass on one run; AC-28 at S9 (main plan ORCH-3, ORCH-7). AC-24 is already checked; P4-T4 re-verifies it after the runbook edit.

**Frozen epic surfaces.** No task edits `.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-orchestrate/SKILL.md`; P5-T10 asserts both are absent from the changed set, so the frozen-digest re-baseline of the main plan is not triggered.

## Decisions Recorded by the Planner

- **Static diagnosis replaces the scoped coverage run.** Remediation-inputs R1 step 1 asks for a scoped Pester coverage run and for `(Get-Command Get-EpicMergeGateSelectorPrNumber).ScriptBlock.File` from inside the suite. Neither can run locally (Conventions, executor capability boundary). Phase 1 records the static facts that bear on attribution; the `ScriptBlock.File` observation is moved into the Codex suite as the provenance case of Appendix R.2(b), which CI evaluates in ORCH-R1 (job `poshqc / PowerShell QC`, coverage on) and ORCH-R2 (job `poshqc / PowerShell hook suites (Linux)`).
- **Planner reading of the attribution question (input to P1-T6, not a finding).** Facts read at authoring: the Codex merge-queue suite dot-sources the Codex gate in-process (`tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:33-35`), the gate dot-sources the Codex helper in-process (`.codex/hooks/enforce-epic-merge-gate.ps1:21`), and its C-4 rows at `:134` (URL selector) and `:135` (REST path) reach helper lines 63-64 and 176-180 through `Get-CodexMergeCommandPrNumber` (`.codex/hooks/enforce-epic-merge-gate.ps1:68`); no test file defines a helper function (a search of `tests/` for the helper function names returns nothing); the coverage run is a single `Invoke-Pester` call (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:397`) over the population of `config/poshqc-coverage.json`, and no `UseBreakpoints` key is set (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`). The one setup difference between the Claude MergeQueue suite (credited for the same lines on the Claude copy) and the Codex merge-queue suite is that the Claude suite resolves the hook path with `Resolve-Path` (`tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:30`) and the Codex suite passes an unresolved `Join-Path` result (`:34`). The static cause is therefore expected to remain undetermined; the plan addresses the two remaining hypotheses deterministically: H1 (path form) by the setup-parity edit of Appendix R.2(c), and H2 (resolution to another copy) by the provenance case of Appendix R.2(b). Lines 68, 160, 161, 166, 173 and 183 are driven by no Codex reader case today and are covered by the rows of Appendix R.2(a).
- **Setup-parity edit is a hardening, not a confirmed fix.** Appendix R.2(c) is applied unconditionally, so the executor makes no choice. If ORCH-R3 still reports the Codex helper below 85.00 while the provenance row passes, the item routes to a further remediation cycle with that evidence.
- **CR-5 location.** The follow-up is added to `spec.md` `## Rollout & Follow-up` (after `:336`), not to `policy-followups.md`, because it is not a policy-file change. No acceptance-criterion line of `spec.md` changes (P4-T1 asserts a one-line, add-only diff).
- **CR-4 shape.** The equals-joined value is converted once; a `$null` result advances the scan by the existing one-token step (`.claude/hooks/enforce-epic-merge-gate-command.ps1:168`), because `--merge=<value>` is not in `$script:EpicMergeGateValueFlags` (`:22`). A numeric or URL value returns as before.
- **Parser cases are characterization cases.** The four Appendix R.4 cases pass against the unchanged parser; the parser is not edited, so they need no fail-before run. P2-T9 halts for the caller if the `t-ci-gate` call raises.

## Files Written

Every repository-relative path this plan creates or modifies. No task writes a path absent from this list.

Modified outside the feature folder (7):

- `.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T2 to P3-T4)
- `.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T5, Write-tool copy)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T6)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T6)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (P2-T1 to P2-T3)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (P2-T4)
- `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` (P2-T5)

Inside the feature folder:

- `FEATURE/spec.md` (P4-T1, one added line under `## Rollout & Follow-up`; orchestrator AC check-offs in ORCH-R3)
- `FEATURE/ruleset/runbook.md` (P4-T3, line `:23` only)
- `FEATURE/remediation-plan.2026-10-16T12-51.md` (ORCH-R0 deletes the directive line and its paragraph; after that, checklist state only)
- `FEATURE/evidence/**` (every artifact named in the tasks)

Not edited: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `config/poshqc-coverage.json`, `.github/workflows/_poshqc.yml`, `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, every file under `.claude/rules/` and `.github/instructions/`, `FEATURE/plan.2026-10-16T00-15.md`, `FEATURE/policy-followups.md`, `FEATURE/issue.md`, every Python file. No coverage exclusion is added and no threshold changes. Deleted: none.

## Restart Rule (Phase 5)

P5-T1 through P5-T4 form the final QA loop. If P5-T1 changes a tracked file, or if P5-T2 raises on a `GREEN` key, fix the cause without adding a suppression attribute and without changing an Appendix R test expectation; when the changed file is `.claude/hooks/enforce-epic-merge-gate-command.ps1`, repeat P3-T5 and P3-T6 so all four copies match; commit; and restart from P5-T1, writing a new artifact (new `<timestamp>`) for each re-run task. A raised P5-T3 call on a `GREEN` key or a failing P5-T4 run halts execution for the caller instead (P5-T3 and P5-T4). P5-T5 records every pass. Do not proceed to P5-T6 until P5-T1 through P5-T4 pass in one uninterrupted pass.

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read the policy files and the remediation inputs in the required order and write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  Order: `CLAUDE.md`; `.github/copilot-instructions.md`; `.claude/rules/tonality.md`; `.github/instructions/tonality.instructions.md`; `.claude/rules/general-code-change.md`; `.github/instructions/general-code-change.instructions.md`; `.claude/rules/general-unit-test.md`; `.github/instructions/general-unit-test.instructions.md`; `.claude/rules/quality-tiers.md`; `quality-tiers.yml`; `.claude/rules/powershell.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.claude/rules/python.md`; `.github/instructions/python-unit-test.instructions.md`; `.claude/rules/plan-acceptance-gates.md`; then `FEATURE/remediation-inputs.2026-10-16T12-51.md`; `FEATURE/policy-audit.2026-10-16T12-51.md`; `FEATURE/code-review.2026-10-16T12-51.md`; `FEATURE/feature-audit.2026-10-16T12-51.md`; `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md`.
  Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the twenty-one paths above in that order, one per line; it records `Work Mode: full-bug` read from `FEATURE/issue.md`, and `spec.md: present`, `user-story.md: absent` after a Glob of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/{spec.md,user-story.md}`. No policy file is modified.
- [ ] [P0-T2] Capture the branch state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/branch-state.<timestamp>.md`.
  Commands: `git fetch origin`; `git rev-parse --abbrev-ref HEAD`; `git rev-parse HEAD`; `git rev-parse origin/main`; `git merge-base origin/main HEAD`; `git status --porcelain`; `git grep -c -e "^DIRECTIVE: PREFLIGHT VALIDATION ONLY$" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`.
  Acceptance: the last command (anchored at both line ends, so it matches only a line that is exactly the directive) exits 1 with no output and is recorded in its own artifact `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/directive-removed.<timestamp>.md` with `EXIT_CODE: 1`, `ExpectedExitCode: 1` and `Output Summary: DIRECTIVE_REMOVED=true`. Before ORCH-R0 the same command prints a count of 1 and exits 0; that outcome records `DIRECTIVE_REMOVED=false`, fails the task, and halts execution. `EXIT_CODE: 0` for each other command; `Output Summary:` records the branch name `bug/ci-merge-queue-for-main-952` (any other value fails the task), `REM_BASE_SHA=<git rev-parse HEAD output>`, the `origin/main` SHA, `B_NOW=<merge-base output>`, and the porcelain output verbatim. The porcelain output is expected to list only the untracked P0-T1 artifact; any other listed path fails the task and halts execution.
- [ ] [P0-T3] Check `origin/main` for concurrent changes to the files this plan touches or depends on and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/concurrency-check.<timestamp>.md`.
  Command: `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 .github/workflows/_poshqc.yml scripts/powershell/PoshQC config/poshqc-coverage.json`
  Acceptance: `EXIT_CODE: 0`; the output recorded verbatim. Empty output records `CONCURRENT_CHANGES=0`. A non-empty output records `CONCURRENT_CHANGES=<line count>`, fails the task, and halts execution for the caller (the orchestrator merges `origin/main`, re-runs the main plan's ORCH-1, and obtains a planner re-derivation delta before resuming).
- [ ] [P0-T4] Capture the baseline hashes of the four helper copies into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/helper-hashes.<timestamp>.md`.
  Command: `git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1`
  Acceptance: `EXIT_CODE: 0`; four hashes recorded with their paths, each equal to `d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd` (the value recorded in `FEATURE/evidence/other/mirror-sync-hooks.2026-10-16T11-03.md`); `Output Summary:` records `HELPER_COPIES_EQUAL=4/4` and `HELPER_BASE_HASH=d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd`. Any other value fails the task and halts execution.
- [ ] [P0-T5] Capture the baseline line counts into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/line-counts.<timestamp>.md`.
  Command: `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`
  Acceptance: `EXIT_CODE: 0`; the output, read as a set of lines, equals exactly: `.claude/hooks/enforce-epic-merge-gate-command.ps1:184`; `.codex/hooks/enforce-epic-merge-gate-command.ps1:184`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:190`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:191`; `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1:121`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md:337`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md:60`. A missing, extra or different line is recorded and halts execution, because the cited line numbers depend on these counts.
- [ ] [P0-T6] Capture the baseline PowerShell format state of R-FSET into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/ps-format.<timestamp>.md`.
  Commands: `git status --porcelain -- .claude/hooks .codex/hooks tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-lib/ci-gate` (before); `mcp__drm-copilot__run_poshqc_format` with the five R-FSET folders; the same `git status --porcelain` command (after).
  Acceptance: the before-output is empty and the call returned. An empty after-output records `PRE-EXISTING-FORMAT-DRIFT=NONE`. A non-empty after-output records every listed path under `PRE-EXISTING-FORMAT-DRIFT`, each listed path is restored with `git restore -- <listed path>`, and a final run of the same `git status --porcelain` command is recorded empty. A raised call is recorded and halts execution for the caller.
- [ ] [P0-T7] Capture the baseline analyzer disposition of each R-FSET folder, one call and one artifact per folder, into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/ps-analyze-<key>.<timestamp>.md` for each of the five R-FSET keys.
  Command (five calls): `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = the single folder of the key.
  Acceptance: five artifacts exist, each recording the call disposition and `Baseline: GREEN` (returned) or `Baseline: RED` (raised, with the error text). A `RED` folder is not a stop condition; the Baseline disposition rule governs its later calls.
- [ ] [P0-T8] Capture the baseline test disposition of each R-TSET folder, one call and one artifact per folder, into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/ps-test-<key>.<timestamp>.md` for each of the four R-TSET keys.
  Command (four calls): `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = the single folder of the key.
  Acceptance: four artifacts exist, each recording the call disposition, `Baseline: GREEN` or `Baseline: RED`, and the statement that per-suite Passed counts and coverage come from CI (P0-T9 for the baseline, ORCH-R1 to ORCH-R3 after the change), not from this call.
- [ ] [P0-T9] Record the baseline PowerShell coverage and Passed-count headline into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/ps-coverage.<timestamp>.md`.
  Sources (Read): `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md`, `FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T12-40.md`, `FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T12-40.md` (R_final 38899600487, job `poshqc / PowerShell QC` for coverage).
  Acceptance: `Output Summary:` records, copied verbatim from the sources: `R_BASE_REM=38899600487`; `CODEX_HELPER_LINE=75.47` and `CODEX_HELPER_CHANGED=75.47` with uncovered lines `63, 64, 68, 160, 161, 166, 173, 176, 177, 178, 179, 180, 183`; `CLAUDE_HELPER_LINE=94.34` with uncovered lines `68, 160, 161`; `PARSER_LINE=91.67` with uncovered lines `98, 101, 108, 128`; Windows Passed counts `CLAUDE_MQ=36`, `CODEX_MQ=34`, `PARSER_SUITE=13`; Linux Passed counts `CLAUDE_MQ=36`, `CODEX_MQ=34`. Every value is numeric; a value that differs from the source halts execution.
- [ ] [P0-T10] Capture the baseline Python contract-suite result into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/python-contract-suites.<timestamp>.md`.
  Command (`PY-CONTRACT`): `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the final pytest summary line recorded verbatim, containing `passed` and neither `failed` nor `error`. A failure is recorded with its node IDs and halts execution for the caller.
- [ ] [P0-T11] Record Python applicability into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/python-coverage-applicability.<timestamp>.md`.
  Acceptance: the artifact records `PY_COVERAGE=NOT-APPLICABLE` and `PY_TOOLCHAIN=REGRESSION-ONLY`, with the reason that `## Files Written` names no Python file, so Black, Ruff and Pyright have no touched input and the `PY-CONTRACT` command (P0-T10, P5-T4) is the Python regression gate; it states that P5-T10 verifies `PY_PATHS=0` in the final changed set.
- [ ] [P0-T12] Commit and push the Phase 0 evidence and the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "docs(952): record remediation cycle 1 baseline"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

### Phase 1 — Coverage-Attribution Diagnosis (static, R1)

- [ ] [P1-T1] Record how the test tree loads the Codex gate and helper into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-helper-loads.<timestamp>.md`.
  Command: `git grep -n -e "enforce-epic-merge-gate.ps1" -e "enforce-epic-merge-gate-command.ps1" -- tests/scripts`; then Read each listed file around every output line that is under `tests/scripts/codex-hooks` or that builds a `.codex/hooks` path (including the runtime table of `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:22-25`).
  Acceptance: `EXIT_CODE: 0`; the output recorded verbatim; a table classifies each such line by this rule: `IN_PROCESS` when the path is dot-sourced (`. (` or `. $` at statement start, on that line or on the line that consumes the variable it sets); `CHILD_PROCESS` when the path is passed to `Invoke-HookProcess`, `pwsh`, `Start-Process`, or `&` with `-File`; `REFERENCE` otherwise. `Output Summary:` records `CODEX_GATE_IN_PROCESS_LOADS=<n>`, `CODEX_GATE_CHILD_PROCESS_LOADS=<n>`, `MQ_SUITE_LOAD=<IN_PROCESS or CHILD_PROCESS>` for `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:34-35`, and `HELPER_DIRECT_LOADS=<n>` (lines naming `enforce-epic-merge-gate-command.ps1`; the planner read 0).
- [ ] [P1-T2] Record every definition of the helper and reader functions into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/helper-definitions.<timestamp>.md`.
  Command: `git grep -n -e "function Get-EpicMergeGateSelectorPrNumber" -e "function ConvertFrom-EpicMergeGateSelector" -e "function Test-EpicMergeGateCommandInScope" -e "function Get-CodexMergeCommandPrNumber" -- .claude .codex extensions tests scripts`
  Acceptance: `EXIT_CODE: 0`; the output, read as a set of lines, has exactly 14 lines: for each of the four helper copies (the two sources and the two bundle mirrors named in P0-T4), one line each at `:46`, `:110` and `:136`; and `.codex/hooks/enforce-epic-merge-gate.ps1:51` plus its mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1:51`. `Output Summary:` records `DEFINITION_LINES=14` and `TEST_TREE_DEFINITIONS=0` (no line under `tests/`). A different set is recorded verbatim and counts as a confirmed attribution finding for P1-T6.
- [ ] [P1-T3] Record the coverage configuration that governs attribution into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/coverage-attribution-config.<timestamp>.md`.
  Command: `git grep -n -e "UseBreakpoints" -- scripts/powershell/PoshQC config`; then Read `config/poshqc-coverage.json:1-10`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1:349-364` and `:397`.
  Acceptance: the search exits 1 with no output, recorded with `ExpectedExitCode: 1` (no `UseBreakpoints` key is set, so Pester's default coverage mode applies); `Output Summary:` records `COVERAGE_ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts`, `USE_BREAKPOINTS_SET=false`, `PESTER_INVOCATIONS=1` (one `Invoke-Pester` call at `PoshQC.Testing.psm1:397`, so every suite shares one coverage session), and `COVERAGE_OUTPUT_FORMAT=CoverageGutters`. No file is edited.
- [ ] [P1-T4] Map each uncovered Codex helper line to the Codex reader cases that reach it and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/uncovered-line-map.<timestamp>.md`.
  Reads: `.codex/hooks/enforce-epic-merge-gate-command.ps1:60-68` and `:153-183`; `.codex/hooks/enforce-epic-merge-gate.ps1:64-68`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:128-143`.
  Acceptance: a table lists each of lines 63, 64, 68, 160, 161, 166, 173, 176, 177, 178, 179, 180 and 183 with the C-4 rows (`:130` to `:135`) whose command reaches it through `Get-CodexMergeCommandPrNumber`, by tracing the code path. The planner's trace is: 63 and 64 from `:134`; 176 to 180 from `:135`; 68, 160, 161, 166, 173 and 183 from no row. `Output Summary:` records `DRIVEN_BUT_REPORTED_UNCOVERED=<lines>` and `NOT_DRIVEN_BY_C4=<lines>`; a trace that differs from the planner's is recorded with the reason and is not a stop condition.
- [ ] [P1-T5] Compare the hook-loading setup of the two MergeQueue suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/mergequeue-setup-compare.<timestamp>.md`.
  Reads: `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:29-34`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:32-38`.
  Acceptance: the artifact quotes both setup blocks verbatim and records `CLAUDE_MQ_HOOK_PATH=Resolve-Path` (`:30`) and `CODEX_MQ_HOOK_PATH=Join-Path-unresolved` (`:34`), or the observed forms when they differ.
- [ ] [P1-T6] Write the diagnosis record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-helper-coverage-diagnosis.<timestamp>.md`.
  Acceptance: the artifact carries `Timestamp:`, `Command:` (the P1-T1 to P1-T3 commands and the P1-T4 and P1-T5 reads), `EXIT_CODE: 0` and `Output Summary:` with: `STATIC_CAUSE=` decided by this rule: `CONFIRMED:child-process-load` when P1-T1 recorded `MQ_SUITE_LOAD=CHILD_PROCESS`; `CONFIRMED:test-tree-definition` when P1-T2 recorded a `TEST_TREE_DEFINITIONS` value above 0; otherwise `NOT-DETERMINED-STATICALLY`. It lists hypothesis H1 (unresolved hook path, addressed by P2-T3), hypothesis H2 (helper functions resolved from another copy, tested by the provenance case of P2-T2 in ORCH-R1 and ORCH-R2), and the not-driven lines from P1-T4 (addressed by P2-T1). It states that the scoped coverage run and the `ScriptBlock.File` observation of remediation-inputs R1 step 1 cannot run in this session (Conventions, executor capability boundary) and are replaced by the provenance case evaluated in CI; and it states that no coverage exclusion, threshold change, or edit to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` or `config/poshqc-coverage.json` is made.
- [ ] [P1-T7] Commit and push the Phase 1 evidence and the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "docs(952): record codex helper coverage diagnosis"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

### Phase 2 — Regression and Coverage Tests (CR-4 fails first)

- [ ] [P2-T1] Edit `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`: insert the 18 lines of Appendix R.2(a) immediately after `:142` (the closing `        }` of the C-4 `It 'resolves 5 for <Command>'` block) and before `:143` (the closing `    }` of the C-4 `Context`).
  Acceptance: `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` succeeds; `git grep -c -F -e "gh pr merge --merge=true 5" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count of 1; `git grep -c -F -e "gh pr merge feature-branch --merge" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count of 1.
- [ ] [P2-T2] Edit `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`: insert the 9 lines of Appendix R.2(b) immediately after `:65` (the `It 'baseline mock interception probe'` line).
  Acceptance: `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` succeeds; `git grep -c -F -e "resolves the selector helper functions from the Codex helper file" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count of 1.
- [ ] [P2-T3] Edit `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:34`: replace the line with the single line of Appendix R.2(c) (setup parity with `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:30`). No other line changes.
  Acceptance: `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` succeeds; `git grep -n -F -e "Resolve-Path -Path (Join-Path" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints exactly one line, numbered 34.
- [ ] [P2-T4] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`: insert the 14 lines of Appendix R.3 immediately after `:139` (the closing `        }` of the B-4 `It 'resolves 5 for <Command>'` block) and before `:140` (the closing `    }` of the B-4 `Context`).
  Acceptance: `git add tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` succeeds; `git grep -c -F -e "gh pr merge --merge=true 5" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` prints a count of 1; `git grep -c -F -e "gh pr merge feature-branch --merge" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` prints a count of 1.
- [ ] [P2-T5] Edit `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`: insert the 32 lines of Appendix R.4 immediately after `:120` (the closing `    }` of `It 'runs the script entry point when invoked directly'`) and before `:121` (the closing `}` of the `Describe`).
  Acceptance: `git add tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` succeeds; each of `git grep -c -F -e "maps MERGED with a null mergedAt to merged with an empty merge time"`, `git grep -c -F -e "throws the null-or-empty message for an empty snapshot"`, `git grep -c -F -e "renders a datetimeoffset merge time as UTC ISO-8601"` and `git grep -c -F -e "returns a non-date merge time value verbatim"`, each followed by `-- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`, prints a count of 1.
- [ ] [P2-T6] Record the line counts and the temporary-file scan of the three edited suites into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/line-counts-tests.<timestamp>.md`.
  Commands: `git grep -c -e "^" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`; `git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process|Start-Sleep|GetTempFileName|GetTempPath" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`.
  Acceptance: the count command exits 0 and prints three counts, each at or below 500 (planner projections: Codex suite 218, Claude suite 204, parser suite 153; the projections are recorded beside the observed values and are not asserted); the scan exits 1 with no output, recorded with `ExpectedExitCode: 1`.
- [ ] [P2-T7] [expect-fail] Run the Codex hook test folder before the helper change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-selector-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/codex-hooks"]` (key `t-codex-hooks`).
  Acceptance (P0-T8 `t-codex-hooks` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` naming `returns 5 for gh pr merge --merge=true 5` as failing pre-change (`.codex/hooks/enforce-epic-merge-gate-command.ps1:165-167` returns `ConvertFrom-EpicMergeGateSelector -Selector 'true'`, which is `$null` at `:68`), and the other six Appendix R.2(a) rows and the Appendix R.2(b) provenance case as passing pre-change (their code paths are unchanged by Phase 3). A returned call fails the task and halts execution. Acceptance (P0-T8 `t-codex-hooks` RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.codex-selector.<timestamp>.md` with `WhyFailingRunImpossible:` (the folder baseline is RED and MCP results name no row) and the same `RowAttribution:`. CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P2-T8] [expect-fail] Run the Claude hook test folder before the helper change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-selector-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks"]` (key `t-claude-hooks`).
  Acceptance (P0-T8 `t-claude-hooks` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` naming `returns 5 for gh pr merge --merge=true 5` as failing pre-change (same reason, `.claude/hooks/enforce-epic-merge-gate-command.ps1:165-167` and `:68`) and the other three Appendix R.3 rows as passing pre-change. A returned call fails the task and halts execution. Acceptance (P0-T8 `t-claude-hooks` RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.claude-selector.<timestamp>.md` with `WhyFailingRunImpossible:` and the same `RowAttribution:`. CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P2-T9] Run the ci-gate test folder with the new characterization cases and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-cases-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]` (key `t-ci-gate`).
  Acceptance (P0-T8 `t-ci-gate` GREEN): the call returned. A raised call is recorded and halts execution for the caller; the executor does not change an Appendix R.4 expectation or the parser. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results come from ORCH-R1 (job `poshqc / PowerShell QC`).
- [ ] [P2-T10] Commit and push Phase 2 (`tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`); the deliberately failing CR-4 rows are committed and Phase 3 makes them pass. No CI runs on this push (`ci.yml` runs on `push` only for `main` and `development`, and no PR exists).
  Commands: `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "test(952): add codex helper coverage, selector, and parser cases"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- tests/scripts docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

### Phase 3 — Selector Reader Fix and Header Note (four helper copies)

- [ ] [P3-T1] Re-check `origin/main` for concurrent changes to the helper and gate files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/concurrency-recheck.<timestamp>.md`.
  Commands: `git fetch origin`; `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`.
  Acceptance: `EXIT_CODE: 0` for both; empty `git log` output records `CONCURRENT_CHANGES=0`. A non-empty output records the lines, fails the task, and halts execution for the caller before any helper edit.
- [ ] [P3-T2] Edit `.claude/hooks/enforce-epic-merge-gate-command.ps1:165-167`: replace the three lines with the four lines of Appendix R.1(a).
  Acceptance: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1` succeeds; `git grep -c -F -e "if ($null -ne $equalsNumber) { return $equalsNumber }" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 1; `git grep -n -F -e "return ConvertFrom-EpicMergeGateSelector -Selector $token.Substring" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` exits 1.
- [ ] [P3-T3] Edit `.claude/hooks/enforce-epic-merge-gate-command.ps1:142-143` (the `.DESCRIPTION` of `Get-EpicMergeGateSelectorPrNumber`): replace the two lines with the three lines of Appendix R.1(b).
  Acceptance: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1` succeeds; `git grep -c -F -e "an equals-joined value that is not a number is skipped" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 1.
- [ ] [P3-T4] Edit `.claude/hooks/enforce-epic-merge-gate-command.ps1`: insert the four lines of Appendix R.1(c) immediately after `:14` (`    Get-CommandLineStructuralMatch, which the gate loads from hook-command-invocation.ps1 first.`) and before `:15` (`#>`).
  Acceptance: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1` succeeds; `git grep -c -F -e "is not visible to this text-based scope" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 1; `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 190 (184 + 1 + 1 + 4).
- [ ] [P3-T5] Write `.codex/hooks/enforce-epic-merge-gate-command.ps1` with the Write tool, using the exact text of `.claude/hooks/enforce-epic-merge-gate-command.ps1` as read with the Read tool, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-helper.<timestamp>.md`.
  Commands: `git add .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`.
  Acceptance: the hash command prints two identical hashes, each different from `d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd`; the artifact records both and `Output Summary: PAIR_EQUAL=true helper-claude-codex`. Unequal hashes: rewrite the file and repeat the task.
- [ ] [P3-T6] Copy both helper sources to their bundle mirrors by the mirror mechanism and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-helper-bundles.<timestamp>.md`.
  Commands: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/hooks/enforce-epic-merge-gate-command.ps1`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1`.
  Acceptance: `EXIT_CODE: 0` for each command; the four hashes are equal to each other and differ from `d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd`; the artifact records `Output Summary: HELPER_COPIES_EQUAL=4/4 HELPER_HASH=<hash>`.
- [ ] [P3-T7] Run the Codex hook test folder after the helper change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-selector-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/codex-hooks"]`.
  Acceptance (P0 GREEN): the call returned (this folder includes the mirror byte-identity rows of `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`). A raised call is recorded with its error text, fails the task, and halts execution for the caller: the helper edit is fully specified by Appendix R.1 and an MCP result names no failing row, so the executor neither changes the helper beyond Appendix R.1 nor changes an Appendix R expectation. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`.
- [ ] [P3-T8] Run the Claude hook test folder after the helper change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-selector-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks"]`.
  Acceptance (P0 GREEN): the call returned. A raised call is handled as in P3-T7. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`.
- [ ] [P3-T9] Run the Claude runtime test folder and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-runtime-after-selector.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-runtime"]`.
  Acceptance (P0 GREEN): the call returned (the folder reads the bundle mirrors through `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`). A raised call is handled as in P3-T7. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`.
- [ ] [P3-T10] Run the push-down resource and manifest tests and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pushdown-after-selector.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error`.
- [ ] [P3-T11] Commit and push Phase 3: `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, and their two bundle mirrors.
  Commands: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "fix(952): keep scanning after a non-numeric --merge value"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- .claude/hooks .codex/hooks extensions/drm-copilot/resources docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

### Phase 4 — Follow-up and Scope Records (CR-5, CR-7, CR-8)

- [ ] [P4-T1] Edit `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`: insert the single line of Appendix R.5 immediately after `:336` (`  - Follow-up: evaluate gating `gh` invocations issued through the Claude PowerShell tool.`) and before `:337` (`- Links: ...`).
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`; `git grep -c -F -e "is not visible to the text-based gh api scope" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`; `git diff -U0 --cached HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: the count is 1; the staged diff shows exactly one added line (the Appendix R.5 line) and no removed line, so no acceptance-criterion line changed.
- [ ] [P4-T2] Write the scope-deviation record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/scope-deviation-d10.<timestamp>.md`.
  Command: `git diff --stat 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea HEAD -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  Acceptance: `EXIT_CODE: 0`; the stat output recorded verbatim and lists both paths; the artifact quotes `FEATURE/spec.md:71` and `FEATURE/spec.md:334` verbatim (the out-of-scope statement and the follow-up line for the cleanup skill); it records that coordinator decision D10(a) delivered the cleanup-skill edit in-item, citing `FEATURE/plan.2026-10-16T00-15.md:83` (`## Scope Recap` item 7) and `:96` (Decisions, "Cleanup skill queue-aware wording (coordinator D10(a))"), and the evidence `FEATURE/evidence/regression-testing/procedure-pins-before.2026-10-16T11-26.md` and `FEATURE/evidence/regression-testing/procedure-pins-after.2026-10-16T11-33.md`; it states that no acceptance criterion is added or edited and that the PR body references this record; `Output Summary:` records `SCOPE_DEVIATION=D10(a) DELIVERED_IN_ITEM=true SPEC_AC_EDITED=false`.
- [ ] [P4-T3] Edit `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md:23`: replace the line with the single line of Appendix R.6.
  Acceptance: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` succeeds; `git grep -c -F -e "The capture file is not committed." -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` prints a count of 1; `git grep -n -F -e "15241672 > protect-main.live.json" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` exits 1.
- [ ] [P4-T4] Re-run the AC-24 runbook section check and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/runbook-sections.<timestamp>.md`.
  Command: `git grep -n -F -e "## Preconditions" -e "## Capture and Diff Before Applying" -e "## Apply" -e "## Post-Apply Verification" -e "## Expected Failure on a User-Owned Repository" -e "## Rollback" -e "## Non-Strict Alternative (Separate Operator Decision)" -e "## Admin Merges Skip the Queue" -e "gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input" -e "422" -e "gh pr update-branch" -e "This item applies nothing" -e "merge queues for organization-owned repositories" -e "is expected to be rejected" -e "is a separate operator decision" -e "--input protect-main.rollback.json" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`
  Acceptance: `EXIT_CODE: 0`; the output recorded verbatim; a pattern-to-line table shows each of the 16 patterns matched by at least one output line; `Output Summary: TOKENS_FOUND=16/16` (the same check as the main plan's P7-T5, recorded in `FEATURE/evidence/qa-gates/runbook-sections.2026-10-16T11-35.md`). Fewer than 16 fails the task and halts execution; AC-24 stays checked only with this result.
- [ ] [P4-T5] Commit and push Phase 4: `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`, `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`, and the Phase 4 evidence.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "docs(952): record gh api file-input follow-up, scope deviation, and runbook capture path"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

### Phase 5 — Final QA Loop

P5-T1 through P5-T4 run under the Restart Rule. Every command is unconditional; no task may record `EXIT_CODE: SKIPPED`. Type checking does not apply to PowerShell; Black, Ruff and Pyright have no touched Python input (P0-T11), so the Python leg of the loop is the `PY-CONTRACT` regression gate.

- [ ] [P5-T1] Run the PowerShell formatter over R-FSET and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-ps-format.<timestamp>.md`.
  Commands: `git status --porcelain -- .claude/hooks .codex/hooks tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-lib/ci-gate` (before; expected empty after the Phase 4 commit); `mcp__drm-copilot__run_poshqc_format` with the five R-FSET folders; the same `git status --porcelain` command (after).
  Acceptance: the call returned and the after-output is empty (the formatter changed nothing). A non-empty after-output is classified path by path: a path listed under `PRE-EXISTING-FORMAT-DRIFT` by P0-T6 and absent from `## Files Written` is restored with `git restore -- <path>` and recorded; a path in `## Files Written` keeps the formatter output (for the Claude helper, P3-T5 and P3-T6 are repeated), the files are committed, and the loop restarts at P5-T1; any other path fails the task and halts execution.
- [ ] [P5-T2] Run the analyzer over each R-FSET folder (five calls) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-ps-analyze-<key>.<timestamp>.md` per key.
  Command (five calls): `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = the single folder of the key.
  Acceptance: every key whose P0-T7 baseline is `GREEN` returned. A `RED` key is recorded `LOCAL-NONDISCRIMINATING (baseline RED)`; the Analyze step of job `poshqc / PowerShell QC` in `R_final_2` (ORCH-R1) is its gate. A raised call on a `GREEN` key fails the task: fix the finding without adding a suppression attribute and restart the loop.
- [ ] [P5-T3] Run the tests of each R-TSET folder (four calls) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-ps-test-<key>.<timestamp>.md` per key.
  Command (four calls): `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = the single folder of the key.
  Acceptance: every key whose P0-T8 baseline is `GREEN` returned. A `RED` key is recorded `LOCAL-NONDISCRIMINATING (baseline RED)`. Each artifact states that post-change coverage and per-suite Passed counts are recorded by ORCH-R1 to ORCH-R3. A raised call on a `GREEN` key is recorded with its error text, fails the task, and halts execution for the caller (an MCP result names no failing row; no Appendix R text is changed).
- [ ] [P5-T4] Run the Python contract suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-python-contract-suites.<timestamp>.md`.
  Command: the `PY-CONTRACT` command of P0-T10.
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error`. A failure is recorded with its node IDs and halts execution for the caller.
- [ ] [P5-T5] Write the loop record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-loop-status.<timestamp>.md`.
  Acceptance: the artifact lists each loop pass with the artifact file names of P5-T1 to P5-T4 and their dispositions or exit codes; the last listed pass has an empty P5-T1 after-output, every `GREEN`-baseline call of P5-T2 and P5-T3 returned, and P5-T4 recorded `EXIT_CODE: 0`.
- [ ] [P5-T6] Verify the final helper hashes and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-helper-hashes.<timestamp>.md`.
  Command: the `git hash-object` command of P0-T4 (same four paths, same order).
  Acceptance: `EXIT_CODE: 0`; four equal hashes, each equal to the P3-T6 `HELPER_HASH` (or to the hash of the latest P3-T6 repeat) and different from `d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd`; `Output Summary: HELPER_COPIES_EQUAL=4/4`.
- [ ] [P5-T7] Verify the line counts of every touched production and test file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-line-counts.<timestamp>.md`.
  Command: `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`
  Acceptance: `EXIT_CODE: 0`; seven `<path>:<count>` lines recorded; every count is at or below 500 (AC-26 stays satisfied); the four helper counts are equal.
- [ ] [P5-T8] Verify that no edited test creates a temporary file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-temp-file-scan.<timestamp>.md`.
  Command: `git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|Start-Process" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`
  Acceptance: `EXIT_CODE: 1` with no output, recorded with `ExpectedExitCode: 1`.
- [ ] [P5-T9] Write the coverage status `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-coverage-status.<timestamp>.md`.
  Acceptance: the artifact records `PYTHON: NOT-APPLICABLE` with the P0-T11 reason; the P0-T9 baseline values (`CODEX_HELPER_LINE=75.47`, `CLAUDE_HELPER_LINE=94.34`, `PARSER_LINE=91.67`, R_final 38899600487); and `POWERSHELL: PENDING-ORCH (ORCH-R3; D-COV and D-CHANGED on R_final_2, job poshqc / PowerShell QC)`. It records no PowerShell `PASS` verdict.
- [ ] [P5-T10] Verify the changed-path set of this cycle and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/rem-final-scope-boundary.<timestamp>.md`.
  Commands: `git diff --name-only <REM_BASE_SHA> HEAD` (`REM_BASE_SHA` from P0-T2); `git status --porcelain`; `git diff -U0 <REM_BASE_SHA> HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`.
  Acceptance: the union of the name-only paths and the porcelain paths, excluding paths under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/`, equals exactly the 7 modified paths of `## Files Written` plus `FEATURE/spec.md`, `FEATURE/ruleset/runbook.md` and `FEATURE/remediation-plan.2026-10-16T12-51.md` (`OUTSIDE_PATHS=7`, `FEATURE_NON_EVIDENCE_PATHS=3`); in particular `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `config/poshqc-coverage.json`, `.github/workflows/_poshqc.yml`, every path under `.claude/rules/` and `.github/instructions/`, and every `.py` path are absent (`PY_PATHS=0`, `FROZEN_EPIC_SURFACES_CHANGED=0`); every removed line of the plan diff begins with `- [ ] [P` and its paired added line is identical except `[ ]` became `[x]` (`PLAN_NONCHECKBOX_CHANGES=0`). Any other path fails the task; the executor records it with `git log --oneline <REM_BASE_SHA>..HEAD -- <path>` and halts for the caller rather than reverting it.
- [ ] [P5-T11] Write the remediation status record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/remediation-status.<timestamp>.md`.
  Acceptance: the artifact maps each finding to its evidence and status: R1 to `codex-helper-coverage-diagnosis.*.md`, `codex-selector-before.*.md`, `codex-selector-after.*.md` with `PENDING-ORCH (ORCH-R1, ORCH-R3)`; CR-2 and CR-4 to `claude-selector-before.*.md`, `claude-selector-after.*.md`, `codex-selector-before.*.md`, `codex-selector-after.*.md`, `rem-final-helper-hashes.*.md` with `LOCAL-PASS, CI rows PENDING-ORCH`; CR-3 to `parser-cases-after.*.md` with `LOCAL-PASS, CI rows PENDING-ORCH`; CR-5 to the P3-T4 and P4-T1 token counts with `LOCAL-PASS`; CR-7 to `scope-deviation-d10.*.md` with `LOCAL-PASS`; CR-8 to the P4-T3 token checks and `runbook-sections.*.md` (`TOKENS_FOUND=16/16`) with `LOCAL-PASS`; CR-6 and CR-9 with `ORCH-OWNED (ORCH-R3)`; R2 with `PENDING-CI (main plan ORCH-3 and ORCH-7 at S9)`. It names the next step (ORCH-R1 to ORCH-R4) and states that no acceptance criterion was checked off by the executor.
- [ ] [P5-T12] Commit and push the Phase 5 evidence, any Phase 5 restart repair, and the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`.
  Commands: `git add` of each path in `## Files Written` that the Phase 5 loop changed, then `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md`; `git commit -m "docs(952): record remediation cycle 1 final QA evidence"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.

## Orchestrator-Owned Verification

This section is not a phase and its items are not tasks: each is a plain `[ORCH-Rn]` bullet with no checkbox, so the executor stop hook (`.claude/hooks/validate-executor-output.ps1:258-285`, unchecked-task pattern at `:259`) never counts it, and the executor neither performs nor checks off any item. Derivations D-FINAL, D-JUNIT, D-COV and D-CHANGED are those of the main plan (`FEATURE/plan.2026-10-16T00-15.md`, `## Fixed Derivations`), with `R_final_2` in place of `R_final`. Each item writes its artifact under `FEATURE/evidence/<kind>/` and commits and pushes it with `git add` of the named artifacts (plus `FEATURE/spec.md` when it checks off an AC), `git commit`, `git push origin bug/ci-merge-queue-for-main-952`. Never force-push. Any FAIL routes to remediation; it is not a pass.

- [ORCH-R0] Before delegating execution, after the approved plan (still carrying the directive) has been committed and pushed in its own commit: delete from `REM_PLAN` the line that consists only of the preflight directive (line 3 at approval), the paragraph that follows it (line 5 at approval, beginning "The directive line above serves preflight rounds only"), and the blank line after each, leaving one blank line between the title and the metadata list. No other line changes. Commit and push with `git commit -m "docs(952): remove the remediation preflight directive before execution"`. Acceptance: `git grep -c -e "^DIRECTIVE: PREFLIGHT VALIDATION ONLY$" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md` exits 1 with no output; `git diff -U0 HEAD~1 HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md` shows four removed lines and no added line.
- [ORCH-R1] Windows per-suite results on a new dispatch (repeat of ORCH-4), after the executor's P5-T12 push and before re-audit: `git fetch origin`; record `H_final_2` = `git rev-parse origin/bug/ci-merge-queue-for-main-952`; `gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952`; select `R_final_2` by D-FINAL (the `gh run list` poll of the main plan, at most 20 attempts 15 seconds apart); `gh run watch <R_final_2> --exit-status`; `gh run view <R_final_2> --json jobs,headSha,conclusion,event`; `gh run download <R_final_2> -n poshqc-test-results -D SCRATCH/issue-952-ci-<R_final_2>/win`; write `FEATURE/evidence/qa-gates/ci-rows-windows.<timestamp>.md`. Acceptance: `event` is `workflow_dispatch`, `headSha` equals `H_final_2`, the run concludes `success`, and jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` conclude `success`; every listed suite has zero testcases with a `failure` or `error` child; Passed counts (job `poshqc / PowerShell QC`, Windows file) equal: `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` = 40 (36 + 4); `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` = 42 (34 + 1 + 7); `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` = 17 (13 + 4); and, unchanged from `FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T12-40.md`: `tests/scripts/workflows/CiWorkflow.Tests.ps1` = 4, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` = 57, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` = 16, `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` = 37, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1` = 2, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` = 20, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` = 13, `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` = 11, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` = 29, `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` = 14, `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` = 8, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` = 17, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` = 23, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` = 22, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` = 11, `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` = 2, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` = 35, `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` = 2, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` = 12; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` each have at least one testcase and none failing. If the orchestrator merged `origin/main` after R_final 38899600487, the main plan's ORCH-1 is re-run first and the unchanged suites' expected values come from the new `ci-baseline.*.md`. Named rows pass, each evaluated only within its paired suite: rows (a) to (f) of the main plan's ORCH-4; (g) `resolves the selector helper functions from the Codex helper file` in `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (the H2 provenance check); (h) `returns 5 for gh pr merge --merge=true 5`, evaluated separately in `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` and in `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (CR-4); (i) `maps MERGED with a null mergedAt to merged with an empty merge time` in `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` (CR-3). Zero matches for a named row in its paired suite is a FAIL.
- [ORCH-R2] Linux per-suite results (repeat of ORCH-5), after ORCH-R1: `gh run download <R_final_2> -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-<R_final_2>/linux`; by D-JUNIT on the Linux file (job `poshqc / PowerShell hook suites (Linux)`, no coverage) write `FEATURE/evidence/qa-gates/ci-rows-linux.<timestamp>.md`. Acceptance: every claude-hooks and codex-hooks suite listed in ORCH-R1 has zero failing or erroring testcases and the Passed count stated there (`enforce-epic-merge-gate.MergeQueue.Tests.ps1` = 40, `enforce-epic-merge-gate-merge-queue.Tests.ps1` = 42, the others as in `FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T12-40.md`); rows (g) and (h) pass in their paired suites. This item makes no coverage claim.
- [ORCH-R3] Coverage comparison (repeat of ORCH-6, AC-27), after ORCH-R2: by D-COV and D-CHANGED on `R_final_2` (job `poshqc / PowerShell QC`; `B` = the `B=` value of the lexicographically greatest `FEATURE/evidence/baseline/ci-baseline.*.md`), write `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md` for the seven production files of the main plan's ORCH-6, plus: (CR-9) `REPO_PS_LINE=<percent>` with its covered and missed counts, computed as `100 * covered / (covered + missed)` from the `counter` element with `type="LINE"` that is a direct child of the root `report` element of `powershell-coverage.xml`, rounded to two decimals; (CR-6) a `CauseStatement:` for the earlier Codex helper gap that cites the lexicographically greatest `FEATURE/evidence/regression-testing/codex-helper-coverage-diagnosis.*.md` and the ORCH-R1 result of row (g), states that the Codex merge-queue suite already drove helper lines 63-64 and 176-180 through its URL and REST reader rows before this cycle (so the earlier statement that the Codex suites did not drive the URL selector or the REST reader path is withdrawn), and states that lines 68, 160, 161, 166, 173 and 183 were driven by no Codex reader case before this cycle; and `PYTHON: NOT-APPLICABLE` with the P0-T11 reason. Acceptance: verdict `POWERSHELL: PASS` only when `.codex/hooks/enforce-epic-merge-gate-command.ps1` and every other new file has post value and changed-line percent of at least 85.00, every modified file meets the main plan's ORCH-6 rule, and `REPO_PS_LINE` is numeric; otherwise `POWERSHELL: FAIL` and the item routes to a further remediation cycle (with row (g) PASS and the Codex helper below 85.00, the cycle-2 input states that attribution is not explained by function resolution). When ORCH-R1, ORCH-R2 and ORCH-R3 all pass, change the AC box to checked in `FEATURE/spec.md` for AC-1, AC-2, AC-5 to AC-15 and AC-27, confirm `git grep -c -F -e "- [x] AC-27:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` (and likewise each of the other thirteen) prints a count of 1, and commit and push the ORCH-R1 to ORCH-R3 artifacts with `FEATURE/spec.md`. That commit changes only `FEATURE/` paths, so `R_final_2` stays valid.
- [ORCH-R4] Re-audit: after ORCH-R3 passes, run the feature-review workflow (policy-audit, code-review, feature-audit) on the branch head. The ruleset payload files are unchanged by this cycle, so the main plan's ORCH-2 is not repeated. Exit gate: zero autonomous blocking findings; AC-28 remains pending CI until S9 (main plan ORCH-3 and ORCH-7, which also re-check that no non-feature-folder path changed after `R_final_2`).

## Appendix R — Edit texts

All edit texts below are exact. Indentation is spaces. A line shown as `(empty line)` is a line with no characters.

### R.1 — `.claude/hooks/enforce-epic-merge-gate-command.ps1` (CR-4, CR-5)

(a) Replace `:165-167`, which currently read:

```powershell
                if ($name -ceq '--merge' -and $token.Length -gt $name.Length) {
                    return ConvertFrom-EpicMergeGateSelector -Selector $token.Substring($name.Length + 1)
                }
```

with these four lines:

```powershell
                if ($name -ceq '--merge' -and $token.Length -gt $name.Length) {
                    $equalsNumber = ConvertFrom-EpicMergeGateSelector -Selector $token.Substring($name.Length + 1)
                    if ($null -ne $equalsNumber) { return $equalsNumber }
                }
```

The literal `if ($null -ne $equalsNumber) { return $equalsNumber }` is created by this edit.

(b) Replace `:142-143`, which currently read:

```text
        their values, other flags are skipped, an equals-joined --merge=<digits> yields its
        digits, and the first non-flag token (or the token after a bare '--') is the selector.
```

with these three lines:

```text
        their values, other flags are skipped, an equals-joined --merge=<digits> yields its
        digits (an equals-joined value that is not a number is skipped like any other flag),
        and the first non-flag token (or the token after a bare '--') is the selector.
```

The phrase "an equals-joined value that is not a number is skipped" is created by this edit.

(c) Insert after `:14` these four lines (the first is an empty line):

```text
(empty line)
    Known limitation (issue #952 code review CR-5): the gh api scope reads the command text
    only. A GraphQL mutation supplied from a file (gh api graphql -F query=@mutation.graphql,
    or gh api --input payload.json) is not visible to this text-based scope and is not gated.
```

The phrase "is not visible to this text-based scope" is created by this edit.

### R.2 — `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (R1, CR-4)

(a) Insert after `:142` these 18 lines (the first is an empty line):

```powershell
(empty line)
        It 'returns <Label> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge -- 5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge --'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge=5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge feature-branch --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh api graphql -f query=''mutation { mergePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }'''; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge=true 5'; Expected = 5; Label = '5' }
        ) {
            # Act: the reader is a pure string function and reads nothing from disk.
            $prNumber = Get-CodexMergeCommandPrNumber -Command $Command

            # Assert: a bare '--' passes the next token as the selector, a branch name or a
            # GraphQL node id carries no number, and a non-numeric --merge=<value> does not end
            # the scan (issue #952 R1 and CR-4).
            $prNumber | Should -Be $Expected -Because "the selector of $Command resolves to $Label"
        }
```

Pre-change outcome: the `gh pr merge --merge=true 5` row fails (the reader returns `$null`); the other six rows pass. Helper lines reached: 160 (`-- 5`), 161 (`--merge --`), 166 (`--merge=5`), 68 (`feature-branch`), 173 (`--merge`), 176 to 179 and 183 (the GraphQL row).

(b) Insert after `:65` these 9 lines (the first is an empty line):

```powershell
(empty line)
    It 'resolves the selector helper functions from the Codex helper file' {
        # Coverage is credited to the file that defines the executing function, so this suite
        # must run the Codex copy rather than its byte-identical Claude twin (issue #952 R1).
        foreach ($name in @('Get-EpicMergeGateSelectorPrNumber', 'ConvertFrom-EpicMergeGateSelector', 'Test-EpicMergeGateCommandInScope')) {
            $definitionFile = [string](Get-Command -Name $name -CommandType Function).ScriptBlock.File
            ($definitionFile -replace '\\', '/') | Should -BeLike '*/.codex/hooks/enforce-epic-merge-gate-command.ps1' -Because "$name must be defined by the Codex helper copy"
        }
    }
```

The test name "resolves the selector helper functions from the Codex helper file" is created by this edit.

(c) Replace `:34`, which currently reads:

```powershell
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
```

with:

```powershell
        $script:UnderTest = (Resolve-Path -Path (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1')).Path
```

The literal "Resolve-Path -Path (Join-Path" is created by this edit.

Suite total after R.2: 42 cases (34 + 1 + 7).

### R.3 — `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (CR-2, CR-4)

Insert after `:139` these 14 lines (the first is an empty line):

```powershell
(empty line)
        It 'returns <Label> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge -- 5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge --'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge feature-branch --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge=true 5'; Expected = 5; Label = '5' }
        ) {
            # Act: the reader is a pure string function and reads nothing from disk.
            $prNumber = Get-EpicMergeGateCommandPrNumber -CommandText $Command

            # Assert: a bare '--' passes the next token as the selector, a branch name carries no
            # number, and a non-numeric --merge=<value> does not end the scan (issue #952 CR-2, CR-4).
            $prNumber | Should -Be $Expected -Because "the selector of $Command resolves to $Label"
        }
```

Pre-change outcome: the `gh pr merge --merge=true 5` row fails; the other three pass. Helper lines reached: 160, 161, 68. Suite total after R.3: 40 cases (36 + 4).

### R.4 — `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` (CR-3)

Insert after `:120` these 32 lines (each block starts with an empty line):

```powershell
(empty line)
    It 'maps MERGED with a null mergedAt to merged with an empty merge time' {
        # Arrange: gh can report a merged pull request whose mergedAt is null.
        $json = '{"state":"MERGED","mergedAt":null,"mergeCommit":{"oid":"abc123"}}'

        # Act
        $result = Invoke-MergeConfirmationParser -PrJson $json

        # Assert: the null merge time is rendered as an empty string, not an error.
        $result.Status | Should -BeExactly 'merged'
        $result.MergedAt | Should -BeExactly '' -Because 'a null mergedAt is handled (AC-12)'
    }
(empty line)
    It 'throws the null-or-empty message for an empty snapshot' {
        { Invoke-MergeConfirmationParser -PrJson '' } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser: the pull-request snapshot is null or empty.'
    }
(empty line)
    It 'renders a datetimeoffset merge time as UTC ISO-8601' {
        # Arrange: a +02:00 value. ConvertFrom-Json does not produce this type, so the branch is
        # exercised through the function directly.
        $value = [datetimeoffset]::new(2026, 10, 16, 14, 34, 56, [timespan]::FromHours(2))

        $text = ConvertTo-MergeConfirmationTimeText -Value $value

        $text | Should -BeExactly '2026-10-16T12:34:56Z'
    }
(empty line)
    It 'returns a non-date merge time value verbatim' {
        $text = ConvertTo-MergeConfirmationTimeText -Value 'not-a-date'

        $text | Should -BeExactly 'not-a-date'
    }
```

Parser lines reached: 98 (null mergedAt), 128 (empty input), 101 (`[datetimeoffset]`), 108 (non-date string). All four cases pass against the unchanged parser. Suite total after R.4: 17 cases (13 + 4). The test names "maps MERGED with a null mergedAt to merged with an empty merge time", "throws the null-or-empty message for an empty snapshot", "renders a datetimeoffset merge time as UTC ISO-8601" and "returns a non-date merge time value verbatim" are created by this edit.

### R.5 — `FEATURE/spec.md` (CR-5)

Insert after `:336` this single line:

```markdown
  - Follow-up: the merge gate's `gh api` scope reads command text only, so a GraphQL mutation supplied from a file (`gh api graphql -F query=@mutation.graphql` or `gh api --input payload.json`) is not visible to the text-based gh api scope and is not gated; evaluate fail-closed handling for an `@file` query or `--input` (issue #952 code review CR-5).
```

The phrase "is not visible to the text-based gh api scope" is created by this edit.

### R.6 — `FEATURE/ruleset/runbook.md` (CR-8)

Replace `:23`, which currently reads:

```markdown
1. Capture the live ruleset: `gh api repos/drmoisan/drm-copilot/rulesets/15241672 > protect-main.live.json`.
```

with:

```markdown
1. Capture the live ruleset to a scratch directory outside the repository: `gh api repos/drmoisan/drm-copilot/rulesets/15241672 > <scratch-dir>/protect-main.live.json`, where `<scratch-dir>` is any directory outside the working tree. The capture file is not committed.
```

The sentence "The capture file is not committed." is created by this edit.
