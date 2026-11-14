# Task Check P6-T2

Timestamp: 2026-11-14T14-44
Command: sh SCRATCH/issue-1173-pysel.sh tests/scripts/claude-lib/docs/python/test_docs_python_native_cli.py (fail-before); sh SCRATCH/issue-1173-black.sh over cli.py and the test; sh SCRATCH/issue-1173-pysel.sh over the cli, cli_argparse and corpus tests (pytest -n auto); sh SCRATCH/issue-1173-py-repo-static.sh; sh SCRATCH/issue-1173-pymirror.sh
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/python/docs_python_native/cli.py (_FileSites carries the provisional roles and handoffs; private _under and _bind; analyze_cli keeps one resolution memo per file and binds each role of function f in module m to the first handoff, in path order, whose callee is m.f and whose position or keyword names the parameter, so the commands and options registered through the parameter resolve under the caller's command with the same declaration, parent and path rules; a role with no such handoff reports CLI_UNBOUND_REGISTRATION at every site beneath it) and its bundle copy (cmp: byte-identical).
- Tests: TestCrossModuleRegistration in test_docs_python_native_cli.py (bound case: "tool daily" in cli_daily.py with parent ("cli-command", "tool", "src/pkg/cli.py") and "tool daily --date" under it, no diagnostics; an attached console-script root names the bound commands; unresolvable caller: CLI_UNBOUND_REGISTRATION at lines 2 and 3 and no fact beneath the parameter).
- Fail-before: 3 failed, 6 passed.
- First pass-after run: 1 failed (the new test read a path attribute that Fact does not have; it now reads the path from the facts map key); Black reformatted cli.py once. Rerun: 25 passed over the three selections; Black "1063 files would be left unchanged.", Ruff "All checks passed!", Pyright 0 errors; mirror pytest 23 passed.
- Size: cli.py 357.
