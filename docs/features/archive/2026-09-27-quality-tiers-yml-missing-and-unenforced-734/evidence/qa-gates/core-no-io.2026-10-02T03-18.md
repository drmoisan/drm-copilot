# P2-T4 Core Performs No I/O (expect-fail search)

Timestamp: 2026-10-02T03-18
Command: git grep -n -E "^(import|from) (os|sys|io|subprocess|pathlib|shutil|tempfile)( |$|\.)|open\(|read_text|write_text|print\(" -- scripts/dev_tools/quality_tiers_contract.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No match in the committed core module (commit 85e8257e). The module imports only `__future__`, posixpath, re, dataclasses, typing names, yaml, and (under TYPE_CHECKING) collections.abc names; it contains no file, process, or console I/O call.
