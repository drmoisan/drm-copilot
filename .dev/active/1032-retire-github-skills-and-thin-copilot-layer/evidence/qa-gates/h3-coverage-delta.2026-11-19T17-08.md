# H3 Coverage Delta ([P2-T3])

Timestamp: 2026-11-19T17-08
Plan: plan-h3-sync-writer-retirement.md
Command: comparison of h3-pytest-baseline.2026-11-19T14-45.md, h3-jest-baseline.2026-11-19T14-49.md and h3-pester-baseline.2026-11-19T15-09.md with h3-pytest-final.2026-11-19T16-55.md, h3-jest-final.2026-11-19T16-55.md and h3-pester-final.2026-11-19T17-08.md; changed lines read with `git diff <MB> HEAD -- <file>` (MB per AD-7: merge base of origin/epic/shared-agent-harness-layer-integration and HEAD)
EXIT_CODE: 0
Output Summary: every in-scope file is at or above 85% line and 75% branch; no regression on changed lines (the edits remove code; the one modified executable line is a covered import); whole-file decreases come only from removing covered code and are recorded, not failed.

| File | Baseline line | Final line | Baseline branch | Final branch | Changed-line result |
| --- | --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` | 98.26% (452/460) | 98.17% (431/439) | 90.27% (65/72) | 90.00% (63/70) | one modified executable line, the `./command-runtime` import (now `getWorkspaceRoot` only), executed whenever the module loads; otherwise removal only (21 covered lines and 2 covered branches of `registerSyncAgentsFromInstructionsCommand` and its call). The 8 uncovered lines and 7 uncovered branches are unchanged code. |
| `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts` | 99.17% (241/243) | 99.15% (234/236) | 94.11% (16/17) | 94.11% (16/17) | no added lines: one catalog entry (7 covered lines) removed; the doc comment change is not executable |
| `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` | 98.25% (56/57) | 98.25% (56/57) | 90.00% (9/10) | 90.00% (9/10) | no added lines: one `RewriteTarget` argument removed from the `targets` tuple (part of one statement); the single missing line is unchanged code |
| `scripts/harness-generation/HarnessInstructions.psm1` (reworded before P2-T1) | not recorded at baseline (outside the plan's per-file list) | 100.00% (64/64) | n/a (Pester measures no branches) | n/a | two text edits (a comment and a string literal in a covered line) |
| `scripts/dev-tools/sync-agents-from-instructions.ps1` | 72.09% (93/129) | deleted | n/a | n/a | leaves the coverage denominator |

Repository-wide: pytest line 98.00% / branch 95.46% at baseline and final; Jest lines 97.42% / branches 94.63% at baseline and final; Pester line 96.77% at baseline, 96.84% at final.
