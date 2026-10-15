Timestamp: 2026-10-12T09-23
Command: P2-T1 pytest command (amended nine test files, --cov-report=term-missing); P2-T2 pytest command (same plus --cov-report=xml:artifacts/python/coverage-892-amended.xml); Grep tool, output_mode=content, -o=true, pattern `<class name="push_down_claude_[a-z_]+\.py"[^>]*>`, path artifacts/python/coverage-892-amended.xml
EXIT_CODE: 0
Output Summary:
P2-T1 exit code: 0 (116 passed). P2-T2 exit code: 0 (116 passed). Four matches found (one per module); both cross-checks pass for every module. No <source> element recorded.

Matched elements (verbatim):
11:<class name="push_down_claude_customizations.py" filename="scripts/dev_tools/push_down_claude_customizations.py" complexity="0" line-rate="0.9367" branch-rate="0.875">
95:<class name="push_down_claude_filesystem.py" filename="scripts/dev_tools/push_down_claude_filesystem.py" complexity="0" line-rate="0.9646" branch-rate="0.9286">
213:<class name="push_down_claude_gitignore_merge.py" filename="scripts/dev_tools/push_down_claude_gitignore_merge.py" complexity="0" line-rate="1" branch-rate="1">
266:<class name="push_down_claude_pack_selection.py" filename="scripts/dev_tools/push_down_claude_pack_selection.py" complexity="0" line-rate="0.9398" branch-rate="0.8333">

Per-module coverage, amended command (P2-T2 table):
| Module | line % (covered_lines/Stmts) | branch % (covered_branches/Branch) | line >= 85 | branch >= 75 | XML line-rate check | Cover cross-check (printed) |
| push_down_claude_customizations.py | 93.67 (74/79) | 87.50 (14/16) | yes | yes | 0.9367 = 74/79: pass | round(100*88/95)=93 = 93%: pass |
| push_down_claude_filesystem.py | 96.46 (109/113) | 92.86 (26/28) | yes | yes | 0.9646 = 109/113: pass | round(100*135/141)=96 = 96%: pass |
| push_down_claude_gitignore_merge.py | 100.00 (48/48) | 100.00 (14/14) | yes | yes | 1 = 48/48: pass | round(100*62/62)=100 = 100%: pass |
| push_down_claude_pack_selection.py | 93.98 (78/83) | 83.33 (25/30) | yes | yes | 0.9398 = 78/83: pass | round(100*103/113)=91 = 91%: pass |

The threshold observation is recorded as observed and does not change AC-22 status in the #790 spec.
