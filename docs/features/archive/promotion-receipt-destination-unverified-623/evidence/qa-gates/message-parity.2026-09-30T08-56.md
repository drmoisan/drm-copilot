# Message Parity (AC-8) (#623)

Timestamp: 2026-09-30T08-56
Command: git grep -n -F "Promoted file missing after move: " -- extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: Exactly two output lines, one per runtime; both emit the literal "Promoted file missing after move: " followed by the destination path.

Output (verbatim):

```
extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts:444:    emitLine(`Promoted file missing after move: ${destPath}`);
scripts/dev_tools/potential_to_issue.py:470:        _emit(f"Promoted file missing after move: {dest_path}")
```
