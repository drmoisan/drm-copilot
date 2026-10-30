# P2-T8 corrected parity behavior, pending final byte binding

Timestamp: 2026-10-18T10:13:27Z

Command: `poetry run python SCRATCH/issue-980-probe-p2t8.py`

EXIT_CODE: 1

Output Summary: All 53 independent cases passed. The command deliberately returned nonzero because production hashes changed while the specialist continued formatting/type preparation. The initial and final hashes are retained in `p2t8-executor-corrected-probes.2026-10-18T10-13.json`; this run is not final byte-bound acceptance evidence.

All four consolidated defect regressions pass. Positive controls confirm that separately passing implementations can divide required mode coverage and that a configured imported historical source can support a distinct local target. The executor will rerun this same bounded set once the specialist freezes final source bytes. No additional semantic scope, production edits or task checkoff follows from this preliminary result.
