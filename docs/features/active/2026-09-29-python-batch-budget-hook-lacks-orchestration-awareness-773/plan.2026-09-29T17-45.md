# python-batch-budget-hook-lacks-orchestration-awareness (Plan)

- **Issue:** #773
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T20-15
- **Status:** Draft (revision 1.1; executor preflight round 1 deltas applied to P1-T4, P4-T2 and PD6, and P0-T24 with CMD-TS-CI; pending validator and executor preflight round 2)
- **Version:** 1.1
- **Work Mode:** full-bug (`spec.md` is the acceptance-criteria source, AC-1 through AC-29; no `user-story.md`)
- **Branch:** `bug/python-batch-budget-hook-lacks-orchestration-awareness-773`
- **Research:** `research/2026-09-29T18-00-python-batch-budget-routing-research.md`
- **Structural precedent:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/plan.2026-09-29T13-19.md` (cleared preflight at revision 1.2)

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Recap

The approved spec and the research artifact define the change:

1. Replace the PowerShell-named Claude route helper with one language-neutral helper per runtime (`.claude/hooks/enforce-batch-budget-route.ps1`, `.codex/hooks/enforce-batch-budget-route.ps1`, byte-identical), loaded by all four batch-budget hooks, with a parity suite binding the two copies. The Codex PowerShell hook loses its inline route helpers. PowerShell hook behavior does not change.
2. Make both Python batch-budget hooks large-path aware through an injectable `ReadCheckpoint` seam: on a non-terminal `large`, `remediation`, or `preparation` route no Python path is denied for count and no state is touched; in direct mode only distinct production Python paths are counted and the 4th is denied with the `PYTHON_LARGE_PATH_REQUIRED` routing message. Remove the test-file cap, the `CLAUDE_PYTHON_BUDGET_*` override, and the persisted cap overlay. Add `Invoke-PythonBatchBudgetCodexEntryPoint`.
3. Update pack manifests, both `pester.runsettings.psd1` copies, `$script:SharedModuleNames`, and every bundle mirror.
4. Replace per-batch, batching, override, and approval-based scope-expansion text on the Python text surfaces with the routing rule; remove the test-file routing clause from the three Python orchestration surfaces; remove the `budget:` input from `.agents/skills/invoke-powershell-engineer/SKILL.md`; regenerate the Codex variants.
5. Record two follow-up potential entries (AC-29).

Out of scope (spec, Out of scope / Explicitly excluded): `python-execution-only-typed`; the language-generic orchestrator surfaces; the Codex topology resolver; the D2 test-classification rule; C# hooks and text; the #769 triple-parse Nit; a runtime `Test-Path` guard for the helper; `.claude/settings.json`, `.codex/config.toml`, `scripts/powershell/Publish-DrmCopilotExtension.ps1`; `.github/copilot-instructions.md` and `.github/instructions/*`; every `.py` file; the orchestrator checkpoint.

### Current-tree facts this plan relies on (verified 2026-09-29 by reading the files)

- `.claude/hooks/enforce-python-batch-budget.ps1` is 454 lines: docstring lines 1-46; `Import-Module` of `HookPayload.psm1` at line 51; state functions lines 173-225 (persisted cap overlay lines 211-212); decision function lines 251-304 (deny message line 293); `Invoke-PythonBatchBudgetHook` lines 306-385; entry point lines 387-439 (env override block lines 423-430); top-level wiring lines 441-454.
- `.codex/hooks/enforce-python-batch-budget.ps1` is 254 lines: leading blank line 1; docstring lines 2-33; dot-source of `codex-pretooluse-file-mapping.ps1` line 39; overlay lines 75-76; deny message line 137; top-level try/catch lines 221-254 reading `[Console]::In.ReadToEnd()` at line 224 with `-RequireSessionId`.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` is 486 lines: line 62 imports `HookPayload.psm1`; line 63 is `. (Join-Path $PSScriptRoot 'enforce-powershell-batch-budget-route.ps1')`; lines 395-396 call `Test-PowerShellBatchBudgetLargePathRoute` and `Get-PowerShellBatchBudgetSelectedRoute`.
- `.claude/hooks/enforce-powershell-batch-budget-route.ps1` is 137 lines and defines `ConvertFrom-PowerShellBatchBudgetCheckpoint` (line 16), `Get-PowerShellBatchBudgetSelectedRoute` (line 53), and `Test-PowerShellBatchBudgetLargePathRoute` (line 92).
- `.codex/hooks/enforce-powershell-batch-budget.ps1` is 461 lines: line 51 dot-sources `codex-pretooluse-file-mapping.ps1`; line 52 is blank; lines 53-174 are the three inline route functions; line 175 is blank; lines 351-352 call the two route functions; `Invoke-PowerShellBatchBudgetCodexEntryPoint` lines 384-448; `[Console]::In.ReadToEnd()` at line 456.
- `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` is 485 lines with 35 `It` blocks: `BeforeAll` ends at line 32 (line 31 is the last statement); `AfterEach` lines 34-39 clear `CLAUDE_PYTHON_BUDGET_*` at lines 37-38; the test-path-recorded case is lines 53-62; the production deny assertion is line 83; the test-cap deny case is lines 88-97 followed by blank line 98; line 136 asserts a loaded `testFiles` entry.
- `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` is 371 lines, 41 tests (17 shared cases times 2 rows plus 7 Python-only): Python row `ExtraSeams = @{}` at line 80; PowerShell row seam at line 90; header comment lines 4-21 (line 5 contains "per-batch"; lines 10-13 describe the Python-only Context); shared Context closes at line 274; line 275 is blank; the Python-only Context is lines 276-370; line 371 closes the Describe.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is 497 lines; `$script:SharedModuleNames` is the single line 30; lines 96-142 run the parse, 500-line, byte-identity, no-`$env:CLAUDE_`, and core-manifest checks over `StaticCheckNames`; lines 227-231 call `Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1` and `Invoke-PythonBatchBudgetDecision ... -StateFile`.
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (353 lines, 47 tests) calls the PowerShell-named helpers at lines 125 and 136; `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (382 lines, 49 tests) at lines 136 and 147. `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` has 36 tests.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 32 lists `.claude/hooks/enforce-powershell-batch-budget-route.ps1`; line 137 lists `.codex/hooks/enforce-powershell-batch-budget.ps1`. The bundled copy under `extensions/drm-copilot/resources/powershell/PoshQC/settings/` carries the same lines.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json` line 9 lists the old helper; `.../claude-customizations/pack-manifests/core.json` line 25 is `".claude/hooks/enforce-checkpoint-monotonic.ps1",`; `.../codex-and-agents-customizations/pack-manifests/core.json` line 50 is `".codex/hooks/check-python-test-purity.ps1",` and line 51 is `".codex/hooks/enforce-checkpoint-monotonic.ps1",`.
- `scripts/dev_tools/generate_codex_agent_variants.py` rewrites the Codex base alias and variants (newline-preserving) and rewrites every Codex pack manifest with `write_text` (lines 259-267), preserving existing `paths` and appending required family paths (lines 195-218). Under `core.autocrlf=true` this produced CRLF-only manifest changes during #769 (`docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/other/codex-variants-regenerated.2026-09-29T14-39.md`).
- `.gitignore` ignores `/artifacts`, `.claude/agent-memory`, `.claude/state/`, and `.codex/state/`; `.codex/` and `.agents/` are tracked.
- `artifacts/orchestration/orchestrator-state.json` carries `"path_selected": "large"` (line 7), `"route_id": "large"` (line 8), and `"issue-num": 773` (line 14). The orchestrator sets `lifecycle_ready: true` before execution.
- `extensions/drm-copilot/run-jest.cjs` forwards arguments to Jest; `extensions/drm-copilot/jest.config.cjs` sets `collectCoverage: false`, so a single-file Jest run applies no coverage threshold.
- `extensions/drm-copilot/node_modules` is absent in this worktree; P0-T24 installs it with CMD-TS-CI. `extensions/drm-copilot/package-lock.json` is tracked, `extensions/drm-copilot/package.json` declares no `preinstall`, `install`, `postinstall`, or `prepare` script, and `.gitignore` line 3 (`node_modules`) ignores the installed tree at any depth.

### Plan decisions (resolutions of spec latitude, recorded for review)

- **PD1 — Rename order.** Research Section 8 is followed exactly: create the new Claude helper (P1-T1); add its dot-source beside the old one (P1-T2); switch the call sites (P1-T3); remove the old dot-source (P1-T5); probe (P1-T6); only then delete the old helper and its bundle copy with `git rm` (P1-T15). The live Claude PowerShell hook loads a route helper at every step.
- **PD2 — Codex helper by copy.** `.codex/hooks/enforce-batch-budget-route.ps1` is created by `cp` from the formatted Claude helper (P4-T3), so byte identity holds by construction; the parity suite then asserts it.
- **PD3 — Threshold and `TestCap` placement.** The threshold stays state-based as in #769: `-ProdCap` (default 3) on the hook function feeds `state.prodCap`, and the decision reads `$State.prodCap`. Per spec "Functions/classes/CLI commands impacted", `Get-PythonBatchBudgetState`, `ConvertTo-PythonBatchBudgetState`, and `Invoke-PythonBatchBudgetDecision` accept an optional, ignored `[int] $TestCap = 0` carrying `[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'TestCap', Justification = 'Accepted and ignored for callers written against the removed test-file cap.')]`. `Invoke-PythonBatchBudgetHook` drops `-TestCap` (after the entry points change, no caller passes it).
- **PD4 — `-StateFile`** on the decision function becomes `[AllowEmptyString()][string] $StateFile = ''` and appears only in a `Write-Verbose` line on the deny branch.
- **PD5 — Existing Claude Python suite determinism.** Per spec Test Strategy, `BeforeAll` sets a default empty reader through `$PSDefaultParameterValues`. PowerShell evaluates a scriptblock value stored in `$PSDefaultParameterValues` and binds its result, so the stored value is a scriptblock that returns the reader scriptblock (double braces). An `AfterAll` removes the key so the default does not outlive the suite.
- **PD6 — Parity fail-before signal.** Pester 5.6.1 counts tests under a failed `BeforeAll` in `FailedCount` but reports their `ExpandedPath` with the unexpanded block template (`the <Runtime> route helper`). P4-T2 therefore asserts exact counts (55/27/28) and matches `<Runtime>` or `Codex`, observed at preflight.
- **PD7 — Direct-mode fallback coverage.** The Python routing suites run a nine-row direct-mode fallback table per hook (AC-5, AC-6); the 21-row route predicate table runs once per helper copy in the parity suite (AC-14).
- **PD8 — Manifest commit before regeneration.** The Codex core manifest edit is committed in Phase 4, so the generator's CRLF-only manifest rewrite in Phase 8 can be restored with `git checkout --` without losing the helper entry.
- **PD9 — Follow-ups.** Two entries (spec Follow-ups 1 and 2). The `.agents/skills/invoke-powershell-engineer/SKILL.md` residual is in scope (spec In scope item 9, P8-T3), not a follow-up.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`.
- BRANCH means `bug/python-batch-budget-hook-lacks-orchestration-awareness-773`.
- CB means `extensions/drm-copilot/resources/claude-customizations`; XB means `extensions/drm-copilot/resources/codex-and-agents-customizations`; GB means `extensions/drm-copilot/resources/customizations`.
- CROUTE means `.claude/hooks/enforce-batch-budget-route.ps1`; CROUTE_OLD means `.claude/hooks/enforce-powershell-batch-budget-route.ps1`; XROUTE means `.codex/hooks/enforce-batch-budget-route.ps1`.
- CPSHOOK means `.claude/hooks/enforce-powershell-batch-budget.ps1`; XPSHOOK means `.codex/hooks/enforce-powershell-batch-budget.ps1`; CPYHOOK means `.claude/hooks/enforce-python-batch-budget.ps1`; XPYHOOK means `.codex/hooks/enforce-python-batch-budget.ps1`.
- CPYTEST means `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`; CPYRTEST means `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`; XPYRTEST means `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`; PARTEST means `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`; XTEST means `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`; LEGTEST means `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`; CPSTEST means `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`; CPSRTEST means `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`; XPSRTEST means `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`.
- RUNSET means `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; RUNSET_B means `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- CHECKPOINT means `artifacts/orchestration/orchestrator-state.json`.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA means the merge-base commit recorded by P0-T7; commands that name BASE_SHA substitute the recorded 40-character commit.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. PowerShell test-step artifacts that name coverage record numeric `LinePercent=` values in `Output Summary:`.
- KL-510 is the known local failure of issue #510 in node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. A run of that node satisfies KL-510 in exactly two cases. Case (a): the node prints PASSED; the artifact carries `KL-510: PASSED`. Case (b): the node fails, its assertion message is the literal "Repo file missing from bundle:" followed by a path whose first two components are `.claude` and `state`, and no output line contains "Bundle content differs from repo for:"; the artifact carries `KL-510: STATE-ONLY`, quotes the assertion message, and carries `ExpectedExitCode: 1` when that node is the only FAILED line. Any other outcome stops the task.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind one of `baseline`, `regression-testing`, `qa-gates`, or `other`. No artifact is written under `artifacts/`. Coverage XML and report files written by scratch scripts go to SCRATCH. No non-canonical evidence path was supplied by the caller, so no override record is needed.

### Shell route

- The worktree isolation hook refuses Bash-tool command text containing the words bash, pwsh, or wsl, heredocs, compound commands, cd-chains, or xargs. Every git, poetry, npm, and cp command in this plan is one plain command with literal arguments.
- CMD-TS-CI and CMD-TS-TWIN are issued as bare `npm` commands. The executor's `tools` list names no `npm` pattern, but it names no `sh`, `cp`, or `poetry run python` pattern either, and the #769 executor ran `sh SCRATCH/run-ps.sh ...` and `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` under the same agent definition (`docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/baseline/line-counts.2026-09-29T14-39.md`, `.../evidence/baseline/codex-variants-check.2026-09-29T14-39.md`), so the Bash pattern list does not restrict these commands in practice. The alternative form `pwsh -NoProfile -Command "npm --prefix extensions/drm-copilot ci"` is not used, because the isolation hook refuses command text containing the word pwsh (previous bullet). If a hook or permission check denies either npm command, the stop rule below applies.
- Every PowerShell script runs through scratch script A1: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`. The command text never names the PowerShell executable.
- Bundle mirrors and XROUTE are produced by `cp` from the edited primary file, never through Write or Edit, so they are byte-identical.
- **Stop rule for hook denials.** If any hook denies a Write, Edit, or command in this plan, stop and report the verbatim denial text. Do not delete any file under `.claude/state/`, do not set `CLAUDE_POWERSHELL_BUDGET_*` or `CLAUDE_PYTHON_BUDGET_*`, do not edit CHECKPOINT, and do not bypass the hook by any other route.
- Python commands run as `poetry run pytest ...` or `poetry run python -m scripts.dev_tools.generate_codex_agent_variants ...` (module form; the script-path form fails with `ModuleNotFoundError: scripts`).
- Searches for the `/orchestrate` token pass the single-quoted literal '`/orchestrate' (leading backtick). Git Bash converts an argument that begins with `/` into a Windows path, so the bare form is never passed to `git grep`. Every `/orchestrate` occurrence that Appendix C writes is preceded by a backtick.
- `git grep` searches tracked files only. Every file a search in this plan targets is tracked when the search runs (an existing file, or a file committed by an earlier commit task). Files created in a phase are verified by scratch scripts until their commit task.
- `git add` argument lists never name a path already removed by `git rm` (a pathspec that matches nothing exits 128); the `git rm` deletions are already staged.

### Agent memory

- Do not write files under `.claude/agent-memory/` until P14-T30 is complete (the bundle parity suites enumerate `.claude/**`).

### Bootstrap ordering (spec Dependencies)

The session runs this worktree's own hooks. This plan writes no `.py` file, so the live Claude Python hook never evaluates a counted path. Every `.ps1`/`.psd1` write is evaluated by the live post-#769 CPSHOOK, which reads CHECKPOINT (`route_id: large`) and allows the write without recording it. PD1 keeps CPSHOOK loadable at every step: after P1-T2 it loads both helpers; after P1-T3 it calls the neutral names; after P1-T5 it loads only CROUTE; CROUTE_OLD is removed at P1-T15. CPYHOOK is rewritten at P3-T1, after CROUTE exists, so the live Python hook always finds its helper. The orchestrator sets `lifecycle_ready: true` in CHECKPOINT before execution; this plan never writes CHECKPOINT and P0-T8 only reads it. P0-T9 and P11-T14 show that no PowerShell or Python state was recorded during the run.

### Toolchain loop rule

Each implementation phase on a PowerShell file runs the PoshQC MCP format and analyze calls, a read-only format check (A6), an analyzer count (A7), and targeted direct Pester runs. Phase 11 is the final PowerShell QA loop: format, analyze, test (type checking does not apply to PowerShell per `.claude/rules/powershell.md`). If any Phase 11 step fails or changes a tracked file, fix the cause and restart Phase 11 from P11-T1. Phase 12 re-runs the Python parity suites and the TypeScript twin; no Python or TypeScript source file is created or modified by this plan (verified by P10-T10), so black, ruff, pyright, tsc, and their coverage gates have no in-scope file.

### Commit rule

Each implementation phase ends with a commit-and-push task. CMD-GIT-COMMIT carries the commit attribution lines the executor's session requires, one `--trailer` argument per line, supplied by the executor from its session instructions. Commit-task acceptance scopes `git status --porcelain` to the named non-FEATURE paths, because evidence written after a commit stays untracked. If a hook denies staging, stop and report the denial text.

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
CMD-GIT-COUNT         git grep -c -F -e '<literal>' -- <paths>
CMD-GIT-RM            git rm -- <paths>
CMD-GIT-ADD           git add -A -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "<each attribution line>"
CMD-GIT-PUSH          git push -u origin bug/python-batch-budget-hook-lacks-orchestration-awareness-773

CMD-PY-TEST           poetry run pytest -v <test files listed in the task>
CMD-PY-GEN            poetry run python -m scripts.dev_tools.generate_codex_agent_variants
CMD-PY-GEN-CHECK      poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
CMD-TS-CI             npm --prefix extensions/drm-copilot ci
CMD-TS-TWIN           npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format  (workspace_root = worktree root, scan_folders = folders listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test    (workspace_root = worktree root)
```

CMD-GIT-COUNT is the only count template. Its literal is always wrapped in single quotes, and no literal this plan passes to it contains a single quote. The literal named in the task text is the text between the single quotes; a task never adds its own quotes around it. Multi-literal and regular-expression searches are fixed commands in Appendix G.

### Observed success outputs that acceptance conditions rely on

- The PoshQC MCP tools return a fixed summary string composed before the child process runs, with no exit code and no per-test output. Their only observable signal is whether the call returns or raises; every count, percentage, and finding is read from scratch scripts A2, A3, A6, and A7, never from an MCP result. Artifacts record the MCP call disposition as `EXIT_CODE: 0` when the call returned and non-zero when it raised.
- Scratch scripts print their result lines by construction (Appendix A): A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test; A3 additionally prints one `COVERAGE file=... LinePercent=` line and `HIT`/`MISSED` lines per coverage file; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `PSSA-SUMMARY DiagnosticCount=`; A14 prints `FUNCTIONS file=... ParseErrors=... Names=...`. A2 and A3 exit 0 whether or not tests fail; failures are read from their output. These formats were observed in the recorded #769 runs (for example `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/` artifacts produced by the same A2, A3, A6, and A7 scripts).
- `git grep` prints one `path:line:text` line per match (or `path:count` with `-c`) and exits 1 with no output when nothing matches.
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line.
- CMD-PY-GEN-CHECK exits 0 and prints nothing when nothing is stale; it exits 1 and prints one stderr line per stale path otherwise.
- Jest prints a `Tests:` summary line of the form `Tests:       <n> passed, <n> total` on success.
- `git rm` prints one `rm '<path>'` line per removed path.

### Search literal register

Searches in this plan use these fixed strings, quoted here so each is an explicit instruction and not an inferred phrase: "enforce-batch-budget-route.ps1", "enforce-powershell-batch-budget-route", "Test-BatchBudgetLargePathRoute", "Get-BatchBudgetSelectedRoute", "ConvertFrom-BatchBudgetCheckpoint", "function Test-BatchBudgetLargePathRoute", "function Get-BatchBudgetSelectedRoute", "function ConvertFrom-BatchBudgetCheckpoint", "PowerShellBatchBudgetLargePathRoute", "PowerShellBatchBudgetSelectedRoute", "PowerShellBatchBudgetCheckpoint", "PYTHON_LARGE_PATH_REQUIRED", "CLAUDE_PYTHON_BUDGET", "$env:CLAUDE_", "[Console]::In.ReadToEnd()", "function Invoke-PythonBatchBudgetCodexEntryPoint", "test file cap is", "Invoke-PythonBatchBudgetHook:ReadCheckpoint", "the Python batch-budget hook cap contract", "ReadCheckpoint = {", "Per-Batch Change Budget", "Scope Expansion Protocol", "python-orchestrator", "`/orchestrate" (passed single-quoted as '`/orchestrate'), ".codex/prompts/orchestrate-work.md", "1-3", "1–3", "more than 3", "no production-file cap", "not counted toward the routing threshold", "budget: prod=", "per-batch", "per batch", "batch cap", "smaller batches", "split the work", "new batch", "three-test", "in-flight batch", "budget override", "seek an override", "test Python files", "1-3 test Python files", "production Python files", "deleting", "reset the", "raise the cap", "record an approved cap", "#673", "stale", "#773", "## Acceptance Criteria (early draft)", ".claude/hooks/enforce-batch-budget-route.ps1", ".codex/hooks/enforce-batch-budget-route.ps1", "New-TemporaryFile", "GetTempFileName", "GetTempPath", "TestDrive", "Set-Content", "Out-File", "New-Item", "- [x] AC-", "- [ ] AC-".

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [x] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order. Acceptance: both read; recorded in P0-T5.
- [x] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, and `.github/instructions/python-unit-test.instructions.md`. Acceptance: all six read; recorded in P0-T5.
- [x] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and `.claude/rules/plan-acceptance-gates.md`. Acceptance: all five read; recorded in P0-T5.
- [x] [P0-T4] Read, in order, `.claude/rules/powershell.md`, `.claude/rules/python.md`, and `.claude/rules/python-suppressions.md`. Acceptance: all three read; recorded in P0-T5.
- [x] [P0-T5] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md. Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the 16 files read in P0-T1 through P0-T4 in reading order.
- [x] [P0-T6] Create the 15 scratch scripts of Appendix A (A1 through A14 and A11b) verbatim under SCRATCH, then smoke-test: CMD-PS-SCRIPT with script line-counts (A4) and argument `CLAUDE.md`. Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: exit 0 and one output line beginning `CLAUDE.md LineCount=`; the artifact lists the 15 script file names.
- [x] [P0-T7] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md. Commands: CMD-GIT-BRANCH, CMD-GIT-FETCH-MAIN, CMD-GIT-HEAD, CMD-GIT-MERGE-BASE, CMD-GIT-STATUS. Acceptance: the branch is BRANCH; the merge-base is recorded as BASE_SHA (40 hexadecimal characters); CMD-GIT-STATUS prints nothing or only lines naming a path under FEATURE. Any other line stops the plan (the orchestrator commits the planning artifacts and the promotion move before execution).
- [x] [P0-T8] Verify checkpoint readiness read-only for CHECKPOINT. Command: CMD-PS-SCRIPT with script checkpoint-probe (A9) and argument `artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/baseline/checkpoint-readiness.TS.md. Acceptance: output contains `ROUTE_ID=large`, `LIFECYCLE_READY=True`, and `ISSUE_NUM=773`, and the `NEXT_STEP=` value is not `complete`. If `LIFECYCLE_READY=True` is absent, stop and report to the orchestrator; this plan does not write CHECKPOINT.
- [x] [P0-T9] Record the batch-budget state read-only from `.claude/state/`. Command: CMD-PS-SCRIPT with script budget-state-probe (A10). Write FEATURE/evidence/baseline/budget-state.TS.md. Acceptance: exit 0; the artifact records every `STATE kind=` line and the `STATE-SUMMARY` line verbatim, and the per-kind sums of `prodCount` and `testCount` (recorded as PS_PROD_0, PS_TEST_0, PY_PROD_0, PY_TEST_0).
- [x] [P0-T10] Record pre-change line counts in FEATURE/evidence/baseline/line-counts.TS.md. Command: CMD-PS-SCRIPT with script line-counts (A4) over CPYHOOK, XPYHOOK, CPSHOOK, XPSHOOK, CROUTE_OLD, CPYTEST, XTEST, LEGTEST, CPSRTEST, XPSRTEST, RUNSET, and `.agents/skills/invoke-powershell-engineer/SKILL.md`. Acceptance: exit 0 and twelve `LineCount=` lines with CPYHOOK 454, XPYHOOK 254, CPSHOOK 486, XPSHOOK 461, CROUTE_OLD 137, CPYTEST 485, XTEST 371, LEGTEST 497, CPSRTEST 353, XPSRTEST 382, `.agents/skills/invoke-powershell-engineer/SKILL.md` 65; the RUNSET value is recorded as RUNSET_0.
- [x] [P0-T11] Record mirror-pair hashes in FEATURE/evidence/baseline/mirror-hashes.TS.md. Command: CMD-PS-SCRIPT with script pair-hashes (A13) over the 23 pairs of Appendix E1 (primary, then mirror, for each pair). Acceptance: `PAIR-SUMMARY pairs=23 unequal=0`. An unequal pair stops the plan, because a `cp` would then discard a bundle-specific difference.
- [x] [P0-T12] Record the Codex variant generator baseline for `.codex/agents/*.toml`. Command: CMD-PY-GEN-CHECK (`poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`). Write FEATURE/evidence/baseline/codex-variants-check.TS.md. Acceptance: exit 0 and no stderr line. A non-zero exit stops the plan.
- [x] [P0-T13] PowerShell format baseline over `.claude/hooks`, `.codex/hooks`, `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, and `scripts/powershell/PoshQC/settings` (the folders the later MCP format calls scan). Command: CMD-PS-SCRIPT with script ps-format-check (A6) over `.claude/hooks/*.ps*1 .codex/hooks/*.ps*1 tests/scripts/claude-hooks/*.ps1 tests/scripts/codex-hooks/*.ps1 scripts/powershell/PoshQC/settings/*.psd1`. Write FEATURE/evidence/baseline/powershell-format.TS.md. Acceptance: exit 0 and `FORMAT-SUMMARY ChangedCount=0`. A non-zero count stops the plan, because the folder-scoped MCP format calls would rewrite files outside this item.
- [x] [P0-T14] PowerShell analyzer baseline for CPYHOOK, XPYHOOK, CPSHOOK, XPSHOOK, CROUTE_OLD, CPYTEST, XTEST, LEGTEST, CPSRTEST, and XPSRTEST. Command: CMD-PS-SCRIPT with script pssa-count (A7) over those ten files. Write FEATURE/evidence/baseline/powershell-analyze.TS.md. Acceptance: exit 0 and the `PSSA-SUMMARY DiagnosticCount=` value is recorded.
- [x] [P0-T15] Claude Python hook test and coverage baseline for CPYHOOK (`.claude/hooks/enforce-python-batch-budget.ps1`), written to FEATURE/evidence/baseline/claude-python-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 -CoveragePath .claude/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-cpy-base.xml -ReportPath SCRATCH/cov-cpy-base.txt`. Acceptance: `TotalCount=35`, `FailedCount=0`, and a numeric `LinePercent=` for CPYHOOK (recorded as CPY_BASE_PCT).
- [x] [P0-T16] Codex Python hook test and coverage baseline for XPYHOOK (`.codex/hooks/enforce-python-batch-budget.ps1`), written to FEATURE/evidence/baseline/codex-python-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 -CoveragePath .codex/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xpy-base.xml -ReportPath SCRATCH/cov-xpy-base.txt`. Acceptance: `TotalCount=41`, `FailedCount=0`, and a numeric `LinePercent=` for XPYHOOK (recorded as XPY_BASE_PCT).
- [x] [P0-T17] Claude PowerShell hook and old route helper coverage baseline, written to FEATURE/evidence/baseline/claude-powershell-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-powershell-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-cps-base.xml -ReportPath SCRATCH/cov-cps-base.txt`. Acceptance: `TotalCount=83`, `FailedCount=0`, and numeric `LinePercent=` values for CPSHOOK and CROUTE_OLD (recorded as CPS_BASE_PCT and ROUTE_BASE_PCT).
- [x] [P0-T18] Codex PowerShell hook coverage baseline, written to FEATURE/evidence/baseline/codex-powershell-hook-coverage.TS.md. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xps-base.xml -ReportPath SCRATCH/cov-xps-base.txt`. Acceptance: `TotalCount=90`, `FailedCount=0`, and a numeric `LinePercent=` for XPSHOOK (recorded as XPS_BASE_PCT).
- [x] [P0-T19] Pester regression baseline for `tests/scripts/claude-hooks`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks`. Write FEATURE/evidence/baseline/pester-claude-hooks.TS.md. Acceptance: the artifact records `TotalCount=`, `PassedCount=`, `FailedCount=`, and every `FAILED:` line verbatim (the baseline failure set, possibly empty).
- [x] [P0-T20] Pester regression baseline for `tests/scripts/codex-hooks`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/codex-hooks`. Write FEATURE/evidence/baseline/pester-codex-hooks.TS.md. Acceptance: as P0-T19.
- [x] [P0-T21] Pester regression baseline for `tests/scripts/claude-runtime`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-runtime`. Write FEATURE/evidence/baseline/pester-claude-runtime.TS.md. Acceptance: as P0-T19.
- [x] [P0-T22] Python parity baseline for the eleven suites of Appendix F (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and ten others). Command: CMD-PY-TEST over the eleven Appendix F files. Write FEATURE/evidence/baseline/python-parity.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED or SKIPPED, and that node satisfies KL-510.
- [x] [P0-T23] Python regression baseline for `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/baseline/python-dev-tools.TS.md. Acceptance: the artifact records the summary line (passed, failed, skipped counts) and every `FAILED` line verbatim (the baseline failure set). The artifact carries ExpectedExitCode: 1 only when the KL-510 node is the only FAILED line and satisfies case (b).
- [x] [P0-T24] TypeScript twin baseline for `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Command: CMD-TS-CI (`npm --prefix extensions/drm-copilot ci`), then CMD-GIT-STATUS-PATH over `extensions/drm-copilot`, then CMD-TS-TWIN. Write FEATURE/evidence/baseline/ts-manifest-completeness.TS.md. Acceptance: CMD-TS-CI exits 0 and prints an `added` line; CMD-GIT-STATUS-PATH over `extensions/drm-copilot` prints nothing after CMD-TS-CI (`node_modules` is gitignored, `.gitignore` line 3); CMD-TS-TWIN exits 0 and the `Tests:` summary line reports no failed test; its total is recorded as TS_TOTAL_0.
- [x] [P0-T25] Non-vacuity baseline for the AC-18 phrase sweep. Command: the AC-18 sweep of Appendix G. Write FEATURE/evidence/baseline/ac18-sweep.TS.md. Acceptance: exit 0; at least one match line names each of CPYHOOK, XPYHOOK, `.claude/skills/python-change-budget-router/SKILL.md`, `.agents/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, and `.github/agents/python-typed-engineer.agent.md`; no match line names a path containing `python-execution-only-typed` (proves the exclusion pathspecs work).
- [x] [P0-T26] Non-vacuity baseline for the AC-20 test-clause searches. Commands: the AC-20 regex search, then the AC-20 fixed-string search of Appendix G. Write FEATURE/evidence/baseline/ac20-test-clause.TS.md. Acceptance: the regex search exits 0 and names each of the six AC-20 files at least once; the fixed-string search exits 0 and names `.github/agents/python-orchestrator.agent.md` and its GB mirror.
- [x] [P0-T27] Non-vacuity baseline for the AC-13 helper-name sweep. Command: the AC-13 sweep of Appendix G. Write FEATURE/evidence/baseline/ac13-helper-names.TS.md. Acceptance: exit 0 and at least one match line names each of CPSHOOK, CROUTE_OLD, XPSHOOK, CPSRTEST, XPSRTEST, and the CB and XB copies of those hooks.
- [x] [P0-T28] Non-vacuity baseline for AC-22 and AC-8. Commands: CMD-GIT-COUNT with literal `budget: prod=` over `.claude/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-powershell-engineer/SKILL.md`; CMD-GIT-COUNT with literal `CLAUDE_PYTHON_BUDGET` over CPYHOOK and its CB copy. Write FEATURE/evidence/baseline/ac22-ac8-nonvacuity.TS.md. Acceptance: the first search prints three `path:count` lines; the second prints two `path:count` lines.
- [x] [P0-T29] Record that no new file of this plan exists yet. Command: CMD-GIT-LS over CROUTE, XROUTE, CPYRTEST, XPYRTEST, and PARTEST. Write FEATURE/evidence/baseline/new-files-absent.TS.md. Acceptance: the command prints nothing.

### Phase 1 — Shared Claude Route Helper (Rename Sequence)

- [x] [P1-T1] Write CROUTE (`.claude/hooks/enforce-batch-budget-route.ps1`) per Appendix B1. Acceptance: the Write succeeds without a hook denial; CMD-PS-SCRIPT with script function-names (A14) over CROUTE prints `ParseErrors=0` and `Names=ConvertFrom-BatchBudgetCheckpoint,Get-BatchBudgetSelectedRoute,Test-BatchBudgetLargePathRoute`; CMD-PS-SCRIPT with script route-probe (A11) and arguments `.claude/hooks/enforce-batch-budget-route.ps1 artifacts/orchestration/orchestrator-state.json` prints `LARGE-PATH-ROUTE=True` and `SELECTED-ROUTE=large`. Write FEATURE/evidence/regression-testing/route-helper-created.TS.md.
- [x] [P1-T2] Edit CPSHOOK (`.claude/hooks/enforce-powershell-batch-budget.ps1`): insert the line `. (Join-Path $PSScriptRoot 'enforce-batch-budget-route.ps1')` immediately after line 63 (the old dot-source). Acceptance: CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over CPSHOOK prints a count of 1, and CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route.ps1` over CPSHOOK prints a count of 1.
- [x] [P1-T3] Edit CPSHOOK: in the two call lines (lines 396-397 after P1-T2), replace `Test-PowerShellBatchBudgetLargePathRoute` with `Test-BatchBudgetLargePathRoute` and `Get-PowerShellBatchBudgetSelectedRoute` with `Get-BatchBudgetSelectedRoute`; nothing else changes. Acceptance: CMD-GIT-COUNT with literal `Test-BatchBudgetLargePathRoute` over CPSHOOK prints 1; CMD-GIT-COUNT with literal `Get-BatchBudgetSelectedRoute` over CPSHOOK prints 1; CMD-GIT-COUNT with literal `PowerShellBatchBudgetLargePathRoute` over CPSHOOK exits 1 with no output.
- [x] [P1-T4] Edit CPSRTEST (`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`): on line 125 replace `Test-PowerShellBatchBudgetLargePathRoute` with `Test-BatchBudgetLargePathRoute`; on line 136 replace `Get-PowerShellBatchBudgetSelectedRoute` with `Get-BatchBudgetSelectedRoute`; nothing else changes. Acceptance: CMD-GIT-COUNT with literal `PowerShellBatchBudgetLargePathRoute` over CPSRTEST exits 1 with no output; CMD-GIT-COUNT with literal `PowerShellBatchBudgetSelectedRoute` over it exits 1 with no output; CMD-GIT-COUNT with literal `Test-BatchBudgetLargePathRoute` over it prints 1; CMD-GIT-COUNT with literal `Get-BatchBudgetSelectedRoute` over it prints 1.
- [x] [P1-T5] Edit CPSHOOK: delete line 63 (`. (Join-Path $PSScriptRoot 'enforce-powershell-batch-budget-route.ps1')`). Acceptance: CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route` over CPSHOOK exits 1 with no output; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over it prints 1.
- [x] [P1-T6] Probe the live CPSHOOK after the switch. Command: CMD-PS-SCRIPT with script route-probe (A11) and arguments `.claude/hooks/enforce-powershell-batch-budget.ps1 artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/regression-testing/live-route-probe-cpshook.TS.md. Acceptance: output contains `LARGE-PATH-ROUTE=True` and `SELECTED-ROUTE=large`. Any other output stops the plan before any further PowerShell write.
- [x] [P1-T7] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`: delete line 9 (`".claude/hooks/enforce-powershell-batch-budget-route.ps1",`). Acceptance: CMD-PS-SCRIPT with script json-parse (A12) over the file prints `JSON-OK`; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route` over the file exits 1 with no output.
- [x] [P1-T8] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert the line `    ".claude/hooks/enforce-batch-budget-route.ps1",` immediately before line 25. Acceptance: A12 over the file prints `JSON-OK`; CMD-GIT-COUNT with literal `.claude/hooks/enforce-batch-budget-route.ps1` over the file prints 1.
- [x] [P1-T9] Edit RUNSET (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`): replace line 32 with `            '.claude/hooks/enforce-batch-budget-route.ps1'` (same twelve-space indentation). Acceptance: CMD-PS-SCRIPT with script psd1-parse (A8) over RUNSET prints `PSD1-OK`; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over RUNSET prints 1; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route` over RUNSET exits 1.
- [x] [P1-T10] Format CROUTE, CPSHOOK, CPSRTEST, and RUNSET. Commands: MCP-PS-FORMAT with scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`, `scripts/powershell/PoshQC/settings`; then CMD-GIT-STATUS-PATH over `.claude/hooks tests/scripts/claude-hooks scripts/powershell/PoshQC/settings`; then CMD-PS-SCRIPT with script ps-format-check (A6) over the four files. Write FEATURE/evidence/qa-gates/format-p1.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than CROUTE (`??`), CPSHOOK, CPSRTEST, and RUNSET; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [x] [P1-T11] Analyze CROUTE, CPSHOOK, CPSRTEST, and RUNSET. Commands: MCP-PS-ANALYZE with the P1-T10 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the four files. Write FEATURE/evidence/qa-gates/analyze-p1.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P1-T12] Run CPSRTEST after the switch (AC-16). Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/cpsrtest-after-switch.TS.md. Acceptance: `TotalCount=47`, `PassedCount=47`, `FailedCount=0`.
- [x] [P1-T13] Run CPSTEST after the switch (AC-16). Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`. Write FEATURE/evidence/regression-testing/cpstest-after-switch.TS.md. Acceptance: `TotalCount=36`, `PassedCount=36`, `FailedCount=0`.
- [x] [P1-T14] Mirror CPSHOOK and CROUTE into CB and RUNSET into RUNSET_B. Commands: `cp .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`, `cp .claude/hooks/enforce-batch-budget-route.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1`, `cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the three pairs prints `PAIR-SUMMARY pairs=3 unequal=0`.
- [x] [P1-T15] Delete CROUTE_OLD and its CB copy. Command: CMD-GIT-RM with `.claude/hooks/enforce-powershell-batch-budget-route.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`; then CMD-GIT-LS over the same two paths; then CMD-GIT-STATUS-PATH over the same two paths. Write FEATURE/evidence/other/old-route-helper-removed.TS.md. Acceptance: `git rm` exits 0 and prints two `rm '` lines; CMD-GIT-LS prints nothing; the status prints exactly two lines, each beginning `D ` and naming one of the two paths.
- [x] [P1-T16] Run the Claude bundle contract suites `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Command: CMD-PY-TEST over those three files. Write FEATURE/evidence/regression-testing/claude-bundle-contracts-p1.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED or SKIPPED, and that node satisfies KL-510.
- [x] [P1-T17] Run the TypeScript manifest-completeness twin. Command: CMD-TS-TWIN. Write FEATURE/evidence/regression-testing/ts-manifest-completeness-p1.TS.md. Acceptance: exit 0 and the `Tests:` summary line reports no failed test and a total equal to TS_TOTAL_0.
- [x] [P1-T18] Record line counts for CROUTE, CPSHOOK, CPSRTEST, and RUNSET. Command: CMD-PS-SCRIPT with script line-counts (A4) over the four files. Write FEATURE/evidence/qa-gates/line-counts-p1.TS.md. Acceptance: CROUTE at most 500; CPSHOOK 486; CPSRTEST 353; RUNSET equals RUNSET_0.
- [x] [P1-T19] Commit and push Phase 1. Commands: CMD-GIT-ADD with `.claude/hooks/enforce-batch-budget-route.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773` (the two `git rm` deletions are already staged and are not named), CMD-GIT-COMMIT with message "refactor(773): share a language-neutral batch-budget route helper in the Claude runtime", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.claude/hooks tests/scripts/claude-hooks scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/powershell extensions/drm-copilot/resources/claude-customizations` prints nothing and the push exits 0.

### Phase 2 — Claude Python Regression Tests First

- [x] [P2-T1] Write CPYRTEST (`tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`) per Appendix B4 (13 direct-mode, 5 large-path, 3 test-path, 5 override, 6 seam cases). Acceptance: the Write succeeds without a hook denial, and CMD-PS-SCRIPT with script line-counts (A4) over CPYRTEST prints one `LineCount=` value of at most 500. The case count is verified by P2-T2.
- [x] [P2-T2] [expect-fail] Run CPYRTEST against the unfixed CPYHOOK. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/claude-python-routing-before-fix.TS.md with `ExpectedExitCode: 0` (A2 reports test failures in its output, not its exit code). Acceptance: exit 0, `TotalCount=32`, `PassedCount=0`, `FailedCount=32`. Any other count stops the plan for a design review, because every Appendix B4 case depends on the new hook surface.
- [x] [P2-T3] Commit and push Phase 2. Commands: CMD-GIT-ADD with `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "test(773): add Claude Python batch-budget routing regression tests", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `tests/scripts/claude-hooks` prints nothing and the push exits 0.

### Phase 3 — Claude Python Hook Fix

- [x] [P3-T1] Write CPYHOOK (`.claude/hooks/enforce-python-batch-budget.ps1`) per Appendix B3 as one Write call carrying the complete file. Acceptance: the Write succeeds without a hook denial; CMD-GIT-COUNT with literal `PYTHON_LARGE_PATH_REQUIRED` over CPYHOOK prints a count of at least 2 (docstring and deny reason); CMD-GIT-COUNT with literal `CLAUDE_PYTHON_BUDGET` over CPYHOOK exits 1 with no output; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over CPYHOOK prints 1.
- [x] [P3-T2] Edit CPYTEST (`tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`) per Appendix B5. Acceptance: CMD-GIT-COUNT with literal `test file cap is` over CPYTEST exits 1; CMD-GIT-COUNT with literal `PYTHON_LARGE_PATH_REQUIRED` over it prints 1; CMD-GIT-COUNT with literal `Invoke-PythonBatchBudgetHook:ReadCheckpoint` over it prints 2.
- [x] [P3-T3] Format CPYHOOK, CPYTEST, and CPYRTEST. Commands: MCP-PS-FORMAT with scan_folders `.claude/hooks` and `tests/scripts/claude-hooks`; then CMD-GIT-STATUS-PATH over `.claude/hooks tests/scripts/claude-hooks`; then CMD-PS-SCRIPT with script ps-format-check (A6) over the three files. Write FEATURE/evidence/qa-gates/format-p3.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than CPYHOOK, CPYTEST, and CPYRTEST; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [x] [P3-T4] Analyze CPYHOOK, CPYTEST, and CPYRTEST. Commands: MCP-PS-ANALYZE with the P3-T3 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the three files. Write FEATURE/evidence/qa-gates/analyze-p3.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P3-T5] Run CPYRTEST after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/claude-python-routing-after-fix.TS.md. Acceptance: `TotalCount=32`, `PassedCount=32`, `FailedCount=0`.
- [x] [P3-T6] Run CPYTEST after the fix. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`. Write FEATURE/evidence/regression-testing/claude-python-existing-after-fix.TS.md. Acceptance: `TotalCount=34`, `PassedCount=34`, `FailedCount=0`.
- [x] [P3-T7] Run `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (AC-9 deny shape). Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write FEATURE/evidence/regression-testing/pretooluse-schema.TS.md. Acceptance: `FailedCount=0` and `TotalCount=` equals `PassedCount=`.
- [x] [P3-T8] Mirror CPYHOOK into CB. Command: `cp .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P3-T9] Run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Command: CMD-PY-TEST over that file. Write FEATURE/evidence/regression-testing/claude-bundle-contracts-p3.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED or SKIPPED, and that node satisfies KL-510.
- [x] [P3-T10] Record line counts for CPYHOOK, CPYTEST, and CPYRTEST. Command: CMD-PS-SCRIPT with script line-counts (A4) over the three files. Write FEATURE/evidence/qa-gates/line-counts-p3.TS.md. Acceptance: CPYHOOK at most 500; CPYTEST 481; CPYRTEST at most 500.
- [x] [P3-T11] Commit and push Phase 3. Commands: CMD-GIT-ADD with `.claude/hooks/enforce-python-batch-budget.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "fix(773): route over-budget Python changes to the large path in the Claude hook", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations` prints nothing and the push exits 0.

### Phase 4 — Codex Route Helper, Codex PowerShell Rewiring, and Parity Suite

- [x] [P4-T1] Write PARTEST (`tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`) per Appendix B6 (1 byte-identity case plus 27 cases per runtime copy). Acceptance: the Write succeeds without a hook denial, and A4 over PARTEST prints one `LineCount=` value of at most 500.
- [x] [P4-T2] [expect-fail] Run PARTEST before XROUTE exists. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`. Write FEATURE/evidence/regression-testing/route-parity-before-codex-helper.TS.md with `ExpectedExitCode: 0`. Acceptance: exit 0, `TotalCount=55`, `PassedCount=27`, `FailedCount=28`; exactly one `FAILED:` line contains `byte-identical`; every other `FAILED:` line contains `<Runtime>` or `Codex` (Pester 5.6.1 reports tests under a failed block `BeforeAll` with the unexpanded block template); no `FAILED:` line contains `the Claude route helper` (PD6). Any other outcome stops the plan for a design review.
- [x] [P4-T3] Create XROUTE (`.codex/hooks/enforce-batch-budget-route.ps1`) as a byte copy of the formatted CROUTE. Command: `cp .claude/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-batch-budget-route.ps1`. Acceptance: CMD-PS-SCRIPT with script pair-hashes (A13) over the pair CROUTE, XROUTE prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P4-T4] Write XPSHOOK (`.codex/hooks/enforce-powershell-batch-budget.ps1`) per Appendix B7 as one Write call carrying the complete file. Acceptance: the Write succeeds without a hook denial; CMD-GIT-COUNT with literal `PowerShellBatchBudgetCheckpoint` over XPSHOOK exits 1; CMD-GIT-COUNT with literal `PowerShellBatchBudgetLargePathRoute` over XPSHOOK exits 1; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over XPSHOOK prints 1; CMD-GIT-COUNT with literal `[Console]::In.ReadToEnd()` over XPSHOOK prints 1.
- [x] [P4-T5] Edit XPSRTEST (`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`): on line 136 replace `Test-PowerShellBatchBudgetLargePathRoute` with `Test-BatchBudgetLargePathRoute`; on line 147 replace `Get-PowerShellBatchBudgetSelectedRoute` with `Get-BatchBudgetSelectedRoute`; nothing else changes. Acceptance: CMD-GIT-COUNT with literal `PowerShellBatchBudgetLargePathRoute` over XPSRTEST exits 1; CMD-GIT-COUNT with literal `Get-BatchBudgetSelectedRoute` over it prints 1.
- [x] [P4-T6] Edit LEGTEST (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`) line 30: insert `, 'enforce-batch-budget-route.ps1'` after `'hook-command-invocation.ps1'` inside the array, on the same line. No other edit. Acceptance: CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over LEGTEST prints 1; A4 over LEGTEST prints `LineCount=497`.
- [x] [P4-T7] Edit `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: insert the line `    ".codex/hooks/enforce-batch-budget-route.ps1",` immediately after line 50. Acceptance: A12 prints `JSON-OK`; CMD-GIT-COUNT with literal `.codex/hooks/enforce-batch-budget-route.ps1` over the file prints 1.
- [x] [P4-T8] Edit RUNSET: insert the line `            '.codex/hooks/enforce-batch-budget-route.ps1'` immediately after line 137 (the `.codex/hooks/enforce-powershell-batch-budget.ps1` entry). Acceptance: A8 prints `PSD1-OK`; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over RUNSET prints 2.
- [x] [P4-T9] Format XROUTE, XPSHOOK, XPSRTEST, LEGTEST, PARTEST, and RUNSET. Commands: MCP-PS-FORMAT with scan_folders `.codex/hooks`, `tests/scripts/codex-hooks`, `scripts/powershell/PoshQC/settings`; then CMD-GIT-STATUS-PATH over `.codex/hooks tests/scripts/codex-hooks scripts/powershell/PoshQC/settings`; then A6 over the six files; then A13 over the pair CROUTE, XROUTE. Write FEATURE/evidence/qa-gates/format-p4.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than XROUTE (`??`), PARTEST (`??`), XPSHOOK, XPSRTEST, LEGTEST, and RUNSET; A6 prints `FORMAT-SUMMARY ChangedCount=0`; A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P4-T10] Analyze the six P4-T9 files. Commands: MCP-PS-ANALYZE with the P4-T9 scan_folders, then A7 over the six files. Write FEATURE/evidence/qa-gates/analyze-p4.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P4-T11] Run PARTEST after XROUTE exists (AC-14). Command: A2 with `-Path tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`. Write FEATURE/evidence/regression-testing/route-parity-after.TS.md. Acceptance: `TotalCount=55`, `PassedCount=55`, `FailedCount=0`.
- [x] [P4-T12] Run XPSRTEST after the rewiring (AC-16). Command: A2 with `-Path tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/xpsrtest-after-rewire.TS.md. Acceptance: `TotalCount=49`, `PassedCount=49`, `FailedCount=0`.
- [x] [P4-T13] Run XTEST after the rewiring (AC-16, PowerShell row). Command: A2 with `-Path tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`. Write FEATURE/evidence/regression-testing/xtest-after-rewire.TS.md. Acceptance: `TotalCount=41`, `PassedCount=41`, `FailedCount=0`.
- [x] [P4-T14] Mirror XROUTE and XPSHOOK into XB and RUNSET into RUNSET_B. Commands: `cp .codex/hooks/enforce-batch-budget-route.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-batch-budget-route.ps1`, `cp .codex/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`, `cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: A13 over the three pairs prints `PAIR-SUMMARY pairs=3 unequal=0`.
- [x] [P4-T15] Run LEGTEST, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. Command: A2 with `-Path` set to the three paths joined by commas. Write FEATURE/evidence/regression-testing/codex-contracts-p4.TS.md. Acceptance: every `FAILED:` line (if any) is a member of the P0-T20 baseline failure set, and no `FAILED:` line names a test containing "byte-identical", "500 lines", "legacy Claude environment", "core pack manifest", "batch-budget", or "session_id".
- [x] [P4-T16] Run `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Command: CMD-PY-TEST over those three files. Write FEATURE/evidence/regression-testing/codex-bundle-contracts-p4.TS.md. Acceptance: exit 0 and no FAILED line.
- [x] [P4-T17] Record line counts for XROUTE, XPSHOOK, XPSRTEST, LEGTEST, PARTEST, and RUNSET. Command: A4 over the six files. Write FEATURE/evidence/qa-gates/line-counts-p4.TS.md. Acceptance: XROUTE and PARTEST at most 500; XPSHOOK 341; XPSRTEST 382; LEGTEST 497; RUNSET equals RUNSET_0 plus 1.
- [x] [P4-T18] Commit and push Phase 4. Commands: CMD-GIT-ADD with `.codex/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1 tests/scripts/codex-hooks scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "refactor(773): load the shared route helper in the Codex PowerShell hook", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.codex/hooks tests/scripts/codex-hooks scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/powershell extensions/drm-copilot/resources/codex-and-agents-customizations` prints nothing and the push exits 0.

### Phase 5 — Codex Python Regression Tests First

- [x] [P5-T1] Write XPYRTEST (`tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`) per Appendix B8 (13 direct-mode, 5 large-path, 3 test-path, 4 override, 6 seam, 3 entry-point cases). Acceptance: the Write succeeds without a hook denial, and A4 over XPYRTEST prints one `LineCount=` value of at most 500.
- [x] [P5-T2] [expect-fail] Run XPYRTEST against the unfixed XPYHOOK. Command: A2 with `-Path tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/codex-python-routing-before-fix.TS.md with `ExpectedExitCode: 0`. Acceptance: exit 0, `TotalCount=34`, `PassedCount=0`, `FailedCount=34`. Any other count stops the plan for a design review.
- [x] [P5-T3] Commit and push Phase 5. Commands: CMD-GIT-ADD with `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "test(773): add Codex Python batch-budget routing regression tests", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `tests/scripts/codex-hooks` prints nothing and the push exits 0.

### Phase 6 — Codex Python Hook Fix

- [x] [P6-T1] Write XPYHOOK (`.codex/hooks/enforce-python-batch-budget.ps1`) per Appendix B9 as one Write call carrying the complete file. Acceptance: the Write succeeds without a hook denial; CMD-GIT-COUNT with literal `PYTHON_LARGE_PATH_REQUIRED` over XPYHOOK prints at least 2; CMD-GIT-COUNT with literal `$env:CLAUDE_` over XPYHOOK exits 1; CMD-GIT-COUNT with literal `[Console]::In.ReadToEnd()` over it prints 1; CMD-GIT-COUNT with literal `function Invoke-PythonBatchBudgetCodexEntryPoint` over it prints 1; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over it prints 1.
- [x] [P6-T2] Edit XTEST (`tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`) per Appendix B10. Acceptance: CMD-GIT-COUNT with literal `the Python batch-budget hook cap contract` over XTEST exits 1; CMD-GIT-COUNT with literal `ReadCheckpoint = {` over XTEST prints 2; A4 over XTEST prints `LineCount=275`.
- [x] [P6-T3] Format XPYHOOK, XTEST, and XPYRTEST. Commands: MCP-PS-FORMAT with scan_folders `.codex/hooks` and `tests/scripts/codex-hooks`; then CMD-GIT-STATUS-PATH over `.codex/hooks tests/scripts/codex-hooks`; then A6 over the three files. Write FEATURE/evidence/qa-gates/format-p6.TS.md. Acceptance: the MCP call returns without raising; the status output names no path other than XPYHOOK, XTEST, and XPYRTEST; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [x] [P6-T4] Analyze XPYHOOK, XTEST, and XPYRTEST. Commands: MCP-PS-ANALYZE with the P6-T3 scan_folders, then A7 over the three files. Write FEATURE/evidence/qa-gates/analyze-p6.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P6-T5] Run XPYRTEST after the fix. Command: A2 with `-Path tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/regression-testing/codex-python-routing-after-fix.TS.md. Acceptance: `TotalCount=34`, `PassedCount=34`, `FailedCount=0`.
- [x] [P6-T6] Run XTEST after the fix. Command: A2 with `-Path tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`. Write FEATURE/evidence/regression-testing/xtest-after-python-fix.TS.md. Acceptance: `TotalCount=34`, `PassedCount=34`, `FailedCount=0` (41 minus the 7 removed Python-only cases).
- [x] [P6-T7] Mirror XPYHOOK into XB. Command: `cp .codex/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1`. Acceptance: A13 over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P6-T8] Run LEGTEST, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (AC-10). Command: A2 with `-Path` set to the three paths joined by commas. Write FEATURE/evidence/regression-testing/codex-contracts-p6.TS.md. Acceptance: as P4-T15.
- [x] [P6-T9] Run `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Command: CMD-PY-TEST over that file. Write FEATURE/evidence/regression-testing/codex-bundle-contracts-p6.TS.md. Acceptance: exit 0 and no FAILED line.
- [x] [P6-T10] Record line counts for XPYHOOK, XTEST, and XPYRTEST. Command: A4 over the three files. Write FEATURE/evidence/qa-gates/line-counts-p6.TS.md. Acceptance: XPYHOOK at most 500; XTEST 275; XPYRTEST at most 500.
- [x] [P6-T11] Commit and push Phase 6. Commands: CMD-GIT-ADD with `.codex/hooks/enforce-python-batch-budget.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "fix(773): route over-budget Python changes to the large path in the Codex hook", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.codex/hooks tests/scripts/codex-hooks extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks` prints nothing and the push exits 0.

### Phase 7 — Claude and Copilot Python Text Surfaces

- [x] [P7-T1] Write `.claude/skills/python-change-budget-router/SKILL.md` per Appendix C1 (complete file). Acceptance: CMD-GIT-COUNT with literal `Per-Batch Change Budget` over the file exits 1; CMD-GIT-COUNT with literal `python-orchestrator` over it exits 1; CMD-GIT-COUNT with literal `1-3` over it prints at least 2; CMD-GIT-COUNT with literal '`/orchestrate' (leading backtick; the template supplies the single quotes) over it prints at least 1.
- [x] [P7-T2] Edit `.claude/skills/invoke-python-engineer/SKILL.md` per Appendix C2. Acceptance: CMD-GIT-COUNT with literal `budget: prod=` over the file exits 1; CMD-GIT-COUNT with literal '`/orchestrate' over it prints at least 1; CMD-GIT-COUNT with literal `1-3` over it prints at least 2.
- [x] [P7-T3] Edit `.claude/agents/python-typed-engineer.md` per Appendix C3. Acceptance: CMD-GIT-COUNT with literal `per-batch` over the file exits 1; CMD-GIT-COUNT with literal `in-flight batch` over it exits 1; CMD-GIT-COUNT with literal '`/orchestrate' over it prints at least 1.
- [x] [P7-T4] Edit `.github/agents/python-typed-engineer.agent.md` per Appendix C4. Acceptance: CMD-GIT-COUNT with literal `budget: prod=` over the file exits 1; CMD-GIT-COUNT with literal `seek an override` over it exits 1; CMD-GIT-COUNT with literal `1-3` over it prints at least 2; CMD-GIT-COUNT with literal `python-orchestrator` over it prints at least 2.
- [x] [P7-T5] Edit `.github/agents/python-orchestrator.agent.md` per Appendix C5. Acceptance: CMD-GIT-COUNT with literal `test Python files` over the file exits 1; CMD-GIT-COUNT with literal `no production-file cap` over it prints 1.
- [x] [P7-T6] Edit `.github/prompts/orchestrate-python-work.prompt.md` per Appendix C6. Acceptance: CMD-GIT-COUNT with literal `test Python files` over the file exits 1; CMD-GIT-COUNT with literal `1–3` over it exits 1; CMD-GIT-COUNT with literal `1-3` over it prints 1.
- [x] [P7-T7] Mirror the three Claude text files into CB. Commands: `cp .claude/skills/python-change-budget-router/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-change-budget-router/SKILL.md`, `cp .claude/skills/invoke-python-engineer/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`, `cp .claude/agents/python-typed-engineer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`. Acceptance: A13 over the three pairs prints `PAIR-SUMMARY pairs=3 unequal=0`.
- [x] [P7-T8] Mirror the three Copilot text files into GB. Commands: `cp .github/agents/python-typed-engineer.agent.md extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md`, `cp .github/agents/python-orchestrator.agent.md extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md`, `cp .github/prompts/orchestrate-python-work.prompt.md extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md`. Acceptance: A13 over the three pairs prints `PAIR-SUMMARY pairs=3 unequal=0`.
- [x] [P7-T9] Run `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Command: CMD-PY-TEST over those two files. Write FEATURE/evidence/regression-testing/text-surface-contracts-p7.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED or SKIPPED, and that node satisfies KL-510.
- [x] [P7-T10] Commit and push Phase 7. Commands: CMD-GIT-ADD with `.claude/skills/python-change-budget-router/SKILL.md .claude/skills/invoke-python-engineer/SKILL.md .claude/agents/python-typed-engineer.md .github/agents/python-typed-engineer.agent.md .github/agents/python-orchestrator.agent.md .github/prompts/orchestrate-python-work.prompt.md extensions/drm-copilot/resources/claude-customizations extensions/drm-copilot/resources/customizations docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "docs(773): state the Python routing rule on Claude and Copilot surfaces", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.claude/skills .claude/agents .github/agents .github/prompts extensions/drm-copilot/resources/claude-customizations extensions/drm-copilot/resources/customizations` prints nothing and the push exits 0.

### Phase 8 — Codex and .agents Text Surfaces and Variant Regeneration

- [x] [P8-T1] Write `.agents/skills/python-change-budget-router/SKILL.md` per Appendix C7 (complete file). Acceptance: CMD-GIT-COUNT with literal `Scope Expansion Protocol` over the file exits 1; CMD-GIT-COUNT with literal `.codex/prompts/orchestrate-work.md` over it prints at least 1; CMD-GIT-COUNT with literal `1-3` over it prints at least 2.
- [x] [P8-T2] Edit `.agents/skills/invoke-python-engineer/SKILL.md` per Appendix C8. Acceptance: CMD-GIT-COUNT with literal `three-test` over the file exits 1; CMD-GIT-COUNT with literal `budget: prod=` over it exits 1; CMD-GIT-COUNT with literal `.codex/prompts/orchestrate-work.md` over it prints 1.
- [x] [P8-T3] Edit `.agents/skills/invoke-powershell-engineer/SKILL.md`: delete line 26 (`- Optional budget override in the form ...`) and change nothing else (spec In scope item 9). Acceptance: CMD-GIT-COUNT with literal `budget: prod=` over the file exits 1; A4 over the file prints `LineCount=64`.
- [x] [P8-T4] Edit `.codex/agents/python-typed-engineer.toml` per Appendix C9. Acceptance: CMD-GIT-COUNT with literal `per-batch` over the file exits 1; CMD-GIT-COUNT with literal `.codex/prompts/orchestrate-work.md` over it prints 1; CMD-GIT-COUNT with literal `no production-file cap` over it prints 1.
- [x] [P8-T5] Edit `.codex/agents/python-orchestrator.toml` per Appendix C10. Acceptance: CMD-GIT-COUNT with literal `test files.` over the file exits 1; CMD-GIT-COUNT with literal `not counted toward the routing threshold` over it prints 1.
- [x] [P8-T6] Mirror the three `.agents` files and `.codex/agents/python-orchestrator.toml` into XB. Commands: `cp .agents/skills/python-change-budget-router/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-change-budget-router/SKILL.md`, `cp .agents/skills/invoke-python-engineer/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`, `cp .agents/skills/invoke-powershell-engineer/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`, `cp .codex/agents/python-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml`. Acceptance: A13 over the four pairs prints `PAIR-SUMMARY pairs=4 unequal=0`.
- [x] [P8-T7] Regenerate the Codex variants with the repository generator and restore CRLF-only manifest rewrites (PD8). Commands: CMD-PY-GEN; then `git diff --name-only HEAD -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`; then `git status --porcelain -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`; then, for each path under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` that the status lists, `git hash-object <path>` and `git rev-parse HEAD:<path>`, and `git checkout -- <path>` only when the two hashes are equal; then CMD-GIT-STATUS-PATH over the same three pathspecs again. Write FEATURE/evidence/other/codex-variants-regenerated.TS.md. Acceptance: the generator exits 0; the diff lists exactly the fourteen paths `.codex/agents/python-typed-engineer.toml`, `.codex/agents/python-typed-engineer-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`, `.codex/agents/python-orchestrator.toml`, and the same seven file names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`; every manifest the first status lists has equal hashes and is restored; the final status lists exactly the same fourteen paths, each with status `M`. An unequal manifest hash stops the plan. No variant is hand-edited.
- [x] [P8-T8] Verify the regenerated variants. Command: CMD-PY-GEN-CHECK. Write FEATURE/evidence/qa-gates/codex-variants-check.TS.md. Acceptance: exit 0 and no stderr line.
- [x] [P8-T9] Run `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`, and `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`. Command: CMD-PY-TEST over those five files. Write FEATURE/evidence/regression-testing/codex-surface-contracts.TS.md. Acceptance: exit 0 and no FAILED line.
- [x] [P8-T10] Commit and push Phase 8. Commands: CMD-GIT-ADD with `.agents/skills/python-change-budget-router/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-powershell-engineer/SKILL.md .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`, CMD-GIT-COMMIT with message "docs(773): remove per-batch text from Codex and .agents Python surfaces", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.agents/skills .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations` prints nothing and the push exits 0.

### Phase 9 — Follow-up Potential Entries

- [x] [P9-T1] Write `docs/features/potential/2026-09-29-python-execution-only-typed-per-batch-cap.md` per Appendix D1. Acceptance: the Write succeeds without a hook denial; content is verified after commit by P9-T3.
- [x] [P9-T2] Write `docs/features/potential/2026-09-29-generic-orchestrator-test-file-routing-clause.md` per Appendix D2. Acceptance: as P9-T1.
- [ ] [P9-T3] Commit, push, and verify the two entries (AC-29). Commands: CMD-GIT-ADD with the two paths of P9-T1 and P9-T2 and FEATURE, CMD-GIT-COMMIT with message "docs(773): record Python routing follow-up potential entries", CMD-GIT-PUSH; then CMD-GIT-LS over the two paths, CMD-GIT-COUNT with literal `#773` over them, and CMD-GIT-COUNT with literal `## Acceptance Criteria (early draft)` over them. Write FEATURE/evidence/other/follow-up-entries.TS.md. Acceptance: CMD-GIT-LS prints exactly the two paths; each CMD-GIT-COUNT prints two `path:count` lines; no `gh` command is run.

### Phase 10 — Acceptance Searches and Scope Guards

- [ ] [P10-T1] AC-18 phrase sweep over the Python-path surfaces and mirrors (all targets tracked and committed). Command: the AC-18 sweep of Appendix G. Write FEATURE/evidence/qa-gates/ac18-sweep.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.
- [ ] [P10-T2] AC-19 routing-text check over the seven AC-19 files of Appendix G. Commands: CMD-GIT-COUNT with literal `1-3`, then with literal `more than 3`, then with literal `no production-file cap`, then with literal `not counted toward the routing threshold`, each over the seven files. Write FEATURE/evidence/qa-gates/ac19-routing-text.TS.md. Acceptance: each of the four searches prints exactly seven `path:count` lines, one per file, each count at least 1.
- [ ] [P10-T3] AC-20 test-clause check over the six AC-20 files of Appendix G. Commands: the AC-20 regex search, the AC-20 fixed-string search, then CMD-GIT-COUNT with literal `production Python files` over the six files. Write FEATURE/evidence/qa-gates/ac20-test-clause.TS.md with `ExpectedExitCode: 1` (the negative searches). Acceptance: both negative searches exit 1 with no output; the positive search prints six `path:count` lines.
- [ ] [P10-T4] AC-21 routing-target check. Commands: CMD-GIT-COUNT with literal `python-orchestrator` over `.claude/skills/python-change-budget-router/SKILL.md .claude/skills/invoke-python-engineer/SKILL.md .claude/agents/python-typed-engineer.md`; CMD-GIT-COUNT with literal '`/orchestrate' over the same three files; CMD-GIT-COUNT with literal `.codex/prompts/orchestrate-work.md` over `.agents/skills/python-change-budget-router/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .codex/agents/python-typed-engineer.toml`; CMD-GIT-COUNT with literal `python-orchestrator` over `.github/agents/python-typed-engineer.agent.md`. Write FEATURE/evidence/qa-gates/ac21-routing-target.TS.md. Acceptance: the first search exits 1 with no output; the second and third each print three `path:count` lines; the fourth prints one `path:count` line.
- [ ] [P10-T5] AC-22 input and section check. Commands: CMD-GIT-COUNT with literal `budget: prod=` over the three invoke skills (`.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-powershell-engineer/SKILL.md`) and their three mirrors; CMD-GIT-COUNT with literal `Per-Batch Change Budget` and then with literal `Scope Expansion Protocol` over the two router copies and their two mirrors. Write FEATURE/evidence/qa-gates/ac22-budget-input.TS.md with `ExpectedExitCode: 1`. Acceptance: all three searches exit 1 with no output.
- [ ] [P10-T6] AC-13 helper-name sweep. Command: the AC-13 sweep of Appendix G. Write FEATURE/evidence/qa-gates/ac13-helper-names.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.
- [ ] [P10-T7] AC-15 registration check. Commands: CMD-GIT-LS over CROUTE_OLD and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`; CMD-GIT-COUNT with literal `enforce-powershell-batch-budget-route` over `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json` RUNSET RUNSET_B; CMD-GIT-COUNT with literal `.claude/hooks/enforce-batch-budget-route.ps1` over `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; CMD-GIT-COUNT with literal `.codex/hooks/enforce-batch-budget-route.ps1` over `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over LEGTEST RUNSET RUNSET_B. Write FEATURE/evidence/qa-gates/ac15-registration.TS.md. Acceptance: CMD-GIT-LS prints nothing; the second search exits 1 with no output; the third and fourth each print one `path:1` line; the last prints LEGTEST with count 1 and each runsettings copy with count 2.
- [ ] [P10-T8] AC-12 helper check. Commands: CMD-GIT-COUNT with literal `function ConvertFrom-BatchBudgetCheckpoint`, then `function Get-BatchBudgetSelectedRoute`, then `function Test-BatchBudgetLargePathRoute`, each over CROUTE and XROUTE; CMD-GIT-COUNT with literal `enforce-batch-budget-route.ps1` over CPSHOOK CPYHOOK XPSHOOK XPYHOOK; A13 over the pair CROUTE, XROUTE. Write FEATURE/evidence/qa-gates/ac12-helper.TS.md. Acceptance: each function search prints two `path:1` lines; the dot-source search prints four `path:1` lines; A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P10-T9] AC-16 diff check on the two #769 routing suites. Commands: `git diff --numstat BASE_SHA -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, `git diff -U0 BASE_SHA -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, and `git status --porcelain -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`. Write FEATURE/evidence/qa-gates/ac16-routing-suite-diff.TS.md. Acceptance: the numstat prints exactly two lines, each `2` added and `2` deleted; every `-` content line in the `-U0` output contains `PowerShellBatchBudget` and its paired `+` line is identical except that `PowerShellBatchBudget` reads `BatchBudget`; the status prints nothing.
- [ ] [P10-T10] AC-25 scope check. Commands: `git diff --exit-code BASE_SHA -- .github/copilot-instructions.md .github/instructions .github/agents/python-execution-only-typed.agent.md scripts/dev_tools/resolve_codex_topology.py extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`, `git status --porcelain -- .github/copilot-instructions.md .github/instructions .github/agents/python-execution-only-typed.agent.md scripts/dev_tools/resolve_codex_topology.py extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`, `git diff --name-only BASE_SHA -- "*.py"`, and `git status --porcelain -- "*.py"`. Write FEATURE/evidence/qa-gates/ac25-scope-unchanged.TS.md. Acceptance: the first diff exits 0 with no output, and the other three commands print nothing.
- [ ] [P10-T11] AC-28 docstring check on CPYHOOK and XPYHOOK. Commands: the AC-28 negative search of Appendix G; then CMD-GIT-COUNT with literal `#673`, with literal `stale`, and with literal `PYTHON_LARGE_PATH_REQUIRED`, each over CPYHOOK XPYHOOK. Write FEATURE/evidence/qa-gates/ac28-docstrings.TS.md. Acceptance: the negative search exits 1 with no output; each positive search prints two `path:count` lines, the `PYTHON_LARGE_PATH_REQUIRED` counts each at least 2.
- [ ] [P10-T12] AC-8 source check. Command: CMD-GIT-COUNT with literal `CLAUDE_PYTHON_BUDGET` over CPYHOOK XPYHOOK and their CB and XB copies. Write FEATURE/evidence/qa-gates/ac8-no-env-override.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.
- [ ] [P10-T13] AC-11 temporary-file and live-checkpoint check on CPYRTEST, XPYRTEST, PARTEST, CPYTEST, and XTEST. Commands: the AC-11 negative search of Appendix G; then CMD-GIT-COUNT with literal `Invoke-PythonBatchBudgetHook:ReadCheckpoint` over CPYTEST and CMD-GIT-COUNT with literal `ReadCheckpoint = {` over XTEST. Write FEATURE/evidence/qa-gates/ac11-no-temp-files.TS.md with `ExpectedExitCode: 1` (the negative search). Acceptance: the negative search exits 1 with no output; the CPYTEST count is 2; the XTEST count is 2 (both rows inject an empty checkpoint).

### Phase 11 — Final QA Loop: PowerShell (PoshQC and Pester)

- [ ] [P11-T1] Format: CMD-PS-SCRIPT with script file-hashes (A5) over the fifteen QA files of Appendix H (before); MCP-PS-FORMAT with scan_folders `.claude/hooks`, `.codex/hooks`, `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `scripts/powershell/PoshQC/settings`; the same A5 run (after); CMD-GIT-STATUS-PATH over `.claude/hooks .codex/hooks tests/scripts/claude-hooks tests/scripts/codex-hooks scripts/powershell/PoshQC/settings`; A6 over the fifteen files. Write FEATURE/evidence/qa-gates/powershell-format.TS.md. Acceptance: the MCP call returns without raising; the before and after hashes are identical for all fifteen files; CMD-GIT-STATUS-PATH prints nothing; A6 prints `FORMAT-SUMMARY ChangedCount=0`. If A6 reports `Changed=True` for a file the MCP call left unchanged, stop and report rather than editing by hand.
- [ ] [P11-T2] Analyze the fifteen Appendix H files. Commands: MCP-PS-ANALYZE with the P11-T1 scan_folders, then A7 over the fifteen files. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P11-T3] Run the policy-mandated MCP test step (route compliance only). Command: MCP-PS-TEST. Write FEATURE/evidence/qa-gates/powershell-mcp-test.TS.md. Acceptance: the call returns without raising; the artifact records the call disposition and states that counts and coverage are taken from P11-T4 through P11-T12, because the MCP result carries no test output.
- [ ] [P11-T4] Test with coverage for CPYHOOK, written to FEATURE/evidence/qa-gates/claude-python-hook-coverage.TS.md. Command: A3 with `-TestPath tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-cpy-final.xml -ReportPath SCRATCH/cov-cpy-final.txt`. Acceptance: `TotalCount=66`, `PassedCount=66`, `FailedCount=0`; the CPYHOOK `LinePercent=` is at least 85.
- [ ] [P11-T5] Test with coverage for CPSHOOK and CROUTE, written to FEATURE/evidence/qa-gates/claude-powershell-hook-coverage.TS.md. Command: A3 with `-TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-cps-final.xml -ReportPath SCRATCH/cov-cps-final.txt`. Acceptance: `TotalCount=83`, `PassedCount=83`, `FailedCount=0`; the CPSHOOK and CROUTE `LinePercent=` values are each at least 85.
- [ ] [P11-T6] Test with coverage for XPYHOOK, written to FEATURE/evidence/qa-gates/codex-python-hook-coverage.TS.md. Command: A3 with `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xpy-final.xml -ReportPath SCRATCH/cov-xpy-final.txt`. Acceptance: `TotalCount=68`, `PassedCount=68`, `FailedCount=0`; the XPYHOOK `LinePercent=` is at least 85.
- [ ] [P11-T7] Test with coverage for XPSHOOK and XROUTE, written to FEATURE/evidence/qa-gates/codex-powershell-hook-coverage.TS.md. Command: A3 with `-TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1,.codex/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-xps-final.xml -ReportPath SCRATCH/cov-xps-final.txt`. Acceptance: `TotalCount=83`, `PassedCount=83`, `FailedCount=0`; the XPSHOOK and XROUTE `LinePercent=` values are each at least 85.
- [ ] [P11-T8] Test with coverage for both helper copies through the parity suite, written to FEATURE/evidence/qa-gates/route-helper-coverage.TS.md. Command: A3 with `-TestPath tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 -CoveragePath .claude/hooks/enforce-batch-budget-route.ps1,.codex/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-route-final.xml -ReportPath SCRATCH/cov-route-final.txt`. Acceptance: `TotalCount=55`, `PassedCount=55`, `FailedCount=0`; the CROUTE and XROUTE `LinePercent=` values are each at least 85.
- [ ] [P11-T9] Changed-line coverage against BASE_SHA, written to FEATURE/evidence/qa-gates/changed-line-coverage.TS.md. Commands: A11b with `-CoverageReportPath SCRATCH/cov-cpy-final.txt -BaseRef BASE_SHA -File .claude/hooks/enforce-python-batch-budget.ps1`; A11b with `-CoverageReportPath SCRATCH/cov-cps-final.txt -BaseRef BASE_SHA -File .claude/hooks/enforce-powershell-batch-budget.ps1`; A11b with `-CoverageReportPath SCRATCH/cov-xpy-final.txt -BaseRef BASE_SHA -File .codex/hooks/enforce-python-batch-budget.ps1`; A11b with `-CoverageReportPath SCRATCH/cov-xps-final.txt -BaseRef BASE_SHA -File .codex/hooks/enforce-powershell-batch-budget.ps1`; A11b with `-CoverageReportPath SCRATCH/cov-route-final.txt -BaseRef BASE_SHA -File .claude/hooks/enforce-batch-budget-route.ps1,.codex/hooks/enforce-batch-budget-route.ps1` (BASE_SHA replaced by the recorded commit). Acceptance: six `CHANGED-COVERAGE file=` lines, none `MISSING`, each with numeric `ChangedPercent=` at least 85. `ChangedPercent=NA` fails the threshold and is reported, not waived.
- [ ] [P11-T10] Regression over `tests/scripts/claude-hooks`, written to FEATURE/evidence/qa-gates/pester-claude-hooks.TS.md. Command: A2 with `-Path tests/scripts/claude-hooks`. Acceptance: `TotalCount=` equals the P0-T19 value plus 31 (32 new, 1 removed from CPYTEST), and every `FAILED:` line is a member of the P0-T19 baseline failure set.
- [ ] [P11-T11] Regression over `tests/scripts/codex-hooks`, written to FEATURE/evidence/qa-gates/pester-codex-hooks.TS.md. Command: A2 with `-Path tests/scripts/codex-hooks`. Acceptance: `TotalCount=` equals the P0-T20 value plus 82 (34 XPYRTEST plus 55 PARTEST, minus 7 removed from XTEST); every `FAILED:` line is a member of the P0-T20 baseline failure set; no `FAILED:` line names a test containing "500-line" or "500 lines" (AC-26).
- [ ] [P11-T12] Regression over `tests/scripts/claude-runtime`, written to FEATURE/evidence/qa-gates/pester-claude-runtime.TS.md. Command: A2 with `-Path tests/scripts/claude-runtime`. Acceptance: `TotalCount=` equals the P0-T21 value, and every `FAILED:` line is a member of the P0-T21 baseline failure set.
- [ ] [P11-T13] File-size limit check, written to FEATURE/evidence/qa-gates/line-counts-final.TS.md. Command: A4 over the fifteen Appendix H files and the six bundle hook and helper copies (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`, `.../claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`, `.../claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1`, `.../codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`, `.../codex-and-agents-customizations/.codex/hooks/enforce-batch-budget-route.ps1`) and RUNSET_B. Acceptance: every `LineCount=` value for a `.ps1` file is at most 500 (AC-26); RUNSET and RUNSET_B each equal RUNSET_0 plus 1.
- [ ] [P11-T14] Record the live state after all writes from `.claude/state/`. Command: A10. Write FEATURE/evidence/qa-gates/live-state-final.TS.md. Acceptance: the per-kind sums equal PS_PROD_0, PS_TEST_0, PY_PROD_0, and PY_TEST_0 (P0-T9): no PowerShell write on the large path and no Python write was recorded.

### Phase 12 — Final QA: Python Parity Harness and TypeScript Twin

- [ ] [P12-T1] Run the eleven Appendix F parity suites (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and ten others). Command: CMD-PY-TEST over the eleven files. Write FEATURE/evidence/qa-gates/python-parity.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED or SKIPPED, and that node satisfies KL-510 (AC-24).
- [ ] [P12-T2] Regression over `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/qa-gates/python-dev-tools.TS.md. Acceptance: every `FAILED` line is a member of the P0-T23 baseline failure set, and the collected total (passed plus failed plus skipped) equals the P0-T23 total. The artifact carries ExpectedExitCode: 1 only when the KL-510 node is the only FAILED line and satisfies case (b).
- [ ] [P12-T3] Run the TypeScript manifest-completeness twin (AC-24). Command: CMD-TS-TWIN. Write FEATURE/evidence/qa-gates/ts-manifest-completeness.TS.md. Acceptance: exit 0 and the `Tests:` summary line reports no failed test and a total equal to TS_TOTAL_0.

### Phase 13 — Mirror Check, Coverage Comparison, and Evidence Commit

- [ ] [P13-T1] Final mirror check across the 24 pairs of Appendix E2. Command: A13 over the 24 pairs. Write FEATURE/evidence/qa-gates/mirror-hashes-final.TS.md. Acceptance: `PAIR-SUMMARY pairs=24 unequal=0` (AC-24).
- [ ] [P13-T2] Coverage comparison: write FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the P0-T15 through P0-T18 and P11-T4 through P11-T9 artifacts. Acceptance: the artifact carries, for PowerShell, `Baseline Coverage:` (CPY_BASE_PCT, XPY_BASE_PCT, CPS_BASE_PCT, XPS_BASE_PCT, ROUTE_BASE_PCT for CROUTE_OLD), `Post-Change Coverage:` (the P11-T4 through P11-T8 values for CPYHOOK, CPSHOOK, CROUTE, XPYHOOK, XPSHOOK, XROUTE), `New/Changed-code Coverage:` (the six P11-T9 `ChangedPercent=` values), and `Disposition:`, all numeric. `Disposition:` is `PASS` only when every post-change value and every changed-code value is at least 85; otherwise `BLOCKED`. The artifact states that no Python or TypeScript source file changed (P10-T10) and that PowerShell has no branch-coverage gate.
- [ ] [P13-T3] Commit and push the final QA evidence. Commands: CMD-GIT-STATUS, then CMD-GIT-ADD with FEATURE plus every path CMD-GIT-STATUS listed outside FEATURE (fixes made by Phase 11 loop restarts), CMD-GIT-COMMIT with message "docs(773): record final QA evidence", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS-PATH over `.claude .codex .agents .github tests scripts extensions` prints nothing and the push exits 0.

### Phase 14 — Acceptance-Criteria Check-Off

Each check-off task changes the AC line from `- [ ] AC-n:` to `- [x] AC-n:` in both `FEATURE/spec.md` and `FEATURE/issue.md` (the issue list mirrors the spec list) and records the check-off, with the cited artifacts, in FEATURE/evidence/other/ac-checkoff.TS.md. Its acceptance is the cited artifacts existing with passing acceptance; P14-T30 verifies the line state of both files. An AC whose cited artifacts do not all pass stays unchecked, and the plan outcome is remediation-required.

- [ ] [P14-T1] Check off AC-1 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P2-T2 (fail-before), P3-T5.
- [ ] [P14-T2] Check off AC-2 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P5-T2 (fail-before), P6-T5.
- [ ] [P14-T3] Check off AC-3 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5 and P6-T5 (direct-mode case D3 in each suite).
- [ ] [P14-T4] Check off AC-4 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P6-T5 (large-path cases L1 through L3), P6-T6.
- [ ] [P14-T5] Check off AC-5 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P6-T5 (fallback rows 4 and 5, case L3), P4-T11.
- [ ] [P14-T6] Check off AC-6 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P6-T5 (fallback rows 1 through 9, case S3), P4-T11.
- [ ] [P14-T7] Check off AC-7 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P6-T5 (cases P1 through P3), P3-T6.
- [ ] [P14-T8] Check off AC-8 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P6-T5 (override cases), P0-T28 (non-vacuity), P10-T12.
- [ ] [P14-T9] Check off AC-9 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P3-T6, P3-T7, P6-T5, P6-T8.
- [ ] [P14-T10] Check off AC-10 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P6-T1, P6-T5 (entry-point cases), P6-T8.
- [ ] [P14-T11] Check off AC-11 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P10-T13 and the seam cases of P3-T5 and P6-T5.
- [ ] [P14-T12] Check off AC-12 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P1-T1, P4-T3, P10-T8.
- [ ] [P14-T13] Check off AC-13 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T27 (non-vacuity), P10-T6.
- [ ] [P14-T14] Check off AC-14 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P4-T2 (fail-before), P4-T11, P11-T8.
- [ ] [P14-T15] Check off AC-15 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P1-T15, P10-T7, P4-T15.
- [ ] [P14-T16] Check off AC-16 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P1-T12, P1-T13, P4-T12, P4-T13, P6-T6, P10-T9, P11-T14.
- [ ] [P14-T17] Check off AC-17 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P3-T5, P3-T6, P6-T5, P6-T6, P6-T8.
- [ ] [P14-T18] Check off AC-18 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T25 (non-vacuity), P10-T1.
- [ ] [P14-T19] Check off AC-19 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P10-T2.
- [ ] [P14-T20] Check off AC-20 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T26 (non-vacuity), P10-T3.
- [ ] [P14-T21] Check off AC-21 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P10-T4.
- [ ] [P14-T22] Check off AC-22 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P0-T28 (non-vacuity), P10-T5.
- [ ] [P14-T23] Check off AC-23 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P8-T7, P8-T8, P8-T9.
- [ ] [P14-T24] Check off AC-24 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P12-T1, P12-T3, P6-T8, P13-T1.
- [ ] [P14-T25] Check off AC-25 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P10-T10.
- [ ] [P14-T26] Check off AC-26 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P11-T13, P11-T11, P6-T8.
- [ ] [P14-T27] Check off AC-27 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P11-T1, P11-T2, P11-T4 through P11-T9, P13-T2 (`Disposition: PASS`).
- [ ] [P14-T28] Check off AC-28 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P10-T11.
- [ ] [P14-T29] Check off AC-29 in `FEATURE/spec.md` and `FEATURE/issue.md`. Evidence: P9-T3.
- [ ] [P14-T30] Verify and commit the check-off in `FEATURE/spec.md` and `FEATURE/issue.md`. Commands: CMD-GIT-ADD with FEATURE and CMD-GIT-COMMIT with message "docs(773): check off acceptance criteria"; then CMD-GIT-COUNT with literal `- [x] AC-` over `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/spec.md docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/issue.md`, then CMD-GIT-COUNT with literal `- [ ] AC-` over the same two files; then CMD-GIT-PUSH. Acceptance: the first search prints `spec.md:29` and `issue.md:29` (with their full paths); the second exits 1 with no output; CMD-GIT-STATUS-PATH over `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/spec.md docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/issue.md` prints nothing after the push.

---

## Acceptance Criteria Traceability

| AC | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| AC-1 | P3-T1 | P2-T2 (fail-before), P3-T5 | regression-testing/claude-python-routing-after-fix |
| AC-2 | P6-T1 | P5-T2 (fail-before), P6-T5 | regression-testing/codex-python-routing-after-fix |
| AC-3 | P3-T1, P6-T1 | P3-T5, P6-T5 | regression-testing/claude-python-routing-after-fix, codex-python-routing-after-fix |
| AC-4 | P3-T1, P6-T1 | P3-T5, P6-T5, P6-T6 | regression-testing/codex-python-routing-after-fix |
| AC-5 | P1-T1, P3-T1, P6-T1 | P3-T5, P6-T5, P4-T11 | regression-testing/route-parity-after |
| AC-6 | P1-T1, P3-T1, P6-T1 | P3-T5, P6-T5, P4-T11 | regression-testing/claude-python-routing-after-fix |
| AC-7 | P3-T1, P6-T1 | P3-T5, P3-T6, P6-T5 | regression-testing/claude-python-existing-after-fix |
| AC-8 | P3-T1, P6-T1 | P0-T28, P3-T5, P6-T5, P10-T12 | qa-gates/ac8-no-env-override |
| AC-9 | P3-T1, P6-T1 | P3-T5, P3-T6, P3-T7, P6-T5, P6-T8 | regression-testing/pretooluse-schema |
| AC-10 | P6-T1 | P6-T5, P6-T8 | regression-testing/codex-contracts-p6 |
| AC-11 | P2-T1, P3-T2, P5-T1, P6-T2 | P10-T13 | qa-gates/ac11-no-temp-files |
| AC-12 | P1-T1, P1-T2 through P1-T5, P3-T1, P4-T3, P4-T4, P6-T1 | P10-T8 | qa-gates/ac12-helper |
| AC-13 | P1-T3 through P1-T5, P1-T15, P4-T4, P4-T5 | P0-T27, P10-T6 | qa-gates/ac13-helper-names |
| AC-14 | P4-T1, P4-T3 | P4-T2 (fail-before), P4-T11, P11-T8 | regression-testing/route-parity-after |
| AC-15 | P1-T7 through P1-T9, P1-T15, P4-T6 through P4-T8 | P10-T7, P4-T15 | qa-gates/ac15-registration |
| AC-16 | P1-T2 through P1-T5, P4-T4, P4-T5 | P1-T12, P1-T13, P4-T12, P4-T13, P6-T6, P10-T9 | qa-gates/ac16-routing-suite-diff |
| AC-17 | P2-T1, P3-T2, P4-T6, P5-T1, P6-T2 | P3-T5, P3-T6, P6-T5, P6-T6, P6-T8 | regression-testing/xtest-after-python-fix |
| AC-18 | P3-T1, P6-T1, P7-T1 through P7-T4, P8-T1, P8-T2, P8-T4, P8-T7 | P0-T25, P10-T1 | qa-gates/ac18-sweep |
| AC-19 | P7-T1 through P7-T4, P8-T1, P8-T2, P8-T4 | P10-T2 | qa-gates/ac19-routing-text |
| AC-20 | P7-T5, P7-T6, P8-T5 | P0-T26, P10-T3 | qa-gates/ac20-test-clause |
| AC-21 | P7-T1 through P7-T4, P8-T1, P8-T2, P8-T4 | P10-T4 | qa-gates/ac21-routing-target |
| AC-22 | P7-T1, P7-T2, P8-T1 through P8-T3 | P0-T28, P10-T5 | qa-gates/ac22-budget-input |
| AC-23 | P8-T4, P8-T7 | P8-T8, P8-T9 | qa-gates/codex-variants-check |
| AC-24 | P1-T14, P3-T8, P4-T14, P6-T7, P7-T7, P7-T8, P8-T6, P8-T7 | P12-T1, P12-T3, P6-T8, P13-T1 | qa-gates/mirror-hashes-final |
| AC-25 | (no write to the protected paths) | P10-T10 | qa-gates/ac25-scope-unchanged |
| AC-26 | P3-T1, P4-T4, P6-T1, P6-T2 | P11-T13, P11-T11, P6-T8 | qa-gates/line-counts-final |
| AC-27 | Phases 1, 3, 4, and 6 | P11-T1, P11-T2, P11-T4 through P11-T9, P13-T2 | qa-gates/coverage-comparison |
| AC-28 | P3-T1, P6-T1 | P10-T11 | qa-gates/ac28-docstrings |
| AC-29 | P9-T1, P9-T2 | P9-T3 | other/follow-up-entries |

---

## Appendix A — Scratch Scripts

Scripts are written verbatim under SCRATCH by P0-T6 and never committed. A1 through A13 and A11b are carried from the #769 plan; A10 and A11 are adapted (A10 reports both state kinds; A11 calls the neutral helper names and accepts any script that defines them); A14 is new.

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
$fileCount = 0
foreach ($kind in @('powershell', 'python')) {
    $stateFiles = @(Get-ChildItem -LiteralPath $stateDirectory -Filter "$kind-batch-budget.*.json" -File)
    foreach ($stateFile in $stateFiles) {
        $fileCount++
        $state = Get-Content -Raw -LiteralPath $stateFile.FullName | ConvertFrom-Json
        $prodCount = @($state.prodFiles | Where-Object { $_ }).Count
        $testCount = @($state.testFiles | Where-Object { $_ }).Count
        Write-Output "STATE kind=$kind file=$($stateFile.Name) prodCount=$prodCount testCount=$testCount"
    }
}
Write-Output "STATE-SUMMARY files=$fileCount"
```

A11 route-probe.ps1 (read-only; dot-sourcing a hook runs no entry point because of its `InvocationName` guard):

```powershell
param([Parameter(Mandatory)][string] $ScriptPath, [Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
. (Resolve-Path -LiteralPath $ScriptPath).Path
$checkpointText = Get-Content -Raw -LiteralPath $CheckpointPath
Write-Output "LARGE-PATH-ROUTE=$(Test-BatchBudgetLargePathRoute -CheckpointText $checkpointText)"
Write-Output "SELECTED-ROUTE=$(Get-BatchBudgetSelectedRoute -CheckpointText $checkpointText)"
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

A14 function-names.ps1 (read-only; top-level function definitions only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $file).Path, [ref]$tokens, [ref]$errors)
    $names = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name } | Sort-Object)
    Write-Output "FUNCTIONS file=$file ParseErrors=$(@($errors).Count) Names=$($names -join ',')"
}
```

The P0-T6 smoke artifact lists these 15 file names: run-ps.sh, pester-counts.ps1, pester-coverage.ps1, line-counts.ps1, file-hashes.ps1, ps-format-check.ps1, pssa-count.ps1, psd1-parse.ps1, checkpoint-probe.ps1, budget-state-probe.ps1, route-probe.ps1, changed-line-coverage.ps1, json-parse.ps1, pair-hashes.ps1, function-names.ps1.

---

## Appendix B — Implementation and Test Specifications

### B1 — CROUTE `.claude/hooks/enforce-batch-budget-route.ps1` (XROUTE is its byte copy)

Start from the full text of CROUTE_OLD (137 lines) and change only:

1. The comment-based help block (lines 1-14): `.SYNOPSIS` "Pure route helpers shared by the batch-budget hooks." `.DESCRIPTION`: the functions read the selected route from orchestrator checkpoint text and decide whether that checkpoint selects the uncapped orchestrated large path; the file is dot-sourced by the PowerShell and Python batch-budget hooks and has no entry point; the Claude and Codex runtime copies are byte-identical and a parity test holds them identical; none of the functions reads a file or an environment variable, and the checkpoint text is supplied by the caller. `.NOTES` unchanged. The help text must not contain the character sequence `$env:`.
2. Every occurrence of `ConvertFrom-PowerShellBatchBudgetCheckpoint` becomes `ConvertFrom-BatchBudgetCheckpoint` (definition at line 16 and calls at lines 72 and 113); `Get-PowerShellBatchBudgetSelectedRoute` becomes `Get-BatchBudgetSelectedRoute` (definition line 53, call line 118); `Test-PowerShellBatchBudgetLargePathRoute` becomes `Test-BatchBudgetLargePathRoute` (definition line 92).

Function bodies, parameters, attributes, and comment help of the three functions are otherwise unchanged, so behavior is unchanged (spec "Shared route helper design").

### B2 — CPSHOOK edits (Phase 1)

Only P1-T2 (insert the new dot-source after line 63), P1-T3 (rename the two calls), and P1-T5 (delete line 63). The docstring, functions, and behavior are otherwise unchanged; the file stays 486 lines.

### B3 — CPYHOOK `.claude/hooks/enforce-python-batch-budget.ps1` (complete Write)

Keep unchanged: `Test-PythonBatchBudgetPathInRoot`, `ConvertTo-PythonBatchBudgetSafeSegment`, `Get-PythonBatchBudgetSessionId`, `Get-PythonBatchBudgetBlockDecision` (name, parameters, deny shape), the `Import-Module` of `HookPayload.psm1`, the envelope fail-closed branch and its reason text, the `file_path` and `.py` filters, the session-id resolution call, `Invoke-PythonBatchBudgetEntryPoint`'s payload acquisition, deny-only output, and `state` stripping, and the top-level wiring (current lines 441-454).

Changes (mirroring the post-#769 CPSHOOK structure, `.claude/hooks/enforce-powershell-batch-budget.ps1` lines 1-57 and 185-426):

1. **Docstring** (replaces lines 1-46). `.SYNOPSIS`: "Pre-tool-use hook that routes Python changes of more than three production files to the orchestrated large path." `.DESCRIPTION` in plain sentences: invoked before any Write or Edit; for a `.py` target it decides whether the change may proceed in direct mode; direct mode counts distinct production Python paths per Claude Code session, persisted under `.claude/state/python-batch-budget.<session_id>.json`, counts repeated edits once, and denies the 4th distinct production path with a `PYTHON_LARGE_PATH_REQUIRED` reason instructing the caller to route the change through /orchestrate; the large path is detected from `<root>/artifacts/orchestration/orchestrator-state.json` (selected route is `route_id` when that key is present, otherwise `path_selected`, usable only as a non-blank string; `large`, `remediation`, or `preparation`; not terminal when `next_step` is not `complete` and `completed_steps` does not contain `S12_complete`), where no path is denied for count and no state is read or written; every other checkpoint outcome, including an absent, unreadable, or malformed checkpoint, enforces direct mode; test files (`tests/**/*.py`, `test_*.py`) are never counted; all other `.py` files are production files and non-Python paths pass through; the threshold of three production files is a routing constant and is not configurable at runtime; legacy `prodCap`, `testCap`, and `testFiles` keys are ignored when state is loaded; the session-id resolution and containment paragraphs (current lines 16-27) are kept; on a deny the script emits the PreToolUse deny JSON and exits 0, and files already counted are always allowed; "Known limitation: a stale non-terminal large-path checkpoint left at the root exempts a later direct-mode session at that root. Orchestrator checkpoint hygiene (issue #673) moves foreign checkpoints aside before a new run." The docstring must not contain "per-batch", "per batch", "deleting", "reset the", "new batch", "batch cap", "split the work", "raise the cap", "record an approved cap", or "CLAUDE_PYTHON_BUDGET".
2. Immediately after the `Import-Module` line, add `. (Join-Path $PSScriptRoot 'enforce-batch-budget-route.ps1')`.
3. **`Get-PythonBatchBudgetState`**: the PD3 `SuppressMessageAttribute`; parameters `[Parameter(Mandatory)][int] $ProdCap` and `[int] $TestCap = 0`; returns `[ordered]@{ prodCap = $ProdCap; prodFiles = @() }`.
4. **`ConvertTo-PythonBatchBudgetState`**: the PD3 attribute; `InputObject` (mandatory), `ProdCap` (mandatory), `[int] $TestCap = 0`, and `Root` (unchanged default); a two-line comment stating that only `prodFiles` is carried over and legacy keys are ignored; builds `Get-PythonBatchBudgetState -ProdCap $ProdCap` and copies only `prodFiles` through the existing containment filter; never reads `prodCap`, `testCap`, or `testFiles` from the input.
5. **`Invoke-PythonBatchBudgetDecision`**: the PD3 attribute; parameters `FilePath` (mandatory), `State` (mandatory), `[AllowEmptyString()][string] $StateFile = ''`, `[int] $TestCap = 0`, `Root` (unchanged default), `[switch] $LargePathRoute`, `[AllowEmptyString()][string] $ObservedRoute = ''`. Order: `.py` filter (allow, no write); out-of-root discard (allow, no write; unchanged `Write-Verbose`); if `LargePathRoute`, allow with `shouldWriteState = $false`; if the path is a test path (unchanged D2 regexes), allow with `shouldWriteState = $false`; if already in `prodFiles`, allow without write; if `@($State.prodFiles).Count -ge [int]$State.prodCap`, `Write-Verbose` a line naming `$StateFile`, then deny through `Get-PythonBatchBudgetBlockDecision -Reason <message> -State $State`; otherwise append to `prodFiles` and allow with `shouldWriteState = $true`. Message, with `<cap>` = `$State.prodCap`, `<counted>` = `prodFiles` joined by `, `, `<route>` = `$ObservedRoute` or `none` when blank: `PYTHON_LARGE_PATH_REQUIRED: this change touches more than <cap> production Python files (already counted: <counted>; requested: <normalized path>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route>.`
6. **`Invoke-PythonBatchBudgetHook`**: drop `-TestCap`; keep `-ProdCap = 3` and every existing seam; add `[scriptblock] $ReadCheckpoint` whose default returns `Get-Content -LiteralPath $Path -Raw` when `Test-Path -LiteralPath $Path -PathType Leaf` is true and `''` otherwise. After the `.py` filter, compute `$stateDir`, the session id (unchanged call), and `$stateFile`; then, before any `TestPathExists`/`EnsureDirectory` call, read `Join-Path -Path $Root -ChildPath 'artifacts/orchestration/orchestrator-state.json'` through `ReadCheckpoint` inside `try`/`catch` (any exception yields `''` and a `Write-Verbose` line); compute `$isLargePath = Test-BatchBudgetLargePathRoute -CheckpointText $checkpointText` and `$observedRoute = Get-BatchBudgetSelectedRoute -CheckpointText $checkpointText`. If `$isLargePath`, return `Invoke-PythonBatchBudgetDecision -FilePath $filePath -State (Get-PythonBatchBudgetState -ProdCap $ProdCap) -StateFile $stateFile -Root $Root -LargePathRoute` without calling `TestPathExists`, `EnsureDirectory`, `ReadState`, or `WriteState`. Otherwise ensure the directory, load state (`ConvertTo-PythonBatchBudgetState -InputObject $loaded -ProdCap $ProdCap -Root $Root`), and call the decision with `-ObservedRoute $observedRoute`, then write state as today.
7. **`Invoke-PythonBatchBudgetEntryPoint`**: delete the `$prodCap`/`$testCap` block (current lines 423-430) and call `Invoke-PythonBatchBudgetHook -ToolInputRaw $ToolInputRaw -SessionId $sessionId`.

### B4 — CPYRTEST `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` (32 cases)

Structure: comment-based help stating the covered behaviors and that every state and checkpoint operation runs through in-memory seams (no file created or written; the only file reads are the read-only source scan in O4); `Set-StrictMode -Version Latest`; one `Describe 'enforce-python-batch-budget.ps1 large-path routing'`. `BeforeAll` dot-sources CPYHOOK (resolved from `$PSScriptRoot` as CPYTEST line 10 does) and defines:

- `$script:ThreeProductionPaths = '{"prodFiles":["src/a.py","scripts/b.py","src/c.py"]}'`.
- `Get-RoutingToolInput -FilePath` (a `Write` envelope, as CPYTEST lines 14-21).
- `Initialize-RoutingStore [-PersistedText]` setting `$script:RoutingStore = @{ Text = $PersistedText; Writes = 0; Ensures = 0; Reads = 0; Probes = 0; CheckpointReads = 0; CheckpointPath = '' }`.
- `Get-RoutingStateSeam` returning the four state seams: `TestPathExists` increments `Probes` and returns `$null -ne $script:RoutingStore.Text`; `EnsureDirectory` increments `Ensures`; `ReadState` increments `Reads` and returns `Text`; `WriteState` increments `Writes` and stores `$State | ConvertTo-Json -Compress -Depth 5` in `Text`.
- `Get-RoutingCheckpointSeam` returning a scriptblock that increments `CheckpointReads`, records `CheckpointPath`, and returns `$script:RoutingCheckpointText`.
- `Invoke-RoutedHook -FilePath -CheckpointText` (sets `$script:RoutingCheckpointText`, then calls `Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-RoutingToolInput -FilePath $FilePath) -SessionId 'routing' -Root '/repo' -ReadCheckpoint (Get-RoutingCheckpointSeam) @seams`).
- `Get-RoutedDenyReason -CheckpointText` (initializes the store, sends `src/a.py`, `scripts/b.py`, `src/c.py`, then returns the reason for `src/d.py`).

`BeforeEach` calls `Initialize-RoutingStore` and saves `$env:CLAUDE_PYTHON_BUDGET_PROD` and `$env:CLAUDE_PYTHON_BUDGET_TEST` into `$script:PriorProdBudget` and `$script:PriorTestBudget`; `AfterEach` restores both variables from those saved values. Seam parameters a scriptblock does not use are consumed with `[void] $Path`. Helper verbs avoid `New`, `Set`, `Reset`, `Remove`, `Update`.

Context 'direct mode' — 13 cases:
- D1 'allows the first three distinct production paths and denies the 4th with no checkpoint': `src/a.py`, `scripts/b.py`, `src/c.py` allowed; `src/d.py` denied; checkpoint text `''`.
- D2 'names the routing target, counted paths, requested path, and observed route': with `{"route_id":"small"}` the reason is like `PYTHON_LARGE_PATH_REQUIRED:*`, contains `/orchestrate`, `src/a.py, scripts/b.py, src/c.py`, `requested: src/d.py`, and `Checkpoint route observed: small.`; with `''` it contains `Checkpoint route observed: none.`.
- D3 'omits every prohibited remedy phrase and the state-file path from the deny reason': the reason is like `PYTHON_LARGE_PATH_REQUIRED:*` and, for each of `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, `.claude/state`, is not like `*<phrase>*`.
- D4 'allows a repeated production path without a state write': persisted `{"prodFiles":["src/a.py"]}`; request `src/a.py` with `''`; allow; `Writes` 0.
- DF '<Name> checkpoint enforces direct mode for the 4th production path' `-ForEach` nine rows (Name, Text): 1 `route_id small` `{"route_id":"small"}`; 2 `terminal next_step complete` `{"route_id":"large","next_step":"complete"}`; 3 `terminal S12_complete` `{"route_id":"large","completed_steps":["S11_pr_created","S12_complete"]}`; 4 `null route_id with path_selected large` `{"route_id":null,"path_selected":"large"}`; 5 `blank route_id with path_selected large` `{"route_id":"   ","path_selected":"large"}`; 6 `unknown route` `{"route_id":"epic"}`; 7 `malformed` `{not-json`; 8 `non-object` `[1,2]`; 9 `empty` (empty string). Each: store initialized with `$script:ThreeProductionPaths`; `{ $script:FallbackDecision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText $Text } | Should -Not -Throw`; the decision is `deny` with a reason like `PYTHON_LARGE_PATH_REQUIRED:*`.

Context 'large path' — 5 cases:
- L1 '<Route> route allows six distinct production paths without touching state' over `large`, `remediation`, `preparation` (3 cases): `src/a.py` through `src/f.py` each allowed with `{"route_id":"<Route>"}`; `Writes`, `Ensures`, `Reads`, and `Probes` are all 0.
- L2 'the decision with LargePathRoute allows without recording': state `Get-PythonBatchBudgetState -ProdCap 1` with `prodFiles` `@('src/a.py')`; `Invoke-PythonBatchBudgetDecision -FilePath 'src/e.py' -State $state -Root '/repo' -LargePathRoute` allows, `shouldWriteState` false, `prodFiles` count 1.
- L3 'a path_selected-only large checkpoint allows the 4th production path': persisted three paths; `{"path_selected":"large"}`; `src/d.py` allowed; `Writes` 0.

Context 'test paths' — 3 cases:
- P1 'allows five distinct tests/ paths in direct mode without recording them': `tests/unit/test_a.py` through `tests/unit/test_e.py` with `''`; five allows; `Writes` 0.
- P2 'allows a root-level test_ file after three production paths without recording it': persisted three paths; `test_a.py` with `''`; allow; `Writes` 0.
- P3 'allows both test path forms on the large path without touching state': `tests/unit/test_a.py` and `test_a.py` with `{"route_id":"large"}`; both allow; `Writes` and `Ensures` 0.

Context 'removed cap overrides' — 5 cases:
- O1 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path': persisted `{"prodCap":10,"testCap":10,"prodFiles":["src/a.py","scripts/b.py","src/c.py"],"testFiles":["tests/unit/test_x.py"]}`; `src/d.py` with `''` denied with the prefix and no exception.
- O2 'a persisted prodCap below the default does not lower the threshold': persisted `{"prodCap":1,"prodFiles":["src/a.py"]}`; `scripts/b.py` with `''` allowed; `Writes` 1.
- O3 'ignores CLAUDE_PYTHON_BUDGET_PROD and _TEST set in the test scope': both set to `10`; persisted three paths; `src/d.py` denied.
- O4 'the hook and helper sources contain no CLAUDE_PYTHON_BUDGET reference': `Get-Content -Raw` of CPYHOOK and of `enforce-batch-budget-route.ps1` in the same directory, each not like `*CLAUDE_PYTHON_BUDGET*` (read-only).
- O5 'a fresh state carries no test-file keys': `(Get-PythonBatchBudgetState -ProdCap 3).Contains('testFiles')` and `.Contains('testCap')` are both false.

Context 'checkpoint seam' — 6 cases:
- S1 'the default reader yields direct mode when the checkpoint file is absent': `Invoke-PythonBatchBudgetHook` with `-Root 'C:/synthetic-absent-root'`, no `ReadCheckpoint` argument, state seams holding three paths; `src/d.py` denied with the prefix.
- S2 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root': after one routed call, `($script:RoutingStore.CheckpointPath -replace '\\', '/')` is `/repo/artifacts/orchestration/orchestrator-state.json`.
- S3 'treats a throwing checkpoint reader as direct mode without raising': a `ReadCheckpoint` that throws; three persisted paths; `src/d.py` denied; the call is wrapped in `Should -Not -Throw`.
- S4 'still denies an unreadable envelope when the checkpoint route is large': `-ToolInputRaw ''` with a reader returning `{"route_id":"large"}`; deny with a reason like `*empty payload*`.
- S5 'does not read the checkpoint for a non-Python path': `README.md` routed with `{"route_id":"large"}`; allow; `CheckpointReads` 0.
- S6 'does not read the checkpoint when the envelope carries no file_path': `Invoke-PythonBatchBudgetHook -ToolInputRaw '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' -SessionId 'routing' -Root '/repo' -ReadCheckpoint (Get-RoutingCheckpointSeam) @seams`; allow; `CheckpointReads` 0.

Count: 13 + 5 + 3 + 5 + 6 = 32. Against the unfixed hook every case fails (the unfixed hook has no `ReadCheckpoint` or `LargePathRoute` parameter, requires `-TestCap`, still references `CLAUDE_PYTHON_BUDGET`, and emits the old deny text).

### B5 — CPYTEST edits (`tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`)

Line numbers refer to the file before P3-T2 (485 lines); apply the edits from the bottom of the file upward.

1. Replace line 136 with `        $result.state.Contains('testFiles') | Should -BeFalse`.
2. Delete lines 88-98 (the test-cap deny case and the blank line after it).
3. Replace line 83 with `        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'`.
4. Replace lines 53-62 with the case 'allows a new test file without recording it': the same arrange and act lines; asserts `permissionDecision` is `allow`, `shouldWriteState` is false, `$result.state.Contains('testFiles')` is false, and `$result.state.prodFiles` is null or empty (10 lines).
5. After line 39 (end of `AfterEach`), insert four lines: a blank line, `    AfterAll {`, `        $null = $PSDefaultParameterValues.Remove('Invoke-PythonBatchBudgetHook:ReadCheckpoint')`, `    }`.
6. After line 31 (the last `BeforeAll` statement), insert three lines: a blank line; the comment `        # Hook calls read an empty checkpoint unless a case supplies its own reader; the stored value returns the reader because PowerShell evaluates a scriptblock default before binding it.`; and `        $PSDefaultParameterValues['Invoke-PythonBatchBudgetHook:ReadCheckpoint'] = { { param([string] $Path) [void] $Path; '' } }`.

No case is added. Result: 34 cases, 481 lines. The `CLAUDE_PYTHON_BUDGET_*` lines 37-38 and the entry-point case at lines 474-483 are unchanged (malformed JSON denies before any count logic).

### B6 — PARTEST `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` (55 cases)

Header `#Requires -Version 7.0` and the Pester `#Requires` line (as XTEST lines 1-2); comment help stating that the suite binds the Claude and Codex copies of the route helper and reads both files read-only; `Set-StrictMode -Version Latest`; `Describe 'batch-budget route helper parity'`. `BeforeAll` sets `$script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path`.

- 'keeps the Claude and Codex route helpers byte-identical' (1 case): SHA256 of `<RepoRoot>/.codex/hooks/enforce-batch-budget-route.ps1` equals SHA256 of `<RepoRoot>/.claude/hooks/enforce-batch-budget-route.ps1`.
- `Context 'the <Runtime> route helper' -ForEach @(@{ Runtime = 'Claude'; RelativePath = '.claude/hooks/enforce-batch-budget-route.ps1' }, @{ Runtime = 'Codex'; RelativePath = '.codex/hooks/enforce-batch-budget-route.ps1' })`, whose `BeforeAll` resolves `$script:HelperPath` from `$script:RepoRoot` and `$RelativePath` and dot-sources it. Per runtime (27 cases):
  - 'loads the route functions from its own file': `(Get-Command Test-BatchBudgetLargePathRoute).ScriptBlock.File` equals `$script:HelperPath`.
  - 'defines exactly the three neutral route functions': the top-level `FunctionDefinitionAst` names of `$script:HelperPath` (parsed with `[System.Management.Automation.Language.Parser]::ParseFile`), sorted, equal `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, `Test-BatchBudgetLargePathRoute`.
  - `It '<Name>'` over the 21 route-predicate rows of CPSRTEST lines 103-123 (same Name, Text, Expected values), asserting `Test-BatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected`.
  - `It 'selects <Expected> from <Text>'` over the 4 rows of CPSRTEST lines 131-134, asserting `Get-BatchBudgetSelectedRoute -CheckpointText $Text | Should -Be $Expected`.

Count: 1 + 2 x (1 + 1 + 21 + 4) = 55.

### B7 — XPSHOOK `.codex/hooks/enforce-powershell-batch-budget.ps1` (complete Write)

The current 461-line file with exactly two changes: (a) lines 53-174 (the three inline route functions) are replaced by the two lines `# Shared route helpers; this file is byte-identical to the Claude runtime copy.` and `. (Join-Path $PSScriptRoot 'enforce-batch-budget-route.ps1')`, keeping blank line 52 before them and blank line 175 after them; (b) on the two call lines (current 351-352), `Test-PowerShellBatchBudgetLargePathRoute` becomes `Test-BatchBudgetLargePathRoute` and `Get-PowerShellBatchBudgetSelectedRoute` becomes `Get-BatchBudgetSelectedRoute`. Result: 341 lines; behavior unchanged.

### B8 — XPYRTEST `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` (34 cases)

Structure as B4, with the `#Requires` lines of XTEST lines 1-2, dot-sourcing XPYHOOK from `$PSScriptRoot/../../../.codex/hooks`. Helpers (as XPSRTEST lines 27-105 with Python paths): `Get-CodexRoutingToolInput -FilePath` returns `@{ file_path = $FilePath } | ConvertTo-Json -Compress`; `Initialize-CodexRoutingStore` with the B4 counters; `Get-CodexRoutingSeam [-IncludeCheckpoint]` returns the four B4 state seams and, with the switch, the counting `ReadCheckpoint` seam; `Invoke-CodexRoutedHook -FilePath -CheckpointText` calls the Codex `Invoke-PythonBatchBudgetHook -ToolInputRaw ... -SessionId 'routing' -Root '/repo' @seams`; `Get-CodexRoutingPayload -FilePath [-SessionId 'routing-entry']` returns a `Write` payload `{"session_id":...,"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":...,"content":"x"}}`; `Get-CodexRoutedDenyReason` as B4. `BeforeEach` calls `Initialize-CodexRoutingStore`. No environment variable is read or written.

- Direct mode (13): D1, D4, and DF (nine rows) as B4; D2 asserts `.codex/prompts/orchestrate-work.md` in place of `/orchestrate`; D3 as B4 with `.codex/state` in place of `.claude/state`.
- Large path (5): L1 (3) and L3 as B4; L2 as B4 without `-Root` (the Codex decision has no containment parameter).
- Test paths (3): P1, P2, P3 as B4.
- Overrides (4): O1 and O2 as B4; O3 'a fresh state carries no test-file keys'; O4 'ConvertTo state ignores persisted prodCap, testCap, and testFiles': `ConvertTo-PythonBatchBudgetState -InputObject ('{"prodCap":10,"testCap":10,"prodFiles":["a.py"],"testFiles":["tests/b.py"]}' | ConvertFrom-Json) -ProdCap 3` gives `prodCap` 3, `prodFiles` containing `a.py`, and no `testFiles` key.
- Seam (6): S1, S2, S3, S5 as B4; S4 'still denies malformed tool_input JSON when the checkpoint route is large': `-ToolInputRaw 'not json'` with a reader returning `{"route_id":"large"}`; deny with a reason like `*malformed JSON*`; S6 'does not read the checkpoint when tool_input carries no file_path': `-ToolInputRaw '{"content":"x"}'` with the counting reader; allow; `CheckpointReads` 0.
- Entry point (3), using `Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw <payload> -RepositoryRoot '/repo' -HookSeams <seams with checkpoint>`:
  - E1 'allows a Write payload for a production path under a large-route checkpoint without output or state write': result array has one element, `[int]` 0; `Writes` and `Ensures` 0.
  - E2 'emits a deny envelope without a state property for the 4th production path in direct mode': persisted three paths, checkpoint `''`, payload for `src/d.py`; the last element is 0; the preceding element parses as JSON with `permissionDecision` `deny`, a reason like `PYTHON_LARGE_PATH_REQUIRED:*`, and no `state` property.
  - E3 'returns exit code 2 and writes stderr for an empty payload': `-PayloadRaw ''` with `[System.Console]::SetError` redirected to a `StringWriter` and restored in `finally` (as XPSRTEST lines 368-380); the returned value is 2 and the captured stderr matches `enforce-python-batch-budget hook input is empty`.

Count: 13 + 5 + 3 + 4 + 6 + 3 = 34. Against the unfixed hook every case fails (no `ReadCheckpoint`, `LargePathRoute`, or entry-point function; `-TestCap` mandatory; old deny text).

### B9 — XPYHOOK `.codex/hooks/enforce-python-batch-budget.ps1` (complete Write)

Mirror B3 semantics with these Codex specifics, following the post-P4 XPSHOOK structure: keep the leading blank line, `[CmdletBinding()] param()`, and the dot-source of `codex-pretooluse-file-mapping.ps1` with its comment; add `# Shared route helpers; this file is byte-identical to the Claude runtime copy.` and `. (Join-Path $PSScriptRoot 'enforce-batch-budget-route.ps1')`. Docstring as B3 with "Codex session", state under `.codex/state/python-batch-budget.<session_id>.json`, routing target `.codex/prompts/orchestrate-work.md`, no session-id or containment paragraphs, and the same "Known limitation" paragraph naming issue #673; the same prohibited-phrase list applies. `Get-PythonBatchBudgetState` per B3 item 3; `ConvertTo-PythonBatchBudgetState` per B3 item 4 without `Root` and containment (copies `prodFiles` as-is); `Get-PythonBatchBudgetBlockDecision` unchanged; `Invoke-PythonBatchBudgetDecision` per B3 item 5 without `Root` and the out-of-root branch, with the routing sentence `Route the change through .codex/prompts/orchestrate-work.md.`; `Invoke-PythonBatchBudgetHook` keeps `SessionId = 'default'`, `Root = (Get-Location).Path`, `ProdCap = 3`, the four state seams, the empty-input allow, the malformed-JSON deny (reason text unchanged), and the `file_path` and `.py` filters, drops `TestCap`, and adds `ReadCheckpoint` with the B3 item 6 flow (state file `python-batch-budget.$SessionId.json`; checkpoint read after the `.py` filter; the large path returns before `TestPathExists`/`EnsureDirectory`). New `Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw -RepositoryRoot [-HookSeams <hashtable> = @{}]`, a copy of `Invoke-PowerShellBatchBudgetCodexEntryPoint` (XPSHOOK lines 384-448) with `-HookName 'enforce-python-batch-budget'`, the Python hook call `Invoke-PythonBatchBudgetHook -ToolInputRaw $toolInputRaw -SessionId $sessionId -Root $RepositoryRoot @HookSeams`, and Python wording in its help. Top-level wiring after the `InvocationName` guard: `$entryPointResult = @(Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()) -RepositoryRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))`, write every element except the last, then `exit ([int]$entryPointResult[-1])`. No `$env:CLAUDE_` read.

### B10 — XTEST edits (`tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`)

Line numbers refer to the file before P6-T2; apply from the bottom upward.

1. Delete lines 275-370 (the blank line after the shared Context and the whole Python-only Context); line 371 closes the Describe.
2. Replace line 80 `            ExtraSeams = @{}` with `            ExtraSeams = @{ ReadCheckpoint = { param([string] $Path) [void] $Path; '' } }` (the PowerShell row's line 90 form).
3. Replace line 5 with `    Unit coverage for the two Codex batch-budget PreToolUse hooks`.
4. Replace lines 10-13 with the four lines `    Context-level -ForEach, dispatching by function name. Both rows inject an empty`, `    orchestrator checkpoint through ExtraSeams, so neither reads a host checkpoint.`, `    The routing cases for each hook live in codex-python-batch-budget-routing.Tests.ps1`, `    and codex-powershell-batch-budget-routing.Tests.ps1.`.

The Describe name is unchanged. Result: 17 shared cases times 2 rows, 34 in total, 275 lines. The surviving intent of the deleted Python-only cases is carried by B8 (O1 through O4, D1, P1, P2).

### B11 — Other test and registration edits

- LEGTEST line 30 (P4-T6), CPSRTEST lines 125 and 136 (P1-T4), XPSRTEST lines 136 and 147 (P4-T5): exactly as stated in those tasks.
- Manifests and runsettings: P1-T7, P1-T8, P1-T9, P4-T7, P4-T8.

---

## Appendix C — Text Surface Edits

Every edit replaces the named line's full text with the new text shown and changes nothing else in the file. ASCII hyphens are used (`1-3`, never an en dash). Line numbers refer to each file before its edit task; apply a file's edits from the highest line number downward. Every `/orchestrate` occurrence is written with a leading backtick.

C1 `.claude/skills/python-change-budget-router/SKILL.md` — complete file, in this order:
- Front matter: `name: python-change-budget-router`; `description: Budget-first routing contract for Python work. Estimate production-file scope, choose small vs large path, and route direct-mode work of more than 3 production files to the orchestrated large path.`
- `# Python Change Budget Router`, then: `Canonical guidance for deciding whether Python work stays on the small path (\`python-typed-engineer\` direct mode) or escalates to the orchestrated large path through \`/orchestrate\` (the \`orchestrator\` agent).`
- `## When to Use This Skill` with the current lines 12-16 (the executor batch-check bullet at line 17 is dropped).
- `## Canonical Routing Rules`: current line 21; `2. Route:`; the current line 23 bullet; `   - More than 3 production files → **large path** (\`/orchestrate\`, the \`orchestrator\` agent). The large path has no production-file cap.`; `3. Test files are not counted toward the routing threshold.`
- `## Direct-Mode Rejection Rule`: `If \`python-typed-engineer\` is invoked directly and the estimated scope, or the scope discovered during implementation, is more than 3 production files:` followed by the bullets `- Stop before editing the 4th production file.`, `- Report the production files already changed and the production files still required.`, `- Return an explicit routing instruction to invoke \`/orchestrate\`.`, `- Do not request an exception to the threshold; routing is the only path past it.`
- `## Orchestrated Small-Path Requirements`: `When routed through \`/orchestrate\`, the small path still requires lifecycle scaffolding before implementation:` followed by current lines 61-70 unchanged.
- `## Documentation Expectations`: current lines 74-78 unchanged (line 79 is dropped).
- The "Per-Batch Change Budget (Hard Gate)" and "Scope Expansion Protocol" sections (current lines 26-49) are not carried over.

C2 `.claude/skills/invoke-python-engineer/SKILL.md`:
- line 26: delete.
- line 18: `If the estimated scope is more than 3 production files, this skill defers to the orchestrated large path (\`/orchestrate\`) via \`python-change-budget-router\` instead of proceeding directly. The large path has no production-file cap, and test files are not counted toward the routing threshold.`
- line 3: `description: Invoke the python-typed-engineer worker to design, implement, and verify Python changes within typed repository boundaries. Applies Black -> Ruff -> Pyright -> Pytest toolchain, the 1-3 production-file direct-mode budget with routing to the orchestrated large path above it, and zero-regression quality gates.`

C3 `.claude/agents/python-typed-engineer.md`:
- line 61: `- the scope estimate exceeds 3 production files in direct mode,`
- line 40: `2. **Routing and scope** — apply \`python-change-budget-router\` to estimate scope and select direct mode (1-3 production files) or, for more than 3 production files, large-path escalation through \`/orchestrate\`. The large path has no production-file cap, and test files are not counted toward the routing threshold.`
- line 4: `description: Project-scoped worker that implements and verifies Python changes within typed repository boundaries. Applies the Black -> Ruff -> Pyright -> Pytest toolchain, the 1-3 production-file direct-mode budget with routing to the orchestrated large path above it, and zero-regression quality gates.`

C4 `.github/agents/python-typed-engineer.agent.md`:
- line 138: `Before exiting Phase B, perform a quick line-count check on all in-scope files. If any file is near the 500-line limit or planned additions would push it over 500, decide upfront to split now (counting new files against the budget) before Phase C. If uncertain, treat it as at-risk and plan for a split rather than discovering it mid-execution. If an approved plan would create a 500-line violation, halt and seek clarification before proceeding.`
- lines 78-80: replace with the two lines `- Direct mode budget: 1-3 production Python files (+ corresponding tests). A change of more than 3 production Python files belongs on the orchestrated large path (\`python-orchestrator\`).` and `- Test files are not counted toward the routing threshold, and the orchestrated large path has no production-file cap.`
- line 76: `## 2) Change budget (routing threshold)`
- line 66: `- If the change requires more than 3 production files, stop and instruct the caller to use \`python-orchestrator\` (or \`.github/prompts/orchestrate-python-work.prompt.md\`). The orchestrated large path has no production-file cap.`
- line 62: `- Within the direct-mode budget, a slice may include production files beyond the primary module only when it is required to:`
- line 61: `- Default scope is **one feature slice** (typically **1-3 production files** within the same package) plus its corresponding test file(s).`
- Lines 63-65 and the scope-expansion STOP block (lines 67-74) are kept.

C5 `.github/agents/python-orchestrator.agent.md`:
- line 246: `## Large path (budget >3 production Python files)`
- line 129: `## Small path (budget 1-3 production Python files)`
- line 120: `1. Read user request and infer likely touched production Python files.`
- line 100: `- If estimate is more than 3 (\`>3\`) production Python files, use **large path**. The large path has no production-file cap. Test files are not counted toward the routing threshold.`

C6 `.github/prompts/orchestrate-python-work.prompt.md`:
- line 26: `3. If budget is **more than 3 production Python files**:`
- line 24: `2. If budget is **1-3 production Python files** (+ corresponding tests):`
- line 23: `1. Estimate rough change budget first (production Python files; test files are not counted toward the routing threshold).`

C7 `.agents/skills/python-change-budget-router/SKILL.md` — complete file identical to C1 except: the intro ends `... or escalates to the orchestrated large path through \`.codex/prompts/orchestrate-work.md\`.`; the large-path rule reads `   - More than 3 production files → **large path** (\`.codex/prompts/orchestrate-work.md\`). The large path has no production-file cap.`; the rejection bullet reads `- Return an explicit routing instruction to invoke \`.codex/prompts/orchestrate-work.md\`.`; the small-path lead line keeps `When routed through the orchestrator, the small path still requires lifecycle scaffolding before implementation:`; and the first small-path bullet keeps this copy's current line 62 (MCP wording). The text contains no `/orchestrate` token other than inside `.codex/prompts/orchestrate-work.md`.

C8 `.agents/skills/invoke-python-engineer/SKILL.md`:
- line 26: delete.
- line 18: `If the estimated scope is more than 3 production files, this skill defers to the orchestrated large path (\`.codex/prompts/orchestrate-work.md\`) via \`python-change-budget-router\` instead of proceeding directly. The large path has no production-file cap, and test files are not counted toward the routing threshold.`
- line 3: `description: Invoke the python-typed-engineer worker to design, implement, and verify Python changes within typed repository boundaries. Applies Black, Ruff, Pyright, and Pytest with a 1-3 production-file direct-mode budget, routing to the orchestrated large path above it, and zero-regression quality gates.`

C9 `.codex/agents/python-typed-engineer.toml`:
- line 89: `- the scope estimate exceeds 3 production files in direct mode,`
- line 68: the C3 line 40 text with `\`/orchestrate\`` replaced by `\`.codex/prompts/orchestrate-work.md\``.
- line 32: the C3 line 4 text.

C10 `.codex/agents/python-orchestrator.toml`:
- line 31: `- Large path is required for more than 3 (\`>3\`) production Python files. The large path has no production-file cap.`
- line 18: `- Estimate change budget from likely affected Python production files before selecting a path; test files are not counted toward the routing threshold.`

C11 `.agents/skills/invoke-powershell-engineer/SKILL.md`: delete line 26 only (P8-T3).

---

## Appendix D — Follow-up Potential Entries

Each entry uses the headings `# <slug> (Potential Bug)`, a metadata list (`- Date captured: 2026-09-29`, `- Author: Dan Moisan`, `- Status: Draft`, `- Related: #773, #769`), then `## Summary`, `## Scope`, `## Acceptance Criteria (early draft)`, `## Constraints & Risks`, and `## Next Step` (unchecked items: promote through the MCP promotion tool; create the active feature folder). No `gh` command is run.

- D1 `docs/features/potential/2026-09-29-python-execution-only-typed-per-batch-cap.md` (slug `python-execution-only-typed-per-batch-cap`): `.github/agents/python-execution-only-typed.agent.md` lines 34-37 and its GB copy carry a separate 30 production / 30 test per-batch cap and a `budget: prod=<N>, test=<M>` override, and line 84 offers "seek an override"; #773 excluded the agent (spec Out of scope); no routing surface delegates to it and `.codex/agents/python-execution-only-typed.toml` carries no budget text. An owner decision is required: align it with the routing model, retain it as a distinct execution-only budget, or remove it. Draft criteria: the owner decision is recorded; if aligned, the #773 AC-18 phrase search returns no match in the agent file and its mirror, and the pair stays byte-identical.
- D2 `docs/features/potential/2026-09-29-generic-orchestrator-test-file-routing-clause.md` (slug `generic-orchestrator-test-file-routing-clause`): `.github/agents/orchestrator.agent.md` lines 117 and 283 and `.github/prompts/orchestrate-work.prompt.md` line 37 route to the large path on more than 3 test files, while #769 and #773 route on production files only and the Codex resolver routes only on production count; scope is the two files and their GB mirrors; the C# surfaces carry the same clause (`.github/agents/csharp-orchestrator.agent.md` lines 102 and 248, `.github/prompts/orchestrate-csharp-work.prompt.md` line 37, `.github/skills/csharp-change-budget-router/SKILL.md` line 22) and are noted as related. Draft criteria: the #773 AC-20 regex search returns no match in the two files and their mirrors; the mirrors stay byte-identical.

---

## Appendix E — Mirror Pairs (primary, then mirror)

E1 (baseline, P0-T11, 23 pairs):

1. `.claude/hooks/enforce-powershell-batch-budget.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
2. `.claude/hooks/enforce-powershell-batch-budget-route.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`
3. `.claude/hooks/enforce-python-batch-budget.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
4. `.codex/hooks/enforce-powershell-batch-budget.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`
5. `.codex/hooks/enforce-python-batch-budget.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1`
6. `.codex/hooks/codex-pretooluse-file-mapping.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-pretooluse-file-mapping.ps1` (unchanged dependency)
7. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` / `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
8. `.claude/skills/python-change-budget-router/SKILL.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-change-budget-router/SKILL.md`
9. `.claude/skills/invoke-python-engineer/SKILL.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`
10. `.claude/agents/python-typed-engineer.md` / `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`
11. `.agents/skills/python-change-budget-router/SKILL.md` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-change-budget-router/SKILL.md`
12. `.agents/skills/invoke-python-engineer/SKILL.md` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`
13. `.agents/skills/invoke-powershell-engineer/SKILL.md` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`
14. `.codex/agents/python-typed-engineer.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml`
15. `.codex/agents/python-typed-engineer-c1.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml`
16. `.codex/agents/python-typed-engineer-c2.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml`
17. `.codex/agents/python-typed-engineer-c3.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml`
18. `.codex/agents/python-typed-engineer-c3-elevated.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml`
19. `.codex/agents/python-typed-engineer-c4.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml`
20. `.codex/agents/python-orchestrator.toml` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml`
21. `.github/agents/python-typed-engineer.agent.md` / `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md`
22. `.github/agents/python-orchestrator.agent.md` / `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md`
23. `.github/prompts/orchestrate-python-work.prompt.md` / `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md`

E2 (final, P13-T1, 24 pairs): E1 pairs 1 and 3 through 23 (22 pairs; pair 2 no longer exists), plus:

24. `.claude/hooks/enforce-batch-budget-route.ps1` / `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1`
25. `.codex/hooks/enforce-batch-budget-route.ps1` / `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-batch-budget-route.ps1`

## Appendix F — Python Parity Suites

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`, `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`, `tests/scripts/dev_tools/test_resolve_codex_topology.py` (the last confirms the out-of-scope resolver is untouched).

## Appendix G — Search Commands

AC-18 sweep (tracked Python-path surfaces and their mirrors; a git pathspec `*` matches across `/`, so `.claude/*python*` covers skill directories; the two `:(exclude)` pathspecs remove `python-execution-only-typed`):

```text
git grep -n -i -F -e 'per-batch' -e 'per batch' -e 'batch cap' -e 'smaller batches' -e 'split the work' -e 'new batch' -e 'three-test' -e 'in-flight batch' -e 'budget: prod=' -e 'budget override' -e 'seek an override' -- '.claude/*python*' '.agents/*python*' '.codex/*python*' '.github/agents/*python*' '.github/skills/*python*' '.github/prompts/*python*' 'extensions/drm-copilot/resources/claude-customizations/.claude/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/*python*' 'extensions/drm-copilot/resources/customizations/.github/agents/*python*' 'extensions/drm-copilot/resources/customizations/.github/skills/*python*' 'extensions/drm-copilot/resources/customizations/.github/prompts/*python*' ':(exclude).github/agents/python-execution-only-typed.agent.md' ':(exclude)extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md'
```

The seven AC-19 files are `.claude/skills/python-change-budget-router/SKILL.md`, `.agents/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, and `.github/agents/python-typed-engineer.agent.md`.

The six AC-20 files are `.github/agents/python-orchestrator.agent.md`, `.github/prompts/orchestrate-python-work.prompt.md`, `.codex/agents/python-orchestrator.toml`, and their mirrors `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md`, `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml`.

AC-20 regex search (POSIX classes are used because `\s` is not portable across git regex builds; the backticks are literal inside single quotes):

```text
git grep -n -i -E -e '>[[:space:]]*`?3`?[[:space:]]*test' -- .github/agents/python-orchestrator.agent.md .github/prompts/orchestrate-python-work.prompt.md .codex/agents/python-orchestrator.toml extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml
```

AC-20 fixed-string search:

```text
git grep -n -i -F -e '1-3 test Python files' -- .github/agents/python-orchestrator.agent.md .github/prompts/orchestrate-python-work.prompt.md .codex/agents/python-orchestrator.toml extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml
```

AC-13 sweep:

```text
git grep -n -F -e 'PowerShellBatchBudgetCheckpoint' -e 'PowerShellBatchBudgetSelectedRoute' -e 'PowerShellBatchBudgetLargePathRoute' -- .claude/hooks .codex/hooks tests/scripts extensions/drm-copilot/resources
```

AC-28 negative search:

```text
git grep -n -i -F -e 'per-batch' -e 'per batch' -e 'deleting' -e 'reset the' -e 'new batch' -e 'batch cap' -e 'split the work' -e 'raise the cap' -e 'record an approved cap' -e 'CLAUDE_PYTHON_BUDGET' -- .claude/hooks/enforce-python-batch-budget.ps1 .codex/hooks/enforce-python-batch-budget.ps1
```

AC-11 negative search:

```text
git grep -n -F -e 'New-TemporaryFile' -e 'GetTempFileName' -e 'GetTempPath' -e 'TestDrive' -e 'Set-Content' -e 'Out-File' -e 'New-Item' -- tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
```

## Appendix H — Final QA File Set (fifteen files)

CROUTE, XROUTE, CPSHOOK, XPSHOOK, CPYHOOK, XPYHOOK, CPYTEST, CPYRTEST, XPYRTEST, PARTEST, XTEST, LEGTEST, CPSRTEST, XPSRTEST, RUNSET.
