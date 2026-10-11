# File-Size Limit (P8-T2, AC-19)

Timestamp: 2026-10-09T04-40
Command: poetry run python -c "[print(p, len(open(p, encoding='utf-8').read().splitlines())) for p in [<the eleven P0-T4 paths, in plan order>]]" (the same command as P0-T4)
EXIT_CODE: 0
Output Summary: eleven lines, same paths and order as P0-T4; every count is at most 500. The Python extraction module is 468 (P0-T4: 475) and the PowerShell extraction module is 464 (P0-T4: 474), neither above baseline. The PowerShell path test file is 460, equal to its P0-T4 count.

## Output

```text
scripts/dev_tools/_blast_radius_extraction.py 468
scripts/dev_tools/_blast_radius_token_shapes.py 218
.claude/lib/blast-radius/BlastRadiusExtraction.psm1 464
.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 267
tests/scripts/dev_tools/test_blast_radius_extraction.py 466
tests/scripts/dev_tools/test_blast_radius_extraction_rules.py 313
tests/scripts/dev_tools/test_blast_radius_token_shapes.py 213
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 460
tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 357
tests/scripts/dev_tools/test_blast_radius_verification_integrity.py 273
tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 409
```
