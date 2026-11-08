---
paths:
  - ".github/workflows/**"
description: Exit-code rules for GitHub Actions workflow steps that run pwsh.
---

# CI Workflow Authoring

This rule governs GitHub Actions workflow steps that run PowerShell (`pwsh`). It exists because a `pwsh` step that intentionally invoked a failing nested command left `$LASTEXITCODE == 1` after its verification logic had already succeeded, leaking a failure to GitHub Actions even though the step's intent was satisfied (issue #26, PR #30).

## Deliberately-Failing Nested Command Pattern (Required)

A workflow step whose `run:` block intentionally invokes a command expected to fail — for example a negative-path self-validation that asserts a gate catches a synthetic regression — MUST not allow the residual non-zero exit code to propagate to GitHub Actions.

For any such step, the `run:` block MUST do one of the following:

1. Reset the exit code explicitly after the expected failure:
   ```powershell
   & ./some-tool --expect-failure
   $LASTEXITCODE = 0
   ```
2. Or terminate the success path with an explicit zero exit:
   ```powershell
   if ($verificationSucceeded) { exit 0 } else { exit 1 }
   ```

A `pwsh` step terminates with the exit code of the last external command unless the script explicitly resets it or calls `exit`. Negative-path verification steps therefore require an explicit reset or explicit `exit 0`.

## Epic Integration-Branch Trigger (Required When Epic Branches Are Used)

A repository that runs epics with `epic/<slug>-integration` branches MUST list `epic/**` in the `pull_request` branches of its workflow named `CI`, so that every child pull request into an integration branch receives a CI run on its head (issue #1130):

```yaml
name: CI
on:
  pull_request:
    branches: [main, "epic/**"]
```

The epic merge gates (`.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` and its byte-identical `.codex/hooks/` twin) allow an epic-child merge only when the newest run of the workflow named `CI` on the live child head is a completed, successful `pull_request` run, or the `workflow_dispatch` run recorded in `ci_gate.dispatch_run_id`. A `push`-event run is not accepted, and a repository whose required workflow has a different name is denied with `EPIC_CHILD_CI_NOT_VERIFIED`. When the trigger is missing, the dispatch fallback of S9 in `.claude/skills/orchestrate/SKILL.md` (`## Step S9 — CI Green Gate`) starts the run with `gh workflow run CI --ref <child branch>`. Destination repositories receive this rule only through push-down, so a destination needs a push-down refresh before it applies.

## Rationale

- GitHub Actions interprets a step's process exit code as the step result. A leaked `$LASTEXITCODE` from an intentionally-failing nested command causes a passing verification to report failure.
- No local toolchain stage executes a workflow's `run:` block, so this defect is invisible to local feature-review. This textual rule is the artifact local review cites when reading workflow YAML.

## Enforcement

- Local feature-review cites this rule when reviewing diffs that add or modify `pwsh` steps with deliberately-failing nested commands.
- The feature-review policy rule `modified-workflow-needs-green-run` (see `.claude/skills/feature-review-workflow/SKILL.md`) requires a green workflow run against the branch head before a workflow change can merge, which exercises the exit-code path on the runner.

## Scope

- This rule applies to any workflow step whose `run:` block uses `shell: pwsh` (or the repo default `pwsh`) and intentionally invokes a failing nested command.
- It does not change required-check configuration or branch protection.
- The epic integration-branch trigger section applies to the workflow named `CI` in a repository that uses epic integration branches.
