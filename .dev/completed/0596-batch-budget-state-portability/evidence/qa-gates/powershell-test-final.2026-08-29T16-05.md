# [P7-T4] PowerShell test — final QA loop (PoshQC MCP runner, unscoped)

Timestamp: 2026-08-29T22-20

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
and no `scan_folders` restriction.

EXIT_CODE: 2

Output Summary: The unscoped MCP test run returned `ok: false` with `summary` reading
`Command exited with code 2.`, from which `EXIT_CODE: 2` is derived. **This task's stated acceptance
(`ok: true`) is NOT met.** The cause is the two pre-existing failures recorded at the [P0-T11] and
[P0-T12] baselines, whose test names [P7-T5] reproduces byte-identically. No `ExpectedExitCode:` is
declared, because this task is a gate rather than a baseline capture and declaring an expectation
here would normalize an unmet gate to pass. The failure is classified as **pre-existing** on the
evidence set out below; it is not merge-introduced and not feature-caused. Per the plan's scope
constraint, the two unrelated suites were not repaired. This is loop iteration **1**.

## Exit-code derivation

Derived exactly as fixed in the plan's "How `EXIT_CODE:` is derived for a PoshQC MCP task"
paragraph. A non-zero exit of the spawned `pwsh` process is converted into a `CommandExecutionError`
whose message is `Command exited with code <N>.`, which the MCP layer projects onto `ok: false` with
that message in `summary`. This result carries `ok: false` and `summary` reading
`Command exited with code 2.`, so `EXIT_CODE: 2` with `N = 2`.

## Result object, verbatim

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```

`summary` field, verbatim:

```
Command exited with code 2.
```

`stderr_excerpt` field, verbatim:

```
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
```

This `stderr_excerpt` is **byte-identical** to the one recorded in the [P0-T11] baseline artifact
`evidence/baseline/powershell-test.2026-08-29T16-05.md`. As that baseline artifact already
established, these publish-verification lines are stderr emitted by a **passing** suite
(`Invoke-ReleaseTagPush.Tests.ps1`, marked `[+]`); they are not themselves the failures. The
`stderr_excerpt` field is a truncated stderr capture and does not identify the failing tests.

## What this MCP result does not carry

This MCP result carries **no test counts and no test names**. On both the success and the failure
path the `run_poshqc_test` result object exposes only `ok`, `tool`, `workspace_root`, `summary`, and
(on failure) `stderr_excerpt`. No Pester passed/failed/skipped counts, no `It` names, and no process
stdout are returned. **No count is asserted in this artifact.**

The task that records the counts and the test names is **[P7-T5]**, which runs the self-hosted
Form A Pester invocation, extracts names through Form B, and compares the passed count against the
[P0-T12] baseline. Its artifact is
`evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md`.

## Failure classification — pre-existing

The classification is drawn from [P7-T5]'s Form B extraction, which names the two failing tests.
Both names are **byte-identical** to the pair recorded in the [P0-T12] baseline artifact
`evidence/baseline/powershell-test-coverage.2026-08-29T16-05.md`:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
   — resides in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`
   — resides in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`

Three facts fix the classification as **pre-existing** rather than merge-introduced or
feature-caused.

- **Not feature-caused.** `git diff --name-only main -- tests/` reports exactly three files, all of
  them this feature's own suites: `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`, and
  `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`. Neither failing suite is among them, and
  neither failing test exercises any of the three hooks this feature changes.
- **Not merge-introduced.** The failure **count** is unchanged at 2 across the merge while the
  discovered test total rose from 3851 at baseline to 3904 now. All 53 newly discovered tests
  therefore pass. Three of the four suites the integration merge added were observed passing in the
  Form A console output with a `[+]` marker: `validate-prd-feature-output.Tests.ps1`,
  `GeneratedDocumentCounters.Tests.ps1`, and `claude-settings.Tests.ps1`. The fourth,
  `codex-pretooluse-integration.Tests.ps1`, contains failure 2 — but that same failure name is
  already present in the Phase 0 baseline artifact, so it was failing before this phase began and is
  not newly introduced by the merge into this branch's QA position.
- **Already recorded at baseline.** The [P0-T11] and [P0-T12] baseline artifacts both record exit
  code 2 with these two exact failures, captured before Phase 7 ran.

## Scope constraint — no repair attempted

Neither unrelated suite was repaired. Repairing them would widen this feature's scope beyond the
plan, which is prohibited. The consequence is recorded honestly rather than masked: the acceptance
criterion at `spec.md` line 773 requires `run_poshqc_format`, `run_poshqc_analyze`, and
`run_poshqc_test` to be **consecutively clean**, and an unscoped `run_poshqc_test` cannot be clean
while these two pre-existing failures stand. That criterion is therefore **partially unsatisfiable**
in this worktree and is reported to the orchestrator as such. See
`evidence/qa-gates/toolchain-loop-convergence.2026-08-29T16-05.md` for the loop verdict.

---

## Iteration 2 — re-run after the [P7-T6] restart

Timestamp: 2026-08-29T22-39

This task was re-run at its position in iteration 2, after [P7-T6] rewrote a TypeScript file in
iteration 1 and triggered the [P7-T11] restart. The iteration 1 record above is retained rather than
overwritten.

EXIT_CODE: 2

Result object, verbatim:

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```

The result is **byte-identical** to iteration 1 in every field, and its `stderr_excerpt` is
byte-identical to the [P0-T11] baseline. The [P7-T5] iteration 2 run confirms the identical failing
pair by name and the identical counts (3904 discovered, 3893 passed, 2 failed, 9 skipped).

The reproduction across two independent full runs establishes that the failure is **deterministic**
and is not a flake. Combined with the byte-identical baseline match, the classification stands
unchanged: **pre-existing**, not merge-introduced, not feature-caused. Nothing changed between the
two iterations except a Prettier line-wrap in a `.ts` file, which no PowerShell test loads.

**Iteration 2 verdict for this task: NOT MET, for the same pre-existing cause. No repair attempted.**
