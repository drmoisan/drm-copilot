# P10-T3 AC-14 vswhere Check

Timestamp: 2026-10-10T00-28
Command: git diff --unified=0 --output=artifacts/orchestration/wip824-hunks/codex-setup-final.diff b50df12b6467789d67118c994a5fd56a2fc8db81 -- .codex/codex-web-setup.sh; git status --porcelain -- .codex/codex-web-setup.sh; grep -c -F "vswhere_check" .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh; grep -c -e "^[-+].*vswhere" artifacts/orchestration/wip824-hunks/codex-setup-final.diff
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 1. Diff anchored to BASE_SHA (exit 0): written to the git-ignored artifacts/orchestration/wip824-hunks/codex-setup-final.diff; the file holds 68 lines (non-empty; `wc -l` cross-check), so the hunk search below is not vacuous.
- 2. Status (exit 0): empty (the change is committed; the BASE_SHA-anchored diff carries it).
- 3. vswhere_check grep (exit 1, both counts 0): ".codex/codex-web-setup.sh:0"; "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh:0". Met.
- 4. Hunk grep for added/removed lines mentioning vswhere (exit 1): "0". Met.
- Result: PASS (AC-14 vswhere condition holds on the final tree).
