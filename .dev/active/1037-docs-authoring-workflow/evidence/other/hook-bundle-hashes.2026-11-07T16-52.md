# Hook Bundle Hashes (P2-T3 copy repeated after the P7-T2 fixes)

Timestamp: 2026-11-07T16-52
Command: sh SCRATCH/issue-1037-copy-hooks.sh (`cp` of each hook to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, then `sha256sum` of source and copy)
EXIT_CODE: 0
Output Summary: Three byte copies made by a copy step; all three SHA-256 pairs are equal. Supersedes `hook-bundle-hashes.2026-11-07T16-16.md` for `docs-role-contract.ps1` and `enforce-docs-role-write-scope.ps1`, whose sources changed in the [P7-T2] analyzer fixes.

| Source | SHA-256 (source = copy) | Result |
|---|---|---|
| `.claude/hooks/docs-role-contract.ps1` | `4c85a5d1082cd8c133bc539c58fdbfdbece80d35152aeae48654dbd1e77e2661` | EQUAL |
| `.claude/hooks/validate-docs-role-output.ps1` | `7efdb0dd43c7fd8ac937e9d68be1919bae703f02aba743b2fca0ffee3b70739f` | EQUAL |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | `facc01b648552e5b7756c7e3f4461d280560ab3c434b50122957f1c8c180e20e` | EQUAL |
