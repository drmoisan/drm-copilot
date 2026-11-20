# poshqc-test-terminal-output-scan-config — Remediation Plan (Cycle 1)

- **Issue:** #344
- **Remediation cycle:** 1 (R1)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-10
- **Status:** Ready for Preflight
- **Work Mode:** full-feature (remediation of blocking findings; no new feature scope)
- **Plan Path (continuity):** `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/remediation-plan.2026-07-10T20-46.md` (update in place across revision loops; do not create sibling plan files)

## Remediation Inputs

- Remediation inputs: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/remediation-inputs.2026-07-10T19-52.md`
- Policy audit: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/policy-audit.2026-07-10T19-52.md` (section 8, R1–R3)
- Code review: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/code-review.2026-07-10T19-52.md` (three Blockers)
- Feature audit: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/feature-audit.2026-07-10T19-52.md` (AC16 PARTIAL)
- Original plan: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.md`

## Findings in Scope (all Blocking)

- **R1** — TypeScript post-change coverage artifact (`extensions/drm-copilot/coverage/lcov.info`) is stale at HEAD: no records for the three new modules; totals equal the baseline (31877/32985 lines = 96.64%, 4056/4577 branches = 88.62%).
- **R2** — `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` (and its bundled mirror) is outside the Pester coverage denominator because `PoshQC.psm1` loads sub-modules via fileless `[scriptblock]::Create((Get-Content ... -Raw))` dot-sourcing, so Pester breakpoints never bind. Remediation is the policy-preferred scope_change: refactor the loading so breakpoints bind, add the module to `CodeCoverage.Path`, and evidence its coverage. No human exception is taken.
- **R3** — Python coverage artifact absent at `artifacts/python/lcov.info` although `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` changed on the branch.

## Scope Constraints

- Remediate R1–R3 and their direct prerequisites only. No implementation-logic rework of delivered behavior. If R2 work surfaces a genuinely new defect, record it as an out-of-cycle finding in the P2-T14 artifact and do not fix it in this cycle.
- Do-Not-Do list from `remediation-inputs.2026-07-10T19-52.md` applies in full: no policy-file edits, no weakened tests or assertions, no restoration of the bundled `RequiredModules` block, no `CodeCoverage.ExcludedPath` reintroduction, no exclusion of any production source path from coverage.
- The non-blocking bundled-wrapper self-test collision (code review CR-4) is explicitly out of scope; it is tracked for a follow-up issue and must not be fixed or worked around here.

## Conventions

- `<FEATURE>` = `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344`. Evidence artifacts go only to `<FEATURE>/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/`-rooted evidence path is permitted. (`artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and `extensions/drm-copilot/coverage/lcov.info` are machine-readable toolchain outputs at their repo-standard locations, not evidence artifacts; the evidence markdown that cites them lives under `<FEATURE>/evidence/`.)
- Every evidence artifact records `Timestamp:` (ISO-8601 `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- TypeScript toolchain (run in `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:coverage`.
- PowerShell toolchain: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`.
- Python toolchain: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info`.
- Loop rule: if any toolchain stage fails or changes files, restart that language's loop from formatting and repeat until a single clean pass completes. If formatting changes a workspace PoshQC module, re-copy the bundled mirrors (P1-T3 file set) before rerunning.
- Determinism: no temporary files in tests; mock the wrapper seam or injectable scriptblock, never the executable; no wall-clock reads, timers, or sleeps. No test file changes are planned in this cycle.
- Coverage thresholds: line >= 85% and branch >= 75% for changed/new code; no regression on changed lines. Pester's `CoverageGutters` output is command/line-based; where the PowerShell coverage report emits no branch data, the evidence records that fact explicitly and the line figure is the recorded threshold value (this matches the accepted `baseline-ps-test-coverage.md` evidence convention and is the only authorized limitation note — it is not a skip).
- PowerShell per-batch cap: Phase 1 is one batch of exactly 2 production PowerShell files (`scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) and 0 test files — under the 3/3 cap. The two bundled-mirror copies are byte-for-byte mechanical resyncs mandated by the parity gate and introduce no independent design surface.
- No `SKIPPED` outcome is authorized for any command task in this plan except the explicitly stated branch-data limitation note above, which does not skip any command.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Remediation Fail-Before Baselines

- [x] [P0-T1] Read policy files in the required order and record the read evidence.
  - Order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md` (if present), `.claude/rules/python.md`, `.claude/rules/python-suppressions.md` (if present)
  - Artifact: `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read
  - Acceptance: artifact exists with all required fields; list matches the order above
- [x] [P0-T2] Record the R2 fail-before state: the current Pester coverage XML contains no PoshQC module sourcefile.
  - Command: `pwsh -NoLogo -NoProfile -Command "[xml]$x = Get-Content artifacts/pester/powershell-coverage.xml; $x.SelectNodes('//sourcefile') | ForEach-Object { $_.name }"` (run from the repo root; adjust the XPath to the actual document shape if needed and record the exact command used)
  - Artifact: `<FEATURE>/evidence/remediation-baseline/r2-fail-before-ps-coverage.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the sourcefile names and stating that no `PoshQC*.psm1` entry is present)
  - Acceptance: artifact exists and demonstrates the absence of any PoshQC module from the coverage denominator
- [x] [P0-T3] Record the R1 fail-before state: the on-disk TypeScript lcov is stale.
  - Command: `pwsh -NoLogo -NoProfile -Command "Select-String -Path extensions/drm-copilot/coverage/lcov.info -Pattern 'poshqc-scan-config|poshqc-terminal-output|poshqc-folder-picker' | Measure-Object | Select-Object -ExpandProperty Count"` (expected result: 0) plus `(Get-Item extensions/drm-copilot/coverage/lcov.info).LastWriteTime`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/r1-fail-before-ts-lcov.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording the match count of 0, the file mtime, and the stale totals 31877/32985 lines and 4056/4577 branches)
  - Acceptance: artifact exists and demonstrates that the current lcov omits the three new modules
- [x] [P0-T4] Record the R3 fail-before state: the Python coverage artifact is absent.
  - Command: `pwsh -NoLogo -NoProfile -Command "Test-Path artifacts/python/lcov.info"` (expected result: `False`)
  - Artifact: `<FEATURE>/evidence/remediation-baseline/r3-fail-before-py-artifact.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording the `False` result)
  - Acceptance: artifact exists and demonstrates the artifact's absence before remediation

### Phase 1 — R2: Make `PoshQC.ScanConfig.psm1` Coverage-Instrumentable

Batch declaration: 2 production PowerShell files (`scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), 0 test files — within the 3/3 per-batch cap. Bundled mirrors in P1-T3 are mechanical byte copies. `PoshQC.ScanConfig.psm1` itself is not modified.

- [x] [P1-T1] Refactor the sub-module loading in `scripts/powershell/PoshQC/PoshQC.psm1` (lines 82-88) so the loaded scriptblocks retain their on-disk file association while preserving module-scope function definition.
  - Change: replace each of the four `. ([scriptblock]::Create((Get-Content (Join-Path $script:ModuleRoot '<Name>.psm1') -Raw)))` lines with AST-based loading: `. ([System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:ModuleRoot '<Name>.psm1'), [ref]$null, [ref]$null).GetScriptBlock())` for `PoshQC.FileDiscovery.psm1`, `PoshQC.ScanConfig.psm1`, `PoshQC.Analyzer.psm1`, `PoshQC.Testing.psm1` (a shared private helper looping over the four names is acceptable if simpler). A scriptblock obtained from `Parser::ParseFile` carries the source file path, so Pester coverage breakpoints can bind, while dot-sourcing it still executes in the caller's (module) scope — the same scope behavior the current comment documents for the PS 7.6+ isolated-module workaround. Update the explanatory comment (lines 82-84) to describe the new mechanism and why it is used (coverage instrumentation + module scope). Parse errors reported by `ParseFile` must fail module import fast (throw naming the file), not be silently ignored.
  - Constraints: exported function set unchanged (all nine exports at lines 92-102 plus the `Install-PoshQCTools` alias); file stays <= 500 lines; no other logic changes
  - Contingency: if the full Pester run in P1-T4 shows coverage breakpoints still do not bind to `PoshQC.ScanConfig.psm1` under this mechanism, stop, revert nothing, and report the plan blocked with the empirical evidence — the R2 option-b human-approved exception cannot be self-approved and is not authorized by this plan
  - Acceptance: `Import-Module ./scripts/powershell/PoshQC -Force` succeeds and `Get-Command -Module PoshQC` lists the same exported command set as before the change (verified within the P1-T4 test run)
- [x] [P1-T2] Add `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (path list at lines 23-80).
  - Change: append the entry `'scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1'` with a comment in the file's established style: issue #344 remediation cycle 1 (R2) — the new production module is measured so it is not excluded from coverage; module loading was refactored to AST-based scriptblocks so breakpoints bind
  - Constraints: no entry removed; `CodeCoverage.ExcludedPath` must not be introduced; all other keys unchanged
  - Acceptance: the settings file parses (`Import-PowerShellDataFile` succeeds) and contains the new path entry exactly once
- [x] [P1-T3] Mirror the two changed workspace files byte-for-byte into the bundled resources (mechanical copies; parity pairs preserved).
  - Copies: `scripts/powershell/PoshQC/PoshQC.psm1` → `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` → `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Acceptance: each bundled file is byte-identical to its workspace source (`git diff` inspection; enforced by P1-T5)
- [x] [P1-T4] Run the full PowerShell toolchain loop until a single clean pass and verify R2 instrumentation from the regenerated coverage XML.
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`; restart from format if any step fails or changes files; re-copy mirrors (P1-T3) if formatting changed the workspace files
  - Verification: after the clean test pass, parse `artifacts/pester/powershell-coverage.xml` and extract the per-file covered/missed line counts for `PoshQC.ScanConfig.psm1`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ps-scanconfig-coverage.2026-07-10T20-46.md` (`Timestamp:`, `Command:` for the test run and the XML parse, `EXIT_CODE:`, `Output Summary:` with Pester pass/fail counts (0 failures required), the numeric line-coverage percentage for `PoshQC.ScanConfig.psm1`, and the branch figure when the report emits branch data — otherwise the explicit line-based-instrument note from Conventions)
  - Acceptance: all Pester tests pass (0 failures); `PoshQC.ScanConfig.psm1` appears as a coverage sourcefile with line coverage >= 85%; artifact recorded with numeric values (no placeholders)
- [x] [P1-T5] Verify the eight-pair parity gate passes with the Phase 1 mirrors in place.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-parity-gate.2026-07-10T20-46.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the eight parity-locked pairs as passing)
  - Acceptance: exit code 0; all eight parity pairs pass, including `PoshQC.psm1` and `settings/pester.runsettings.psd1`

### Phase 2 — Final QA Loop, Coverage Regeneration (R1/R3), and Closure Verification

Loop rule for this phase: if any command in P2-T1..P2-T12 fails or changes files, fix within R1–R3 scope, then restart that language's loop from its formatting step and re-record the affected artifacts. No `SKIPPED` outcomes are authorized.

- [x] [P2-T1] Run TypeScript formatting and record evidence.
  - Command: `npm run format` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ts-format.2026-07-10T20-46.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0; no file changes on the final pass
- [x] [P2-T2] Run TypeScript linting and record evidence.
  - Command: `npm run lint` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ts-lint.2026-07-10T20-46.md`
  - Acceptance: exit code 0, zero errors
- [x] [P2-T3] Run TypeScript type-checking and record evidence.
  - Command: `npm run typecheck` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ts-typecheck.2026-07-10T20-46.md`
  - Acceptance: exit code 0, zero errors
- [x] [P2-T4] Regenerate the TypeScript coverage artifact at HEAD (R1) and record numeric post-change coverage.
  - Command: `npm run test:coverage` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ts-test-coverage.2026-07-10T20-46.md`; `Output Summary:` MUST include the numeric repo-wide line and branch percentages and the per-file figures for `src/poshqc-scan-config.ts`, `src/poshqc-terminal-output.ts`, `src/poshqc-folder-picker.ts`, `src/poshqc-command-registration.ts`
  - Acceptance: all tests pass; `extensions/drm-copilot/coverage/lcov.info` is regenerated in this run (post-remediation worktree state)
- [x] [P2-T5] Verify the regenerated lcov machine-readably resolves R1.
  - Command: parse `extensions/drm-copilot/coverage/lcov.info` and extract per-file `LH/LF` and `BRH/BRF` for `poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`, `poshqc-command-registration.ts`, plus repo-wide totals (e.g., a `pwsh` `Select-String`/aggregation one-liner; record the exact command)
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ts-lcov-verification.2026-07-10T20-46.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with all four per-file line/branch percentages and the repo-wide totals compared against the baseline 96.64% lines / 88.62% branches)
  - Acceptance: all four modules present in the lcov; each has line coverage >= 85% and branch coverage >= 75%; repo-wide figures show no regression versus the baseline
- [x] [P2-T6] Run PowerShell formatting via MCP and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_format`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ps-format.2026-07-10T20-46.md`
  - Acceptance: exit code 0; if files changed, re-copy the P1-T3 mirrors and restart the PowerShell loop
- [x] [P2-T7] Run the PowerShell analyzer via MCP and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ps-analyze.2026-07-10T20-46.md`
  - Acceptance: exit code 0, zero findings
- [x] [P2-T8] Run Pester tests via MCP in coverage mode and record final numeric post-change coverage (R2 closure gate).
  - Command: `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-ps-test-coverage.2026-07-10T20-46.md`; `Output Summary:` MUST include pass/fail counts (0 failures), the overall coverage figure, and the per-file numeric line coverage for `PoshQC.ScanConfig.psm1` from `artifacts/pester/powershell-coverage.xml` (branch figure when emitted, otherwise the Conventions limitation note)
  - Acceptance: all tests pass; `PoshQC.ScanConfig.psm1` line coverage >= 85%; numeric values recorded, no placeholders
- [x] [P2-T9] Run Python formatting and record evidence.
  - Command: `poetry run black .`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-py-format.2026-07-10T20-46.md`
  - Acceptance: exit code 0; no file changes on the final pass
- [x] [P2-T10] Run Python linting and record evidence.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-py-lint.2026-07-10T20-46.md`
  - Acceptance: exit code 0, zero errors
- [x] [P2-T11] Run Python type-checking and record evidence.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-py-typecheck.2026-07-10T20-46.md`
  - Acceptance: exit code 0, zero errors
- [x] [P2-T12] Run the Python test suite with coverage to produce the missing artifact (R3) and record numeric figures.
  - Command: `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info` (from the repo root; `pytest-cov >= 7.0` is already a project dependency and `addopts` already routes the lcov report to this path)
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-py-coverage.2026-07-10T20-46.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the pytest pass count — including the eight-pair parity test — confirmation that `artifacts/python/lcov.info` now exists, and the numeric repo-wide Python line percentage plus branch percentage when the coverage configuration emits branch data, otherwise an explicit note that branch measurement is not enabled in the repo coverage configuration)
  - Acceptance: exit code 0; `artifacts/python/lcov.info` exists; numeric repo-wide figures recorded; either repo-wide line >= 85% (and branch >= 75% when measured) or the below-threshold pre-existing state is documented with the explicit statement that this branch changes no Python production code, so changed-line regression is structurally impossible (per remediation-inputs R3 expected behavior)
- [x] [P2-T13] Refresh the coverage baseline/post-change/changed-code comparison artifact.
  - Inputs: `<FEATURE>/evidence/baseline/baseline-ts-test-coverage.md`, `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md`, and the Phase 2 artifacts from P2-T4, P2-T5, P2-T8, P2-T12
  - File updated: `<FEATURE>/evidence/qa-gates/coverage-comparison.md` (update in place; append a `## Remediation Cycle 1 (2026-07-10T20-46)` section rather than deleting the original content) reporting, per language: baseline coverage, post-change coverage, and new/changed-code coverage (TypeScript per-file figures for the four modules; PowerShell per-file figure for `PoshQC.ScanConfig.psm1`; Python repo-wide figure with the test-only-change note), each sourced from the regenerated machine-readable artifacts — numeric values only, no placeholders
  - Acceptance: the refreshed section shows line >= 85% and branch >= 75% for changed code (subject to the stated PowerShell branch-data limitation note) and no regression on changed lines; if any required numeric value is unavailable, the plan outcome is remediation-required, not PASS
- [x] [P2-T14] Produce the findings-resolution and AC16 re-evaluation artifact.
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-findings-resolution.2026-07-10T20-46.md` containing, for each of R1, R2, R3: the finding statement, the resolving task IDs, the machine-readable artifact path, and the numeric evidence values; plus an AC16 re-evaluation section concluding whether the AC16 coverage clause now evaluates PASS (referencing the P2-T5, P2-T8, P2-T12, P2-T13 evidence) and confirming the existing `[x]` marks for AC16 in `spec.md` and `user-story.md` are now accurate (no source-file edit expected — both are already checked; document the confirmation); plus an `## Out-of-Cycle Findings` section listing any genuinely new defect surfaced during remediation (or `none`)
  - Acceptance: artifact exists; all three findings are marked resolved with numeric evidence; AC16 coverage clause evaluates PASS; no unresolved blocking item remains in this cycle's scope
- [x] [P2-T15] Verify change-surface containment and file-size compliance.
  - Commands: `git status --porcelain` and `git diff --stat` from the repo root; line counts for `scripts/powershell/PoshQC/PoshQC.psm1` and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation-change-surface.2026-07-10T20-46.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing every modified/added path and each checked file's line count)
  - Acceptance: modified/added paths are limited to the two workspace PowerShell files, their two bundled mirrors, regenerated toolchain outputs (`extensions/drm-copilot/coverage/**`, `artifacts/pester/**`, `artifacts/python/lcov.info`, `artifacts/.coverage`), and `<FEATURE>/evidence/**` plus this plan file; both checked production files are <= 500 lines; no production code outside R2 scope changed

## Finding-to-Task Mapping

| Finding | Resolved by tasks | Closure evidence |
|---|---|---|
| R1 (stale TS lcov at HEAD) | P0-T3 (fail-before), P2-T4, P2-T5, P2-T13 | `remediation-ts-lcov-verification.2026-07-10T20-46.md` + regenerated `extensions/drm-copilot/coverage/lcov.info` |
| R2 (PoshQC module outside Pester coverage denominator) | P0-T2 (fail-before), P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P2-T6, P2-T7, P2-T8, P2-T13 | `remediation-ps-scanconfig-coverage.2026-07-10T20-46.md`, `remediation-ps-test-coverage.2026-07-10T20-46.md` + `artifacts/pester/powershell-coverage.xml` sourcefile entry |
| R3 (absent Python coverage artifact) | P0-T4 (fail-before), P2-T9..P2-T12, P2-T13 | `remediation-py-coverage.2026-07-10T20-46.md` + `artifacts/python/lcov.info` |
| AC16 coverage clause (PARTIAL → PASS) | P2-T13, P2-T14 | `remediation-findings-resolution.2026-07-10T20-46.md` |

## Notes

- The R2 mechanism (AST-based `Parser::ParseFile(...).GetScriptBlock()` dot-sourcing) preserves the documented PS 7.6+ module-scope workaround while restoring the file-path association Pester breakpoints require. If the P1-T4 empirical verification shows breakpoints still do not bind, execution halts as blocked per the P1-T1 contingency; the option-b human exception is out of this plan's authority.
- Only `PoshQC.ScanConfig.psm1` is added to `CodeCoverage.Path` in this cycle, matching the R2 remediation directive. Broader denominator expansion for pre-existing modules (`PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`) is out of cycle-1 scope; those files had zero instrumented lines before this cycle, so no-regression on them holds structurally.
- FR2.5 residual limitation (carry into the PR description): the installed extension converges on the reconciled bundled resources only at the next packaged release.
