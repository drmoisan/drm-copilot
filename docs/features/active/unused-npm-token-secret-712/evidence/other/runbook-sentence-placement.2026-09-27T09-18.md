# Runbook Sentence Placement (P3-T4)

Timestamp: 2026-09-27T09-18
Command: grep -c -F "historical reference only. The unused" docs/engineering/npm-token-rotation.runbook.md
EXIT_CODE: 0
Output Summary: 1 (the sentence sits on the superseded-notice line directly after the anchor)

Supplementary observation: `git diff --numstat HEAD -- docs/engineering/npm-token-rotation.runbook.md` printed `1	1	docs/engineering/npm-token-rotation.runbook.md` after the edit (one line changed, no other byte of the file changed).
