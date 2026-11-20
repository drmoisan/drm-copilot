# Code Review: Strict epic_mode in three enforcement hooks (#1001), reaudit after remediation cycle 1

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001`
**Feature Folder Selection Rule:** the only active folder whose suffix matches issue 1001 in the branch name; it holds the material scoping-doc changes.
**Base Branch:** `main` (merge base `ccec4eba82e272d27f7d81c0e0657a93110de5fb`)
**Head Branch:** `bug/merge-gate-epic-mode-string-false-1001` (`45827a64c91d648bff71be0bf41c04cf31aebfe7`)
**Review Type:** Re-review after remediation cycle 1 (prior review `2026-10-31T06-56`)

---

## Executive Summary

The branch fixes a type-coercion defect in three PowerShell enforcement hooks. Two hooks cast the checkpoint `epic_mode` value with `[bool]`, so the string `"false"` and any non-zero number were treated as epic mode; the third compared with `-eq $true`, so the string `"true"` and the integer `1` were treated as epic mode. Each site now uses `(($v -is [bool]) -and $v)`, the idiom already used by `enforce-epic-merge-gate-green-ci.ps1` and the Codex merge gate.

Remediation cycle 1 changed only documentation and evidence files inside the feature folder (10 files, verified with `git diff --name-only efa4259525e592dcc42a52a03bb0e938821d774e HEAD`); no hook, mirror, or test file changed since the prior review, so the prior code assessment carries over unchanged. This review re-verified mirror parity (`cmp`, 3 of 3 identical), the branch-diff scope, and the new full-suite coverage artifact.

**What changed:**
- `Test-ChildCheckpointAllowsEpicMerge`, `Test-EpicBaseBranchOverride`, and `Get-ModelRoutingAuthorAssertedReason` each replace one predicate expression. Property presence is still tested before the value is read, so strict mode remains safe.
- Script and function help in all three hooks state that only the JSON boolean `true` counts and cite issue #1001.
- Three bundled mirrors are byte-identical to the sources.
- Three new suites cover the eight-value matrix and merge-gate decision rows.

**Top 3 risks:**
1. Behavior tightening: a live checkpoint that records `epic_mode` as `"true"` or `1` loses epic treatment in all three hooks. The spec records that no writer of such a value was found, and the change direction is toward the documented contract.
2. The strict idiom is repeated inline in five places across the Claude hook surface; a future consumer could reintroduce a coercing form. The spec rejected a shared helper deliberately.
3. Hook execution context: isolated subagents run `main`'s hook copies, so the new behavior is exercised only by Pester until merge.

**PR readiness recommendation:** **Go.** No Blocker or Major code finding. The prior policy-audit evidence gap (repo-wide PowerShell coverage) is closed at 93.53% from a full-suite run.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1` | changed predicate lines (180, 121, 237) | The strict `epic_mode` idiom is written inline at each site, alongside existing inline copies in `enforce-epic-merge-gate-green-ci.ps1`. Nothing prevents a future hook from reintroducing `[bool]$x.epic_mode`. | No change required for this item (the spec rejected a shared helper as approach B). Consider a repository lint or contract test that flags `[bool]$<name>.epic_mode` and `.epic_mode -eq $true` under `.claude/hooks/` if the pattern recurs. | Inline repetition of a security-relevant predicate relies on reviewers to keep it consistent. | `git diff ccec4eba8..HEAD -- .claude/hooks`; `spec.md` Scope & Non-Goals |
| Nit | `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1` | lines 16-29 | `BeforeAll` sits at file scope, while the two sibling suites place it inside `Describe`. Both forms are valid in Pester 5. | Optional: move `BeforeAll` inside `Describe` to match the sibling suites. | Consistency across the three new suites aids reading; behavior is unaffected (shuffle, single-process, and full-suite runs pass). | `shuffle-seed-*.md`, `pester-coverage-full.2026-10-31T07-21.md` |
| Nit | `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` | lines 77-81 | Decision rows cover JSON `true`, `"false"`, and `"true"`; integer `1` is covered only at the unit level. | Optional: add an integer `1` decision row. | The unit row already proves `Test-ChildCheckpointAllowsEpicMerge` returns `$false` for `1`, and branch 1 consumes only that result. The spec AC-2 requires only the string rows. | `spec.md` AC-2 |
| Info | `docs/features/active/.../evidence/regression-testing/shuffle-seed-*.md` | n/a | The seeded runs shuffle file order; test order within each file follows Pester's default. | None for this item. | Matches the plan's fixed seed set and the repository shuffle procedure. | `shuffle-seed-2718.2026-10-31T06-37.md` |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `.claude/hooks/enforce-epic-merge-gate.ps1` and its mirror at 482), so no file-size Warning applies. `config/file-size-baseline.json` is not in the diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Each fix is a single-expression change that keeps the property-presence guard first, so an absent key still returns the non-epic result under `Set-StrictMode`.
- The fix uses an idiom already present in the repository, which keeps the merge gate's branch 1 consistent with the green-CI branch added in #997 and with the Codex merge gate.
- Deny and reason strings are untouched (only predicate lines and help text changed), so existing suites that assert them verbatim pass without edits.
- Mirror copies are byte-identical (`cmp` by this review: 3 of 3).

#### API and safety notes

- Function signatures, parameter sets, and output types are unchanged.
- The model-routing change narrows the waiver: only a `System.Boolean` `$true` waives the author-asserted line.
- The base-branch change removes a deny-direction misparse for non-boolean `epic_mode` values.
- PSScriptAnalyzer reports 0 findings on all 9 changed PowerShell files.

#### Error handling and logging

- No new exception path. Non-boolean values take the existing non-epic path. No logging change.

---

## Test Quality Audit

Three new Pester suites (31 rows including three probe rows). No existing test file is edited. Fail-before (11 expected failures), pass-after, three seeded shuffle runs, a single-process `tests/scripts` run, a full-suite coverage run (13518 tests, 0 failures, 0 errors, 10 skipped), and mirror-contract evidence are present.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` — 8 unit rows, 3 decision rows, 1 otherwise-green standalone row asserting zero `Get-EpicMergeGateLivePrHeadSha` calls, 1 probe row.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1` — 8 rows, 1 probe row.
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1` — 8 rows on in-memory `ConvertFrom-Json` checkpoints, 1 probe row.
- `evidence/regression-testing/fail-before.2026-10-31T06-20.md` — 31 tests, 11 failures.
- `evidence/regression-testing/pass-after.2026-10-31T06-22.md` — 31 passed.
- `evidence/qa-gates/pester-coverage-full.2026-10-31T07-21.md` — re-verified by this review from `artifacts/pester/powershell-coverage.xml` (repo-wide LINE 20871/1444 = 93.53%; hooks 132/0, 29/2, 81/3).

### Quality assessment prompts

- **Determinism:** in-memory JSON; mocked resolution, checkpoint, `gh`, and `git` seams; synthetic roots valid on Linux and Windows.
- **Isolation:** one value per `It`; `Should -Invoke ... -Scope It` on the call-count assertions.
- **Speed:** no disk or process I/O in the new suites.
- **Diagnostics:** `-Because` clauses include the value label or the deny reason.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation added; branch 1 remains checkpoint-only. |
| Input validation at boundaries | ✅ PASS | The fix is itself a stricter type check on checkpoint input. |
| Error handling remains explicit | ✅ PASS | Presence check precedes the value read; no catch added. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed; `config/` is not in the diff. |
| Gate strictness preserved | ✅ PASS | Merge gate and model-routing gate become stricter; base-branch gate stops applying an unintended requirement for non-boolean values. Deny strings unchanged. |

---

## Research Log

No external research was required. The review relied on the spec, the research document, rule files, the remediation plan, and the branch diff.

---

## Verdict

The code change is correct, minimal, and consistent with existing repository idioms, and it is supported by fail-before and pass-after evidence across the full value matrix with no coverage regression on the modified hooks and a full-suite repo-wide coverage figure of 93.53%. The findings are one Minor, two Nit, and one Info item; none requires remediation in this item. The branch is ready for PR authoring.
