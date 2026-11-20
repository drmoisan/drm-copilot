# Pass-After Capture — Claude Family Batch (issue #516)

## Command block 1 — Pester, Claude hook suites

Timestamp: 2026-08-24T16-02
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and `scan_folders` = `["tests/scripts/claude-hooks"]`
EXIT_CODE: 0

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC test against '...' with 1 selected scan folder(s)."}
```

Counts read from `artifacts/pester/pester-junit.xml`:

```text
TOTAL tests=1088 failures=0 errors=0
  enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | tests=33 failures=0 errors=0
  enforce-orchestration-preimplementation-gate.Tests.ps1                | tests=35 failures=0 errors=0
  PreToolUseSchema.Contract.Tests.ps1                                   | tests=15 failures=0 errors=0
```

| Suite required by [P2-T4] | Tests | Failures | Verdict |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` (new) | 33 | 0 | PASS |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (run-only, unmodified) | 35 | 0 | PASS |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (run-only, unmodified) | 15 | 0 | PASS |

Zero failures across all three required suites, and zero failures across the whole `tests/scripts/claude-hooks` folder (1088 tests). The 19 cases that failed in the [P1-T12] fail-before capture now all pass, and no case that passed before now fails.

Output Summary: Pester over `tests/scripts/claude-hooks` reports 1088 passed, 0 failed, 0 errored. All three suites named by [P2-T4] report zero failures. The new absolute-paths suite went from 19 failures to 0 with no change to any test file, confirming the two edited predicates in the Claude copy are what closed the gap.

## Command block 2 — push-down parity leg

Timestamp: 2026-08-24T16-03
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
EXIT_CODE: 0

```text
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
collected 10 items
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py ..........  [100%]
============================= 10 passed in 0.12s ==============================
```

Preparatory step recorded for auditability: immediately before this invocation, the gitignored transient file `.claude/state/powershell-batch-budget.default.json` was removed, because the batch-budget hook had recreated it during this phase's PowerShell writes and `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every on-disk `.claude/**` file and requires a bundled counterpart. The cause and the in-scope justification are recorded in full in `evidence/baseline/baseline-pytest-pushdown-parity.2026-08-23T23-25.md`. The removal touches no tracked file.

Output Summary: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes 10 of 10 with EXIT_CODE 0 after the Claude edit, confirming Claude root-to-bundle content equality. This is the parity gate for the Claude family and it agrees with the direct `Get-FileHash` comparison in [P2-T3]: `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` for both Claude copies.

## Command block 3 — [P2-T6] production-file scope check

Timestamp: 2026-08-24T16-04
Command: `git diff --name-only fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` (substituted baseline per the mandatory reconciliation recorded in `evidence/baseline/baseline-branch-and-fileset.2026-08-23T23-25.md`)
EXIT_CODE: 0

```text
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/issue.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/research/2026-08-23T23-40-preimplementation-gate-absolute-path-516-research.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
```

| Acceptance condition | Result |
| --- | --- |
| Exactly two production files changed so far | **Yes** — the two Claude hook copies, and no other production file |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` present | **Yes** |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` present | **Yes** |
| No path beginning with `.codex/` | **Yes** — zero such paths |

The four remaining entries are documentation under this item's own feature folder: `issue.md`, the research artifact, the plan file (this executor's checkbox ticks), and `spec.md`. None is a production file. The two new test suites are untracked at this point and therefore invisible to `git diff` against a commit; they are captured by the union in [P5-T1], which is why that task uses the union rather than the diff alone.

Output Summary: Exactly two production files have changed after batch 1 — both Claude hook copies — reaching the configured per-batch production cap of 2. Neither Codex hook copy appears, confirming no Codex write occurred before the [P3-T1] batch-budget reset, as the plan requires.
