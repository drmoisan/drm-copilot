# P9-T13 Post-Change PowerShell Coverage Values (OPS-2 substitution)

Timestamp: 2026-10-10T00-22
Command: git diff --stat f03407757f313e34a1a58062c241a5cd1586374c HEAD -- .claude/hooks scripts/powershell config tests/scripts/claude-hooks; G5 one-liner with input 'artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml'; git diff --no-color --unified=0 --output=artifacts/orchestration/wip824-hunks/hook-final.diff b50df12b6467789d67118c994a5fd56a2fc8db81 -- .claude/hooks/validate-feature-review-coverage.ps1; git status --porcelain -- .claude/hooks/validate-feature-review-coverage.ps1; G7 one-liner with its XML input changed to 'artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml'
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1
- OPS-2: PowerShell coverage values come from the poshqc-test-results artifact of branch CI run 38022356096 (_poshqc.yml at f03407757, conclusion success), downloaded by the orchestrator into artifacts/orchestration/ci-final-poshqc/, because the MCP runner's coverage population omits the hook.
- 1. Tree-equivalence check `git diff --stat f03407757... HEAD -- .claude/hooks scripts/powershell config tests/scripts/claude-hooks`: exit 0, empty output. The CI artifact represents the current tree for these paths.
- 2. G5 (exit 0): "REPO_LINE 88.63 SOURCEFILES 179"; "FILE .claude/hooks/validate-feature-review-coverage.ps1 95.28"; "FILE .claude/hooks/feature-review-coverage-thresholds.ps1 100.0". Matches the orchestrator's run.
- FINAL_PS_LINE 88.63 (>= BASE_PS_LINE 88.0). Met.
- FINAL_HOOK_COV 95.28 (>= 85 and >= BASE_HOOK_COV 49.52). Met.
- FINAL_HELPER_COV 100.0 (>= 85; whole-file value is its new-code coverage). Met.
- 3. Hunk diff anchored to BASE_SHA b50df12b6467789d67118c994a5fd56a2fc8db81: exit 0; written to the git-ignored artifacts/orchestration/wip824-hunks/hook-final.diff (folder created with mkdir -p; it was absent in this worktree).
- 4. Status: exit 0, empty (committed state).
- 5. G7 (exit 0): "CHANGED_LINES 20 EXECUTABLE_CHANGED 7 UNCOVERED_CHANGED NONE" (FINAL_HOOK_CHANGED_LINES). CHANGED_LINES > 0, EXECUTABLE_CHANGED > 0, no uncovered changed line. Met.
- Result: PASS
