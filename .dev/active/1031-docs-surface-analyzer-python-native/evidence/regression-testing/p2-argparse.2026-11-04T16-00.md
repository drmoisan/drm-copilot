# [P2-T1] PKG/cli_argparse.py

Timestamp: 2026-11-04T16-00
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py
EXIT_CODE: 0
Output Summary: 8 passed, 0 failed, 0 errors. Cases: ArgumentParser root with literal prog= spanning three lines, attach to the enclosing function or the receiver; long, short and positional add_argument with required=, action=, help= and default= in varied keyword order; add_subparsers, nested add_parser and add_argument_group mapping; CLI_DYNAMIC_REGISTRATION (name, f-string, starred, prog, add_parser), CLI_REGISTRATION_IN_LOOP (for body, comprehension), CLI_UNBOUND_REGISTRATION (parameter, attribute, call result, broken chain) and CLI_PARENTS_UNRESOLVED, each removing only its own site while the other sites survive; silence on a tracked non-argparse receiver.
