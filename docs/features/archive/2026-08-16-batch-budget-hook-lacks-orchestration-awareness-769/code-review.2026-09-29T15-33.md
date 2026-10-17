# Code Review: PowerShell batch-budget hook large-path routing (#769)

---

**Review Date:** 2026-09-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`
**Feature Folder Selection Rule:** the only active folder with material scoping-doc changes on the branch; its `-769` suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e`)
**Head Branch:** `bug/batch-budget-hook-lacks-orchestration-awareness-769` @ `79c69039aa76152316a581625acbeed33ad15ceb`
**Review Type:** Initial review

---

## Executive Summary

The branch converts the PowerShell batch-budget PreToolUse hooks (Claude and Codex) from a per-session chunking cap into a routing gate. Both hooks now read `<root>/artifacts/orchestration/orchestrator-state.json`, and when the selected route (`route_id`, else `path_selected`, non-blank string only) is `large`, `remediation`, or `preparation` and the checkpoint is not terminal, every PowerShell path is allowed without counting or writing state. Outside that condition the hooks count distinct production paths and deny the 4th with a `POWERSHELL_LARGE_PATH_REQUIRED` reason that names the orchestrator entry point for the runtime. The test-file cap, the `CLAUDE_POWERSHELL_BUDGET_*` override, and the persisted cap override are removed. Policy text on Claude, Copilot, Codex, and `.agents` PowerShell surfaces drops the per-batch model, and bundle mirrors are byte-identical.

Evidence reviewed: the full branch diff, `artifacts/pr_context.summary.txt` and appendix, the feature `evidence/` tree, the canonical coverage artifact `artifacts/pester/powershell-coverage.xml`, and reviewer-run checks (Pester 231/231 on the six affected suites, PSScriptAnalyzer 0 findings, formatter clean, 20 mirror pairs identical, Python parity suites 44/44 on a clean HEAD snapshot). Implementation quality is good: pure parsing functions are separated from I/O, failure modes resolve toward enforcement, and the test suites use in-memory seams throughout.

**What changed:**
- `.claude/hooks/enforce-powershell-batch-budget.ps1`: `ReadCheckpoint` seam, checkpoint read before any state operation, `-LargePathRoute` and `-ObservedRoute` on the decision function, routing deny message, removal of the environment override and test-file tracking, `TestCap` retained as an ignored parameter.
- `.claude/hooks/enforce-powershell-batch-budget-route.ps1` (new, 137 lines): `ConvertFrom-PowerShellBatchBudgetCheckpoint`, `Get-PowerShellBatchBudgetSelectedRoute`, `Test-PowerShellBatchBudgetLargePathRoute`; dot-sourced by the hook, registered in the PowerShell pack manifest and both `pester.runsettings.psd1` copies.
- `.codex/hooks/enforce-powershell-batch-budget.ps1`: the same semantics with inlined helpers, a Codex routing target, and a new testable `Invoke-PowerShellBatchBudgetCodexEntryPoint`.
- Text surfaces and bundle mirrors; four Pester suites (two new).

**Top 3 risks:**
1. A stale non-terminal large-route checkpoint left at a root exempts later direct-mode sessions at that root (documented limitation; mitigated by #673 checkpoint hygiene).
2. The route helpers exist in two copies (Claude sibling file and inlined in the Codex hook); future edits can drift without a parity check.
3. The Claude hook now depends on a dot-sourced sibling; if that file is absent in a consumer install, the hook exits non-zero, which the runtime treats as non-blocking, so enforcement would be silently off. Pack-manifest registration and the completeness test mitigate this.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all findings are Minor, Nit, or Info and none affects correctness of the specified behavior.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.codex/hooks/enforce-powershell-batch-budget.ps1` | lines 53-174 | The three route helpers are a second copy of `.claude/hooks/enforce-powershell-batch-budget-route.ps1` lines 16-137. The duplication is intentional per spec (the Codex bundle cannot carry `.claude/lib`), but no test asserts the two copies stay equivalent. | Add a contract test that extracts the three function bodies from both files via AST and asserts equality, or record the duplication as an accepted parity obligation in the hook docstrings. | Divergent route semantics between runtimes would reintroduce the class of defect this item fixes. The mirrored routing suites catch behavioral drift only for the cases they enumerate. | Side-by-side read of both files; functions are textually identical at HEAD. |
| Minor | `.claude/hooks/enforce-powershell-batch-budget.ps1` | line 63 | The hook dot-sources `enforce-powershell-batch-budget-route.ps1`. If the sibling is missing (partial consumer install), the dot-source throws, the process exits non-zero, and Claude Code treats a non-zero, non-2 exit as non-blocking, so the budget is not enforced. | Accept, given the pack-manifest entry and `test_push_down_claude_pack_manifest_completeness.py`; optionally guard the dot-source with `Test-Path` and fail closed with a deny. | Fail-open on a packaging defect is silent. The same exposure already exists for the `HookPayload.psm1` import on line 62, so this is not a new class of risk. | `extensions/.../pack-manifests/powershell.json` diff; completeness test passed. |
| Nit | `.claude/hooks/enforce-powershell-batch-budget-route.ps1` | lines 113-118; hook lines 395-396 | The checkpoint text is parsed up to three times per invocation (`Test-...LargePathRoute` parses, then calls `Get-...SelectedRoute` which parses again; the hook calls `Get-...SelectedRoute` a third time). | Optionally parse once and pass the object, or have the predicate accept the selected route. | Minor per-call cost on every PowerShell write; no correctness impact. | Code inspection. |
| Nit | `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1` | `Get-PowerShellBatchBudgetState`, `ConvertTo-PowerShellBatchBudgetState` | `-TestCap` is retained as an accepted-and-ignored parameter with a `PSReviewUnusedParameter` suppression. | Remove the parameter in a later cleanup once no caller passes it. | Dead parameters obscure the contract; the justification string is present, so this is acceptable for now. | Claude lines 186-194, 203-214; Codex lines 177-185, 194-205. |
| Nit | `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` | lines 96-99 | `AfterEach` sets `CLAUDE_POWERSHELL_BUDGET_PROD/_TEST` to `$null` rather than restoring any prior value. | Capture prior values in `BeforeEach` and restore them. | A developer shell with these variables set would lose them for the remainder of the session. Test outcomes are unaffected. | Code inspection. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical coverage artifact does not contain the new route helper, because the MCP PoshQC runner reads the installed extension's `pester.runsettings.psd1`, which predates this branch. The executor's direct Pester run reports 94.12% (32/34) with misses on lines 134-135, consistent with the file's defensive catch. | Confirm the file appears in CI PowerShell coverage after merge or after the extension is rebuilt and reinstalled. | Coverage verdict relies on executor evidence for one new file. | `jacoco.py` parse of the artifact; `evidence/qa-gates/claude-hook-coverage.2026-09-29T14-39.md`. |
| Info | `.claude/hooks/enforce-powershell-batch-budget.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | whole file | 486 and 490 lines respectively, close to the 500-line limit. | Place future additions in sibling files, as done here with the route helper and the new routing suite. | Keeps the files within policy on the next change. | `wc -l`. |
| Info | `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md` | header | `Status: Draft` while all 23 acceptance criteria are checked. | Update the status during closeout. | Documentation hygiene only. | `spec.md` line 7. |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The checkpoint is read and evaluated before any state operation, so the large path creates no state directory and performs no state read or write (`Invoke-PowerShellBatchBudgetHook`, Claude lines 384-399, Codex lines 340-355).
- Every checkpoint failure mode resolves toward direct-mode enforcement: empty text, parse failure, non-object root, null/non-string/blank route, unknown route, terminal checkpoint, and a throwing reader. None of them produces an allow or a non-zero exit.
- Route precedence matches `Get-OrchestratorStateSelectedRouteId` in `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1`: `route_id` wins when present even if null; `path_selected` is consulted only when `route_id` is absent; only non-blank strings are usable.
- Route matching is case-sensitive (`-ccontains`, `-ceq`), which prevents `LARGE` or `Complete` from being misread.
- The out-of-root discard runs before the large-path check, so containment behavior is unchanged in both modes.
- The deny reason includes counted paths, the requested path, and the observed route, and omits the state-file path, which removes the state-deletion remedy the original message offered.
- The Codex entry point is now a function returning an exit code, with the process wiring reduced to a few lines, which made it testable through `-HookSeams`.

#### API and safety notes

- `Get-PowerShellBatchBudgetBlockDecision` keeps its name, parameters, and deny shape; `PreToolUseSchema.Contract.Tests.ps1` passes.
- New functions use `[CmdletBinding()]`, `[OutputType()]`, approved verbs, and comment-based help. No `ShouldProcess` is required: the new functions are read-only, and the state-writing seam is unchanged.
- The Codex hook contains no `$env:CLAUDE_` read (`git grep` exit 1; `legacy-codex-hook-contracts.Tests.ps1` passes).
- PSScriptAnalyzer: 0 findings on all changed PowerShell files with `pssa.settings.psd1`.

#### Error handling and logging

- `try`/`catch` blocks around the checkpoint read and parse log with `Write-Verbose` and fall back to direct mode. This matches the spec requirement that checkpoint content never causes a non-zero exit. These are bounded fallbacks at a hook boundary, not silent swallowing of arbitrary errors.
- The fail-closed deny on an unreadable envelope is preserved and is evaluated before the checkpoint, so a large route cannot bypass it (test: "still denies an unreadable envelope when the checkpoint route is large").

---

## Test Quality Audit

Automated evidence covers every acceptance-criterion behavior in both hooks. The two new suites fail entirely against the unfixed hooks (47/47 and 49/49 recorded in `evidence/regression-testing/*-before-fix.2026-09-29T14-39.md`) and pass after the fix, which demonstrates that they detect the defect. Live route probes against the worktree checkpoint confirm the Claude hook reads `route_id: large` as the large path.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` — 47 cases: route predicate table (21), selected route (4), direct mode, large path, test paths, removed overrides, checkpoint seam. Reviewer run: pass.
- `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` — 49 cases mirroring the Claude suite plus Codex entry-point cases. Reviewer run: pass.
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` — test-cap cases replaced; entry-level cases pin `-ReadCheckpoint` to an empty checkpoint so the worktree's live checkpoint cannot influence results. Reviewer run: pass.
- `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` — PowerShell row made language-specific; Python row unchanged. Reviewer run: pass.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — unchanged contract suites. Reviewer run: pass.
- `evidence/qa-gates/coverage-comparison.2026-09-29T14-39.md`, `evidence/qa-gates/changed-line-coverage.2026-09-29T14-39.md` — per-file and changed-line coverage >= 85%, no regression; values for the two hooks match the canonical artifact.

### Quality assessment prompts

- **Determinism:** checkpoint and state are in-memory strings passed through seams; entry-level tests pin the checkpoint reader. One case exercises the default reader against a synthetic absent root, which is read-only and deterministic.
- **Isolation:** each `It` covers one behavior; store reset in `BeforeEach`.
- **Speed:** 231 tests across six suites complete in one short local run; no waits.
- **Diagnostics:** `-Because` messages on the prohibited-phrase and source-scan loops identify the failing phrase or file.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation or `Invoke-Expression` added. |
| Input validation at boundaries | ✅ PASS | Checkpoint parsed defensively; only non-blank string routes accepted; object-root check before property access. |
| Error handling remains explicit | ✅ PASS | Bounded fallbacks toward enforcement, logged via `Write-Verbose`. |
| Configuration / path handling is safe | ✅ PASS | Checkpoint path is fixed relative to the hook root; session-id sanitization and out-of-root containment unchanged. |
| Bypass resistance | ⚠️ PARTIAL (accepted by spec) | An agent can edit `route_id` to `large` to lift the cap. Spec classifies the hook as a policy guard, not a security control, and notes that a falsified route fails the completion validator. |

---

## Research Log

No external research was required. The route precedence rule was checked against `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` (`Get-OrchestratorStateSelectedRouteId`), and the design against the committed research record `research/2026-09-29T13-35-batch-budget-routing-research.md`.

---

## Verdict

The change implements the specified routing model correctly and consistently in both runtimes, removes the override and chunking mechanisms, and updates every in-scope policy surface with byte-identical bundle mirrors. Tests are thorough, seam-based, and demonstrably detect the original defect. The branch is ready for normal PR flow.

The Minor findings (duplicated route helpers without a parity test, and the fail-open exposure on a missing sibling file) are improvement opportunities rather than defects in the delivered behavior, and can be addressed in a follow-up. The Info item on the canonical coverage artifact should be closed by checking CI coverage output after merge.
