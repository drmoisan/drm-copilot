# Batch B5 — batch toolchain gate (coverage registration and the Codex contract suite)

Timestamp: 2026-09-07T13-01

Task: [P4-T15]

Batch B5 contents: production `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`; test
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

Both runsettings copies carry the `.psd1` extension and the batch-budget classifier at
`.claude/hooks/enforce-powershell-batch-budget.ps1` line 273 counts every `.ps1`, `.psm1`, and `.psd1`
target, treating a path as a test file only when it matches `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$`
at line 284. This batch's production count is therefore two rather than zero, exactly as the plan's
batching table states.

## Batch budget reset (closes B5)

Pre-reset listing of `.claude/state/`:

```
powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json
```

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [".../scripts/powershell/PoshQC/settings/pester.runsettings.psd1"],
  "testFiles": [".../tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1"]
}
```

This is the observation that confirms the `.psd1` classification: the runsettings file was recorded
under `prodFiles`, not `testFiles`. The bundled copy is absent from the counter because it was written
with `cp`, which does not pass through the PreToolUse hook; that route was chosen so the two copies are
byte-identical by construction, which is what `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
requires. Batch B5's real file count is 2 production and 1 test file, under the 3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain captures before and after the formatter are byte-identical; both reduce to MD5
`c337945d14faaf28f39a8ee9847fff19`. The capture lists 29 paths: six modified files (the plan, the two
pack manifests, both runsettings copies, and the legacy Codex contract suite), the four canonical
parser copies, the four bundle parser mirrors, the four parser test suites, and the eleven evidence
artifacts written so far.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observations: the two runsettings copies still share SHA-256
`bcaebfb014f569ecf116b21ad936296eb024c209e304c188e2bc89d7244ddf91` after the formatter ran, and
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` still measures 494 lines.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

Recorded for accuracy: `Invoke-PoshQCAnalyze` filters the discovered file list to `.ps1` and `.psm1`,
so neither `.psd1` copy edited by this batch is inside the analyzed set. Stage 2 is therefore not the
mechanism that validates the runsettings edits. Those are validated by the structural scan and the
parity test recorded in the [P4-T12] registration inventory artifact.

## Stage 3 — targeted Pester over the test file this batch owns

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1
and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 15 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |

Zero failed tests for the Codex contract suite, which is one of the task's explicit acceptance
conditions. The suite's case count rose because [P4-T9] extended `$script:SharedModuleNames` from two
members to four; `$script:StaticCheckNames` is built from that array, and the suite's parse,
500-line-cap, and root-versus-bundle byte-identity legs iterate it. Those legs now cover
`hook-command-scanner.ps1` and `hook-command-invocation.ps1` on the Codex side, and all pass. The
byte-identity leg compares SHA-256, so its passing is an independent confirmation of the [P4-T4] and
[P4-T5] mirror hashes.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 731 tests, **15** failures — unchanged from the batch B4 gate. The
composition was enumerated by name in this run and is exactly:

- 13 from `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` — known-red
  inventory rows, closed by Phase 5.
- 1 from `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` — the intended
  assertion reversal, a known-red inventory row closed by Phase 5.
- 1 from `codex-pretooluse-integration.Tests.ps1` — the out-of-inventory, out-of-scope
  environment-dependent failure the batch B1 artifact identified by name and traced to
  `enforce-epic-wave-barrier.ps1` reading the live epic checkpoint.

13 + 1 = 14 matches the Codex-side known-red row count exactly, and the fifteenth is accounted for.
Batch B5 closes no inventory row.

## Push-down resource contracts, deselected form

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

Result: **10 passed, 1 deselected, 0 failed** in 0.09s.

The deselected case is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, deselected by
node ID. It is **open issue #510** and is red for a cause this change does not create: that module
enumerates the repository `.claude` tree from the filesystem and excludes only
`.claude/settings.local.json` and `.claude/agent-memory/**`, so any file under `.claude/state/` is
demanded of the bundled payload. `.claude/hooks/enforce-powershell-batch-budget.ps1` recreates
`.claude/state/` on the first `Write` or `Edit` of a `.ps1`, `.psm1`, or `.psd1` file, which happened
at [P1-T2], so the case has been red from Phase 1 onward for an environmental reason.

The exclusion is by node ID rather than by a name filter, so it removes exactly one case and cannot
silently widen. The 10 remaining cases include the byte-identity assertions over the bundled `.claude`
payload, which are the ones that observe the [P4-T1] and [P4-T2] mirrors, and all 10 pass.

Recorded so the deselection is auditable: `.claude/state/` was observed immediately after this batch's
reset and contains **no files**, though the directory itself exists. The directory's existence alone is
enough to make the excluded case's premise environment-dependent, and re-creating a state file is a
side effect of the next PowerShell write rather than of anything this change does.

## Batch-level parity

| File | SHA-256 |
| --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `bcaebfb014f569ecf116b21ad936296eb024c209e304c188e2bc89d7244ddf91` |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `bcaebfb014f569ecf116b21ad936296eb024c209e304c188e2bc89d7244ddf91` |

Equal. `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` reported
**1 passed, 0 failed**, which is the [P4-T11] acceptance condition; the hash equality above is a
strictly stronger observation than the text equality that test asserts.

Output Summary: batch B5 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**, before and after porcelain captures sharing MD5
`c337945d14faaf28f39a8ee9847fff19`. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide
diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports **43 tests / 0 failures** for
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. The deselected-form push-down pytest
reports **10 passed, 1 deselected, 0 failed**, the deselection being
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` under open issue **#510**. No stage
failed and no stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget
reset exited 0.
