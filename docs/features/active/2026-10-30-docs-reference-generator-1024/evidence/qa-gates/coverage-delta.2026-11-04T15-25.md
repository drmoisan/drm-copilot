# Coverage Delta (issue 1024, remediation cycle 1)

Timestamp: 2026-11-04T15-25
Task: [P3-T4]
Command: compare evidence/remediation-baseline/pester-docs.2026-11-04T14-48.md with evidence/qa-gates/pester-docs.2026-11-04T15-25.md; then pwsh -NoProfile -File SCRATCH/issue-1024-ast-cov.ps1 (parses .claude/lib/docs/DocsReferenceFrontMatter.psm1 with the PowerShell AST, takes the body extents of the two functions, and reads the `line` entries of the DocsReferenceFrontMatter.psm1 source-file element in artifacts/pester/powershell-coverage.xml inside each extent)
EXIT_CODE: 0
Output Summary: DocsReferenceFrontMatter.psm1 100% before (77/77) and 100% after (90/90), at least 85 and not below baseline. Invoke-DocsCommand.ps1 87.82% before (137/156) and 87.82% after (137/156), not below baseline. Changed code: 12 instruction-bearing lines in Test-DocsReferenceCanonicalNumberRejected and 10 in ConvertTo-DocsReferenceFrontMatterText, none with zero covered instructions. Pester measures no branch coverage, so no branch gate applies.

| File | Baseline | Post-change | Changed-code result |
|---|---|---|---|
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | 100% (77/77) | 100% (90/90) | 22 of 22 instruction-bearing lines in the two function bodies covered |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 87.82% (137/156) | 87.82% (137/156) | not changed in this cycle |

## AST mapping output

- `FUNCTION Test-DocsReferenceCanonicalNumberRejected instruction-lines=12 zero-covered=0`
- `FUNCTION ConvertTo-DocsReferenceFrontMatterText instruction-lines=10 zero-covered=0`

The 19 uncovered lines of `Invoke-DocsCommand.ps1` are the same set before and after the change.
