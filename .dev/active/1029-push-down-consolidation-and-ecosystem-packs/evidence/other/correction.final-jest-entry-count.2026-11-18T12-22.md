# Correction: Jest per-file threshold entry count

Timestamp: 2026-11-18T12-22
Command: node -e "console.log(Object.keys(JSON.parse(require('fs').readFileSync('extensions/drm-copilot/jest.push-down-coverage.json','utf8'))).length)"; then `git diff --exit-code REM_BASE -- docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/evidence/qa-gates/final-jest.2026-11-18T11-19.md`
EXIT_CODE: 0
Output Summary: Observed count: 13 top-level properties in the parsed `extensions/drm-copilot/jest.push-down-coverage.json`. `evidence/qa-gates/final-jest.2026-11-18T11-19.md` states "the 14 entries of `jest.push-down-coverage.json`"; the correct figure is 13. The `git diff --exit-code REM_BASE` over that file exited 0.

## Statement

- The final Jest gate artifact `evidence/qa-gates/final-jest.2026-11-18T11-19.md` reports 14 entries for `extensions/drm-copilot/jest.push-down-coverage.json`. The file holds 13 entries, counted as the top-level properties of the parsed JSON.
- The coverage result of that run is unaffected. The run reported no `coverageThreshold` failure, so every per-file entry that Jest applied, all 13 of them, was met. The figures in that artifact (6119 tests passed, 0 failed, lines 97.42%, branches 94.63%) are unchanged by this correction.
- The original artifact is left unchanged, because evidence is append-only. This note is the correction record.
