# Remediation Inputs — Cycle 2 (Bundle Push-Down Contract Failure)

- Timestamp: 2026-07-19T02:51:07Z
- Feature: legacy-discovery-dotnet-vsto-analyzers
- Canonical issue number: 369
- PR: #384 (base epic/legacy-discovery-and-parity-integration)
- Branch head at cycle entry: 008e59e91ff8473792da98ba656653a146c31165
- Source: New finding discovered during cycle-1 execution (Scope-change Rule)
- Cycle entry: remediation.cycle_2.inputs

## Finding 1 — BLOCKING: bundled `.claude` payload missing two repo hook files

Severity: Blocking

The contract test
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails. It requires every non-memory repo `.claude` file to have a byte-identical
counterpart in the bundled extension payload under
`extensions/drm-copilot/resources/claude-customizations/.claude/`.

Independently verified missing files (repo tree has them, bundle does not):

- `.claude/hooks/enforce-discovery-artifact-gate.ps1`
- `.claude/hooks/validate-discovery-artifact-gate.ps1`

### Provenance

Verified against `origin/epic/legacy-discovery-and-parity-integration`: both repo hook
files exist on the integration branch, and neither has a bundle counterpart on the
integration branch. The defect therefore pre-exists on the integration branch and was
inherited by this feature branch through the cycle-1 merge; it was not introduced by the
#369 analyzer changes. It nonetheless blocks CI-green for PR #384 (the merged feature
branch runs the full test suite), so it must be resolved before the S9 merge-on-green step.

This matches the established repository remediation pattern for this contract test (for
example commit f17f1af0 "fix(bundled-resources): push-down four missing agent personas to
extension bundle").

### Required remediation

1. Push down each missing repo `.claude` file to the bundled extension payload as a
   byte-identical copy:
   - `.claude/hooks/enforce-discovery-artifact-gate.ps1`
     -> `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1`
   - `.claude/hooks/validate-discovery-artifact-gate.ps1`
     -> `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1`
   Use the repository's `.claude` push-down tooling when available; otherwise copy the
   bytes verbatim. Do not modify the repo-root originals.
2. Re-run the contract test module until it passes with no missing-from-bundle assertions.
3. Run the full Python toolchain (Black -> Ruff -> Pyright -> Pytest with coverage) to
   confirm the whole suite is green and coverage thresholds hold (line >= 85%,
   branch >= 75%) with no regression.
4. Commit and push.

### Expected outcome

The contract test passes, the full test suite is green, and PR #384 remains mergeable, so
the S9 CI-green gate and epic-mode merge-on-green can proceed.
