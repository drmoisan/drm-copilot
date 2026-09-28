# AC3 Runbook Single-Line Change Check (P6-T4)

Timestamp: 2026-09-27T09-23
Scope: local evidence only (origin/main fetched at 91cffc3b)

Command: git fetch origin main
EXIT_CODE: 0
Output Summary: fetched `main` into FETCH_HEAD.

Command 2: git diff --numstat origin/main...HEAD -- docs/engineering/npm-token-rotation.runbook.md
EXIT_CODE 2: 0
Output Summary 2: `1	1	docs/engineering/npm-token-rotation.runbook.md` (one line changed; the edit is committed in b89b2108)

Command 3: git diff --numstat HEAD -- docs/engineering/npm-token-rotation.runbook.md
EXIT_CODE 3: 0
Output Summary 3: no output (no uncommitted change)

Across the two numstat outputs exactly one line is printed, and it reads `1`, tab, `1`, tab, `docs/engineering/npm-token-rotation.runbook.md`.

Supporting artifacts:
- P3-T3: `docs/features/active/unused-npm-token-secret-712/evidence/other/runbook-sentence-occurrence.2026-09-27T09-18.md` (one output line, EXIT_CODE 0)
- P3-T4: `docs/features/active/unused-npm-token-secret-712/evidence/other/runbook-sentence-placement.2026-09-27T09-18.md` (`1`, EXIT_CODE 0)

Result: acceptance met.
