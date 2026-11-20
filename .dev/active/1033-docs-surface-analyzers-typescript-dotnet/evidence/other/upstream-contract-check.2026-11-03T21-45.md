# Upstream 1020 contract check ([P0-T3])

Timestamp: 2026-11-03T21-45
Command: pwsh -NoProfile -File SCRATCH/issue-1033-p0t3-contract-check.ps1
EXIT_CODE: 0
Output Summary: 35 rows, all PRESENT. Every consumed 1020 module exists; every consumed function is exported after `Import-Module` of its module; `New-DocsSurfaceElement` carries `-AnalysisMethod` and `-SourceText`; `New-DocsDiagnostic` carries `-Severity`, accepts `warning` (blocking `$false`), has no extensions parameter, and returns a record with an `extensions` member; `Invoke-DocsAnalyzer` carries `-ImportModule`; the scanner table and the 1033 anchor are present as exact text; the three suites, the `core.json` entry, and the `quality-tiers.yml` entry exist. Result: PRESENT.

## Rows

| Item | Status |
|---|---|
| module DocsAnalyzerRegistry.psm1 | PRESENT |
| function DocsAnalyzerRegistry.psm1::Get-DocsAnalyzerRegistration exported | PRESENT |
| function DocsAnalyzerRegistry.psm1::Test-DocsAnalyzerRegistration exported | PRESENT |
| function DocsAnalyzerRegistry.psm1::New-DocsCapturedInput exported | PRESENT |
| function DocsAnalyzerRegistry.psm1::Invoke-DocsAnalyzer exported | PRESENT |
| module DocsJson.psm1 | PRESENT |
| function DocsJson.psm1::ConvertFrom-DocsJsonText exported | PRESENT |
| function DocsJson.psm1::ConvertTo-DocsCanonicalJson exported | PRESENT |
| function DocsJson.psm1::Get-DocsSha256Hex exported | PRESENT |
| function DocsJson.psm1::Get-DocsBytesSha256Hex exported | PRESENT |
| module DocsSurface.psm1 | PRESENT |
| function DocsSurface.psm1::Get-DocsElementKind exported | PRESENT |
| function DocsSurface.psm1::Get-DocsAnalysisMethod exported | PRESENT |
| function DocsSurface.psm1::Get-DocsElementId exported | PRESENT |
| function DocsSurface.psm1::ConvertTo-DocsDeclarationText exported | PRESENT |
| function DocsSurface.psm1::Get-DocsDeclarationSha256 exported | PRESENT |
| function DocsSurface.psm1::New-DocsSurfaceElement exported | PRESENT |
| function DocsSurface.psm1::ConvertFrom-DocsSurfaceElement exported | PRESENT |
| function DocsSurface.psm1::New-DocsDiagnostic exported | PRESENT |
| New-DocsSurfaceElement has -AnalysisMethod parameter (C1 analysis-method parameter) | PRESENT |
| New-DocsSurfaceElement has -SourceText parameter | PRESENT |
| New-DocsDiagnostic has -Severity parameter | PRESENT |
| New-DocsDiagnostic -Severity accepts warning (blocking false) | PRESENT |
| New-DocsDiagnostic has no extensions parameter | PRESENT |
| New-DocsDiagnostic returned record carries an extensions member | PRESENT |
| Invoke-DocsAnalyzer has -ImportModule seam | PRESENT |
| registry scanner table `$script:DocsAnalyzerRow` text | PRESENT |
| registry anchor line `# --- 1033: TypeScript and .NET analyzers ---` inside the scanner table | PRESENT |
| registry carries no `# --- 900NNN:` placeholder anchor | PRESENT |
| suite Docs.Manifest.Tests.ps1 | PRESENT |
| suite DocsNeutrality.Tests.ps1 | PRESENT |
| suite DocsAnalyzerRegistry.Tests.ps1 | PRESENT |
| core.json entry `.claude/lib/docs/DocsSurface.psm1` | PRESENT |
| quality-tiers.yml entry `.claude/lib/docs` | PRESENT |

Result: PRESENT

Note: a first run of the check script used a lowercase probe code (`probe-code`) and was rejected by `New-DocsDiagnostic` with `DOCS_IDENTITY_INPUT_INVALID: Code 'probe-code' does not match ^[A-Z][A-Z0-9_]*$.`; the probe was changed to `PROBE_CODE` and the run above is the corrected run. The code grammar is recorded under [P0-T4] row C7.
