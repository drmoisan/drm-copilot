# Coverage Applicability

Timestamp: 2026-10-09T20-56
Command: git fetch origin main ; git diff --name-only origin/main...HEAD -- src scripts extensions ; git status --porcelain -- src scripts extensions
EXIT_CODE: 0
Output Summary: Both outputs are empty; no production file changed.

ChangedProductionFiles:

- `git diff --name-only origin/main...HEAD -- src scripts extensions`: (empty)
- `git status --porcelain -- src scripts extensions`: (empty)

BaselineCoverageScopeArtifact: docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-coverage-scope.md
NewOrChangedCodeCoverage: not applicable - no production line changed; tests/* is omitted from coverage measurement (pyproject.toml line 123)
Verdict: PASS
