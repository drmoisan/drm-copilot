# P5-T2 retained parity outcome freeze

Timestamp: 2026-10-20T06-25

Command: poetry run python SCRATCH/freeze_outcomes.py

EXIT_CODE: 0

Output Summary: Black, Ruff and scoped Pyright passed; 91 scoped cases passed in 11.98 seconds (13.745 seconds harness), preserving all 77 existing cases.

The three runtime modules and one new test module are frozen. Carriers cover 35/35 statements; main rules 104/104 statements and 38/38 branches; extracted entry rules 137/139 statements and 53/56 branches. Every measured class/callable exceeds the 90% line floor. Two defensive guard statements remain unexecuted and are identified in the manifest; unchanged TargetProof retains its accepted 99/99 and 48/50 proof.

The manifest binds exact source bytes, original diagnostics, ordered receipts, raw/portable coverage and the accepted baseline. The sibling Markdown heading change does not affect consumed ReportBudget or ReportLimitError definitions. Only the outcome subset is ready for independent review; graph integration and full task acceptance remain pending.
