# Remediation Cycle 2 — Policy-Path Invariant

Timestamp: 2026-08-28T02-21
Task: [P3-T11]
Command: `git diff --name-only origin/main...HEAD`, `git diff --name-only HEAD`, `git status --porcelain`, and `git ls-files --others --exclude-standard`, unioned and deduplicated in Python with a three-character prefix strip applied to every porcelain line
EXIT_CODE: 0 (all four listings returned 0)

## Union construction

| Listing | Size |
| --- | --- |
| `git diff --name-only origin/main...HEAD` (three-dot, whole-branch) | 117 |
| `git diff --name-only HEAD` (two-dot, uncommitted tracked) | 1 |
| `git status --porcelain` (tracked and untracked, three-char prefix stripped) | 10 |
| `git ls-files --others --exclude-standard` (untracked) | 9 |
| **Deduplicated union** | **127** |

**Prefix stripping.** Each porcelain line's **three-character status-and-separator prefix** — the
two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2,
with the path beginning at position 3 — is stripped before its path enters the union. Implemented as
`line[3:]`.

**Deduplication.** The union is a Python `set`, applied **before** the prefix tests below, so a path
reported by more than one listing contributes exactly one member.

**Why the strip width is load-bearing here in particular.** Stripping only two characters would leave
a leading space on every porcelain path, so a newly created `.claude/rules/` file would enter the
union as `` ` .claude/rules/…` ``, which does **not** begin with `.claude/rules/` and would pass this
check silently. **No redundant clause sits behind that one**: the three prefix tests below are the
whole of this task's assertion, so the strip width is the difference between a real check and a
vacuous one.

**Why the porcelain and untracked listings are required.** Neither name-listing diff can report an
untracked path, so a newly created policy-tree file would be invisible to the two diffs alone.

## Result — no path under any of the three prohibited prefixes

| Prohibited prefix | Members in the union |
| --- | --- |
| `.claude/rules/` | **0** |
| `.claude/skills/` | **0** |
| `.github/` | **0** |

**The union contains no path beginning with `.claude/rules/`, no path beginning with
`.claude/skills/`, and no path beginning with `.github/`.** In particular
`.github/copilot-instructions.md` and every file under `.github/instructions/` are untouched by this
branch.

This satisfies statement `(b)` of the `## DECLARED BLAST RADIUS` section of `spec.md` and
prohibition 2 of the remediation plan.

## Top-level segment distribution of the union

| Top segment | Count |
| --- | --- |
| `docs/` | 112 |
| `extensions/` | 7 |
| `tests/` | 3 |
| `.claude/` | 2 |
| `.codex/` | 2 |
| `scripts/` | 1 |
| **Total** | **127** |

The `.claude/` count of 2 is entirely accounted for by
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and
`.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, both under `.claude/hooks/`
and both declared production entries of this branch (unchanged by **this cycle**, per [P3-T10] and
[P3-T12]). Neither is under `.claude/rules/` or `.claude/skills/`.

## The fifteen non-`docs/` members of the union, in full

```
.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
```

Every one is a `## DECLARED BLAST RADIUS` entry of `spec.md`: four `Production — modified`, four
`Production — new`, four `Configuration and manifests`, and three `Tests — new`. None is under a
prohibited policy prefix.

Output Summary: The deduplicated four-listing union holds **127** paths and contains **zero** paths
beginning with `.claude/rules/`, **zero** beginning with `.claude/skills/`, and **zero** beginning
with `.github/`. The policy-path invariant holds. EXIT_CODE 0.
