# Final Delivery Guards — Closing Check

Timestamp: 2026-09-08T08-47

Task: [P8-T7]

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q --no-header -p no:cacheprovider`

EXIT_CODE: 0

The single `EXIT_CODE:` row above records the pack-manifest-completeness run alone. This closing
check covers three guards with different expectations, and the `ExpectedExitCode` field is per-file
rather than per-gate, so one artifact cannot express all three. The other two guards are recorded
below in forms whose text before the first colon is not exactly `EXIT_CODE`, because
`scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last row whose pre-colon
text is exactly `EXIT_CODE` as this artifact's rendered result; a subsidiary row in that spelling
would render this passing gate as a failed one.

## Guard 1 — pack manifest completeness

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q --no-header -p no:cacheprovider`,
exit status 0.

Console result line transcribed verbatim:

```
2 passed in 0.03s
```

| Field | Value |
| --- | --- |
| Tests collected and passed | **2** |
| Failed | 0 |
| Exit status | 0 |

The numeric test count this task's acceptance requires is **2**.

## Guard 2 — no-Python enforcement-hook guard

`pwsh` cannot be invoked in this worktree-isolated runtime, so this Pester suite cannot be started
on its own. The plan therefore directs that its result be transcribed from the
`artifacts/pester/pester-junit.xml` written by the [P8-T4] run, which executed the full configured
scan set and so included this suite.

Provenance check performed before reading the file: the root `testsuites` start tag on disk carries
`tests="4460" errors="0" failures="2" disabled="9" time="148.716"`, which matches the tag [P8-T4]
transcribed in `evidence/qa-gates/final-test-mcp.2026-09-06T23-09.md` in every attribute including
`time`. The file on disk is therefore the [P8-T4] run's output and was not overwritten by the
[P8-T5] CI download, which wrote to `artifacts/poshqc-ci/final/` instead.

Complete `testsuite` start tag whose `name` attribute ends with
`enforcement-hooks-no-python-invocation.Tests.ps1`, transcribed verbatim:

```xml
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" tests="27" errors="0" failures="0" hostname="MEGALODON4" id="113" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" time="2.037">
```

| Required attribute | Required value | Observed value | Satisfied |
| --- | --- | --- | --- |
| `failures` | `0` | `0` | **yes** |
| `errors` | `0` | `0` | **yes** |
| `tests` | at least 27 | `27` | **yes** |

This guard carries no exit code of its own, by design: it is a transcribed `testsuite` start tag
rather than a process invocation, so it contributes no `EXIT_CODE:` row to this artifact.

## Guard 3 — push-down resource contracts

Recorded in `evidence/qa-gates/push-down-resource-contracts-state-exempt-final.2026-09-06T23-09.md`
and in no other file, because its success case is a non-zero exit and therefore requires its own
`ExpectedExitCode` declaration, which is a per-file field.

Summary for cross-reference only: the run reported exit status 1 with a complete missing-path list
of exactly one entry, `.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`,
which sits under `.claude/state/` and is the batch-budget state file whose name embeds the resolved
session id. That is the exempt shape this task's acceptance permits.

That path differs from the artifact path `evidence/qa-gates/push-down-resource-contracts-state-exempt.2026-09-06T23-09.md`
that [P6-T6] wrote, so the Phase 6 record survives unmodified.

## PowerShell batch-budget reset — not required on this pass

The plan requires a batch-budget counter reset **before re-running any mirror task**, because
Batch F's counter already holds the two `pester.runsettings.psd1` files and
`.claude/hooks/enforce-powershell-batch-budget.ps1` counts distinct paths cumulatively, so a
remediation touching more than one mirror would be denied.

**No mirror task was re-run on this pass, so no reset was performed.** The condition that would have
required one did not arise: the resource-contracts guard reported no `.claude` path that this work
changed. Its single reported path is gitignored local runtime state, confirmed by

Command: `git check-ignore -v .claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`,
exit status 0, output `.gitignore:68:.claude/state/`.

A file under a gitignored directory is never part of the bundled payload, so its absence from the
bundle is structural rather than a missed mirror. The failure branch the plan describes — in which
the [P8-T1] format pass rewrote a source file without its Phase 5 or Phase 6 mirror — would have
surfaced a tracked `.claude` path in that list. It surfaced none, so no mirror task required
re-running, no reset was needed, and the toolchain loop does not restart at [P8-T1].

Recording this as a reasoned non-action rather than omitting it, so the absence of a reset row in
this artifact is auditable rather than ambiguous.

Output Summary: All three closing delivery guards pass. Guard 1,
`test_push_down_claude_pack_manifest_completeness.py`, exited **0** with **2** tests passed. Guard 2,
the no-Python enforcement-hook guard, is transcribed from the [P8-T4] run's `pester-junit.xml` —
provenance confirmed by an exact match of the root `testsuites` tag including `time="148.716"` —
and reports `tests="27" errors="0" failures="0"`, satisfying the at-least-27 requirement with zero
failures and zero errors. Guard 3, `test_push_down_claude_resource_contracts.py`, exited 1 with a
complete reported-path list of exactly one entry, all of it under `.claude/state/`, and is recorded
in its own artifact with `ExpectedExitCode: 1`. No mirror task was re-run, so no PowerShell
batch-budget reset was required or performed; the reported path is gitignored runtime state
(`.gitignore:68`) rather than a tracked file this work changed.
