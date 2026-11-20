# Feature Audit: Batch-budget hooks resolve the target worktree (#1009)

---

**Audit Date:** 2026-10-30
**Feature Folder:** `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009`
**Base Branch:** `main`
**Head Branch:** `bug/batch-budget-hooks-coordinator-root-1009`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `8451891a592e4d8e267d7de2a9f76f516e77f187`)
- **Head branch/commit:** `bug/batch-budget-hooks-coordinator-root-1009` (commit `84574e7ad5aad1de3a70671e3515b76f6e37ec46`)
- **Merge base:** `8451891a592e4d8e267d7de2a9f76f516e77f187`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-30 19:08:37 UTC for the head SHA above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/evidence/**`
  - Additional evidence: direct inspection by this review of `artifacts/pester/powershell-coverage.xml`, the hook and module diffs, SHA-256 of each source/bundle pair and the six brief copies, logical line counts, and `validate_evidence_locations.py`
- **Feature folder used:** `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source; no `user-story.md` exists or is required.
- **Scope note:** The audit covers the full branch diff against `main`. AC-13, AC-25, and AC-39 contain clauses that require CI on the PR head; no PR exists yet, so those clauses are UNVERIFIED pending CI and are owned by the orchestrator S9 gate per `acceptance-criteria-tracking` `### CI-Dependent Criteria` (`evidence/qa-gates/ci-checks.2026-10-30T19-04.md`).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/spec.md` — only source

### Acceptance criteria

Criteria are numbered AC-1 to AC-40 in source order; full text is in `spec.md` `## Acceptance Criteria`.

Resolver module:
1. `HookTargetWorktree.psm1` exists, sets StrictMode Latest, imports no module, references no module-scope `$script:` state, and exports exactly the six named functions via explicit `Export-ModuleMember`.
2. `Resolve-HookTargetWorktree` has the seven named parameters and returns `WorktreeRoot`, `Source`, `Ambiguous`, `ReasonCode`, `Detail`, `Candidates` within the contract domains; verified by `HookTargetWorktree.Tests.ps1`.
3. Strict precedence verified; no-source case returns the session root without calling the invoker.
4. Absolute path resolves to the nearest enclosing registered worktree (nested, sibling, main).
5. Relative path resolves to the session root without calling the invoker.
6. Path in no worktree, throwing invoker, and empty invoker each yield the session-root fallback with non-empty `Detail`.
7. Ambiguity and not-derivable rows pass; a present identity naming no worktree never falls back to the session root.
8. A test pins the two reason-code literals to `Get-WorktreeResolutionAmbiguityReasonCode` / `Get-WorktreeResolutionNoTargetReasonCode`.
9. Normalization and `OrdinalIgnoreCase` verified across backslash, repeated-slash, trailing-slash, drive-rooted, and case-variant inputs.
10. Porcelain parser rows cover main, linked, bare (skipped), detached, prunable, blank lines, and CRLF.
11. `Get-HookTargetWorktreeKey` format and equality with the worktree-derived session-id algorithm pinned by a test.
12. AST test asserts no file/environment/clock read outside the default invoker body and the shape of the default invoker body.

Codex twin:
13. Twin exists as functions-only with equal function names and `Extent.Text`, verified by `hook-target-worktree.Tests.ps1`, which also runs behavior rows on the Linux hook-suite job.
14. `hook-target-worktree.ps1` added to `$script:SharedModuleNames`; `legacy-codex-hook-contracts.Tests.ps1` passes.

Claude batch-budget hooks:
15. Both Claude hooks use the guarded one-statement import; guard-completeness passes; B-row denies naming `HookTargetWorktree.psm1`; no new exemption entry.
16. Repro fixed: item worktree checkpoint `large`/`remediation`/`preparation` leaves the item uncapped; checkpoint path read is under the item root.
17. Item worktree without checkpoint (or terminal/non-large route) stays capped with unchanged reason text.
18. State keyed per resolved worktree root; worktree-keyed name under the session root; session-root name unchanged; no state in other worktrees; containment and rehydrate use the resolved root.
19. Root-level `artifacts/` paths (absolute and relative) allowed without slot or state for `.py` and `.ps1`; nested `artifacts` still counts.
20. File outside every registered worktree keeps today's behavior.
21. Claude sibling-worktree edits count against that worktree's own budget; test row and brief statement.
22. Ordering preserved; route-helper import failure denies before any invoker call; RouteImportFailure suite unchanged and passing.
23. Cap as strict as today; `Ambiguous` or `$null` result falls back to the session root.

Codex batch-budget hooks:
24. Both Codex hooks dot-source the twin through a guarded statement; B-row passes.
25. `codex-batch-budget.TargetWorktree.Tests.ps1` passes for both Codex hooks with the seven listed rows.

Existing suites and unchanged files:
26. The eleven listed existing suites pass without edits.
27. Route helper and listed #1010/#1011 consumer files, `enforce-model-routing-receipt.ps1`, `settings.json`, `config.toml`, `python.json`/`powershell.json` manifests, and checkpoint schemas unchanged.

Mirrors, manifests, and contracts:
28. Bundled copies byte-identical; both resource-contract pytests pass.
29. Pack-manifest entries present; completeness, dependency-closure, and generator `--check` pass.
30. `WorktreeResolution.Manifest.Tests.ps1` lists the module in `$script:ExpectedPaths` and each `-ForEach` list, and passes.

Documentation:
31. All six brief copies updated identically with the specified Batch Budget, Hook Execution Context, and Preflight Defect Classes statements.
32. `test_execution_environment_brief_contracts.py` passes.
33. `## Command-Text Restrictions` reviewed, unchanged, reason recorded.
34. `.claude/rules/orchestrator-state.md` and bundle gain the identical `## Enforcement` statement.
35. Each edited hook's `.DESCRIPTION` documents resolved-root behavior and the 8.3/junction limitation.

Non-functional gates:
36. No enforcement hook invokes Python.
37. Line coverage for the module and twin meets the threshold; changed hook lines do not regress.
38. File-size limits hold.
39. Full toolchain loop completes in one clean pass, and the isolation checks pass.
40. Evidence artifacts under `<FEATURE>/evidence/<kind>/` with UTC stamps, no absolute paths, counts from `pester-junit.xml`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Module shape and exports | PASS | Module lines 34-35 (StrictMode, Stop), no `Import-Module`, no `$script:` reference, lines 385-391 export six functions | `Read .claude/lib/worktree-resolution/HookTargetWorktree.psm1` | Inspected directly. |
| 2 | Resolver parameters and result shape | PASS | Lines 225-233, 242-252; `resolver-suite.2026-10-30T17-27.md` 83/83 | `Invoke-PoshQCTest` over `HookTargetWorktree.Tests.ps1` | |
| 3 | Strict precedence; no-source case | PASS | Lines 307-322; resolver rows 18 pass | same | |
| 4 | Nearest enclosing worktree | PASS | `Get-HookTargetWorktreeEnclosingRoot` longest-prefix rule (lines 114-121); helper and resolver rows | same | |
| 5 | Relative path, no invoker call | PASS | `$needsList` (line 326) excludes relative-only sets; resolver rows with recording invoker | same | |
| 6 | Fallback rows with non-empty `Detail` | PASS | Lines 278-281, 333-339; resolver rows | same | |
| 7 | Ambiguity and not-derivable rows | PASS | Lines 287-297, 345-382; identity rows 25 pass | same | |
| 8 | Reason-code literal equality test | PASS | Module-only reason-code accessor row passes | same | |
| 9 | Normalization and case-insensitive comparison | PASS | Lines 55-60, 237; helper rows 24 pass | same | |
| 10 | Porcelain parser rows | PASS | Lines 165-191; porcelain rows 7 pass | same | |
| 11 | Worktree key format and session-id equality | PASS | Lines 141-145; session-id equality row passes | same | |
| 12 | AST no-I/O and default invoker shape | PASS | AST rows 7 pass; banned-command list in `HookTargetWorktree.Tests.ps1` line 195 | same | |
| 13 | Codex twin parity and Linux behavior rows | UNVERIFIED | Local: `twin-suite.2026-10-30T17-30.md` 83/83 (9 parity rows, 74 behavior rows); mirror hash equal. Linux job result pending. | `Invoke-PoshQCTest` over `hook-target-worktree.Tests.ps1`; CI `poshqc / PowerShell hook suites (Linux)` | CI-dependent; owned by S9. Local clauses satisfied. |
| 14 | `SharedModuleNames` entry; legacy contracts pass | PASS | Diff adds `'hook-target-worktree.ps1'`; `pester-touched.2026-10-30T18-27.md` legacy suite 43/43 | `git diff 8451891a5..HEAD -- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | |
| 15 | Claude guarded import and dependency rows | PASS | Hook diff line +81 (guarded `Import-Module ... -ErrorAction Stop`); B1 rows pass; guard completeness 671/671; `HookImportFailureExemptions.Helpers.ps1` absent from diff | `git diff --stat 8451891a5..HEAD` | |
| 16 | Repro fixed (item checkpoint uncapped) | PASS | R1 rows pass; `regression-fail-before` (expected exit 12) and `regression-pass-after` | `Invoke-PoshQCTest` over the three TargetWorktree suites | |
| 17 | Item without checkpoint stays capped | PASS | Claude TargetWorktree suites 20/20 and 21/21 | same | |
| 18 | State keyed per resolved worktree root | PASS | Hook lines `$stateLeaf`; R2 asserts `python-batch-budget.r2.item-<8hex>.json` under `/repo/.claude/state/`; `-Root $targetRoot` on containment and rehydrate | Diff inspection; same suites | |
| 19 | Root-level `artifacts/` excluded; nested counts | PASS | Hook `$relativePath` check; R3 rows pass in both Claude suites | same | |
| 20 | Outside every worktree keeps today's behavior | PASS | Resolver fallback returns session root; hook keeps `$Root`; suite rows pass | same | |
| 21 | Claude sibling-worktree tightening | PASS | Sibling row passes; brief `## Batch Budget` bullet states it | `Read .claude/skills/execution-environment/SKILL.md` | |
| 22 | Ordering preserved | PASS | Resolver call placed after the scope filter and route-import deny; RouteImportFailure 20/20 unchanged | Diff inspection; `pester-touched.2026-10-30T18-27.md` | |
| 23 | Cap as strict as today | PASS | No change to `-ProdCap`, reason text, or decision functions in diff; `Ambiguous`/`$null` guard on `$targetRoot` | Diff inspection | |
| 24 | Codex guarded dot-source and B-row | PASS | Codex hook diff adds guarded `. (Join-Path $PSScriptRoot 'hook-target-worktree.ps1')`; Codex B1 rows pass | same | |
| 25 | Codex TargetWorktree suite passes with seven rows | UNVERIFIED | Local: 20/20 including the `apply_patch` move row (line 200). CI result pending. | CI `poshqc / PowerShell hook suites (Linux)` and `poshqc / PowerShell QC` | CI-dependent; owned by S9. |
| 26 | Existing suites pass without edits | PASS | All eleven suites pass with counts listed in `pester-touched.2026-10-30T18-27.md`; none appears in the branch diff | `git diff --name-only 8451891a5..HEAD` | |
| 27 | Listed files unchanged | PASS | Branch diff contains no route helper, no `enforce-orchestration-preimplementation-gate*`, no `enforce-pr-author-skill*`, no `enforce-model-routing-receipt.ps1`, `settings.json`, `config.toml`, `python.json`, `powershell.json`, or schema file; route-helper bundle hash equal | `git diff --name-only 8451891a5..HEAD`; SHA-256 check | |
| 28 | Bundles byte-identical; resource-contract pytests pass | PASS | All eleven source/bundle pairs equal (verified by this review); resource contracts 14 and 9 pass | SHA-256 check; `poetry run pytest ...` | |
| 29 | Pack-manifest entries; closure and generator pass | PASS | Diff of both `core.json`; completeness 2+2, closure 18; `codex-generator-check.2026-10-30T18-27.md` exit 0 | same | |
| 30 | Manifest test lists updated and passing | PASS | Diff adds the module to `$script:ExpectedPaths` and three `-ForEach` lists; 25/25 | same | |
| 31 | Six brief copies updated identically | PASS | One distinct SHA-256 across six copies (this review); diff shows the three required section edits | SHA-256 check; diff of `.claude/skills/execution-environment/SKILL.md` | |
| 32 | Brief contract pytest passes | PASS | `pytest-contracts.2026-10-30T18-27.md` brief contracts 19 passed | `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | |
| 33 | Command-Text Restrictions reviewed, unchanged | PASS | `evidence/other/command-text-restrictions-review.2026-10-30T17-45.md`; section absent from diff hunks | Diff inspection | |
| 34 | Rule file and bundle statement | PASS | Diff adds the `## Enforcement` bullet; source and bundle hashes equal | same | |
| 35 | Hook help updated | PASS | `.DESCRIPTION` diffs in all four hooks; `help-tokens-*.md` | Diff inspection | |
| 36 | No enforcement hook invokes Python | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 33/33 | `Invoke-PoshQCTest` | |
| 37 | Coverage threshold and no regression | PASS | Module 99.34%, twin 99.33%; hooks 94.08% and 95.80% vs baseline 93.53% and 95.28% (re-read from `artifacts/pester/powershell-coverage.xml`) | JaCoCo parse | |
| 38 | File-size limits hold | PASS | Logical counts: Codex hooks 390/387 and twin 369 (at or below 500); Claude hooks 535/532; none at or above 801 | Logical line count by this review | |
| 39 | Full toolchain loop and isolation checks | UNVERIFIED | Local: clean final pass (`format`, `pssa`, `type-check`, `architecture`, `pester-touched`, `pytest-contracts`, `integration` at 18-27), full run 13319 passed, three seeded shuffles, single-process run. CI confirmation pending. | CI contexts listed in `ci-checks.2026-10-30T19-04.md` | CI-dependent; owned by S9. Local clauses satisfied. |
| 40 | Evidence locations and format | PASS | `validate_evidence_locations.py` exit 0; no `artifacts/(baselines|qa|evidence|coverage)/` path in diff | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 3 criteria (AC-13, AC-25, AC-39; CI-dependent, pending the PR-head CI run)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None in local scope. The three UNVERIFIED criteria are CI-dependent and are resolved by the orchestrator S9 gate after the PR exists; they are not remediation items.

**Recommended follow-up verification steps:**

1. At S9, confirm `poshqc / PowerShell hook suites (Linux)`, `poshqc / PowerShell QC`, `CI full run`, and the eleven required contexts in `evidence/qa-gates/ci-checks.2026-10-30T19-04.md` conclude `success` on the final PR head.
2. Check off AC-13, AC-25, and AC-39 in `spec.md` from the item's own worktree, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/spec.md`
- Total AC items: 40
- Checked off (delivered): 37
- Remaining (unchecked): 3
- Items remaining: AC-13 (Codex twin parity verified by `hook-target-worktree.Tests.ps1`, including the Linux hook-suite job); AC-25 (`codex-batch-budget.TargetWorktree.Tests.ps1` passes for both Codex hooks with the seven listed rows); AC-39 (full toolchain loop in one clean pass and isolation checks)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 40 | 37 | 3 | Checkbox-backed; the 37 PASS items were already checked by the executor and are confirmed here; the 3 unchecked are CI-dependent. |

No source-file checkbox change was made by this review: every criterion evaluated PASS was already checked, and the three UNVERIFIED CI-dependent criteria remain unchecked for the S9 check-off.
