# Skill Prose Verification (P6-T4, P6-T5)

Timestamp: 2026-08-24T20-25

Task: [P6-T4] pinned-marker survival plus skill-mirror parity; [P6-T5] `pathspec-bearing` presence
verification across the four skill files.

## Step 0 — Whole-directory clear of `.claude/state/` (P6-T4 precondition)

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -File -Force -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-CLEAR " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`

EXIT_CODE: 0

Output Summary: `none` — zero files were enumerated, so nothing was deleted. Post-clear listing
command `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name'`
(EXIT_CODE 0) emitted no names, confirming `.claude/state/` held zero files immediately before the
parity leg ran.

## Step 1 — Pinned marker tests (Pester)

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the worktree root and
`scan_folders` = `["tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1"]`

EXIT_CODE: 0

Output Summary: 35 tests, 0 failures, 0 errors (read from `artifacts/pester/pester-junit.xml`:
`tests=35 failures=0 errors=0`, elapsed 1.033 s). The #535 preparation-mode marker tests and the
verbatim-kickoff allow-case prompt tests pass without modification to any assertion, confirming the
pinned literals `Preparation mode: true.` and `route_id: preparation.` survived the Phase 6 prose
additions byte-unchanged.

## Step 2 — Claude push-down parity for the skill mirrors

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

Output Summary: 10 passed, 0 failed, 0.18 s. Every repo `.claude/**` file, including both edited
skill documents, is content-equal to its bundled counterpart.

## Step 3 — `pathspec-bearing` presence verification (P6-T5)

Command: `pwsh -NoProfile -Command "@('.claude/skills/epic-plan/SKILL.md','.claude/skills/parallel-plan/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md') | ForEach-Object { $m = Select-String -SimpleMatch -Pattern 'pathspec-bearing' -Path $_; Write-Output ($_ + ' matches=' + (@($m).Count)) }"`

EXIT_CODE: 0

Output Summary: match count at least 1 in each of the four files.

| Skill file | `pathspec-bearing` match count |
| --- | --- |
| `.claude/skills/epic-plan/SKILL.md` | 2 |
| `.claude/skills/parallel-plan/SKILL.md` | 2 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md` | 2 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | 2 |

## Step 4 — Additive-only confirmation and mirror hashes

Command: `git diff --numstat -- <the four skill paths>`

EXIT_CODE: 0

Output Summary: purely additive on every file — 27 insertions / 0 deletions for each `epic-plan`
copy and 28 insertions / 0 deletions for each `parallel-plan` copy. Zero deletions confirms no
pre-existing line was modified or removed and the pinned marker literals are untouched.

SHA-256 mirror equality (P6-T3), from
`pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 ..."` (EXIT_CODE 0):

| Pair | SHA-256 | Equal |
| --- | --- | --- |
| `epic-plan/SKILL.md` canonical and bundled | `39ECBB5AE26D49A480BC75A2A845C456B33D20DC66359A6AAD9399E89068612F` | yes |
| `parallel-plan/SKILL.md` canonical and bundled | `81167F87F5569A858A7909192CAEE1FC837F9CDAD9E65458EA9CF79E193E588E` | yes |
