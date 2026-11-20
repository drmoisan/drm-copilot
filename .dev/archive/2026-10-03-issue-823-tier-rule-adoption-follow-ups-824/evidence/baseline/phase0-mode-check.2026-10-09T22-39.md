# P0-T1 Phase 0 Mode Check

Timestamp: 2026-10-09T22-39
Command: cp --version; mkdir --version; tail --version; wc --version; npm --version; node --version; npx --version; poetry run python --version; sh -c "exit 0" (OPS-1: not run); git branch --show-current; ls docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824; grep -c '^## Acceptance Criteria$' docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md; grep -c "^- \[ \] AC-[0-9]" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md; grep -c -F -e "- Work Mode: full-bug" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md
EXIT_CODE: 0
Output Summary:
- Route probes (command order):
  - cp --version: EXIT 0; first line "cp (GNU coreutils) 8.32"
  - mkdir --version: EXIT 0; first line "mkdir (GNU coreutils) 8.32"
  - tail --version: EXIT 0; first line "tail (GNU coreutils) 8.32"
  - wc --version: EXIT 0; first line "wc (GNU coreutils) 8.32"
  - npm --version: EXIT 0; first line "11.9.0"
  - node --version: EXIT 0; first line "v24.14.0"
  - npx --version: EXIT 0; first line "11.9.0"
  - poetry run python --version: EXIT 0; first line "Python 3.13.12"
  - sh -c "exit 0": OPS-1: not run (sh route prohibited by operator)
- Note: a first attempt that wrapped the probes in a shell for-loop was refused by the worktree isolation guard ("this command runs a command whose name is computed at runtime inside a construct too complex to verify"); the probes were then run as plain separate commands, unchanged. No probe command itself was denied.
- git branch --show-current: EXIT 0; "bug/issue-823-tier-rule-adoption-follow-ups-824"
- ls FEATURE: EXIT 0; issue.md, plan.2026-10-08T22-16.md, research/, spec.md (spec.md and issue.md present; no user-story.md)
- Acceptance-heading grep: EXIT 0; 1
- AC checkbox grep: EXIT 0; 15
- Work-mode grep: EXIT 0; 1
- Result: PASS (full-bug preconditions satisfied)
