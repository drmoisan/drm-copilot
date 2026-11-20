# Converter TypeScript port — standing guidance not emitted ([P2-T1])

Timestamp: 2026-11-17T20-13
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension codex-native-converter; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension <the five converter test files> --json --outputFile=SCRATCH/issue-1028-p2t1-jest.json; grep -rn renderMergedStandingGuidance extensions/drm-copilot/src extensions/drm-copilot/test; git diff <BASE> --numstat -- extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: The suites whose path matches `codex-native-converter` pass: 24 of 24 suites and 197 of 197 tests, covering the converter directory and the four extension suites that call the converter. The five changed test files report 52 passed and 0 failed in the JSON result. The search for `renderMergedStandingGuidance` under `extensions/drm-copilot/src` and `extensions/drm-copilot/test` returns 0 matches. The `jest.config.cjs` diff from `BASE` is 14 added and 0 deleted lines.

Production changes:
- `mapping.ts` `planTargetPaths`: a `TargetRole.STANDING_GUIDANCE` record keeps its role and conversion class, gets a null `targetPath`, and gains the note "Not emitted: AGENTS.md is a hand-authored source maintained outside the converter." after its existing notes. The literal is exported as `STANDING_GUIDANCE_NOT_EMITTED_NOTE`.
- `engine-pipeline.ts` `renderGeneratedOutput` and `pipeline.ts` `buildTopologyEdges`: standing-guidance source paths derive from the role alone, and the `AGENTS.md` merge branch is removed.
- `pipeline-render.ts`: `renderMergedStandingGuidance` and the standing-guidance branch of `wrapRenderedTargetContent` are deleted, and `pipeline.ts` no longer re-exports the function.
- `validation.ts` `validateDuplicateTargets`: the `AGENTS.md` exemption is removed.
- TSDoc is updated in each file.
- `jest.config.cjs`: an issue #1028 comment and `lines: 85`, `branches: 75` entries for `engine-pipeline.ts`, `pipeline.ts` and `validation.ts` are appended after the last entry. No baseline figure of the five changed files is below 85% line or 75% branch (`evidence/baseline/jest-coverage.2026-11-17T18-50.md`), so no test was added on that account.

Tests, as listed in `## Existing Test Disposition` (all passed):
- Updated: `maps standing guidance to AGENTS.md` renamed `leaves standing guidance unemitted with the hand-authored-source reason`; `produces the required review artifact set without writing a destination` (no proposed-tree `AGENTS.md`); `merges repo-wide instructions into one generated AGENTS.md` renamed `does not emit AGENTS.md for repo-wide standing-guidance sources`; `writes report artifacts through the filesystem for review mode`; `wraps standing-guidance content with the converted-guidance header and rewrite summary` renamed `renders standing-guidance content without a converted-guidance header`; the `renderMergedStandingGuidance` describe block and its import removed; `allows multiple standing-guidance inputs to merge into AGENTS.md` renamed `ignores unemitted standing-guidance records in duplicate-target checks`.
- New: `reports each standing-guidance source as not emitted with the hand-authored-source reason`, `keeps standing-guidance reference rewrites to AGENTS.md in other outputs`, `does not create a destination AGENTS.md in apply mode`, `leaves an existing destination AGENTS.md unchanged in apply mode`, `adds no AGENTS.md destination when standing guidance is not emitted`, `reports duplicate-target-path for two records targeting AGENTS.md`.
