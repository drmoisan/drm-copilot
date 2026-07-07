# Phase 0 — Policy Instructions Read (Remediation Cycle 1, Issue #328)

Timestamp: 2026-07-07T13-42

Policy Order:
1. CLAUDE.md (standing instructions) — NOT PRESENT at repo root in this worktree; repository policy is auto-loaded via path-scoped frontmatter in `.claude/rules/`. Recorded as absent rather than read.
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/powershell.md (PowerShell code standards — language-specific rule for files in scope)
5. .claude/rules/quality-tiers.md (module rigor tiers and coverage thresholds)

Files Read:
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/quality-tiers.md

Files Referenced But Absent:
- CLAUDE.md (not present at `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-07-11-50\CLAUDE.md`; no CLAUDE.md found under repo root or `.claude/`). Standing instructions are supplied to the agent via the auto-loaded rule set above.

Key constraints acknowledged for this remediation cycle (measurement/evidence only):
- Do not change production behavior of the script, its bundled template, or any TypeScript file. Only a behavior-preserving dot-source guard is permitted, applied in lockstep to script and template, verified byte-identical via `git diff --no-index`.
- Do not lower or reinterpret coverage thresholds (line >= 85%, branch >= 75%, uniform across T1-T4).
- Do not exclude any production file from coverage; do not add production `exclude` entries; do not remove existing `CodeCoverage.Path` entries.
- Do not weaken, delete, or skip tests. Adding tests is permitted.
- Do not mock git or other executables directly; use the wrapper/scriptblock seam.
- Evidence written only under `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/<kind>/`.
