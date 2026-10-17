# Baseline Line Counts (P0-T4)

Timestamp: 2026-10-09T02-51
Command: poetry run python -c "[print(p, len(open(p, encoding='utf-8').read().splitlines())) for p in [<the eleven P0-T4 paths, in plan order>]]"
EXIT_CODE: 0
Output Summary: eleven lines, each with an integer; all at most 500. These are the comparison values for P1-T7, P2-T2, P3-T2, and P8-T2.

## Deviation (PowerShell route denied)

The plan counts with `@(Get-Content -LiteralPath $p).Count` in the PowerShell tool; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). `len(str.splitlines())` returns the same count as `Get-Content` for files that end with a newline. The same command is used at P8-T2 so the comparison is like for like.

## Output

```text
scripts/dev_tools/_blast_radius_extraction.py 475
scripts/dev_tools/_blast_radius_token_shapes.py 144
.claude/lib/blast-radius/BlastRadiusExtraction.psm1 474
.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 189
tests/scripts/dev_tools/test_blast_radius_extraction.py 462
tests/scripts/dev_tools/test_blast_radius_extraction_rules.py 225
tests/scripts/dev_tools/test_blast_radius_token_shapes.py 146
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 460
tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 197
tests/scripts/dev_tools/test_blast_radius_verification_integrity.py 273
tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 409
```
