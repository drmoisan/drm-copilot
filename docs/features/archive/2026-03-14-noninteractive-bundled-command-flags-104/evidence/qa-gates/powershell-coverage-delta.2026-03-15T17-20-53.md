Baseline Coverage:
- 42.98% (`evidence/baseline/powershell-test.2026-03-14T23-24.md`)

Final Coverage:
- 42.76% (`evidence/qa-gates/powershell-test.2026-03-15T00-21-26.md`)

Changed/New PowerShell Coverage:
- 84.34% (70/83 covered lines for changed production PowerShell file `scripts/dev-tools/new-potential-entry.ps1`, derived from the final `artifacts/pester/powershell-coverage.xml` `LINE` counters for `sourcefilename="new-potential-entry.ps1"`)

Threshold Check:
- PASS WITH NOTE — no planned PowerShell command task was skipped; overall PowerShell coverage changed by -0.22 percentage points from baseline while the changed production PowerShell file remained above 80% line coverage and the new template-root behavior is exercised by `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` and `tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1`.

Coverage Source Artifact:
- `artifacts/pester/powershell-coverage.xml` (final QA run), corroborated by `evidence/baseline/powershell-test.2026-03-14T23-24.md` and `evidence/qa-gates/powershell-test.2026-03-15T00-21-26.md`

No planned command task skipped: true
