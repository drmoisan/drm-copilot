# Pre-Gate Sync (P6-T9)

Timestamp: 2026-11-14T08-02
Command: `git fetch origin main`; `git merge --no-edit origin/main`; Pester `Run.Path` = the debugging selection below, `Run.Exit` = `$true`; `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <contract selection>`; `generate_codex_agent_variants --check`; `git status --porcelain`
EXIT_CODE: 0
Output Summary: plain merge of `origin/main` into the branch with no conflict (merge commit subject `Merge remote-tracking branch 'origin/main' into feature/test-execution-policy-machine-lock-1158`); registration branch A remains in force because #1159 is not in the merge base; ledger entry number in force `0012`; no re-application needed; ledger tests 20 passed, 0 failed; Registration test 8 passed, 0 failed; `test-execution-command-form.Tests.ps1` 322 passed, 0 failed; `parallel-gate-wording.Tests.ps1` 88 passed, 0 failed; pytest contract selection 84 passed, 0 failed; generator `--check` exit 0; `git status --porcelain` empty after the merge commit.

## Merge Result

- Main brought PR #1175 (issue #1169, documentation workflow end to end), which edits the six `execution-environment` brief copies and both `core.json` pack manifests. Git merged both files without conflict.
- An earlier merge in this run (before P5-T2) brought PR #1174 (issue #1160), with its changes to the preimplementation gate and the brief.
- After the merge the six brief copies share one SHA-256 (prefix b7749a6ea6b86f06), and each still carries the lane statement once.

## Sibling Status

| Sibling | In the merge base of `origin/main` and `HEAD` | Effect |
|---|---|---|
| #1156 | yes (merged before this run) | none on this item's files beyond text merges |
| #1157 | yes | none |
| #1159 | no | registration branch A in force: direct `Bash` and MCP groups in `.claude/settings.json`, `.codex/config.toml`, and their bundle copies; no `pretooluse-dispatch.json` registry exists at `.claude/hooks/` or `.codex/hooks/`, so there are no #1159 registry or timeout-sum tests to name |
| #1160 | yes | `Read-CommandLineInvocationSegment` and `Skip-CommandLineTransparentWrapper` changed since P0-T1; `test-execution-command-form.Tests.ps1` re-run as a debugging run: 322 passed |
| #1161 | yes | none |
| #1162 | not observed in the merged history | none |
| #1163 | yes | none |

## Ledger

- Entries in force: `0001` to `0012`; main added no entry, so this item's entry keeps number `0012`.
- No sibling change edits a region that this item rebased; no record needed re-application.
- `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`: 5 passed, 0 failed. `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`: 15 passed, 0 failed.

## Debugging Runs

| Suite | Passed | Failed |
|---|---|---|
| `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | 5 | 0 |
| `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | 15 | 0 |
| `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1` | 8 | 0 |
| `tests/scripts/claude-hooks/test-execution-command-form.Tests.ps1` | 322 | 0 |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 88 | 0 |
| pytest: brief contracts, resource contracts, pack-manifest completeness and closure, skill-bundle contract | 84 | 0 |
