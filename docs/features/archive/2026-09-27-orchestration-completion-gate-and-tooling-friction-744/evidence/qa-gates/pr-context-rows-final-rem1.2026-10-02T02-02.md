Timestamp: 2026-10-02T02-50
Command: poetry run python -m scripts.dev_tools.pr_context.collector --base b080a69ecb60b65d016362b21fffed0a34be9144 --head HEAD --repo-root .
EXIT_CODE: 0
Output Summary: Collector exit 0. Q is 10. Source rows (a) 48 and pass rows (b) 48 equal N_BEFORE (38) plus Q (10); fail rows (c) 0; 01-17 timestamp rows (d) 0; 01-25..01-31 timestamp rows (e) 9.

# Final PR-Context Rows (Remediation Cycle 1, task P4-T6)

Loop iteration: 1

Primary command output:

  Wrote context summary to: artifacts\pr_context.summary.txt
  Wrote context appendix to: artifacts\pr_context.appendix.txt

stderr (runpy notice, not an error):

  <frozen runpy>:128: RuntimeWarning: 'scripts.dev_tools.pr_context.collector' found in sys.modules after import of package 'scripts.dev_tools.pr_context', but prior to execution of 'scripts.dev_tools.pr_context.collector'; this may result in unpredictable behaviour

## Companion commands

  (a) grep -c -e "^  - Source: " artifacts/pr_context.summary.txt  exit=0
    48
  (b) grep -c -e "^  - Normalized result: pass" artifacts/pr_context.summary.txt  exit=0
    48
  (c) grep -c -e "^  - Normalized result: fail" artifacts/pr_context.summary.txt  exit=1
    0
  (d) grep -c -e "^  - Timestamp: 2026-10-02T01-17" artifacts/pr_context.summary.txt  exit=1
    0
  (e) grep -c -e "^  - Timestamp: 2026-10-02T01-2[5-9]" -e "^  - Timestamp: 2026-10-02T01-31" artifacts/pr_context.summary.txt  exit=0
    9
  (f) grep -r -l -e "^Timestamp: " --include="*-rem1.2026-10-02T02-02.md" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates  exit=0
    10 paths (Q = 10), under FEATURE/evidence/qa-gates/:
    evidence-locations-rem1.2026-10-02T02-02.md
    evidence-numstat-rem1.2026-10-02T02-02.md
    main-plan-validator-rem1.2026-10-02T02-02.md
    pr-context-rows-rem1.2026-10-02T02-02.md
    pytest-pr-context-rem1.2026-10-02T02-02.md
    rem1-timestamps-rem1.2026-10-02T02-02.md
    scope-rem1.2026-10-02T02-02.md
    timestamp-correction-lines-rem1.2026-10-02T02-02.md
    timestamp-residue-rem1.2026-10-02T02-02.md
    timestamp-values-rem1.2026-10-02T02-02.md

## Acceptance check

- Collector exit 0.
- (f) exit 0 with exactly 10 paths, the qa-gates rem1 artifacts of P3-T1 through P3-T5 and P4-T1 through P4-T5; Q = 10.
- (a) and (b) both 48 = N_BEFORE (38) + Q (10); (c) 0; (d) 0; (e) 9.
