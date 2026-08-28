# Phase 4 — Python Collector Module Size After Extraction

Timestamp: 2026-08-28T12-47

Task: [P4-T1]

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath scripts/dev_tools/pr_context/collector.py).Count"` (working directory: repository root)

EXIT_CODE: 0

The recorded exit code is the exit code of the `pwsh` command itself, captured directly and not
from a pipeline tail.

## Output Summary

The command printed the integer:

```
474
```

`scripts/dev_tools/pr_context/collector.py` is **474 lines**, at or below the 500-line limit. At
baseline (`[P0-T14]`) it was **623 lines**, a pre-existing overage of 123 lines. The extraction
removed 149 lines net.

## Blocks moved into `scripts/dev_tools/pr_context/collector_documents.py`

The plan's first-listed set was sufficient; no block from the contingency list needed to be
relocated.

1. The two character-budget constants `SUMMARY_CHAR_BUDGET` and `APPENDIX_CHAR_BUDGET`, which the
   two assembly blocks truncate against.
2. `_render_verification_evidence_section`, moved and renamed to the public
   `render_verification_evidence_section`.
3. The feature-summary assembly, moved as `build_feature_summary`.
4. The summary-document assembly, moved as `build_summary_document`. This carries the
   `intent_block` construction, the `summary_sections` list, the stale-base WARNING branch, and
   the summary truncation.
5. The appendix-document assembly, moved as `build_appendix_document`. This carries the feature
   block, the issue and pull-request appendix sections, and the appendix truncation.

Blocks from the plan's contingency list that were **not** moved, because the module was already
under the limit after the moves above: the changed-file bucketing, the scoping-summary assembly,
and the digest joins. All three remain in `collector.py`.

## Preserved in place, as the task requires

- `write_output`, `collect_and_write`, `parse_args`, `main`, and the module entry-point guard all
  remain in `collector.py`.
- The two output-path defaults `SUMMARY_PATH_DEFAULT` and `APPENDIX_PATH_DEFAULT` remain in
  `collector.py`.
- **The output-path resolution is unchanged.** The assignment of the summary path directly from
  the supplied output argument stays as written; no join against the repository root was
  introduced. `[P7-T3]` verifies this against the tracked source.

## Re-exports so existing importers are unaffected

`collector.py` re-exports `SUMMARY_CHAR_BUDGET` and `APPENDIX_CHAR_BUDGET`, and binds
`_render_verification_evidence_section` to the moved function. The last of these is required, not
tidiness: `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` imports that private
name directly from `scripts.dev_tools.pr_context.collector`, and records in its own docstring that
it reaches the private symbol deliberately rather than through a public wrapper. Moving the
function without the alias would have left a dangling import.

## Acceptance test set

Command: `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part3.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`

EXIT_CODE: 0

```
============================= 45 passed in 0.20s ==============================
```

45 passed, 0 failed. The private-symbol import in
`test_collect_pr_context_expected_exit.py` resolves through the re-export and its three tests
pass.

## New module size

`scripts/dev_tools/pr_context/collector_documents.py` is 345 lines, at or below the 500-line
limit.
