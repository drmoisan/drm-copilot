# R4 AC re-check note (P6-T6, AC-CHK-2)

Timestamp: 2026-10-17T03-42
Command: git merge-base --is-ancestor c5e9a77d3 HEAD; git merge-base --is-ancestor f96b623ea HEAD; git merge-base --is-ancestor 08130a03e HEAD; git merge-base --is-ancestor 58a355c8a HEAD; git log -1 --format=%s f96b623ea; git log -1 --format=%s 08130a03e; git log -1 --format=%s 58a355c8a
EXIT_CODE: 0
Output Summary:
- git merge-base --is-ancestor c5e9a77d3 HEAD: exit 0
- git merge-base --is-ancestor f96b623ea HEAD: exit 0
- git merge-base --is-ancestor 08130a03e HEAD: exit 0
- git merge-base --is-ancestor 58a355c8a HEAD: exit 0
- git log -1 --format=%s f96b623ea: test(935): R4 F-1 conditional-construct rows and balanced-brace leaf pattern (TEST-1, CR-F4) (exit 0)
- git log -1 --format=%s 08130a03e: test(935): R4 helper CmdletBinding, shared hook-literal pattern and header corrections (CR-F1-F3, CR-F5-F8) (exit 0)
- git log -1 --format=%s 58a355c8a: perf(935): R4 Discovery suite memos and reused discovery data (PERF-1 to PERF-5) (exit 0)

CHANGE: spec.md AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23 and AC-26 changed from [x] to [ ] with the criterion text unchanged; AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22 and AC-25 stay checked; AC-24 stays unchecked (AC-CHK-1).
SUPERSEDED-BASIS: commit c5e9a77d3 checked these criteria from CI run 38963921545 on the former PR #956 head 048d76cd8.
R4-CHANGES: commits f96b623ea, 08130a03e and 58a355c8a changed the Branches, HookReference and Discovery suites and the EpicStateIsolation helpers that these criteria name.
RECHECK: main-plan P7-T10 re-checks each of the 17 lines at S9 from CI on the follow-on PR head (orchestrator note (1)).
RULE: acceptance-criteria-tracking rule 4 and ### CI-Dependent Criteria.
NOT-EDITED: evidence/qa-gates/s9-ac-verification.2026-10-16T21-46.md.
COUNTS: 8 checked, 18 unchecked.
