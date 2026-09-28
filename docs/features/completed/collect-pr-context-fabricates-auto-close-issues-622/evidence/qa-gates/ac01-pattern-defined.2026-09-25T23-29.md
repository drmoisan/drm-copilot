# AC 1 Pattern Defined (P10-T1)

Timestamp: 2026-09-26T20-27
Branch: N588

Command: grep -c -F -e 're.compile(r"(?<!\w)#\d+(?!\w)", re.ASCII)' scripts/dev_tools/pr_context/models.py
EXIT_CODE: 0
Output Summary: Printed `1`. The Python shared pattern is defined exactly once in models.py.

Command: grep -c -F -e "export const ISSUE_REFERENCE_PATTERN = /(?<!\w)#\d+(?!\w)/u;" extensions/drm-copilot/src/lib/pr-context/models.ts
EXIT_CODE: 0
Output Summary: Printed `1`. The TypeScript shared pattern is exported exactly once from models.ts.
