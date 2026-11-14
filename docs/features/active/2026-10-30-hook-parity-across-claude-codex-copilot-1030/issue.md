# hook-parity-across-claude-codex-copilot (Issue #1030)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-parity-across-claude-codex-copilot/ (Issue #1030)
- Epic: #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 5

- Issue: #1030
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1030
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`, 75 files on `main`), Codex (`.codex/hooks`, 50 files) and GitHub Copilot
(`.github/hooks`, 6 files). The sets were built separately and drifted: some Claude gates have no
Codex counterpart, some Codex hooks exist only to express Codex-specific attestation, and the
Copilot hooks cover only the discovery surface. No record states, for each hook, whether its
function is shared across ecosystems, native to one ecosystem, generated, or deliberately dropped,
so a missing gate in one ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hook counts need not match, and
Codex gains a hook only where its hook system can express the behavior.

## Proposed Behavior

- Every hook registration in each ecosystem has a disposition in the parity matrix (shared,
  native, generated, or dropped with a written reason).
- Where a Claude gate's function is expressible in Codex and the matrix marks it shared, the Codex
  counterpart exists and behaves the same on the same inputs; where it is not expressible, the
  matrix records the reason.
- The Copilot hooks under `.github/hooks` receive dispositions; their function is kept native in
  `.github` (the thin Copilot layer that child 6 finalizes).
- Enforcement hooks do not invoke Python.
- Hook registrations in agent frontmatter and in `.codex/config.toml` follow the generator
  ownership that child 3 establishes.
- Bundled mirrors under `extensions/drm-copilot/resources/` stay byte-identical and their parity
  tests stay green.

## Acceptance Criteria (early draft)

- [ ] Every hook registration in `.claude/settings.json`, agent frontmatter, `.codex/config.toml`
  and `.github/hooks` has a parity-matrix disposition, and the completeness test passes.
- [ ] Every hook whose disposition is shared has a counterpart in each ecosystem that can express
  it, with a test proving equivalent behavior.
- [ ] No enforcement hook invokes Python.
- [ ] Bundled mirrors and their parity tests are green.

## Constraints & Risks

- Depends on child 3 (generator ownership of hook registrations) and on child 1's matrix schema,
  whose `id` encoding is still open.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; that run edits
  many hooks.
- Language rule: hooks and their libraries are pushed down to destination repositories, so new
  hook code is PowerShell or bash only.

## Test Conditions to Consider

- [ ] Unit coverage areas: each new or ported Codex hook (Pester), matrix hook-entry coverage.
- [ ] Integration scenarios: Linux hook-suite job over `tests/scripts/codex-hooks`.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/hook-parity-across-claude-codex-copilot/` folder from the template
