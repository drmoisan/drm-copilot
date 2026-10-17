# Phase 0 Instructions Read (Issue #847)

Timestamp: 2026-10-09T23-46
Task: [P0-T1]
Plan: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md` (revision 1.1)
Execution amendment: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (read before execution; binding verification-route substitution)

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`

Files read (in order):
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md`
7. `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/research/research.2026-10-08T23-50.md`

Additional context read (not part of the policy order): `.claude/rules/tonality.md`; the plan file; the execution amendment; the BASE5 source files `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/bootstrap-host.helpers.ps1`, `scripts/dev-tools/verify-host.ps1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`, `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`.

Key obligations extracted:
- 500-line limit for every production and test file.
- Line coverage >= 85% uniform across tiers; no branch-coverage gate for PowerShell (Pester); no production coverage exclusions.
- No temporary files in tests; all host I/O mocked.
- PowerShell toolchain order: format, analyze, test (type checking not applicable).
- Wrapper-function seam pattern; mock wrappers, not executables; mock signatures match production parameter names.

Not-applicable stages: type checking (not applicable to PowerShell), architecture-boundary tests (no architecture-boundary tooling covers these PowerShell dev-tools files), contract/schema checks (no host-service contract or schema boundary in these files), and integration tests (no adapter interacts with an external system under test; all host seams are mocked) are not applicable to these PowerShell files, per spec Test Strategy ("architecture, contract, and integration stages are not applicable to these files and are recorded as such").
