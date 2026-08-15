# Cycle 2 TypeScript Evidence Reuse

Timestamp: 2026-08-15T02-03
Command: Re-hash the P0-T10 TypeScript coverage summary and test receipt after P2-T5; do not execute any TypeScript QA command.
EXIT_CODE: 0
Output Summary: Both frozen TypeScript artifacts exactly match their P0-T10 hashes. The P2-T5 fingerprint proves TypeScript inputs unchanged, so the retained numeric coverage, test, and owner results remain valid without rerunning the suite.

## Integrity

- Coverage artifact: `extensions/drm-copilot/coverage/coverage-summary.json`
- Expected coverage SHA-256: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`
- Current coverage SHA-256: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`
- Test artifact: `evidence/qa-gates/cycle1-typescript-test.2026-08-14T09-36.md`
- Expected test SHA-256: `41245C2DC5F113864AFAB445A61FB541A6D52AD63E41098F9DF5237C8296CDD7`
- Current test SHA-256: `41245C2DC5F113864AFAB445A61FB541A6D52AD63E41098F9DF5237C8296CDD7`
- P2-T5 freshness receipt SHA-256: `B0EF30BCF55FBC38EA6AEDB39D02162DF0355D87A784311CF4F0AB34F147B9A7`
- Exact hash equality: `YES`

## Retained result

- Lines: `44,127/45,740 = 96.47%`
- Branches: `6,589/7,338 = 89.79%`
- Tests: `2,690/2,690 passed; 0 failed`
- Modified owners non-regressing: `5/5`
- TypeScript suite rerun in cycle 2: `NO`

Result: PASS
