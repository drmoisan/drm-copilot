# P8-T12 Regression over tests/scripts/claude-runtime

Timestamp: 2026-10-09T00-57
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=83
  PassedCount=83
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 8 files.
Discovery found 83 tests in 221ms.
Running tests.

Running tests from 'tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1'
Describing checkpoint hygiene and delegation identity skill contract
 87ms (69ms|18ms)
 6ms (6ms|1ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 14ms (13ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-runtime\claude-architecture-doc.Tests.ps1'
Describing claude-architecture-doc
 18ms (16ms|2ms)
 8ms (7ms|1ms)
 10ms (9ms|1ms)
 9ms (8ms|1ms)
 16ms (15ms|1ms)
 13ms (13ms|1ms)

Running tests from 'tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1'
Describing claude-runtime-structure
 11ms (9ms|2ms)
 10ms (9ms|1ms)
 6ms (5ms|1ms)
 9ms (9ms|1ms)
 7ms (6ms|1ms)
 18ms (18ms|1ms)

Running tests from 'tests\scripts\claude-runtime\claude-settings.Tests.ps1'
Describing claude-settings
 23ms (21ms|1ms)
 7ms (6ms|1ms)
 8ms (7ms|1ms)
 12ms (11ms|1ms)
 48ms (47ms|1ms)

Running tests from 'tests\scripts\claude-runtime\enforcement-hooks-checkpoint-path-explicit.Tests.ps1'
Describing enforcement hooks supply the checkpoint path explicitly
 420ms (420ms|1ms)
 485ms (484ms|1ms)
 477ms (477ms|1ms)
 564ms (563ms|1ms)
 466ms (465ms|1ms)
 408ms (408ms|1ms)
 27ms (26ms|1ms)
 8ms (7ms|1ms)

Running tests from 'tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1'
Describing enforcement hooks must not invoke Python
 Context allowlist policy
 18ms (14ms|4ms)
 Context detection class 1 - constant interpreter command
 24ms (23ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|0ms)
 5ms (5ms|1ms)
 8ms (8ms|1ms)
 5ms (4ms|1ms)
 Context detection class 2 - subprocess start targeting an interpreter
 18ms (16ms|2ms)
 6ms (5ms|1ms)
 5ms (4ms|0ms)
 Context detection class 3 - dynamic invocation fail-closed
 15ms (14ms|1ms)
 6ms (5ms|1ms)
 Context detection class 4 - arbitrary text execution
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 Context non-detection - constructs that must never be reported
 6ms (4ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 7ms (7ms|0ms)
 Context carve-out boundaries - the inline sibling-load exemption stays tight
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 6ms (6ms|0ms)
 Context repository scan
 29ms (28ms|1ms)
 792ms (792ms|1ms)
 740ms (739ms|0ms)

Running tests from 'tests\scripts\claude-runtime\legacy-discovery-agent-roles.Tests.ps1'
Describing legacy-discovery-agent-roles structural test
 Context detection logic (in-memory fixtures)
 8ms (6ms|2ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 Context real persona files
 4ms (3ms|1ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 10ms (10ms|0ms)
 5ms (4ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-runtime\test-name-uniqueness.Tests.ps1'
Describing test-name-uniqueness adapter-ID collision guard
 Context detection logic (in-memory fixtures)
 18ms (16ms|2ms)
 15ms (15ms|1ms)
 6ms (6ms|1ms)
 5ms (4ms|0ms)
 Context repository suite scan
 2.51s (2.51s|1ms)
Tests completed in 8.63s
Tests Passed: 83, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=83
PassedCount=83
FailedCount=0
```

Baseline comparison: TotalCount 83 = BASE_RT; FailedCount 0; no FAILED or FAILED-CONTAINER line names enforcement-hooks-no-python-invocation.Tests.ps1 (AC-43).
