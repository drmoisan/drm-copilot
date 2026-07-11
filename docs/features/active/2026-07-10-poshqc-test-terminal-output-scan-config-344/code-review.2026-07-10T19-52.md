# Code Review: poshqc-test-terminal-output-scan-config (#344)

**Review Date:** 2026-07-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number (#344) in scope; also the folder holding all materially changed scoping docs.
**Base Branch:** `main` (merge-base `cf036d3f5c1608f900d2ad23e08f809713101fa3`)
**Head Branch:** `drm-copilot-wt-2026-07-10T16-55` @ `2ed08b193e9adaabd115983f56d0cf2f3992ffad`
**Review Type:** Initial review
**Template source note:** Created from the bundled asset source file `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the same content the MCP template resolver serves); the MCP resolver tool could not be invoked in this session.

---

## Executive Summary

The branch delivers four capabilities in one commit (`2ed08b19`, 61 files, +11953/-55, of which ~1,900 lines are production and test code and the remainder is feature documentation and evidence): (1) a streaming pseudoterminal tee for the `Run PoshQC Test` command that leaves the spawn pipeline and failure contract untouched; (2) a bundled-module resync locked by an extended eight-pair byte-parity gate; (3) a persisted scan-folder configuration (`config/poshqc-scan.json`) with identical validation rules implemented in both the TypeScript and PowerShell consumers; and (4) a seeded multi-select QuickPick replacing the native folder dialog in the test-command flow.

Evidence reviewed: full branch diff, all new/changed production and test sources, executor QA-gate and baseline evidence, and the machine-readable coverage artifacts (`extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml`). Implementation quality is high: small cohesive modules, dependency-injected seams throughout, fail-fast validation with file-naming error messages, and deterministic tests with no banned APIs and no temporary files. The blocking findings are coverage-evidence gaps, not logic defects.

**What changed:**
Three new TypeScript modules (141/228/190 lines), one rewired registration module, a 5-line `extension.ts` delta, one new PowerShell module (125 lines), a precedence block in `PoshQC.Testing.psm1`, mechanical bundled resyncs, one new JSON config, an extended Python parity test, and five new/extended test suites.

**Top 3 risks:**
1. Coverage-evidence integrity: the persisted TypeScript lcov artifact predates the final state and omits the three new modules; the changed PowerShell modules are structurally outside coverage instrumentation (Blockers CR-1/CR-2, mirrored as policy-audit R1/R2).
2. In this development repository only, the bundled command wrapper reports 31 self-mocking test failures caused by a module-instance collision after the FR2.2 `RequiredModules` removal (Major, non-blocking, CR-4) — a confusing in-repo command-palette experience until a follow-up lands.
3. The TS/PowerShell duplication of validation rules and of the excluded-directory list is a cross-language sync liability, currently mitigated only by comments and the parity gate (Minor, CR-6).

**PR readiness recommendation:** **Needs Revision** — no logic rework required, but the three coverage-evidence blockers (stale TS lcov, PowerShell instrumentation gap without approved exception, absent Python coverage artifact) must be remediated before PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/coverage/lcov.info` | whole artifact | Post-change coverage artifact is stale relative to HEAD: no records for the three new modules; totals (31877/32985 lines = 96.64%) equal the recorded baseline; mtime 17:43 predates the 18:25 final gate. | Rerun `npm run test:coverage` at HEAD, verify per-file thresholds from the regenerated lcov, refresh the coverage-comparison evidence. | Fail-closed evidence rule: threshold compliance for new files must be corroborated by a machine-readable artifact, not only a gate log. | lcov parsed programmatically in this review; `evidence/qa-gates/final-ts-test-coverage.md` |
| Blocker | `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` | whole file (also `PoshQC.Testing.psm1`, `PoshQC.psm1`) | New production module has zero instrumented coverage lines: `PoshQC.psm1` loads sub-modules via fileless scriptblock dot-sourcing, so Pester breakpoints never bind; the module set is absent from `CodeCoverage.Path`. No approved exception recorded. | Refactor the sub-module loading so breakpoints bind and add the modules to `CodeCoverage.Path`, or record an explicit human-approved exception for this structural constraint. | `.claude/rules/general-unit-test.md` Coverage Exclusion Policy: no production file may be excluded from measurement; the prescribed response to untestable lines is refactoring. | `artifacts/pester/powershell-coverage.xml` (16 sourcefiles, none from PoshQC modules); `evidence/qa-gates/final-ps-test-coverage.md` |
| Blocker | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | n/a (language-level) | Python has a changed file on the branch but no coverage artifact exists at `artifacts/python/lcov.info`. | Run `poetry run pytest --cov` with an lcov reporter and persist the artifact; record repo-wide Python figures. | Coverage verification is mandatory for every language with changed files; test-only scope lowers practical severity but does not waive the artifact requirement. | `artifacts/` directory listing; `evidence/qa-gates/final-py-parity.md` |
| Major | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` | wrapper import flow (not modified by this branch) | Non-blocking: running the bundled wrapper inside this development repository now reports 31 failures in PoshQC's own self-mocking tests (`Mock data are not setup for this scope`) — a module-instance collision between the wrapper's resident bundled `PoshQC` import and the workspace module re-imported by those tests, exposed by the FR2.2 `RequiredModules` removal. | Open a follow-up issue: remove the resident module after the wrapper builds its invocation (e.g., run `Invoke-PoshQCTest` then `Remove-Module`), or make PoshQC's self-tests defensively remove same-named resident modules in `BeforeAll`. Do not restore `RequiredModules` (violates AC2 byte parity). | AC2 is discovered-set parity (holds, 1103=1103); the authoritative task/MCP gate passes 0 failures; production consumer repos lack PoshQC's self-tests, so the collision cannot occur there. In-repo command-palette UX regression only. | `evidence/regression-testing/junit-diff-post-change.md`; `evidence/qa-gates/acceptance-criteria-status.md` |
| Minor | `extensions/drm-copilot/src/poshqc-command-registration.ts` | `resolvePoshQcRunContext` call sites (lines 111, 137, 148) | A fresh `TerminalOutput` (and therefore a fresh integrated terminal) is created per command invocation; the writer's terminal reuse applies only within one invocation. Repeated runs accumulate terminals all named "drm-copilot: PoshQC". | Hoist a single shared `TerminalOutput` to `registerPoshQcCommands` scope (spec FR1.5 already anticipated all four commands sharing one terminal) so repeated runs reuse one live terminal. | Terminal proliferation degrades the intended task-like UX; AC1 does not require cross-invocation reuse, so this is not blocking. | Inspection of `poshqc-command-registration.ts` and `poshqc-terminal-output.ts` (`ensureTerminal` reuses only within the writer instance) |
| Minor | `extensions/drm-copilot/src/poshqc-folder-picker.ts` + `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` | `EXCLUDED_DIRECTORY_NAMES` (picker lines 25-40); validation rules (both consumers) | Excluded-directory list and validation rules are duplicated across TypeScript and PowerShell with comment-based sync only. | Acceptable per spec FR4.2 (explicit mirrored-constant design with pointer comment). Consider a future shared fixture test asserting the two lists/rule sets match. | Cross-language drift would silently diverge picker candidates from module scan behavior; current mitigations are comments plus dual test suites. | `poshqc-folder-picker.ts:20-40`; spec FR4.2 |
| Info | `extensions/drm-copilot/test/*` | harness | Suites use Jest (`run-jest.cjs`) while `.claude/rules/typescript.md` names Vitest generically. Pre-existing package convention; spec explicitly forbids introducing a second framework. | No action for this feature. | Documented deviation, consistent across the package's 140 suites. | spec.md Constraints & Risks; `extensions/drm-copilot/test/` |
| Info | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | removed `ExcludedPath` block | The bundled resync removes the undocumented `CodeCoverage.ExcludedPath` block and adopts the workspace coverage `Path` list — a policy-aligned cleanup (the exclusion of production files from coverage is prohibited). | None; note that the workspace copy is authoritative and unchanged by this branch. | Confirms FR2.2/FR2.4: only bundled copies changed to match the workspace. | Branch diff of the bundled settings file; `git diff --name-only` shows no workspace settings change |

No further Blocker or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- `poshqc-terminal-output.ts` keeps the spawn pipeline untouched and implements the display tee exactly as specified: append-mode pseudoterminal, CRLF normalization, pre-open buffering with ordered flush, and exited-terminal replacement. The failure contract (`CommandExecutionError`, `getStderrExcerpt`) is preserved and regression-tested (AC5).
- `poshqc-scan-config.ts` is a clean pure-logic module behind the `FileSystem` seam: fail-fast validation with messages that name the file, canonical writes (sorted, deduplicated, forward-slash, trailing newline) with a byte-stable round-trip, and absence semantics that preserve pre-feature behavior.
- `poshqc-command-registration.ts` absorbs all wiring so `extension.ts` grew by only 5 lines and `repo-automation-service.ts` is untouched (verified: no diff), satisfying the FR1.5 near-cap constraint.

#### Type safety and maintainability

- Precise types throughout: `asserts folder is string` narrowing, `ParsedScanConfig` modeling only consumed fields as `unknown`, `readonly` arrays on public signatures, discriminated absence handling. No `any`, no type assertions beyond the single post-validation `scanFolders as string[]` (justified — every element was just asserted to be a string), and no ESLint/TS suppressions in the changed files.
- The optional `createService` / `createTerminalOutput` / `fileSystem` seams keep the default path byte-compatible while making the terminal behavior fully testable.

#### Error handling and logging

- JSON parse failures rethrow with context and `{ cause }`; validation errors name `config/poshqc-scan.json`; empty-selection and cancel paths are explicit no-ops with a user-facing information message where required (FR4.5/FR4.6).

### PowerShell implementation audit

#### What changed well

- `Get-PoshQCScanConfigFolder` mirrors the TypeScript validation contract rule-for-rule, uses the module's established DI style (injectable `$TestPathExists`/`$ReadContent`/`$Logger`), and implements the FR3.5 policy precisely: skip-with-warning for config-sourced missing folders, hard error when the surviving set is empty, and no weakening of `Resolve-PoshQCScanFolder` (explicit folders still throw on missing — regression-tested).
- The `Invoke-PoshQCTest` precedence block is minimal and explicit: explicit `-ScanFolders` wins; otherwise `$ResolveScanConfig` is consulted; an empty result leaves `Run.Path` defaults untouched. Because resolution lives in the module, the MCP tool became config-aware with zero MCP code change (AC12).

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, mandatory `$Root`, approved verb. StrictMode-safe property access through `PSObject.Properties` is a correct defensive choice for `ConvertFrom-Json` output. No global state; no `Invoke-Expression`; no ShouldProcess needed (read-only function).

#### Error handling and logging

- Fail-fast `throw` messages name the config file and the offending entry; the skip warning names file, folder, and root. Analyzer-clean (zero findings).

### Python implementation audit

#### What changed well

- The parity gate extension is the minimal correct change: four path literals appended to `POSHQC_PARITY_PATHS`, byte-locking the manifest, both settings files, and the new module against their bundled mirrors — permanently closing the drift class that caused the original divergence.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Unchanged assertion behavior; a parity failure names the drifted pair.

---

## Test Quality Audit

Coverage, regression, and baseline evidence are present and well organized under the feature `evidence/` tree; the gaps are the three artifact-level blockers recorded above.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/poshqc-scan-config.test.ts` — 13 cases covering every validation rule, absence semantics, canonical write, and byte-stable round-trip against the in-memory `FileSystem`. No gaps observed.
- `extensions/drm-copilot/test/poshqc-terminal-output.test.ts` — full writer lifecycle including pre-open buffering, exited-terminal replacement, and tee ordering.
- `extensions/drm-copilot/test/poshqc-folder-picker.test.ts` — depth-2 enumeration with exclusions, seeding, warning marker, persistence-before-return, cancel and empty-selection semantics (AC13–AC15).
- `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` — command-path terminal streaming, dual-sink identity, and the AC5 failure-semantics case (`CommandExecutionError` with `exitCode`/`stdout`/`stderr`, unchanged `getStderrExcerpt`).
- `extensions/drm-copilot/test/mcp-server.test.ts` — asserts the MCP dispatch path never creates a terminal (AC6).
- `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1` / `PoshQC.ScanFolders.Tests.ps1` — 12 + 4 seam-injection It blocks covering validation, skip/error policy, and precedence (AC8–AC10).
- `evidence/regression-testing/junit-diff-post-change.md` + XMLs — discovered-set parity 1103=1103 with a transparent pass/fail-delta analysis (AC2/AC7 closure).
- `evidence/qa-gates/*` — complete final toolchain gate set with commands and exit codes for all three languages.

### Quality assessment prompts

- **Determinism:** No timers, wall-clock reads, randomness, or temp files in any new/changed test (grep-verified); all host interaction via injected fakes/seams.
- **Isolation:** One behavior per test; per-test fresh fakes; Pester seams injected per It block.
- **Speed:** Single-pass gate runs, exit 0; no waits.
- **Diagnostics:** Error-path tests assert exact file-naming messages, so failures identify the violated rule directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: config file contains folder names only; no credentials, tokens, or `.env` content anywhere in the branch. |
| No unsafe subprocess or command construction | PASS | Spawn pipeline unchanged (`command-runtime.ts` not in diff); scan folders pass through the existing `-ScanFoldersJson` argument path; no `Invoke-Expression`. |
| Input validation at boundaries | PASS | Both consumers reject absolute paths and `..` segments before any filesystem use, preventing scan-set escape from the workspace root; version gate rejects unknown schemas. |
| Error handling remains explicit | PASS | Fail-fast throws with context in both languages; no broad catch-alls (the single TS `catch` rethrows with `{ cause }`). |
| Configuration / path handling is safe | PASS | Canonicalization never rewrites `..` (explicit comment and test coverage); `Join-Path`/POSIX joins against the workspace root only; writes create the parent directory then write canonical content. |

---

## Research Log

No external research was required. All findings derive from branch-diff inspection, repository policy files, executor evidence artifacts, and programmatic parsing of the two machine-readable coverage artifacts.

---

## Verdict

The implementation is well designed and ready in substance: capability delivery matches the spec, the failure and precedence contracts are regression-tested, determinism and file-size rules hold, and the toolchain is clean across TypeScript, PowerShell, and Python. The change is **not yet ready for normal PR flow** because three coverage-evidence blockers remain (stale TypeScript lcov at HEAD, changed PowerShell production modules outside the coverage denominator with no approved exception, absent Python coverage artifact). These are evidence and instrumentation tasks, not logic rework. The escalated bundled-wrapper failure mode was independently evaluated and determined non-blocking (development-repository-only module collision; authoritative gates pass; recommend the CR-4 follow-up issue). After remediation of the three blockers, this branch merits a Go.
