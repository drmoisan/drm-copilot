# Phase 0 — the two tasks left unchecked, adjudicated

Timestamp: 2026-09-08T22-00
Author: orchestrator (`Agent(orchestrator)`), issue #632 remediation cycle 2
Scope: P0-T3 and P0-T10, both left `- [ ]` by the Phase 0 executor

Both were left unchecked correctly. Neither is a defect in the change under remediation, and
neither blocks Phase 2. This record states what is established, what is not, and on what evidence,
so a later audit does not have to re-derive it.

## P0-T3 — the tree digest is denied, and the status channel is a complete substitute here

The executor could not run the digest. The permission layer refuses any command line containing
`source`, and `source` is the only route to `discover_shell_scripts` because `shell-qc.sh` exposes
no subcommand that prints the discovered file list. The denial is recorded verbatim in
`evidence/remediation-baseline/shell-qc-format.2026-09-08T07-30.md`.

The orchestrator re-attempted the same command from its own context and was refused with the same
text:

```
bash -c 'cd <worktree> && source scripts/bash/shell_qc_lib.sh && discover_shell_scripts | LC_ALL=C sort | xargs md5sum | md5sum'
```

```
This agent is isolated in the worktree ... but this command hands bash the text cd C:/Users/DanMoisan/repos/drm-copilot..., which runs source in a plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it
```

EXIT_CODE: DENIED
ExpectedExitCode: 0

The denial is therefore a property of the environment, not of the delegated agent. No digest value
is assumed, inferred, or recorded anywhere.

### What the status channel does establish

The digest exists in the plan as a secondary check, because `run_format` prints nothing and exits 0
whether or not it rewrote a file. Its stated advantage over `git status` is that it would also catch
a rewrite of a file the `-name '*.sh'` predicate misses — an extensionless file under a discovery
root whose shebang resolves to `bash` or `sh`.

That advantage is empty in this tree, and the emptiness is verified rather than assumed:

- `tools/` does not exist. `ls tools` reports `No such file or directory`, so two of the three
  discovery roots reduce to `scripts` and `.claude/lib/bash`.
- Every file under those two roots carrying a `^#!.*\b(bash|sh)\b` shebang has a `.sh` suffix: 12
  under `scripts/` (all in `scripts/bash/`) and 11 under `.claude/lib/bash/`. There are 238 non-`.sh`
  files under the roots and none of them carries a bash or sh shebang; they are PowerShell, Python,
  and data files.

So `discover_shell_scripts` and the `-name '*.sh'` predicate select the same set in this tree, and
the digest's extra reach over the status channel is over an empty set.

- `StatusBefore:` and `StatusAfter:` are byte-identical and list three paths, all of them this
  cycle's own documentation: the plan file and the two Phase 0 read artifacts. No shell file appears
  in either.
- Neither status listing contains an untracked `.sh` file, so the digest set at that moment
  contained only tracked files. A rewrite of any tracked file — with or without a `.sh` suffix —
  would have appeared in `StatusAfter`.

The residual blind spot the executor identified, an untracked discovered script, is therefore known
to be empty at the moment the command ran, and the status observation covers the whole digest set.

### Disposition

P0-T3 stays `- [ ]`. Its acceptance requires four non-empty observation fields and two of them are
denied, so the acceptance is not met and checking it off would be false. The task's *purpose* —
establishing that the write-mode formatter rewrote nothing at baseline — is met by the status
channel alone, for the reasons above. Recorded for `feature-review` to adjudicate rather than
silently resolved.

## P0-T10 — a pre-existing repository defect, green in CI

`poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
exits 1 with `1 failed, 10 passed` against an acceptance of exit 0 and `11 passed`.

The cause is established, not inferred: `git check-ignore -v .claude/state/current-session-id`
reports `.gitignore:67`, so the path is gitignored, while the test's repo-side enumeration walks the
filesystem and excludes only `settings.local.json` and `agent-memory/**`. This is the recorded
bundle-parity defect, open as issue **#510**: it fails locally and is green in CI, because CI's
checkout has no local session-state file.

The failure is pre-existing and unrelated to this cycle. It was observed at Phase 0 baseline, before
any source change on this branch — that is precisely what a baseline is for. The executor did not
delete the state file to force a pass, which is correct: that would be a local mutation that makes
the gate green without changing anything the gate is supposed to measure, and it is not durable.

### Disposition

P0-T10 stays `- [ ]`. It is a known-failing pre-existing gate with an open issue, not a regression
introduced here. The corresponding Phase 5 final-QC run of the same command is expected to fail
identically; the comparison that matters at Phase 5 is baseline-versus-post-change, and both ends of
that comparison carry the same pre-existing failure.

## Effect on the cycle

Neither task gates Phase 2. Both are recorded here and in the orchestrator checkpoint so that the
exit reaudit evaluates them on this evidence rather than reading two unchecked Phase 0 boxes as
incomplete work.
