# Fail-before: merge-gate ordinal key rows (P1-T3)

Timestamp: 2026-11-24T15-56
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 (through SCRATCH/issue-1233-r1-fbf3.sh; new rows added, .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 and its copies unchanged)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=2; wall-clock=129.22s; exit code=1 (no merged artifact; read from the shard JUnit and logs copied to SCRATCH/r1-fbf3-parallel/).
- Claude suite: tests=62, failures=12. Codex suite: tests=72, failures=15. Every failing row is a new row; every pre-existing row passed.
- Claude failing rows (12): CLAUDE-OPT-ORD-L1-LOCAL-QC-GATE-KEY, CLAUDE-OPT-ORD-L1-CONCLUSION-KEY, CLAUDE-OPT-ORD-L1-HEAD-SHA-KEY, CLAUDE-OPT-ORD-L1-EVIDENCE-PATH-KEY, CLAUDE-OPT-ORD-L1-FEATURE-FOLDER-KEY, CLAUDE-OPT-ORD-L2-REMEDIATION-LOOP-KEY, CLAUDE-OPT-ORD-L2-REVIEW-OUTCOMES-KEY, CLAUDE-OPT-ORD-L2-REVIEW-HEAD-SHA-KEY, CLAUDE-OPT-ORD-FALLBACK-EPIC-CONTEXT-KEY, CLAUDE-OPT-ORD-FALLBACK-INTEGRATION-BRANCH-KEY, CLAUDE-OPT-ORD-PREDICATE-CHILD-CI-KEY, CLAUDE-OPT-ORD-PREDICATE-EPIC-MODE-KEY.
- Codex failing rows (15): OPT-ORD-L1-LOCAL-QC-GATE-KEY, OPT-ORD-L1-CONCLUSION-KEY, OPT-ORD-L1-HEAD-SHA-KEY, OPT-ORD-L1-EVIDENCE-PATH-KEY, OPT-ORD-L1-FEATURE-FOLDER-KEY, OPT-ORD-L2-REMEDIATION-LOOP-KEY, OPT-ORD-L2-REVIEW-OUTCOMES-KEY, OPT-ORD-L2-REVIEW-HEAD-SHA-KEY, OPT-ORD-FALLBACK-EPIC-CONTEXT-KEY, OPT-ORD-FALLBACK-INTEGRATION-BRANCH-KEY, OPT-ORD-PREDICATE-CHILD-CI-KEY, OPT-ORD-PREDICATE-EPIC-MODE-KEY, and the three OPT-ORD-ACCESSOR rows (the accessor does not exist yet).
- Cause: the case-insensitive reader applies the opt-out for a case-variant predicate key (stage B deny instead of the pre-change deny text) and passes the record for case-variant L1 and L2 keys (allow instead of deny).
