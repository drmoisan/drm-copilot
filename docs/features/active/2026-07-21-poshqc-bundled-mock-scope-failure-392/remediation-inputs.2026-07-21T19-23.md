# Remediation Inputs (Issue #392) — Cycle Entry 2026-07-21T19-23

- **Feature folder:** `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/`
- **Base branch:** `main` (merge-base `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`)
- **Head:** `drm-copilot-wt-2026-07-21T17-18` @ `92bf1f29659da829e4cbf4d0bcc4af2182d87b06`
- **Produced by:** feature-review agent, from the 2026-07-21T19-23 audit pass
- **Source audit artifacts:**
  - `policy-audit.2026-07-21T19-23.md` (FAIL finding: section 1.2 and section 8)
  - `code-review.2026-07-21T19-23.md` (Major finding, Findings Table row 1)
  - `feature-audit.2026-07-21T19-23.md` (all 8 AC PASS; no AC-level remediation)
- **Handoff:** plan authoring is delegated to `atomic-planner` per `remediation-handoff-atomic-planner`; the target plan file `remediation-plan.2026-07-21T19-23.md` has been created in this feature folder and must be completed/validated by `atomic-planner`, preflighted by `atomic-executor`, and executed before re-audit.

## Remediation-Required Findings

### Fix 1 (Blocking) — Raise modified-file line coverage of `PoshQC.Testing.psm1` to >= 85%

- **File:** `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (production; measured copy — test-only remediation, no production edit expected, therefore no mirror parity impact)
- **Current state:** 76.41% line coverage (149/195 covered) per `artifacts/pester/powershell-coverage.xml` (JaCoCo, reviewer-regenerated 2026-07-21T19-23 via `scripts/dev-tools/run-poshqc-suite.ps1`, exit 0).
- **Policy floor:** >= 85% line coverage for modified files (`.claude/rules/quality-tiers.md` uniform gates; feature-review-workflow step 5). 76.41% is also below the 80% remediation trigger.
- **Uncovered lines (46):** 98, 291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369, 401-403, 410-415, 417-420, 423-424, 427-428, 433-439. These are pre-existing default seam bodies (Koverage copy/relative-conversion, summary/logger, and result-handling paths) that entered the measured set when this feature added the file to `CodeCoverage.Path`.
- **Expected behavior after fix:** per-file LINE counter for `PoshQC.Testing.psm1` in `artifacts/pester/powershell-coverage.xml` >= 85%; repo measured-set LINE remains >= 85%; full suite remains 0 failed; no changed-line regression.
- **Suggested approach (planner may refine):** add unit tests in `tests/scripts/powershell/PoshQC/` (extend `PoshQC.TestingSeamDefaults.Tests.ps1` or add a sibling `*.Tests.ps1`, each file <= 500 lines) that invoke the remaining default seam scriptblocks (extracted via the same AST pattern already used) with stubbed boundaries. Covering approximately 17 of the 46 uncovered lines reaches the 85% floor (166/195 = 85.1%); prefer covering complete seam bodies rather than the minimum line count.
- **Verification commands:**
  1. `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1` — expect exit 0, 0 failed.
  2. Parse `artifacts/pester/powershell-coverage.xml`: `sourcefile name="PoshQC.Testing.psm1"` LINE counter `covered/(covered+missed) >= 0.85`.
  3. `python scripts/dev_tools/validate_evidence_locations.py --root .` — expect exit 0 for any new evidence artifacts.

## Informational Items (no code change required this cycle)

- **Branch-coverage counter absent:** the Pester/JaCoCo report emits no BRANCH counter, so the 75% branch floor cannot be numerically verified for PowerShell. Toolchain capability limitation, repo-wide and pre-existing. Do not attempt to fix inside this remediation cycle; record as follow-up tooling debt.
- **MCP stale-bundle gate:** `mcp__drm-copilot__run_poshqc_test` exits 33 against the pre-fix installed extension bundle. Post-merge follow-up: repackage the extension from main, re-run the MCP gate, expect exit 0. Not actionable from this branch.
- **Pre-existing over-limit file:** `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` is 766 lines (also 766 at merge base). Do not expand it during remediation; place new tests in a different file.

## Do Not Do

- Do not modify production files (`PoshQC.Testing.psm1`, `pester.runsettings.psd1`, or their bundled mirrors) — this is a test-addition remediation only.
- Do not weaken, remove, or skip existing tests or assertions to move the coverage percentage.
- Do not add `exclude` entries or remove files from `CodeCoverage.Path` to satisfy the floor (prohibited by the coverage exclusion policy).
- Do not run real nested `Invoke-Pester` executions or spawn external processes inside unit tests.
- Do not write evidence outside `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/<kind>/`.
- Do not expand scope beyond Fix 1; new findings, if any, open a new cycle.
