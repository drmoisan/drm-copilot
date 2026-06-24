# relocate-research-canonical-location (Issue #227)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/relocate-research-canonical-location/ (Issue #227)

- Issue: #227
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/227
- Last Updated: 2026-06-24
- Work Mode: full-feature

## Problem / Why

The research step of orchestration writes research files to `artifacts/research/`. The repository `.gitignore` ignores `artifacts` (line 6), so research output is never tracked in version control. The research artifacts contain substantive findings (current-state analysis, candidate approaches, requirements mapping) that are valuable to retain alongside the feature they support. Discarding them on every clean checkout is suboptimal.

## Proposed Behavior

Change the canonical research output location across all three customization ecosystems (Claude, Codex, GitHub Copilot), including bundled extension copies, so research is persisted in tracked locations:

- When research is associated with an orchestration / feature, write it inside the active feature folder, e.g. `docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md`.
- When research is one-off and not associated with a feature, write it to a general `docs/research/<timestamp>-<short-name>-research.md` folder.

The validation hooks, agent write-path allowlists, skills, prompts, and tests that currently assume `artifacts/research/` must be updated to the new contract consistently across ecosystems.

## Acceptance Criteria (early draft)

- [ ] Feature-associated research is written to `<FEATURE>/research/` and one-off research to `docs/research/`; `artifacts/research/` is no longer the canonical target.
- [ ] The Claude ecosystem (root `.claude/` and bundled `claude-customizations`) reflects the new contract in agents, skills, and hooks.
- [ ] The Codex ecosystem (bundled `codex-and-agents-customizations`) reflects the new contract in agents, skills, and hooks.
- [ ] The GitHub Copilot ecosystem (root `.github/` and bundled `customizations`) reflects the new contract in prompts and agents.
- [ ] `validate-task-researcher-output` and `enforce-evidence-locations` hooks accept the new tracked locations and reject the old untracked location, with tests updated accordingly.
- [ ] Both tracked research locations resolve to git-tracked paths (not under the ignored `artifacts` tree).

## Constraints & Risks

- The change is contract-wide and must remain consistent across the three ecosystems and their bundled copies; divergence is a regression.
- Hook regexes and agent write-path allowlists must accept two distinct roots without weakening evidence-location enforcement.
- Backward compatibility: existing archived research under `artifacts/research/` is historical and is not migrated by this change.

## Test Conditions to Consider

- [ ] Hook unit tests for accepted (feature and one-off) and rejected research paths.
- [ ] Filename-convention validation preserved under the new roots.
- [ ] Evidence-location enforcement unaffected for non-research paths.

## Next Step

- [ ] Promote to GitHub issue (refactor template)
- [ ] Create `docs/features/active/relocate-research-canonical-location/` folder from the template