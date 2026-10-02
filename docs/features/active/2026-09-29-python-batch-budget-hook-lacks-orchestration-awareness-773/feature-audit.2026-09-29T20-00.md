# Feature Audit: Python batch-budget hook orchestration awareness (#773)

---

**Audit Date:** 2026-09-29
**Feature Folder:** `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`
**Base Branch:** `main`
**Head Branch:** `bug/python-batch-budget-hook-lacks-orchestration-awareness-773`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `43c9e95eaa39b3d896a9da5501cd57953033c2bc`)
- **Head branch/commit:** `bug/python-batch-budget-hook-lacks-orchestration-awareness-773` (commit `2c493e30a8825137bee7f9f48439e38b322ca815`)
- **Merge base:** `43c9e95eaa39b3d896a9da5501cd57953033c2bc`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-29 23:54 UTC for head `2c493e30`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/evidence/{baseline,qa-gates,regression-testing,other}/`
  - Additional evidence: reviewer re-runs recorded in `policy-audit.2026-09-29T20-00.md` Appendix B (Pester 445/445 with coverage, analyzer and formatter over 22 files, clean-snapshot pytest 5252 passed, 18 mirror `cmp` checks, grep checks)
- **Feature folder used:** `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 11 reads `- Work Mode: full-bug`, so `spec.md` is the only authoritative AC source.
- **Scope note:** The executor plan measured changed-line coverage against BASE_SHA `91805f15ddc5930759d877cf6147467096ad91fe`. That commit is an ancestor of the merge-base, and `git diff 91805f15..43c9e95e -- .claude/hooks .codex/hooks tests/scripts` is empty, so the executor baseline is equivalent to the review baseline for every changed code file.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/spec.md` — only source

`issue.md` also mirrors the 29 criteria under `## Acceptance Criteria` and has a separate `## Acceptance Criteria (early draft)` section; neither is authoritative for `full-bug`.

### Acceptance criteria

1. AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `/orchestrate`.
2. AC-2: In direct mode, the Codex Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
3. AC-3: Neither Python hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, or the state-file path; asserted by unit tests for both hooks.
4. AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither Python hook denies any Python path for file count at any number of distinct production files, and neither hook reads state, writes state, or creates the state directory for those paths.
5. AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both Python hooks.
6. AC-6: A missing checkpoint, a throwing reader, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both Python hooks, and no checkpoint condition causes a non-zero hook exit.
7. AC-7: Test Python paths matching the unchanged classification rule (`tests/**/*.py` and `test_*.py`) are never denied for count and are not recorded in state, in either mode, in both Python hooks.
8. AC-8: `CLAUDE_PYTHON_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both Python hooks; a search for `CLAUDE_PYTHON_BUDGET` in both Python hooks and their bundle copies returns no match.
9. AC-9: Existing behaviors hold in both Python hooks: fail-closed deny on an unreadable envelope (Claude) or malformed JSON (Codex), including under a large route; allow on missing `file_path` or non-`.py` path without invoking the checkpoint reader; out-of-root discard without a state write (Claude); repeated-path allow without a state write; deny-only output with `state` stripped; and the `Get-PythonBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
10. AC-10: The Codex Python hook contains no `$env:CLAUDE_` read, exposes `Invoke-PythonBatchBudgetCodexEntryPoint` exercised in-process through seams, and still requires `session_id` (`legacy-codex-hook-contracts.Tests.ps1` and `codex-pretooluse-transport.Tests.ps1` pass).
11. AC-11: The checkpoint is supplied to both Python hooks through an injectable `ReadCheckpoint` seam; no new or modified test creates a temporary file; and no new or modified Python-hook test depends on the live `artifacts/orchestration/orchestrator-state.json` (the Python row of the shared Codex Context injects an empty checkpoint).
12. AC-12: `.claude/hooks/enforce-batch-budget-route.ps1` and `.codex/hooks/enforce-batch-budget-route.ps1` exist, define `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, and `Test-BatchBudgetLargePathRoute`, and are byte-identical; `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, and `.codex/hooks/enforce-python-batch-budget.ps1` each dot-source their runtime's helper.
13. AC-13: A search for `PowerShellBatchBudgetCheckpoint`, `PowerShellBatchBudgetSelectedRoute`, and `PowerShellBatchBudgetLargePathRoute` returns no match under `.claude/hooks/`, `.codex/hooks/`, `tests/scripts/`, or their bundle mirrors under `extensions/drm-copilot/resources/` (no inline or PowerShell-named copy of the route helper remains).
14. AC-14: `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` exists, asserts the Claude and Codex helper copies are byte-identical, runs the route predicate table against each copy, and passes.
15. AC-15: `.claude/hooks/enforce-powershell-batch-budget-route.ps1` and its bundle copy no longer exist; the Claude helper is listed in `claude-customizations/pack-manifests/core.json` and a search for `enforce-powershell-batch-budget-route` in `claude-customizations/pack-manifests/powershell.json` returns no match; the Codex helper is listed in `codex-and-agents-customizations/pack-manifests/core.json` and in `$script:SharedModuleNames`; both `pester.runsettings.psd1` copies list both new helper paths and do not list the old path.
16. AC-16: No PowerShell regression: `enforce-powershell-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1`, and the PowerShell row of `codex-batch-budget-hooks.Tests.ps1` pass after the switch to the shared helper, and the diff of the two #769 routing suites relative to `main` consists only of the helper function-name renames.
17. AC-17: New suites `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` exist and pass, and the updated `enforce-python-batch-budget.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, and `legacy-codex-hook-contracts.Tests.ps1` pass.
18. AC-18: A case-insensitive search for `per-batch`, `per batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, `in-flight batch`, `budget: prod=`, `budget override`, and `seek an override` returns no match in files whose path contains `python` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, or `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/python-execution-only-typed.agent.md` and its mirror.
19. AC-19: Python routing text in `python-change-budget-router` (both copies), `invoke-python-engineer` (both copies), `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, and `.github/agents/python-typed-engineer.agent.md` states `1-3` production files for the small/direct path and more than 3 for the large path, states that the large path has no production-file cap, and states that test files are not counted toward the routing threshold.
20. AC-20: A case-insensitive regex search for ``>\s*`?3`?\s*test`` and for `1-3 test Python files` returns no match in `.github/agents/python-orchestrator.agent.md`, `.github/prompts/orchestrate-python-work.prompt.md`, `.codex/agents/python-orchestrator.toml`, or their bundle mirrors, and the path-selection rules in those files route on production-file count only.
21. AC-21: Routing instructions in `.claude/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, and `.claude/agents/python-typed-engineer.md` name `/orchestrate` and do not name `python-orchestrator`; the `.agents` router and invoke-skill copies and `.codex/agents/python-typed-engineer.toml` name `.codex/prompts/orchestrate-work.md`; `.github/agents/python-typed-engineer.agent.md` names `python-orchestrator`.
22. AC-22: Neither `invoke-python-engineer` copy nor `.agents/skills/invoke-powershell-engineer/SKILL.md` (nor their bundle mirrors) offers the `budget: prod=<N>, test=<M>` input, and neither `python-change-budget-router` copy contains a `Per-Batch Change Budget` or `Scope Expansion Protocol` section.
23. AC-23: Every generated variant of `.codex/agents/python-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
24. AC-24: Bundle parity and manifest completeness pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and core-manifest checks in `legacy-codex-hook-contracts.Tests.ps1`; every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
25. AC-25: `.github/copilot-instructions.md`, `.github/instructions/*`, `.github/agents/python-execution-only-typed.agent.md`, `scripts/dev_tools/resolve_codex_topology.py`, and `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` are unchanged on the branch relative to `main`, and no `.py` file is modified.
26. AC-26: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` and `codex-epic-runtime-contracts.Tests.ps1` pass.
27. AC-27: PoshQC format -> analyze -> test passes with zero analyzer findings; line coverage is >= 85% for each changed hook and each helper copy (helper figures from a direct Pester run recorded under `<FEATURE>/evidence/qa-gates/`); and there is no coverage regression on changed lines.
28. AC-28: Both Python hook docstrings describe the routing model and document the stale-checkpoint limitation with the #673 hygiene mitigation, and contain no per-batch, cap-override, or state-file-deletion guidance.
29. AC-29: Potential entries under `docs/features/potential/` are recorded for the `python-execution-only-typed` 30/30 cap (owner decision) and for the language-generic orchestrator test-file routing clause in `.github/agents/orchestrator.agent.md` and `.github/prompts/orchestrate-work.prompt.md`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Claude direct mode 3 allowed, 4th denied, `/orchestrate` | PASS | `.claude/hooks/enforce-python-batch-budget.ps1` lines 312-318; routing suite "direct mode" context passes | `Invoke-Pester` (reviewer `route-cov.ps1`, 364/364) | Deny text: `PYTHON_LARGE_PATH_REQUIRED: ... Route the change through /orchestrate.` |
| 2 | AC-2 Codex direct mode, `.codex/prompts/orchestrate-work.md` | PASS | `.codex/hooks/enforce-python-batch-budget.ps1` lines 162-168; Codex routing suite passes | `Invoke-Pester` (364/364) | |
| 3 | AC-3 prohibited phrases absent from deny reason | PASS | Deny string in both hooks contains none of the listed phrases; state file path only in `Write-Verbose`; suites assert omission | `Invoke-Pester`; source read | |
| 4 | AC-4 large/remediation/preparation allow without state I/O | PASS | Early return at Claude line 400-402 and Codex 236-238 before `TestPathExists`/`EnsureDirectory`/`ReadState`/`WriteState`; suites assert seams not called | `Invoke-Pester` | Claude hook still reads `current-session-id` before the check (code-review Minor); the budget state file and directory are untouched, as the AC specifies |
| 5 | AC-5 route precedence, null/blank `route_id` | PASS | `Get-BatchBudgetSelectedRoute` lines 76-90; parity cases `route_id null with path_selected large` -> false | `Invoke-Pester` (parity suite) | |
| 6 | AC-6 fail-closed checkpoint conditions, exit 0 | PASS | Helper returns false for every listed case; hooks catch reader exceptions; nine direct-mode rows per hook pass | `Invoke-Pester` | |
| 7 | AC-7 test paths never counted or recorded | PASS | Classification check precedes counting (Claude 302-305, Codex 152-155) with `shouldWriteState = $false` | `Invoke-Pester` | |
| 8 | AC-8 overrides removed; legacy state loads | PASS | `git grep CLAUDE_PYTHON_BUDGET -- .claude/hooks .codex/hooks extensions/drm-copilot/resources` returned no match; `ConvertTo-PythonBatchBudgetState` carries only `prodFiles` | `git grep`; `Invoke-Pester` | |
| 9 | AC-9 existing behaviors hold; schema contract | PASS | Envelope/JSON validation precedes checkpoint read; `PreToolUseSchema.Contract.Tests.ps1` passes | `Invoke-Pester` contract suites (81/81) | |
| 10 | AC-10 Codex no `$env:CLAUDE_`, entry point, `session_id` required | PASS | `git grep 'env:CLAUDE_'` on the Codex hook returned no match; `-RequireSessionId` at line 302; transport and legacy suites pass | `git grep`; `Invoke-Pester` | |
| 11 | AC-11 `ReadCheckpoint` seam; no temp files; no live checkpoint | PASS | Seam at Claude 341-347, Codex 184-190; reviewer grep for temp-file APIs in new suites and added lines returned no match; only the injected `/repo/...` path string appears | `git grep -E 'New-TemporaryFile|GetTempFileName|GetTempPath|TestDrive|Set-Content|Out-File|New-Item|orchestrator-state.json'` | |
| 12 | AC-12 helpers exist, three functions, byte-identical, dot-sourced | PASS | `cmp` identical; parity suite asserts function set; dot-source lines in all four hooks | `cmp`; `git grep enforce-batch-budget-route` | |
| 13 | AC-13 no PowerShell-named helper copies | PASS | `git grep -E 'PowerShellBatchBudget(Checkpoint|SelectedRoute|LargePathRoute)'` over the four scopes returned no match | `git grep` | |
| 14 | AC-14 parity suite exists and passes | PASS | `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`, 55 tests | `Invoke-Pester` | |
| 15 | AC-15 old helper removed; manifests, shared list, runsettings | PASS | Old paths absent (`ls` error); `core.json` line 25 (Claude) and line 51 (Codex); `$script:SharedModuleNames` line 30; both runsettings list both helpers and not the old path; runsettings copies identical | `ls`; `git grep`; `git diff`; `cmp` | |
| 16 | AC-16 no PowerShell regression; rename-only diff | PASS | PowerShell suites pass; `git diff` of both #769 routing suites shows only two function-name renames each | `Invoke-Pester`; `git diff 43c9e95e..HEAD -- <suites>` | |
| 17 | AC-17 new and updated suites pass | PASS | All five named suites in the 364/364 run | `Invoke-Pester` | |
| 18 | AC-18 per-batch phrases absent from Python surfaces | PASS | `git grep -i -l -E '<phrases>'` over the listed trees, filtered to paths containing `python` and excluding `python-execution-only-typed.agent.md`, returned no file | `git grep` | |
| 19 | AC-19 routing text states 1-3, more than 3, no cap, tests not counted | PASS | Diff of router, invoke skill, Claude/Codex/Copilot engineer agents shows all three statements | `git diff`; `evidence/qa-gates/ac19-routing-text.2026-09-29T20-50.md` | Copilot agent retains a separate approval clause (code-review Minor); the required statements are present |
| 20 | AC-20 no test-count routing in orchestrator surfaces | PASS | Regex search over the three files and mirrors returned no match; small/large headings route on production files only | `git grep -i -n -E` | |
| 21 | AC-21 routing targets per surface | PASS | Claude surfaces name `/orchestrate`; Codex agent names `.codex/prompts/orchestrate-work.md`; Copilot agent names `python-orchestrator` | `git diff`; `evidence/qa-gates/ac21-routing-target.2026-09-29T20-50.md` | |
| 22 | AC-22 no `budget: prod=` input or removed sections | PASS | `git grep` hits only C# skills and the excluded `python-execution-only-typed` mirror, none of which AC-22 names | `git grep -n -E 'budget: prod=|Per-Batch Change Budget|Scope Expansion Protocol'` | C# surfaces tracked in `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md` |
| 23 | AC-23 Codex variants regenerated; generator test passes | PASS | `generate_codex_agent_variants --check` exit 0 (executor); `test_generate_codex_agent_variants.py` passed in the clean-snapshot run | `python -m pytest tests/scripts/dev_tools` (snapshot) | |
| 24 | AC-24 bundle parity and manifest completeness | PASS | Clean-snapshot pytest 5252 passed, 0 failed (includes all named Python suites); TS twin 16/16 (executor); legacy suite passes; 18 mirror pairs identical | pytest (snapshot); `cmp`; `Invoke-Pester` | Working-tree failure of `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is #510 state-only |
| 25 | AC-25 protected files and `.py` unchanged | PASS | `git diff --name-only 43c9e95e..HEAD -- <listed paths> '*.py'` printed nothing | `git diff --name-only` | |
| 26 | AC-26 500-line limit | PASS | Largest changed file 497 lines; `codex-epic-runtime-contracts.Tests.ps1` and legacy suite pass | `wc -l`; `Invoke-Pester` | |
| 27 | AC-27 PoshQC loop, 0 findings, >= 85% per file, no regression | PASS | 0 analyzer findings, 0 format drift; CPY 95.45, XPY 98.99, CPS 95.45, XPS 98.99, each helper 94.12; changed lines 94.12-100 | reviewer `qa-checks.ps1`, `route-cov.ps1`; `evidence/qa-gates/coverage-comparison.2026-09-29T21-11.md` | |
| 28 | AC-28 docstrings describe routing and #673 limitation | PASS | Claude hook lines 1-57, Codex hook lines 2-45 | Source read | |
| 29 | AC-29 potential entries recorded | PASS | `docs/features/potential/2026-09-29-python-execution-only-typed-per-batch-cap.md`, `docs/features/potential/2026-09-29-generic-orchestrator-test-file-routing-clause.md` | `ls docs/features/potential/2026-09-29-*.md` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 29 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm CI (S9 gate) is green on the PR head, including the Linux run of `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
2. After the extension is rebuilt and reinstalled, confirm the two route helpers appear in the canonical `artifacts/pester/powershell-coverage.xml`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/spec.md`
- Total AC items: 29
- Checked off (delivered): 29
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/spec.md` | 29 | 29 | 0 | Checkbox-backed; authoritative for `full-bug` |

No source-file checkbox change was made by this review. All 29 items in `spec.md` were already checked by the executor in commit `d5409c1f`, and each was independently evaluated as PASS above, so no item needed to be checked or unchecked.
