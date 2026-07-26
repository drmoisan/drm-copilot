# Phase 0 — Git Baseline (Issue #415)

Timestamp: 2026-07-25T19-05

## Command 1

Command: `git rev-parse --abbrev-ref HEAD`
EXIT_CODE: 0

```
bug/codex-pretooluse-hook-transport-415
```

## Command 2

Command: `git rev-parse HEAD`
EXIT_CODE: 0

```
f28fe510bf0d695913fbf1e72ae5dfefc045c3a2
```

## Command 3

Command: `git status --porcelain`
EXIT_CODE: 0

```
 M docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md
?? .codex/state/
?? docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/
```

## Command 4

Command: `git diff .codex/config.toml`
EXIT_CODE: 0

Full output (verbatim): empty. The command produced no output at all.

## Supplementary verification

Command: `Get-FileHash -Algorithm SHA256 .codex/config.toml` and the same for `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
EXIT_CODE: 0

```
160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD  .codex/config.toml
160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml
```

## Output Summary

Branch is `bug/codex-pretooluse-hook-transport-415` at commit `f28fe510bf0d695913fbf1e72ae5dfefc045c3a2` (the planning-artifact commit).

Characterization of the `.codex/config.toml` diff: **there is no diff**. The plan's Verified Preconditions recorded the working tree carrying an uncommitted `^Bash$`-group ordering swap of three handler blocks (`enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-orchestration-preimplementation-gate.ps1`). That edit was deliberately reverted before execution began, so the working-tree file is already at its committed form. `git diff .codex/config.toml` is empty and the root file's SHA256 already equals the bundle copy's SHA256 (`160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD`), which matches the hash the plan recorded for `git show HEAD:.codex/config.toml`.

Consequence for P1-T2: step (a)'s "only uncommitted change is the ordering swap" precondition is satisfied in its stronger form (there is no uncommitted change at all, so no non-ordering hunk exists), step (b) `git restore .codex/config.toml` is a no-op, and steps (c)/(d) are pure verification that already passes. This is the state the delegation baseline predicted.

Working tree otherwise contains only: the plan file (checkbox updates from this execution), the untracked `.codex/state/` Codex hook runtime directory (must not be committed), and the untracked feature `evidence/` tree created by this Phase 0.
