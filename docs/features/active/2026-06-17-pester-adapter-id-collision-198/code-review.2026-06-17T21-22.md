# Code Review: pester-adapter-id-collision (Issue #198)

**Review Date:** 2026-06-17
**Reviewer:** feature-review agent (Claude Opus 4.8)
**Feature Folder:** `docs/features/active/2026-06-17-pester-adapter-id-collision-198`
**Feature Folder Selection Rule:** Folder suffix `-198` matches the issue number in the branch name `fix/pester-adapter-id-collision-198`; it is the only active folder with material scoping-doc changes in this diff.
**Base Branch:** `main` (merge-base `fb05bbea85d5efcf7f2f4d5b311ced644c607d9d`)
**Head Branch:** `fix/pester-adapter-id-collision-198` (`9eb40c16c355ecd9f50b0e6ca5501956d1037dd4`)
**Review Type:** Initial review

---

## Executive Summary

This change resolves issue #198, in which the VS Code `pspester.pester-test` Test Explorer adapter folds discovered test IDs to uppercase during static discovery, causing sibling Describe/Context/It names — and `-ForEach`/`-TestCases` expansions — that differ only by letter case to collide to a single adapter ID and be dropped or misreported. `Invoke-Pester` does not fold case, so the engine reports green and hides the defect.

The change is test-only and contains two parts. First, `Invoke-FullRelease.Tests.ps1` merges the two confirmation-token case-sensitivity `It` blocks (`"YES"` and `"Yes"`) into one `-ForEach` block carrying a non-case `CaseLabel` (`uppercase`/`titlecase`) included in the `It` name, so the uppercased adapter IDs differ (`...(UPPERCASE)...` vs `...(TITLECASE)...`). Both exit-code-2 assertions are preserved. Second, a new regression guard `test-name-uniqueness.Tests.ps1` AST-parses every `*.Tests.ps1` under `tests/`, mirrors the adapter's uppercase ID-folding rules, and asserts that no two sibling test names — and no two literal `-ForEach`/`-TestCases` expansions — collide case-insensitively.

**What changed:**
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (+10/-16): disambiguation via a `-ForEach` block with a `CaseLabel` discriminator.
- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` (+495, NEW): AST-based collision guard with 5 tests (2 positive, 2 negative, 1 repository suite scan) and 6 helper functions sharing a single detection path (`Get-AdapterIdCollision`).
- No production code changed.

**Top 3 risks:**
1. The guard only inspects literal `-ForEach`/`-TestCases` arrays of literal hashtables; non-literal data (variable references, function calls) is skipped, not failed. This is an intentional, documented limitation, but a future collision introduced via a non-literal data set would not be caught.
2. The guard mirrors the adapter's ID-folding heuristic (uppercase name + appended `KEY=VALUE` segments). If a future adapter version changes its ID scheme, the guard's discriminator computation could drift from the real adapter behavior.
3. AC6 (CI required checks green on the PR head) is unverified pending PR creation; this is expected for a pre-PR review and is outside the local diff scope.

**PR readiness recommendation:** **Go** — The change is test-only, the PowerShell toolchain passes clean, the regression guard is well-structured and deterministic, and no blocking or major findings were identified. The documented non-literal limitation is acceptable and matches the spec's stated scope.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` | `ConvertTo-LiteralDataRow` / `Get-LiteralHashtableElement` (lines 116-216) | Non-literal `-ForEach`/`-TestCases` arguments are skipped rather than detected, so a case collision introduced via a variable-bound data set would not be caught. | Keep as the documented limitation; consider a follow-up note if non-literal `-ForEach` data becomes common in the suite. | The guard's value is scoped to the literal pattern that caused #198; the limitation is explicitly tested ("skips a non-literal -ForEach argument") and documented in spec Risks & Mitigations. | spec.md Risks & Mitigations; test at lines 456-471 |
| Info | `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` | `Get-AdapterIdCollision` parent-scope resolution (lines 367-377) | Parent scope keys use `GetHashCode().ToString()` on the AST node. This is correct within a single parse but relies on AST node identity, not a structural path. | No change required; AST node identity is stable within one `ParseInput` call, which is the only context used. | Worth noting for maintainers, but not a defect: scopes are only compared within one file's single parse. | Inspected lines 367-392 |
| Info | `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` | Suite-scan `It` (lines 474-493) | The repository suite-scan test reads every `*.Tests.ps1` under `tests/`, so the guard's runtime grows with the suite size. | Acceptable; AST parsing is fast and the qa-gate shows the full scan completing within a normal Pester run. | Determinism and speed are preserved (no external I/O); only a forward-looking scale note. | qa-gate.md (294/0/2 within normal run) |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The detection logic is consolidated into a single shared path (`Get-AdapterIdCollision`) exercised by both in-memory fixtures and the repository-wide scan, so the proven behavior and the enforced invariant cannot diverge.
- The `-ForEach` disambiguation in `Invoke-FullRelease.Tests.ps1` is the minimal correct fix: it preserves both confirmation-token assertions while making the uppercased adapter IDs distinct via a non-case `CaseLabel` that is included in the `It` name.
- Helper decomposition is clean and each helper carries comment-based help: literal extraction (`Get-LiteralArgumentValue`), hashtable-row conversion (`ConvertTo-LiteralHashtableRow`), array-shape handling (`Get-LiteralHashtableElement`), data-row assembly (`ConvertTo-LiteralDataRow`), and discriminator computation (`Get-BlockDiscriminator`).
- The `tests/` root is resolved by walking up from `$PSScriptRoot`, not from CWD, which preserves Terminal/Test Explorer parity — directly relevant to the bug being fixed.

#### API and safety notes

- All helper functions use mandatory, typed parameters; `[AllowNull()]` is applied where a null AST is a valid input. Approved verbs are used throughout (Get, ConvertTo).
- Invariant-culture uppercasing (`CultureInfo.InvariantCulture.TextInfo.ToUpper`) is used for folding, avoiding locale-dependent case behavior — a correct choice for matching the adapter's deterministic folding.
- No `Invoke-Expression`, no plaintext secrets, no hard-coded absolute paths. Only `$script:TestsRoot` is script-scoped, which is required to share the resolved root from `BeforeAll` into the `It` blocks.

#### Error handling and logging

- The `tests/` root resolution throws a clear, specific message when the root cannot be found (fail-fast).
- Non-literal data is handled by returning `$null` and skipping, which is the documented intent rather than a silent error; the skip path is explicitly tested.
- Collision messages name the source label and the folded discriminator, and the suite-scan assertion uses `-Because ($allCollisions -join "`n")` so a failure prints every offending file and name.

---

## Test Quality Audit

The verification evidence is the feature-folder qa-gate plus direct inspection of the two changed files. The qa-gate records a clean format -> analyze -> test loop and a passing new guard file.

### Reviewed test and QA artifacts

- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` — 5 tests covering positive collision detection (sibling `It`, `-ForEach` data-value), negative cases (disambiguated `-ForEach`, non-literal skip), and the repository-wide invariant. Deterministic, no external dependencies.
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` — the disambiguated case-sensitivity `-ForEach` block; mocks only the wrapper seams (`Invoke-NpmExe`, `Invoke-PublishScript`, `Invoke-GitExe`, `Write-StderrLine`), consistent with the wrapper-seam mocking rule.
- `docs/features/active/2026-06-17-pester-adapter-id-collision-198/evidence/qa-gates/2026-06-18T01-11/qa-gate.md` — format EXIT 0, analyze EXIT 0 (0 findings), Pester 294/0/2 on scan folders, guard 5/5, file-size 495 lines (< 500).
- `artifacts/pester/powershell-coverage.xml` — repo-wide PowerShell production line coverage 96.8% (275/284).

### Quality assessment prompts

- **Determinism:** No randomness, wall-clock reads, network, or temporary files. AST parsing and file reads only. `tests/` root resolved from `$PSScriptRoot`.
- **Isolation:** Each `It` targets one behavior; fixtures are self-contained in-memory strings.
- **Speed:** AST parsing of in-memory strings and file content; the full scan-folder suite completes within a normal Pester run (qa-gate).
- **Diagnostics:** The suite-scan assertion prints every colliding file and discriminator on failure; fixture assertions match on the expected folded discriminator substring.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Inspected both files; no credentials, tokens, or secrets. |
| No unsafe subprocess or command construction | ✅ PASS | No external process invocation; AST parsing and file reads only. No `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Mandatory/typed parameters; `tests/` root resolution throws when unresolved; non-literal data returns `$null` and is skipped. |
| Error handling remains explicit | ✅ PASS | Fail-fast `throw` on unresolved root; explicit `$null` returns for non-literal shapes; no broad catch-all. |
| Configuration / path handling is safe | ✅ PASS | Paths resolved from `$PSScriptRoot` (CWD-independent); no hard-coded absolute paths. |

---

## Research Log

No external research was required. The review is grounded in the branch diff, the feature-folder scoping documents, the qa-gate evidence, the coverage artifact, and the repository policy rules (`general-code-change.md`, `general-unit-test.md`, `powershell.md`).

---

## Verdict

The change is ready for normal PR flow. It is a focused, test-only fix that both disambiguates the colliding case-sensitivity cases and adds a deterministic, well-structured regression guard against future case-insensitive sibling-name collisions. The PowerShell toolchain passes clean, the new tests are deterministic and isolated, and no blocking or major findings were identified. The only notes are informational: the guard intentionally scopes to literal `-ForEach`/`-TestCases` data (documented limitation), and the suite-scan runtime scales with suite size. This conclusion is consistent with the Findings Table and the **Go** PR-readiness recommendation above. The remaining acceptance item AC6 (CI green on the PR head) is expected to be satisfied by the S9 CI gate after PR creation and is outside the local diff scope.
