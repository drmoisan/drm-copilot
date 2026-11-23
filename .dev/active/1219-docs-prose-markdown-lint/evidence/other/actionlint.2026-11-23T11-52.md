# actionlint Over the Workflow Template (P4-T1)

Timestamp: 2026-11-23T11-52
Command: sh SCRATCH/issue-1219-actionlint.sh (PowerShell 7 launched from the script file: downloads actionlint_1.7.12_windows_amd64.zip and actionlint_1.7.12_checksums.txt from https://github.com/rhysd/actionlint/releases/download/v1.7.12/, verifies the asset SHA-256 against the checksums file with an ordinal comparison before extraction, then runs `actionlint -no-color .claude/lib/docs/templates/_docs-quality.yml` from the worktree root)
EXIT_CODE: 0
Output Summary:
- Asset verification: expected SHA-256 6e7241b51e6817ea6a047693d8e6fed13b31819c9a0dd6c5a726e1592d22f6e9 (from the release checksums file), actual 6e7241b51e6817ea6a047693d8e6fed13b31819c9a0dd6c5a726e1592d22f6e9; match.
- Version: `actionlint -version` printed `1.7.12` (installed by downloading from release page; built with go1.26.1 for windows/amd64).
- actionlint over .claude/lib/docs/templates/_docs-quality.yml: exit code 0; 0 findings (no output lines).
