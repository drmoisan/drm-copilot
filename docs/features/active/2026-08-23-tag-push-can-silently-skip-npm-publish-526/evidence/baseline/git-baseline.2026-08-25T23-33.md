# Git Baseline (P0-T2)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `git rev-parse --abbrev-ref HEAD` and `git rev-parse HEAD`

EXIT_CODE: 0

## Observed Values

- Branch name: `bug/tag-push-can-silently-skip-npm-publish-526`
- Commit SHA: `afbf51dfe6508319a2d673603d31825077d8cddb`
- SHA length: 40 characters

## Per-Command Detail

| Command | Exit code | Stdout |
|---|---|---|
| `git rev-parse --abbrev-ref HEAD` | 0 | `bug/tag-push-can-silently-skip-npm-publish-526` |
| `git rev-parse HEAD` | 0 | `afbf51dfe6508319a2d673603d31825077d8cddb` |

Output Summary: Both invocations exited 0. The working branch is
`bug/tag-push-can-silently-skip-npm-publish-526`, which matches the branch named in the execution
directive. HEAD resolves to the 40-character commit SHA
`afbf51dfe6508319a2d673603d31825077d8cddb`. This is the pre-change baseline commit against which
every later diff and coverage delta in this plan is measured. No repository state was modified by
either command; both are read-only.
