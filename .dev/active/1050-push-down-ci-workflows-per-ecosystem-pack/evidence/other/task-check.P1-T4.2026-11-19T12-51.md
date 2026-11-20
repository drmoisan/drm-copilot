# Task Check P1-T4 (advisory-fix plan: README copy-mode note)

Timestamp: 2026-11-19T12-51
Command: grep -c "top-level tests directory" extensions/drm-copilot/README.md; npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/README.md
EXIT_CODE: 0
Output Summary: token count 1 in `## Push-Down CI Workflows`; Prettier check exit 0. No contract test reads extensions/drm-copilot/README.md, so the test selection is empty.

Changed files:
- extensions/drm-copilot/README.md (one bullet in `## Push-Down CI Workflows`)

Selection rule: contract tests that read the changed Markdown path. Searches: the extension test tree under `test/lib/push-down` for `README` (two unrelated in-memory names, no read of the extension README) and `tests/` for `drm-copilot.{0,20}README` (no files). Selection: none.
