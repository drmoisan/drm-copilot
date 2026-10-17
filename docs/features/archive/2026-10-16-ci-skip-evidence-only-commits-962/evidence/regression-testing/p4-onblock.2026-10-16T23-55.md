# ci.yml trigger block unchanged (P4-T14, AC-22)

Timestamp: 2026-10-16T23-55
Command: sh SCRATCH/tools/run-cr.sh cr-onblock
EXIT_CODE: 0
Output Summary: The on: block of the edited ci.yml is identical to the merge-base copy (475bb06d5, which equals origin/main): ONBLOCK-IDENTICAL: True, 7 lines each. ONBLOCK-HAS-MERGE-GROUP: False, matching CI-MERGE-GROUP: absent in the latest edit-points artifact. EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-onblock
MERGE-BASE: 475bb06d5c6caeb3e68b13f847a4097dc026fa89
ONBLOCK-LINES: base=7 | head=7
ONBLOCK-HAS-MERGE-GROUP: False
ONBLOCK-IDENTICAL: True
EXIT_CODE_COMPUTED: 0
```
