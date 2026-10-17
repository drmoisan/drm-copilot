# Cycle 2 gh Observation Before the F2 Edit (Issue #931)

Timestamp: 2026-10-16T05-12
Command: gh pr checks 15 --json bucket 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: gh version 2.87.3 (2026-02-23). `gh pr checks --help` lists a `--json` flag and states "Additional exit codes: 8: Checks pending". PR 15 (no checks): exit 1, text `no checks reported on the 'chore/gitignore' branch`. PR 948: exit 0, a single-line JSON array beginning `[` of 17 objects with a `"bucket"` field (pass and pending values), so a pending set under `--json` exits 0, not 8. All P0-T12 acceptance conditions hold; the F2 rule of Decision 5 stands.

## Step 1

- Command: `gh --version`
- Exit code: 0

```text
gh version 2.87.3 (2026-02-23)
https://github.com/cli/cli/releases/tag/v2.87.3
```

## Step 2

- Command: `gh pr checks --help`
- Exit code: 0
- Output (trimmed to description exit-code section, usage, and flags):

```text
When the `--json` flag is used, it includes a `bucket` field, which categorizes
the `state` field into `pass`, `fail`, `pending`, `skipping`, or `cancel`.

Additional exit codes:
	8: Checks pending

USAGE
  gh pr checks [<number> | <url> | <branch>] [flags]

FLAGS
      --fail-fast         Exit watch mode on first check failure
  -i, --interval int      Refresh interval in seconds in watch mode (default 10)
  -q, --jq expression     Filter JSON output using a jq expression
      --json fields       Output JSON with the specified fields
      --required          Only show checks that are required
  -t, --template string   Format JSON output using a Go template; see "gh help formatting"
      --watch             Watch checks until they finish
  -w, --web               Open the web browser to show details about checks
```

## Step 3

- Command: `gh pr checks 15 --json bucket 2>&1`
- Exit code: 1

```text
no checks reported on the 'chore/gitignore' branch
```

## Step 4

- Command: `gh pr checks 948 --json bucket 2>&1`
- Exit code: 0

```text
[{"bucket":"pass"},{"bucket":"pass"},{"bucket":"pending"},{"bucket":"pass"},{"bucket":"pass"},{"bucket":"pending"},{"bucket":"pass"},{"bucket":"pending"},{"bucket":"pending"},{"bucket":"pending"},{"bucket":"pending"},{"bucket":"pending"},{"bucket":"pass"},{"bucket":"pass"},{"bucket":"pass"},{"bucket":"pass"},{"bucket":"pass"}]
```

## Derivation:

Recorded sources:

1. `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/research/research.2026-10-09T02-25.md` line 44:
   > In `pkg/cmd/pr/checks/checks.go`, `populateStatusChecks` runs before the JSON exporter and returns an error for zero checks: `no checks reported on the '<branch>' branch`, and with `--required`, `no required checks reported on the '<branch>' branch`. The JSON exporter returns before the pending exit-code path, so a pending set with `--json` exits 0.
2. `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/research/2026-10-15-release-flow-all-checks-research.md` lines 26-29:
   > Zero reported checks returns an error before any output: `no checks reported on the '<branch>' branch`. This is a plain error, so a non-zero exit (1 by cobra/gh convention; the manual does not state the number).
   > With `--required` and zero required checks after filtering: error `no required checks reported on the '<branch>' branch`, also before the pending/failed logic.
   > At the end of `checksRun`: `counts.Failed > 0` returns `cmdutil.SilentError` (exit 1); else `counts.Pending > 0` returns `cmdutil.PendingError` (exit 8). Failure outranks pending.
   > `--json`: `if opts.Exporter != nil { return opts.Exporter.Write(opts.IO, checks) }` returns before the failed/pending exit logic. With `--json` the exit code is therefore 0 for pass, fail, and pending sets; only the two "no checks" errors (and transport/auth errors) exit non-zero.
3. `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md` line 58:
   > no required checks reported on the 'bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2' branch
4. Live observation in this task (Step 3): `gh pr checks 15 --json bucket` printed `no checks reported on the 'chore/gitignore' branch` and exited 1. Step 4 confirms that a pending set under `--json` exits 0, as sources 1 and 2 state.

Rule (`## Decisions` item 5): in Phase A, a non-zero poll is retried only when its output contains the substring `no checks reported`. Any other non-zero poll, such as an authentication or network failure, fails promptly without sleeping: it writes `Could not query the checks for PR #<n> (gh exit code <code>).` to stderr and returns 1 at once, before any `Invoke-Sleep` call. The rule reads output text rather than the exit code because gh uses exit 1 both for the no-checks error and for HTTP errors.
