# Feature Audit: legacy-discovery-publishing (#372)

**Audit Date:** 2026-07-19
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-publishing-372`
**Base Branch:** `origin/epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-publishing-372`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/legacy-discovery-and-parity-integration` (commit `a6dd7d4591ef80f4d351cea4b0488ce08568286e`, "docs(epic): launch wave 3 (#370, #372), mark worktree_created")
- **Head branch/commit:** `feature/legacy-discovery-publishing-372` (commit `e64efcd136929f45febca53aec359e46e384f64e`, "test(discovery): add manifest-completeness verification for Python side")
- **Merge base:** `a6dd7d4591ef80f4d351cea4b0488ce08568286e` (equals the resolved base head — the base is fully merged into the feature branch; the diff range is the full branch-vs-base diff)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated during this review via `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/legacy-discovery-and-parity-integration --head HEAD`, since no prior artifact existed)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/**` (30 artifacts across `baseline/`, `other/`, `qa-gates/`, `regression-testing/`)
  - Additional evidence: direct git diff/filesystem verification performed by this reviewer (see Appendix-equivalent command list in `policy-audit.2026-07-19T07-10.md`)
- **Feature folder used:** `docs/features/active/2026-07-17-legacy-discovery-publishing-372/` (suffix `-372` matches the issue number in the branch name; only active feature folder for this branch)
- **Requirements source:** work mode `full-feature` -> `spec.md` (13 ACs) and `user-story.md` (5 ACs), per the persisted `- Work Mode: full-feature` marker in `issue.md`.
- **Work mode resolution note:** explicit marker present in `issue.md`; no fail-closed inference needed.
- **Scope note:** the audit scope is the full branch-vs-base diff (one commit, `e64efcd1`), not the plan's task-level scope. All acceptance-criteria evaluations below are independently re-verified by this reviewer via direct command execution and filesystem inspection, not merely transcribed from the executor's or plan's own claims. This reviewer additionally treated the delegating agent's framing of the TypeScript-defect question as a request for independent judgment, not as an instruction to narrow scope; see the dedicated reasoning subsection below.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md` — primary source (13 ACs)
- `docs/features/active/2026-07-17-legacy-discovery-publishing-372/user-story.md` — primary source (5 ACs)

### From spec.md (13 acceptance criteria)

1. Every new `.claude/agents/*.md` persona file introduced by `legacy-discovery-agent-roles` is present byte-identically at the matching path under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`.
2. Every new `.claude/skills/<name>/SKILL.md` skill introduced by `legacy-discovery-skills` is present byte-identically at the matching path under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`.
3. Every new `.claude/hooks/*` file introduced by `legacy-discovery-hooks` is present byte-identically at the matching path under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and any corresponding `.claude/settings.json` hook-registration change is mirrored.
4. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with all newly mirrored `.claude/**` assets present, with no modification to that test's enumeration logic.
5. Each mirrored asset's Codex-native converted equivalent is present byte-identically under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, and `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` passes.
6. This spec documents the Codex-native converter registration determination (purely structural; no `mapping.py`/`classifier.py`/`inventory.py` edits), and no such edits are present in the change set for name-based registration of the new agent/skill/hook categories.
7. Every new agent-persona path and every new skill `SKILL.md` path is added as an individual path-string entry to the `paths` array of both `pack-manifests/core.json` files (using the converted `.codex`/`.agents` destination path on the Codex side).
8. Every new hook path is added as an individual path-string entry to both `core.json` manifests.
9. A real-filesystem manifest-completeness test exists on the Python side or the Codex side (a functional twin of `claude-pack-manifest-completeness.test.ts`), asserting every bundled `.claude/agents/*.md`, `.claude/hooks/*`, and `.claude/skills/*/SKILL.md` file appears in the union of every manifest's `paths` array, and that test passes.
10. The schema (`legacy-discovery-schemas`) and init-template (`legacy-discovery-init-templates`) mirror obligation is resolved per the conditional rule in "Schema/Init-Template Placement": mirrored into `resources/` with a `core.json` entry if landed under a mirrored root, or explicitly documented as out of mirror-contract scope if landed under `scripts/`.
11. `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pass.
12. The TypeScript twin push-down tests under `extensions/drm-copilot/test/lib/push-down/`, including `claude-pack-manifest-completeness.test.ts` and its new Python/Codex-side counterpart, pass.
13. No TaskMaster/TMW/Outlook/VSTO/email/task-management-specific identifier is introduced by any file, manifest entry, or test added by this feature.

### From user-story.md (5 acceptance criteria)

1. A consumer repository's existing, unmodified push-down invocation (including a language-scoped `--packs` selection) receives every new discovery-framework agent persona, skill, and hook because those assets are placed in the `core` pack, unconditionally unioned into every `--packs` selection.
2. No consumer repository is required to add a new pack name, flag, or manual file-copy step to receive the discovery capability.
3. The push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and their TypeScript twins) pass with the mirrored discovery assets present, so a maintainer pulling from a green drm-copilot build never observes a missing or corrupted mirrored file.
4. A manifest-completeness check (existing on the Claude/TypeScript side; extended to the Python/Codex side by this feature) prevents a bundled discovery asset from being present in the mirror but silently absent from a scoped `--packs` pull.
5. The Codex-native converter requires no per-consumer or per-asset registration step: a consumer relying on the Codex/`.agents` surface receives the same discovery capability through the existing path-prefix classification, with no additional configuration.

---

## Acceptance Criteria Evaluation

### spec.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `.claude/agents/*.md` personas byte-identical in bundle | PASS | `.claude/agents/*.md` (22 files) byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/*.md` (22 files); zero name/content diff | `diff <(cd .claude/agents && ls *.md \| sort) <(cd extensions/drm-copilot/resources/claude-customizations/.claude/agents && ls *.md \| sort)` -> no diff | Independently re-verified by this reviewer, not merely trusted from `claude-mirror-gap-inventory.md`. |
| 2 | `.claude/skills/<name>/SKILL.md` byte-identical in bundle | PASS | Full recursive `.claude/skills/**` tree byte-identical to bundle tree | `diff <(cd .claude/skills && find . -type f \| sort) <(cd .../claude-customizations/.claude/skills && find . -type f \| sort)` -> no diff | Independently re-verified. |
| 3 | `.claude/hooks/*` byte-identical (+ settings.json mirror if applicable) | PASS | Full `.claude/hooks/` tree byte-identical; `.claude/settings.json` not listed as a gap (no hook-registration change needed) | `diff <(cd .claude/hooks && ls -1 \| sort) <(cd .../claude-customizations/.claude/hooks && ls -1 \| sort)` -> no diff | Independently re-verified. |
| 4 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes, no enumeration-logic edit | PASS | Test passes; `git diff` on `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is empty (file not in the changed-file list) | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` -> 7 passed; `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD` does not list this file | Independently re-run. |
| 5 | Codex-converted equivalents byte-identical + test passes | PASS | `.codex/agents/*.toml` and `.agents/skills/**` byte-identical to bundle; test passes (6/6) | `diff <(cd .codex/agents && ls *.toml \| sort) <(cd .../.codex/agents && ls *.toml \| sort)`; `diff <(cd .agents/skills && find . -type f \| sort) <(cd .../.agents/skills && find . -type f \| sort)`; `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -v` -> 6 passed | Independently re-verified. |
| 6 | Converter registration determination documented, no source edits | PASS | `git diff` on `mapping.py`/`classifier.py`/`inventory.py` is empty; `spec.md` documents the determination in a dedicated section | `git diff --stat origin/epic/legacy-discovery-and-parity-integration...HEAD -- scripts/dev_tools/codex_native_converter/mapping.py scripts/dev_tools/codex_native_converter/classifier.py scripts/dev_tools/codex_native_converter/inventory.py` -> empty | Independently re-verified. |
| 7 | Agent/skill paths added individually to both `core.json` | PASS | Zero-count outcome: `git diff` on both `pack-manifests/core.json` files is empty; consistent with zero new mirror-copy files (AC 1–2 already byte-identical pre-feature) | `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` -> no output | The zero-count outcome is the correct result given AC 1–2's zero-gap finding, not an omission. |
| 8 | Hook paths added individually to both `core.json` | PASS | Same zero-count basis as AC 7 | (same command as AC 7) | Same evidence basis. |
| 9 | Real-filesystem manifest-completeness test exists (Python/Codex) and passes | PASS | Both new modules exist and pass (4/4); independently spot-checked as non-vacuous (Codex-side exception list matches an independently-computed missing-agent set exactly) | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -v` -> 4 passed | See `code-review.2026-07-19T07-10.md` for the non-vacuousness spot-check detail. |
| 10 | Schema/init-template mirror obligation resolved | PASS | `spec.md`'s new "Schema/Init-Template Placement — Resolved" section cites `schemas/discovery/v1/*.schema.json` and `docs/discovery/templates/**`; both independently confirmed present at those non-mirrored paths | `ls schemas/discovery/v1/`, `ls docs/discovery/templates/`, `ls scripts/dev_tools/discovery/` (all present); none of these three roots is `.claude/`, `.codex/`, or `.agents/` | Independently verified the assets exist at the documented non-mirrored roots, corroborating the "no mirror copy, no manifest entry" resolution. |
| 11 | Python push-down contract tests pass | PASS | Both resource-contract test modules pass (13/13 combined) | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -v` -> 13 passed | Independently re-run. |
| 12 | TypeScript twin push-down tests pass | PASS (reviewer-independent verification; left unchecked in `spec.md` by design — see Notes) | Suite could not run from this worktree (Jest `testMatch` path-resolution defect, root cause independently confirmed). This reviewer independently ran the byte-identical push-down suite from the main repository checkout and confirmed 12/12 suites, 137/137 tests pass, including `claude-pack-manifest-completeness.test.ts`. | This worktree: `node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"` -> "No tests found", exit 1. Main checkout: `node run-jest.cjs --testPathPattern "test/lib/push-down"` -> 12 passed, 137 passed, exit 0. Tree-identity check: `git diff --stat main...HEAD -- extensions/drm-copilot/src/lib/push-down extensions/drm-copilot/test/lib/push-down` -> empty. | See "TypeScript Twin-Test Blocking Determination" below for full reasoning. This reviewer evaluates the criterion PASS on independently-verified evidence but does not check it off in `spec.md`, since the plan's own literal acceptance bar (a passing artifact produced from this worktree) was not met; the gap is documented instead. |
| 13 | No domain-specific identifiers introduced | PASS | Full-diff case-insensitive grep for `TaskMaster\|TMW\|Outlook\|VSTO` returns matches only inside plan/spec prose that names the terms as things being checked for; zero occurrences in the two new production/test files | `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD \| grep -niE "TaskMaster\|TMW\|Outlook\|VSTO"` -> 5 matches, all in `plan.md`/`spec.md` prose referencing the check itself, none in code | Independently re-run against the full diff, not just the two changed test files. |

### user-story.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Consumer's unmodified `--packs` invocation receives discovery assets via `core` pack | PASS | `core.json` unmodified; the four #365 discovery personas already registered in `core.json` pre-feature; `always_includes_core` test passes | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py -k always_includes_core -v` -> passed | Independently re-run. |
| 2 | No new pack/flag/manual copy required | PASS | Zero new packs introduced; `git diff` confirms no pack-selection-logic file changed | `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD` (no `push_down_*pack_selection.py` file listed) | Independently confirmed. |
| 3 | Contract tests (Python + TS twins) pass | PASS (reviewer-independent verification; left unchecked in `user-story.md` by design — see Notes) | Python: 13/13 pass (AC 11 above). TS: independently corroborated 137/137 passing from an alternate, byte-identical-tree checkout; could not be executed from this worktree due to the documented Jest defect. | Same evidence as spec.md AC 11 and AC 12. | Same reasoning as spec.md AC 12; see "TypeScript Twin-Test Blocking Determination" below. |
| 4 | Manifest-completeness check extended to Python/Codex side | PASS | Both new test modules exist and pass | Same as spec.md AC 9. | Independently re-verified. |
| 5 | Converter requires no per-consumer registration | PASS | Zero diff to `mapping.py`/`classifier.py`/`inventory.py` | Same as spec.md AC 6. | Independently re-verified. |

---

## TypeScript Twin-Test Blocking Determination (independent reviewer judgment)

The delegating context asked this reviewer to independently verify the executor's finding regarding the TypeScript Jest test-discovery failure and to reach an independent conclusion on whether it constitutes a Blocking finding for this feature's review, rather than deferring to the executor's framing. This reviewer performed the following independent verification steps (not present in the executor's evidence):

1. **Reproduced the failure directly** in this worktree: `node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"` -> `No tests found, exiting with code 1`, `testMatch: ... 0 matches` against 353 discovered files.
2. **Confirmed the root cause independently** via `npx jest --showConfig`: the resolved `testMatch` value is `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a66ce225a2ded5e52/extensions/drm-copilot/test/**/*.test.ts` — a literal backslash injected immediately before the `.claude` path segment amid an otherwise forward-slash-normalized absolute-path glob. This is consistent with, and independently corroborates, the executor's claimed root cause.
3. **Confirmed zero TypeScript files changed by this feature**: `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD -- "*.ts" "*.tsx"` returns 0 results.
4. **Confirmed tree-level byte-identity** between the main repository checkout (`main` branch, commit `d13b3d31`, no dot-prefixed path segment) and this feature branch for the exact scope under test: `git diff --stat main...HEAD -- extensions/drm-copilot/src/lib/push-down extensions/drm-copilot/test/lib/push-down` returns no output (zero differences), and `git diff --name-only main HEAD -- extensions/drm-copilot/src/lib/push-down extensions/drm-copilot/test/lib/push-down` confirms zero changed files across the full history since the `main`/feature-branch merge-base. This means the push-down TypeScript source and test files on this feature branch are byte-for-byte identical to what exists on `main`.
5. **Ran the identical suite from the main checkout**: `node run-jest.cjs --testPathPattern "test/lib/push-down"` from `C:\Users\DanMoisan\repos\drm-copilot` (no dot-segment) -> `Test Suites: 12 passed, 12 total`, `Tests: 137 passed, 137 total`, exit code 0. This run includes `claude-pack-manifest-completeness.test.ts`, the specific pre-existing TS test named in spec.md AC 12.
6. **Noted an unrelated, pre-existing config property**: adding `--coverage` to the main-checkout run additionally triggers unrelated per-file `coverageThreshold` failures for files entirely outside `src/lib/push-down` (e.g., `src/mcp-tool-inputs.ts`, `src/lib/subagent-tree/**`), because `jest.config.cjs`'s `coverageThreshold` block gates the full `collectCoverageFrom: ["src/**/*.ts", ...]` set regardless of `--testPathPattern` scope. This is a separate, pre-existing, unrelated Jest configuration property (confirmed by reading `jest.config.cjs` directly, including its own comment: "Per-changed-file thresholds only... a global threshold would fail the run on unrelated legacy coverage"), not evidence against the push-down suite's own health, and not something introduced or touched by this feature.

**Determination: NOT a Blocking finding for this feature's review.** Reasoning:

- This feature changed zero TypeScript files (confirmed independently, not merely asserted).
- The defect's root cause (a worktree-path string-handling quirk in Jest's `testMatch` resolution) is proven, via independent reproduction and root-cause tracing, to be a property of this specific worktree's absolute path, not of the code under test.
- Independent corroboration from an alternate, provably byte-identical checkout demonstrates the actual push-down TypeScript test suite — including the specific test named in the acceptance criterion — passes cleanly (137/137, 12/12 suites) when run in an environment unaffected by the defect.
- CI checks out via `actions/checkout@v7` to a runner-native workspace path that does not contain a `.claude/worktrees` segment (confirmed by inspecting the checkout action's default behavior and the absence of any custom `path:` override for this repository's extension-test workflow), so this specific failure mode is very unlikely to reproduce in the CI environment that will actually gate the merge.
- Fixing the root cause (most plausibly in `extensions/drm-copilot/jest.config.cjs`'s `testMatch`/`rootDir` handling, or a Jest/micromatch version property) is unrelated to this feature's own plan scope (`extensions/drm-copilot/resources/**`, `scripts/dev_tools/**`, `tests/scripts/dev_tools/**`) and would constitute a separate, repo-wide infrastructure fix.

Both spec.md AC 12 and user-story.md AC 3 are evaluated **PASS** in the tables above on the strength of this independent corroborating evidence. However, per the acceptance-criteria-tracking check-off protocol ("Evidence before check-off: Only mark an AC item `[x]` after the work satisfying it has been implemented and verified"), this reviewer intentionally does **not** check off either item in the source files, because the plan's own literal acceptance bar for these specific tasks (`P0-T18`, `P7-T2`, `P8-T8` — "artifact exists... `EXIT_CODE: 0` recorded" from *this* worktree) was not met, and the executor's own evidence artifacts correctly record these tasks as unchecked/BLOCKED. Leaving them unchecked in the source files preserves an accurate, auditable trail that the literal task-level verification gap still exists and should be closed by a future re-run from an unaffected environment (CI or a non-dotted-path checkout), even though this reviewer's own independent judgment is that the gap does not warrant blocking this PR. This is recorded as a documented Advisory finding in `policy-audit.2026-07-19T07-10.md` and `code-review.2026-07-19T07-10.md`, with a recommended follow-up.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary (spec.md, 13 ACs):**
- **PASS:** 13 criteria (all 13; AC 12 evaluated PASS on independent reviewer evidence, left unchecked in the source file per the check-off protocol — see above)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Criteria summary (user-story.md, 5 ACs):**
- **PASS:** 5 criteria (all 5; AC 3 evaluated PASS on independent reviewer evidence, left unchecked in the source file per the check-off protocol — see above)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None preventing the overall PASS verdict. The two items left unchecked in the source files (spec.md AC 12, user-story.md AC 3) are documented, independently-corroborated-as-passing, environment-specific verification gaps rather than functional failures; see "TypeScript Twin-Test Blocking Determination" above for the full reasoning behind treating this feature as GO despite the two unchecked boxes.

**Recommended follow-up verification steps:**

1. Re-run `node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"` from CI or a non-dotted-path checkout and record a passing artifact, then check off spec.md AC 12 and user-story.md AC 3 with that evidence.
2. Open a separate, repo-wide infrastructure issue for the Jest `testMatch`/`rootDir` worktree-path defect (`extensions/drm-copilot/jest.config.cjs`) so future worktree-based agent sessions do not re-encounter this blocker.
3. Open a separate remediation issue for the pre-existing Codex-side pack-manifest completeness gap (73 undocumented-until-now entries) identified transparently by this feature's new test module.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, criteria evaluated as PASS may be checked off if not already checked. This reviewer independently re-verified all 13 spec.md items and all 5 user-story.md items evaluated above; every item that was already checked `[x]` in the source files remains correctly checked (no phantom or premature check-offs were found), and no additional item required checking off beyond what the executor had already marked, **except** that this reviewer's independent verification confirms AC 11 (spec.md) — "Python push-down contract tests pass" — was already correctly checked, and no source-file edit was needed for any item.

Two items (spec.md AC 12, user-story.md AC 3) are evaluated PASS in this audit's evidence tables above but are intentionally left unchecked in the source files, per the reasoning in "TypeScript Twin-Test Blocking Determination." No source-file checkbox was changed by this review.

### AC Status Summary

- Source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md`
- Total AC items: 13
- Checked off (delivered): 12 (pre-existing from executor's work; independently re-verified, no change made)
- Remaining (unchecked): 1
- Items remaining: "The TypeScript twin push-down tests under `extensions/drm-copilot/test/lib/push-down/`, including `claude-pack-manifest-completeness.test.ts` and its new Python/Codex-side counterpart, pass." (independently verified PASS via an alternate checkout; left unchecked pending a literal in-worktree or CI re-run per the check-off protocol)

- Source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/user-story.md`
- Total AC items: 5
- Checked off (delivered): 4 (pre-existing from executor's work; independently re-verified, no change made)
- Remaining (unchecked): 1
- Items remaining: "The push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and their TypeScript twins) pass with the mirrored discovery assets present..." (Python half independently verified PASS; TypeScript half independently verified PASS via an alternate checkout; left unchecked pending a literal in-worktree or CI re-run per the check-off protocol)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 13 | 12 | 1 | Checkbox-backed. Item 12 independently evaluated PASS but left unchecked per check-off protocol (see above). |
| `user-story.md` | 5 | 4 | 1 | Checkbox-backed. Item 3 independently evaluated PASS but left unchecked per check-off protocol (see above). |

No source-file checkbox change was made by this review: all 16 already-checked items were independently re-verified as legitimately supported by evidence (no phantom check-offs found), and the 2 remaining unchecked items are intentionally left unchecked per the reasoning above rather than checked off by this reviewer.
