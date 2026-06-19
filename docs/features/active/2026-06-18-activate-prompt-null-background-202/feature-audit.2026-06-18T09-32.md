# Feature Audit: activate-prompt-null-background (#202)

**Audit Date:** 2026-06-18
**Feature Folder:** `docs/features/active/2026-06-18-activate-prompt-null-background-202`
**Base Branch:** `main`
**Head Branch:** `fix/activate-prompt-null-background`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` @ `db3d528ea9c8fb87e9ec21a4d96e4c263d347651`)
- **Head branch/commit:** `fix/activate-prompt-null-background` @ `34176ed1ed82c1353443667dbcb10bff60541deb`
- **Merge base:** `db3d528ea9c8fb87e9ec21a4d96e4c263d347651`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml`
  - Additional evidence: `git diff db3d528..34176ed`; Pester/PSScriptAnalyzer/Invoke-Formatter output captured during review.
- **Feature folder used:** `docs/features/active/2026-06-18-activate-prompt-null-background-202`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`. Per the work-mode contract, `full-bug` resolves the AC source to `spec.md` only.
- **Scope note:** The audit scope is the full feature-vs-base diff (`db3d528..34176ed`), which contains exactly one production PowerShell file, one PowerShell test file, and three feature-scoping docs. No caller narrowing was accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-06-18-activate-prompt-null-background-202/spec.md` — only source (work mode `full-bug`)

### Acceptance criteria

1. AC1: `Get-VenvAwarePrompt -BackgroundColor $null` returns the uncolored prompt and does not throw.
2. AC2: A valid background color is unchanged in behavior (dark -> green-wrapped, light/non-dark -> plain).
3. AC3: A deterministic regression test for the null-background case exists and passes without depending on the ambient host.
4. AC4: `tests/scripts/dev-tools/activate.Tests.ps1` passes in full (no failures).
5. AC5: Full PowerShell toolchain passes (format -> analyze -> test) with zero new findings.
6. AC6: CI required checks are green on the PR head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `Get-VenvAwarePrompt -BackgroundColor $null` returns uncolored prompt, no throw | PASS | New `It` passes asserting `Should -Be '(mix-calculator)> '`; null guard at `activate.ps1` lines 301-306 renders uncolored. 53/53 tests pass. | `Invoke-Pester` on `tests/scripts/dev-tools/activate.Tests.ps1` | Null path (else `$false`, line 305) is covered. |
| 2 | Valid background unchanged (dark -> green, non-dark -> plain) | PASS | Parameter change is a widening; `Test-IsDarkBackground` and `Get-ColorizedPrompt` unchanged in diff. Retained tests cover Black -> green-wrapped and non-dark -> plain; `Test-IsDarkBackground` parameterized over all dark/non-dark colors all pass. | `git diff db3d528..34176ed -- scripts/dev-tools/activate.ps1`; `Invoke-Pester` | No behavior change for valid colors confirmed by diff inspection plus passing tests. |
| 3 | Deterministic null-background regression test exists, host-independent | PASS | The added `It` supplies `$null` explicitly (no ambient host read), with a comment documenting Test Explorer host parity. | `git diff db3d528..34176ed -- tests/scripts/dev-tools/activate.Tests.ps1` | Removes the ambient-host determinism violation noted in spec Root Cause Analysis. |
| 4 | `activate.Tests.ps1` passes in full | PASS | 53 passed, 0 failed, 0 skipped. | `Invoke-Pester -Configuration <activate suite>` | Execution 0.985s. |
| 5 | Full PowerShell toolchain passes (format -> analyze -> test), zero new findings | PASS | FORMAT_CLEAN (Invoke-Formatter, no diff), ANALYZE_CLEAN (PSScriptAnalyzer with repo `pssa.settings.psd1`, zero findings), 53/53 tests pass. | `Invoke-Formatter`; `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-Pester` | All stages clean in a single pass. |
| 6 | CI required checks green on PR head | UNVERIFIED | No PR exists for this branch (PR digests: none; CI status HEAD: not available in PR context). | n/a | Cannot be verified locally; downstream orchestrator CI gate must confirm. Not a code defect. |

---

## Summary

**Overall Feature Readiness:** PASS (pending downstream CI confirmation for AC6)

**Criteria summary:**
- **PASS:** 5 criteria (AC1-AC5)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC6)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC6 (CI green on PR head) is UNVERIFIED because no PR exists yet for this branch. This is a downstream gate, not a local defect; it does not require remediation.

**Recommended follow-up verification steps:**

1. Open the PR for `fix/activate-prompt-null-background` and confirm required CI checks are green on head `34176ed` to satisfy AC6.
2. Optionally widen `pester.runsettings.psd1` coverage scope to include `scripts/dev-tools/**` so the standing coverage gate tracks `activate.ps1`.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, AC1-AC5 are evaluated PASS and are checked off in the authoritative source file `spec.md`. AC6 is UNVERIFIED and remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-06-18-activate-prompt-null-background-202/spec.md`
- Total AC items: 6
- Checked off (delivered): 5 (AC1-AC5)
- Remaining (unchecked): 1
- Items remaining: AC6: CI required checks are green on the PR head.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 6 | 5 | 1 | Checkbox-backed; AC6 left unchecked pending downstream CI on the PR head. |
