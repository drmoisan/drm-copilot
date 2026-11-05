Timestamp: 2026-11-05T04-28
Command: inspect actual merged kcov Cobertura XML and completed Bats TAP log
EXIT_CODE: 0
Output Summary:
- Bats: 799 passed, 0 failed; full ordered format/lint/syntax/test loop passed.
- Raw kcov: 3616/4059 lines = 89.086%.
- Production Bash: 3616/3799 lines = 95.1829%. The only nonproduction class is .devcontainer/TROUBLESHOOTING.md (0/260), incorrectly classified by kcov; it remains disclosed in raw totals. No production file is excluded.
- Shared version predicate: 31/31 (100%).
- Workspace helper: 16/16 (100%).
- Verifier: 91/91 (100%).
- Post-create: 101/118 (85.5932%).
- Only current-source valid runs contribute: corrected full Bats, corrected Codespaces lifecycle, corrected local group-metadata boundary lifecycle. The invalid HOME attempt and pre-correction source reports do not contribute.
Raw report: SCRATCH/issue-1082-final-shell.xml
