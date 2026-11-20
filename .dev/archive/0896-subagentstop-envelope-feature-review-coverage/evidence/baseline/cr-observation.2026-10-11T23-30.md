# CR Observation Run (P0-T23; success-output observation rule)

Timestamp: 2026-10-11T23-58
Command: scratchpad route, in order: CR-PARSE (<LIST> = LIST-PROD-BASE plus T5; <IT-PATTERNS> = T824-*); CR-TEXT (<CHECKS> = @{ Path = '.claude/hooks/validate-feature-review-coverage.ps1'; Present = @("ReasonPrefix 'validate-feature-review-coverage:'"); Absent = @('subagentstop-envelope.ps1') }); CR-JSON (<MANIFEST> = extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json; <ENTRIES> = .claude/hooks/validate-feature-review-coverage.ps1); CR-SHA (<PAIRS> = the H4 pair); CR-MIRROR (same pair, run because the CR-SHA line ended MATCH) with git status --porcelain before and after
EXIT_CODE: 0
Output Summary: CR-PARSE PARSE-ERROR-COUNT: 0 and IT-COUNT: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | T824-* | 1; CR-TEXT TEXT-CHECK-FAILURES: 0; CR-JSON JSON-PARSE: ok | paths=217, JSON-MISSING-COUNT: 0; CR-SHA SHA-DIFFER-COUNT: 0; CR-MIRROR COPY-DIFFER-COUNT: 0; status before and after CR-MIRROR identical. Every named success-case literal was observed.

## CR-PARSE

```
PARSE: .claude/hooks/validate-feature-review-coverage.ps1 | errors=0 | functions=Get-ArtifactFileContent,Get-ChangedLanguageSet,Get-JacocoBranchCoverage,Get-JacocoRepoCoverage,Get-LanguageBranchCoverage,Get-LanguageRepoCoverage,Get-LcovBranchCoverage,Get-LcovRepoCoverage,Get-ReviewArtifactInfo,Get-ReviewArtifactPathFromOutput,Invoke-FeatureReviewCoverageValidation,Test-LanguageCoverageRow
IT-COUNT: .claude/hooks/validate-feature-review-coverage.ps1 | T824-* | 0
PARSE: .claude/hooks/feature-review-coverage-thresholds.ps1 | errors=0 | functions=Get-FeatureReviewCoverageThreshold
IT-COUNT: .claude/hooks/feature-review-coverage-thresholds.ps1 | T824-* | 0
PARSE: .codex/hooks/validate-feature-review-coverage.ps1 | errors=0 | functions=Get-ChangedLanguageSet,Get-FeatureReviewCoverageContinuation,Get-JacocoRepoCoverage,Get-LanguageRepoCoverage,Get-LatestPolicyAudit,Get-LcovRepoCoverage,Get-RepoRoot,Test-LanguageCoverageRow
IT-COUNT: .codex/hooks/validate-feature-review-coverage.ps1 | T824-* | 0
PARSE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | errors=0 | functions=
IT-COUNT: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | T824-* | 1
PARSE-ERROR-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-TEXT

```
TEXT-FILE: .claude/hooks/validate-feature-review-coverage.ps1 | exists=True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage.ps1 | ReasonPrefix 'validate-feature-review-coverage:' | True
TEXT-ABSENT: .claude/hooks/validate-feature-review-coverage.ps1 | subagentstop-envelope.ps1 | True
TEXT-CHECK-FAILURES: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-JSON

```
JSON-PARSE: ok | paths=217
JSON-HAS: .claude/hooks/validate-feature-review-coverage.ps1 | True
JSON-MISSING-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-SHA

```
SHA: .claude/hooks/feature-review-coverage-thresholds.ps1 | 9BC0E932926D0DF7624D5F13B46A4669E00315DC56DE79D16E6AEA62A530C587 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1 | 9BC0E932926D0DF7624D5F13B46A4669E00315DC56DE79D16E6AEA62A530C587 | MATCH
SHA-DIFFER-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-MIRROR

```
COPIED: .claude/hooks/feature-review-coverage-thresholds.ps1 | 9BC0E932926D0DF7624D5F13B46A4669E00315DC56DE79D16E6AEA62A530C587 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1 | 9BC0E932926D0DF7624D5F13B46A4669E00315DC56DE79D16E6AEA62A530C587 | MATCH
COPY-DIFFER-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## git status --porcelain before CR-MIRROR

```
 M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/upstream-merge-check.2026-10-11T23-30.md
```

## git status --porcelain after CR-MIRROR

```
 M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/upstream-merge-check.2026-10-11T23-30.md
```
