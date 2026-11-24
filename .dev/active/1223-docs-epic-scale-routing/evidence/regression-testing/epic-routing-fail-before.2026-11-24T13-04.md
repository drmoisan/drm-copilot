# Fail-before proof: documentation-workflow.EpicRouting.Tests.ps1 against the unedited skill

Timestamp: 2026-11-24T13-04
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode (prose): nonzero is expected; this is an expect-fail proof, not a gate. The recorded exit code is the observed value; the shard process exit code was 34 (the failed test count).
Output Summary: 34 testcases, 34 failures (read from artifacts/pester/parallel/shard-1/pester-junit.xml; no merged artifact is written on failure). Failing It names, each in every row: 'places ## Epic-Scale Routing once, after ## Rules and before ## Commit, Receipt and Pull Request' (4 rows), 'states the routing condition and the page threshold' (4), 'lists the waves in order with each family id in its own wave segment' (4), 'states ownership and omits family-record field names' (4), 'states the dispatch rule' (4), 'states the receipt rule' (4), 'qualifies the single-run statements' (4), 'states the epic standard behavior' (2 rows), and 'lists this suite in ## Contract Tests That Pin Mirrored Files' (4 rows). Cause: the section, OB-6, and the brief suite name are absent.
