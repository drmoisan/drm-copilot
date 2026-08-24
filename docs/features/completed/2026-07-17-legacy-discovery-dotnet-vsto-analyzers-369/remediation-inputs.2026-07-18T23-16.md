# Remediation Inputs — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T23-16
- Source review: feature-review re-audit of the full branch diff (analyzer feature + merge integration + bundle push-down)
- Base branch: `epic/legacy-discovery-and-parity-integration`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041`
- Related artifacts:
  - `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/policy-audit.2026-07-18T23-16.md`
  - `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/code-review.2026-07-18T23-16.md`
  - `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/feature-audit.2026-07-18T23-16.md`

## Remediation-Required Findings

### R-1 — Mandatory PowerShell coverage artifact absent for bundle hook mirrors (Blocking)

- **Severity:** Blocking (feature-review coverage rule: coverage verification is mandatory for every language with changed files in the branch diff).
- **Trigger:** The branch diff adds two PowerShell files under the bundled extension payload:
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1`
- **Finding:** PowerShell is a language with changed files on the branch, so a coverage verdict is mandatory and cannot be `N/A`. The required artifact `artifacts/pester/powershell-coverage.xml` is absent. Per rule, an absent coverage artifact for a language with changed files is a FAIL.
- **Mitigating context (does not clear the finding):**
  - Both added `.ps1` files are byte-identical to the pre-existing repo originals `.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.claude/hooks/validate-discovery-artifact-gate.ps1` (verified by `diff`). No new PowerShell logic is introduced.
  - The repo originals are exercised by an existing Pester suite (`tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`).
  - The bundle mirror's byte-identity to the tested originals is enforced by the now-passing pytest contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
  - The bundle payload (`extensions/**`) is outside the Python coverage `source` (`["src", "scripts/dev_tools"]`) and is packaged mirror output.
- **Residual risk:** Low. The risk is an evidence/classification gap, not a code defect; the mirrored logic is tested and its fidelity is contract-verified.
- **Acceptance criterion to satisfy remediation (either option is sufficient):**
  1. Produce `artifacts/pester/powershell-coverage.xml` via `mcp__drm-copilot__run_poshqc_test` (or the repository Pester coverage command) covering the discovery-artifact-gate hook logic, demonstrating line coverage >= 85% and branch coverage >= 75%; record the result under `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/evidence/qa-gates/`; OR
  2. Record an explicit policy classification that the `extensions/**` bundled-extension payload is packaged/mirror output not subject to per-language coverage measurement (mirroring the `.claude/rules/general-unit-test.md` coverage-exclusion treatment of build-output directories such as `dist/**`, `lib/**`), so that byte-identical mirror files under `extensions/**` do not constitute coverage-bearing changed files. This classification should be recorded in the authoritative coverage-policy rule and cited in the re-audit.
- **Files/paths in scope:** the two bundle `.ps1` files above; the coverage artifact `artifacts/pester/powershell-coverage.xml`; optionally the coverage-exclusion policy rule.
- **Out of scope:** modifying the analyzer Python modules, tests, or the hook logic; changing any acceptance criterion.

## Non-Blocking Observations (no remediation required)

- Informational code-review notes (open #363 CLI-flow-helper coordination item; heuristic `+=` detection residual false positives) are documented in `code-review.2026-07-18T23-16.md` and require no change in this feature.
- Stale PR-context artifacts were superseded by a direct git-derived diff for this audit; regenerating `artifacts/pr_context.summary.txt` / `.appendix.txt` against the current head is recommended for downstream consumers but is not a review blocker.

## Handoff

Route R-1 to remediation planning per `remediation-handoff-atomic-planner`. The remediation is a single, low-effort evidence/classification item; the underlying feature acceptance criteria all pass (see feature audit). No source-code change to the analyzer feature is required.
