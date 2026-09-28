# Python Coverage Comparison and Changed-Line Coverage — [P8-T6]

Timestamp: 2026-09-26T20-24
Loop iteration: 1
Command: git diff -U0 ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- scripts/dev_tools/pr_context/models.py scripts/dev_tools/pr_context/feature_docs.py scripts/dev_tools/pr_context/render_feature_excerpts.py scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/collector.py
EXIT_CODE: 0
Output Summary:
Scope anchor: ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 ([P0-T5]). Baseline from [P0-T19]; final from [P8-T5]. The diff printed 28 hunks.

Per-file baseline -> final (line %, branch %):
- models.py: 99.19% -> 99.21% line; 92.86% -> 92.86% branch (no decrease)
- feature_docs.py: 93.45% -> 93.45% line; 86.96% -> 86.96% branch (no decrease)
- render_feature_excerpts.py: 83.33% -> 86.11% line; 69.44% -> 75.00% branch (increase; now meets both floors)
- render_pr_helpers.py: 94.49% -> 96.15% line; 91.67% -> 95.31% branch (no decrease)
- collector.py: 93.55% -> 93.45% line; 86.36% -> 84.00% branch. Relocation: the reference-classification loop and pending-primary handling moved out of collector.py into autoclose.py (spec D7), which removed covered statements and branches from this file's denominator. Final values meet the floors (93.45% >= 85.00% line; 84.00% >= 75.00% branch).
- New code, autoclose.py: 45/45 = 100.00% line; 16/16 = 100.00% branch (floors 85.00% / 75.00% met).

Added lines (+ side of every hunk) versus the file-level `files[<path key>]["missing_lines"]` list of python-coverage-final.json. Tags: `executed` = in executed_lines; `non-exec` = neither executed nor missing (comments, docstrings, blank or continuation lines); `MISSING` = in missing_lines.
  - scripts/dev_tools/pr_context/collector.py: 9:executed, 195:executed, 196:non-exec, 197:non-exec, 198:non-exec, 199:non-exec, 200:non-exec, 201:non-exec, 202:non-exec, 203:non-exec, 204:non-exec, 239:executed, 240:non-exec, 241:non-exec, 244:non-exec, 246:non-exec, 247:non-exec, 250:executed, 253:non-exec, 254:non-exec, 256:executed, 257:executed
  - scripts/dev_tools/pr_context/feature_docs.py: 7:executed, 35:non-exec, 36:non-exec, 37:non-exec, 38:non-exec, 39:non-exec, 40:non-exec, 43:executed, 46:non-exec
  - scripts/dev_tools/pr_context/models.py: 25:non-exec, 26:executed, 27:non-exec, 28:executed, 29:non-exec, 30:non-exec, 31:non-exec, 32:non-exec, 33:executed, 34:non-exec, 35:non-exec
  - scripts/dev_tools/pr_context/render_feature_excerpts.py: 9:executed, 26:non-exec, 27:non-exec, 28:non-exec, 29:non-exec, 30:non-exec, 33:executed, 36:non-exec
  - scripts/dev_tools/pr_context/render_pr_helpers.py: 10:non-exec, 11:non-exec, 13:non-exec, 104:non-exec, 105:non-exec, 106:non-exec, 107:non-exec, 108:non-exec, 111:executed, 114:non-exec, 217:non-exec, 218:non-exec, 219:executed, 220:executed, 242:non-exec, 243:non-exec, 256:non-exec, 257:non-exec, 258:non-exec, 259:non-exec, 260:non-exec, 261:non-exec, 278:non-exec, 279:non-exec, 280:non-exec, 283:executed, 284:executed, 285:executed, 286:executed
Result: 20 added executable lines across the five files; none is in missing_lines. No per-file percentage decreased for a file that received no relocated-out code. PASS.
