# Code Review: retire `.github/skills` and thin the Copilot layer (#1032)

---

**Review Date:** 2026-11-20
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`
**Feature Folder Selection Rule:** named by the orchestrator delegation for issue #1032
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `0cf0dd629c51e74d84298e3c8c98b01044c4ec3d`, AD-7)
**Head Branch:** `feature/retire-github-skills-and-thin-copilot-layer-1032` at `6a0b4b3f7da7d98629be3fa3c695834e9b514406`
**Review Type:** Initial S7 review and post-remediation re-review of cycles 1 and 2

---

## Executive Summary

The branch is dominated by deletions: both `RETIRED-SKILL-TREES` (104 files in commit `720b4ec7d`, plus the two incoming `push-down-integration` Copilot copies removed during the cycle-2 merge), the `AGENTS.md` sync writer, its bundled template and its Pester suite. Production code edits are confined to six files and consist of removals or text-only changes: one array element in `copilot-customizations-engine.ts`, one tuple element in `agentic_sync.py`, one catalog entry in `reference-rewrites.ts` and its Python twin, the writer command registration in `repo-automation-command-registration-admin.ts`, and a comment and finding detail in `HarnessInstructions.psm1`. The remaining changes are Markdown (brief copy counts, read-first repoints, Copilot instructions, current-fact documents), JSON data (parity matrix, pack manifests, tasks, shard weights), ledger entries and stored patches, and pinning tests. A new Pester guard suite pins the end state.

Evidence reviewed: the PR context summary and appendix generated at the reviewed head, the full branch diff, the five plans and two remediation inputs, the cycle-2 gate records, the executor's coverage reports, and a reviewer root Jest coverage run.

**What changed:**
Retirement of the Copilot skill copies and their bundle mirror; Branch B `native` dispositions for 50 `copilot:agent:` entries; Copilot instructions reduced to Copilot-only text; user-scope collision controls in `README.md`; writer retirement across all `H3-SURFACES`; six-to-four count rewrites in all remaining brief and contract copies; ledger regions removed or regenerated in the same commits; pack-manifest entries for retired paths removed (cycle 1) and the cycle-2 merge conflicts resolved with the retired copies kept deleted.

**Top 3 risks:**
1. Destination repositories that received `.github/skills` from earlier push-downs keep stale copies until child 4's destination cleanup runs (spec risk R3; outside this child's scope).
2. Collision controls are user-scope documentation only (E4 read as `no`), so contributors who skip the README step still see duplicate loading (spec risk R1).
3. No CI run exists at the reviewed head; the last green runs are at `02a329dc1` and `58bca152e`, before the cycle-2 merge. The S9 gate covers this.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all gates passed at the reviewed head and both remediation cycles are resolved.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` | `Test-ClrBriefCount` retired-path branch; `Test-ClrCollisionControl` workspace branch | CR-1: two rule branches have no discriminating negative case. No `-REJECTS` case feeds a brief copy that names the retired path, and no case feeds a complete workspace-scope settings file (the REJECTS case has no `chat.` key), so a defect in the workspace-case value comparison would not fail any test. | Add a brief-copy fixture holding the retired path, and a workspace-case fixture with one wrong value (for example `".claude/skills": true`), each asserting one violation. Can be done in a later change that touches the suite. | The positive cases pass at the head regardless of these branches; the guard intent is fully met only when each rule clause can fail. | Inspection of lines 119 to 180 and 251 to 316 of the suite. |
| Info | `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | `COPILOT_ROOT_FOLDERS` | CR-2: the retired root is removed; the file was later refactored by #1029 and now reports 100.00% lines and branches. Spec risk R5 (`fs.listFiles` on an absent root) is moot because the root is no longer listed. | None. | Confirms cycle-1 finding F2 is resolved. | `git diff 0cf0dd629..HEAD` of the file; `coverage/coverage-summary.json`. |
| Info | `coverage/lcov.info` (gitignored) | worktree root | CR-3: the executor's final Jest gate wrote its report under `SCRATCH`, so the canonical TypeScript artifact was absent at review start. The reviewer ran one root Jest coverage run (6482 passed) and recorded it as new evidence. | Executors should run the root Jest coverage command, or copy the canonical artifact, at the final gate. | The coverage stop hook and this review read the canonical path. | `evidence/qa-gates/review-jest-root-coverage.2026-11-20T05-09.md` |
| Info | spec AC18 and AC22 commands | `origin/main...HEAD` and `origin/main..HEAD` | CR-4: read literally against `origin/main`, the AC18 command lists one added `.py` file (`tests/scripts/dev_tools/atomic_executor/test_cli_compat_proxies.py`, added by sibling #1035 commit `6ba112a13` on the integration branch). Under AD-7 the scope is the integration merge base, where no `.py` file is added. | None; AD-7 is the recorded scope decision. | Prevents a false FAIL when the commands are re-run literally. | `git diff --name-only --diff-filter=A origin/main...HEAD`; `git log --diff-filter=A` of that file. |

No Blocker or Major findings. No covered file is at or above 700 logical lines, so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- `scripts/dev_tools/agentic_sync.py`: the `.github/skills` element is removed from `ROOT_FOLDERS`, and the module docstring now lists the four remaining roots, including `.github/hooks`, which the old docstring omitted.
- `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`: one `RewriteTarget` removed from the `targets` tuple, matching the TypeScript catalog.

#### Typing and API notes
- Typed tuple constants keep their annotations; no signature changed.

#### Error handling and logging
- Not affected.

### TypeScript implementation audit (if applicable)

#### What changed well
- `repo-automation-command-registration-admin.ts`: `registerSyncAgentsFromInstructionsCommand` and its registration call are removed together, and the `./command-runtime` import is narrowed to the symbol still used, so no dead import remains.
- `reference-rewrites.ts`: the writer catalog entry and the catalog-size doc comment change together, keeping the Python twin and the TypeScript catalog in parity.
- `package.json`: the `contributes.commands` entry is removed; the CHANGELOG records the removal under `### Removed` in `## [Unreleased]`.

#### Type safety and maintainability
- No type was widened; no suppression comment added.

#### Error handling and logging
- Not affected.

### PowerShell implementation audit (if applicable)

#### What changed well
- `HarnessInstructions.psm1`: the comment and the `GENERATED-NOTE` finding detail name the retired writer by issue instead of a deleted path, so the stale-reference search for the writer finds no hit in live code; the detection string `> NOTE: This file is **generated** from:` is unchanged, so the check child 3 relies on still fires.
- The new guard suite separates reader seams from pure rule checks and builds the retired path and writer tokens at runtime, so the suite does not register as a stale reference itself.

#### API and safety notes
- The guard suite reads only; it writes nothing and removes its helper functions in `AfterAll`.

#### Error handling and logging
- An absent file is returned as `$null` and reported as a named violation.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md`: 29123 passed, 0 failed; guard suite 22, ledger chain 5, ledger 69, parity-matrix gate 7, file-size gate 5.
- `evidence/regression-testing/c2-pytest-final.2026-11-20T04-43.md`: 17101 passed, 0 failed; `PUSH-DOWN-CONTRACT-TESTS` and `BRIEF-PIN-TESTS` named.
- `evidence/regression-testing/c2-jest-final.2026-11-20T04-43.md`: 6450 passed, 0 failed; `push-down-integration-skill.test.ts` and `push-down-ci-contract.test.ts` updated by cycle 2.
- `evidence/qa-gates/c2-final-static.2026-11-20T04-34.md`, `c2-contract-checks.2026-11-20T04-34.md`, `c2-brief-copy-facts.2026-11-20T04-37.md`, `c2-coverage-note.2026-11-20T04-56.md`, `self-review.2026-11-20T04-59.md`.
- `evidence/qa-gates/review-jest-root-coverage.2026-11-20T05-09.md` (reviewer).

### Quality assessment prompts
- Edits to pinning suites remove only rows for retired copies; the remaining-copy assertions are kept, and the canonical copy in `test_execution_environment_brief_contracts.py` and `test_discovery_documentation_contracts.py` moved to `.agents/skills/execution-environment/SKILL.md`.
- The three `tests/scripts/claude-hooks/*.Parity.Tests.ps1` suites, `test_bash_command_shape_surfaces.py` and `PoshQC.VendoredCoverage.RepoGate.Tests.ps1` are outside the spec's named sets; each edit removes the two retired brief copies from a copy list, which is the required consequence of the deletion and of cycle-2 finding F1.
- Each `CLR-` rule has a positive and a negative case; see CR-1 for the two branches without a negative case.

---

## Security / Correctness Checks

- No secrets, credentials, or host paths added; `git grep` of the diff found no absolute host path in added evidence.
- `REMAINING-BRIEF-COPIES` share one blob (`a566b17e4`); contract copies form the two pre-existing pairs (AD-8).
- No source wording of `BRIEF-COUNT-STATEMENTS` remains in any brief or contract copy; the location list in S1 names exactly the four remaining copies.
- The 61 files that still hold `.github/skills` outside `docs/features/` match the cycle-2 classification exactly (file and count), with 0 unclassified and 0 `example` hits; no `COPILOT-AGENT-FILES` member has a hit.
- Writer tokens remain only in the 8 classified files (`historical` and `example`).
- `LEDGER-RECORDS` hold none of the three retired header strings; `ProcessReductionChain.psm1` is not in the diff.
- `git merge-tree` against the integration tip reports no conflict.

---

## Research Log

- `git -C <worktree> diff --name-status 0cf0dd629..HEAD` and per-file diffs of every production file and every test outside the spec's named sets.
- `git -C <worktree> ls-files -s` of the brief and contract copies.
- `git -C <worktree> grep -c -F '.github/skills'` compared with `evidence/other/stale-reference-classification.2026-11-20T04-37.md` by a sorted file-and-count diff (identical).
- `git -C <worktree> log --first-parent 0cf0dd629..HEAD -- docs/engineering/process-reductions/` for ledger tokens.
- Node scripts over `coverage/coverage-summary.json`, the executor pytest JSON report, and logical line counts of 49 covered files.
- Inspection of `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` in full.

---

## Verdict

**Go.** No Blocker or Major finding. One Minor test-discrimination observation (CR-1) and three Info notes are non-blocking and are not carried into remediation inputs.
