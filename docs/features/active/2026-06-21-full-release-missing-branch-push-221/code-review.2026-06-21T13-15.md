# Code Review: full-release-missing-branch-push (Issue #221)

**Review Date:** 2026-06-21
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-06-21-full-release-missing-branch-push-221`
**Feature Folder Selection Rule:** Folder suffix `-221` matches the canonical issue number #221 and the supplied active feature folder.
**Base Branch:** `main` (merge-base `d33687885f1a113a4290d3ab798fc0c0e2e2b379`)
**Head Branch:** `drm-copilot-wt-2026-06-21-12-02` (commit `6f24a420e09827c15ca9e8b1db8b95f3d94cbbb3`)
**Review Type:** Initial review

---

## Executive Summary

This change fixes a release-automation defect in `scripts/dev-tools/Invoke-FullRelease.ps1`. Previously, `Invoke-FullReleaseGuarded` committed the bumped manifests on a local release branch and then called `gh pr create --head <branch>` without ever publishing the branch to `origin`. In non-interactive mode with an explicit `--head`, `gh pr create` does not push the branch, so GitHub reported blank head/base SHAs and "No commits between main and release/...". The fix inserts a `git push -u origin <branch>` step (via the existing `Invoke-GitExe` seam) between the commit step and PR creation, with non-zero-exit handling that emits a `Write-StderrLine` diagnostic and returns 1.

**What changed:**
- `scripts/dev-tools/Invoke-FullRelease.ps1`: +9 net lines. Added the push step (lines 248-252) and renumbered the PR step to Step 6; updated the `.DESCRIPTION` comment block.
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`: +32 lines. Added a push-failure negative-path test and strengthened the success-path test to assert the push precedes `gh pr create`.

The implementation is minimal, mirrors the established Step 4 add/commit failure-handling pattern, and preserves the wrapper-seam isolation boundary. Toolchain evidence (format, analyze, test) is clean with 319 tests passing.

**Top 3 risks:**
1. Branch coverage cannot be measured as a distinct counter under the Pester toolchain; the >= 75% branch threshold is supported only by instruction coverage (89.22%) and explicit coverage of both decision arms. This is a measurement limitation, not an observed defect.
2. The new push step uses `git push -u`, which sets upstream tracking; behavior on a pre-existing remote branch with diverged history is not exercised by tests (the production seam delegates this to `git`, and the failure path is covered).
3. The success-path ordering assertion relies on a `$script:`-counter snapshot of call counts rather than a strict interleaved timeline; it is correct for the current linear flow but is an indirect ordering check (Minor, see findings).

**PR readiness recommendation:** **Go** — The change is correct, isolated, fully toolchain-verified, and covered on both decision arms. No blocking or major findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev-tools/Invoke-FullRelease.ps1` | lines 248-252 | Push step correctly reuses the `Invoke-GitExe` seam and matches the Step 4 failure-handling contract (diagnostic + `return 1`). | None. | Consistent error handling and seam isolation reduce maintenance risk. | Diff; `evidence/qa-gates/poshqc-analyze.2026-06-21T12-06.md` (0 diagnostics) |
| Minor | `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` | success-path ordering assertion (~lines 96-110) | Push-before-PR ordering is asserted indirectly via `$script:ghInvokedAfterGitCount` equal to the total git-call count, rather than via an explicit interleaved call sequence. Correct for the current linear flow but coupled to the count of git calls. | Optional: assert the push args appear in the git-call list at an index lower than the gh-call point using a shared monotonic sequence counter for both seams. | An indirect ordering check can mask a future reordering if additional git calls are added after the push. Current behavior is correctly verified. | Diff; `evidence/qa-gates/poshqc-test.2026-06-21T12-06.md` |
| Info | `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` | new failure-path test | Negative-path test asserts return 1, the `Failed to push release branch` diagnostic, and `Invoke-GhExe` invoked 0 times. | None. | Confirms fail-fast behavior and that PR creation is short-circuited on push failure. | `evidence/regression-testing/push-failure-fail-before.2026-06-21T12-06.md` (fail-before), `evidence/qa-gates/poshqc-test.2026-06-21T12-06.md` (pass-after) |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is the smallest correct change: one push step inserted at the right point in the sequence, reusing the existing `Invoke-GitExe` wrapper rather than calling `git` directly. This preserves the repository's wrapper-seam isolation policy and keeps the function testable without live executables.
- Failure handling is consistent with the immediately preceding Step 4 (`git add` / `git commit`): non-zero `ExitCode` produces a specific `Write-StderrLine` diagnostic that names the branch and the exit code, then returns 1. This matches the documented return-code contract (1 on failed git seam).
- The `.DESCRIPTION` comment block was updated to document the new push step and renumber the PR step, satisfying the spec's "docs updated to match new behavior" criterion.

#### API and safety notes

- No public parameter surface change; the return-code contract is preserved (2 on missing confirmation, 1 on failure paths, npm exit on bump failure, 0 on success).
- The branch-name value flows from the existing release-branch logic into `git push -u origin $branchName`; it is not derived from untrusted external input. Arguments are passed as a discrete array to the seam, avoiding string-based command construction.
- No global or script-scoped mutable production state introduced. The `$script:` variables added are confined to the test file's capture infrastructure.

#### Error handling and logging

- Fail-fast and explicit: the push failure short-circuits before `gh pr create`, preventing the original blank-SHA failure mode and avoiding a partially-completed release attempt. The diagnostic is actionable (branch name + exit code). No broad catch-all is used.

---

## Test Quality Audit

The change is accompanied by a fail-before/pass-after negative-path test and an updated positive-path ordering test. Coverage, regression, and toolchain evidence are present in the feature folder. No end-to-end live-release test exists, which is consistent with the spec's explicit non-goal of live git/gh/npm execution.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` — Adds the push-failure test and the success-path ordering assertion. Both target observable behavior (return code, diagnostic, gh-not-invoked, ordering). Mocks only the three external wrapper seams.
- `evidence/regression-testing/push-failure-fail-before.2026-06-21T12-06.md` — Documents the `[expect-fail]` state: before the production fix the new test fails because control flows directly to `gh pr create` (the mock throws). Confirms the test genuinely exercises the missing behavior.
- `evidence/qa-gates/poshqc-test.2026-06-21T12-06.md` — Post-change full suite: 319 tests, 0 failures; per-file coverage 92.11% line, 89.22% instruction.
- `evidence/qa-gates/coverage-delta.2026-06-21T12-06.md` — Baseline 91.67% -> post-change 92.11% line coverage; 0 missed instructions on the inserted step; both decision arms covered.
- `evidence/qa-gates/poshqc-format.2026-06-21T12-06.md`, `evidence/qa-gates/poshqc-analyze.2026-06-21T12-06.md` — Format clean (no churn); analyze 0 diagnostics.

### Quality assessment prompts

- **Determinism:** All external executables are mocked behind wrapper seams; no network, clock, or RNG dependency. Deterministic.
- **Isolation:** Each test targets a single behavior; the new test isolates the push-failure arm.
- **Speed:** Pure in-process Pester; recorded full-suite run completed without slow-test flags.
- **Diagnostics:** Assertions are specific (`Should -Match` on the diagnostic, `Should -Invoke -Times 0 -Exactly` on the gh seam), producing clear failure messages.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no credentials, tokens, or secrets added. |
| No unsafe subprocess or command construction | PASS | Push invoked via `Invoke-GitExe -GitArgs @(...)` array; no string interpolation into a shell command. |
| Input validation at boundaries | PASS | Branch name originates from internal release-branch logic, not user input; passed as a discrete argument array. |
| Error handling remains explicit | PASS | Non-zero push exit emits a specific diagnostic and returns 1; no silent failure. |
| Configuration / path handling is safe | N/A | No configuration or filesystem path handling was added by this change. |

---

## Research Log

No external research was required. The fix follows the in-repo pattern established by the companion `Invoke-ReleaseTagPush.ps1` (which pushes via the `Invoke-GitExe` seam) and the repository PowerShell wrapper-seam and mocking policies in `.claude/rules/powershell.md`.

---

## Verdict

The change is correct, minimal, and consistent with repository design and test policy. It fixes the documented release-PR failure by publishing the release branch before `gh pr create`, with explicit fail-fast handling and full coverage of both decision arms. Toolchain gates are clean (format, analyze, test) and line coverage on the changed file increased to 92.11%. The single Minor finding (indirect ordering assertion in the success-path test) does not block merge; it is an optional test-robustness improvement. This change is ready for normal PR flow.
