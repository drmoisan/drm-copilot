# Code Review: Batch-budget hooks resolve the target worktree (#1009)

---

**Review Date:** 2026-10-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009`
**Feature Folder Selection Rule:** the only active folder whose suffix matches issue 1009 in the branch name; it holds the material scoping-doc changes.
**Base Branch:** `main` (merge base `8451891a592e4d8e267d7de2a9f76f516e77f187`)
**Head Branch:** `bug/batch-budget-hooks-coordinator-root-1009` (`84574e7ad5aad1de3a70671e3515b76f6e37ec46`)
**Review Type:** Initial review

---

## Executive Summary

The branch fixes the batch-budget hooks evaluating the coordinator session root instead of the worktree being edited. It adds a pure resolver module (`HookTargetWorktree.psm1`, 391 lines) and a Codex twin with byte-equal function text (`hook-target-worktree.ps1`, 369 lines), and adds 13 executable lines of wiring to each of the four batch-budget hooks. The diff was reviewed against `main` using the refreshed PR context, direct inspection of the module and hook diffs, the coverage artifact, mirror hashes, and the feature evidence folder.

**What changed:**
Each hook now calls `Resolve-HookTargetWorktree -SessionRoot $Root -FilePath $filePath` after the scope filter and the route-import check. A non-ambiguous result that differs from the session root becomes `$targetRoot`. The hook allows root-level `artifacts/` paths without a slot, reads the checkpoint from `$targetRoot`, passes `-Root $targetRoot` to containment and rehydration (Claude), and keys the state file as `<kind>-batch-budget.<sessionId>.<worktreeKey>.json` under the session root's state directory when the target differs from the session root. Bundled mirrors, pack manifests, six brief copies, and the orchestrator-state rule are updated.

**Top 3 risks:**
1. Each in-scope Write/Edit with an absolute path now starts one unbounded `git worktree list --porcelain` process (accepted in spec R3); a stalled git would stall the hook.
2. Per-worktree keying gives a session a separate three-file direct-mode budget in each registered worktree; this follows from the spec but widens the per-session total across worktrees.
3. The resolver's nested helper functions read variables of the enclosing function through dynamic scope (`$roots`, `$listDetail`, `$records`, `$session`), which is correct today but sensitive to reordering in the consumer items #1010 and #1011.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all local gates pass, and the remaining CI confirmation is owned by the S9 gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1` | `Invoke-*BatchBudgetHook`, resolver wiring block (about 15 lines each) | The target-root selection and the `artifacts/` check are duplicated textually across four hooks. | When #1010 or #1011 adds a third consumer pattern, consider a small exported helper (for example, a function returning `TargetRoot` and `IsSessionRoot`) in the module and twin. No change required for this item. | Four copies of the same rule can drift; the existing mirror tests compare source to bundle, not hook to hook. | `git diff 8451891a5..HEAD -- .claude/hooks/enforce-python-batch-budget.ps1 .codex/hooks/enforce-python-batch-budget.ps1` |
| Minor | `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | lines 241-299 (nested helpers) | `Resolve-HookTargetPathSource` and `Resolve-HookTargetBranchSource` read `$roots`, `$listDetail`, `$records`, and `$session` from the enclosing function by dynamic scope; `$roots` and `$listDetail` are assigned after the helper definitions. | Pass these values as parameters, or add a comment at the definition site naming the enclosing variables each helper reads. Keep the twin in step. | Implicit coupling is easy to break when a consumer item reorders statements; the existing comment at line 241 states the pattern but not the variable list. | `HookTargetWorktree.psm1` lines 241, 277, 280, 295, 330-341 |
| Nit | `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | line 260 (`Get-HookTargetRecordedIssue`) | A throwing `-CheckpointIssueReader` is converted to `$null` without recording the error in `Detail`. | Consider surfacing the reader failure in `Detail` when #1010 or #1011 first supplies a reader. | The resolver contract is not-throwing, so swallowing is intended, but a silent reader failure reduces diagnosability. Not exercised by the batch-budget hooks. | `HookTargetWorktree.psm1` line 260 |
| Nit | `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1` (and the PowerShell sibling) | lines 100, 112, 124 | The invoker is supplied through a local `$PSDefaultParameterValues` entry whose scriptblock value is evaluated to return the invoker, rather than through the `-Extra` hashtable the helper already accepts. | Optional: pass `-Extra @{ WorktreeListInvoker = (Get-TargetInvoker) }` for direct readability. | The indirection is correct (local to the `It` scope; shuffle runs pass) but less obvious to a reader. | `isolation-shuffle.2026-10-30T18-48.md` |
| Info | `.claude/hooks/enforce-*-batch-budget.ps1` | resolver call | One `git` process per in-scope absolute-path Write/Edit, unbounded (spec R3). | None for this item; monitor hook latency after merge. | Accepted design decision recorded in `spec.md` Performance constraints and Risks. | `spec.md` R3 |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `.claude/hooks/enforce-python-batch-budget.ps1` at 535), so no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- All resolution logic is in one module with no imports and no file, environment, or clock reads; the only I/O is the injectable invoker and reader, pinned by AST rows.
- The fallback always goes to the session root, which is today's behavior and fails toward the cap. An `Ambiguous` or `$null` result never selects the exemption.
- Session-root edits keep the existing state-file name, so existing state remains valid and rollback is a revert.
- The `artifacts/` exclusion is computed relative to the resolved root and applies only to the root-level directory, matching the `/artifacts` `.gitignore` entry; a nested `artifacts` directory still counts.
- The Codex twin's function text is byte-compared to the module by `Extent.Text`, and both suites run the same 74 shared behavior rows.

#### API and safety notes

- Exported functions use `[CmdletBinding()]`, `[OutputType()]`, and approved verbs; `Export-ModuleMember` lists exactly six functions.
- The new `-WorktreeListInvoker` hook parameter has no default and is forwarded only when bound, so the module default stays the single source of the git invocation.
- Comparisons use `OrdinalIgnoreCase` unconditionally, so Git for Windows forward-slash roots and backslash payload paths match; the 8.3/junction limitation is documented in the module and in each hook's help.
- PSScriptAnalyzer reports 0 findings on all 20 changed PowerShell files.

#### Error handling and logging

- Guarded imports (`Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1'` / `'hook-target-worktree.ps1'`) fail closed; B1 rows in both dependency-failure suites pass.
- Route-helper import failure still denies before any invoker call.
- Invoker exceptions are caught and reported in `Detail` ("the worktree list failed: ..."), then fall back to the session root.

---

## Test Quality Audit

Five new Pester suites and one shared row-helper file were added; two existing contract suites gained one entry each. Coverage, regression (fail-before/pass-after), isolation (three seeded shuffles, single-process full run), and contract-test evidence are present.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` — 83 rows: helpers, porcelain, resolver precedence/fallback/ambiguity, identity, reason-code equality, AST no-I/O assertions.
- `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` — 83 rows: same shared rows against the twin plus 9 parity rows.
- `tests/scripts/claude-hooks/enforce-{python,powershell}-batch-budget.TargetWorktree.Tests.ps1` — 20 and 21 rows: R1/R2/R3 regression, capped-without-checkpoint, sibling tightening, ordering, outside-every-worktree.
- `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` — 20 rows across both Codex hooks, including the `apply_patch` move across worktrees.
- `evidence/regression-testing/regression-fail-before.2026-10-30T17-16.md` — expected EXIT_CODE 12 before the fix; `regression-pass-after.2026-10-30T17-47.md` — passes after.
- `evidence/qa-gates/coverage-delta.2026-10-30T18-27.md` — re-verified by this review from `artifacts/pester/powershell-coverage.xml`.

### Quality assessment prompts

- **Determinism:** in-memory porcelain, checkpoint, and state seams; no git process; slash-rooted synthetic paths valid on Linux and Windows.
- **Isolation:** one behavior per `It`; `BeforeEach` rebuilds the store.
- **Speed:** new suites perform no disk or process I/O; full suite 764.46s for 13329 tests.
- **Diagnostics:** `-Because` clauses include the deny reason text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | The default invoker uses the call operator with an argument list (`& git -C $SessionRoot worktree list --porcelain`), not string-built command text. |
| Input validation at boundaries | ✅ PASS | Blank and relative inputs handled explicitly; porcelain parsing tolerates CRLF and unknown lines. |
| Error handling remains explicit | ✅ PASS | Not-throwing resolver contract with `ReasonCode`/`Detail`; guarded imports fail closed. |
| Configuration / path handling is safe | ✅ PASS | State is written only under the session root's state directory; the worktree key is sanitized to `[A-Za-z0-9._-]` plus 8 hex characters, so it cannot escape the directory. |
| Gate strictness preserved | ✅ PASS | `-ProdCap` default, reason codes and text, and deny-only output unchanged; existing ten batch-budget suites pass without edits. |

---

## Research Log

No external research was required. The review relied on the repository's spec, research document, rule files, and the branch diff.

---

## Verdict

The change is ready for normal PR flow. It implements the spec's resolver contract and hook semantics with logic isolated in a pure module, keeps every fallback on today's behavior, and is supported by high coverage (99.3% on new files, no regression on changed hooks) and clean isolation runs. The findings are Minor, Nit, and Info items for follow-up consideration in #1010 and #1011 and do not require remediation in this item. CI confirmation of AC-13, AC-25, and AC-39 is owned by the S9 gate.
