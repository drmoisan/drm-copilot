# Python Coverage Comparison ([P8-T6])

Timestamp: 2026-09-26T22-24

Command:
1. `poetry run coverage json --data-file=artifacts/.coverage --include="*/pr_context/render_pr_helpers.py,*/pr_context/autoclose.py,*/pr_context/collector.py" --pretty-print -o artifacts/python/coverage-588-final.json` (the [P8-T5] command)
2. `git diff -U0 b67453837646fd2dd4f5ac692f76e6f7703fe798 -- scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/autoclose.py scripts/dev_tools/pr_context/collector.py`

EXIT_CODE:
1. 0
2. 0

Output Summary:
- Test selection, baseline and final: `poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (identical in [P0-T18] and [P8-T4]).
- Per-file line / branch, baseline ([P0-T19]) -> final ([P8-T5]):
  - `render_pr_helpers.py` (edited): 96.15% (125/130) / 95.31% (61/64) -> 96.21% (127/132) / 95.45% (63/66). No decrease.
  - `collector.py` (not edited): 93.45% / 84.00% -> 93.45% / 84.00%.
  - `autoclose.py` (not edited): 100.00% / 100.00% -> 100.00% / 100.00%.
- Final `TOTAL` row: `TOTAL                                                      1610    112    642     80    90%` (baseline `1608 112 640 80 90%`).
- Diff hunks: only `render_pr_helpers.py` (PY_BUILDER_STATE PARAM-ONLY); none in `collector.py` (PY_CALLSITE PRESENT) or `autoclose.py`.
- Added lines (`+` side): 259, 260, 261 (docstring text, not executable statements); 288 (`elif not gh_available:`), 289, 290 (comments), 291 (`body = ...`). `files["scripts\\dev_tools\\pr_context\\render_pr_helpers.py"]["missing_lines"]` = `[68, 93, 94, 95, 141]`; none of the added lines appears in it. Acceptance met.
