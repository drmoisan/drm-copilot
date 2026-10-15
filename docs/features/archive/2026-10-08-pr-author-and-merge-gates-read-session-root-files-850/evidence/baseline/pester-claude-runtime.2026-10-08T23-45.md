# P0-T23 Pester baseline folder tests/scripts/claude-runtime

Timestamp: 2026-10-08T23-45
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=83
  PassedCount=83
  FailedCount=0
  BASE_RT: 83
  Rule EE: does not apply to P0-T23.
  Baseline failure set (P0-T23): empty
  Baseline container set (P0-T23): empty

## Full output

```text
Pester v5.6.1

Starting discovery in 8 files.
Discovery found 83 tests in 309ms.
Running tests.

Running tests from 'tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1'
Describing checkpoint hygiene and delegation identity skill contract
 91ms (72ms|19ms)
 7ms (6ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 15ms (14ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|1ms)
 6ms (5ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-runtime\claude-architecture-doc.Tests.ps1'
Describing claude-architecture-doc
 11ms (10ms|2ms)
 7ms (6ms|0ms)
 5ms (4ms|0ms)
 7ms (6ms|1ms)
 16ms (15ms|1ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1'
Describing claude-runtime-structure
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 11ms (11ms|0ms)

Running tests from 'tests\scripts\claude-runtime\claude-settings.Tests.ps1'
Describing claude-settings
 16ms (15ms|1ms)
 5ms (4ms|0ms)
 6ms (5ms|0ms)
 11ms (10ms|0ms)
 37ms (37ms|0ms)

Running tests from 'tests\scripts\claude-runtime\enforcement-hooks-checkpoint-path-explicit.Tests.ps1'
Describing enforcement hooks supply the checkpoint path explicitly
 453ms (452ms|1ms)
 475ms (475ms|1ms)
 560ms (559ms|1ms)
 469ms (469ms|1ms)
 419ms (419ms|1ms)
 670ms (669ms|1ms)
 48ms (47ms|1ms)
 10ms (9ms|1ms)

Running tests from 'tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1'
Describing enforcement hooks must not invoke Python
 Context allowlist policy
 27ms (21ms|6ms)
 Context detection class 1 - constant interpreter command
 44ms (42ms|2ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)
 9ms (8ms|1ms)
 12ms (11ms|1ms)
 17ms (16ms|1ms)
 Context detection class 2 - subprocess start targeting an interpreter
 16ms (13ms|3ms)
 10ms (9ms|1ms)
 6ms (6ms|1ms)
 Context detection class 3 - dynamic invocation fail-closed
 18ms (16ms|1ms)
 8ms (7ms|1ms)
 Context detection class 4 - arbitrary text execution
 7ms (5ms|1ms)
 7ms (7ms|1ms)
 Context non-detection - constructs that must never be reported
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 7ms (6ms|1ms)
 11ms (11ms|1ms)
 Context carve-out boundaries - the inline sibling-load exemption stays tight
 9ms (8ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 Context repository scan
 43ms (42ms|1ms)
 1.06s (1.06s|1ms)
 1.01s (1.01s|1ms)

Running tests from 'tests\scripts\claude-runtime\legacy-discovery-agent-roles.Tests.ps1'
Describing legacy-discovery-agent-roles structural test
 Context detection logic (in-memory fixtures)
 11ms (9ms|2ms)
 5ms (4ms|1ms)
 9ms (8ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 Context real persona files
 10ms (9ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 7ms (6ms|1ms)
 12ms (11ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-runtime\test-name-uniqueness.Tests.ps1'
Describing test-name-uniqueness adapter-ID collision guard
 Context detection logic (in-memory fixtures)
 23ms (21ms|2ms)
 22ms (21ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 Context repository suite scan
 3.44s (3.44s|2ms)
Tests completed in 10.57s
Tests Passed: 83, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=83
PassedCount=83
FailedCount=0
```
