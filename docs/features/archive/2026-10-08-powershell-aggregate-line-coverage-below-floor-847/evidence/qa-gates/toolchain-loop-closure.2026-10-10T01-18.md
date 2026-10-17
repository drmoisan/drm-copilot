# Toolchain Loop Closure (Issue #847, AC-11)

Timestamp: 2026-10-10T01-18
Task: [P7-T14]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md`, the hash observation uses `git hash-object` (in place of SHA256 `Get-FileHash`), and the format, analyze, and test stages use the MCP calls plus CI run 38011932558 as recorded in the cited artifacts.
Command: `git hash-object <the 19 CPFS paths in plan order>` (recomputed after P7-T3 through P7-T13), compared element by element with the list recorded at the start of P7-T1.
EXIT_CODE: 0
Output Summary:
- Stage artifacts from the same pass (loop iteration 1):
  - Format: `evidence/qa-gates/pwsh-format.2026-10-10T01-18.md` (PASS; MCP `ok: true`; CI 19 `Already formatted:`, 0 `Formatted:`; UNCHANGED_HASHES=19)
  - Analyze: `evidence/qa-gates/pwsh-analyze.2026-10-10T01-18.md` (PASS; MCP `ok: true`; CI `PSScriptAnalyzer passed: no findings`; 19 lines `errors=0 warnings=0`)
  - Test: `evidence/qa-gates/pwsh-test-full.2026-10-10T01-18.md` (PASS; FULL_RUN valid; tests=6709 failures=0 errors=0)
- UNCHANGED_HASHES=19 recomputed after P7-T3: all 19 CPFS `git hash-object` values equal the P7-T1 start-of-pass list (and the HEAD `1c3d1a4c6` blobs measured by CI run 38011932558).
- Loop iterations: 1 (no stage rewrote a file, reported a finding, or failed; no restart).
- Not applicable stages (spec Test Strategy; also recorded in `evidence/baseline/phase0-instructions-read.md`): type checking (no type checker exists for PowerShell; the rule's stage 3 is skipped for PowerShell), architecture-boundary tests (no architecture-boundary tooling covers `scripts/dev-tools`), contract/schema compatibility checks (no host-service contract or schema boundary changes), integration tests (the scripts are host-provisioning tools whose real execution is excluded by the plan's No-host-execution rule; all host seams are mocked in unit tests).
- Result: PASS (AC-11, local part). PR CI on the final head is AC-15 and is decided in a later stage.
