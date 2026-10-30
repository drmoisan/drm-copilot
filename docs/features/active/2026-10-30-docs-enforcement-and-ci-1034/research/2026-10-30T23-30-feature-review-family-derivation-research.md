# docs-enforcement-and-ci (#1034) - Feature-review Family Derivation

- Issue: #1034
- Purpose: supporting numeric derivation for the `spec.md` and `user-story.md` acceptance criteria that
  enumerate the edited and unedited feature-review surfaces.
- Relationship to the primary research: `research/research.2026-10-30T23-01.md` section 4.5 and its
  `## Numeric Derivation Evidence` describe the same family. That record lists the primary member set
  but describes the cross-check member set only by derivation. This record re-runs both searches in
  this worktree on 2026-10-30 and enumerates both member sets path by path.

## Numeric Derivation Evidence

Claim: the feature-review family comprises 26 files; 1034 edits 12 of them and leaves 14 unedited.

- Complete Family: every agent, converted Codex agent, generated Codex agent variant and skill file
  that defines feature-review behavior on the Claude (`.claude/`), Codex (`.codex/`), `.agents` and
  Copilot (`.github/`) surfaces, including every bundle copy under `extensions/drm-copilot/resources/`
  (`claude-customizations`, `codex-and-agents-customizations`, `customizations`).
- Exhaustive Search Scope: the whole worktree, excluding `docs/**` (feature folders and archives hold
  historical evidence files, not runtime surfaces).
- Inclusion Rules: an agent file, Codex agent TOML file or skill `SKILL.md` file whose file name or
  containing directory name begins with `feature-review`, or whose frontmatter `name:` / TOML
  `name =` value is a feature-review family name (`feature-review`, `feature-reviewer`,
  `feature-reviewer-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`, `feature-review-workflow`,
  `feature_code_review_agent`).
- Exclusion Rules: hooks (`feature-review-coverage-thresholds.ps1` in `.claude/hooks/`,
  `.codex/hooks/` and their bundle copies); prompts (`.codex/prompts/feature-review-remediate.md` and
  its bundle copy); test files under `tests/`; anything under `docs/**`; index files that only mention
  a family name (`.github/skills/README.md` and
  `extensions/drm-copilot/resources/customizations/.github/skills/README.md`).
- Primary Search Strategy or Query Expression: file-name search. Glob `**/feature-review*` (files)
  and Glob `**/feature-review*/**` (files under skill directories), then the inclusion and exclusion
  rules above.
- Primary Member Set (repository-relative paths):
  1. `.claude/agents/feature-review.md`
  2. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`
  3. `.codex/agents/feature-review.toml`
  4. `.codex/agents/feature-reviewer.toml`
  5. `.codex/agents/feature-reviewer-c1.toml`
  6. `.codex/agents/feature-reviewer-c2.toml`
  7. `.codex/agents/feature-reviewer-c3.toml`
  8. `.codex/agents/feature-reviewer-c3-elevated.toml`
  9. `.codex/agents/feature-reviewer-c4.toml`
  10. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`
  11. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer.toml`
  12. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c1.toml`
  13. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c2.toml`
  14. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3.toml`
  15. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3-elevated.toml`
  16. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c4.toml`
  17. `.github/agents/feature-review.agent.md`
  18. `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`
  19. `.claude/skills/feature-review-workflow/SKILL.md`
  20. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`
  21. `.agents/skills/feature-review-workflow/SKILL.md`
  22. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`
  23. `.github/skills/feature-review-workflow/SKILL.md`
  24. `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`
  25. `.agents/skills/feature-review/SKILL.md`
  26. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md`
- Primary Count: 26 (18 agent files: 2 Claude, 14 Codex, 2 Copilot; 8 skill files).
- Cross-check Search Strategy or Query Expression: content search, independent of file names. Grep
  `^name(:| =) "?(feature-review(er)?(-workflow|-c1|-c2|-c3|-c3-elevated|-c4)?|feature_code_review_agent)"?\s*$`
  over the worktree with glob `!docs/**`, files-with-matches mode; then the exclusion rules above.
- Cross-check Member Set: the Grep returned 28 files. Removing the two excluded index files
  (`.github/skills/README.md`, `extensions/drm-copilot/resources/customizations/.github/skills/README.md`)
  leaves these 26 paths:
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`;
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`;
  `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`;
  `.github/skills/feature-review-workflow/SKILL.md`;
  `.github/agents/feature-review.agent.md`;
  `.codex/agents/feature-reviewer.toml`;
  `.codex/agents/feature-reviewer-c4.toml`;
  `.codex/agents/feature-reviewer-c3.toml`;
  `.codex/agents/feature-reviewer-c3-elevated.toml`;
  `.codex/agents/feature-reviewer-c2.toml`;
  `.codex/agents/feature-reviewer-c1.toml`;
  `.codex/agents/feature-review.toml`;
  `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`;
  `.claude/skills/feature-review-workflow/SKILL.md`;
  `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c4.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3-elevated.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c1.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c2.toml`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`;
  `.claude/agents/feature-review.md`;
  `.agents/skills/feature-review/SKILL.md`;
  `.agents/skills/feature-review-workflow/SKILL.md`.
- Cross-check Count: 26.
- Member-set Comparison: both sets were normalized to forward-slash repository-relative paths and
  compared path by path. Every one of the 26 primary paths appears in the cross-check set and every
  one of the 26 cross-check paths appears in the primary set; no path appears in only one set. The
  primary search additionally surfaced hooks, prompts, tests and `docs/**` evidence files, all
  removed by the exclusion rules; the cross-check additionally surfaced the two `README.md` index
  files, removed by the same rules. The derivations differ in strategy (file-name globbing versus
  `name` field content search), so agreement is not an artifact of a shared query.

### Edited and unedited subsets (design decision, research section 4.5)

- Edited (12): primary members 1, 2 (Claude agent pair), 3, 10 (converted Codex agent pair), 19 to 26
  (the eight skill files).
- Unedited (14): primary members 17, 18 (Copilot agent pair, which delegates to the
  `feature-review-workflow` skill) and 4 to 9 and 11 to 16 (the twelve `feature-reviewer*` Codex TOML
  files: the hand-edited base pair and the ten generated variants).
- 12 + 14 = 26, matching both counts above.
