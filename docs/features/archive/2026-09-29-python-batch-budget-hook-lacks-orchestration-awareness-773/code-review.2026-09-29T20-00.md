# Code Review: Python batch-budget hook orchestration awareness (#773)

---

**Review Date:** 2026-09-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its `-773` suffix matches the branch issue number.
**Base Branch:** `main` (merge-base `43c9e95eaa39b3d896a9da5501cd57953033c2bc`)
**Head Branch:** `bug/python-batch-budget-hook-lacks-orchestration-awareness-773` (`2c493e30a8825137bee7f9f48439e38b322ca815`)
**Review Type:** Initial review

---

## Executive Summary

The branch applies the #769 routing model to the Claude and Codex Python batch-budget hooks. In direct mode the hooks count only distinct production Python paths and deny the 4th with a `PYTHON_LARGE_PATH_REQUIRED` routing instruction; under a non-terminal `large`, `remediation`, or `preparation` checkpoint they allow every Python path without touching state. The route predicate is moved into a language-neutral helper, `enforce-batch-budget-route.ps1`, shared by the PowerShell and Python hooks in each runtime, which removes a 124-line inline copy from the Codex PowerShell hook. Python-scoped agent, skill, and prompt text across the Claude, Codex, `.agents`, and Copilot surfaces is rewritten to the routing model, and all bundle mirrors are byte-identical.

Evidence reviewed: the full branch diff, the PR context summary and appendix, executor evidence under the feature folder, and reviewer re-runs of the analyzer, formatter check, twelve Pester suites (445/445) with coverage, the `tests/scripts/dev_tools` pytest suite in a clean snapshot (5252 passed, 0 failed), mirror `cmp` checks, line counts, and the grep-based acceptance checks. Implementation quality is consistent with the #769 PowerShell hook it mirrors.

**What changed:**
`.claude/hooks/enforce-python-batch-budget.ps1` and `.codex/hooks/enforce-python-batch-budget.ps1` gain a `ReadCheckpoint` seam, an early large-path return, production-only counting, and routing deny text; `testFiles`/`testCap` handling and the `CLAUDE_PYTHON_BUDGET_*` overrides are removed. The Codex Python hook gains `Invoke-PythonBatchBudgetCodexEntryPoint` and drops its `$env:CLAUDE_` reads. Both PowerShell hooks now dot-source the shared helper. Three new Pester suites cover Python routing per runtime and helper parity.

**Top 3 risks:**
1. A stale non-terminal large-path checkpoint at the root exempts a later direct-mode session. This is documented in both hook docstrings with the #673 hygiene mitigation and matches the accepted #769 behavior.
2. `.github/agents/python-typed-engineer.agent.md` keeps a user-approval scope-expansion clause next to the new routing instruction, which leaves a second reading of how to exceed 3 production files on the Copilot surface.
3. The canonical `artifacts/pester/powershell-coverage.xml` does not measure the two new helper files until the installed extension's runsettings are updated; helper coverage currently depends on the direct Pester run.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all acceptance checks and toolchain stages were reproduced by the reviewer.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.github/agents/python-typed-engineer.agent.md` (and bundle mirror) | Section 1, lines 67-74 | The new line 66 routes changes of more than 3 production files to `python-orchestrator`, but lines 67-74 still allow additional production files when "the user explicitly expands scope" and "Proceed only after user approval". The Claude router now states "Do not request an exception to the threshold; routing is the only path past it." | In a follow-up, reword lines 67-74 so scope expansion that crosses 3 production files routes to `python-orchestrator` rather than proceeding on user approval. | Two instructions in one section give different exits from the same condition; an agent may choose the approval path the hook will then deny. | Reviewer read of lines 58-80; AC-19/AC-21 text checks still pass because they do not cover this clause. |
| Minor | `.claude/hooks/enforce-python-batch-budget.ps1` (and bundle mirror) | `Invoke-PythonBatchBudgetHook`, lines 375-401 | Session-id resolution runs before the checkpoint check, so on the large path the hook still reads `<root>/.claude/state/current-session-id` through `ReadSessionIdFile` (when `CLAUDE_SESSION_ID` is unset). It does not read or write the budget state file or create the directory, so AC-4 as written holds. The same order exists in the #769 PowerShell hook. | Move the checkpoint read and large-path return above `Get-PythonBatchBudgetSessionId` in both Claude hooks in a follow-up. | The large path is described as not touching state; reading a state-directory file is unnecessary work on that path and slightly widens its I/O surface. | Lines 379-401; `.claude/hooks/enforce-powershell-batch-budget.ps1` has the same sequence. |
| Nit | `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1` | `Get-PythonBatchBudgetState`, `ConvertTo-PythonBatchBudgetState`, `Invoke-PythonBatchBudgetDecision` | Ignored `TestCap` parameters are retained with `PSReviewUnusedParameter` suppressions, and `ProdCap` remains an `Invoke-PythonBatchBudgetHook` parameter (default 3) and a persisted `prodCap` key. The threshold is not runtime-configurable (no environment or state override), so AC-8 holds. | Consider removing `TestCap` once no in-repo caller passes it, and documenting `ProdCap` as a test seam. | Dead parameters add suppression noise and suggest a configurable test cap that no longer exists. | Lines 186-213, 259-272 (Claude); 57-133 (Codex). |
| Nit | `.claude/hooks/enforce-batch-budget-route.ps1`, `.codex/hooks/enforce-batch-budget-route.ps1` | `Test-BatchBudgetLargePathRoute` lines 117-121; hook lines 398-399 | Each hook invocation parses the checkpoint JSON three times: once in `Test-BatchBudgetLargePathRoute`, once in its nested `Get-BatchBudgetSelectedRoute`, and once in the hook's own `Get-BatchBudgetSelectedRoute` call. | No action required; optionally accept a parsed object in a later refactor. | Cost is negligible for a small checkpoint; noted for simplicity only. | Helper source; reviewer read. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical coverage artifact includes the four changed hooks but not the two new helper files; the MCP runner uses the installed extension's runsettings. | After the extension is rebuilt and reinstalled, confirm the helpers appear in the canonical artifact. | Coverage for new files currently rests on the direct Pester run. | Reviewer parse: no `batch-budget-route` entry; direct run 94.12% per helper. |
| Info | `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/issue.md` | `## Acceptance Criteria (early draft)`, `## Next Step` | Seven unchecked checkbox items remain in non-authoritative sections (five early-draft criteria superseded by `spec.md`, two promotion steps already performed). | Optionally mark the early-draft section as superseded. | Readers may mistake these for open acceptance criteria. For `full-bug` the AC source is `spec.md` only. | `grep -n '^- \[ \]' issue.md`. |
| Info | `.codex/hooks/enforce-python-batch-budget.ps1` | `Invoke-PythonBatchBudgetDecision` | The Codex Python hook has no out-of-root containment check, unlike the Claude hook. This asymmetry predates the branch and AC-9 scopes out-of-root discard to Claude. | None for this item. | Recorded for completeness. | Base and head source comparison. |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The route predicate now lives in one pure helper per runtime with neutral names, dot-sourced by four hooks; the parity suite asserts byte identity and runs the same 21-case predicate table against each copy.
- The large-path decision is evaluated before any budget-state operation, and tests assert through seams that the state file is not read or written and `EnsureDirectory` is not called.
- Route precedence (`route_id` over `path_selected`, non-blank string only) and terminal detection are case-sensitive and fail closed to direct mode for every malformed input.
- Deny text names the routing target per runtime (`/orchestrate` for Claude, `.codex/prompts/orchestrate-work.md` for Codex) and omits the removed per-batch, override, and state-deletion phrases; the state file path appears only in `Write-Verbose`.
- The Codex hook's process-level logic is moved into `Invoke-PythonBatchBudgetCodexEntryPoint`, leaving a thin entry block (only line 341 uncovered).

#### API and safety notes

- All new and changed functions are advanced functions with `[OutputType()]`; analyzer reports 0 findings with repository settings.
- `ConvertFrom-Json -ErrorAction Stop` inside `try/catch` with a verbose log; no broad catch swallows an error that should surface. The Codex entry point writes to stderr and returns 2 on unexpected failure.
- Legacy state keys (`prodCap`, `testCap`, `testFiles`) are ignored on load; only `prodFiles` is carried over, and the Claude hook still drops out-of-root persisted entries.

#### Error handling and logging

- Checkpoint read failures, unparseable checkpoints, unreadable state, and state write failures are logged with `Write-Verbose` and do not change the exit code, matching the deny-only hook contract.
- Envelope/JSON failures remain fail-closed denies, including under a large route (AC-9), because payload validation precedes the checkpoint read.

---

## Test Quality Audit

Automated coverage is thorough for the new behavior. Reviewer re-runs matched every executor figure.

### Reviewed test and QA artifacts

- `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` — byte identity, function set, predicate and selected-route tables for both copies (55 tests).
- `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` — direct/large/precedence/fail-closed/classification/legacy/deny-text groups for the Claude hook.
- `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` — same groups plus the in-process Codex entry point.
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` — diff against `main` is four function-name renames per file (reviewer `git diff`).
- `evidence/regression-testing/claude-python-routing-before-fix.2026-09-29T19-35.md` and `codex-python-routing-before-fix.2026-09-29T20-10.md` — the new suites failed before the fix, so they discriminate the defect.
- `evidence/qa-gates/changed-line-coverage.2026-09-29T21-03.md`, `coverage-comparison.2026-09-29T21-11.md`, `route-helper-coverage.2026-09-29T21-02.md` — coverage figures reproduced by the reviewer.

### Quality assessment prompts

- **Determinism:** All I/O injected through scriptblock seams; no clock, randomness, temp files, or live checkpoint.
- **Isolation:** One behavior per `It`; data-driven tables for route cases.
- **Speed:** Twelve suites completed in a single session run without timeouts.
- **Diagnostics:** Named `-ForEach` cases identify the failing route input directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation added; hooks only read/write JSON through seams. |
| Input validation at boundaries | ✅ PASS | Envelope and Codex JSON validated before use; checkpoint accepted only as a JSON object with string route values. |
| Error handling remains explicit | ✅ PASS | Fail-closed deny on unreadable envelope/malformed JSON; direct mode on any checkpoint failure. |
| Configuration / path handling is safe | ✅ PASS | Session id sanitized to `[A-Za-z0-9._-]` in both hooks; Claude out-of-root containment retained; environment overrides removed. |

---

## Research Log

No external research was required. The review relied on repository sources: `spec.md`, the research document, #769 hook sources, and the repository policy rules.

---

## Verdict

The change is ready for normal PR flow. The implementation matches the specification, all 29 acceptance criteria were verified by reviewer re-runs or direct inspection, the toolchain is clean, coverage meets the uniform thresholds with no regression, and all bundle mirrors are identical to their runtime copies.

The two Minor findings (the residual approval clause in the Copilot python-typed-engineer agent, and session-id resolution preceding the large-path check in the Claude hook) do not affect any acceptance criterion and are suitable for a follow-up item. No remediation is required before merge.
