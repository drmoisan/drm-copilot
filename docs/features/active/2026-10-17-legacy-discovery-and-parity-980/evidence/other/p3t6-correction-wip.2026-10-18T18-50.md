# P3-T6 checked correction WIP

Status: frozen for a progress commit; task acceptance remains pending.

The unchanged-production forward suite passed 430/430 in 784.00 seconds, then failed the references.py per-file baseline coverage comparison. Reverse, contracts and integration were not run. The approved new isolated test file adds four physical/source selection cases, passing in 0.22 seconds. It directly executes line 243 and arc 242 to 243. The same-source diagnostic coverage union is 169/171 lines (98.830409%) and 82/84 arcs (97.619048%), above accepted 152/154 and 74/76. This union is preparation evidence, not a substitute for the next full ordered gate.

Black, Ruff and full Pyright pass on all ten paths. The existing nine paths, including all production and consumed fixtures, remain byte-identical to pass2. All files have required class/function docstrings and explicit-loop comments, no suppressions were introduced, maximum size is 489 lines, and 251 unaffected accepted plus 24 frozen paths remain unchanged. The earlier one-line lint failure is retained.

The next required full population is 434; all seven stages and final index/evidence acceptance remain pending. Exact hashes, raw coverage, binding and command status: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-correction-wip.2026-10-18T18-50.json
