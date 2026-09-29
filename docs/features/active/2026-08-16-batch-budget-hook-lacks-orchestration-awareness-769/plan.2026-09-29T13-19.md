# batch-budget-hook-lacks-orchestration-awareness (Plan)

- **Issue:** #769
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-30
- **Status:** Draft (pending validator and executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the acceptance-criteria source, AC-1 through AC-23; no `user-story.md`)
- **Branch:** `bug/batch-budget-hook-lacks-orchestration-awareness-769`
- **Research:** `research/2026-09-29T13-35-batch-budget-routing-research.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Recap

The approved spec and the research artifact define the change:

1. Make both batch-budget hooks (`.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`) large-path aware by reading `<Root>/artifacts/orchestration/orchestrator-state.json` through an injectable `ReadCheckpoint` seam. On a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, no PowerShell path is denied for count and no state is written. Otherwise (direct mode) only distinct production paths are counted and the 4th is denied with the `POWERSHELL_LARGE_PATH_REQUIRED` routing message.
2. Remove the test-file cap, the `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` environment override, and the persisted `prodCap`/`testCap` override; legacy state keys load and are ignored.
3. Mirror both hooks byte-identically into the extension bundle.
4. Remove per-batch text from every PowerShell surface in every runtime; reconcile the Claude and Copilot threshold text to `1-3` / more than 3; name `/orchestrate` on Claude surfaces; regenerate the Codex agent variants with `scripts/dev_tools/generate_codex_agent_variants.py`; mirror every changed text file.
5. Record three follow-up potential entries under `docs/features/potential/`.

Out of scope (spec, Out of scope / Explicitly excluded): Python and C# budget hooks and text; the Codex topology resolver budget of 2 and the Codex/`.agents` threshold text that documents it; `.github/copilot-instructions.md` and `.github/instructions/*`; `.github/agents/Powershell DI Unit Test Engineer.agent.md`; `.codex/agents/orchestrator*.toml`; `local_execution_overrides` validators; pull-request authoring.

### Current-tree facts this plan relies on (verified 2026-09-29 by reading the files)

- `.claude/hooks/enforce-powershell-batch-budget.ps1` is 457 lines. Deny message at line 296; env override block lines 426-433; persisted cap overlay lines 214-215; `Invoke-PowerShellBatchBudgetHook` lines 309-388; extension filter lines 347-350; entry point lines 390-442; top-level wiring lines 444-457.
- `.codex/hooks/enforce-powershell-batch-budget.ps1` is 256 lines. Deny message line 139; persisted cap overlay lines 77-78; hook function lines 152-217; top-level wiring lines 219-256 (reads `[Console]::In.ReadToEnd()` at line 226).
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` is 495 lines with 36 `It` blocks. Cases bound to removed behavior: lines 63-72 (test slot recorded), 85-96 (old message), 98-107 (test-cap deny), 131-147 (line 146 asserts a loaded `testFiles` entry), 484-493 (sets the removed environment variables).
- `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` runs 24 `It` blocks per language through a two-row `-ForEach` (lines 69-88), 48 tests in total. PowerShell-incompatible cases after the fix: lines 103-110, 112-121, 123-130, 167-176, 178-185, 187-195, 267-281.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 234 calls `Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1` on the Codex hook and line 236 passes `-StateFile`; line 126 requires the literal `[Console]::In.ReadToEnd()` in every Codex hook; lines 96-120 enforce the 500-line cap and root/bundle byte identity; lines 130-135 forbid `$env:CLAUDE_` in Codex hooks. This suite is not modified, so both signatures stay callable.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 31 lists the Claude hook, line 136 the Codex hook; the bundled copy `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` carries the same lines.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json` line 8 lists the Claude hook.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1` treats Error, Warning, and Information as failures, so an unused parameter (PSReviewUnusedParameter) fails analysis.
- `scripts/dev_tools/generate_codex_agent_variants.py` accepts `--check`; without it, it rewrites the base alias and the five variants in both the repository and the bundle (lines 221-268).
- `artifacts/orchestration/orchestrator-state.json` carries `"route_id": "large"` and `"path_selected": "large"` (lines 7-8), `"issue-num": 769`, and `"next_step": "S4_atomic_planning"`.

### Plan decisions (resolutions of spec latitude, recorded for review)

- **D1 — Route helpers move to a sibling file.** The spec directs a dot-sourced sibling `.claude/hooks/enforce-powershell-batch-budget-route.ps1` if the Claude hook would exceed 500 lines. Estimate: 457 current lines, about 25 removed (test-cap branches, persisted overlay, env block), about 75 added for the three route functions with comment-based help, about 35 added for the seam, early return, decision switch, and message, and about 8 net added to the docstring: about 550 lines. The plan therefore takes the sibling path. Bootstrap ordering is kept: the first production PowerShell write is a single complete `Write` of the Claude hook with the route functions inline (P2-T1); the sibling is created afterwards (P2-T3) and the hook is then edited to dot-source it (P2-T4). Every write after P2-T1 is evaluated by the corrected hook. The sibling is added to `pack-manifests/powershell.json`, the bundle, and both `pester.runsettings.psd1` copies.
- **D2 — Additional pure helpers.** Besides the spec's `Test-PowerShellBatchBudgetLargePathRoute -CheckpointText`, each hook defines `ConvertFrom-PowerShellBatchBudgetCheckpoint -CheckpointText` (parse; `$null` on any failure or non-object) and `Get-PowerShellBatchBudgetSelectedRoute -CheckpointText` (route precedence; `''` when unusable). The second supplies the "Checkpoint route observed" clause of the deny message.
- **D3 — Threshold parameter placement.** The threshold stays state-based, as in the current code: `-ProdCap` on `Get-PowerShellBatchBudgetState` and `Invoke-PowerShellBatchBudgetHook` (default 3) sets `state.prodCap`, and the decision reads `$State.prodCap`. `ConvertTo-PowerShellBatchBudgetState` never copies a persisted `prodCap`. `Get-PowerShellBatchBudgetState` and `ConvertTo-PowerShellBatchBudgetState` keep an optional, ignored `-TestCap` parameter so `legacy-codex-hook-contracts.Tests.ps1:234` and the existing Claude suite still bind; each carries `[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'TestCap', Justification = 'Accepted and ignored for callers written against the removed test-file cap.')]` (precedent: `scripts/powershell/Publish-DrmCopilotExtension.ps1:50`). `Invoke-PowerShellBatchBudgetHook` loses its `-TestCap` parameter.
- **D4 — `-StateFile` on the decision function** becomes optional (`[AllowEmptyString()][string] $StateFile = ''`) and is used only in a `Write-Verbose` diagnostic on the deny branch; it no longer appears in the deny reason.
- **D5 — Codex entry function.** The Codex top-level wiring is extracted into `Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw -RepositoryRoot [-HookSeams <hashtable>]`, which returns an `[int]` exit code (0 or 2) after writing any deny JSON to the output stream. `HookSeams` is splatted into `Invoke-PowerShellBatchBudgetHook`, so the `ReadCheckpoint` seam is reachable from the entry point. The top-level wiring keeps the literal `[Console]::In.ReadToEnd()`.
- **D6 — Existing Codex suite restructure.** The PowerShell row stays in the shared `-ForEach` for the language-neutral cases and gains an `ExtraSeams` entry that injects an empty checkpoint; the seven cap-specific cases move into a Python-only `Context`. The PowerShell replacements for those seven cases live in the new Codex routing suite.
- **D7 — Three follow-up entries.** The caller asked for three potential entries (Python hook, C# text, Codex resolver budget). They cover the spec's two follow-ups: Follow-up 1 is split into the Python and C# entries.

### Operator-directed policy change

Repository policy prohibits edits to rule files. This plan edits `.claude/rules/powershell.md` and its bundle mirror only because the approved spec (In scope items 4, 5, and 6) directs it. No file under `.github/instructions/` and neither `.github/copilot-instructions.md` is written (AC-19, verified by P11-T1).

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`.
- BRANCH means `bug/batch-budget-hook-lacks-orchestration-awareness-769`.
- CB means `extensions/drm-copilot/resources/claude-customizations`; XB means `extensions/drm-copilot/resources/codex-and-agents-customizations`; GB means `extensions/drm-copilot/resources/customizations`.
- CHOOK means `.claude/hooks/enforce-powershell-batch-budget.ps1`; CROUTE means `.claude/hooks/enforce-powershell-batch-budget-route.ps1`; XHOOK means `.codex/hooks/enforce-powershell-batch-budget.ps1`.
- CTEST means `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`; CRTEST means `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`; XTEST means `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`; XRTEST means `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`.
- CHECKPOINT means `artifacts/orchestration/orchestrator-state.json`.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA means the merge-base commit recorded by P0-T7.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. Test-step artifacts for PowerShell record numeric coverage values in `Output Summary:` where the task names coverage.
- KL-510 is the known local failure of issue #510 in node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: the batch-budget hooks write gitignored state under `.claude/state/`, which the node reports as missing from the bundle. A run of that node satisfies KL-510 in exactly two cases. Case (a): the node prints PASSED; the artifact carries `KL-510: PASSED`. Case (b): the node fails, its assertion message is the literal "Repo file missing from bundle:" followed by a path whose first two components are `.claude` and `state`, and no output line contains "Bundle content differs from repo for:"; the artifact carries `KL-510: STATE-ONLY` and quotes the assertion message. Any other outcome stops the task.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind one of `baseline`, `regression-testing`, `qa-gates`, or `other`. No artifact is written under `artifacts/`. Coverage XML written by the scratch Pester script goes to SCRATCH, not to the repository. No non-canonical path was supplied by the caller, so no override record is needed.

### Shell route

- The worktree isolation hook refuses Bash-tool command text containing the words bash, pwsh, or wsl, heredocs, compound commands, cd-chains, or xargs. Every git, poetry, and cp command in this plan is one plain command with literal arguments.
- Every PowerShell script runs through scratch script A1: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`. The command text never names pwsh.
- Scratch `.ps1` files are written under SCRATCH, which lies outside the worktree root; the Claude batch-budget hook discards out-of-root candidates without consuming a slot (CHOOK lines 277-282), so they do not affect the budget.
- Bundle mirrors are produced by `cp` from the edited primary file, never through Write or Edit, so they are byte-identical and are not evaluated by the `Write|Edit` hooks.
- **Stop rule for hook denials.** If any hook denies a Write, Edit, or command in this plan, stop and report the verbatim denial text. Do not delete any file under `.claude/state/`, do not set `CLAUDE_POWERSHELL_BUDGET_PROD` or `CLAUDE_POWERSHELL_BUDGET_TEST`, do not edit CHECKPOINT, and do not bypass the hook by any other route.
- Python scratch work is not needed; every Python command runs as `poetry run pytest ...` or `poetry run python scripts/dev_tools/generate_codex_agent_variants.py ...`.

### Bootstrap ordering (spec Dependencies)

The session runs this worktree's own CHOOK. The plan's PowerShell writes through the Write/Edit tools, in order, are: CRTEST (test, P1-T1), CHOOK (production, P2-T1; evaluated by the pre-fix hook), CROUTE (production, P2-T3), CHOOK again (P2-T4), CTEST (test, P2-T6), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (production, P3-T1), XRTEST (test, P4-T1), XHOOK (production, P5-T1), XTEST (test, P5-T2). Before P2-T1 only one test path and one production path are written, which the pre-fix cap (3 and 3) admits unless the session state already holds 3 test or 3 production paths; P0-T9 records that state read-only. From P2-T1 onward the corrected hook reads CHECKPOINT (`route_id: large`) and allows every PowerShell path without recording it. In this plan's own sequence the distinct production PowerShell paths written through Write or Edit are CHOOK (1st), CROUTE (2nd), the runsettings file (3rd), and XHOOK (4th). In direct mode the corrected hook would deny XHOOK, because the pre-fix hook recorded CHOOK and direct mode would have recorded CROUTE and the runsettings file; P5-T1 succeeding is therefore live evidence that the large path is not capped, and P2-T12 and P9-T11 show that nothing after P2-T1 was recorded. The orchestrator sets `lifecycle_ready: true` in CHECKPOINT before execution; this plan never writes CHECKPOINT and P0-T8 only reads it.

### Toolchain loop rule

Each implementation task on a PowerShell file is followed by the PoshQC MCP format and analyze calls and a targeted direct Pester run (the per-task loop). Phase 9 is the final PowerShell QA loop: format, analyze, test (the type-check stage does not apply to PowerShell per `.claude/rules/powershell.md`). If any Phase 9 step fails or changes a tracked file, fix the cause and restart Phase 9 from P9-T1. Phase 10 re-runs the Python parity suites; no Python source file is created or modified by this plan (verified by P10-T3), so black, ruff, pyright, and Python coverage gates do not apply.

### Commit rule

Each implementation phase ends with a commit-and-push task. CMD-GIT-COMMIT carries the commit attribution lines the executor's session requires, one `--trailer` argument per line, supplied by the executor from its session instructions. If a pre-implementation or orchestration hook denies staging, stop and report the denial text.

### Command catalogue

Angle-bracket fields are filled from the task text. Commands run from the worktree root.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-MAIN    git fetch origin main
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/main
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-LS            git ls-files -- <pathspec>
CMD-GIT-COUNT         git grep -c -F -e <literal> -- <paths>
CMD-GIT-ADD           git add -A -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "<each attribution line>"
CMD-GIT-PUSH          git push -u origin bug/batch-budget-hook-lacks-orchestration-awareness-769

CMD-PY-TEST           poetry run pytest -v <test files listed in the task>
CMD-PY-GEN            poetry run python scripts/dev_tools/generate_codex_agent_variants.py
CMD-PY-GEN-CHECK      poetry run python scripts/dev_tools/generate_codex_agent_variants.py --check

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format  (workspace_root = worktree root, scan_folders = folders listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test    (workspace_root = worktree root)
```

### Observed success outputs that acceptance conditions rely on

- The PoshQC MCP tools return a fixed summary string composed before the child process runs, with no exit code and no stdout. Their only observable signal is whether the call returns or raises; every count, percentage, and finding is therefore read from scratch scripts A2, A3, A6, and A7, never from an MCP result. Artifacts record the MCP call disposition as `EXIT_CODE: 0` when the call returned and non-zero when it raised.
- Scratch scripts print their result lines by construction (Appendix A): A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test; A3 additionally prints one `COVERAGE file=... LinePercent=` line and `HIT`/`MISSED` lines per coverage file; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `PSSA-SUMMARY DiagnosticCount=`. These formats were observed in the recorded runs of the #762 plan (for example `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/qa-gates/powershell-test-coverage.2026-09-28T22-17.md` line 8 records `COVERAGE file=... AnalyzedLines=34 CoveredLines=32 LinePercent=94.12`, and `.../powershell-format.2026-09-28T22-17.md` line 9 records `FORMAT-SUMMARY ChangedCount=0`). A2 and A3 exit 0 whether or not tests fail; failures are read from their output.
- `git grep` prints one `path:line:text` line per match (or `path:count` with `-c`) and exits 1 with no output when nothing matches. `git grep` searches tracked files only; every file a negative search in this plan targets is tracked before the search runs (existing files, or files committed by an earlier commit task).
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line.
- `generate_codex_agent_variants.py --check` exits 0 and prints nothing when nothing is stale; it exits 1 and prints one stderr line per stale path otherwise (lines 281-290).

### Search literal register

The negative and positive searches in this plan use these fixed strings, quoted here so each is an explicit instruction and not an inferred phrase: "per-batch", "batch cap", "smaller batches", "split the work", "new batch", "three-test", "1-2", "1–2", ">2", "2 production", "up to 2", "2-production", "1-3", "powershell-orchestrator", "/orchestrate", "budget: prod=", "POWERSHELL_LARGE_PATH_REQUIRED", "#673", "stale", "deleting", "reset the", "CLAUDE_POWERSHELL_BUDGET", "New-TemporaryFile", "GetTempFileName", "GetTempPath", "TestDrive", "Set-Content", "Out-File", "New-Item", "enforce-powershell-batch-budget-route.ps1", "- [x] AC-", "- [ ] AC-".

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [ ] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order. Acceptance: both read; recorded in P0-T5.
- [ ] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, and `.github/instructions/python-unit-test.instructions.md`. Acceptance: all six read; recorded in P0-T5.
- [ ] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and `.claude/rules/plan-acceptance-gates.md`. Acceptance: all five read; recorded in P0-T5.
- [ ] [P0-T4] Read, in order, `.claude/rules/powershell.md`, `.claude/rules/python.md`, and `.claude/rules/python-suppressions.md`. Acceptance: all three read; recorded in P0-T5.
- [ ] [P0-T5] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md. Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the 16 files read in P0-T1 through P0-T4 in reading order.
- [ ] [P0-T6] Create the 14 scratch scripts of Appendix A (A1 through A13 and A11b) verbatim under SCRATCH, then smoke-test: CMD-PS-SCRIPT with script line-counts (A4) and argument `CLAUDE.md`. Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: exit 0 and one output line beginning `CLAUDE.md LineCount=`; the artifact lists the 14 script file names.
- [ ] [P0-T7] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md. Commands: CMD-GIT-BRANCH, CMD-GIT-FETCH-MAIN, CMD-GIT-HEAD, CMD-GIT-MERGE-BASE, CMD-GIT-STATUS. Acceptance: the branch is BRANCH; the merge-base is recorded as BASE_SHA (40 hexadecimal characters); every CMD-GIT-STATUS line names one of `docs/features/potential/2026-08-16-batch-budget-hook-lacks-orchestration-awareness.md`, a path under `docs/features/potential/promoted/`, or a path under FEATURE. Any other line stops the plan.
- [ ] [P0-T8] Verify checkpoint readiness read-only for CHECKPOINT (`artifacts/orchestration/orchestrator-state.json`). Command: CMD-PS-SCRIPT with script checkpoint-probe (A9) and argument `artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/baseline/checkpoint-readiness.TS.md. Acceptance: output contains `ROUTE_ID=large`, `LIFECYCLE_READY=True`, and `ISSUE_NUM=769`, and the `NEXT_STEP=` value is not `complete`. If `LIFECYCLE_READY=True` is absent, stop and report to the orchestrator; this plan does not write CHECKPOINT.
- [ ] [P0-T9] Record the batch-budget state read-only from `.claude/state/`. Command: CMD-PS-SCRIPT with script budget-state-probe (A10). Write FEATURE/evidence/baseline/budget-state.TS.md. Acceptance: exit 0; the artifact records every `STATE file=` line and the `STATE-SUMMARY` line verbatim, and the sums of `prodCount` and of `testCount` across all lines (recorded as PROD_SUM_0 and TEST_SUM_0). If any single line has `prodCount=3` or `testCount=3`, stop and report before Phase 1, because the pre-fix hook would deny the first write; do not delete the file.
- [ ] [P0-T10] Record pre-change line counts in FEATURE/evidence/baseline/line-counts.TS.md. Command: CMD-PS-SCRIPT with script line-counts (A4) over CHOOK, XHOOK, CTEST, XTEST, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: exit 0 and six `LineCount=` lines; CHOOK is 457, XHOOK is 256, CTEST is 495.
- [ ] [P0-T11] Record mirror-pair hashes in FEATURE/evidence/baseline/mirror-hashes.TS.md. Command: CMD-PS-SCRIPT with script pair-hashes (A13) over the 15 pairs of Appendix E (primary, then mirror, for each pair). Acceptance: `PAIR-SUMMARY pairs=15 unequal=0`. An unequal pair stops the plan, because a `cp` would then discard a bundle-specific difference.
- [ ] [P0-T12] Record the Codex variant generator baseline for `.codex/agents/powershell-typed-engineer*.toml`. Command: CMD-PY-GEN-CHECK. Write FEATURE/evidence/baseline/codex-variants-check.TS.md. Acceptance: exit 0 and no stderr line. A non-zero exit stops the plan, because regeneration would otherwise rewrite unrelated families.
- [ ] [P0-T13] PowerShell format baseline over `.claude/hooks`, `.codex/hooks`, `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, and `scripts/powershell/PoshQC/settings` (the five folders the MCP format calls of P2-T7, P5-T3, and P9-T1 scan). Command: CMD-PS-SCRIPT with script ps-format-check (A6) over `.claude/hooks/*.ps*1 .codex/hooks/*.ps*1 tests/scripts/claude-hooks/*.ps1 tests/scripts/codex-hooks/*.ps1 scripts/powershell/PoshQC/settings/*.psd1`. Write FEATURE/evidence/baseline/powershell-format.TS.md. Acceptance: exit 0 and `FORMAT-SUMMARY ChangedCount=0`. A non-zero count stops the plan, because the folder-scoped MCP format calls in later phases would rewrite files outside this item.
- [ ] [P0-T14] PowerShell analyzer baseline for CHOOK, XHOOK, CTEST, and XTEST. Command: CMD-PS-SCRIPT with script pssa-count (A7) over those four files. Write FEATURE/evidence/baseline/powershell-analyze.TS.md. Acceptance: exit 0 and the `PSSA-SUMMARY DiagnosticCount=` value is recorded.
- [ ] [P0-T15] Claude hook test and coverage baseline for CHOOK (`.claude/hooks/enforce-powershell-batch-budget.ps1`), written to FEATURE/evidence/baseline/claude-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-claude-baseline.xml -ReportPath SCRATCH/cov-claude-baseline.txt`. Acceptance: `TotalCount=36`, `FailedCount=0`, and the `COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1` line has a numeric `LinePercent=` (recorded as CLAUDE_BASE_PCT).
- [ ] [P0-T16] Codex hook test and coverage baseline for XHOOK (`.codex/hooks/enforce-powershell-batch-budget.ps1`), written to FEATURE/evidence/baseline/codex-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-codex-baseline.xml -ReportPath SCRATCH/cov-codex-baseline.txt`. Acceptance: `TotalCount=48`, `FailedCount=0`, and a numeric `LinePercent=` for XHOOK (recorded as CODEX_BASE_PCT).
- [ ] [P0-T17] Pester regression baseline for `tests/scripts/claude-hooks`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks`. Write FEATURE/evidence/baseline/pester-claude-hooks.TS.md. Acceptance: the artifact records `TotalCount=`, `PassedCount=`, `FailedCount=`, and every `FAILED:` line verbatim (the baseline failure set, possibly empty).
- [ ] [P0-T18] Pester regression baseline for `tests/scripts/codex-hooks`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/codex-hooks`. Write FEATURE/evidence/baseline/pester-codex-hooks.TS.md. Acceptance: as P0-T17.
- [ ] [P0-T19] Pester regression baseline for `tests/scripts/claude-runtime`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-runtime`. Write FEATURE/evidence/baseline/pester-claude-runtime.TS.md. Acceptance: as P0-T17.
- [ ] [P0-T20] Python parity baseline for the eight suites of Appendix F (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and seven others). Command: CMD-PY-TEST over the eight Appendix F files. Write FEATURE/evidence/baseline/python-parity.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED, and that node satisfies KL-510 (the artifact carries the KL-510 line and, for case (b), `ExpectedExitCode: 1`).
- [ ] [P0-T21] Python regression baseline for `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/baseline/python-dev-tools.TS.md. Acceptance: the artifact records the summary line (passed, failed, skipped counts) and every `FAILED` line verbatim (the baseline failure set; KL-510 case (b) may be a member).
- [ ] [P0-T22] Non-vacuity baseline for the AC-13 per-batch search over the PowerShell-path surfaces of Appendix G. Command: the AC-13 search command of Appendix G. Write FEATURE/evidence/baseline/ac13-sweep.TS.md. Acceptance: exit 0 and at least one match line in each of `.claude/rules/powershell.md`, `.agents/skills/powershell/SKILL.md`, `.github/agents/powershell-typed-engineer.agent.md`, and `.codex/agents/powershell-typed-engineer.toml`, proving the search finds the text it later asserts absent.
- [ ] [P0-T23] Non-vacuity baseline for the AC-14 threshold search over the eight files of Appendix G. Command: the AC-14 negative search command of Appendix G. Write FEATURE/evidence/baseline/ac14-threshold.TS.md. Acceptance: exit 0 and each of the eight files appears on at least one match line.
- [ ] [P0-T24] Non-vacuity baseline for the AC-15 name search over the four Claude files of Appendix G. Command: the AC-15 negative search command of Appendix G. Write FEATURE/evidence/baseline/ac15-orchestrator-name.TS.md. Acceptance: exit 0 and each of `.claude/skills/powershell-change-budget-router/SKILL.md` (lines 8, 22, 26, 41), `.claude/rules/powershell.md` (line 39), and `.claude/agents/powershell-typed-engineer.md` (lines 39, 49) appears on at least one match line; `.claude/skills/invoke-powershell-engineer/SKILL.md` has no match at baseline and gains its `/orchestrate` reference through C4.

### Phase 1 — Claude Regression Tests First

- [ ] [P1-T1] Write CRTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`) per Appendix B3 (21 route rows, 4 selected-route cases, 6 direct-mode cases, 5 large-path cases, 2 test-path cases, 4 override cases, 5 seam cases). Acceptance: the Write succeeds without a hook denial, and CMD-PS-SCRIPT with script line-counts (A4) over CRTEST prints one `LineCount=` value of at most 500. The case count is verified by P1-T2 (`TotalCount=47`); the file is untracked until P1-T3, so no `git grep` assertion is made on it here (its temporary-file check is P9-T12).
- [ ] [P1-T2] [expect-fail] Run CRTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`) against the unfixed hook. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/claude-routing-before-fix.TS.md with `ExpectedExitCode: 0` (A2 reports test failures in its output, not its exit code). Acceptance: exit 0, `TotalCount=47`, `PassedCount=0`, `FailedCount=47`. Any other count stops the plan for a design review, because every Appendix B3 case depends on the new hook surface.
- [ ] [P1-T3] Commit and push Phase 1 (CRTEST, FEATURE, and the promotion move). Commands: CMD-GIT-ADD with `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769 docs/features/potential/2026-08-16-batch-budget-hook-lacks-orchestration-awareness.md docs/features/potential/promoted/2026-08-16-batch-budget-hook-lacks-orchestration-awareness.md`, CMD-GIT-COMMIT with message "test(769): add Claude batch-budget routing regression tests", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit and the push exits 0.

### Phase 2 — Claude Hook Fix (Bootstrap First)

- [ ] [P2-T1] Write CHOOK (`.claude/hooks/enforce-powershell-batch-budget.ps1`) per Appendix B1 as one Write call carrying the complete file, with the three route functions of Appendix B2 inline immediately after `Test-PowerShellBatchBudgetPathInRoot`. This is the first production PowerShell write of the plan. Acceptance: the Write succeeds without a hook denial; CMD-GIT-COUNT with literal `POWERSHELL_LARGE_PATH_REQUIRED` over CHOOK prints a count of 1; CMD-GIT-COUNT with literal `CLAUDE_POWERSHELL_BUDGET` over CHOOK exits 1 with no output.
- [ ] [P2-T2] Probe the corrected CHOOK against the live CHECKPOINT. Command: CMD-PS-SCRIPT with script route-probe (A11) and arguments `.claude/hooks/enforce-powershell-batch-budget.ps1 artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/regression-testing/live-route-probe-inline.TS.md. Acceptance: output contains `LARGE-PATH-ROUTE=True` and `SELECTED-ROUTE=large`. Any other output stops the plan before any further PowerShell write.
- [ ] [P2-T3] Write CROUTE (`.claude/hooks/enforce-powershell-batch-budget-route.ps1`) per Appendix B2, carrying the three route functions exactly as they appear in CHOOK after P2-T1. Acceptance: the Write succeeds without a hook denial (CROUTE is the 2nd distinct production path and is evaluated by the corrected hook); CMD-PS-SCRIPT with script route-probe (A11) and arguments `.claude/hooks/enforce-powershell-batch-budget-route.ps1 artifacts/orchestration/orchestrator-state.json` prints `LARGE-PATH-ROUTE=True` and `SELECTED-ROUTE=large` (CROUTE is untracked here, so a script probe is used instead of `git grep`).
- [ ] [P2-T4] Edit CHOOK (`.claude/hooks/enforce-powershell-batch-budget.ps1`): delete the three inline route functions and insert the line `. (Join-Path $PSScriptRoot 'enforce-powershell-batch-budget-route.ps1')` immediately after the `Import-Module` line. Acceptance: CMD-GIT-COUNT with literal `function Test-PowerShellBatchBudgetLargePathRoute` over CHOOK exits 1; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route.ps1` over CHOOK prints a count of 1.
- [ ] [P2-T5] Re-probe CHOOK after the split. Command: as P2-T2. Write FEATURE/evidence/regression-testing/live-route-probe-split.TS.md. Acceptance: output contains `LARGE-PATH-ROUTE=True` and `SELECTED-ROUTE=large`.
- [ ] [P2-T6] Edit CTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`) per Appendix B5. Acceptance: CMD-GIT-COUNT with literal `test file cap is` over CTEST exits 1; `git grep -c -F -e 'ReadCheckpoint $script:NoCheckpoint' -- tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (single quotes, so the shell does not expand `$script`) prints a count of 11.
- [ ] [P2-T7] Format CHOOK, CROUTE, CTEST, and CRTEST. Commands: MCP-PS-FORMAT with scan_folders `.claude/hooks` and `tests/scripts/claude-hooks`; then CMD-GIT-STATUS-PATH over `.claude/hooks tests/scripts/claude-hooks`; then CMD-PS-SCRIPT with script ps-format-check (A6) over the four files. Write FEATURE/evidence/qa-gates/claude-format-p2.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than CHOOK, CROUTE, CTEST, and CRTEST; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P2-T8] Analyze CHOOK, CROUTE, CTEST, and CRTEST. Commands: MCP-PS-ANALYZE with the P2-T7 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the four files. Write FEATURE/evidence/qa-gates/claude-analyze-p2.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P2-T9] Run CRTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`) after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/claude-routing-after-fix.TS.md. Acceptance: `TotalCount=47`, `PassedCount=47`, `FailedCount=0`.
- [ ] [P2-T10] Run CTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`) after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/claude-existing-after-fix.TS.md. Acceptance: `TotalCount=36`, `PassedCount=36`, `FailedCount=0`.
- [ ] [P2-T11] Run `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (AC-9 deny shape). Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/pretooluse-schema.TS.md. Acceptance: `FailedCount=0` and `TotalCount=` equals `PassedCount=`.
- [ ] [P2-T12] Record the live large-path state effect in `.claude/state/`. Command: CMD-PS-SCRIPT with script budget-state-probe (A10). Write FEATURE/evidence/regression-testing/live-state-after-claude-fix.TS.md. Acceptance: the sum of `prodCount` equals PROD_SUM_0 plus 1 (CHOOK, recorded by the pre-fix hook at P2-T1) and the sum of `testCount` equals TEST_SUM_0 plus 1 (CRTEST, recorded at P1-T1); CROUTE, the P2-T4 edit, and the CTEST edit added nothing. Record the two sums as PROD_SUM_2 and TEST_SUM_2.
- [ ] [P2-T13] Record line counts for CHOOK, CROUTE, CTEST, and CRTEST. Command: CMD-PS-SCRIPT with script line-counts (A4) over the four files. Write FEATURE/evidence/qa-gates/line-counts-p2.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [ ] [P2-T14] Commit and push Phase 2 (CHOOK, CROUTE, CTEST). Commands: CMD-GIT-ADD with `.claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-powershell-batch-budget-route.ps1 tests/scripts/claude-hooks docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "fix(769): route over-budget PowerShell changes to the large path in the Claude hook", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 3 — Claude Bundle, Pack Manifest, and Coverage Registration

- [ ] [P3-T1] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: insert the line `            '.claude/hooks/enforce-powershell-batch-budget-route.ps1'` immediately after line 31 (the CHOOK entry). This is the 3rd distinct production PowerShell path written through Write or Edit. Acceptance: the Edit succeeds without a hook denial; CMD-PS-SCRIPT with script psd1-parse (A8) over the file prints `PSD1-OK`; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route.ps1` over the file prints a count of 1.
- [ ] [P3-T2] Mirror `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` into the PoshQC bundle. Command: `cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P3-T3] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`: insert the line `    ".claude/hooks/enforce-powershell-batch-budget-route.ps1",` immediately after line 8. Acceptance: CMD-PS-SCRIPT with script json-parse (A12) over the file prints `JSON-OK`; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route.ps1` over the file prints a count of 1.
- [ ] [P3-T4] Mirror CHOOK and CROUTE into CB. Commands: `cp .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` and `cp .claude/hooks/enforce-powershell-batch-budget-route.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P3-T5] Run the Claude bundle contract suites `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Command: CMD-PY-TEST over those three files. Write FEATURE/evidence/regression-testing/claude-bundle-contracts.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED, and that node satisfies KL-510.
- [ ] [P3-T6] Commit and push Phase 3 (runsettings, manifest, CB hooks). Commands: CMD-GIT-ADD with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/claude-customizations docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "fix(769): bundle the Claude batch-budget route helpers", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 4 — Codex Regression Tests First

- [ ] [P4-T1] Write XRTEST (`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`) per Appendix B4 (21 route rows, 4 selected-route cases, 6 direct-mode cases, 5 large-path cases, 2 test-path cases, 3 override cases, 5 seam cases, 3 entry-point cases). Acceptance: the Write succeeds without a hook denial, and CMD-PS-SCRIPT with script line-counts (A4) over XRTEST prints one `LineCount=` value of at most 500. The case count is verified by P4-T2 (`TotalCount=49`).
- [ ] [P4-T2] [expect-fail] Run XRTEST (`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`) against the unfixed Codex hook. Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/codex-routing-before-fix.TS.md with `ExpectedExitCode: 0`. Acceptance: exit 0, `TotalCount=49`, `PassedCount=0`, `FailedCount=49`. Any other count stops the plan for a design review.
- [ ] [P4-T3] Commit and push Phase 4 (XRTEST). Commands: CMD-GIT-ADD with `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "test(769): add Codex batch-budget routing regression tests", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 5 — Codex Hook Fix

- [ ] [P5-T1] Write XHOOK (`.codex/hooks/enforce-powershell-batch-budget.ps1`) per Appendix B6 as one Write call carrying the complete file. Acceptance: the Write succeeds without a hook denial (this is the 4th distinct production PowerShell path written through Write or Edit; see Bootstrap ordering); CMD-GIT-COUNT with literal `POWERSHELL_LARGE_PATH_REQUIRED` over XHOOK prints a count of 1; CMD-GIT-COUNT with literal `[Console]::In.ReadToEnd()` over XHOOK prints a count of 1.
- [ ] [P5-T2] Edit XTEST (`tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`) per Appendix B7. Acceptance: CMD-GIT-COUNT with literal `ExtraSeams` over XTEST prints a count of at least 7; CMD-GIT-COUNT with literal `the Python batch-budget hook cap contract` over XTEST prints a count of 1.
- [ ] [P5-T3] Format XHOOK, XTEST, and XRTEST. Commands: MCP-PS-FORMAT with scan_folders `.codex/hooks` and `tests/scripts/codex-hooks`; then CMD-GIT-STATUS-PATH over `.codex/hooks tests/scripts/codex-hooks`; then CMD-PS-SCRIPT with script ps-format-check (A6) over the three files. Write FEATURE/evidence/qa-gates/codex-format-p5.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than XHOOK, XTEST, and XRTEST; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P5-T4] Analyze XHOOK, XTEST, and XRTEST. Commands: MCP-PS-ANALYZE with the P5-T3 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the three files. Write FEATURE/evidence/qa-gates/codex-analyze-p5.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P5-T5] Run XRTEST (`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`) after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/codex-routing-after-fix.TS.md. Acceptance: `TotalCount=49`, `PassedCount=49`, `FailedCount=0`.
- [ ] [P5-T6] Run XTEST (`tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`) after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/codex-existing-after-fix.TS.md. Acceptance: `TotalCount=41` (the P0-T16 value 48 minus the 7 PowerShell cap cases moved per D6), `PassedCount=41`, `FailedCount=0`.
- [ ] [P5-T7] Mirror XHOOK into XB. Command: `cp .codex/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P5-T8] Run the unchanged Codex contract suites `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path` set to the three paths joined by commas. Write FEATURE/evidence/regression-testing/codex-contracts.TS.md. Acceptance: every `FAILED:` line (if any) is a member of the P0-T18 baseline failure set, and no `FAILED:` line names a test containing "byte-identical", "500 lines", "legacy Claude environment", or "batch-budget".
- [ ] [P5-T9] Record line counts for XHOOK, XTEST, and XRTEST. Command: CMD-PS-SCRIPT with script line-counts (A4) over the three files. Write FEATURE/evidence/qa-gates/line-counts-p5.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [ ] [P5-T10] Commit and push Phase 5 (XHOOK, XTEST, XB hook). Commands: CMD-GIT-ADD with `.codex/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 tests/scripts/codex-hooks docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "fix(769): route over-budget PowerShell changes to the large path in the Codex hook", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 6 — Claude and Copilot Text Surfaces

- [ ] [P6-T1] Edit `.claude/rules/powershell.md` per Appendix C1. Acceptance: CMD-GIT-COUNT with literal `split the work` over the file exits 1, and CMD-GIT-COUNT with literal `/orchestrate` over it prints a count of at least 1.
- [ ] [P6-T2] Edit `.claude/skills/powershell-change-budget-router/SKILL.md` per Appendix C2. Acceptance: CMD-GIT-COUNT with literal `powershell-orchestrator` over the file exits 1, and CMD-GIT-COUNT with literal `1-3` over it prints a count of at least 2.
- [ ] [P6-T3] Edit `.claude/agents/powershell-typed-engineer.md` per Appendix C3. Acceptance: CMD-GIT-COUNT with literal `per-batch` over the file exits 1, and CMD-GIT-COUNT with literal `/orchestrate` over it prints a count of at least 2.
- [ ] [P6-T4] Edit `.claude/skills/invoke-powershell-engineer/SKILL.md` per Appendix C4. Acceptance: CMD-GIT-COUNT with literal `budget: prod=` over the file exits 1, and CMD-GIT-COUNT with literal `/orchestrate` over it prints a count of at least 1.
- [ ] [P6-T5] Edit `.github/skills/powershell-change-budget-router/SKILL.md` per Appendix C5. Acceptance: CMD-GIT-COUNT with literal `1-3` over the file prints a count of at least 1, and CMD-GIT-COUNT with literal `>2` over it exits 1.
- [ ] [P6-T6] Edit `.github/agents/powershell-typed-engineer.agent.md` per Appendix C6. Acceptance: CMD-GIT-COUNT with literal `per-batch` over the file exits 1, and CMD-GIT-COUNT with literal `1-3` over it prints a count of at least 3.
- [ ] [P6-T7] Edit `.github/agents/powershell-orchestrator.agent.md` per Appendix C7. Acceptance: CMD-GIT-COUNT with literal `1-2` over the file exits 1, and CMD-GIT-COUNT with literal `1-3` over it prints a count of at least 4.
- [ ] [P6-T8] Edit `.github/prompts/orchestrate-powershell-work.prompt.md` per Appendix C8. Acceptance: CMD-GIT-COUNT with literal `1–2` over the file exits 1, and CMD-GIT-COUNT with literal `1-3` over it prints a count of 1.
- [ ] [P6-T9] Mirror the four Claude text files into CB. Commands: `cp .claude/rules/powershell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md`, `cp .claude/skills/powershell-change-budget-router/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-change-budget-router/SKILL.md`, `cp .claude/agents/powershell-typed-engineer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`, `cp .claude/skills/invoke-powershell-engineer/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the four pairs prints `PAIR-SUMMARY pairs=4 unequal=0`.
- [ ] [P6-T10] Mirror the four Copilot text files into GB. Commands: `cp .github/skills/powershell-change-budget-router/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/powershell-change-budget-router/SKILL.md`, `cp .github/agents/powershell-typed-engineer.agent.md extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md`, `cp .github/agents/powershell-orchestrator.agent.md extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md`, `cp .github/prompts/orchestrate-powershell-work.prompt.md extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-powershell-work.prompt.md`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the four pairs prints `PAIR-SUMMARY pairs=4 unequal=0`.
- [ ] [P6-T11] AC-14 threshold check over the eight files of Appendix G. Commands: the AC-14 negative search, then the AC-14 positive search of Appendix G. Write FEATURE/evidence/qa-gates/ac14-threshold.TS.md. Acceptance: the negative search exits 1 with no output (`ExpectedExitCode: 1` in the artifact); the positive search prints exactly eight `path:count` lines, one per file.
- [ ] [P6-T12] AC-15 name check over the four Claude files of Appendix G. Commands: the AC-15 negative search, then the AC-15 positive search of Appendix G. Write FEATURE/evidence/qa-gates/ac15-orchestrator-name.TS.md. Acceptance: the negative search exits 1 with no output (`ExpectedExitCode: 1`); the positive search prints exactly four `path:count` lines.
- [ ] [P6-T13] AC-16 check on `.claude/skills/invoke-powershell-engineer/SKILL.md` and its CB mirror. Command: `git grep -n -F -e "budget: prod=" -- .claude/skills/invoke-powershell-engineer/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`. Write FEATURE/evidence/qa-gates/ac16-budget-input.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.
- [ ] [P6-T14] Run `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Command: CMD-PY-TEST over those two files. Write FEATURE/evidence/regression-testing/text-surface-contracts.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED, and that node satisfies KL-510.
- [ ] [P6-T15] Commit and push Phase 6 (eight text files and their mirrors). Commands: CMD-GIT-ADD with `.claude/rules/powershell.md .claude/skills/powershell-change-budget-router/SKILL.md .claude/agents/powershell-typed-engineer.md .claude/skills/invoke-powershell-engineer/SKILL.md .github/skills/powershell-change-budget-router/SKILL.md .github/agents/powershell-typed-engineer.agent.md .github/agents/powershell-orchestrator.agent.md .github/prompts/orchestrate-powershell-work.prompt.md extensions/drm-copilot/resources/claude-customizations extensions/drm-copilot/resources/customizations docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "docs(769): state the PowerShell routing rule on Claude and Copilot surfaces", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 7 — Codex and .agents Text Surfaces and Variant Regeneration

- [ ] [P7-T1] Edit `.agents/skills/powershell/SKILL.md` per Appendix C9. Acceptance: CMD-GIT-COUNT with literal `split the work` over the file exits 1, and CMD-GIT-COUNT with literal `up to 2` over it prints a count of 1 (the deferred threshold line is kept).
- [ ] [P7-T2] Edit `.agents/skills/invoke-powershell-engineer/SKILL.md` per Appendix C10. Acceptance: CMD-GIT-COUNT with literal `three-test` over the file exits 1, and CMD-GIT-COUNT with literal `one-to-two` over it prints a count of 1.
- [ ] [P7-T3] Edit `.codex/agents/powershell-typed-engineer.toml` per Appendix C11. Acceptance: CMD-GIT-COUNT with literal `per-batch` over the file exits 1, and CMD-GIT-COUNT with literal `1-2 production` over it prints a count of at least 2 (the deferred threshold clauses are kept).
- [ ] [P7-T4] Mirror the two `.agents` files into XB. Commands: `cp .agents/skills/powershell/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell/SKILL.md` and `cp .agents/skills/invoke-powershell-engineer/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P7-T5] Regenerate the Codex variants of `.codex/agents/powershell-typed-engineer.toml` with the repository generator. Commands: CMD-PY-GEN, then CMD-GIT-STATUS-PATH over `.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`. Write FEATURE/evidence/other/codex-variants-regenerated.TS.md. Acceptance: the generator exits 0; the status output lists exactly the twelve paths `.codex/agents/powershell-typed-engineer.toml`, `.codex/agents/powershell-typed-engineer-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`, and the same six file names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`, each with status `M`, and no other path. No variant is hand-edited.
- [ ] [P7-T6] Verify the regenerated variants. Command: CMD-PY-GEN-CHECK. Write FEATURE/evidence/qa-gates/codex-variants-check.TS.md. Acceptance: exit 0 and no stderr line.
- [ ] [P7-T7] Run `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Command: CMD-PY-TEST over those two files. Write FEATURE/evidence/regression-testing/codex-surface-contracts.TS.md. Acceptance: exit 0 and no FAILED line.
- [ ] [P7-T8] Commit and push Phase 7 (`.agents`, `.codex/agents`, XB). Commands: CMD-GIT-ADD with `.agents/skills/powershell/SKILL.md .agents/skills/invoke-powershell-engineer/SKILL.md .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`, CMD-GIT-COMMIT with message "docs(769): remove per-batch text from Codex and .agents PowerShell surfaces", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.
- [ ] [P7-T9] AC-13 per-batch sweep over the PowerShell-path surfaces and mirrors of Appendix G (all targets are tracked and committed at this point). Command: the AC-13 search command of Appendix G. Write FEATURE/evidence/qa-gates/ac13-sweep.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.

### Phase 8 — Follow-up Potential Entries

- [ ] [P8-T1] Write `docs/features/potential/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness.md` per Appendix D1. Acceptance: the Write succeeds without a hook denial; content is verified after commit by P8-T4.
- [ ] [P8-T2] Write `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md` per Appendix D2. Acceptance: as P8-T1.
- [ ] [P8-T3] Write `docs/features/potential/2026-09-29-codex-routing-resolver-powershell-budget-two.md` per Appendix D3. Acceptance: as P8-T1.
- [ ] [P8-T4] Commit, push, and verify the three entries under `docs/features/potential/`. Commands: CMD-GIT-ADD with the three paths of P8-T1 through P8-T3 and FEATURE, CMD-GIT-COMMIT with message "docs(769): record batch-budget follow-up potential entries", CMD-GIT-PUSH; then CMD-GIT-LS over the three paths, CMD-GIT-COUNT with literal `#769` over them, and CMD-GIT-COUNT with literal `## Acceptance Criteria (early draft)` over them. Write FEATURE/evidence/other/follow-up-entries.TS.md. Acceptance: CMD-GIT-LS prints exactly the three paths; each CMD-GIT-COUNT prints three `path:count` lines; no `gh` command is run.

### Phase 9 — Final QA Loop: PowerShell (PoshQC and Pester)

- [ ] [P9-T1] Format: CMD-PS-SCRIPT with script file-hashes (A5) over CHOOK, CROUTE, XHOOK, CTEST, CRTEST, XTEST, XRTEST, and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (before); MCP-PS-FORMAT with scan_folders `.claude/hooks`, `.codex/hooks`, `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `scripts/powershell/PoshQC/settings`; the same file-hashes run (after); CMD-GIT-STATUS; CMD-PS-SCRIPT with script ps-format-check (A6) over the same eight files. Write FEATURE/evidence/qa-gates/powershell-format.TS.md. Acceptance: the MCP call returns without raising; the before and after hashes are identical for all eight files; CMD-GIT-STATUS prints nothing; A6 prints `FORMAT-SUMMARY ChangedCount=0`. If A6 reports `Changed=True` for a file the MCP call left unchanged, the two formatters use different settings; stop and report rather than editing by hand.
- [ ] [P9-T2] Analyze the eight P9-T1 files (CHOOK and the other seven). Commands: MCP-PS-ANALYZE with the P9-T1 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the eight files. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P9-T3] Run the policy-mandated MCP test step for `tests/scripts` (route compliance only). Command: MCP-PS-TEST. Write FEATURE/evidence/qa-gates/powershell-mcp-test.TS.md. Acceptance: the call returns without raising; the artifact records the call disposition and states that counts and coverage are taken from P9-T4 through P9-T9, because the MCP result carries no test output.
- [ ] [P9-T4] Test with coverage for CHOOK and CROUTE, written to FEATURE/evidence/qa-gates/claude-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-powershell-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-claude-final.xml -ReportPath SCRATCH/cov-claude-final.txt`. Acceptance: `TotalCount=83`, `PassedCount=83`, `FailedCount=0`; the `COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1` and `COVERAGE file=.claude/hooks/enforce-powershell-batch-budget-route.ps1` lines each have `LinePercent=` at least 85.
- [ ] [P9-T5] Test with coverage for XHOOK, written to FEATURE/evidence/qa-gates/codex-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-codex-final.xml -ReportPath SCRATCH/cov-codex-final.txt`. Acceptance: `TotalCount=90`, `PassedCount=90`, `FailedCount=0`; the `COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1` line has `LinePercent=` at least 85.
- [ ] [P9-T6] Changed-line coverage for CHOOK, CROUTE, and XHOOK against BASE_SHA, written to FEATURE/evidence/qa-gates/changed-line-coverage.TS.md. Commands: CMD-PS-SCRIPT with script changed-line-coverage (A11b) and `-CoverageReportPath SCRATCH/cov-claude-final.txt -BaseRef BASE_SHA -File .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-powershell-batch-budget-route.ps1`, then the same script with `-CoverageReportPath SCRATCH/cov-codex-final.txt -BaseRef BASE_SHA -File .codex/hooks/enforce-powershell-batch-budget.ps1` (BASE_SHA replaced by the recorded commit). Acceptance: three `CHANGED-COVERAGE file=` lines, none `MISSING`, each with numeric `ChangedPercent=` at least 85.
- [ ] [P9-T7] Regression over `tests/scripts/claude-hooks`, written to FEATURE/evidence/qa-gates/pester-claude-hooks.TS.md. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks`. Acceptance: `TotalCount=` equals the P0-T17 value plus 47, and every `FAILED:` line is a member of the P0-T17 baseline failure set.
- [ ] [P9-T8] Regression over `tests/scripts/codex-hooks`, written to FEATURE/evidence/qa-gates/pester-codex-hooks.TS.md. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/codex-hooks`. Acceptance: `TotalCount=` equals the P0-T18 value plus 42 (49 new, 7 removed from the PowerShell row), and every `FAILED:` line is a member of the P0-T18 baseline failure set.
- [ ] [P9-T9] Regression over `tests/scripts/claude-runtime`, written to FEATURE/evidence/qa-gates/pester-claude-runtime.TS.md. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-runtime`. Acceptance: `TotalCount=` equals the P0-T19 value, and every `FAILED:` line is a member of the P0-T19 baseline failure set.
- [ ] [P9-T10] File-size limit check, written to FEATURE/evidence/qa-gates/line-counts-final.TS.md. Command: CMD-PS-SCRIPT with script line-counts (A4) over the eight P9-T1 files and the four bundle hook copies (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`). Acceptance: every `LineCount=` value for a `.ps1` file is at most 500; the runsettings pair counts equal the P0-T10 runsettings value plus 1.
- [ ] [P9-T11] Record the live state after all PowerShell writes from `.claude/state/`. Command: CMD-PS-SCRIPT with script budget-state-probe (A10). Write FEATURE/evidence/qa-gates/live-state-final.TS.md. Acceptance: the `prodCount` sum equals PROD_SUM_2 and the `testCount` sum equals TEST_SUM_2 (P2-T12): the runsettings edit, XRTEST, XHOOK, and XTEST, written on the large path, added nothing.
- [ ] [P9-T12] AC-11 temporary-file check on CRTEST, XRTEST, CTEST, and XTEST. Command: `git grep -n -F -e "New-TemporaryFile" -e "GetTempFileName" -e "GetTempPath" -e "TestDrive" -e "Set-Content" -e "Out-File" -e "New-Item" -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`. Write FEATURE/evidence/qa-gates/ac11-no-temp-files.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.

### Phase 10 — Final QA: Python Parity Harness

- [ ] [P10-T1] Run the eight Appendix F parity suites (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and seven others). Command: CMD-PY-TEST over the eight Appendix F files. Write FEATURE/evidence/qa-gates/python-parity.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED and that node satisfies KL-510.
- [ ] [P10-T2] Regression over `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/qa-gates/python-dev-tools.TS.md. Acceptance: every `FAILED` line is a member of the P0-T21 baseline failure set, and the collected total (passed plus failed plus skipped) equals the P0-T21 total.
- [ ] [P10-T3] Confirm that no Python source file under the repository changed. Commands: `git diff --name-only BASE_SHA -- "*.py"` and `git status --porcelain -- "*.py"`. Write FEATURE/evidence/qa-gates/python-scope.TS.md. Acceptance: both commands print nothing, so the Python format, lint, type-check, and coverage gates have no in-scope file.

### Phase 11 — Scope Guards and Coverage Comparison

- [ ] [P11-T1] AC-19 check on `.github/copilot-instructions.md` and `.github/instructions`. Commands: `git diff --exit-code BASE_SHA -- .github/copilot-instructions.md .github/instructions` and `git status --porcelain -- .github/copilot-instructions.md .github/instructions`. Write FEATURE/evidence/qa-gates/ac19-policy-unchanged.TS.md. Acceptance: the diff exits 0 with no output and the status prints nothing.
- [ ] [P11-T2] AC-22 docstring check on CHOOK, CROUTE, XHOOK. Commands: `git grep -n -i -F -e "per-batch" -e "deleting" -e "reset the" -e "new batch" -e "batch cap" -e "split the work" -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-powershell-batch-budget-route.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1` (negative), then CMD-GIT-COUNT with literal `#673` and CMD-GIT-COUNT with literal `stale` over CHOOK and XHOOK (positive). Write FEATURE/evidence/qa-gates/ac22-docstrings.TS.md. Acceptance: the negative search exits 1 with no output; each positive search prints two `path:count` lines.
- [ ] [P11-T3] Final mirror check across the 15 pairs of Appendix E plus the CROUTE pair. Command: CMD-PS-SCRIPT with script pair-hashes (A13) over the 16 pairs. Write FEATURE/evidence/qa-gates/mirror-hashes-final.TS.md. Acceptance: `PAIR-SUMMARY pairs=16 unequal=0`.
- [ ] [P11-T4] Coverage comparison: write FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the P0-T15, P0-T16, P9-T4, P9-T5, and P9-T6 artifacts. Acceptance: the artifact carries, for PowerShell, the fields `Baseline Coverage:` (CLAUDE_BASE_PCT for CHOOK, CODEX_BASE_PCT for XHOOK), `Post-Change Coverage:` (the P9-T4 values for CHOOK and CROUTE and the P9-T5 value for XHOOK), `New/Changed-code Coverage:` (the three P9-T6 `ChangedPercent=` values), and `Disposition:`, all numeric. `Disposition:` is `PASS` only when every post-change value and every changed-code value is at least 85; otherwise `BLOCKED`. The artifact also states that Python has no in-scope source file (P10-T3) and that no TypeScript file is changed.
- [ ] [P11-T5] Commit and push the final QA evidence under FEATURE. Commands: CMD-GIT-STATUS, then CMD-GIT-ADD with FEATURE plus every path CMD-GIT-STATUS listed (fixes made by Phase 9 loop restarts), CMD-GIT-COMMIT with message "docs(769): record final QA evidence", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 12 — Acceptance-Criteria Check-Off

Each check-off task changes the AC line from `- [ ] AC-n:` to `- [x] AC-n:` in both `FEATURE/spec.md` and `FEATURE/issue.md` (the issue list mirrors the spec list) and records the check-off, with the cited artifacts, in FEATURE/evidence/other/ac-checkoff.TS.md. Its acceptance is the CMD-GIT-COUNT of the literal `- [x] AC-n:` (passed through `-e`) printing one line for each of the two files, plus the cited artifacts existing with passing acceptance. An AC whose cited artifacts do not all pass stays unchecked, and the plan outcome is remediation-required.

- [ ] [P12-T1] Check off AC-1 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P1-T2 (fail-before), P2-T9.
- [ ] [P12-T2] Check off AC-2 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P4-T2 (fail-before), P5-T5.
- [ ] [P12-T3] Check off AC-3 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9 and P5-T5 (case D4 in each suite).
- [ ] [P12-T4] Check off AC-4 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P5-T5 (large-path cases), P2-T12 and P9-T11 (live session state).
- [ ] [P12-T5] Check off AC-5 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P5-T5 (route rows 9 through 13, case L3).
- [ ] [P12-T6] Check off AC-6 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P5-T5 (route rows 4 through 8 and 14 through 21, cases D6, S1, S3).
- [ ] [P12-T7] Check off AC-7 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P5-T5 (cases P1, P2), P2-T10.
- [ ] [P12-T8] Check off AC-8 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P5-T5 (override cases), P2-T1 (no `CLAUDE_POWERSHELL_BUDGET` in CHOOK).
- [ ] [P12-T9] Check off AC-9 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T10, P2-T11, P5-T6, P5-T8 (the Codex hook has no containment filter, per research Section 1.2, so the out-of-root clause applies to the Claude hook).
- [ ] [P12-T10] Check off AC-10 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P5-T8.
- [ ] [P12-T11] Check off AC-11 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P9-T12 and the seam cases of P2-T9 and P5-T5.
- [ ] [P12-T12] Check off AC-12 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T9, P2-T10, P5-T5, P5-T6.
- [ ] [P12-T13] Check off AC-13 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T22 (non-vacuity), P7-T9.
- [ ] [P12-T14] Check off AC-14 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T23 (non-vacuity), P6-T11.
- [ ] [P12-T15] Check off AC-15 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T24 (non-vacuity), P6-T12.
- [ ] [P12-T16] Check off AC-16 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P6-T13.
- [ ] [P12-T17] Check off AC-17 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P7-T5, P7-T6, P7-T7.
- [ ] [P12-T18] Check off AC-18 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P5-T8, P6-T14, P7-T7, P10-T1, P11-T3.
- [ ] [P12-T19] Check off AC-19 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P11-T1.
- [ ] [P12-T20] Check off AC-20 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T13, P5-T9, P9-T10, P5-T8.
- [ ] [P12-T21] Check off AC-21 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P9-T1, P9-T2, P9-T4, P9-T5, P9-T6, P11-T4 (`Disposition: PASS`).
- [ ] [P12-T22] Check off AC-22 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P11-T2.
- [ ] [P12-T23] Check off AC-23 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P8-T4.
- [ ] [P12-T24] Verify and commit the check-off in `FEATURE/spec.md` and `FEATURE/issue.md`. Commands: `git grep -c -F -e "- [x] AC-" -- docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/issue.md`, then `git grep -c -F -e "- [ ] AC-" -- <the same two files>`; then CMD-GIT-ADD with FEATURE, CMD-GIT-COMMIT with message "docs(769): check off acceptance criteria", CMD-GIT-PUSH. Acceptance: the first search prints `spec.md:23` and `issue.md:23` (with their full paths); the second exits 1 with no output; CMD-GIT-STATUS prints nothing after the push.

---

## Acceptance Criteria Traceability

| AC | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| AC-1 | P2-T1, P2-T3, P2-T4 | P1-T2 (fail-before), P2-T9 | regression-testing/claude-routing-after-fix |
| AC-2 | P5-T1 | P4-T2 (fail-before), P5-T5 | regression-testing/codex-routing-after-fix |
| AC-3 | P2-T1, P5-T1 | P2-T9, P5-T5 | regression-testing/claude-routing-after-fix, codex-routing-after-fix |
| AC-4 | P2-T1, P5-T1 | P2-T9, P5-T5, P2-T12, P9-T11 | qa-gates/live-state-final |
| AC-5 | P2-T3, P5-T1 | P2-T9, P5-T5 | regression-testing/claude-routing-after-fix |
| AC-6 | P2-T3, P5-T1 | P2-T9, P5-T5 | regression-testing/codex-routing-after-fix |
| AC-7 | P2-T1, P5-T1 | P2-T9, P2-T10, P5-T5 | regression-testing/claude-existing-after-fix |
| AC-8 | P2-T1, P5-T1 | P2-T9, P5-T5 | regression-testing/claude-routing-after-fix |
| AC-9 | P2-T1, P5-T1 | P2-T10, P2-T11, P5-T6, P5-T8 | regression-testing/pretooluse-schema |
| AC-10 | P5-T1 | P5-T8 | regression-testing/codex-contracts |
| AC-11 | P1-T1, P4-T1, P2-T6, P5-T2 | P9-T12 | qa-gates/ac11-no-temp-files |
| AC-12 | P1-T1, P4-T1, P2-T6, P5-T2 | P2-T9, P2-T10, P5-T5, P5-T6 | regression-testing/codex-existing-after-fix |
| AC-13 | P2-T1, P5-T1, P6-T1..P6-T10, P7-T1..P7-T5 | P0-T22, P7-T9 | qa-gates/ac13-sweep |
| AC-14 | P6-T1..P6-T8 | P0-T23, P6-T11 | qa-gates/ac14-threshold |
| AC-15 | P6-T1..P6-T4 | P0-T24, P6-T12 | qa-gates/ac15-orchestrator-name |
| AC-16 | P6-T4 | P6-T13 | qa-gates/ac16-budget-input |
| AC-17 | P7-T3, P7-T5 | P7-T6, P7-T7 | qa-gates/codex-variants-check |
| AC-18 | P3-T2, P3-T4, P5-T7, P6-T9, P6-T10, P7-T4, P7-T5 | P3-T5, P5-T8, P6-T14, P7-T7, P10-T1, P11-T3 | qa-gates/mirror-hashes-final |
| AC-19 | (no write to the protected paths) | P11-T1 | qa-gates/ac19-policy-unchanged |
| AC-20 | P2-T3, P2-T6, P5-T2 | P2-T13, P5-T9, P9-T10 | qa-gates/line-counts-final |
| AC-21 | Phases 2 and 5 | P9-T1, P9-T2, P9-T4, P9-T5, P9-T6, P11-T4 | qa-gates/coverage-comparison |
| AC-22 | P2-T1, P2-T3, P5-T1 | P11-T2 | qa-gates/ac22-docstrings |
| AC-23 | P8-T1, P8-T2, P8-T3 | P8-T4 | other/follow-up-entries |

---

## Appendix A — Scratch Scripts

Scripts are written verbatim under SCRATCH by P0-T6 and never committed. A1, A4, A5, A6, A7, A8, and A12 are carried from the #762 plan; A2 and A3 extend the #762 versions with comma-separated path lists and, for A3, `HIT`/`MISSED`/report-file output.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param([Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
    $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
    $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 pssa-count.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A8 psd1-parse.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
foreach ($file in $Path) { $null = Import-PowerShellDataFile -LiteralPath $file; Write-Output "PSD1-OK file=$file" }
```

A9 checkpoint-probe.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
$checkpoint = Get-Content -Raw -LiteralPath $CheckpointPath | ConvertFrom-Json
Write-Output "ROUTE_ID=$($checkpoint.route_id)"
Write-Output "PATH_SELECTED=$($checkpoint.path_selected)"
Write-Output "NEXT_STEP=$($checkpoint.next_step)"
Write-Output "LIFECYCLE_READY=$($checkpoint.lifecycle_ready)"
Write-Output "ISSUE_NUM=$($checkpoint.'issue-num')"
```

A10 budget-state-probe.ps1 (read-only):

```powershell
$stateDirectory = '.claude/state'
if (-not (Test-Path -LiteralPath $stateDirectory)) { Write-Output 'STATE-SUMMARY files=0'; return }
$stateFiles = @(Get-ChildItem -LiteralPath $stateDirectory -Filter 'powershell-batch-budget.*.json' -File)
foreach ($stateFile in $stateFiles) {
    $state = Get-Content -Raw -LiteralPath $stateFile.FullName | ConvertFrom-Json
    $prodCount = @($state.prodFiles | Where-Object { $_ }).Count
    $testCount = @($state.testFiles | Where-Object { $_ }).Count
    Write-Output "STATE file=$($stateFile.Name) prodCount=$prodCount testCount=$testCount"
}
Write-Output "STATE-SUMMARY files=$($stateFiles.Count)"
```

A11 route-probe.ps1 (read-only; dot-sourcing the hook runs no entry point because of its `InvocationName` guard):

```powershell
param([Parameter(Mandatory)][string] $HookPath, [Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
. (Resolve-Path -LiteralPath $HookPath).Path
$checkpointText = Get-Content -Raw -LiteralPath $CheckpointPath
Write-Output "LARGE-PATH-ROUTE=$(Test-PowerShellBatchBudgetLargePathRoute -CheckpointText $checkpointText)"
Write-Output "SELECTED-ROUTE=$(Get-PowerShellBatchBudgetSelectedRoute -CheckpointText $checkpointText)"
```

A11b changed-line-coverage.ps1 (reads an A3 report file; lines absent at the base ref count as changed):

```powershell
param(
    [Parameter(Mandatory)][string] $CoverageReportPath,
    [Parameter(Mandatory)][string] $BaseRef,
    [Parameter(Mandatory)][string[]] $File
)
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$report = Get-Content -LiteralPath $CoverageReportPath
foreach ($target in $File) {
    $hitLine = $report | Where-Object { $_ -like "HIT file=$target Lines=*" } | Select-Object -First 1
    $missLine = $report | Where-Object { $_ -like "MISSED file=$target Lines=*" } | Select-Object -First 1
    if (-not $hitLine -or -not $missLine) { Write-Output "CHANGED-COVERAGE file=$target MISSING"; continue }
    $hit = @(($hitLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $miss = @(($missLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($diffLine in @(git diff -U0 $BaseRef -- $target)) {
            if ($diffLine -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
                $start = [int]$Matches[1]
                $count = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
                for ($offset = 0; $offset -lt $count; $offset++) { [void]$changed.Add($start + $offset) }
            }
        }
    } else {
        $lineCount = (Get-Content -LiteralPath $target).Count
        for ($lineNumber = 1; $lineNumber -le $lineCount; $lineNumber++) { [void]$changed.Add($lineNumber) }
    }
    $changedHit = @($hit | Where-Object { $changed.Contains($_) }).Count
    $changedMiss = @($miss | Where-Object { $changed.Contains($_) }).Count
    $analyzed = $changedHit + $changedMiss
    $percent = if ($analyzed -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit / $analyzed, 2) }
    Write-Output "CHANGED-COVERAGE file=$target ChangedLines=$($changed.Count) ChangedAnalyzed=$analyzed ChangedCovered=$changedHit ChangedPercent=$percent"
}
```

A `ChangedPercent=NA` value (no analyzable changed line) fails the P9-T6 threshold and is reported, not waived.

A12 json-parse.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
Write-Output "JSON-OK file=$Path"
```

A13 pair-hashes.ps1 (arguments: primary, mirror, primary, mirror, ...):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
if ($Path.Count % 2 -ne 0) { throw 'pair-hashes requires an even number of paths.' }
$unequal = 0
for ($index = 0; $index -lt $Path.Count; $index += 2) {
    $primary = $Path[$index]
    $mirror = $Path[$index + 1]
    $primaryHash = (Get-FileHash -LiteralPath $primary -Algorithm SHA256).Hash
    $mirrorHash = if (Test-Path -LiteralPath $mirror) { (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash } else { 'MISSING' }
    $equal = $primaryHash -eq $mirrorHash
    if (-not $equal) { $unequal++ }
    Write-Output "PAIR equal=$equal primary=$primary mirror=$mirror"
}
Write-Output "PAIR-SUMMARY pairs=$($Path.Count / 2) unequal=$unequal"
```

The P0-T6 smoke artifact lists these 14 file names: run-ps.sh, pester-counts.ps1, pester-coverage.ps1, line-counts.ps1, file-hashes.ps1, ps-format-check.ps1, pssa-count.ps1, psd1-parse.ps1, checkpoint-probe.ps1, budget-state-probe.ps1, route-probe.ps1, changed-line-coverage.ps1, json-parse.ps1, pair-hashes.ps1.

---

## Appendix B — Implementation and Test Specifications

### B1 — `.claude/hooks/enforce-powershell-batch-budget.ps1` (CHOOK)

Keep unchanged: `Test-PowerShellBatchBudgetPathInRoot`, `ConvertTo-PowerShellBatchBudgetSafeSegment`, `Get-PowerShellBatchBudgetSessionId`, `Get-PowerShellBatchBudgetBlockDecision` (name, parameters, deny shape), the `Import-Module` of `HookPayload.psm1`, the envelope fail-closed branch, the `file_path` and extension filters, `Invoke-PowerShellBatchBudgetEntryPoint`'s deny-only output and `state` stripping, and the top-level wiring (lines 444-457).

Changes:

1. **Docstring** (replaces lines 1-49). `.SYNOPSIS`: "Pre-tool-use hook that routes PowerShell changes of more than three production files to the orchestrated large path." `.DESCRIPTION` states, in plain sentences: direct mode counts distinct production PowerShell paths per session and denies the 4th with `POWERSHELL_LARGE_PATH_REQUIRED` and a routing instruction to `/orchestrate`; the large path is detected from `<root>/artifacts/orchestration/orchestrator-state.json` when the selected route (`route_id` when the key is present, otherwise `path_selected`, usable only as a non-blank string) is `large`, `remediation`, or `preparation` and the checkpoint is not terminal (`next_step` is not `complete`, `completed_steps` has no `S12_complete`); on the large path no path is denied for count and no state is written; every other checkpoint outcome enforces direct mode; test files (`tests/**/*.ps1`, `*.Tests.ps1`) are never counted; the threshold is a routing constant, not configurable at runtime; legacy `prodCap`, `testCap`, and `testFiles` state keys are ignored; the session-id resolution and containment paragraphs are kept (current lines 17-28); and a "Known limitation" paragraph: "A stale non-terminal large-path checkpoint left at the root exempts a later direct-mode session at that root. Orchestrator checkpoint hygiene (issue #673) moves foreign checkpoints aside before a new run." The docstring must not contain "per-batch", "deleting", "reset the", "new batch", "batch cap", or "split the work".
2. **Route functions** (Appendix B2), inline for P2-T1, moved to CROUTE by P2-T3 and P2-T4.
3. **`Get-PowerShellBatchBudgetState`**: parameters `[Parameter(Mandatory)][int] $ProdCap` and optional `[int] $TestCap = 0` with the D3 `SuppressMessageAttribute`; returns `[ordered]@{ prodCap = $ProdCap; prodFiles = @() }`.
4. **`ConvertTo-PowerShellBatchBudgetState`**: same `ProdCap`/optional `TestCap` (D3 attribute) and `Root`; builds the fresh state and copies only `prodFiles` through the existing containment filter; never reads `prodCap`, `testCap`, or `testFiles` from the input object.
5. **`Invoke-PowerShellBatchBudgetDecision`**: parameters `FilePath` (mandatory), `State` (mandatory), `[AllowEmptyString()][string] $StateFile = ''`, `Root` (unchanged default), `[switch] $LargePathRoute`, `[AllowEmptyString()][string] $ObservedRoute = ''`. Order: extension filter (allow, no write); out-of-root discard (allow, no write); if `LargePathRoute`, allow with `shouldWriteState = $false`; if the path is a test path (unchanged regex), allow with `shouldWriteState = $false`; if already in `prodFiles`, allow without write; if `@($State.prodFiles).Count -ge [int]$State.prodCap`, `Write-Verbose` a line naming `$StateFile`, then deny through `Get-PowerShellBatchBudgetBlockDecision -Reason <message> -State $State`; otherwise append to `prodFiles` and allow with `shouldWriteState = $true`. Message (with `<cap>` = `$State.prodCap`, `<counted>` = `prodFiles` joined by `, `, `<route>` = `$ObservedRoute` or `none` when blank): `POWERSHELL_LARGE_PATH_REQUIRED: this change touches more than <cap> production PowerShell files (already counted: <counted>; requested: <normalized path>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route>.`
6. **`Invoke-PowerShellBatchBudgetHook`**: drop `-TestCap`; keep `-ProdCap = 3` and every existing seam; add `[scriptblock] $ReadCheckpoint` whose default returns `Get-Content -LiteralPath $Path -Raw` when `Test-Path -LiteralPath $Path -PathType Leaf` is true and `''` otherwise. After the extension filter and after the session id and state-file path are computed, but before `TestPathExists`/`EnsureDirectory`: read `Join-Path -Path $Root -ChildPath 'artifacts/orchestration/orchestrator-state.json'` through `ReadCheckpoint` inside `try`/`catch` (any exception yields `''` and a `Write-Verbose` line); compute `$isLargePath = Test-PowerShellBatchBudgetLargePathRoute -CheckpointText $checkpointText` and `$observedRoute = Get-PowerShellBatchBudgetSelectedRoute -CheckpointText $checkpointText`. If `$isLargePath`, return `Invoke-PowerShellBatchBudgetDecision -FilePath $filePath -State (Get-PowerShellBatchBudgetState -ProdCap $ProdCap) -StateFile $stateFile -Root $Root -LargePathRoute` without calling `TestPathExists`, `EnsureDirectory`, `ReadState`, or `WriteState`. Otherwise continue as today, passing `-ObservedRoute $observedRoute` to the decision.
7. **`Invoke-PowerShellBatchBudgetEntryPoint`**: delete the `$prodCap`/`$testCap` block (current lines 426-433) and call `Invoke-PowerShellBatchBudgetHook -ToolInputRaw $ToolInputRaw -SessionId $sessionId`.
8. After P2-T4, the line `. (Join-Path $PSScriptRoot 'enforce-powershell-batch-budget-route.ps1')` follows the `Import-Module` line.

### B2 — Route functions (inline in CHOOK at P2-T1; CROUTE from P2-T3; inline in XHOOK)

CROUTE starts with a comment-based help block stating that it defines pure route helpers dot-sourced by CHOOK and has no entry point. Three advanced functions, each with comment-based help and `[CmdletBinding()]`, none reading files or environment variables:

- `ConvertFrom-PowerShellBatchBudgetCheckpoint` — `[OutputType([psobject])]`, parameter `[AllowNull()][AllowEmptyString()][string] $CheckpointText`. Returns `$null` when the text is null or whitespace; otherwise `ConvertFrom-Json -ErrorAction Stop` inside `try`/`catch` (a parse error returns `$null`); returns the parsed value only when it is a `[System.Management.Automation.PSCustomObject]`, otherwise `$null`.
- `Get-PowerShellBatchBudgetSelectedRoute` — `[OutputType([string])]`, same parameter. Parses via the function above (`$null` gives `''`). When the object has a `route_id` property (`$checkpoint.PSObject.Properties.Name -contains 'route_id'`), the raw value is `route_id`; otherwise it is `path_selected`. Returns the raw value when it is a `[string]` that is not null or whitespace; otherwise `''`.
- `Test-PowerShellBatchBudgetLargePathRoute` — `[OutputType([bool])]`, same parameter. Returns `$false` when parsing gives `$null`; `$false` unless the selected route is one of `large`, `remediation`, `preparation` by case-sensitive comparison (`@('large', 'remediation', 'preparation') -ccontains $route`); `$false` when `next_step` is a string equal (`-ceq`) to `complete`; `$false` when `@($checkpoint.completed_steps) -ccontains 'S12_complete'`; otherwise `$true`. The body is wrapped in `try`/`catch` returning `$false`, so no input causes an exception.

### B3 — CRTEST `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (47 cases)

Structure: `Set-StrictMode -Version Latest`; one `Describe 'enforce-powershell-batch-budget.ps1 large-path routing'`. `BeforeAll` dot-sources CHOOK (resolved from `$PSScriptRoot` as in CTEST line 10) and defines helpers `Get-RoutingToolInput -FilePath` (a `Write` envelope, as CTEST lines 14-21), `Initialize-RoutingStore [-PersistedText]` (sets `$script:RoutingStore = @{ Text = $PersistedText; Writes = 0; Ensures = 0; CheckpointReads = 0; CheckpointPath = '' }`), and `Invoke-RoutedHook -FilePath -CheckpointText` (sets `$script:RoutingCheckpointText`, then calls `Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-RoutingToolInput -FilePath $FilePath) -SessionId 'routing' -Root '/repo'` with seams: `ReadCheckpoint` increments `CheckpointReads`, records `CheckpointPath`, returns `$script:RoutingCheckpointText`; `TestPathExists` returns `$null -ne $script:RoutingStore.Text`; `EnsureDirectory` increments `Ensures`; `ReadState` returns `$script:RoutingStore.Text`; `WriteState` increments `Writes` and stores `$State | ConvertTo-Json -Compress -Depth 5` in `Text`). `BeforeEach` calls `Initialize-RoutingStore`. `AfterEach` sets `$env:CLAUDE_POWERSHELL_BUDGET_PROD` and `$env:CLAUDE_POWERSHELL_BUDGET_TEST` to `$null`. Seam parameters that a scriptblock does not use are consumed with `[void] $Path` as in CTEST. Helper verbs avoid `New`, `Set`, `Reset`, `Remove`, `Update` (PSUseShouldProcessForStateChangingFunctions). No file is created, read, or written; the only paths are the synthetic `/repo` and `C:/synthetic-absent-root`.

Context 'large-path route predicate' — one `It '<Name>'` over these 21 rows, asserting `Test-PowerShellBatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected`:

| # | Name | Text | Expected |
| --- | --- | --- | --- |
| 1 | route_id large | `{"route_id":"large","next_step":"S5_atomic_execution"}` | True |
| 2 | route_id remediation | `{"route_id":"remediation"}` | True |
| 3 | route_id preparation | `{"route_id":"preparation"}` | True |
| 4 | route_id small | `{"route_id":"small"}` | False |
| 5 | route_id blank | `{"route_id":"   "}` | False |
| 6 | route_id unknown | `{"route_id":"epic"}` | False |
| 7 | route_id wrong case | `{"route_id":"LARGE"}` | False |
| 8 | no route keys | `{"next_step":"S5_atomic_execution"}` | False |
| 9 | route_id null with path_selected large | `{"route_id":null,"path_selected":"large"}` | False |
| 10 | route_id non-string with path_selected large | `{"route_id":5,"path_selected":"large"}` | False |
| 11 | route_id small wins over path_selected large | `{"route_id":"small","path_selected":"large"}` | False |
| 12 | path_selected large without route_id | `{"path_selected":"large"}` | True |
| 13 | path_selected small without route_id | `{"path_selected":"small"}` | False |
| 14 | terminal next_step complete | `{"route_id":"large","next_step":"complete"}` | False |
| 15 | terminal S12_complete | `{"route_id":"large","completed_steps":["S11_pr_created","S12_complete"]}` | False |
| 16 | non-terminal completed steps | `{"route_id":"large","next_step":"S5_atomic_execution","completed_steps":["S4_atomic_planning"]}` | True |
| 17 | malformed JSON | `{not-json` | False |
| 18 | array JSON | `[1,2]` | False |
| 19 | string JSON | `"large"` | False |
| 20 | empty text | (empty string) | False |
| 21 | whitespace text | three spaces | False |

Context 'selected route' — 4 cases on `Get-PowerShellBatchBudgetSelectedRoute`: `{"route_id":"large","path_selected":"small"}` gives `large`; `{"route_id":null,"path_selected":"large"}` gives `''`; `{"path_selected":"remediation"}` gives `remediation`; `{not-json` gives `''`.

Context 'direct mode' — 6 cases through `Invoke-RoutedHook`:
- D1 'allows the first three distinct production paths and denies the 4th with no checkpoint': `scripts/a.ps1`, `scripts/b.psm1`, `scripts/c.psd1` allowed; `scripts/d.ps1` denied; checkpoint text `''`.
- D2 'denies the 4th distinct production path when the checkpoint route is small': same with `{"route_id":"small"}`.
- D3 'names the routing target, counted paths, requested path, and observed route': after D1's sequence with `{"route_id":"small"}`, the reason starts with `POWERSHELL_LARGE_PATH_REQUIRED:` (assert with `Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'`), contains `/orchestrate`, `scripts/a.ps1, scripts/b.psm1, scripts/c.psd1`, `requested: scripts/d.ps1`, and `Checkpoint route observed: small.`; with checkpoint `''` it contains `Checkpoint route observed: none.`.
- D4 'omits every prohibited remedy phrase and the state-file path from the deny reason': for each of `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, `deleting`, `powershell-batch-budget.`, `.claude/state`, the reason is not like `*<phrase>*`.
- D5 'allows a repeated production path without a state write': persisted text with `prodFiles` `["scripts/a.ps1"]`; request `scripts/a.ps1`; allow and `Writes` is 0.
- D6 'enforces direct mode for a terminal large-route checkpoint': persisted three production paths; checkpoint `{"route_id":"large","next_step":"complete"}`; `scripts/d.ps1` denied.

Context 'large path' — 5 cases:
- L1 '<Route> route allows six distinct production paths without a state write' over `large`, `remediation`, `preparation` (3 cases): six distinct production paths, each allowed; `Writes` and `Ensures` are both 0.
- L2 'the decision with LargePathRoute allows without recording': `Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/e.ps1' -State (Get-PowerShellBatchBudgetState -ProdCap 1) -Root '/repo' -LargePathRoute` with `prodFiles` already `["scripts/a.ps1"]`; allow, `shouldWriteState` false, `prodFiles` count 1.
- L3 'a path_selected-only large checkpoint allows the 4th production path': persisted three production paths; checkpoint `{"path_selected":"large"}`; `scripts/d.ps1` allowed; `Writes` 0.

Context 'test paths' — 2 cases:
- P1 'allows five distinct test paths in direct mode without recording them': `tests/scripts/a.Tests.ps1` through `tests/scripts/e.Tests.ps1` with checkpoint `''`; every decision allows; `Writes` is 0.
- P2 'allows a test path on the large path without a state write': `tests/scripts/a.Tests.ps1` with `{"route_id":"large"}`; allow; `Writes` and `Ensures` 0.

Context 'removed cap overrides' — 4 cases:
- O1 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path': persisted `{"prodCap":10,"testCap":10,"prodFiles":["scripts/a.ps1","scripts/b.ps1","scripts/c.ps1"],"testFiles":["tests/scripts/x.Tests.ps1"]}`; checkpoint `''`; `scripts/d.ps1` denied with the `POWERSHELL_LARGE_PATH_REQUIRED:` prefix and no exception.
- O2 'ignores CLAUDE_POWERSHELL_BUDGET_PROD and _TEST set in the test scope': sets both variables to `10`; persisted three production paths; `scripts/d.ps1` denied.
- O3 'the hook sources contain no CLAUDE_POWERSHELL_BUDGET reference': `Get-Content -Raw` of CHOOK and of every `enforce-powershell-batch-budget*.ps1` sibling in the same directory is not like `*CLAUDE_POWERSHELL_BUDGET*` (read-only).
- O4 'a fresh state carries no test-file keys': `(Get-PowerShellBatchBudgetState -ProdCap 3).Contains('testFiles')` and `.Contains('testCap')` are both false.

Context 'checkpoint seam' — 5 cases:
- S1 'the default reader yields direct mode when the checkpoint file is absent': `Invoke-PowerShellBatchBudgetHook` with `-Root 'C:/synthetic-absent-root'`, no `ReadCheckpoint` argument, in-memory state seams holding three production paths; `scripts/d.ps1` denied with the new prefix.
- S2 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root': after one call, `($script:RoutingStore.CheckpointPath -replace '\\', '/')` is `/repo/artifacts/orchestration/orchestrator-state.json`.
- S3 'treats a throwing checkpoint reader as direct mode without raising': a `ReadCheckpoint` that throws; persisted three production paths; `scripts/d.ps1` denied; `{ ... } | Should -Not -Throw` around the call.
- S4 'still denies an unreadable envelope when the checkpoint route is large': `-ToolInputRaw ''` with `ReadCheckpoint` returning `{"route_id":"large"}`; deny with a reason like `*empty payload*`.
- S5 'does not read the checkpoint for a non-PowerShell path': `README.md`; allow; `CheckpointReads` is 0.

Count: 21 + 4 + 6 + 5 + 2 + 4 + 5 = 47.

### B4 — XRTEST `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (49 cases)

Structure as B3, with `#Requires -Version 7.0` and the Pester `#Requires` line of XTEST lines 1-2, dot-sourcing XHOOK from `$PSScriptRoot/../../../.codex/hooks`. Helpers: `Get-CodexRoutingToolInput -FilePath` returns `@{ file_path = $FilePath } | ConvertTo-Json -Compress`; `Initialize-CodexRoutingStore`; `Invoke-CodexRoutedHook -FilePath -CheckpointText` calling the Codex `Invoke-PowerShellBatchBudgetHook -ToolInputRaw ... -SessionId 'routing' -Root '/repo'` with the same five seams as B3; `Get-CodexRoutingPayload -FilePath [-SessionId 'routing-entry']` returns a `Write` payload `{"session_id":...,"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":...,"content":"x"}}`.

- Route predicate: the same 21 rows as B3 against the Codex `Test-PowerShellBatchBudgetLargePathRoute`.
- Selected route: the same 4 cases.
- Direct mode: D1, D2, D3, D5, D6 as B3; D3 asserts `.codex/prompts/orchestrate-work.md` in place of `/orchestrate`; D4 as B3 with `.codex/state` in place of `.claude/state` (6 cases).
- Large path: L1 (3), L2 (without `-Root`, the Codex decision has no containment parameter), L3 (5 cases).
- Test paths: P1, P2 (2 cases).
- Overrides (3): O1 as B3; O2 'a fresh state carries no test-file keys'; O3 'ConvertTo state ignores persisted prodCap, testCap, and testFiles': `ConvertTo-PowerShellBatchBudgetState -InputObject ('{"prodCap":10,"testCap":10,"prodFiles":["a.ps1"],"testFiles":["b.Tests.ps1"]}' | ConvertFrom-Json) -ProdCap 3` gives `prodCap` 3, `prodFiles` containing `a.ps1`, and no `testFiles` key.
- Seam (5): S1, S2, S3, S5 as B3; S4 'still denies malformed tool_input JSON when the checkpoint route is large': `-ToolInputRaw 'not json'` with a large checkpoint; deny with a reason like `*malformed JSON*`.
- Entry point (3), using `Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw <payload> -RepositoryRoot '/repo' -HookSeams <hashtable of the five seams>`:
  - E1 'allows a Write payload for a production path under a large-route checkpoint without output or state write': result array has one element, `[int]` 0; `Writes` and `Ensures` 0.
  - E2 'emits a deny envelope without a state property for the 4th production path in direct mode': persisted three production paths, checkpoint `''`, payload for `scripts/d.ps1`; the last element is 0; the preceding element parses as JSON with `permissionDecision` `deny`, a reason like `POWERSHELL_LARGE_PATH_REQUIRED:*`, and no `state` property.
  - E3 'returns exit code 2 and writes stderr for an empty payload': `-PayloadRaw ''` with `[System.Console]::SetError` redirected to a `StringWriter` and restored in `finally` (as XTEST lines 50-65); the returned value is 2 and the captured stderr matches `enforce-powershell-batch-budget hook input is empty`.

Count: 21 + 4 + 6 + 5 + 2 + 3 + 5 + 3 = 49.

### B5 — CTEST edits (`tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`)

All line numbers below refer to the file as it stands before P2-T6 (495 lines); apply the edits from the bottom of the file upward so earlier numbers stay valid.

1. In `BeforeAll`, after line 29, add one line: `$script:NoCheckpoint = { param([string] $Path) [void] $Path; '' }`.
2. On each of the 11 `Invoke-PowerShellBatchBudgetHook` calls that pass a PowerShell file path and reach the state path (the calls beginning at lines 188, 211, 226, 260, 276, 293, 309, 320, 331, 347, 413), change the existing `-Root '/repo' `` line to `-Root '/repo' -ReadCheckpoint $script:NoCheckpoint `` (same line; no line is added). The 11 edits make these cases independent of any checkpoint on the host.
3. Replace the case at lines 63-72 with 'allows a Pester test file without recording it': decision allows, `shouldWriteState` false, `prodFiles` empty.
4. Replace the assertions at lines 93-94 with `Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'` and `Should -BeLike '*scripts/second.ps1*'`.
5. Replace the case at lines 98-107 with 'does not count a test file toward the production threshold': state `-ProdCap 1` with `prodFiles` `@('scripts/first.ps1')`; `tests/scripts/second.Tests.ps1` allowed without a state write.
6. Replace line 146 with `$result.state.Contains('testFiles') | Should -BeFalse`.
7. At lines 484-493, rename the case to 'returns exit code 0 for malformed JSON with a non-default session variable set' and delete lines 486-487; delete lines 35-36 from `AfterEach`.

The file keeps 36 cases and stays at most 500 lines (P2-T13).

### B6 — XHOOK `.codex/hooks/enforce-powershell-batch-budget.ps1`

Mirror B1 semantics with these Codex specifics: keep the leading blank line and the dot-source of `codex-pretooluse-file-mapping.ps1`; docstring as B1 with "Codex session", state under `.codex/state/`, routing target `.codex/prompts/orchestrate-work.md`, and the same "Known limitation" paragraph naming issue #673; B2 route functions inline; `Get-PowerShellBatchBudgetState` and `ConvertTo-PowerShellBatchBudgetState` per B1 items 3-4 without containment (no `Root` parameter on ConvertTo); `Invoke-PowerShellBatchBudgetDecision` per B1 item 5 without the `Root` parameter and the out-of-root branch, with the routing sentence `Route the change through .codex/prompts/orchestrate-work.md.`; `Invoke-PowerShellBatchBudgetHook` keeps `SessionId = 'default'`, `Root = (Get-Location).Path`, `ProdCap = 3`, the four state seams, the empty-input allow, and the malformed-JSON deny, drops `TestCap`, and adds `ReadCheckpoint` with the B1 item 6 flow (checkpoint read after the extension filter; large path returns before `TestPathExists`/`EnsureDirectory`). New `Invoke-PowerShellBatchBudgetCodexEntryPoint` (D5) holds the current top-level body (lines 223-255): `ConvertFrom-CodexPreToolUsePayload ... -RequireSessionId`, session sanitizing, both-sides-of-a-rename path collection, one hook call per path with `-Root $RepositoryRoot @HookSeams`, deny output with `state` removed followed by `return 0`, `return 0` when nothing denies, and a `catch` that writes `[string]$_` to `[Console]::Error` and returns 2. Top-level wiring after the `InvocationName` guard: `$entryPointResult = @(Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()) -RepositoryRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))`, write all elements except the last, then `exit ([int]$entryPointResult[-1])`. No `$env:CLAUDE_` read.

### B7 — XTEST edits (`tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`)

All line numbers below refer to the file as it stands before P5-T2.

1. Add `ExtraSeams = @{}` to the Python row and `ExtraSeams = @{ ReadCheckpoint = { param([string] $Path) [void] $Path; '' } }` to the PowerShell row of the `-ForEach` at lines 69-88.
2. Append ` @ExtraSeams` to the `Invoke-...BatchBudgetHook` calls at lines 238, 259, 292, and 306 (same line), so the PowerShell row never reads a host checkpoint.
3. Move the seven cases at lines 103-110, 112-121, 123-130, 167-176, 178-185, 187-195, and 267-281 unchanged into a new `Context 'the Python batch-budget hook cap contract' -ForEach @(<the Python row hashtable>)` with its own `BeforeAll` setting `$script:HookPath`, `$script:NewState`, `$script:ConvertState`, `$script:DecisionFn`, and `$script:HookFn` as lines 90-95 do; the case at lines 267-281 passes `@ExtraSeams` as well.
4. Update the header comment (lines 4-19) to state that the PowerShell routing and cap cases live in `codex-powershell-batch-budget-routing.Tests.ps1`.

Result: 17 shared cases times 2 rows plus 7 Python-only cases, 41 in total.

---

## Appendix C — Text Surface Edits

Every edit replaces the named line's full text with the new text shown, changes nothing else in the file, and uses ASCII hyphens (`1-3`, never an en dash). Line numbers refer to each file as it stands before its Phase 6 or Phase 7 edit task; apply a file's edits from the highest line number downward so deletions do not shift the remaining targets.

C1 `.claude/rules/powershell.md` — replace lines 39-41 with three lines:
- `- Direct-mode scope: 1-3 production PowerShell files (plus corresponding tests). A change that touches more than 3 production PowerShell files belongs on the orchestrated large path: route it through \`/orchestrate\` (the \`orchestrator\` agent) per \`powershell-change-budget-router\`.`
- `- The orchestrated large path has no production-file cap. Test files are not counted toward the routing threshold.`
- `- \`.claude/hooks/enforce-powershell-batch-budget.ps1\` enforces the threshold outside the large path: it denies the 4th distinct production PowerShell file with a routing instruction.`

C2 `.claude/skills/powershell-change-budget-router/SKILL.md`:
- line 8: `Canonical guidance for deciding whether work should execute directly in \`powershell-typed-engineer\` or be escalated to the orchestrated large path through \`/orchestrate\` (the \`orchestrator\` agent).`
- line 21: `- \`1-3\` production files (+ corresponding tests) → **small path** (\`powershell-typed-engineer\` direct mode).`
- line 22: `- More than 3 production files → **large path** (\`/orchestrate\`, the \`orchestrator\` agent). The large path has no production-file cap.`
- line 26: `When routed through \`/orchestrate\`, small path still requires lifecycle scaffolding before implementation:`
- line 39: `If \`powershell-typed-engineer\` is invoked directly and estimated scope is more than 3 production files:`
- line 41: `- Return explicit routing instruction to invoke \`/orchestrate\`.`

C3 `.claude/agents/powershell-typed-engineer.md`:
- line 4: `description: Project-scoped worker that implements and verifies PowerShell changes within typed repository boundaries. Applies PoshQC format -> PSScriptAnalyzer -> Pester toolchain, the 1-3 production-file direct-mode budget with routing to the orchestrated large path above it, and zero-regression quality gates.`
- line 39: `2. **Routing and scope** — apply \`powershell-change-budget-router\` to estimate scope and select direct mode (1-3 production files) vs large-path escalation through \`/orchestrate\`. The large path has no production-file cap.`
- line 49: `- **Direct mode** (default, no directive present): strict 1-3 production PowerShell files cap. If the estimated scope exceeds 3 production files, stop and instruct the caller to invoke \`/orchestrate\` per \`powershell-change-budget-router\`.`
- line 67: `- the scope estimate exceeds the 3-production-file cap in direct mode,`
- line 68: delete.

C4 `.claude/skills/invoke-powershell-engineer/SKILL.md`:
- line 3: `description: Invoke the powershell-typed-engineer worker to design, implement, and verify PowerShell changes within typed repository boundaries. Applies PoshQC format -> analyze -> test toolchain, the 1-3 production-file direct-mode budget with routing to the orchestrated large path above it, and zero-regression quality gates.`
- line 15: `- Estimated scope fits the direct-mode path (1-3 production PowerShell files plus corresponding tests).`
- line 18: `If the estimated scope exceeds the direct-mode budget, this skill defers to the orchestrated large path (\`/orchestrate\`) via \`powershell-change-budget-router\` instead of proceeding directly.`
- line 26: delete.

C5 `.github/skills/powershell-change-budget-router/SKILL.md`:
- line 21: `- \`1-3\` production files (+ corresponding tests) → **small path** (\`powershell-typed-engineer\` direct mode).`
- line 22: `- More than 3 production files → **large path** (\`powershell-orchestrator\`). The large path has no production-file cap.`
- line 39: `If \`powershell-typed-engineer\` is invoked directly and estimated scope is more than 3 production files:`

C6 `.github/agents/powershell-typed-engineer.agent.md`:
- line 52: `  - Intended scope: 1-3 production PowerShell files (+ corresponding tests).`
- line 53: `  - If estimated scope is more than 3 production files: stop and instruct caller to use \`powershell-orchestrator\` (or \`.github/prompts/orchestrate-powershell-work.prompt.md\`).`
- line 118: `- **Direct mode** default scope is one small feature/bug slice (typically **1-3 production PowerShell files**) plus corresponding test file(s).`
- line 119: `- In **Direct mode**, if estimated scope exceeds **3 production PowerShell files**, do not continue implementation; instruct the user to invoke \`powershell-orchestrator\` (or \`.github/prompts/orchestrate-powershell-work.prompt.md\`) and stop.`
- line 120: `- In **Orchestrator handoff mode**, overall scope may exceed 3 production files when supported by provided context package and approved plan artifacts.`
- line 130: `- **Direct mode** overall budget: **1-3 production PowerShell files** (+ corresponding tests).`
- lines 132-134: replace with the single line `- Test files are not counted toward the routing threshold in any mode, and the large path has no production-file cap.`
- line 198: `  - in direct mode, if estimated scope is more than 3 production PowerShell files, STOP and instruct user to invoke \`powershell-orchestrator\` for orchestration.`

C7 `.github/agents/powershell-orchestrator.agent.md`:
- line 17: the prompt text changes only `(1-2 production PowerShell files` to `(1-3 production PowerShell files`.
- line 101: `- If estimate is \`1-3\` production PowerShell files (+ corresponding tests), use **small path**.`
- line 102: `- If estimate is more than 3 (\`>3\`) production PowerShell files, use **large path**. The large path has no production-file cap.`
- line 126: `   - **Small path**: budget \`1-3\``
- line 127: `   - **Large path**: budget \`>3\``
- line 131: `## Small path (budget 1-3 production PowerShell files)`
- line 248: `## Large path (budget >3 production PowerShell files)`

C8 `.github/prompts/orchestrate-powershell-work.prompt.md`:
- line 24: `2. If budget is **1-3 production PowerShell files** (+ corresponding tests):`
- line 26: `3. If budget is **more than 3 production PowerShell files**:`

C9 `.agents/skills/powershell/SKILL.md` — keep line 36 (deferred threshold text); replace lines 37-38 with the single line `- The orchestrated large path has no production-file cap, and test files are not counted toward the routing threshold.`

C10 `.agents/skills/invoke-powershell-engineer/SKILL.md` line 3: `description: Invoke the powershell-typed-engineer worker to design, implement, and verify PowerShell changes within typed repository boundaries. Applies PoshQC formatting, analysis, and testing with a one-to-two production-file direct-mode budget and zero-regression quality gates.`

C11 `.codex/agents/powershell-typed-engineer.toml`:
- line 32: `description: Project-scoped worker that implements and verifies PowerShell changes within typed repository boundaries. Applies PoshQC format -> PSScriptAnalyzer -> Pester toolchain, the 1-2 production-file direct-mode budget, and zero-regression quality gates.`
- line 67: remove the trailing sentence `Enforce the 3 production + 3 test per-batch cap in all modes.` and append ` The large path has no production-file cap.` in its place.
- line 96: delete.

---

## Appendix D — Follow-up Potential Entries

Each entry uses the headings `# <slug> (Potential Bug)`, a metadata list (`- Date captured: 2026-09-29`, `- Author: Dan Moisan`, `- Status: Draft`, `- Related: #769`), then `## Summary`, `## Scope`, `## Acceptance Criteria (early draft)`, `## Constraints & Risks`, and `## Next Step` (unchecked items: promote through the MCP promotion tool; create the active feature folder). No `gh` command is run.

- D1 `docs/features/potential/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness.md`: the Python hooks `.claude/hooks/enforce-python-batch-budget.ps1` (message at line 293) and `.codex/hooks/enforce-python-batch-budget.ps1` (line 137) follow the session-keyed per-batch pattern fixed for PowerShell by #769; scope includes both bundle copies, `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`, the Python row of `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1:227-231`, and the Python text surfaces (`python-change-budget-router`, `invoke-python-engineer`, `python-typed-engineer` on every runtime, with mirrors). Draft criteria mirror #769 AC-1 through AC-8 and AC-13 for Python.
- D2 `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md`: per-batch text on `csharp-change-budget-router` (`.claude`, `.agents`), `.claude/agents/csharp-typed-engineer.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.codex/agents/csharp-typed-engineer*.toml`, and the csharp-legacy variants under `extensions/drm-copilot/resources/claude-customizations/.claude-variants/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/`, with mirrors. Draft criterion: a case-insensitive search for the #769 AC-13 phrases returns no match in C#-scoped surfaces.
- D3 `docs/features/potential/2026-09-29-codex-routing-resolver-powershell-budget-two.md`: the Codex topology resolver pins a PowerShell `max_production_files` of 2 (`config/orchestration-routing.json:229-234` and its two bundled copies, `scripts/dev_tools/resolve_codex_topology.py:76-80`, `.claude/lib/codex-routing/CodexTopology.psm1:72` and its bundle copies, `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`), with the parity fixtures and tests listed in research Section 3.3, and the Codex/`.agents` threshold text deferred by #769 (`.agents/skills/powershell-change-budget-router/SKILL.md`, the `1-2`/"one-to-two" clauses of `.agents/skills/powershell/SKILL.md` and `.agents/skills/invoke-powershell-engineer/SKILL.md`, `.agents/skills/codex-model-routing/SKILL.md`, `.codex/agents/powershell-orchestrator.toml`, and the `1-2`/`2` clauses of `.codex/agents/powershell-typed-engineer*.toml`). Draft criterion: the resolver and its three runtimes route a 3-file PowerShell change to the small path, with parity fixtures updated.

---

## Appendix E — Mirror Pairs (primary, then mirror)

1. `.claude/hooks/enforce-powershell-batch-budget.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
2. `.codex/hooks/enforce-powershell-batch-budget.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`
3. `.claude/rules/powershell.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md`
4. `.claude/skills/powershell-change-budget-router/SKILL.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-change-budget-router/SKILL.md`
5. `.claude/agents/powershell-typed-engineer.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`
6. `.claude/skills/invoke-powershell-engineer/SKILL.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`
7. `.github/skills/powershell-change-budget-router/SKILL.md` / `extensions/drm-copilot/resources/customizations/.github/skills/powershell-change-budget-router/SKILL.md`
8. `.github/agents/powershell-typed-engineer.agent.md` / `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md`
9. `.github/agents/powershell-orchestrator.agent.md` / `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md`
10. `.github/prompts/orchestrate-powershell-work.prompt.md` / `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-powershell-work.prompt.md`
11. `.agents/skills/powershell/SKILL.md` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell/SKILL.md`
12. `.agents/skills/invoke-powershell-engineer/SKILL.md` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`
13. `.codex/agents/powershell-typed-engineer.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml`
14. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` / `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
15. `.codex/hooks/codex-pretooluse-file-mapping.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-pretooluse-file-mapping.ps1` (unchanged dependency of XHOOK)

P11-T3 adds pair 16: `.claude/hooks/enforce-powershell-batch-budget-route.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`.

## Appendix F — Python Parity Suites

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`, `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, `tests/scripts/dev_tools/test_blast_radius_token_shapes.py`, `tests/scripts/dev_tools/test_resolve_codex_topology.py` (the last confirms the deferred resolver value is untouched).

## Appendix G — Search Commands

AC-13 search (tracked PowerShell-path surfaces and their mirrors; git pathspec `*` matches across `/`; the exclusion of `.github/agents/Powershell DI Unit Test Engineer.agent.md` is structural, because its capitalized name does not match the case-sensitive `*powershell*` pathspec):

```text
git grep -n -i -F -e "per-batch" -e "batch cap" -e "smaller batches" -e "split the work" -e "new batch" -e "three-test" -- ".claude/*powershell*" ".agents/*powershell*" ".codex/*powershell*" ".github/agents/*powershell*" ".github/skills/*powershell*" ".github/prompts/*powershell*" "extensions/drm-copilot/resources/claude-customizations/.claude/*powershell*" "extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/*powershell*" "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/*powershell*" "extensions/drm-copilot/resources/customizations/.github/agents/*powershell*" "extensions/drm-copilot/resources/customizations/.github/skills/*powershell*" "extensions/drm-copilot/resources/customizations/.github/prompts/*powershell*"
```

The eight AC-14 files are `.claude/skills/powershell-change-budget-router/SKILL.md`, `.github/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/skills/invoke-powershell-engineer/SKILL.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/powershell-orchestrator.agent.md`, and `.github/prompts/orchestrate-powershell-work.prompt.md`.

AC-14 negative search: `git grep -n -F -e "1-2" -e "1–2" -e ">2" -e "2 production" -e "up to 2" -e "2-production" -- <the eight AC-14 files>`.

AC-14 positive search: `git grep -c -F -e "1-3" -- <the eight AC-14 files>`.

The four AC-15 files are `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, and `.claude/skills/invoke-powershell-engineer/SKILL.md`.

AC-15 negative search: `git grep -n -F -e "powershell-orchestrator" -- <the four AC-15 files>`.

AC-15 positive search: `git grep -c -F -e "/orchestrate" -- <the four AC-15 files>`.

When running these, the executor substitutes the file lists literally; the angle-bracket forms above are documentation shapes, not commands.
