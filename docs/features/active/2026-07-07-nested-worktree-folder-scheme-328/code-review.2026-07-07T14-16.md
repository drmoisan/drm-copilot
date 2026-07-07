# Code Review: nested-worktree-folder-scheme (#328) — Re-Review (Remediation Cycle 1)

---

**Review Date:** 2026-07-07
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/`
**Feature Folder Selection Rule:** Folder suffix `-328` matches the issue number in the branch scope; it holds the primary changed scoping docs.
**Base Branch:** `main` (merge-base `3eda262ffbc3ab82e6eefed3e9a72ab4133b893c`)
**Head Branch:** `drm-copilot-wt-2026-07-07-11-50` @ `8768aeec5129eb9fe52bbdc4f16bf8350c8e2acf`
**Review Type:** Post-remediation re-review

---

## Executive Summary

This is a post-remediation re-review of Issue #328, which reorganizes worktree session creation from a flat sibling scheme to a nested `<repoName>-wt/<yyyy-MM-ddTHH-mm>` scheme across a PowerShell dev-tools script, its bundled template, and the TypeScript extension command builders, and adds empty grouping-directory cleanup to the removal command. The prior review (`code-review.2026-07-07T13-16.md` / `policy-audit.2026-07-07T13-16.md`) found no production-behavior defects; its only Blocking items were two PowerShell coverage-measurement gaps. This cycle re-reviews the remediation delta.

**What changed (this cycle, `f4bbfdf..8768aee`):** Four PowerShell-related files only — the script and bundled template each gained a behavior-preserving dot-source guard; the Pester test was converted to dot-source the whole script for valid coverage attribution and gained a seam test; and `pester.runsettings.psd1` added the changed script to `CodeCoverage.Path`. No TypeScript source changed. No production control flow changed: the guard triggers only when the file is dot-sourced (`$MyInvocation.InvocationName -eq '.'`), which never happens during normal script invocation, so worktree creation behaves exactly as before.

**Top 3 risks:**
1. Residual structurally-uncoverable surface in the PowerShell script (host-bound top-level body, ~21 lines). Mitigated: fully enumerated in a sanctioned exception dossier; refactor deferred by design (measurement-only cycle).
2. Toolchain-emitted branch coverage remains unavailable for PowerShell (Pester limitation, not feature-specific). Mitigated: per-branch enumeration dossier shows 100% coverable-outcome coverage.
3. The dot-source guard is a production-file change made for testability. Mitigated: it is inert during normal invocation and verified byte-identical between script and template.

**PR readiness recommendation:** **Go** — the two prior Blocking coverage findings are resolved with verified evidence; no new defects were introduced by the remediation.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev-tools/new-claude-worktree-session.ps1` | lines 233-238 | Dot-source guard added for test coverage attribution; inert during normal invocation. | Accept. Keep the rationale comment. | Enables valid Pester line attribution without changing production behavior. | Diff inspection; `grep -n InvocationName` shows guard at line 236 in both script and template |
| Info | `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | `BeforeAll` (line 3-9) | Test now dot-sources the whole script (`. $script:scriptPath`) instead of `Import-ScriptFunction` AST re-parse. | Accept. | Removes the root cause of the prior invalid 4.88% attribution; restores valid line coverage. | `evidence/qa-gates/2026-07-07T14-00-targeted-ps-coverage.xml` (file in JaCoCo denominator, `LINE covered=46 missed=29`) |
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` (+4 lines) | Changed script added to the coverage allow-list; no existing entry removed; no production `exclude` added. | Accept. | Puts the changed production file in the committed coverage denominator per the Coverage Exclusion Policy. | `git diff 3eda262..8768aee -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| Minor | `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | Integration Validation Describe | Two structural raw-text assertions (nine-function definition check, ordering check) remain. | Optional: consider replacing with behavioral wiring tests in a future change. | Brittle to refactoring, but an accepted pre-existing pattern for verifying script-body wiring not executable in-unit. | Prior audit Section 4B.2; unchanged this cycle |
| Info | `scripts/dev-tools/new-claude-worktree-session.ps1` | top-level body (lines 244-281) | Host-bound, seam-less orchestration body remains uncovered (~21 lines). | Future: extract into an injectable function per the Coverage Exclusion Policy's preferred remedy. | Raises genuinely-covered line coverage; deferred by design (this cycle prohibited production refactors). | `evidence/regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md` |

No Blocker or Major findings. Both prior Blocking findings (R1 line-coverage attribution, R2 branch-coverage metric) are resolved.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The remediation chose the minimal, behavior-preserving mechanism. The dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) lets the Pester suite resolve the functions from the original file — enabling correct line attribution — without executing the host-bound top-level body during tests. Normal invocation is unaffected because `InvocationName` is the script name, not `.`.
- The direct fix was preferred over the exception dossier: the test was switched from `Import-ScriptFunction` (AST re-parse, which restarted line numbers and defeated attribution) to a whole-file dot-source, and the file was added to the committed `CodeCoverage.Path`. The dossiers were used only for the genuinely uncoverable remainder.
- Lockstep parity was maintained: the guard was added identically to the bundled template, and `git diff --no-index` confirms the two files are byte-identical.

#### API and safety notes

- No public API surface changed this cycle. The `New-WorktreeParentDirectory` (ShouldProcess + injectable seam) and `Get-WorktreeGroupDirectory` functions from the feature cycle are unchanged.
- Advanced-function conventions, parameter validation, and approved verbs remain satisfied; PSScriptAnalyzer reports no findings.

#### Error handling and logging

- Error handling is unchanged: the try/catch + `exit 1` precondition flow and the `ShouldProcess` gate on directory creation remain. The guard's early `return` is reachable only under dot-sourcing and does not intercept any production error path.

### TypeScript implementation audit

No TypeScript source changed between the prior head and the current head (`git diff --name-only f4bbfdf..8768aee` lists no `.ts` files). The prior review's TypeScript assessment carries forward: pure command builders remain side-effect free; discriminated-union cleanup decision logic is well-typed; no `any` and no suppression comments; coverage above thresholds on all changed files.

---

## Test Quality Audit

The remediation improved test quality by restoring valid coverage attribution and adding a seam test, without weakening any assertion or skipping any test.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` — dot-sources the whole script for valid attribution; 33 tests over all nine functions plus structural and parity groups; new `Invoke-GitWorktreeAdd` seam test. Green (33 pass, 2 platform-gated skips).
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/qa-gates/2026-07-07T14-00-targeted-ps-coverage.xml` (+ `.md`) — valid per-file line coverage (46/75 whole-file; 46/46 = 100% coverable surface); file confirmed present in the JaCoCo denominator; zero `type="BRANCH"` counters.
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/qa-gates/2026-07-07T14-00-ps-coverage-delta.md` — repo-wide 93.67% line (no regression); threshold analysis.
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md` — per-command enumeration proving the uncovered remainder is structurally uncoverable.
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md` — per-branch enumeration (8 conditionals, 16 outcomes, 14/14 coverable exercised).
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/qa-gates/2026-07-07T14-00-final-poshqc-{format,analyze,test}.md` — final green toolchain pass (EXIT 0; 1073 tests).

### Quality assessment prompts

- **Determinism:** Injected fixed date fixtures; git/filesystem behind injectable seams; the dot-source guard prevents real `git` in the top-level body from running during tests.
- **Isolation:** One behavior per test; the new seam test targets a single function.
- **Speed:** Changed PS suite ~1 s; full suite EXIT 0.
- **Diagnostics:** Exact-literal `Should -Be` assertions; the coverage dossiers make the uncoverable surface auditable line by line.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No secrets introduced; diff is coverage-plumbing plus an inert guard. |
| No unsafe subprocess or command construction | PASS | Git access remains behind the `$InvokeGit` seam; the top-level `git rev-parse` is pre-existing and unchanged. |
| Input validation at boundaries | PASS | Parameter validation and precondition checks unchanged. |
| Error handling remains explicit | PASS | try/catch + `exit 1` and `ShouldProcess` gates unchanged; guard is inert during normal invocation. |
| Configuration / path handling is safe | PASS | `pester.runsettings.psd1` change is an additive allow-list entry; no production path scheme altered this cycle. |

---

## Research Log

No external research was required. All evidence is derived from the branch diff, the committed remediation evidence tree, the coverage artifacts, and the repository policy rules. The cited precedent (`docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md`) was confirmed to exist.

---

## Verdict

The remediation resolves both prior Blocking findings with verified evidence and introduces no new defects. The PowerShell changed file now has valid line-coverage attribution and is in the committed coverage denominator; its coverable surface is fully covered, and the structurally-uncoverable remainder plus the toolchain's absent branch metric are discharged by two sanctioned, explicitly-authorized exception dossiers with complete enumeration. The dot-source guard is behavior-preserving and maintained in lockstep with the bundled template. The change is ready for normal PR flow. Recommendation: **Go**.
