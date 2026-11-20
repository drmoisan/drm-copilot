Timestamp: 2026-10-02T02-45
Command: poetry run python -m scripts.dev_tools.pr_context.collector --base b080a69ecb60b65d016362b21fffed0a34be9144 --head HEAD --repo-root .
EXIT_CODE: 0
Output Summary: Collector exit 0. Q is 0. Source rows (a) 38 and pass rows (b) 38 equal N_BEFORE (38) plus Q (0); fail rows (c) 0; 01-17 timestamp rows (d) 0 (was 9); 01-25..01-31 timestamp rows (e) 9 (was 0).

# PR-Context Rows After Correction (Remediation Cycle 1, task P3-T1)

Loop iteration: 1
Restart-cleanup: none (iteration 1)

Primary command output:

  Wrote context summary to: artifacts\pr_context.summary.txt
  Wrote context appendix to: artifacts\pr_context.appendix.txt

stderr (runpy notice, not an error):

  <frozen runpy>:128: RuntimeWarning: 'scripts.dev_tools.pr_context.collector' found in sys.modules after import of package 'scripts.dev_tools.pr_context', but prior to execution of 'scripts.dev_tools.pr_context.collector'; this may result in unpredictable behaviour

## Companion commands

  (a) grep -c -e "^  - Source: " artifacts/pr_context.summary.txt  exit=0
    38
  (b) grep -c -e "^  - Normalized result: pass" artifacts/pr_context.summary.txt  exit=0
    38
  (c) grep -c -e "^  - Normalized result: fail" artifacts/pr_context.summary.txt  exit=1
    0
  (d) grep -c -e "^  - Timestamp: 2026-10-02T01-17" artifacts/pr_context.summary.txt  exit=1
    0
  (e) grep -c -e "^  - Timestamp: 2026-10-02T01-2[5-9]" -e "^  - Timestamp: 2026-10-02T01-31" artifacts/pr_context.summary.txt  exit=0
    9
  (f) grep -r -l -e "^Timestamp: " --include="*-rem1.2026-10-02T02-02.md" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates  exit=1
    (no output; Q = 0)

## Acceptance check

- Collector exit 0.
- (f) exit 1 with no output, Q = 0.
- (a) and (b) both 38 = N_BEFORE (38) + Q (0).
- (c) 0; (d) 0 (was 9); (e) 9 (was 0), the nine collected rows corrected by P1-T19 through P1-T27.
- Exactly one body line begins with the restart-cleanup key.
