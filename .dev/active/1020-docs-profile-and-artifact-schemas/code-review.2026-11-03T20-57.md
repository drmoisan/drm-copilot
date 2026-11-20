# Code Review: Documentation profile and artifact schemas (#1020)

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `5e535f7a6`)
**Head Branch:** `feature/docs-profile-and-artifact-schemas-1020-r2` (head `a3ae4c51d`)
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-11-03T20-22.md`)

---

## Executive Summary

The cycle commit `19643663a` changes four code files: `Invoke-DocsCommand.ps1` and its bundle mirror (ShouldProcess on `Write-DocsFileText` and `Write-DocsContextText`, inert suppression removed, help text updated), `Invoke-DocsCommand.Tests.ps1` (two `-WhatIf` tests and a header update), and `DocsSchema.Tests.ps1` (one mock emits its error with `-ErrorAction SilentlyContinue`). Commit `a3ae4c51d` only checks the final plan box. The reviewer inspected the full diff against the epic tip, re-ran the docs Pester suites (385 of 385), PSScriptAnalyzer and the formatter (0 findings, 0 differences over 23 files), the gate suites (52 of 52), and the push-down contract pytest (34 passed), and parsed the coverage artifact directly.

**What changed:**
`Write-DocsFileText` now declares `[CmdletBinding(SupportsShouldProcess = $true)]` and wraps `Directory.CreateDirectory` and the `FileStream` write in `if ($PSCmdlet.ShouldProcess($FullPath, "Write file ($Mode)"))`. `Write-DocsContextText` declares `SupportsShouldProcess = $true` and forwards unchanged. The bundle mirror is byte-identical.

**Top 3 risks:**
1. Full-tree Pester and the required CI checks are proven only by `windows-latest` CI, which has not yet run for a PR head (F2, F3; `awaiting_ci`).
2. The `-WhatIf` tests use a real path under the repository's `artifacts/` directory; if the gate regressed, a run would create that directory, and later runs would keep failing until it is removed (Nit below).
3. `Invoke-DocsCommand.ps1` coverage margin is now 2.33 points (87.33%); the uncovered lines remain the two seam bodies by design.

**PR readiness recommendation:** **Ready pending CI** - no Blocker or Major finding remains; F2 and F3 resolve at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/docs/Invoke-DocsCommand.ps1` | lines 236, 245-249, 326 | Prior Major finding F1 is resolved: both write functions declare `SupportsShouldProcess`, and the primitive gates the directory creation and write. The inert suppression on `Write-DocsContextText` is removed. | None. | `.claude/rules/powershell.md` line 30 is now met. | Source inspection; PSSA 0 findings; `whatif-gate-removal-check.2026-11-03T20-41.md` |
| Info | `.claude/lib/docs/Invoke-DocsCommand.ps1` | file | Coverage 87.33% (131 of 150); missed lines 207 and 209-223 (`Invoke-DocsProcess`, 16) and 246-248 (`Write-DocsFileText` guarded body, 3), within the P4-T4 budget of 20 and 6. | None. | Matches the executor's attribution. | `artifacts/pester/powershell-coverage.xml` (reviewer parse) |
| Nit | `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | lines 300-331 | The `-WhatIf` tests build their target under `<repository root>/artifacts/docs-whatif-never-created`. With the gate present nothing is created (verified: the directory does not exist after the reviewer run). If the gate regressed, the test would write a real file into the working tree before failing, and the leftover directory would make the third assertion fail on later runs until removed. | Optional: target a path under a root that cannot exist (for example a nonexistent top-level segment) or add an `AfterAll` that removes the directory only if it exists. Non-blocking. | The tests correctly detect a regression; this only affects cleanup after one. | Source inspection |
| Minor | `examples/docs/v1/*.example.json` | all seven files | Carried forward N1: `format_json --check` reports `would reformat`; no CI workflow, test, or rule enforces it. | Not adopted by the orchestrator in this cycle; no action required. | Unchanged from the prior review. | `code-review.2026-11-03T20-22.md` |
| Info | `tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1` | line 310 | Prior Nit N2 is resolved: the mock passes `-ErrorAction SilentlyContinue`; the reviewer run printed no `The value does not match` text, and the test still asserts `DOCS_SCHEMA_INVALID` with pointer `/name`. | None. | Clean output in a green run. | Reviewer Pester run output |
| Info | `docs/features/epics/documentation-estate-tooling/epic-status.md` | n/a | Present on the epic tip, absent on HEAD; HEAD never touched it. | None required. | Unchanged from the prior review. | `git diff --name-status` against the epic tip |

No Blocker or Major findings. No covered file is at or above 700 logical lines (maximum 465), so no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The gate is placed in the single write primitive, so every write path (the `WriteText` member and any direct caller) is covered by one check.
- `Write-DocsContextText` declares `SupportsShouldProcess` without its own `ShouldProcess` call; PowerShell sets `$WhatIfPreference`/`$ConfirmPreference` in its scope when `-WhatIf`/`-Confirm` is passed, and the primitive inherits them. The second new test proves the inherited-preference path through the real context member.
- `ConfirmImpact` stays at the default (Medium), below the default `$ConfirmPreference` (High), so `init -Write` does not prompt; the `init` dry-run, `-Write`, and `-Force` behavior is unchanged (`DocsProfileCommands.Tests.ps1` 22 of 22).
- The comment-based help no longer claims that no test executes the body; it states which path the tests exercise.

#### API and safety notes

- `FileMode.CreateNew` for `create` is retained inside the gate.
- The bundle mirror was re-synced by file copy; `cmp` reports identical.

#### Error handling and logging

- No catch block added; under `-WhatIf` the primitive returns with no output, which is the standard contract.

---

## Test Quality Audit

Reviewed: reviewer re-run of the 12 docs suites plus fixtures (385 of 385); gate suites 52 of 52; push-down contract pytest 34 passed; executor evidence for the cycle.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` - new `Describe 'Write-DocsFileText and the WriteText member under -WhatIf'` with two tests; no mock of the function under test.
- `evidence/regression-testing/whatif-gate-removal-check.2026-11-03T20-41.md` - with the gate replaced by a constant true, exactly the two new tests fail; reverted, confirmed by equal mirror digests.
- `evidence/regression-testing/isolation-shuffled-remediation.2026-11-03T20-51.md` - seeds 101, 202, 303, 112 of 112 each.
- `evidence/qa-gates/qa-pester-coverage.2026-11-03T20-49.md` - 3786 tests, 0 failures; per-function attribution.

### Quality assessment prompts

- **Determinism:** fixed paths; no clock, RNG, or process.
- **Isolation:** `$WhatIfPreference` is set inside the asserted scriptblock only.
- **Speed:** 385 tests in 23.4 s.
- **Diagnostics:** `-Because` texts name the gate.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No secret in the cycle diff. |
| No unsafe subprocess or command construction | ✅ PASS | The cycle does not touch `Invoke-DocsProcess`. |
| Input validation at boundaries | ✅ PASS | `Get-DocsContextFullPath` path check still precedes the forward. |
| Error handling remains explicit | ✅ PASS | No catch added. |
| Configuration / path handling is safe | ✅ PASS | Destructive writes are now ShouldProcess-gated (F1 resolved). |

---

## Research Log

No external research was required. Repository sources consulted: `.claude/rules/powershell.md`, `remediation-inputs.2026-11-03T20-22.md`, `remediation-plan.2026-11-03T20-22.md`, and the cycle evidence files.

---

## Verdict

The cycle resolves the prior Major finding and the Nit without regressions in format, lint, tests, coverage, mirror parity, or file size. The branch is ready for a pull request; the remaining items (F2 full-tree Pester, F3 CI-dependent criteria) resolve through `windows-latest` CI on the PR head.
