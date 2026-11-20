# gh Publish Job and Step Name Probe (P0-T11)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `gh run view 32885709848 --json jobs`

EXIT_CODE: 0

## Operand Resolution

The plan writes this task's operand as `RUN_IDENTIFIER`. That placeholder was replaced with the
concrete integer `databaseId` before the command was run, and the `Command:` field above records the
resolved invocation with that integer in place, as the task requires.

- Source of the integer: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/other/gh-run-list-headbranch-probe.2026-08-25T23-33.md`
- Selection rule: the most recent `databaseId` returned by P0-T10
- Resolved value: `32885709848`
- That run's `headBranch`: `mcp-server-v1.1.2`

## Invocation Note

The logical command recorded in the `Command:` field is what was executed. It was issued through a
`pwsh -NoProfile -Command` entry point because this executor's Bash allowlist does not include `gh`
directly. The wrapper does not mask the inner exit code: `$LASTEXITCODE` was read immediately after
the `gh` invocation and is what `EXIT_CODE:` records.

The query is read-only. It reads an existing run and dispatches, re-runs, cancels, and modifies
nothing.

## Observed Jobs

The run returned three jobs:

| Job name | Conclusion |
|---|---|
| `Extension Tests (windows-latest)` | success |
| `Extension Tests (ubuntu-latest)` | success |
| `Publish to npm` | success |

## Observed Steps of the Publish Job

Job `Publish to npm`:

| # | Step name | Conclusion |
|---|---|---|
| 1 | `Set up job` | success |
| 2 | `Checkout repository` | success |
| 3 | `Set up Node.js` | success |
| 4 | `Upgrade npm for trusted publishing` | success |
| 5 | `Install MCP server dependencies` | success |
| 6 | `Copy resources (prepack)` | success |
| 7 | `Build MCP server bundle` | success |
| 8 | `Publish to npm` | success |
| 15 | `Post Set up Node.js` | success |
| 16 | `Post Checkout repository` | success |
| 17 | `Complete job` | success |

## Names Confirmed, Verbatim

- Observed job name: `Publish to npm`
- Observed publish step name: `Publish to npm`

The job name and the publish step name are the same string. This is a property check (b) must
tolerate: `Test-PublishStepConclusion` (P2-T4) locates the job by name and then the step by name
within that job, so the identical spelling at the two levels is not ambiguous provided the lookup is
performed hierarchically rather than by a flat name search.

## Corroboration Against the Workflow Source

The two names were cross-checked against `.github/workflows/publish-mcp-npm.yml` at the baseline
commit:

- Line 32: `name: Publish to npm` (the job)
- Line 60: `name: Publish to npm` (the step)
- Line 61: `if: github.event_name == 'push'` (the event-name guard on that step)
- Line 63: `run: npm publish --provenance --access public`

The observed API names match the workflow source exactly. The guard at line 61 is the event-name
guard that P4-T2 replaces with the ref-based guard, and it sits at the line number the plan cites,
which confirms the plan's reading of the file is current.

## Determination

PUBLISH_STEP_NAME_CONFIRMED: true

Both names were observed: the job name `Publish to npm` and the publish step name `Publish to npm`.

Output Summary: `gh run view 32885709848 --json jobs` exited 0 for the most recent push-triggered
run of `publish-mcp-npm.yml` (tag `mcp-server-v1.1.2`). The run carried three jobs, all successful.
The publish job is named `Publish to npm` and its publish step is also named `Publish to npm`, at
step number 8, with conclusion `success`. Both names were observed, so
`PUBLISH_STEP_NAME_CONFIRMED: true`. These are the exact names `Test-PublishStepConclusion` (P2-T4)
uses for check (b), and the identical job-level and step-level spelling requires that lookup to be
hierarchical. The `Command:` field records the resolved invocation with the concrete integer run
identifier 32885709848 in place of the plan's RUN_IDENTIFIER operand. Exactly one determination line
is carried above.
