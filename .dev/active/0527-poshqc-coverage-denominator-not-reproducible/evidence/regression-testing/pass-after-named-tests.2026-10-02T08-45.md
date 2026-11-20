# Pass-After: Fail-First Named Tests in Run A (P6-T6)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P6-RUNS (replaces the `[xml]` JUnit expression in a `pwsh` child). Source: run A JUnit, https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194; reduced with `poetry run python artifacts/ci/ci_evidence.py named artifacts/ci/run-36983551836/pester-junit.xml "measures an identical population for the repository and bundled settings copies over the same workspace;measures only the consumer production file when a stale bundled allow-list names pushed-down files;logs the population source and file count before Pester runs"` (named.txt; the executor's 23-title re-run this segment printed the same three lines).
EXIT_CODE: 0
Output Summary: each of the three lines shows CASES=1 FAILED=0.

```text
measures an identical population for the repository and bundled settings copies over the same workspace CASES=1 FAILED=0 SKIPPED=0
measures only the consumer production file when a stale bundled allow-list names pushed-down files CASES=1 FAILED=0 SKIPPED=0
logs the population source and file count before Pester runs CASES=1 FAILED=0 SKIPPED=0
```

- These three tests failed on their assertions against the pre-fix code (P2-T4).
- Acceptance: each of the three lines shows `CASES=1 FAILED=0`. Met.
