# Phase Gate P1

Timestamp: 2026-11-13T20-04
Command: stages 1 to 6 of the toolchain loop over the worktree root: sh SCRATCH/issue-1169-static.sh p1 (check-only Invoke-PoshQCFormat with a no-op WriteFile seam, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on every PoshQC file); sh SCRATCH/issue-1169-pytest.sh p1 (env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing); sh SCRATCH/issue-1169-pester.sh p1 (one Invoke-PoshQCParallelTest); sh SCRATCH/issue-1169-leak.sh (Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary:
- Stage 1 format (PowerShell, 1551 files, check-only): 0 files would change; exit 0.
- Stage 2 lint (PSScriptAnalyzer 1.25.0, 1551 files): 0 findings; exit 0.
- Stage 3 type check: not applicable to PowerShell; no Python or TypeScript file changed.
- Stage 4 architecture-boundary tests and stage 6 contract checks: run inside the pytest gate (push-down resource, pack-manifest, dependency-closure, and brief contract tests under tests/scripts/dev_tools) and the Pester gate (claude-runtime contract suites); all passed.
- Stage 5 unit tests, Pester: one Invoke-PoshQCParallelTest run, 8 shards all exit 0; 21708 tests, 21698 passed, 0 failed, 10 skipped; repo-wide line coverage 95.83% (37853/39500). Per-file: .claude/hooks/hook-docs-only-diff.ps1 98.46% (128/130), .codex/hooks/hook-docs-only-diff.ps1 97.69% (127/130), .claude/lib/docs/DocsProfileCommands.psm1 97.33% (73/75), .claude/lib/docs/DocsReceiptRevision.psm1 100.00% (40/40).
- Stage 5 unit tests, pytest: one pytest -n auto run; 16598 passed, 0 failed, 6 skipped; line 97.11% (34334/35355), branch 94.37% (12668/13424).
- Leak scan: 753 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures; exit 0.
- One clean pass; no stage failed or changed a file, so no restart was needed.
