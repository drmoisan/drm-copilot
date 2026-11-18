# Leak scan (P3-T3)

Timestamp: 2026-11-18T05-43
Command: Invoke-PoshQCLeakScan -Root <worktree root> after importing scripts/powershell/PoshQC/PoshQC.psd1 (launcher route of the execution-environment skill: a `sh` helper under SCRATCH starts pwsh; the scan throws on any failure)
EXIT_CODE: 0
Output Summary: `Leak scan: 862 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures.` The helper printed its completion line (the scan did not throw), so the exit code is 0. `config/poshqc-leak-allowlist.json` is unmodified (`git status --porcelain -- config` lists only the new `config/npm-audit-exceptions.json` from earlier commits, which are already committed, so nothing under config is modified or untracked), hence no new allowlist entry. The warning that `tests/powershell` does not exist under the root comes from the scan configuration and predates this change.
