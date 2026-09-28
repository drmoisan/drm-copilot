# Baseline — PowerShell Tests and Coverage (PoshQC / Pester) — Issue #440

Timestamp: 2026-08-08T20-57

Task: [P0-T4]

Branch: `feature/parallel-enforcement-hooks-440` (base `epic/parallel-orchestration-integration` at `c939b5b8`)

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`

EXIT_CODE: 1

## Raw Result

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Command exited with code 1."
}
```

## Numeric Test Totals

Read from `artifacts/pester/pester-junit.xml` (`testsuites` root attributes) produced by this run:

| Metric | Value |
| --- | --- |
| tests | 2031 |
| failures | 1 |
| errors | 0 |
| skipped | (attribute empty) |
| time (s) | 112.637 |

Passing tests: 2030 of 2031.

## Numeric Coverage Headline

Read from `artifacts/pester/powershell-coverage.xml` (JaCoCo-format top-level `counter` elements) produced by this run:

| Counter type | covered | missed | total | percentage |
| --- | --- | --- | --- | --- |
| LINE | 3148 | 189 | 3337 | **94.34%** |
| INSTRUCTION (commands) | 4316 | 278 | 4594 | **93.95%** |
| METHOD | 240 | 26 | 266 | 90.23% |
| CLASS | 39 | 2 | 41 | 95.12% |

LINE/COMMAND coverage headline (baseline): **94.34% line / 93.95% command**.

BRANCH: not emitted by PoshQC/Pester coverage output

The coverage document contains exactly four top-level `counter` elements — `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS`. No `BRANCH` counter exists in the emitted document, so no branch figure can be read for PowerShell. This is the documented behavior of the repository's PowerShell coverage tooling (precedent: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md`). Line/command coverage is therefore the authoritative PowerShell numeric, and this explicit absence note is the required substitute rather than a placeholder for an available metric (plan Binding Constraint 7).

## Pre-Existing Failure — Recorded, Not Fixed, Not a Blocker

The single failure is pre-existing on this branch and is out of scope for issue #440.

- **Test file:** `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- **Test case:** `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- **Assertion output:**
  ```
  Expected strings to be the same, but they were different.
  Expected length: 5
  Actual length:   4
  Strings differ at index 0.
  Expected: 'allow'
  But was:  'deny'
  ```
- **Cause:** the test reads the real, gitignored `artifacts/orchestration/orchestrator-state.json` rather than injecting checkpoint content through a mocked seam. While an orchestrated run is live, the on-disk checkpoint does not satisfy the PR-author gate, so the hook returns `deny` where the test asserts `allow`.
- **Disposition:** recorded as pre-existing and out of scope per the execution directive. The test file is NOT edited by this feature. This failure must not be treated as a baseline blocker; the counts above establish the apples-to-apples comparison basis for the Phase 1, Phase 2, and Phase 5 runs (expected post-change state: the same single failure, plus the new Phase 1/Phase 2 tests passing).

### Second Named Suspect — Passed in This Run

The execution directive also named the `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` suite as a checkpoint-reading test that fails whenever an orchestrated run is live. In this baseline run it passed:

| Suite | tests | failures |
| --- | --- | --- |
| `tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1` | 37 | 0 |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | 6 | 0 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 56 | 0 |

It is recorded here as a known environment-sensitive suite: a failure in it during a later phase must be evaluated against this baseline and against live-checkpoint state before being attributed to this feature's changes. It is likewise NOT edited by this feature.

Output Summary: EXIT_CODE 1, driven entirely by one pre-existing, out-of-scope failure. 2031 tests executed, 2030 passed, 1 failed, 0 errors, 112.637 s. Baseline coverage headline: 94.34% line / 93.95% command (LINE covered 3148 / missed 189; INSTRUCTION covered 4316 / missed 278). BRANCH: not emitted by PoshQC/Pester coverage output. The single failure is `enforce-pr-author-skill.Tests.ps1` -> `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, which reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam and therefore fails whenever an orchestrated run is live. It is recorded as pre-existing, is not fixed, is not treated as a baseline blocker, and the named test file is not edited by this feature. The `codex-pretooluse-integration.Tests.ps1` suite, named in the directive as similarly environment-sensitive, passed 6 of 6 in this run and is recorded for the same comparison purpose.
