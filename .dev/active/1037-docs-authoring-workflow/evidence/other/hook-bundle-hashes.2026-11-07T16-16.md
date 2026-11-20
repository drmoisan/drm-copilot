# Hook Bundle Hashes (P2-T3)

Timestamp: 2026-11-07T16-16
Command: sh SCRATCH/issue-1037-copy-hooks.sh (`cp` of each hook to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, then `sha256sum` of source and copy)
EXIT_CODE: 0
Output Summary: Three byte copies made by a copy step (no Write or Edit call); all three SHA-256 pairs are equal.

| Source | SHA-256 (source = copy) | Result |
|---|---|---|
| `.claude/hooks/docs-role-contract.ps1` | `95980657e122ae3b51888069bc9828430ec3440247734ddec30ba1b3ee0623fa` | EQUAL |
| `.claude/hooks/validate-docs-role-output.ps1` | `7efdb0dd43c7fd8ac937e9d68be1919bae703f02aba743b2fca0ffee3b70739f` | EQUAL |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | `6c3efc2c96a938c654f8f3b9566e983aae1661cca254ad2432251a6209e8ef4c` | EQUAL |
