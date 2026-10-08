# Code Review: PoshQC workspace-derived coverage population (#527, absorbs #623 item 1)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent (pass 1)
**Feature Folder:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #527 in the branch name.
**Base Branch:** `origin/main` (merge base `71f8dcb4`)
**Head Branch:** `bug/poshqc-coverage-denominator-not-reproducible-527` at `70ab599d`
**Review Type:** Initial review

---

## Executive Summary

The branch moves the Pester coverage population from a hand-maintained, module-copy-specific allow-list to a derivation from the workspace under test. A new sub-module `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (314 lines) adds four internal functions: a settings-list reader, a validated reader for `config/poshqc-coverage.json`, an include-only file-set enumerator, and a precedence resolver (`settings` from a caller-supplied runsettings file, then `config`, then `fallback` to scan folders or `Run.Path`). `Invoke-PoshQCTest` resolves a relative `-Root` to an absolute path, calls the resolver through a new `-ResolveCoveragePopulation` seam, and logs `Code coverage population: source=<s>; files=<n>`. Both runsettings copies drop the `CodeCoverage.Path` list. The bundled mirror is byte-identical. Two new Pester suites (30 cases) drive the code through injected seams with no temporary files.

Evidence reviewed: full branch diff, the four production PowerShell files, the two new and two edited test suites, the fixture, README, config, the PR context summary, the CI artifacts for the baseline run, the fail-first run, run A, and run B (re-reduced independently), and the feature-folder evidence. The implementation matches spec.md and plan D1-D5. No correctness defect requiring a change before merge was found.

**What changed:**
- `PoshQC.Coverage.psm1` (new): `Get-PoshQCSettingsList`, `Get-PoshQCCoverageConfigRoot`, `Get-PoshQCCoverageFileSet`, `Resolve-PoshQCCoveragePopulation`.
- `PoshQC.Testing.psm1`: lines 150-152 (help), 288-291 (new seam), 300-303 (absolute root), 350-363 (population resolution replaces the prune block).
- `PoshQC.psm1`: one sub-module list entry.
- `settings/pester.runsettings.psd1`: 300+ line `Path` list removed; `Enabled`, `OutputFormat`, `OutputPath`, `CoveragePercentTarget` kept.
- `config/poshqc-coverage.json`, `.gitignore`, README (both copies), parity list, potential-entry annotation, consumer fixture.

**Top 3 risks:**
1. Consumer behavior change: a `CodeCoverage.Path` list in the module's own runsettings file is now ignored (logged), and a caller-supplied runsettings file without a `Path` list now gets a derived population instead of Pester's default of instrumenting `Run.Path`. Standalone users who followed the previous README guidance ("Adjust `settings/pester.runsettings.psd1` ... to match your repo paths") lose their list silently except for one log line.
2. The fixture acceptance (AC-11 to AC-13) and the different-cwd determinism leg (AC-01) have not run against the fixed code; the #623 consumer behavior is proven only by the unit-level R2 test and by code inspection.
3. A directory-based derivation measures any untracked `.ps1`/`.psm1` file under a configured root, so a local scratch file changes the denominator (accepted risk in spec Risks & Mitigations; visible through the logged file count).

**PR readiness recommendation:** **Conditional Go** — no code defect blocks merge; the policy audit carries one blocking procedural item (Python coverage artifact) and four acceptance criteria remain deferred by operator decision.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/powershell/PoshQC/README.md`, `extensions/drm-copilot/CHANGELOG.md` | README "Notes for standalone use"; CHANGELOG `[Unreleased]` | Consumer-visible behavior change is documented in the README but not in the extension changelog: (a) a `CodeCoverage.Path` list in the module's own runsettings is ignored; (b) a caller-supplied runsettings file without `Path` now receives a derived population rather than Pester's Run.Path default. Non-blocking. | Add an `[Unreleased]` changelog entry describing the change and the migration to `config/poshqc-coverage.json`, either in this PR or as part of the release that ships it (release is out of this issue's spec). | Consumers that edited the shipped settings in place, as the previous README instructed, get no error; only a single log line signals the change. | `PoshQC.Coverage.psm1:268-297`; README diff line 86; `extensions/drm-copilot/CHANGELOG.md` `[Unreleased]` is empty. |
| Minor | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 183-194 | When an enumerated `FullName` does not start with the normalized `Root` prefix (absolute coverage root outside the workspace, or a `Root` spelled differently from the enumerated paths, such as an 8.3 short path), `RelativePath` falls back to the full absolute path. The `tests` first-segment rule then never applies, and every ancestor directory becomes a candidate `ExcludeDirs` segment, so a workspace under a directory named `build`, `dist`, or `artifacts` would exclude every file. Non-blocking. | Compute the exclusion segments relative to the coverage root when the workspace prefix does not match, or normalize `Root` with `Resolve-Path`/provider path before comparison; add one test with a non-matching prefix. | Silent empty population disables coverage for that run (logged, not fatal). | Code inspection; no test covers the non-matching prefix path. |
| Minor | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 102-112 | Version and `roots`-shape errors name the file but not the offending value; spec Error handling says a configuration error "names `config/poshqc-coverage.json` and the offending value". Entry errors (lines 117-123) include the value. Non-blocking. | Append the received `version` value and the received `roots` JSON type to those two messages. | Faster diagnosis of malformed consumer configs. | `spec.md` Error handling and logging updates; AC-06 is satisfied because AC-06 only requires the file name. |
| Minor | `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` | Describe `Resolve-PoshQCCoveragePopulation precedence` | Untested branches: a non-empty settings list with a blank `-SettingsFile` (D2: treated as not caller-supplied), a non-integer `version` (for example `"1"` or `1.5`), a top-level JSON array (line 96), and a rooted `-ConfigRelativePath` (line 75). New-file coverage is still 95.41%. Non-blocking. | Add three data-driven cases to the existing `-ForEach` table and one precedence case for a blank settings file. | These are boundary conditions named in plan D1/D2 and the general unit-test scenario-completeness rule. | Run A XML uncovered lines 75, 96, 163, 256, 257. |
| Minor | `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | 621-622, 745-746 | The adapted `Test-Path` mock answers true for any path matching `*src*`, which also matches unrelated paths that contain `src`. Non-blocking. | Match the exact joined coverage entry (for example `"$testRoot/src/*"`) instead of a substring. | Narrow mocks keep the test sensitive to path-joining regressions. | Branch diff of the file. |
| Minor | `scripts/powershell/PoshQC/README.md` (and mirror) | line 68 | The edited line still states that tests run "under `scripts` and `tests/powershell`"; the runsettings `Run.Path` also includes `tests/scripts`. Non-blocking (pre-existing wording on an edited line). | Add `tests/scripts` to the sentence. | README accuracy on a line this change rewrote. | `settings/pester.runsettings.psd1` line 3. |
| Nit | `scripts/powershell/PoshQC/README.md` (and mirror) | line 73 | "first root-relative segment is `tests`" can be read as relative to the coverage root; the implementation and spec use the workspace root. | Say "first workspace-relative segment". | Precision for consumers writing `roots`. | `PoshQC.Coverage.psm1:186-191`; spec Data flow. |
| Nit | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 172-174 | A `-ScanFolders` entry that names a file rather than a folder produces the warning "Coverage root ... does not exist", which is inaccurate for an existing file. | Word the warning as "is not a directory" or check leaf existence separately. | Diagnostic clarity only. | Code inspection. |
| Info | `config/poshqc-coverage.json` | roots | The derived population excludes `extensions/drm-copilot/resources/**`, which holds 158 tracked `.ps1`/`.psm1` files; most are mirrors guarded by parity, but some template scripts (for example `resources/templates/hello_pwsh.ps1`, `resources/templates/run-poshqc-*.ps1`) and `resources/lib/codex-routing/*.psm1` may not be byte-mirrors of a measured file. Spec explicitly excludes `extensions/`. | Confirm in a follow-up that every PowerShell file under `extensions/drm-copilot/resources/` is either a parity-guarded mirror of a measured file or is measured. | Coverage Exclusion Policy: no production file may be outside the denominator. | `git ls-files '*.ps1' '*.psm1'` outside the five roots. |
| Info | `<FEATURE>/evidence/other/mcp-route-compliance.2026-10-02T09-00.md`, `<FEATURE>/evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md` | file name and `Timestamp:` | Both timestamps postdate the commit that introduced them (`a987ebfb`, 2026-10-02 04:20 -0400 = 08:20 UTC); evidence timestamps follow UTC, while the convention requires host local time read from the clock. | Record clock-read local timestamps in future evidence; no content change needed here. | Timestamp provenance; cited numeric values were re-derived by the reviewer and matched. | `git log --format="%h %cd" -- <file>`. |

No Blocker findings. One Major finding (non-blocking documentation of a consumer-visible behavior change).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Precedence is evaluated once and returned as a `[pscustomobject]@{ Source; Paths }`, which makes the logged source and count directly testable.
- D2 is implemented exactly: the custom-settings test compares `GetFullPath` of `-SettingsFile` and the module default with `OrdinalIgnoreCase`; rooted entries are kept byte-for-byte; non-rooted entries use `Join-Path $Root`; each pruned path is logged individually. This preserves the existing `PoshQC.TestingCoveragePruning.Tests.ps1` expectations without edits.
- Determinism: candidates are keyed ordinally, sorted with `[StringComparer]::Ordinal`, and de-duplicated with `OrdinalIgnoreCase`, keeping the ordinally smallest variant. Runs A and B produced identical totals (15738 lines, 174 files).
- Issue #409 semantics are preserved: an empty set disables coverage, logs the existing line, and the run continues (`PoshQC.Testing.psm1:358-364`).
- `-Root` is resolved with `[IO.Path]::GetFullPath([IO.Path]::Combine($PWD.ProviderPath, $Root))` only when not rooted, so rooted test roots such as `/cov-root` are unchanged.
- Parity: the five changed or new PoshQC files are byte-identical to their mirrors (`sha256sum`), and the parity tuple includes the new sub-module.

#### API and safety notes

- No exported surface change: the four functions are internal; `PoshQC.psd1` is unchanged. `Invoke-PoshQCTest` gains one optional parameter; no parameter was removed.
- No parameter is `Mandatory` (plan D1, so empty arrays bind). The PowerShell rule asks for `Mandatory` "where appropriate"; the plan's rationale is recorded and acceptable.
- Approved verbs (`Get-`, `Resolve-`); analyzer reported no findings in CI.
- Config validation rejects rooted entries and `..` segments, so a workspace config cannot direct enumeration outside the workspace through relative traversal.

#### Error handling and logging

- Malformed configuration fails fast and aborts the run with a message naming `config/poshqc-coverage.json`. This is the spec's explicit choice; it differs from the #409 principle that coverage problems never abort the run, and the README documents it.
- Missing roots emit one warning each; JSON parse errors are wrapped with the file name and rethrown.
- Logging uses the injected `-Logger` seam consistently; the population line is emitted before Pester runs (asserted by R3).

### Python implementation audit

#### What changed well

- One tuple entry in `POSHQC_PARITY_PATHS`; Black, Ruff, Pyright, and Pytest pass.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- No change.

---

## Test Quality Audit

The new suites drive production code through injected seams and `InModuleScope` cmdlet mocks; no test writes to disk. The three route-level tests (R1-R3) deliberately leave the default coverage seams unmocked so they execute and count toward coverage, and the fail-first CI run shows them failing on assertions (not on binding) against pre-fix code.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` — 13 tests: route independence, #623 consumer population, logging order, absolute root, empty-population disable, scan-config hand-off, and seven file-set edge cases. Well isolated; AAA labelled.
- `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` — 17 cases: absent/valid config, eight malformed inputs via `-ForEach`, seven precedence cases. Gaps listed in the Findings Table.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1` — D14-predicted adaptations; minimal and line-neutral where required.
- `evidence/regression-testing/fail-first-coverage-tests.2026-10-02T08-45.md` — fail-first via CI run 36983544629 (conclusion failure confirmed by `gh run view`).
- `evidence/qa-gates/coverage-new-code.2026-10-02T08-45.md`, `coverage-aggregate.2026-10-02T08-45.md` — figures re-derived by the reviewer from the downloaded CI XML; all matched.
- `evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md` — pre-fix fixture run (installed copy) measured only the stand-in hook; the reviewer confirmed the fixture XML holds one `sourcefile` named `validate-bash.ps1`.

### Quality assessment prompts

- **Determinism:** No clock, RNG, network, or temp files; the relative-root test sets the location explicitly and restores it in `finally`. Test R6 omits `-Root` and therefore reads `$PWD`, but every filesystem seam is injected, so the result does not depend on the directory.
- **Isolation:** Each `It` targets one behavior; state is reset in `BeforeEach`.
- **Speed:** In-memory fakes only.
- **Diagnostics:** Whole-array `Should -Be` comparisons and `-Because` messages give actionable failures (fail-first log lines show expected and actual sets).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | No process launch or `Invoke-Expression` added. |
| Input validation at boundaries | PASS | Config schema validated; rooted and `..` entries rejected. |
| Error handling remains explicit | PASS | `throw` with file name; no silent catch. |
| Configuration / path handling is safe | PASS (with Minor finding) | Relative root resolved once; prefix-mismatch edge case noted above. |

---

## Research Log

No external research was required. Pester 5.6.1 coverage semantics were taken from the feature research document `research/research.2026-09-29T15-40.md` (section 1.5).

---

## Verdict

The implementation is correct against spec.md and plan D1-D5, the tests are deterministic and policy-compliant (no temporary files, AAA structure, mirrored layout), mirror parity holds, and CI runs A and B on the identical code tree pass format, analyze, and the full suite. The remaining items in this review are non-blocking: one Major documentation item for the consumer-visible behavior change and several Minor test-gap and wording items.

Code-review blocking findings: 0. Merge readiness depends on the policy-audit blocker (Python coverage artifact) and on the operator-deferred acceptance criteria recorded in the feature audit.
