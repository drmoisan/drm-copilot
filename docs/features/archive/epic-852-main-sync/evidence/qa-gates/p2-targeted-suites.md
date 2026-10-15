# Phase 2 Targeted Suites After the Fix

Timestamp: 2026-10-11T00-15
Task: [P2-T6]
Command: cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh rscoped tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
EXIT_CODE: 0

```text
PassedCount: 825
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Passed | passed=598 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Passed | passed=140 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | result=Passed | passed=11 | failed=0
```

Required rows (all present among the PASSED lines below):

- S2 repository: `S2: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try`
- S2 mirror: `S2: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try`
- B1: `B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming feature-review-coverage-thresholds.ps1 when that direct edge fails`
- C8: `C8: .claude/hooks/validate-feature-review-coverage.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail`

Output Summary: 825 passed, 0 failed across the seven targeted suites; the S2 repository and mirror rows, the B1 thresholds row, and the C8 row for `.claude/hooks/validate-feature-review-coverage.ps1` pass after the fix. 49 PASSED lines name `validate-feature-review-coverage.ps1`.

## PASSED lines containing `validate-feature-review-coverage.ps1`

```text
PASSED: hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: hook dependency guard structural completeness (issue #786).S2: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: hook dependency guard structural completeness (issue #786).S2: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: hook dependency guard structural completeness (issue #786).S3: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: hook dependency guard structural completeness (issue #786).S3: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: hook dependency guard structural completeness (issue #786).S3: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: hook dependency guard structural completeness (issue #786).S3: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: hook dependency guard structural completeness (issue #786).S4: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: hook dependency guard structural completeness (issue #786).S4: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: hook dependency guard structural completeness (issue #786).S5: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: hook dependency guard structural completeness (issue #786).S5: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: hook dependency guard structural completeness (issue #786).S5: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: hook dependency guard structural completeness (issue #786).S5: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: hook dependency guard structural completeness (issue #786).S6: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: hook dependency guard structural completeness (issue #786).S6: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming feature-review-coverage-thresholds.ps1 when that direct edge fails
PASSED: Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: Claude hook dependency-failure special cases (issue #786).C8: .claude/hooks/validate-feature-review-coverage.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
PASSED: validate-feature-review-coverage.ps1.required artifact tokens.blocks when required review artifact tokens are missing
PASSED: validate-feature-review-coverage.ps1.required artifact tokens.blocks when required review artifacts do not share the same timestamp
PASSED: validate-feature-review-coverage.ps1.coverage verdict enforcement.blocks when a changed language lacks an explicit PASS or FAIL coverage verdict
PASSED: validate-feature-review-coverage.ps1.coverage verdict enforcement.allows termination when required artifacts exist and no changed languages need coverage validation
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-2 falls back to the default floors when the root CLAUDE.md states no figures
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-3 applies a line-only figure and keeps the default branch floor
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-4 reads PowerShell line coverage from the JaCoCo report
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-5 reads branch coverage from the JaCoCo report
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-6 rejects a coverage row that narrows scope
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-7 rejects an audit that does not mention a changed language
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-8 rejects a language mention with no coverage-scoped row
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-9 reads a tracked file and reports a missing one
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V1 blocks an empty payload
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V2 blocks a malformed payload
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V3 blocks an empty agent output
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V4 blocks an artifact outside the active-feature location
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V5 blocks an advertised artifact that does not exist
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V6 blocks a remediation-inputs path outside the location
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V7 blocks a remediation-inputs timestamp that differs
PASSED: validate-feature-review-coverage.ps1 (issue #824).issue #824 - review artifact validation paths (coverage support).F824-V8 blocks a remediation-inputs file that does not exist
```
