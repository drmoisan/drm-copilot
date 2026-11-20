# Coverage comparison - Python and TypeScript (final gates against the Phase 0 baseline)

Timestamp: 2026-11-18T01-10
Command: comparison of evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md with evidence/baseline/pytest.2026-11-17T21-03.md, and of evidence/qa-gates/final-qc-jest.2026-11-18T01-10.md with evidence/baseline/jest-extension.2026-11-17T21-03.md
EXIT_CODE: 0
Output Summary:

| Measure | Phase 0 baseline | Final gate | Result |
|---|---|---|---|
| pytest (passed / failed) | 16957 / 0 | 16957 / 0 | no new failing test |
| pytest repo-wide lines | 97.74% (35100/35910) | 97.74% (35100/35910) | no drop |
| pytest repo-wide branches | 95.15% (13024/13688) | 95.15% (13024/13688) | no drop |
| scripts/dev_tools/push_down_claude_customizations.py lines | 93.67% (74/79) | 93.67% (74/79) | no drop; the added tuple entry is part of an executed statement |
| scripts/dev_tools/push_down_claude_customizations.py branches | 87.50% (14/16) | 87.50% (14/16) | no drop |
| Jest (passed / failed) | 5681 / 0 | 5684 / 0 | no new failing test |
| Jest repo-wide lines | 97.19% (64780/66650) | 97.19% (64781/66651) | no drop (ratio 0.971943 -> 0.971943, one more covered line) |
| Jest repo-wide branches | 94% (9998/10636) | 94% (9999/10637) | no drop (ratio 0.940015 -> 0.940021) |
| src/lib/push-down/claude-customizations.ts lines | 100% (496/496) | 100% (497/497) | no drop; the added line is covered |
| src/lib/push-down/claude-customizations.ts branches | 96.82% (61/63) | 96.82% (61/63) | no drop |

- The coverageThreshold map in extensions/drm-copilot/jest.config.cjs passed in the final Jest run; no new production TypeScript file was added, so no new threshold entry was needed.
- Verdict: PASS for Python and TypeScript (no new failure, no per-file or repo-wide drop).
