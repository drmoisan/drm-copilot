# ci.yml trigger block, rule 17 RI-4 re-run of P4-T14 (AC-22)

Timestamp: 2026-10-17T00-12
Command: sh SCRATCH/tools/run-cr.sh cr-onblock
EXIT_CODE: 0
Output Summary: The merge base is now origin/main b8fcd7790. The on: block of the branch ci.yml (9 lines, including the #952 merge_group trigger) is identical to the merge-base copy: ONBLOCK-IDENTICAL: True. ONBLOCK-HAS-MERGE-GROUP: True, matching CI-MERGE-GROUP: present in edit-points.2026-10-17T00-09.md. EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-onblock
MERGE-BASE: b8fcd77905a51284cfbca54226a2da2a7916a836
ONBLOCK-LINES: base=9 | head=9
ONBLOCK-HAS-MERGE-GROUP: True
ONBLOCK-IDENTICAL: True
EXIT_CODE_COMPUTED: 0
```
