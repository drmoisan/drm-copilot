# Leak Scan and Generator Check (P9-T9)

Timestamp: 2026-11-17T11-22
Command: sh SCRATCH/issue-1035-p9t9-run.sh from the worktree root: pwsh -NoProfile -File on a runtime script that imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCLeakScan -Root <worktree root>` (allowlist config/poshqc-leak-allowlist.json; the scan throws on any failure, so the launcher exits non-zero), then `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary: Leak scan "865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures.", exit 0; the scan also warned that the configured scan folder `tests/powershell` does not exist under the root and was skipped (configuration of config/poshqc-scan.json, unchanged by this branch). No finding needed a fix, so P9-T8 did not re-run for this task. Codex agent variant generator check: exit 0, no drift output.

| Check | EXIT_CODE | Result |
| --- | --- | --- |
| Invoke-PoshQCLeakScan -Root | 0 | 865 files, 78 findings: 76 exempt, 2 allowlisted, 0 failures |
| generate_codex_agent_variants --check | 0 | no drift |
