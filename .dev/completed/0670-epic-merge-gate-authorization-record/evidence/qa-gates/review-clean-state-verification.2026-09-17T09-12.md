# Feature Review Clean-State Verification — Issue #670

Timestamp: 2026-09-17T09-12
Author: feature-review agent
Head: feature/2026-09-13-epic-merge-gate-authorization-record-670 @ 332ab835133af49092d8155c40ea0152560f5557
Base: origin/epic/worktree-scoped-state-resolution-integration @ 79fd5a95c00cd99238b69a3195788206ae96f4cd
Command: git -C <worktree> archive --format=tar -o <scratchpad>/h2.tar HEAD -- .agents .claude .codex .github scripts tests extensions/drm-copilot AGENTS.md CLAUDE.md pyproject.toml poetry.lock ; git -C <worktree> archive --format=tar -o <scratchpad>/h3.tar HEAD -- config ; tar -xf h2.tar -C d ; tar -xf h3.tar -C d ; (in d) python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q -p no:cacheprovider ; (in d) Invoke-Pester over ten suites (listed below)
EXIT_CODE: 0

## Purpose

The executor's final QC loop recorded two non-zero exits that it attributed to local state rather than
to the change:

- `Invoke-PoshQCTest` (whole tree): 4627 tests, 2 failures, both reading the live, gitignored
  `artifacts/orchestration/orchestrator-state.json` of the #670 epic-child run.
- `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`:
  fails on the gitignored `.claude/state/` batch-budget file (open issue #510).

This artifact tests that attribution directly. The committed HEAD tree was exported with
`git archive` into the session scratchpad. The export contains only tracked content, so it has no
`artifacts/` directory and no `.claude/state/` directory. The affected tests were then run against
the export. No repository file was modified.

## Pre-checks in the review worktree

- `git -C <worktree> check-ignore -v .claude/state/powershell-batch-budget.worktree-agent-a51b6017c8cb9c138-ac477202.json`
  printed `.gitignore:68:.claude/state/`, confirming the file that trips issue #510 is gitignored.
- The JUnit artifact `artifacts/pester/pester-junit.xml` (written 2026-09-17 08:45:35 -0400, after the
  last source edit at 08:39:12 -0400) lists exactly two failed test cases:
  1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
  2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`
- Re-running those two suites in the worktree reproduced both failures. The second failure message is
  `EPIC_WAVE_BARRIER_BLOCKED: '670' cannot mutate until every depends_on edge is merged ...`, emitted by
  `enforce-epic-wave-barrier.ps1`, which is not in this change set.

## Results in the clean export

| Check | Result |
| --- | --- |
| `.claude/state/` present | no |
| `artifacts/` present | no |
| pytest, three push-down contract files | `17 passed`, exit 0 |
| `enforce-pr-author-skill.Tests.ps1` | 43 passed, 0 failed |
| `codex-pretooluse-integration.Tests.ps1` | 6 passed, 0 failed |
| `enforce-epic-merge-gate.Authorization.Tests.ps1` | 15 passed, 0 failed |
| `enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` | 37 passed, 0 failed |
| `enforce-epic-merge-gate-authorization.Tests.ps1` (Codex) | 28 passed, 0 failed |
| `enforce-epic-merge-gate.Tests.ps1` | 56 passed, 0 failed |
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 passed, 0 failed |
| `enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 passed, 0 failed |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 7 passed, 0 failed |
| `codex-epic-runtime-contracts.Tests.ps1` | 10 passed, 0 failed |
| Pester total | 227 passed, 0 failed, 0 skipped |

Two earlier attempts in narrower exports produced failures caused by the export itself, not by the
change: the first omitted `.agents/` and `extensions/drm-copilot/src/`, and the second omitted
`config/orchestration-handoff-registry.json`. Adding those tracked paths removed every failure. The
table above is the final attempt.

## Review-worktree checks recorded in the same session

- PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 0 diagnostics for each
  of the six changed or added `.ps1` files.
- Check-only formatting (`Invoke-Formatter` with the same settings file, LF-normalized input, compared
  in memory without writing): all six files already formatted, so no file would be rewritten.
- Targeted Pester in the worktree (17 suites, including the three new suites, the four existing
  merge-gate suites, the no-Python guard, the purity suites and three pre-implementation gate suites):
  434 passed, 0 failed.
- `Invoke-PowerShellTestPurityDecision` returned no decision (no denial) for each of the three new test
  files.
- `validate_evidence_locations.py --root <worktree>`: exit 0.

Output Summary:
- The two whole-tree Pester failures and the issue #510 pytest failure do not reproduce against the
  committed tree when gitignored local state is absent: 227/227 Pester cases and 17/17 pytest cases pass.
- Combined with the whole-tree JUnit artifact (4627 tests, only those two failures), no test failure is
  attributable to the committed change.
- Format and lint are clean in check-only mode, so the final tree passes every loop stage without an
  auto-fix.
