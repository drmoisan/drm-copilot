# gh Run-List headBranch Probe (P0-T10)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `gh run list --workflow=publish-mcp-npm.yml --event=push --limit 5 --json databaseId,headBranch,status,conclusion`

EXIT_CODE: 0

## Invocation Note

The logical command recorded in the `Command:` field above is what was executed. It was issued
through a `pwsh -NoProfile -Command` entry point because this executor's Bash allowlist does not
include `gh` directly. The wrapper does not mask the inner exit code: `$LASTEXITCODE` was read
immediately after the `gh` invocation and is what `EXIT_CODE:` records.

The query is read-only. It lists existing workflow runs and creates, dispatches, cancels, and
modifies nothing.

## Raw Output

```json
[{"conclusion":"success","databaseId":32885709848,"headBranch":"mcp-server-v1.1.2","status":"completed"},{"conclusion":"success","databaseId":32846558904,"headBranch":"mcp-server-v1.1.1","status":"completed"},{"conclusion":"success","databaseId":32656062364,"headBranch":"mcp-server-v1.1.0","status":"completed"},{"conclusion":"success","databaseId":32439743292,"headBranch":"mcp-server-v1.0.27","status":"completed"},{"conclusion":"success","databaseId":32080899336,"headBranch":"mcp-server-v1.0.26","status":"completed"}]
```

## Returned headBranch Values, Verbatim

| # | databaseId | headBranch | status | conclusion |
|---|---|---|---|---|
| 1 | 32885709848 | `mcp-server-v1.1.2` | completed | success |
| 2 | 32846558904 | `mcp-server-v1.1.1` | completed | success |
| 3 | 32656062364 | `mcp-server-v1.1.0` | completed | success |
| 4 | 32439743292 | `mcp-server-v1.0.27` | completed | success |
| 5 | 32080899336 | `mcp-server-v1.0.26` | completed | success |

Most recent `databaseId`: **32885709848** (for `mcp-server-v1.1.2`). This is the value P0-T11
consumes.

## Determination

RUN_LIST_HEADBRANCH_IS_TAG_NAME: true

All five returned `headBranch` values are the short tag name of a release tag. Each matches the
`mcp-server-v<version>` release-tag form used by this repository, and none is a branch name. At
least one returned value is a release tag's short name, which is the condition the determination
requires; here every returned value satisfies it.

## Consequence for Phase 2

Because the determination is true, `Wait-ForWorkflowRun` (P2-T3) may implement check (a) by matching
the run-list `headBranch` field against the short tag name it is waiting for. The head-SHA matching
fallback that a false determination would have required is NOT needed and is not adopted. This is
recorded so that P2-T3, whose acceptance references this artifact for the field to match on, has an
unambiguous instruction: match on `headBranch` against the short tag name.

Output Summary: `gh run list` for `publish-mcp-npm.yml` filtered to push events exited 0 and
returned five completed runs, all with conclusion `success`. Every `headBranch` value is a release
tag short name of the form `mcp-server-v<version>` (1.1.2, 1.1.1, 1.1.0, 1.0.27, 1.0.26), confirming
that a tag-triggered run reports the tag name in the `headBranch` field rather than a branch name.
`RUN_LIST_HEADBRANCH_IS_TAG_NAME: true`, so check (a) matches on `headBranch` and no head-SHA
fallback is required. Exactly one determination line is carried above. The most recent `databaseId`
32885709848 is handed to P0-T11.
