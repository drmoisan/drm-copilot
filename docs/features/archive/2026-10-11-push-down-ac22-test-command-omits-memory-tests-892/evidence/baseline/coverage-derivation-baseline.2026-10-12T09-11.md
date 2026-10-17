Timestamp: 2026-10-12T09-11
Command: Grep tool, output_mode=content, -o=true, pattern `<class name="push_down_claude_[a-z_]+\.py"[^>]*>`, path artifacts/python/coverage-892-baseline.xml; Stmts, Miss, Branch, and Cover taken from the term-missing table of the P0-T7 command (poetry run pytest <original seven test files> --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=xml:artifacts/python/coverage-892-baseline.xml)
EXIT_CODE: 0
Output Summary:
Four matches found (one per module); both cross-checks pass for every module. No <source> element recorded.

Matched elements (verbatim):
11:<class name="push_down_claude_customizations.py" filename="scripts/dev_tools/push_down_claude_customizations.py" complexity="0" line-rate="0.9367" branch-rate="0.875">
95:<class name="push_down_claude_filesystem.py" filename="scripts/dev_tools/push_down_claude_filesystem.py" complexity="0" line-rate="0.9292" branch-rate="0.7857">
213:<class name="push_down_claude_gitignore_merge.py" filename="scripts/dev_tools/push_down_claude_gitignore_merge.py" complexity="0" line-rate="1" branch-rate="1">
266:<class name="push_down_claude_pack_selection.py" filename="scripts/dev_tools/push_down_claude_pack_selection.py" complexity="0" line-rate="0.9398" branch-rate="0.8333">

Per-module derivation (baseline, original command):
| Module | covered_lines/Stmts | line % | covered_branches/Branch | branch % | XML line-rate check | Cover cross-check (printed) |
| push_down_claude_customizations.py | 74/79 | 93.67 | 14/16 | 87.50 | 0.9367 = 74/79: pass | round(100*88/95)=93 = 93%: pass |
| push_down_claude_filesystem.py | 105/113 | 92.92 | 22/28 | 78.57 | 0.9292 = 105/113: pass | round(100*127/141)=90 = 90%: pass |
| push_down_claude_gitignore_merge.py | 48/48 | 100.00 | 14/14 | 100.00 | 1 = 48/48: pass | round(100*62/62)=100 = 100%: pass |
| push_down_claude_pack_selection.py | 78/83 | 93.98 | 25/30 | 83.33 | 0.9398 = 78/83: pass | round(100*103/113)=91 = 91%: pass |
