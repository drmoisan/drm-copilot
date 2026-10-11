# enforcement-hook-precision (Issue #852)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/enforcement-hook-precision/ (Issue #852)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub issue template.

- Issue: #852
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/852
- Last Updated: 2026-10-08
## Problem / Why

The PreToolUse and SubagentStop enforcement hooks under `.claude/hooks/` (and their Codex and bundled mirrors) decide on imprecise evidence. The defects fall into five classes:

- Command matching by substring or denylist over the whole command text rather than by token-aware invocation matching, which denies harmless commands (#824 main defect and addendum 1, #742, #733).
- Feature-folder resolution by longest path match in a delegation prompt, which selects a nested artifact or an upstream dependency instead of the target folder, plus work-mode-unaware prerequisite checks (#565, #568, #696).
- Operand and scope resolution in the preimplementation gate that evaluates literal operand text or only the first `git -C` target (#732, #738, #745, #735).
- Residual reads relative to the session root instead of the worktree that owns the run (#850, #788, #789, #851, #787), and a SubagentStop hook that does not run the wave-barrier Layer 2 check its documents claim (#840).
- Hooks that fail open when an import fails or an imported module writes to stdout (#786, #792), cross-surface parity gaps (#736), and test-hermeticity gaps (#737, #746).

## Proposed Behavior

Deliver the remediation as one epic with eight child features in three dependency waves. Each child bundles existing issues and updates the bundled mirrors under `extensions/drm-copilot/resources/`.

- Wave 1: C1a command-invocation matching (#824 main defect and addendum 1, #742, #733); C2 feature-folder resolution (#565, #568, #696); C5a completion-consistency parity (#736).
- Wave 2: C1b preimplementation operand and scope precision (#732, #738, #745, #735); C3 residual session-root reads (#850, #788, #789, #851); C6 SubagentStop output validator (#787, #840).
- Wave 3: C4 hooks that fail open on import errors (#786, #792); C5b test hermeticity and parity (#737, #746).

The epic manifest and narrative live at `docs/features/epics/enforcement-hook-precision/epic.md`.

## Acceptance Criteria (early draft)

- [ ] Each hook in scope matches the specific invocation it governs, and the reproduction commands recorded in the child issues are allowed.
- [ ] Each hook in scope resolves the target feature folder and target worktree from the declared target, not from match length or the session root.
- [ ] The SubagentStop output validator runs the wave-barrier Layer 2 check through a PowerShell implementation, with no Python leg.
- [ ] A failed import or a stdout write from an imported module produces a deny decision rather than a fail-open exit.
- [ ] The Claude, Codex, and bundled copies of each changed hook stay in parity.
- [ ] All eight child features merge into `epic/enforcement-hook-precision-integration`, and the integration branch merges into `main`.

## Constraints & Risks

- #824 addendum 2 (the #823 follow-ups) is delivered by a concurrent parallel run and is out of scope for this epic.
- Enforcement hooks must not gain Python legs.
- No production file may exceed 500 lines; several hook files are near that limit.
- Changes to deny conditions must keep every currently gated invocation gated.

## Test Conditions to Consider

- Pester negative controls that fail if substring-containment deny paths are restored.
- Prompt-form matrices for feature-folder resolution: folder alone, folder plus nested artifact, nested artifact alone, upstream citation.
- Two-worktree topology tests in which the run checkpoint is not at the session root.
- Import-failure and stdout-write seams for every hook that imports modules.
