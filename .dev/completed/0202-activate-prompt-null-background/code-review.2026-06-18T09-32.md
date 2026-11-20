# Code Review: activate-prompt-null-background (#202)

**Review Date:** 2026-06-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-18-activate-prompt-null-background-202`
**Feature Folder Selection Rule:** Selected by issue-number suffix `-202` matching the branch's autoclose issue #202; it is the only active folder with material scoping-doc changes in the diff.
**Base Branch:** `main` (`origin/main` @ `db3d528ea9c8fb87e9ec21a4d96e4c263d347651`)
**Head Branch:** `fix/activate-prompt-null-background` @ `34176ed1ed82c1353443667dbcb10bff60541deb`
**Review Type:** Initial review

---

## Executive Summary

The branch makes `Get-VenvAwarePrompt -BackgroundColor` null-tolerant so the installed `global:prompt` shim does not throw in hosts that report a null console background (for example the VS Code Pester test adapter). The change is small and localized: the parameter is relaxed from mandatory non-nullable `[System.ConsoleColor]` to optional `[AllowNull()] [System.Nullable[System.ConsoleColor]]`, and a null guard renders the prompt uncolored instead of binding null into the non-nullable dark-background predicate. A deterministic regression test is added that supplies `$null` explicitly, removing the prior ambient-host dependence.

**What changed:**
- `scripts/dev-tools/activate.ps1` (+18/-4): parameter contract widened; null guard added around `Test-IsDarkBackground`; comment-help updated.
- `tests/scripts/dev-tools/activate.Tests.ps1` (+12/-0): one new `It` asserting the null-background path returns the uncolored prompt.
- Three feature-scoping docs added (spec, issue, plan).

No production behavior changes when a valid background color is supplied: dark -> green-wrapped, non-dark -> plain (verified by retained parameterized tests). `Test-IsDarkBackground` and `Get-ColorizedPrompt` are unchanged.

**Top 3 risks:**
1. A host reporting a non-null but invalid background (for example integer `-1`) is not handled; the spec explicitly scopes this out and documents it as a follow-up. Low risk given the observed defect is null only.
2. Repo coverage configuration (`pester.runsettings.psd1`) does not include `activate.ps1`, so the standing coverage artifact does not exercise this file; coverage was verified by a scoped run during review. Configuration follow-up, not a code defect.
3. CI required-checks green on the PR head (AC6) is unverified because no PR exists yet for this branch.

**PR readiness recommendation:** **Go** — The change is minimal, correct, deterministic, and passes the full PowerShell toolchain with high coverage on the changed file. The only outstanding item (CI green on PR head) is a downstream gate, not a code defect.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` | The standing coverage scope excludes `scripts/dev-tools/activate.ps1`, so the repo coverage artifact provides no coverage for the changed file. | Consider widening coverage scope to include `scripts/dev-tools/**` in a follow-up so standing CI coverage exercises this file. | The change is verified here by a scoped run, but the standing gate will not track regressions on this file. | `pester.runsettings.psd1` lines for `CodeCoverage.Path`; `artifacts/pester/powershell-coverage.xml` contains only `.claude/hooks` classes. |
| Info | `scripts/dev-tools/activate.ps1` | `Get-VenvAwarePrompt` null guard | Non-null but invalid background values (e.g. `-1`) are not normalized. | None required for this fix; tracked as spec follow-up. | Out of scope for the observed null defect; documented in spec Risks & Mitigations. | `spec.md` Risks & Mitigations. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is the minimal correct change: it widens one parameter and adds one guard, preserving the existing decision pipeline (`Test-IsDarkBackground` -> `Get-ColorizedPrompt`) untouched.
- The null path is implemented as an explicit `if ($null -ne $BackgroundColor) { ... } else { $false }` expression rather than swallowing an exception, so the failure mode is now defined behavior rather than a caught throw.
- The parameter contract uses `[System.Nullable[System.ConsoleColor]]` with `[AllowNull()]`, which is the idiomatic way to accept null for a value-type parameter in PowerShell, and matches the spec design.

#### API and safety notes

- The parameter change from mandatory non-nullable to optional nullable is a widening change: existing callers that pass a valid `[System.ConsoleColor]` continue to bind and behave identically. No in-repo caller is broken.
- `[CmdletBinding()]`, `[OutputType([string])]`, and `-CurrentPath`'s `[ValidateNotNullOrEmpty()]` are retained. Approved verb `Get` is used.

#### Error handling and logging

- The change converts a parameter-bind exception into a deterministic uncolored render. No logging is needed for this pure decision function; failing fast is not appropriate here because a null background is a legitimate host condition, not an invariant violation.

---

## Test Quality Audit

The added test is deterministic and isolated. It supplies `-BackgroundColor $null` explicitly, which removes the ambient-host dependence that the spec identifies as the root cause of the original masked defect (the prior suite read the live host background, which is non-null on CI/terminal and null only in the adapter host). The assertion checks the exact uncolored prompt string, so a regression to colored output or a re-introduced throw would fail clearly.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/activate.Tests.ps1` — Adds the null-background `It`; retains parameterized dark/non-dark coverage for `Test-IsDarkBackground` and the Black -> green-wrapped case for `Get-VenvAwarePrompt`. 53/53 tests pass.
- `docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml` — JaCoCo coverage for `scripts/dev-tools/activate.ps1`: 98.21% commands, 98.1% lines, all changed lines covered (generated during this review).

### Quality assessment prompts

- **Determinism:** The new test passes `$null` directly; no clock, RNG, network, or ambient host dependence.
- **Isolation:** Each `It` targets a single behavior; the null case is independent of dark/light cases.
- **Speed:** Full suite 0.985s for 53 tests.
- **Diagnostics:** `Should -Be` on the prompt string yields explicit expected-vs-actual output on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff contains no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No `Invoke-Expression` or external command construction in the change. |
| Input validation at boundaries | PASS | `-BackgroundColor` now explicitly accepts null via `[AllowNull()]`; `-CurrentPath` retains `[ValidateNotNullOrEmpty()]`. |
| Error handling remains explicit | PASS | Null handled by explicit branch, not a swallowed exception. |
| Configuration / path handling is safe | PASS | No path or config handling changed. |

---

## Research Log

No external research was required. The change is fully specified by `spec.md` and verifiable against repository policy and the local PowerShell toolchain.

---

## Verdict

The change is ready for normal PR flow. It is a minimal, correct, deterministic null-tolerance fix with high coverage on the changed production file and a clean PowerShell toolchain pass (format, analyze, test). The two recorded findings are Info-level: a standing coverage-scope configuration limitation (compensated during review) and an explicitly out-of-scope non-null-invalid-value case documented as a spec follow-up. The only readiness item outside the code is confirmation of green CI on the PR head, which is a downstream gate. Recommendation: **Go**.
