# PowerShell Owner Reconciliation Baseline

Timestamp: 2026-08-14T23-28
Command: Parse the 25-owner matrix in `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md` and compare its six remediated modified-owner paths with class-source attribution in `artifacts/pester/powershell-coverage.xml`.
EXIT_CODE: 0
Output Summary: The authoritative prior receipt retains 25/25 owner attribution, 17/17 added owners at or above 90%, and 8/8 modified owners meeting their thresholds. The supplemental 46-source bundled report omits all six remediated modified owners and cannot replace that owner-attributed result.

## Authoritative Owner Result

- Attributed owners: `25/25`
- Added owners at or above 90%: `17/17`
- Modified owners meeting their applicable line thresholds: `8/8`
- Added-owner minimum: `90.000000%`
- Modified-owner minimum: `80.888889%`
- Combined owner lines: `2,646/2,934 = 90.184049%`
- Authoritative repository lines: `6,529/7,035 = 92.807392%`
- Authoritative source: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`

## Six Owners Omitted from the Supplemental Bundled Report

Each path below has zero matching class-source entries in the 46-source bundled XML:

- `.codex/hooks/codex-authority-store.ps1` — authoritative value `49/58 = 84.482759%`
- `.codex/hooks/enforce-codex-model-routing.ps1` — authoritative value `68/79 = 86.075949%`
- `.codex/hooks/record-subagent-routing-attestation.ps1` — authoritative value `186/229 = 81.222707%`
- `.codex/hooks/validate-codex-subagent-routing.ps1` — authoritative value `76/86 = 88.372093%`
- `.codex/scripts/launch-epic-child-wave.ps1` — authoritative value `182/225 = 80.888889%`
- `.codex/scripts/resume-epic-child.ps1` — authoritative value `156/178 = 87.640449%`

The supplemental bundled report remains valid only for its own 46-source, `4,040/4,260 = 94.835681%` line scope. It does not establish coverage for the six omitted owners and does not alter the authoritative 25-owner matrix.
