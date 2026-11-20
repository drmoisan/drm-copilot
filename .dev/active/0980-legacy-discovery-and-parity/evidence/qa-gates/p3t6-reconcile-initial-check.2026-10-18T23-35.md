# P3-T6 initial reconciliation checker

Timestamp: 2026-10-18T23-35
Command: `poetry run python SCRATCH/issue-980-p3t6-final-check.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t6-final-audit.2026-10-18T23-34.json 434`
EXIT_CODE: 1
Output Summary: 542 checks passed; five checks failed because the prepared audit helper compared historical working hashes with normalized Git blobs and restricted approved line-ending comparisons to tests. These are audit bookkeeping findings, not a failed behavioral run. No source or test bytes changed.

The five findings name mutation_plan.py and mutation_io.py for historical API working-versus-index comparison, and mutation_plan.py, mutation_io.py, and references.py for current working-versus-index comparison. `git check-attr --all` reports text=auto and eol=lf for all three production paths; `git ls-files --eol` reports i/lf and w/crlf. The corrected checker must verify exact CRLF-to-LF byte mapping, explicit Git attributes, historical recorded hashes, and executable AST equivalence. All original raw hashes remain preserved in the initial result and final audit.

Raw result: [p3t6-reconcile-initial-check.2026-10-18T23-35.json](p3t6-reconcile-initial-check.2026-10-18T23-35.json).

The complete pass3 behavioral evidence remains unchanged. Acceptance is pending the corrected independent audit; this record does not classify the failed checker as passing.