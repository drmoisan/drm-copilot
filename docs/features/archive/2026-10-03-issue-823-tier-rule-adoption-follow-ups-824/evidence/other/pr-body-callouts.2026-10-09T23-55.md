# PR-Body Callout Notes (issue #824, Addendum 2)

Timestamp: 2026-10-09T23-55

These notes are input for the parallel orchestrator's PR authoring. This plan does not author the PR.

## 1. Issue reference

The PR body references the issue with this exact line:

Refs #824

Issue #824 stays open because its main bug, Addendum 1, and FU-823-4 are delivered separately.

## 2. Canonical policy edits (each called out)

- `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md` (FU-823-3). Maintainer authorization is recorded in issue #824 Addendum 2 and applies to this item only. `TaskMaster.sln` is replaced by the `<solution>.sln` placeholder.
- `.claude/rules/architecture-boundaries.md` (FU-823-2). Names are neutralized; the substance is unchanged.
- `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` (review note A). The per-metric fallback sentence is required on every surface that carries the precedence wording. The canonical `.github/instructions/general-unit-test.instructions.md` does not carry that wording and is unchanged.

## 3. FU-823-4

FU-823-4 (extension rebuild, publish, and reinstall) remains open and out of scope. Consumers receive these changes only after it is delivered.

## 4. Out-of-scope follow-ups (spec Rollout & Follow-up)

- `.codex/hooks/validate-feature-review-coverage.ps1` and its mirror keep a separate 80 percent floor.
- 80/90 figures remain in `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.codex/agents/feature-review.toml`, and their mirrors.
- `No-COM` remains in `.claude/rules/typescript.md` and `.claude/rules/csharp.md` and their mirrors (held in the AC-5 exception set), and the `typescript.md` cross-reference no longer matches the renamed heading.
- `.codex/` is outside shell-qc discovery and the kcov include roots.
- Optionally, a new potential entry for FU-823-4.

## 5. Verification status

- AC-15 is pending this PR.
- AC-6 is pending CI (P5-T16 recorded PENDING-CI).

## 6. Evidence sources under operator constraints

- PowerShell coverage values in this branch's evidence are read from CI artifacts (OPS-2).
- Shell syntax and bats verification are CI evidence (OPS-1).
