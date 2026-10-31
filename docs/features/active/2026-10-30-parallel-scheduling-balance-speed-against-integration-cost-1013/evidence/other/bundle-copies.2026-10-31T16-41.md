# Bundle Copies (refresh after the P9-T6 fix)

Timestamp: 2026-10-31T16-41
Command: poetry run python SCRATCH/issue-1013-bundle-copy.py --copy
EXIT_CODE: 0
Output Summary: twelve sources re-copied after replacing the union-find closure in `.claude/lib/blast-radius/BlastRadiusCombination.psm1`; EQUAL_PAIRS=12/12. Only that pair changed: source and bundle SHA-256 are both `3bf4d7dd2a5224077367dbeabfe2a6a7240783575cf15dbb598bbf835b63c111`. The other eleven pairs equal the record in `bundle-copies.2026-10-31T15-58.md`.
