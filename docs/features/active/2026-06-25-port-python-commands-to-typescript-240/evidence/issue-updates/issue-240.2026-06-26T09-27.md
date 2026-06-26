# Issue #240 — Epic AC Update Mirror (F11 completion)

Timestamp: 2026-06-26T09-27
PostedAs: unknown

This mirror records the epic-completion AC update made during F11 (the final feature of epic #240). The change was applied to the local feature spec mirror at `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/spec.md`. No GitHub issue body/comment was posted by this executor; if/when posted, update `PostedAs` and the URL.

## Spec ACs marked satisfied (epic completion)

- AC-E3 — `[ ]` -> `[x]`: `RepoAutomationService` methods invoke in-process TypeScript instead of spawning Python; the `"python"` runtime branch and bundled Python resources are removed (delivered by F11).
- AC-E4 — `[ ]` -> `[x]`: No remaining runtime dependency on a `python` interpreter for extension or MCP command execution.

## Epic #240 status at F11 completion

- AC-E1 (parity), AC-E2 (coverage): delivered by F1–F10.
- AC-E3, AC-E4: delivered by F11 (this change).
- AC-E5 (CI gates pass): both TypeScript and Python suites green at F11 completion.

Supporting evidence: `evidence/qa-gates/f11-acceptance.md`, `evidence/qa-gates/no-python-audit.md`, `evidence/qa-gates/test-coverage-final.md`, `evidence/qa-gates/python-test-final.md`.
