# Coverage Delta ([P2-T5])

Timestamp: 2026-11-19T11-59
Plan: plan.2026-10-30T18-39.md
Command: git diff -U0 MB HEAD -- scripts/dev_tools/agentic_sync.py extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts (MB = merge base of origin/epic/shared-agent-harness-layer-integration and HEAD, per AD-7); figures read from pytest-baseline.2026-11-19T07-59.md, jest-baseline.2026-11-19T08-00.md, pytest-final.2026-11-19T11-33.md and jest-final.2026-11-19T11-34.md
EXIT_CODE: 0
Output Summary: both edited production files are above 85% line and 75% branch coverage after the change, neither dropped against the Phase 0 baseline, and neither has an added or modified executable line (the edits remove one list element each and rewrite a docstring), so no changed line is uncovered.

| File | Baseline line | Final line | Baseline branch | Final branch | Changed-line result |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/agentic_sync.py` | 98.02% (99/101) | 98.02% (99/101) | 94.12% (32/34) | 94.12% (32/34) | no added lines: the diff removes the `Path(".github/skills")` element of `ROOT_FOLDERS` (one statement fewer in the tuple literal, which is still covered) and rewrites lines of the module docstring, which coverage does not count as executable; 0 uncovered added or modified lines |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | 97.99% (440/449) | 97.99% (439/448) | 86.66% (39/45) | 86.66% (39/45) | no added lines: the diff removes one element of `COPILOT_ROOT_FOLDERS`; 0 uncovered added or modified lines |

Repository-wide: pytest line 98.00% and branch 95.46% at baseline and final; Jest lines 97.29% at baseline and final (65686/67513 to 65685/67512), branches 94.30% at both.
