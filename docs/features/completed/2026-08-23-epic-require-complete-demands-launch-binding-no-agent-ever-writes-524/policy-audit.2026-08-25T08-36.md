# Policy Compliance Audit — Issue #524 (Epic `require_complete` Launch-Binding Fix)

- Timestamp: 2026-08-25T08-36
- Branch: `bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524-r3`
- HEAD: `83b45f36` (merge of `origin/main`; branch is 0 commits behind main)
- Base: `origin/main` (merge base `429d8bc866`)
- Work mode: `full-bug` (marker verified in `issue.md`, line 13)
- Reviewer scope: full branch diff `git diff origin/main...HEAD`, verified directly against the resolved base branch in this session

## Scope of the Audit

The branch diff outside the feature folder contains exactly seven paths, confirmed by `git diff --name-status origin/main...HEAD` in this session:

| Path | Status |
| --- | --- |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | M |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` | M |
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` | M |
| `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` | M |
| `.claude/rules/orchestrator-state.md` | M |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | M |
| `docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md` | A |

All remaining diff paths are documentation and evidence under the feature folder `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/`.

Languages with changed files: Python and TypeScript (production plus tests) and Markdown (rule prose plus feature docs). PowerShell and C# have zero changed files on this branch.

## Rejected Scope Narrowing

None. The caller prompt requested the full feature-vs-base audit and enumerated the same seven-path diff this session independently derived from `git diff origin/main...HEAD`. No narrowing attempt was detected.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at review start. They were regenerated in this session with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD` before the audit proceeded (summary 35,422 bytes; appendix 25,407 bytes, both written 2026-08-25 08:37).

## Policy Verdicts

### 1. Tone policy (`CLAUDE.md`, `.claude/rules/tonality.md`) — PASS

The added rule section `## Epic Launch-Binding Activation Scope` (both rule-file copies, line 85) is factual, neutral, and evidence-first. Test docstrings and comments in both changed test files use plain Arrange/Act/Assert language. No humor, hyperbole, or decorative metaphor found in any changed file.

### 2. Do-not-modify-policy constraint — PASS with rationale

`.claude/rules/orchestrator-state.md` and its bundle twin are modified on this branch. This is not a violation: the spec (`spec.md`, In scope) explicitly requires "a prose record of the corrected activation scope in `.claude/rules/orchestrator-state.md` and its byte-identical bundle twin," and the change was authored by the feature executor as planned work, not by this reviewer. The reviewer modified no policy document. The canonical `.github/instructions/` files are untouched (absent from the diff).

### 3. General code change policy (`.claude/rules/general-code-change.md`) — PASS

- Simplicity: the fix is one predicate helper plus one guarded `continue`/`return` per runtime, with an explicit flag computed at the entry point. No new indirection.
- Reusability: the presence test is factored into `_carries_launch_path` (Python, lines 202-205) and `featureCarriesLaunchPath` (TypeScript, lines 234-237) rather than inlined twice.
- Public API compatibility: both entry points keep their signatures. The Python `_validate_launch_bindings` gains a keyword-only parameter with a default of `False`; the planner call site passes `require_launch_paths=False` explicitly, preserving planner behavior byte-for-byte. Verified by reading both modules in full.
- File size limit: all four changed code files are under 500 lines (298 / 325 / 427 / 336, measured with `wc -l` in this session).
- Error handling: no new error string is introduced; existing strings are unchanged in text and ordering (verified by reading the full diff — only control-flow lines were added).
- No new dependency is introduced.

### 4. General unit test policy (`.claude/rules/general-unit-test.md`) — PASS

- Both new tests per runtime are pure in-memory JSON tests: no filesystem, no clock, no temporary files, no external services. Verified by reading the test diff.
- Arrange/Act/Assert structure with explanatory comments is present in all four new tests.
- Test location: `tests/scripts/dev_tools/...` mirrors `scripts/dev_tools/...`; `extensions/drm-copilot/test/lib/validate/...` mirrors `extensions/drm-copilot/src/lib/validate/...`. No colocation.
- Scenario completeness: positive (skip), negative (partial binding), preserved negatives (unmerged feature, missing `merge_commit_sha`), Codex-flag unchanged behavior, and default-off behavior are all covered. See `code-review.2026-08-25T08-36.md` section "Deleted tests" for the residual-gap assessment (Non-blocking).

### 5. Language toolchain — Python — PASS

Verified in this session at merged HEAD `83b45f36` (targeted, check-only):

| Stage | Command | Result |
| --- | --- | --- |
| Format | `poetry run black --check` on both changed Python files | 0 changes ("2 files would be left unchanged") |
| Lint | `poetry run ruff check` on both changed Python files | "All checks passed!" |
| Type check | `poetry run pyright` on both changed Python files | `0 errors, 0 warnings, 0 informations` |
| Unit tests | `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | 37 passed |

Full-loop evidence: `evidence/qa-gates/final-qa-clean-pass.2026-08-25T08-23.md` records a single clean pass of the repo-wide Python loop (black, ruff, pyright, pytest 4117 passed / 0 failed) at commit `14e9cac0`. `git merge-base --is-ancestor 14e9cac0 HEAD` returns true, and `git diff 14e9cac0..HEAD` over all four changed code files is empty, so the evidence run covers the identical file contents present at HEAD.

### 6. Language toolchain — TypeScript — PASS

Verified in this session at merged HEAD (targeted, check-only, in `extensions/drm-copilot/`):

| Stage | Command | Result |
| --- | --- | --- |
| Format | `npx prettier --check` on both changed TS files | "All matched files use Prettier code style!" |
| Lint | `npx eslint` on both changed TS files | zero findings |
| Type check | `npm run typecheck` (`tsc -p ./ --noEmit`, project-wide) | zero errors |
| Unit tests | `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` | 1 suite, 24 tests passed |
| Unit tests | `node run-jest.cjs test/lib/validate/epic-orchestrator-state-core.test.ts` | 1 suite, 31 tests passed |

Full-loop evidence: same `final-qa-clean-pass.2026-08-25T08-23.md` (npm format/lint/typecheck clean; 195 suites, 2658 tests passed, 0 failed), same ancestry argument as above.

Stages 4, 6, 7 of the seven-stage loop (architecture-boundary, contract/schema, integration) have no separately configured command for these languages in this repository; the push-down resource-contract test and the Python/TypeScript parity tests inside the executed suites realize them, as the evidence artifact documents. Accepted as the repository's established practice.

### 7. Coverage — mandatory per language with changed files

Verification model: inspection of the pre-existing evidence artifacts (`evidence/qa-gates/coverage-delta-verification.2026-08-25T08-25.md`, produced at ancestor commit `14e9cac0` whose changed-file contents are byte-identical to HEAD), corroborated by a targeted re-measurement in this session.

| Language | Scope | Line | Branch | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Python | Repo-wide (`scripts.dev_tools` package) | 92.61% | 89.82% | >= 85% / >= 75% | **PASS** |
| Python | Changed file `_epic_orchestrator_state_launch_binding.py` | 97.48% | 94.64% | >= 85% / >= 75% | **PASS** |
| Python | Changed lines (new code) | 100% (4/4) | 100% (2/2) | no regression | **PASS** |
| TypeScript | Repo-wide (all files) | 96.66% | 90.05% | >= 85% / >= 75% | **PASS** |
| TypeScript | Changed file `epic-orchestrator-state-launch-binding.ts` | 96.00% | 92.72% | >= 85% / >= 75% | **PASS** |
| TypeScript | Changed lines (new code) | 100% (13/13) | 100% (6/6) | no regression | **PASS** |
| PowerShell | zero changed files on branch | — | — | — | N/A (permitted: no changed files) |
| C# | zero changed files on branch | — | — | — | N/A (permitted: no changed files) |

Corroboration run (this session): `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py --cov=scripts.dev_tools._epic_orchestrator_state_launch_binding --cov-branch --cov-report=term-missing` yields 113/119 statements and 51/56 branches (94% combined) from the single test file alone — already above both thresholds before the rest of the suite contributes, consistent with the full-suite figure of 116/119 and 53/56. No regression: baseline uncovered lines (185, 217, 277) map one-to-one onto post-change uncovered lines (185, 224, 287) as displaced pre-existing constructs; the evidence artifact documents the identity of each.

Markdown files (`.claude/rules/orchestrator-state.md`, its twin, feature docs, promotion record) carry no coverage obligation.

### 8. Cross-runtime parity (`orchestration-artifacts.ts` parity obligation) — PASS

- Control flow: `_validate_launch_bindings` and `validateLaunchBindings` apply the same three guards in the same order (non-object skip, `skip_not_started`, `require_launch_paths` presence gate). Verified by reading both modules in full.
- Activation flag: Python `require_launch_paths=not (require_codex_model_routing or require_codex_topology)`; TypeScript `requireCodexModelRouting !== true && requireCodexTopology !== true`. Equivalent by De Morgan over the boolean option surface.
- Presence predicate: both use key membership with OR (`in feature ... or ...` / `"..." in feature || ...`). The "either key" requirement of the spec is satisfied; a "both keys" reading is not present.
- Error-string parity for the new assertions: both runtimes assert the identical byte sequence `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.` (Python test line 178-181, concatenated; TS test line 165-167).

### 9. Rule-file twin parity — PASS

`cmp .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` reports the files identical (this session). `git grep -n -F "Epic Launch-Binding Activation Scope"` matches line 85 of both files. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passed in this session (10 tests inside the 37-test run).

### 10. Scope discipline — PASS

`git diff origin/main...HEAD --name-status` over the exclusion set `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `.claude/lib/orchestrator-state`, `.claude/hooks/validate-orchestrator-output.ps1`, `.codex`, `.agents`, `extensions/drm-copilot/jest.config.cjs` returned empty output (this session). The latent planner-surface defect is deferred to issue #543, which exists and is OPEN (`gh issue view 543` — `Bug: epic-planner-ready-gate-demands-codex-only-launch-binding`), with the promotion lifecycle record at `docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md` in the diff.

## Evidence Location Compliance

- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: `git diff origin/main...HEAD --name-only | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` returned no matches (exit 1). **PASS.**
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. **PASS.**
- All feature evidence lives under the canonical `docs/features/active/<feature>/evidence/<kind>/` tree (baseline, qa-gates, regression-testing, issue-updates, other). **PASS.**
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical evidence path.

## Findings Summary

| # | Finding | Severity |
| --- | --- | --- |
| 1 | `require_launch_paths` / `requireLaunchPaths` parameter name reads inverted relative to its effect (see `code-review.2026-08-25T08-36.md`, finding CR-1) | Non-blocking |

Blocking findings: **0**. No remediation-inputs artifact is required.

## Assumptions Documented

- The full-suite coverage and QA evidence was produced at ancestor commit `14e9cac0`, which predates the final merge of `origin/main` into the branch. Accepted because (a) the four changed code files are byte-identical between `14e9cac0` and HEAD (empty `git diff`), and (b) every targeted check re-run in this session at merged HEAD (format, lint, typecheck, unit tests, targeted coverage, both regression fixtures, push-down contract test) passed.
- The destination-repository checkpoints (drmoisan/TaskMaster) are not available here; the regression claim rests on the constructed fixtures, which this session re-validated at HEAD: the no-launch-paths fixture passes `--require-complete` (exit 0) and the one-unmerged variant fails with exactly one completion error (exit 1).
