# P0-T3 Base Reference

Timestamp: 2026-09-27T03-15
Command: git merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary: Branch is bug/preimplementation-gate-blocks-attribution-trailers-713 at 6747ee77; merge-base with origin/main is 2d9bb87c; the in-scope numstat base..HEAD is empty, so BASE_RULE is merge-base and BASE_SHA is 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d. Porcelain lists only feature-folder paths.

Deviation: X2 (see `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/execution-deviations.md`). The merge-base is computed against `origin/main` rather than the stale local `main` ref (2dce111e).

Other commands and exit codes:
- `git rev-parse --abbrev-ref HEAD` EXIT_CODE: 0
- `git rev-parse HEAD` EXIT_CODE: 0
- `git status --porcelain` EXIT_CODE: 0
- `git diff --numstat 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d 6747ee7729939467b2181b99a9893599de7ade55 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .claude/skills/parallel-plan/SKILL.md .claude/skills/epic-plan/SKILL.md` EXIT_CODE: 0

BRANCH: bug/preimplementation-gate-blocks-attribution-trailers-713
HEAD_SHA: 6747ee7729939467b2181b99a9893599de7ade55
MERGE_BASE_SHA: 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d
BASE_RULE: merge-base
BASE_SHA: 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d

Numstat output (BASE..HEAD, in-scope files):

```text
(empty)
```

Branch commits since BASE_SHA (context, `git log --oneline 2d9bb87c..HEAD`): six `docs(713)` commits (feature folder, research, spec, plan, two plan revisions); none touches an in-scope code or skill path.

Porcelain:

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/
```
