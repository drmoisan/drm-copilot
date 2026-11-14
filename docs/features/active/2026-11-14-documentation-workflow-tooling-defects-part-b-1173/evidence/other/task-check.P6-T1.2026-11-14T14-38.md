# Task Check P6-T1

Timestamp: 2026-11-14T14-38
Command: sh SCRATCH/issue-1173-pysel.sh tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py (fail-before and pass-after; pytest -n auto); sh SCRATCH/issue-1173-py-repo-static.sh (black --check ., ruff check ., pyright); sh SCRATCH/issue-1173-pymirror.sh
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/python/docs_python_native/call_sites.py (new frozen records ProvisionalRole and RoleHandoff; CliResult gains provisional and handoffs), .claude/lib/docs/python/docs_python_native/cli_argparse.py (private _Scope, _scope, _parameter_position, _role and _handoffs; recognize_argparse seeds a parameter that receives add_parser as a provisional subparsers role with placeholder parser "#param-<function>-<parameter>" and no diagnostic, and records each call that passes a resolved subparsers receiver as a positional or keyword argument), and both bundle copies (cmp: byte-identical).
- Deviation: the plan says the records are carried "on CliSite and CliResult"; the sites keep their existing fields (the placeholder travels as the parent_id of the command site), and the two records live in call_sites.py beside CliSite and are carried on CliResult.
- Tests: TestProvisionalRole in test_docs_python_native_cli_argparse.py (seeded parameter role with no diagnostic and the command and option parents; signature position counting self; a non-parameter add_parser receiver, an add_argument on a parameter and a module-level receiver stay CLI_UNBOUND_REGISTRATION; positional and keyword handoffs with qualified callees, and no handoff for a root argument).
- Fail-before: collection error, ProvisionalRole cannot be imported from call_sites.
- First static run: Ruff E501 on two new test docstrings; shortened. Pass-after: Black "1063 files would be left unchanged.", Ruff "All checks passed!", Pyright 0 errors; the argparse selection 12 passed; the argparse, cli and corpus selection 22 passed; mirror pytest 23 passed.
- Sizes: cli_argparse.py 522 (guidance tier), call_sites.py 315.
