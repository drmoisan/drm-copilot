# Post-Rebase Toolchain Re-Verification

Timestamp: 2026-08-26T06-38

Author: orchestrator (not a plan task; supplementary evidence)

## Timestamp correction (NB-6)

The filename segment reads `06-55`. That is wrong: this artifact was committed in `2ae27c01`, whose
author date is `2026-08-26 06:44:29 -0400`, so a 06:55 capture time is 11 minutes after the commit
that introduced it. The `Timestamp:` field above has been corrected to `06-38`, which is inside the
window bounded by the preceding commit `c90d2587` (06:34) and the containing commit `2ae27c01`
(06:44), and matches when the four stages below actually ran.

The filename is deliberately NOT renamed. Three review artifacts —
`policy-audit.2026-08-26T06-55.md`, `code-review.2026-08-26T06-55.md`, and
`feature-audit.2026-08-26T06-55.md` — plus `remediation-inputs.2026-08-26T06-55.md` cite this file by
path. Breaking four citations to correct an 11-minute label is a net loss in auditability, so the
divergence is recorded here instead, per the alternative the finding allows.

## Why this artifact exists

The Phase 4 final-QC attestation
(`evidence/qa-gates/qc-consecutive-pass.2026-08-26T06-32.md`) was recorded against a tree based on
`1816b062`. After Phase 4 completed, `origin/main` advanced to `b5a7490b` when sibling parallel item
#526 (`bug/tag-push-can-silently-skip-npm-publish-526`, PR #564) merged. This branch was rebased onto
that new tip.

That merge is not inert with respect to this item's toolchain. #526 modified BOTH copies of
`pester.runsettings.psd1` — `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — which are the
files that configure Pester discovery and the `CodeCoverage.Path` allow-list this item's coverage
numbers are read from. A Phase 4 attestation taken before that change does not by itself establish
that the toolchain is still clean against the base the pull request will actually merge into.

This artifact records the re-run. It supplements the Phase 4 attestation; it does not replace it and
does not alter any Phase 4 checkbox.

## Rebase

```text
git rebase origin/main
```

EXIT_CODE: 0

Six commits replayed with no conflict. Pre-rebase head `d2765aa0`; post-rebase head `c90d2587`.
Merge base is now `b5a7490b`, the current `origin/main` tip.

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`

EXIT_CODE: 0

Output Summary: `ok: true`. No file was reformatted; the working tree remained clean after the run,
so no restart of the loop was triggered.

## Stage 2 — Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root`

EXIT_CODE: 0

Output Summary: `ok: true`. Zero PSScriptAnalyzer findings.

## Stage 3 — Test with coverage

Command: `mcp__drm-copilot__run_poshqc_test` with the same `workspace_root`

EXIT_CODE: 0

Output Summary: Read from `artifacts/pester/pester-junit.xml`: **3680 tests, 0 failures, 0 errors**.
The total rose from the 3617 recorded in Phase 4 because the #526 merge added test files to `main`;
the failure count is 0 both before and after. Overall line coverage read from
`artifacts/pester/powershell-coverage.xml` is **96.17 percent** (6696 covered, 267 missed, 6963
analyzable), against 96.15 percent at Phase 4 and a 96.14 percent Phase 0 baseline. The figure is
above the 85 percent threshold in `.claude/rules/quality-tiers.md`. No branch-coverage threshold
applies to PowerShell.

## Stage 4 — Bundle parity

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

Output Summary: **10 passed, 0 failed** in 0.10 seconds, test file unmodified.
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes, confirming the self-hosted
hook and its bundled mirror remain textually identical after the rebase.

## Stage 4 is environment-conditional — corrected (NB-1)

An earlier revision of this artifact claimed the Stage 4 result was "reproducible for any run that
does not interleave an agent file edit". That claim was too strong and is retracted. The reviewer
disproved it and the orchestrator reproduced the disproof.

Timeline, in this worktree:

| Time | Event |
| --- | --- |
| ~06:19 | `.claude/state/` cleared during [P2-T7] |
| ~06:38 | Stages 1-4 above run; directory confirmed empty before Stage 1 and after Stage 4; Stage 4 is 10 passed / 0 failed |
| 06:47 | `powershell-batch-budget.default.json` regenerated |
| 06:49 | `python-batch-budget.default.json` regenerated |
| ~06:50 | Reviewer re-runs the suite: **1 failed / 9 passed**, identical assertion |
| 07:00 | Orchestrator re-runs the suite: **1 failed / 9 passed**, identical assertion |

What is true is narrower than what was claimed: an MCP PoshQC invocation does not by itself write the
counters. They are written by the `Write`/`Edit` PreToolUse batch-budget hooks, which fire on ordinary
agent file edits — and this run necessarily performs those. The [P2-T7] clearance is therefore **not
durable**, and Stage 4's exit code is conditional on the state of a gitignored directory at the moment
it runs.

**The underlying defect is already tracked as open issue #510**, "Bug:
claude-resource-parity-enumerates-gitignored-state". No new issue was required and none was filed;
the earlier phrasing "carried to a follow-up issue" wrongly implied an undischarged obligation and is
withdrawn. #510 records that `list_scoped_files` enumerates the filesystem without excluding the
gitignored `.claude/state/**` subtree the way it already excludes `.claude/agent-memory/**`, and its
own Impact section anticipates this exact situation: "the natural response is a per-plan workaround
rather than a repository fix."

**The durable evidence for the parity property is not this test.** It is the direct byte comparison of
the two hook copies, which does not depend on `.claude/state/` at all:

```text
git hash-object .claude/hooks/enforce-prd-feature-before-planner.ps1
git hash-object extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1
```

Both return `469fecca912e3be687a123b8a3e33ce8a7f327c6`. The self-hosted hook and its bundled mirror
are byte-identical, which is the property acceptance criterion 23 asserts, and it holds unconditionally.

CI is unaffected in either direction: a CI checkout is fresh and does not run the batch-budget hooks,
so `.claude/state/` does not exist there and the test passes. `main` CI is green at `b5a7490b`, the
base of this branch, with the test file unchanged.

## Verdict

All four stages pass against the post-rebase tree in a single consecutive pass, with no repository
file edited between them. The Phase 4 attestation's conclusions hold against the base the pull
request will merge into.
