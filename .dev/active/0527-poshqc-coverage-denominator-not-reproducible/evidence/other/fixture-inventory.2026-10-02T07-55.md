# Consumer Fixture Inventory (P1-T5)

Timestamp: 2026-10-02T07-55
Command: git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer; git ls-files -- tests/fixtures/poshqc-consumer; find tests/fixtures/poshqc-consumer -type f | sort; test -e tests/fixtures/poshqc-consumer/config; git check-ignore tests/fixtures/poshqc-consumer/scripts/Sample.psm1 tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1
EXIT_CODE: 0
Output Summary: exactly the three fixture files exist; CONFIG_DIR=False; check-ignore exits 1 (none of the three is ignored). Captured before the MCP fixture run, so no run output existed under the fixture.
- Deviation DEV-P1-T5 (git/static equivalent of the `pwsh` Get-ChildItem inventory). The plan's `git check-ignore -q <three paths>` form exits 128 (`fatal: --quiet is only valid with a single pathname`); the same check without `-q` was run and exited 1.

## File inventory (all files under the fixture, sorted)

```text
tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1
tests/fixtures/poshqc-consumer/scripts/Sample.psm1
tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1
CONFIG_DIR=False
```

## git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer

```text
?? tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1
?? tests/fixtures/poshqc-consumer/scripts/Sample.psm1
?? tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1
```

`git ls-files -- tests/fixtures/poshqc-consumer`: no output (the three files are not yet tracked).

## Ignore check

- `git check-ignore -q <three paths>` (plan form): exit 128, `fatal: --quiet is only valid with a single pathname`.
- `git check-ignore <three paths>`: no output, CHECK_IGNORE_EXIT=1 (none ignored; all three can be committed).
