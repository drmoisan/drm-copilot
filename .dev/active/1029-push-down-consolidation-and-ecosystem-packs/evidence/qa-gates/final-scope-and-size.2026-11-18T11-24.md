# Final Scope, Size and Isolation Checks (P5-T6)

Timestamp: 2026-11-18T11-24
Command: sh SCRATCH/issue-1029-scope.sh (git diff --name-only [--diff-filter=A|AM] <integration merge base> HEAD with path filters; git status --porcelain --untracked-files=all -- extensions/drm-copilot tests/scripts .claude/hooks; grep -c enumerateSourceFiles on four modules; grep for mkdtemp, tmpdir and writeFileSync over new test files and added test lines; wc -l over every added or changed code and data file)
EXIT_CODE: 0
Output Summary: Every check passes. The comparison base is the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` (`evidence/other/execution-decision.scope-base.2026-11-18T07-54.md`); the main merge base would attribute the upstream #1025 and #1028 changes to this item. No untracked file exists under the checked folders. No file exceeds 800 lines; three files exceed the 500-line guidance tier, each with a reason below.

| Check | Result | Paths |
| --- | --- | --- |
| No added `.py` file | PASS | none |
| No added `.ts` or `.py` under `.claude/`, `.codex/`, `.agents/`, `.github/`, `config/` or `extensions/drm-copilot/resources/` | PASS | none |
| No change under `.claude/hooks`, `.codex/hooks`, `.github/hooks` | PASS | none |
| No change to `scripts/dev_tools/push_down_*.py` | PASS | none |
| No change to the five static parity tests | PASS | none (`test_push_down_claude_parity.py`, `test_push_down_claude_overlay_parity.py`, `test_push_down_claude_exclusion_parity.py`, `test_push_down_claude_gitignore_parity.py`, `test_skill_bundle_contract_repo.py`) |
| No change to `quality-tiers.yml` or `docs/engineering/process-reductions/` | PASS | none |
| Zero `enumerateSourceFiles` in `push-down-service-call.ts` and the three ecosystem modules | PASS | 0, 0, 0, 0 |
| Zero `mkdtemp`, `tmpdir` or `writeFileSync` in new test files | PASS | none |
| Zero `mkdtemp`, `tmpdir` or `writeFileSync` in added test lines | PASS | none |
| No file above 800 lines | PASS | largest is `extensions/drm-copilot/jest.config.cjs` at 627 |

## Files above 500 lines (guidance tier), with reasons

| File | Lines | Reason |
| --- | --- | --- |
| `extensions/drm-copilot/jest.config.cjs` | 627 | 624 at the integration merge base; this item adds only the `require` line, its comment and the spread line (D9); new coverage entries go into `jest.push-down-coverage.json` |
| `extensions/drm-copilot/src/lib/push-down/push-down-pipeline.ts` | 508 | one cohesive planning module (read, enumerate, claim, classify, report); the apply half is already split into `push-down-apply.ts`; below the 700 advisory tier |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 502 | data manifest (one path per line) that must list every bundled core file; not code |

## Line counts of edited files that the plan bounds

| File | Integration merge base | Now | Rule |
| --- | --- | --- | --- |
| `lib/push-down/claude-customizations.ts` | 497 | 363 | fewer (P2-T3) |
| `lib/push-down/copilot-customizations-engine.ts` | 449 | 315 | fewer (P2-T5) |
| `repo-automation-service.ts` | 495 | 494 | not more (P3-T2) |
| `mcp-tool-inputs.ts` | 483 | 472 | fewer (P3-T3) |
| `repo-automation-command-registration-admin.ts` | 420 | 460 | at or below 500 (P3-T4) |

The full list of 65 added or changed code and data files with their line counts is in `SCRATCH/issue-1029-scope.txt` and is reproducible with the command above.
