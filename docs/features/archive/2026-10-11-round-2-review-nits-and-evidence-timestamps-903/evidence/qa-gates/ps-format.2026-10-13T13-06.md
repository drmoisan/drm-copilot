# PowerShell Format (P12-T12)

Timestamp: 2026-10-13T13-06
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", ".claude/lib/blast-radius", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]; git status --porcelain
EXIT_CODE: 0
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414
Loop-Iteration: 1

EXIT_CODE is the MCP call disposition only (`"ok":true`). No formatter count is asserted from it; the tree observation below is the acceptance signal.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 8 selected scan folder(s)."}
```

Porcelain before format (`<FEATURE>` = docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903):
```
 M <FEATURE>/plan.2026-10-11T10-39.md
?? <FEATURE>/evidence/qa-gates/py-black-check.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/py-contract-suites.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/py-cov-token-shapes.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-coverage-totals.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-pyright.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/py-pytest-full.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-ruff.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/ts-eslint.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/ts-jest-coverage.2026-10-13T13-06.md
?? <FEATURE>/evidence/qa-gates/ts-prettier-check.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/ts-tsc-jest.2026-10-13T13-05.md
```

Porcelain after format:
```
 M <FEATURE>/plan.2026-10-11T10-39.md
?? <FEATURE>/evidence/qa-gates/py-black-check.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/py-contract-suites.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/py-cov-token-shapes.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-coverage-totals.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-pyright.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/py-pytest-full.2026-10-13T13-04.md
?? <FEATURE>/evidence/qa-gates/py-ruff.2026-10-13T13-02.md
?? <FEATURE>/evidence/qa-gates/ts-eslint.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/ts-jest-coverage.2026-10-13T13-06.md
?? <FEATURE>/evidence/qa-gates/ts-prettier-check.2026-10-13T13-05.md
?? <FEATURE>/evidence/qa-gates/ts-tsc-jest.2026-10-13T13-05.md
```

Restore: none required.

Output Summary: PASS. Call disposition ok:true. The two porcelain outputs are identical and list only `<FEATURE>` paths; the formatter changed no file in the eight scan folders.
