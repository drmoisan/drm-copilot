# Coverage Delta (P9-T7)

Timestamp: 2026-09-29T19-22
Command: git diff -U0 origin/epic/push-down-payload-correctness-integration -- extensions/drm-copilot/src/lib/push-down/claude-customizations.ts scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_destination_writes.py   (REGISTRY_MODULE substituted; output redirected to a session scratchpad file); inputs: P0-T14 ts-jest-coverage.2026-09-29T18-41.md, P0-T18 py-pytest-coverage.2026-09-29T18-41.md, P7-T5 ts-jest-coverage.2026-09-29T19-16.md, P8-T5 py-pytest-coverage.2026-09-29T19-19.md; supplementary changed-line read of artifacts/python/coverage-508-final.json with a single-line `poetry run python -c`
EXIT_CODE: 0
Output Summary:
- Baseline totals: TypeScript lines 96.96, branches 90.97; Python statements 93.22, branches 86.07.
- Post-change totals: TypeScript lines 96.98, branches 91.04; Python statements 93.27, branches 86.19. No regression in any total.
- New modules:
  - extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts: lines 99.55, branches 95.87 (>= 85 / >= 75: PASS)
  - scripts/dev_tools/push_down_claude_blast_radius_overlay.py: statements 100.0, branches 100.0 (>= 85 / >= 75: PASS)
- Changed pre-existing files (per-file value route, each is at least 85 lines and 75 branches, which bounds its changed lines):
  - extensions/drm-copilot/src/lib/push-down/claude-customizations.ts: baseline 100 / 94.59 -> post 100 / 95.74 (not below baseline: PASS)
  - extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts (header comment only): baseline 99.35 / 96.29 -> post 99.35 / 96.36 (PASS)
  - scripts/dev_tools/push_down_claude_customizations.py: baseline 92.75 / 75.0 -> post 92.75 / 75.0 (not below baseline; branches equal the 75 threshold: PASS)
  - scripts/dev_tools/push_down_claude_destination_writes.py (REGISTRY_MODULE): baseline 98.84 / 91.67 -> post 99.01 / 92.86 (PASS)
- -U0 hunks (new-side line ranges):
  - claude-customizations.ts: 26, 30, 59, 61-70, 77-139, 173-178, 342-347, 353, 393-395 (plus pure deletions at old 276-277 and 280-292).
  - push_down_claude_customizations.py: 116-119.
  - push_down_claude_destination_writes.py: 25-28, 43, 55-58, 73-76, 87-88, 92, 97, 103-125, 128, 131-163, 256-260, 269-279.
- Supplementary changed-line coverage (Python, from coverage-508-final.json; not required by the per-file route):
  - push_down_claude_customizations.py: changed executable lines executed [116], missing none; branches: n/a (0 branches in hunks). File-level missing lines 100-103 and 109 lie outside every hunk (pre-existing).
  - push_down_claude_destination_writes.py: changed executable lines executed 17 of 17 (43, 55, 104, 120, 121, 133, 138, 139, 149, 150, 151, 155, 269, 270, 271, 278, 279), missing none; changed-line branches 4 of 4 executed ([269,270], [269,280], [278,279], [278,280]). File-level missing line 180 and branch [179,180] lie outside every hunk.
- Every numeric value required by the task is present. No value is missing.
- Acceptance: PASS.
