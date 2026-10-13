# AC-5 sys.path mutation search of scripts/ (issue #886)

Timestamp: 2026-10-12T11-20

Command: git grep --untracked -n -E "sys\.path|__package__|addsitedir|PYTHONPATH" -- scripts

EXIT_CODE: 0

SearchScope: scripts/ (tracked and untracked, excluding ignored files)

SearchPatterns: `sys\.path|__package__|addsitedir|PYTHONPATH`

SearchResult:
- `scripts/dev_tools/validate_orchestration_artifacts.py:17:sys.path[:0] += [str(Path(__file__).resolve().parents[2])] if not __package__ else []` (mutation; the fixed bootstrap from P1-T7)

Output Summary: exactly one line printed, the validator's own bootstrap at line 17, now the prepend form. No other file under scripts/ mutates sys.path, so no additional script needs a consistent fix.
