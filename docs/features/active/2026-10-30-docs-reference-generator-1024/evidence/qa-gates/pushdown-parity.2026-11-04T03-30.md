# Push-Down Parity (issue 1024)

Timestamp: 2026-11-04T03-30
Task: [P8-T3]
Command: Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1 (branch-current scripts/powershell/PoshQC/PoshQC.psd1, launched by a sh launcher under SCRATCH); poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: Pester (artifacts/pester/pester-junit.xml): 7 tests, 0 failures, 0 errors. Python: 34 passed, 0 failed (equal to the [P0-T8] baseline of 34 passed). Both run unmodified.

## Pester detail

- Suite: `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` (unmodified).
- JUnit: `tests=7 failures=0 errors=0`.
- The suite asserts that every filtered `.claude/lib/docs` file is listed exactly once in `CORE`, that each has a bundled counterpart, and that the counterparts are byte-identical; it therefore covers the six NEW-MODULES entries of [P8-T2] and the seven bundle copies of [P8-T1].
- CI: the same suite runs in `poshqc / PowerShell QC shard 1` to `shard 3` on `windows-latest`, aggregated by the required check `poshqc / PowerShell QC`.

## Python detail

- `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`: 34 passed, 0 failed.

## CORE insertion point

The last `.claude/lib/docs/` entry in `CORE` after the integration merge is `.claude/lib/docs/templates/page-check/vale/Project/accept.txt`, which is also the final array element. The task excludes insertion after the final element, so the six entries were inserted directly after the last `.claude/lib/docs/` module entry (`.claude/lib/docs/DocsPageCheck.psm1`). The diff from EPIC-BASE shows six added lines and no removed line; no 1020, 1021 or 1023 entry changed. The manifest suites assert membership only, not order.
