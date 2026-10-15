Timestamp: 2026-10-02T02-39
Command: poetry run python -m scripts.dev_tools.pr_context.collector --base b080a69ecb60b65d016362b21fffed0a34be9144 --head HEAD --repo-root . --out artifacts/pr_context.summary.rem1-before.txt --appendix-out artifacts/pr_context.appendix.rem1-before.txt
EXIT_CODE: 0
Output Summary: Collector wrote the summary and appendix. Source rows (a) 38, pass rows (b) 38, fail rows (c) 0, 01-17 timestamp rows (d) 9, 01-25..01-31 timestamp rows (e) 0. N_BEFORE is 38. No stop condition.

# PR-Context Rows Before Correction (Remediation Cycle 1, task P0-T7)

Primary command output:

  Wrote context summary to: artifacts\pr_context.summary.rem1-before.txt
  Wrote context appendix to: artifacts\pr_context.appendix.rem1-before.txt

stderr (runpy notice, not an error):

  <frozen runpy>:128: RuntimeWarning: 'scripts.dev_tools.pr_context.collector' found in sys.modules after import of package 'scripts.dev_tools.pr_context', but prior to execution of 'scripts.dev_tools.pr_context.collector'; this may result in unpredictable behaviour

## Companion commands

  (a) grep -c -e "^  - Source: " artifacts/pr_context.summary.rem1-before.txt  exit=0
    38
  (b) grep -c -e "^  - Normalized result: pass" artifacts/pr_context.summary.rem1-before.txt  exit=0
    38
  (c) grep -c -e "^  - Normalized result: fail" artifacts/pr_context.summary.rem1-before.txt  exit=1
    0
  (d) grep -c -e "^  - Timestamp: 2026-10-02T01-17" artifacts/pr_context.summary.rem1-before.txt  exit=0
    9
  (e) grep -c -e "^  - Timestamp: 2026-10-02T01-2[5-9]" -e "^  - Timestamp: 2026-10-02T01-31" artifacts/pr_context.summary.rem1-before.txt  exit=1
    0

## Recorded values

- N_BEFORE: 38 (agrees with the 38 rows in the policy audit Executive Summary)

## Acceptance check

- Collector exit 0 and printed `Wrote context summary to:`.
- (a) equals (b) at 38; (c) is 0; (d) is 9; (e) is 0.
