# Feature Audit: PowerShell batch-budget hook large-path routing (#769)

---

**Audit Date:** 2026-09-29
**Feature Folder:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`
**Base Branch:** `main`
**Head Branch:** `bug/batch-budget-hook-lacks-orchestration-awareness-769`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e`)
- **Head branch/commit:** `bug/batch-budget-hook-lacks-orchestration-awareness-769` (commit `79c69039aa76152316a581625acbeed33ad15ceb`)
- **Merge base:** `b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-29 19:28 UTC for head `79c69039`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/**` (baseline, qa-gates, regression-testing, other)
  - Additional evidence: reviewer-run checks recorded in `policy-audit.2026-09-29T15-33.md` Appendix B (Pester 231/231, PSScriptAnalyzer, formatter, mirror `cmp`, AC greps, clean-snapshot parity suites, canonical coverage artifact `artifacts/pester/powershell-coverage.xml`)
- **Feature folder used:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` line 12 carries the explicit marker `- Work Mode: full-bug`; per the work-mode contract the AC source is `spec.md` only. `issue.md` mirrors the list for reference and states that `spec.md` is authoritative.
- **Scope note:** full branch diff against the merge base (120 files). PR-context artifacts were current for the head SHA and were not regenerated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md` — only source

### Acceptance criteria

1. AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude hook allows the first three distinct production PowerShell paths and denies the 4th; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `/orchestrate`.
2. AC-2: In direct mode, the Codex hook denies the 4th distinct production PowerShell path; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
3. AC-3: Neither hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, `deleting`, or the state-file path; asserted by unit tests for both hooks.
4. AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither hook denies any PowerShell path for file count at any number of distinct production files, and neither hook writes state for those paths.
5. AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both hooks.
6. AC-6: A missing checkpoint, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both hooks, and no checkpoint condition causes a non-zero hook exit.
7. AC-7: Test PowerShell paths are never denied for count and are not recorded in state, in either mode, in both hooks.
8. AC-8: `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both hooks.
9. AC-9: Existing behaviors hold in both hooks: fail-closed deny on an unreadable envelope, out-of-root discard without a state write, repeated-path allow without a state write, deny-only entry-point output, and the `Get-PowerShellBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
10. AC-10: The Codex hook contains no `$env:CLAUDE_` read (`legacy-codex-hook-contracts.Tests.ps1` passes).
11. AC-11: The checkpoint is supplied to both hooks through an injectable seam, and no new or modified test creates a temporary file.
12. AC-12: New tests exist at `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` and pass, and the updated `enforce-powershell-batch-budget.Tests.ps1` and `codex-batch-budget-hooks.Tests.ps1` pass.
13. AC-13: A case-insensitive search for `per-batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, and `per-batch cap in all modes` returns no match in files whose path contains `powershell` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, and `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/Powershell DI Unit Test Engineer.agent.md` and its mirror.
14. AC-14: Every PowerShell routing statement in the Claude and Copilot surfaces listed in In scope item 5 states `1-3` production files for the small/direct path and more than 3 for the large path, and none of those files states `1-2` or `>2` as the PowerShell threshold.
15. AC-15: Routing instructions in `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, and `.claude/skills/invoke-powershell-engineer/SKILL.md` name `/orchestrate` and do not name `powershell-orchestrator`.
16. AC-16: `.claude/skills/invoke-powershell-engineer/SKILL.md` no longer offers the `budget: prod=<N>, test=<M>` override input.
17. AC-17: Every generated variant of `.codex/agents/powershell-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
18. AC-18: Bundle parity holds: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and pack-manifest checks in `legacy-codex-hook-contracts.Tests.ps1` pass, and every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
19. AC-19: `.github/copilot-instructions.md` and `.github/instructions/*` are unchanged on the branch relative to `main`.
20. AC-20: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` pass.
21. AC-21: PoshQC format -> analyze -> test passes with zero analyzer errors, line coverage >= 85% for both hooks, and no coverage regression on changed lines.
22. AC-22: The hook docstrings describe the routing model and document the stale-checkpoint limitation and the #673 hygiene mitigation, and contain no per-batch or state-file-deletion reset guidance.
23. AC-23: Follow-up 1 (Python and C# budget hooks and text) and Follow-up 2 (Codex routing resolver PowerShell budget) are recorded as potential entries under `docs/features/potential/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Claude direct mode denies 4th with routing reason | PASS | Claude hook lines 309-315; routing suite "allows the first three ... denies the 4th with no checkpoint", "... when the checkpoint route is small", "names the routing target ..." | `Invoke-Pester` (six affected suites): 231/231 | Reason asserted `BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'` and `'*/orchestrate*'`. |
| 2 | AC-2 Codex direct mode denies 4th with Codex target | PASS | Codex hook lines 279-285; Codex routing suite line 177 asserts `.codex/prompts/orchestrate-work.md` | `Invoke-Pester` (six affected suites) | Entry-point deny case at suite line 359. |
| 3 | AC-3 prohibited phrases absent | PASS | Claude suite lines 173-180; Codex suite line 188 iterate all six phrases plus `powershell-batch-budget.` and the state directory | `Invoke-Pester` | Both hooks' reason strings contain no state-file path by inspection. |
| 4 | AC-4 large/remediation/preparation uncapped, no state write | PASS | Claude hook lines 293-296, 397-399; suites "<Route> route allows six distinct production paths without a state write" (Writes 0, Ensures 0) | `Invoke-Pester` | Executor live probe: `LARGE-PATH-ROUTE=True` for this item's checkpoint (`evidence/regression-testing/live-route-probe-split.2026-09-29T14-39.md`). |
| 5 | AC-5 route precedence | PASS | Route helper lines 77-89 (identical in Codex lines 114-126); predicate rows "route_id null with path_selected large", "route_id non-string ...", "route_id small wins ...", "path_selected large without route_id" | `Invoke-Pester` | Matches `Get-OrchestratorStateSelectedRouteId` rule. |
| 6 | AC-6 fail-safe to direct mode, no non-zero exit | PASS | Predicate rows for malformed/array/string/empty/whitespace/blank/unknown/terminal; "treats a throwing checkpoint reader as direct mode without raising"; "default reader yields direct mode when the checkpoint file is absent" | `Invoke-Pester` | All checkpoint failure branches return `$false`; hook catch around the reader. |
| 7 | AC-7 test paths never counted or recorded | PASS | Claude hook lines 298-302; suites "allows five distinct test paths in direct mode without recording them", "allows a test path on the large path without a state write" | `Invoke-Pester` | Existing suite case replaced accordingly. |
| 8 | AC-8 overrides removed; legacy state loads | PASS | `ConvertTo-PowerShellBatchBudgetState` carries only `prodFiles`; suites "loads a legacy state carrying prodCap, testCap, and testFiles ...", "ignores CLAUDE_POWERSHELL_BUDGET_PROD and _TEST ...", source scan finds no `CLAUDE_POWERSHELL_BUDGET` | `Invoke-Pester` | Mirrored in the Codex suite for persisted caps. |
| 9 | AC-9 existing behaviors hold | PASS | `PreToolUseSchema.Contract.Tests.ps1` pass; existing suite envelope, out-of-root, repeated-path, and entry-point cases pass; "still denies an unreadable envelope when the checkpoint route is large" | `Invoke-Pester` (includes `PreToolUseSchema.Contract.Tests.ps1`) | |
| 10 | AC-10 no `$env:CLAUDE_` in Codex hook | PASS | `git grep` exit 1; `legacy-codex-hook-contracts.Tests.ps1` passed | `git grep -n -F '$env:CLAUDE_' -- .codex/hooks/enforce-powershell-batch-budget.ps1` | |
| 11 | AC-11 injectable seam; no temp files | PASS | `ReadCheckpoint` parameter in both hooks (Claude 338-344, Codex 301-307); no temp-file API in the four changed suites | `git grep -n -F -e New-TemporaryFile -e GetTempFileName -e GetTempPath -e TestDrive -e Set-Content -e Out-File -e New-Item -- <four suites>` | Only read-only `Get-Content`/`Get-ChildItem` source scans present. |
| 12 | AC-12 new and updated suites exist and pass | PASS | Both new files present; four suites pass | `Invoke-Pester` | Executor directory totals: claude-hooks 2070/2070, codex-hooks 1149/1149. |
| 13 | AC-13 per-batch text removed | PASS | No match | `git grep -n -i -F -e "per-batch" -e "batch cap" -e "smaller batches" -e "split the work" -e "new batch" -e "three-test" -- ".claude/*powershell*" ".agents/*powershell*" ".codex/*powershell*" ".github/agents/*powershell*" ".github/skills/*powershell*" ".github/prompts/*powershell*" "extensions/drm-copilot/resources/*powershell*"` (exit 1) | `per-batch cap in all modes` is subsumed by `per-batch`. |
| 14 | AC-14 threshold `1-3` / more than 3 | PASS | All eight In-scope-item-5 files state `1-3` and more than 3 (`>3`); no `1-2` or `>2` threshold | `MSYS_NO_PATHCONV=1 git grep -n -E "1-3\|more than 3\|>3\|1-2\|>2" -- <eight files>` | The only other `1-3` match is "rationale summary (1-3 bullets)", unrelated. |
| 15 | AC-15 Claude surfaces name `/orchestrate`, not `powershell-orchestrator` | PASS | `/orchestrate` present in all four files; `powershell-orchestrator` absent | `MSYS_NO_PATHCONV=1 git grep -n -F "/orchestrate" -- <four files>`; `git grep -n -F "powershell-orchestrator" -- <four files>` (exit 1) | |
| 16 | AC-16 `budget:` input removed | PASS | No match in the PowerShell skill or its mirror | `git grep -n -F "budget: prod=" -- .claude extensions/drm-copilot/resources/claude-customizations` | Remaining matches are Python/C# skills (Follow-up 1, out of scope). |
| 17 | AC-17 Codex variants regenerated | PASS | `generate_codex_agent_variants --check` exit 0; `test_generate_codex_agent_variants.py` passed in the clean-snapshot run | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | |
| 18 | AC-18 bundle parity | PASS | Clean HEAD snapshot: 44 passed across the six parity suites; 20 repo/bundle pairs identical by `cmp`, including all four changed `.github` files; `legacy-codex-hook-contracts.Tests.ps1` passed | `git archive HEAD \| tar -x`; `python -m pytest -q <six suites>`; `cmp -s` per pair | In the worktree one node fails on the gitignored `.claude/state/current-session-id` (issue #510, pre-existing, environment-only). |
| 19 | AC-19 policy files unchanged | PASS | Empty diff | `git diff --stat b7b4a2dc...HEAD -- .github/copilot-instructions.md .github/instructions` | |
| 20 | AC-20 no file over 500 lines | PASS | Max 490 (`enforce-powershell-batch-budget.Tests.ps1`); hook 486; Codex hook 461 | `wc -l <changed PowerShell files>` | `legacy-codex-hook-contracts.Tests.ps1` passed. |
| 21 | AC-21 PoshQC format/analyze/test, coverage | PASS | Formatter unchanged, 0 analyzer findings; canonical artifact: Claude hook 95.45%, Codex hook 97.73%, repo-wide 96.13%; changed-line 100% / 94.12% / 96.51% | `Invoke-Formatter`/`Invoke-ScriptAnalyzer` with `pssa.settings.psd1`; `jacoco.py artifacts/pester/powershell-coverage.xml` | Route helper absent from the canonical artifact (installed-extension runsettings); 94.12% from executor direct run. See policy audit Section 8. |
| 22 | AC-22 docstrings | PASS | Claude header lines 16-23 and 51-53; Codex header lines 17-24 and 39-41; no per-batch or deletion guidance | `git grep -n -i -F -e "per-batch" -e "deleting" -e "reset the" -e "new batch" -e "batch cap" -e "split the work" -- <three hook files>` (executor, exit 1) | |
| 23 | AC-23 follow-ups recorded | PASS | `docs/features/potential/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness.md`, `2026-09-29-csharp-budget-text-per-batch-cap.md`, `2026-09-29-codex-routing-resolver-powershell-budget-two.md` | `git diff --stat b7b4a2dc...HEAD -- docs/features/potential` | Follow-up 1 is split across the Python and C# entries. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After the PR is opened, confirm CI is green and that CI PowerShell coverage output lists `.claude/hooks/enforce-powershell-batch-budget-route.ps1`.
2. After merge, confirm isolated-worktree subagents pick up the fix (they load `origin/main` hooks), as noted in the spec rollout section.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md`
- Total AC items: 23
- Checked off (delivered): 23
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md` | 23 | 23 | 0 | Checkbox-backed; all 23 were already checked by the executor at `79c69039`. |
| `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/issue.md` | 23 | 23 | 0 | Reference mirror, not authoritative for `full-bug`; text and state identical to `spec.md`. |

No source-file checkbox change was made by this review: every criterion evaluated PASS and was already checked in `spec.md`.
