# Phase 0 Line-Count Baseline (AC-25) — Issue #621

Task: [P0-T4]
Branch: feature/push-down-destination-exclusion-manifest-exec-621
HEAD: 9438bdf5253e10903e2e74eab5cf51df988e0466

Timestamp: 2026-09-29T20-00
Command: for f in <each existing file in plan section 3 "modified" lists>; do printf '%s\t%s\n' "$f" "$(awk 'END{print NR}' "$f")"; done
EXIT_CODE: 0

Command substitution: the plan names `(Get-Content -LiteralPath <path>).Count`. The worktree isolation guard refused the `pwsh` invocation for this agent. `awk 'END{print NR}'` was used instead; it counts lines by the same rule as `(Get-Content).Count` (a trailing newline adds no line; a final unterminated line is counted).

| Path | Lines |
| --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 419 |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | 448 |
| `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` | 201 |
| `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` | 406 |
| `extensions/drm-copilot/jest.config.cjs` | 330 |
| `scripts/dev_tools/push_down_claude_customizations.py` | 447 |
| `pyproject.toml` | 165 |
| `README.md` | 415 |
| `extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts` | 198 |
| `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts` | 209 |
| `extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts` | 214 |

Output Summary: One integer recorded per existing file (11 files). Deviations from the plan's stated values, all attributable to #507 (PR #777) and #508 (PR #778) being merged on this branch, contrary to plan rule 14's assumption:
- `claude-customizations.ts`: observed 419, plan stated 361 (+58; touched by commit a6f090e8, `fix(508)`). Watch-list projection 419 + about 50 = about 469, below 500.
- `jest.config.cjs`: observed 330, plan stated 325 (+5).
- `push_down_claude_customizations.py`: observed 447, plan stated 403 before #507/#508 (touched by e263e942 `fix(507)` and 7fdfe009 `fix(508)`). 447 is at or below 460, so the section 3 helper route (`apply_exclusion_filter_and_report`) is not triggered by this count.
- `push-down-service-call.ts` 201 and `repo-automation-command-registration-admin.ts` 406 match the plan.
Consequence for later phases: line citations into `claude-customizations.ts` in plan section 2 items 6 and 14 (for example `:239-322`, `:260-261`, `:294-306`, `:311`, `:346-361`) were made against the pre-#508 file and may be shifted; [P1-T3] records the observed seam lines.
