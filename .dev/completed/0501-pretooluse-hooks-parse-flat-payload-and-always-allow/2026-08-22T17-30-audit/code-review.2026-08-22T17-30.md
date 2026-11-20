# Code Review: PreToolUse hooks parse flat payload and always allow (#501) — Cycle-1 Re-Audit

**Review Date:** 2026-08-22
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
**Base Branch:** `main` (`origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`)
**Head Branch:** `bug/pretooluse-hooks-parse-flat-payload-501 @ db3de8314d12d23d82f2fdaafcc0f9e7632f433e`
**Review Type:** Re-audit (cycle-1 close, plus authorized scope expansion)

**Template source note:** the MCP template-resolution tool was not exercised in this session; the same section layout as the prior cycle's code review (`code-review.2026-08-21T22-23.md`) is reused for continuity.

---

## Executive Summary

This cycle closes the prior review's sole Blocking finding (coverage regression on `enforce-powershell-batch-budget.ps1` and `enforce-python-batch-budget.ps1`) and delivers one authorized scope-expansion item (AC-15, work-mode-aware `enforce-prd-feature-before-planner.ps1`). Both are independently verified in this review: the coverage fix by re-running the affected suites in a freshly-configured `PesterConfiguration` and reproducing the executor's exact 95.56%/86-of-90-lines figure and missed-line set for both hooks, and the AC-15 fix by reading the code directly and independently re-running its test suite (47/47 pass).

Scope for this cycle: two commits, `d0c472c3` (AC-15) and `db3de831` (batch-budget entry-point seam), touching 6 production files (2 hooks + 2 mirrors + `pester.runsettings.psd1` x2) plus their test suites and this feature's own evidence artifacts. The full branch (`fb30a9a5..db3de831`) remains the audit scope per this review's mandate; nothing in the prior cycle's already-verified surface (the shared `HookPayload.psm1` reader, the 24-hook migration, the mirror set) was re-litigated from scratch, but spot checks (mirror byte-identity across all changed `.claude/**` files, the SubagentStop scope boundary, file-size ceiling) were re-run against the full diff rather than trusted from the prior cycle's report.

**What changed this cycle:**
- `enforce-powershell-batch-budget.ps1` / `enforce-python-batch-budget.ps1`: gained `Invoke-<Name>EntryPoint`, the same seam shape as ten precedent hooks (verified byte-for-byte identical tail structure against `enforce-evidence-locations.ps1`); deny-only emission convention preserved (confirmed by direct code reading, since the borrowed precedent is always-emit and this was the one point the task explicitly flagged as needing verification); corrected write-then-exit tail, not the naive `exit (Invoke-...)` form.
- `enforce-prd-feature-before-planner.ps1`: three new functions (`Get-PrdFeatureIssueContent`, `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`) replace a hardcoded two-file requirement with a work-mode-driven lookup that fails closed with a distinguishable reason on an undeterminable mode.
- `pester.runsettings.psd1`: nine `CodeCoverage.Path` entries added, purely additive.
- Four new evidence artifacts dispositioning the prior Major/Minor/Info findings; two documenting AC-15.

**Top risks (re-assessed):**
1. **Resolved.** Tail coverage on the two batch-budget hooks restored to 95.56% each with the changed-line intersection reproduced empty in this session.
2. **New, non-blocking.** `enforce-prd-feature-before-planner.ps1`'s docstring contains a documentation-accuracy defect (duplicated word, stale environment-variable reference) — see Findings Table.
3. **Unchanged from prior cycle, not re-litigated this cycle.** Strict no-flat-fallback posture on the wider hook surface; already reviewed and accepted last cycle.

**PR readiness recommendation:** **Ready to merge** — zero Blocking findings remain.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (resolved) | `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1` | tail (lines 268-284 / 265-281) | Prior Blocking coverage-regression finding is fixed: the `Invoke-<Name>EntryPoint` seam restores per-file line coverage to 95.56% (86/90) each, and the intersection of `git diff -U0` changed lines against the final missed-line set is empty for both files. | None — verified resolved. | Independently reproduced in this session with a fresh `PesterConfiguration` scoped to only the two hooks' suites (no reliance on the executor's XML). | This review's `artifacts/pester/verify-batch-budget-coverage.xml`: LINE missed=4 covered=86 total=90 for both files; missed lines `279,280,281,284` (PowerShell) and `276,277,278,281` (Python). |
| Info (resolved) | `docs/features/active/.../evidence/qa-gates/2026-08-22T15-15-coverage-comparison-correction.md` | whole artifact | Prior Major finding (overstated "no regression" claim) is corrected via a superseding sibling artifact; the original is confirmed untouched (`git status --porcelain` empty, re-verified this session). | None — disposition assessed as correct; appending rather than mutating preserves the audit trail of what was originally measured and claimed. | Evidence-and-timestamp conventions favor append over mutation for exactly this reason. | This session's `git status --porcelain` re-run on the original artifact path; empty output. |
| Minor | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | lines 8-9 (`.DESCRIPTION`) | The docstring reads "Reads tool input JSON from the the envelope's nested tool_input environment variable." This has a duplicated "the the" and is factually stale: the hook no longer reads an environment variable at all (it reads via `Read-ClaudeHookRawPayload`, a stdin-first shared reader with env fallback only inside the module). Introduced by the AC-15 edit to this comment block. | Fix the duplicated word and correct the description to something like "Reads tool input JSON acquired through the shared payload reader (stdin-first, with env-var fallback inside the reader module)." Low-risk, comment-only change. | Stale/incorrect docstrings mislead future maintainers about the transport mechanism this same feature deliberately changed away from an environment variable. | Direct read of `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 1-9, this session. |
| Info (resolved) | `artifacts/pester/powershell-coverage.repo-runsettings.xml` (absent), `.claude/state/*.json` transients, `artifacts/pr_context.summary.txt` noise | n/a | Prior Minor and two Info findings all dispositioned with no code change and an explicit, checkable rationale each; none re-surfaced as a problem in this cycle's evidence. | None — dispositions adequate. | Reviewed each disposition individually; none is a bare "will not fix" — each cites either independent reproduction, a standing procedural mitigation exercised in this cycle's own trail, or a scope boundary. | `evidence/other/2026-08-22T15-19-minor-info-findings-disposition.md`. |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **Entry-point seam reuse is exact, not approximate.** The tail of both batch-budget hooks (`$entryPointResult = @(Invoke-...EntryPoint)`; conditional multi-emit; `exit ([int]$entryPointResult[-1])`) is byte-for-byte the same shape as `enforce-evidence-locations.ps1`'s tail, confirmed by direct comparison in this session. This is genuine pattern reuse, not a superficially similar rewrite.
- **Deny-only emission convention correctly preserved despite an always-emit precedent.** `Invoke-PowerShellBatchBudgetEntryPoint` and its Python sibling gate the `ConvertTo-Json | Write-Output` call behind `if ($decision.hookSpecificOutput.permissionDecision -eq 'deny')`, exactly matching the pre-change behavior (confirmed by diffing the merge-base tail against the current tail). The borrowed precedent hooks are always-emit; this fix correctly did not import that behavior, since it would have changed the hooks' external contract.
- **AC-15's fail-closed default is structurally forced, not merely documented.** `Get-PrdFeatureRequiredFile`'s `switch` statement has exactly three named cases (`full-feature`, `full-bug`, `minor-audit`) and a `default` case returning the strictest set; there is no code path — including `$null` input — that reaches a permissive return. The two block-reason strings (`$modeDetermined` true vs. false) are genuinely different literal strings, not a shared template with an interpolated flag, so AC-15(d)'s distinguishability requirement is met at the code level, not just at the prose level.
- **`Get-PrdFeatureMissingFile`'s `-RequiredFile` parameter correctly handles the zero-element `minor-audit` case.** The call site wraps the result in `@(...)` before passing it, with a comment explaining why: PowerShell unravels a zero-element array to `$null` down the pipeline, which would otherwise fail the `Mandatory` parameter binding. This is a real PowerShell pitfall correctly anticipated and guarded.

#### API and safety notes

- No public API or hook decision contract changed shape this cycle. `Invoke-PrdFeatureBeforePlannerDecision`'s signature and return shape are unchanged; only its internal missing-file computation gained a mode-dependent input.
- The AC-15 regex `(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$` is anchored and case-insensitive per line, matching the convention the docstring cites (`scripts/dev_tools/prompt_mode_contract.py`); this reviewer did not cross-verify the Python-side regex character-for-character, since work-mode parsing is orthogonal to this feature's payload-transport subject and was reviewed once by the prior cycle for the wider hook surface.

#### Error handling and logging

- Both batch-budget hooks continue to fail closed on envelope anomalies via `Get-ClaudeHookPayloadAnomalyReason`, unchanged by this cycle.
- `Get-PrdFeatureIssueContent` catches its `Get-Content` call and returns `$null` on failure rather than propagating, which `Resolve-PrdFeatureWorkMode` then treats identically to an absent marker — collapsing "unreadable" and "absent" into the same fail-closed branch, which is correct per AC-15(d)'s explicit inclusion of both cases in the same fail-closed outcome (though the two are still one class apart from "marker present but unrecognized," and all three receive the same block-reason text, which is intentional per the AC).

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`, `enforce-python-batch-budget.Tests.ps1`: re-run independently this session (45 tests total, 0 failures) with coverage scoped to just the two hook files; coverage figures match the executor's claim exactly.
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`: re-run independently this session (47 tests, 0 failures); spot-checked test titles for the four work-mode branches and the four undeterminable-marker sub-cases — all descriptively named, one behavior per test, AAA-shaped on inspection.
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` (AC-8 structural guard): executor re-run cited (77/77 pass, `evidence/qa-gates/2026-08-22T14-41-payload-contract-regression-check.md`); this reviewer additionally grepped every changed `.claude/hooks/*.ps1` file for the two retired env-var literals and confirmed only out-of-scope files (SessionStart hook, SubagentStop validators) still reference them.
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`: re-run this session, 1 passed.

### Quality assessment prompts

- **Independence/isolation:** both new test additions (batch-budget seam tests, AC-15 work-mode tests) mock their read seams (`-ReadPayload`, `Get-PrdFeatureIssueContent`) rather than touching the filesystem or spawning processes; no shared mutable state observed between tests in either suite when re-run standalone.
- **Determinism:** no `Start-Sleep`, `Get-Date`, or unseeded randomness introduced in either changed test file (grepped this session).
- **Scenario completeness for AC-15:** positive cases for all three named modes, negative cases for all four ways a marker can fail to resolve (absent, unreadable, unrecognized value, `issue.md` itself missing), and the legacy-`full`-normalizes-to-`full-feature` case are all present as distinct `It` blocks.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection this session; work-mode marker is read-only text, no credential handling. |
| No unsafe subprocess or command construction | PASS | No new subprocess invocation; both changed hooks retain their existing read-only seams. |
| Input validation at boundaries | PASS | `Resolve-PrdFeatureWorkMode` anchors its regex and rejects any value outside the three-plus-legacy enum via the `default` switch case. |
| Error handling remains explicit | PASS | Fail-closed on every undeterminable-mode path; no catch-and-continue that silently widens permissions. |
| Fail-open eliminated (AC-15's own subject) | PASS | Reviewer-verified: the `switch` statement's only way to reach a permissive (empty) required-file set is the literal string `'minor-audit'`; every other input, including `$null`, falls through to the strictest set. |
| Regression on the original #501 fix (transport/shape) | PASS | Unchanged by this cycle; not re-litigated in depth here since it was independently verified last cycle and no file in the shared-reader surface was touched this cycle. |

---

## Research Log

- Independently rebuilt a `PesterConfiguration` (no reuse of executor XML) scoped to `enforce-powershell-batch-budget.Tests.ps1` + `enforce-python-batch-budget.Tests.ps1` against the two production hooks; reproduced 95.56% (86/90) for both, missed lines `279-281,284` / `276-278,281`.
- Independently rebuilt a second `PesterConfiguration` scoped to `enforce-prd-feature-before-planner.Tests.ps1`; 47/47 pass, `Covered 88.98% / 75%`.
- Confirmed the entry-point tail shape byte-for-byte against `enforce-evidence-locations.ps1` by direct file inspection, to establish this is the codebase's established norm rather than a special case for the two remediated hooks.
- Confirmed the merge-base tail (`exit 0` unconditional, deny-only emission) by `git show fb30a9a5:.claude/hooks/enforce-powershell-batch-budget.ps1` and diffed against the current tail's semantics.
- Confirmed mirror byte-identity for all 24 changed `.claude/hooks/*.ps1` files, `HookPayload.psm1`, and both `pester.runsettings.psd1` copies via direct `diff`.
- Ran `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- Confirmed no `SubagentStop` validator or `.codex/hooks/` path in the diff, and that the three `SubagentStop`-mentioning changed files reference it only in comments about a separate, later-invoked hook event.

---

## Verdict

**Ready to merge.** Zero Blocking findings. One new Minor finding (docstring accuracy in `enforce-prd-feature-before-planner.ps1`) does not gate merge; recommended as a low-risk follow-up edit, either in this branch before opening the PR or as a trivial fast-follow.

Severity: Minor
