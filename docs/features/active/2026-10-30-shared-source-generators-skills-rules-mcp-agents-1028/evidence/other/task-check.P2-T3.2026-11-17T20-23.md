# Task Check — [P2-T3]

Timestamp: 2026-11-17T20-23
Command: grep -rln (the removed and added phrases, and the section headings) tests extensions/drm-copilot/test (selection search)
EXIT_CODE: 0
Output Summary: Empty selection. The task changed two Markdown files, and no contract test reads the changed sections or phrases. The only `README.md` matches under `tests/` are fixture paths such as `.github/hooks/README.md` in converter tests, which are unrelated to these files. No format, lint or type check applies to Markdown.

Changed files: `README.md`, `scripts/dev_tools/codex_native_converter/README.md`, `<FEATURE>/evidence/qa-gates/converter-parity.2026-11-17T20-23.md`.
Selection rule: `## Test Cadence (Mandatory)`. A changed Markdown path selects the contract tests that read it; none reads these.
