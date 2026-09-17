# Code Review: Preimplementation Gate Worktree Selector (LACS) (#671)

---

**Review Date:** 2026-09-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
**Feature Folder Selection Rule:** Supplied by the caller. Matches the branch name suffix `-671` and is the only active folder with changed scoping docs.
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` (merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
**Head Branch:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671` (`03f4f305765e15745b9275f3a8fd42758f2c6873`)
**Review Type:** Initial review

---

## Executive Summary

The branch widens the issue #539 orchestration-bookkeeping staging exemption along one axis: the repository selector. A single `git -C <value>` is now accepted between `git` and `add`/`commit` when the value meets the eight lexical LACS conditions (L1–L8). The implementation adds one constant, one advanced function (`Test-ExemptOrchestrationSelector`, 57 lines), and a 9-line absorption step in `Test-ExemptOrchestrationSegmentToken`. It is applied byte-identically to four surface copies (433 lines each). The tests add 24 table-driven rows to each of the two command-exemption suites and a new SHA256 parity suite.

The reviewer inspected the full diff, re-derived the coverage and JUnit figures from `artifacts/pester/`, confirmed the hash parity and the diff confinement against the resolved merge base, and ran a read-only probe of `Test-ExemptOrchestrationStagingCommand`. The predicate logic is correct for every allow row and for 14 of the 17 deny rows. Three deny rows fail in both suites: two because of fixture defects inherited from the spec, and one because of a pre-existing fail-open in the caller's parameter binding. That fail-open is a gate bypass: the reviewer reproduced it for implementation paths, not only for the selector form.

**What changed:**
- `enforce-orchestration-preimplementation-gate-helpers.ps1` (four copies): new `$script:OrchestrationSelectorOptionName = '-C'`, an "Accepted widening" comment block, the new `Test-ExemptOrchestrationSelector`, and a prologue branch at lines 309–316 that validates and then strips `-C <value>` so that downstream parsing is unchanged.
- Command-exemption suites (Claude and Codex): two new Contexts with 7 allow and 17 deny rows each.
- New `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`: SHA256 identity and the 500-line cap across the four copies.

**Top 3 risks:**
1. The pre-existing empty-token fail-open. `git add "" -- src/foo.ps1` makes the exemption predicate return `True`, which lets implementation content past the preimplementation gate.
2. Six failing deny rows leave the L3 and L8 rejection branches untested. They also cause a coverage regression on the modified file.
3. The L3 "subcommand at index 3" condition is enforced partly by the unchanged line 319, which no test reaches after this change.

**PR readiness recommendation:** **Blocked** — the test stage fails in both suites, and the L8 criterion depends on closing a confirmed fail-open that the approved plan did not permit editing.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and 3 copies) | line 296 (`param(... [AllowEmptyCollection()][string[]] $Token)`); call site line 428 | CR-1: A segment containing an empty quoted token (`""`) fails parameter binding of `Test-ExemptOrchestrationSegmentToken`. The statement-terminating error skips the `if` at line 428, and `Test-ExemptOrchestrationStagingCommand` returns `True`. The defect is pre-existing (fail-before row 20). It makes the new L8 branch (lines 257–259) unreachable through the gate, and it allows implementation paths. | Add `[AllowEmptyString()]` to the `$Token` parameter of `Test-ExemptOrchestrationSegmentToken`. Also make `Test-ExemptOrchestrationStagingCommand` fail closed on any error, for example by wrapping the per-segment loop in `try { ... } catch { return $false }`. Add deny rows for `git add "" -- src/foo.ps1`, `git add -- src/foo.ts ""`, and the existing L8 row. Add an allow row for `git commit -m "" -- docs/features/active/x/spec.md` if an empty message is intended to be exempt. This needs a spec/plan amendment, because AC 11 (helpers diff confinement) currently forbids editing that line. | The module contract states "Every parse ambiguity answers false". A fail-open in an enforcement hook produces no visible failure. | Reviewer probe (`probe671.ps1`): `git add "" -- src/foo.ps1 => True (errors=1)`, `git add -- "" scripts/powershell/Sample.ps1 => True (errors=1)`, `git -C "" add -- docs/... => True (errors=1)`; `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` row 20; `evidence/other/follow-up-candidates.2026-09-14T01-00.md` item 3 |
| Blocker | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | deny Context rows `LACS L3a`, `LACS L3b` | CR-2: The fixtures `git -C C:/repo/wt` and `git -C C:/repo/wt -- docs/features/active/x/spec.md` contain no `add`/`commit`. The gate trigger does not classify them, so the gate returns `allow` without consulting the exemption, and the `deny` assertion fails. The spec table has the same defect. | Amend the spec table, then replace the fixtures with trigger-matching commands that reach helpers line 253. Candidates: L3a `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` (segment 1 has 3 tokens); L3b `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` (index 3 is dash-led). Before adoption, verify with a coverage run that line 253 is hit. | Two failing rows per suite block the test stage and leave the L3 rejection branch unexecuted. | `artifacts/pester/pester-junit.xml` (reviewer parse: 8 failures, including these 4); `evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md` |
| Blocker | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | lines 253, 254, 258, 259, 319 | CR-3: Line coverage of the modified helpers file regressed from 94.92% (112/118) to 92.72% (140/151). Changed lines 253–254 (L3) and 258–259 (L8) are unexecuted. Unchanged line 319 was covered at baseline and is now unexecuted, because every non-`add`/`commit` token at index 1 is routed through the selector predicate first. | After CR-1 and CR-2, add a trigger-matching row where an accepted selector is followed by another subcommand, for example `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` (deny). Re-run coverage and confirm the helpers file is at or above its baseline. | Modified files must not regress on coverage. | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: `.claude/hooks` sourcefile covered=140 missed=11, zero-hit `[180,253,254,258,259,299,319,348,354,406,423]`; `evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md` |
| Major | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | new Contexts | CR-4: `Test-ExemptOrchestrationSelector` is exercised only through the full gate. Conditions that the gate trigger or the caller's binding hides (L3, L8) therefore cannot be pinned at the unit level. | Add a small predicate-level Context that dot-sources the helpers file and calls `Test-ExemptOrchestrationSelector -Token @(...)` directly for each of L1–L8, asserting `$false`/`$true`. Keep the gate-level rows as integration guards. | Unit isolation per the general unit-test policy. Direct rows would have exposed the L3/L8 reachability gap before execution. | Diff inspection; no direct call to `Test-ExemptOrchestrationSelector` in any test file |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | line 252 | CR-5: L3 is implemented as `$Token.Count -lt 4 -or $Token[3].StartsWith('-')`. A non-dash token at index 3 that is not `add`/`commit` passes the predicate, and is rejected later at line 319. The behavior is correct, but the L3 condition is split across two functions, and the comment-based help implies the predicate alone enforces "the subcommand at index 3". | Either check `$Token[3] -ceq 'add' -or $Token[3] -ceq 'commit'` in the predicate, or state in the help text that subcommand identity is checked by the caller. Pin either choice with a test (see CR-3). | Keeps each LACS condition traceable to one location. | Reviewer probe: `git -C C:/x status -- docs/... => False (errors=0)` (rejected at line 319) |
| Minor | `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md` | tasks P0-T5, P3-T3, P3-T5, P3-T7, P4-T4, P5-T10, P6-T3, P6-T7, P6-T8, P7-T1 | CR-6: These tasks remain `- [ ]`, although the spec criteria delivered by P3-T7, P4-T4, P5-T10, and P6-T8 are checked in spec.md, and P0-T5 has an evidence file. | Reconcile the plan checkboxes with the delivered evidence during remediation. Leave tasks whose acceptance failed (P3-T3, P3-T5, P6-T3, P6-T7, P7-T1) unchecked. | Plan state should match the evidence. | `grep -n -- '- \[ \]' plan.2026-09-13T20-46.md` |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | lines 262–267 | CR-7: L4 accepts `^/` values. On Windows, `/repo/wt` is rooted but drive-relative, so git resolves it against the current drive. The spec explicitly accepts this form (L4). The content-class invariant is unaffected, because operands remain repo-relative. | No change required. Optionally note the drive-relative case in the comment-based help. | Documentation accuracy only. | spec.md L4 row; reviewer probe `git -C /repo/wt add -- docs/... => True` |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | line 248 | CR-8: The L2 repeated-selector test counts `-C` anywhere in the segment, including a commit message value (`-m -C`) or an operand after `--`. Such lines are denied. | No change required; this is fail-closed behavior. | Conservative and consistent with D3. | Reviewer probe: `git -C C:/x commit -m -C -- docs/... => False` |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | line 315 | CR-9: The `$Token` parameter is reassigned inside the function. The behavior is correct, but it hides the original token array for later readers. | Optionally assign to a local such as `$effectiveToken` and use that for the rest of the function. That would widen the diff within the function, so it is optional. | Readability. | Diff inspection |
| Info | `artifacts/pr_context.summary.txt` | Close candidates | CR-10: The PR-context tool lists `#INV-1`…`#INV-7`, `#SHA-256`, `#UTF-8`, `#516`, `#539`, and `#554` as author-asserted autoclose candidates. Only `#671` should close. | The PR body should use a closing keyword only for #671. Reference the other issues without closing keywords. | Prevents unintended issue closure. | `artifacts/pr_context.summary.txt` lines 38–51 |

Blocking findings: 3 (CR-1, CR-2, CR-3).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The change is confined as the spec requires. The reviewer's `git diff --stat 79fd5a95 HEAD` over the four gate files, the four modes files, the four `hook-command-invocation.ps1` copies, and `enforce-epic-merge-gate.ps1` produced no output.
- The four helpers copies are byte-identical (SHA256 `5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1`), and a new SHA256 parity test enforces this. The parity test closes the byte-order-mark and line-ending gap that the existing decoded-text Python check leaves open.
- The absorption strips the accepted selector and re-indexes the token array. As a result, the modelled option table, the `--` handling, and the operand loop are unchanged. Absolute operands still deny (the row "selector with an absolute pathspec operand" passes).
- The purity contract is preserved: no `Test-Path`, `Resolve-Path`, `Start-Process`, `Invoke-Expression`, `env:`, `git worktree`, or `Import-Module` in any copy (reviewer Grep).
- The accepted nested-subdirectory widening is documented in the source, with its measured exposure, following the gate file's precedent.

#### API and safety notes

- `Test-ExemptOrchestrationSelector` uses `[CmdletBinding()]`, `[OutputType([bool])]`, and a mandatory `[string[]]` parameter with `[AllowEmptyCollection()][AllowEmptyString()]`. Its own binding is therefore correct. The defect is in the caller's binding (CR-1).
- All comparisons of option tokens are case-sensitive (`-cne`/`-ceq`), consistent with the existing posture. `-match '^[A-Za-z]:/'` is case-insensitive, which is harmless for a character class that already covers both cases.
- `Test-` is an approved verb. PSScriptAnalyzer reports 0 findings on all seven files.

#### Error handling and logging

- Each rejection emits a distinct `Write-Debug` token (`PREIMPL_SELECTOR_*`), as the spec requires. The tokens are not asserted, which is correct.
- The chain from `Test-ExemptOrchestrationStagingCommand` to `Test-ExemptOrchestrationSegmentToken` does not handle binding errors (CR-1). The gate runs under the default `Continue` preference, so the error is written and execution proceeds to `return $true`.

---

## Test Quality Audit

The reviewer inspected the diff and the executor's evidence, and independently parsed `artifacts/pester/pester-junit.xml` (tests=4597, failures=8, errors=0, disabled=9) and `artifacts/pester/powershell-coverage.xml` (repo LINE 8970/9402 = 95.41%). The helpers hash in the coverage-comparison evidence matches the committed file, so the reports correspond to the reviewed code.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`: 24 new rows. 21 pass; L3a, L3b, and L8 fail.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`: the same 24 rows with identical labels and the same pass/fail pattern.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`: 2 nodes, both pass. It reads files only and creates no temporary file.
- `evidence/regression-testing/exemption-regression-guards.2026-09-14T00-20.md`: 45 D4 deny rows and 8 allow rows retained and passing in each suite; the D4 row 14b/14c/14d guards pass.
- `evidence/qa-gates/diff-additive-only-test-suites.2026-09-14T01-00.md`: numstat `54 0` and `55 0`; no assertion reversed.
- `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` and `pass-after-lacs-repro.2026-09-14T01-00.md`: executed 20-row captures. Rows 2, 3, and 9 flip to `True`; the rest are unchanged, including the row 20 fail-open.
- `evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md`: changed-line coverage 29/33; unexecuted lines identified with causes.
- `evidence/qa-gates/python-pushdown-contracts.2026-09-14T01-00.md`: 16 passed after a batch-budget state reset.

### Quality assessment prompts

- **Determinism:** Fixed string fixtures with no clock, RNG, or process. The failures reproduce identically across four runs.
- **Isolation:** Each row asserts one decision. The predicate is not isolated from the gate trigger (CR-4).
- **Speed:** In-memory only. No per-suite timing was recorded.
- **Diagnostics:** `-Because` text and descriptive labels identify the failing condition directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No process start, `Invoke-Expression`, or dynamic script construction added. |
| Input validation at boundaries | ❌ FAIL | Empty-token binding error fails open (CR-1); confirmed by probe. |
| Error handling remains explicit | ❌ FAIL | Unhandled statement-terminating error inside the allow-side predicate (CR-1). |
| Configuration / path handling is safe | ✅ PASS | The selector must be rooted, non-UNC, and free of dot segments, wildcards, and stray colons. Operands still must be repo-relative under the five exempt trees. The nested-subdirectory widening is accepted and recorded. |
| Diff confinement (gate, modes, shared parser untouched) | ✅ PASS | Reviewer `git diff --stat` produced no output for 13 protected paths. |
| Surface parity | ✅ PASS | Four identical SHA256 values (reviewer `sha256sum`). |

---

## Research Log

No external research was required. The reviewer relied on PowerShell parameter-binding behavior for mandatory `[string[]]` parameters with empty-string elements, and confirmed it empirically with the probe run (a binding error is emitted, and the calling statement is skipped under `Continue`).

---

## Verdict

The LACS implementation is small, pure, and correctly confined, and its allow path and most of its deny path behave as specified. The branch is not ready for merge. Six deny rows fail across the two suites. Coverage on the modified helpers file regressed. One of the failures is caused by a confirmed, pre-existing fail-open that also admits implementation paths through the preimplementation gate.

Remediation requires a spec and plan amendment in three parts:
- replace the L3a/L3b fixtures with trigger-matching commands;
- permit the one-line `[AllowEmptyString()]` fix plus a fail-closed guard, with regression rows;
- add a row that reaches line 319.

After the amendment, re-run the PowerShell loop to a single clean pass. Blocking findings: 3.
