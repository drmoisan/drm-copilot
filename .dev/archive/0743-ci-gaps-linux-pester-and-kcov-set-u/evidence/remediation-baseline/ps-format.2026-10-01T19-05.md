# PowerShell Format Baseline (P0-T13)

Timestamp: 2026-10-01T19-05

Command: git status --porcelain (pre-pass)
EXIT_CODE: 0
Output Summary: three untracked entries under `<FEATURE>/` (linux-baseline-junit artifact, evidence/remediation-baseline/, the plan file).

Command: sha256sum over the five P0-T8 files (pre-pass)
EXIT_CODE: 0
Output Summary:
```
fa59ee5c37f3ff8a52c75bdd3b1e2bad01ee22abe1770f369515ad91a7a2ece2 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
95ea2758d9e0b212ad8f2d642a4d0d25aa32a8de8ae0073987a54cfe71b13b4e tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
04c658f1fa70274bfc9a8490dfaf3cbdb54969094ba49f0618916f661d3f4854 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
848d563795702bfed5567b1b9ddcb22caff2f19ffe423393e53926a4b0f8db7d tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
d6ad2be401897317f684a901e59560143b9c1d08f70aa490a8906f05fcd5f336 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
```

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = item worktree)
EXIT_CODE: 0
Output Summary: `ok: true`. The tool returns no per-file counts; none is asserted.

Command: git status --porcelain (post-pass)
EXIT_CODE: 0
Output Summary: identical to the pre-pass listing.

Command: sha256sum over the five P0-T8 files (post-pass)
EXIT_CODE: 0
Output Summary: all five hashes identical to the pre-pass hashes.

Acceptance: ok true; porcelain unchanged; hashes unchanged (the formatter changed no tracked file). Met.
