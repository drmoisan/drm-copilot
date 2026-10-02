# Baseline Full PowerShell Suite (P0-T4)

Timestamp: 2026-10-02T07-45
Command: CI-evidence deviation DEV-P0-T4 (replaces FR args '.', 'baseline-run.log' and JX args '.'). Source: workflow CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380 (push to main at 71f8dcb49d8ce5d1402ff441855a64be15b37f29), job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219, which runs `Invoke-PoshQCTest -Root <CI_ROOT>` with the repository copy of PoshQC; artifact `poshqc-test-results` (pester-junit.xml) reduced by the orchestrator with `poetry run python artifacts/ci/ci_evidence.py jx artifacts/ci/run-36978425380/pester-junit.xml` (Python port of rule JX; git-ignored scratch tool) into artifacts/ci/run-36978425380/jx.txt, read with the Read tool.
EXIT_CODE: 0
Output Summary: TESTS=6499 FAILURES=0 ERRORS=0 DISABLED=10
- EXIT_CODE is the CI job conclusion (success); the job fails on any Pester failure.
- Measured tree: the branch head 589b51a3 differs from 71f8dcb4 only under docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/ (`git diff --name-only 71f8dcb4 HEAD` lists only that folder), so the PowerShell tree measured by CI is identical to the branch baseline.
- Acceptance: EXIT_CODE 0 and the JX line shows FAILURES=0 ERRORS=0. Met.
