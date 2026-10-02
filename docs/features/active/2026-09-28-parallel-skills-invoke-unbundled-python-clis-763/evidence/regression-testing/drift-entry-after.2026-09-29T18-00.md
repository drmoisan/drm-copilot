# Five Drift Suites With the Entry Script Present (P3-T20)

Timestamp: 2026-09-29T18-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib/parallel-drift ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml parallel-drift/ParallelDriftHalt.Tests.ps1 parallel-drift/ParallelDrift.Tests.ps1 parallel-drift/ParallelDrift.Manifest.Tests.ps1 parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 parallel-drift/ParallelDrift.Parity.Tests.ps1
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary:
- `JUNIT file=parallel-drift/ParallelDriftHalt.Tests.ps1 Total=28 Passed=28 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Tests.ps1 Total=26 Passed=26 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Manifest.Tests.ps1 Total=5 Passed=1 Failed=4 Other=0`
- `JUNIT file=parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 Total=21 Passed=21 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Parity.Tests.ps1 Total=20 Passed=20 Failed=0 Other=0`
- `JUNIT-ALL Total=100 Failed=4`; the four JUNIT-FAILED lines are the Manifest cases awaiting the
  Phase 5 core.json entries and bundle copies. Pester EXIT_CODE 4 equals those four failures.

Passed B19 cases (every B19 It name, plus two executor-added JSON cases):
declares no Mandatory parameter; binds positional arguments only to ChangedPath; exits 2 when
-ItemKey is missing; exits 2 when -ItemKey is not an integer; exits 2 when an unrecognized parameter
reaches the remaining arguments; exits 1 with the failure prefix when the checkpoint cannot be read;
exits 1 with the failure prefix when the checkpoint root is not an object; exits 0 and writes one
JSON object to stdout; emits a one-element escaped_paths as a JSON array; emits a one-element
halted_item_keys as a JSON array; returns timestamp-shaped strings unchanged; treats an omitted
ChangedPath as an empty changed-path list; defaults -At to the mocked UTC clock formatted
yyyy-MM-ddTHH-mm; defaults -ComputedAt to the resolved -At; sorts object keys ordinally in the
emitted JSON; converts integers, floats, booleans, null, arrays, and objects from JSON; keeps JSON
object keys case-sensitive; reads the committed checkpoint and config fixtures and leaves both files
unchanged; resolves relative paths against the current location; (added) emits floats, booleans,
and nulls as JSON values; (added) rejects a value it cannot serialize.

Passed B20 cases: the drift corpus meets the floor of 18 fixtures; the drift corpus names every
required case; and 18 `reproduces drift fixture <name>` cases, one per C1 name:
error-item-key-missing, error-items-not-a-list, error-non-object-root, escape-without-conflict,
halt-both-starts-absent, halt-drifter-started-later, halt-equal-start-timestamps, halt-one-pair,
halt-one-start-absent, halt-several-pairs, malformed-peer-radius-fails-closed,
no-escape-empty-changed-paths, no-escape-inside-radius, non-object-edge-ignored,
peer-not-in-flight-ignored, peer-radius-iso-timestamp-evaluated, reversed-existing-edge-not-new,
tolerated-overlap-under-conflict-tolerance.

Halt and Drift passed-case lists are unchanged from
evidence/regression-testing/drift-modules-after.2026-09-29T18-00.md (28 and 26 cases).

Execution note: the first run of this task showed seven mocked Invoke cases failing because the
test's mock routed by the suffix `checkpoint.json`, which the default checkpoint path
`artifacts/orchestration/parallel-orchestrator-state.json` does not carry. The test's mock routing
was corrected (config paths are recognized by `config.json` or `blast-radius.json`); the entry
script was not changed. The result above is the rerun.
