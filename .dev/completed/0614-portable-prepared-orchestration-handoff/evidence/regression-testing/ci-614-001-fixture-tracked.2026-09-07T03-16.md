# Fixture Is Tracked and Not Ignored — [P1-T17]

Timestamp: 2026-09-07T11-53
Task: [P1-T17]

Command: `git ls-files --error-unmatch -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json`
EXIT_CODE: 0

That `git ls-files --error-unmatch` invocation is the gate command. It was preceded by `git add -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json` and followed by `git check-ignore -v -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json`.

## Observations

```
git add -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json
ADD_EXIT=0

git ls-files --error-unmatch -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json
tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json
LSFILES_EXIT=0

git check-ignore -v -- tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json
(no output)
CHECKIGNORE_EXIT=1
```

- `git add` exited 0.
- `git ls-files --error-unmatch` echoed the path `tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json` and exited 0, so the path is in the index. `--error-unmatch` makes this gate falsifiable: an unindexed path causes a non-zero exit rather than empty output.
- `git check-ignore -v` exited 1 with no output, meaning no `.gitignore` rule matches the fixture. This is the contrast with the live checkpoint the six cases previously read, which `.gitignore` line 6 (`/artifacts`) excludes.

Staging was limited to this one path. No commit was made by this task.

Output Summary: The fixture is a tracked, non-ignored repository file. `git ls-files --error-unmatch` exited 0 and echoed the path, `git add` exited 0, and `git check-ignore -v` exited 1 with no output. The six retargeted byte-identity cases therefore read a file that is present in every checkout, which is the condition the `poshqc / PowerShell QC` CI runner failed on before this change.
