# target-worktree-resolution-module (Issue #669)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/target-worktree-resolution-module/ (Issue #669)
- Epic: `docs/features/epics/worktree-scoped-state-resolution/epic.md`
- Epic ref: F1 (wave 0, complexity C3, no dependencies)

- Issue: #669
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/669
- Last Updated: 2026-09-14
## Problem / Why

`drm-copilot` hooks and MCP tools resolve orchestration state — feature folders, checkpoints, and
diff bases — against the invoking session's current working directory rather than against the
worktree the tool call actually pertains to.

In a single-worktree topology cwd and target coincide, so the defect is invisible. In a parallel or
epic topology the orchestrating session's cwd is a different worktree from the item being acted on,
and the same code path produces two failure modes:

- **False denial** — a gate reads the wrong root, does not find a document that exists, and denies a
  delegation that should have been allowed.
- **False approval** — a gate reads a sibling item's checkpoint, finds it satisfactory, and allows an
  action that was never validated against its own item's state.

Verified 2026-09-13 against this tree: `.claude/lib/` holds eleven modules (`bash`, `blast-radius`,
`cleanup-manifest`, `codex-routing`, `discovery-validation`, `hook-payload`, `mermaid`,
`model-routing`, `orchestrator-state`, `project-file-merge`, `requirements`) and none of them
resolves a worktree or a call target. There is no shared primitive for downstream gates to consume.

A concrete instance of the path-normalisation half of the defect exists today in
`enforce-prd-feature-before-planner.ps1`, whose prompt-token handling truncates candidate paths to a
fixed segment count and therefore discards a valid absolute-path prefix, producing a false denial.

## Proposed Behavior

Introduce the repository's first worktree/target resolution primitive as a new PowerShell module
under `.claude/lib/`, defining the three-part contract that downstream epic features F4
(`prd-feature-gate-target-resolution`) and F5
(`false-approval-elimination-pr-author-model-routing`) are specified against.

1. **Target derivation** — given a tool-call payload, return the worktree the call pertains to, or an
   explicit "no target" result. The target is derived from signals such as the feature-folder path in
   a delegation prompt, an item's branch, or the file being staged.
2. **Path normalisation** — given a path in either relative or absolute form, return its repo-relative
   form by locating the containing worktree. Fixed segment-count truncation is prohibited.
3. **Ambiguity reason code** — a single distinct, greppable reason code emitted when the correct
   target cannot be identified, so a caller can deny with a specific reason instead of silently
   falling back to whatever checkpoint occupies the session root.

This feature adds the primitive and its tests only. It adds **no consumers**: no hook or MCP tool is
rewired in this feature. Rewiring is the scope of F4 and F5.

The module must be registered in the bundled-payload manifest
(`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) and mirrored into
the bundled `.claude/lib/` tree, following the convention that `model-routing` already uses;
otherwise push-down never delivers the module under `--packs core`.

## Acceptance Criteria (early draft)

- [ ] A new `.claude/lib/` module exposes target derivation, path normalisation, and a single
      ambiguity reason code, with no consumer rewiring in this feature.
- [ ] Path normalisation resolves relative and absolute paths by locating the containing worktree; no
      fixed segment-count truncation appears anywhere in the module.
- [ ] The ambiguity reason code is a single distinct, greppable literal, documented for F4/F5 use.
- [ ] When cwd and target coincide, target derivation returns the session root, preserving current
      epic and standalone behaviour.
- [ ] A payload with no derivable target returns an explicit "no target" result distinguishable from
      the ambiguity result.
- [ ] The module path appears exactly once in the `paths` array of
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and a
      matching `*.Manifest.Tests.ps1` asserts that.
- [ ] The module is mirrored into the bundled claude-customizations `.claude/lib/` tree per the
      existing convention.

## Constraints & Risks

- Enforcement/hook-adjacent code must be PowerShell or bash. No Python: a Python leg creates a second
  implementation of the rule that drifts from the first, which has already occurred in this
  repository.
- No production, test, or reusable script file may exceed 500 lines.
- Tests live in a `tests/` tree mirroring production structure
  (`tests/scripts/claude-lib/<module>/...`). Colocation is prohibited.
- Line coverage >= 85%. Pester does not measure branch coverage, so no branch gate applies, but the
  files remain in the coverage denominator.
- Determinism: no temporary files in tests, no wall-clock reads, no external process dependencies
  that make a test environment-sensitive.
- Risk: the contract is consumed by two downstream features that cannot be written until it exists.
  A contract that is imprecise about the difference between "no target" and "ambiguous target" forces
  rework in F4 and F5.
- Risk: omitting the `core.json` registration is silent at development time and only fails at F7,
  where push-down delivers nothing.

## Test Conditions to Consider

- [ ] Table-driven Pester covering the cross product of cwd (session root vs item worktree), path form
      (relative vs absolute), and target (own item vs sibling item vs absent).
- [ ] The "sibling item is the only state present" row returns the ambiguity result and never a
      resolved target.
- [ ] cwd and target coincide: target derivation returns the session root (regression guard).
- [ ] Absolute path to a feature folder normalises without losing its prefix (the segment-truncation
      regression).
- [ ] Manifest test asserting exactly-once registration in `core.json`.
- [ ] Assertions are direct against module functions; this feature has no hook consumers.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/target-worktree-resolution-module/` folder from the template
