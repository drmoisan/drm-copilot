# Policy Audit: Parallel Orchestrator Surface (#441)

- **Timestamp:** 2026-08-08T20-25
- **Feature folder:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`
- **Issue:** #441
- **Base branch (resolved):** `epic/parallel-orchestration-integration`
- **Merge base:** `ee0626e838109fe8d3fe3904fb4631c71879baa3`
- **Feature branch head:** `feature/parallel-orchestrator-surface-441` @ `aa987c1202da3c88807f6bfefc6ba4279468b06c`
- **Work mode:** `full-feature` (marker read from `issue.md:10`)
- **AC sources:** `spec.md` (22 criteria, section at `spec.md:525`) and `user-story.md` (11 criteria, section at `user-story.md:101`)
- **Review type:** re-audit after remediation cycle 1 (prior artifacts timestamped 2026-08-08T18-12; remediation plan `remediation-plan.2026-08-08T18-20.md`)
- **Audit scope:** the full branch diff versus the resolved base branch — 74 files changed, 8596 insertions, 97 deletions across 2 commits (`41633ad5`, `aa987c12`)

## Executive Summary

**Verdict: COMPLIANT.** Both Major findings from cycle 1 are resolved. CR-01 (the parent-side `remediation-inputs` write was not covered by the persona's `Write` grants) is resolved by reassigning the capture and the finding write to the child's `atomic-executor`. CR-02 (the persona had no permitted mechanism to run the manifest-validation gate it must pass) is resolved by granting `Bash(poetry run python -c *)` and naming the exact granted invocation in the gate section. The recommended structural test closing the gap class is delivered as `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py`.

This reviewer independently re-ran every gate rather than accepting the executor's evidence. The full Python toolchain passes in a single pass: Black exit 0 (374 files unchanged), Ruff exit 0 ("All checks passed!"), Pyright 0 errors / 0 warnings / 0 informations, Pytest 3007 passed / 0 failed / 0 skipped. Repo-wide Python line coverage is 91.82% against an 85% floor and branch coverage is 83.80% against a 75% floor, with zero regression, re-aggregated by this reviewer directly from `artifacts/python/lcov.info` rather than by re-running coverage generation.

The reviewer also probed the new contract test for vacuity rather than accepting a passing result. The permission-seam parsers return two prescribed write targets and fourteen prescribed command invocations, all covered; the parsers reject `poetry run pytest -q`, `poetry run black .`, `npm run build`, and `rm -rf /` as uncovered, so the grant-coverage predicate discriminates rather than accepting everything. Details in section 8.

All 33 acceptance criteria are verified PASS. Blocking findings: **0**. Remediation is not required and no `remediation-inputs` artifact is produced for this cycle. Five non-blocking findings are recorded in section 8, the most consequential being that plan tasks P4-T7 and P4-T8 name verification tools that cannot pass on the path they target at HEAD *or* at the merge base — a plan-authoring defect rather than a code defect.

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt stated "No scope narrowing is intended or implied" and instructed "Determine scope yourself per your scope invariant." The scope used is the full branch diff versus `epic/parallel-orchestration-integration`, independently re-derived: `git merge-base HEAD epic/parallel-orchestration-integration` returns `ee0626e838109fe8d3fe3904fb4631c71879baa3`, matching the supplied merge-base SHA.

Three caller-supplied items were framed as facts for independent evaluation rather than as conclusions or scope instructions, and were treated accordingly:

1. The P4-T7 / P4-T8 JSON-governance matter, offered with the closing instruction "Reach your own conclusion on severity and attribution." Independently re-verified at both HEAD and the merge base; conclusion in section 8, Gap G1.
2. The Phase 6 two-iteration toolchain loop and its Ruff TC003 root-cause fix. Independently verified; section 7.
3. The Pester environment note, explicitly offered "as fact rather than as a scope instruction."

Item 3 warrants an explicit record because, if accepted uncredited, it would have functioned as a pre-excuse for a PowerShell test failure. It was not accepted uncredited. Both named suites were executed by this reviewer. The note is **partly inaccurate**: it asserts that both suites fail, but the measured result over the two suites together is `TOTAL=52 PASSED=51 FAILED=1`, with the single failure in `enforce-pr-author-skill.Tests.ps1` and zero failures in `codex-pretooluse-integration.Tests.ps1`. The note's stated mechanism is correct for the one genuinely failing test. Non-attribution to this branch is established structurally rather than by accepting the note: see section 8, Gap G2.

A stale-input observation, recorded for transparency rather than as a narrowing: `artifacts/pr_context.summary.txt` records `Head ref (resolved): HEAD @ 41633ad5e867070853e3e4501c3457b6641d1efc`, which is the *first* of the two branch commits. The remediation commit `aa987c12` is not reflected in the summary's head field. The audit was therefore scoped from live `git` state at `aa987c12`, not from the summary's head field, and every finding in this artifact is derived from commands run against `aa987c12`. The appendix and summary remain usable as narrative context.

## Evidence Location Compliance

`poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exits **0**.

A direct scan of the committed branch diff for the forbidden evidence sub-paths returns no files:

```
git diff ee0626e838109fe8d3fe3904fb4631c71879baa3..aa987c1202da3c88807f6bfefc6ba4279468b06c \
  --name-only -- .github scripts/benchmarks artifacts
  -> (empty)
```

The branch adds zero files under `artifacts/` of any kind, so the prohibited `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/` locations cannot be populated by it. Every evidence artifact this branch adds resides under `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/<kind>/`, using only the canonical kinds `baseline/`, `other/`, `qa-gates/`, `regression-testing/`, and `remediation-baseline/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review; this reviewer wrote no evidence artifacts outside the canonical scheme.

**Verdict: PASS.**

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence / order-independence | PASS | 3007 tests pass in a full-suite run; the two parallel-orchestrator contract suites also pass in isolation (39 passed in 0.11s). |
| Isolation (one unit per test) | PASS | Each of the 3 tests added this cycle asserts one seam property; `test_parallel_orchestrator_permission_contracts.py:59,86,113`. |
| Fast execution | PASS | Full suite 4.19s; the two contract suites 0.11s. |
| Determinism | PASS | Parsers are pure over committed file text. The module docstring records "no temporary file, no external process, no network"; confirmed by inspection and by grep (0 hits for `tempfile`, `tmp_path`). |
| Readability / maintainability | PASS | Google-style docstrings on every function; assertion messages print the parsed targets, the parsed invocations, and the declared grant set. |
| Test file location mirrors source | PASS | All 5 added modules under `tests/scripts/dev_tools/`; zero test files added under a production source tree. |
| No temporary files in tests | PASS | Grep over the added modules finds no `tempfile`, no `NamedTemporaryFile`, no `tmp_path`. |
| Coverage exclusion policy | PASS | No `exclude` entry added or modified by this branch; zero production paths excluded. `grep -c '^SF:tests' artifacts/python/lcov.info` returns 0, confirming test files sit outside the measured denominator as policy requires. |

### 1.1 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| --- | --- | --- | --- | --- | --- | --- |
| Python | 5 | 3007 | 3007 passed, 0 failed, 0 skipped | 91.82% line / 83.80% branch | 91.82% line / 83.80% branch | N/A - the 5 added modules are test and test-support code under `tests/`, outside the measured denominator per general-unit-test policy |
| TypeScript | 0 | 0 | N/A - zero `.ts`/`.tsx` files changed on this branch | N/A - zero `.ts`/`.tsx` files changed on this branch | N/A - zero `.ts`/`.tsx` files changed on this branch | N/A - zero `.ts`/`.tsx` files changed on this branch |
| PowerShell | 0 | 52 | 51 passed, 1 failed (pre-existing, non-attributable) | N/A - zero `.ps1`/`.psm1`/`.psd1` files changed on this branch | N/A - zero `.ps1`/`.psm1`/`.psd1` files changed on this branch | N/A - zero `.ps1`/`.psm1`/`.psd1` files changed on this branch |
| C# | 0 | 0 | N/A - zero `.cs` files changed on this branch | N/A - zero `.cs` files changed on this branch | N/A - zero `.cs` files changed on this branch | N/A - zero `.cs` files changed on this branch |
| JSON | 1 | 2 | 2 passed, 0 failed | N/A - line coverage is not defined for a data manifest | N/A - line coverage is not defined for a data manifest | N/A - line coverage is not defined for a data manifest |
| Markdown | 8 | 39 | 39 passed, 0 failed | N/A - line coverage is not defined for Markdown surface files | N/A - line coverage is not defined for Markdown surface files | N/A - line coverage is not defined for Markdown surface files |

### 1.2 Coverage Artifact Checklist

- Python baseline coverage artifact: `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-pytest-coverage.2026-08-08T16-47.md` records the pre-remediation baseline of 12432/13539 statements and 4190/5000 branch destinations.
- Python post-change coverage artifact: `artifacts/python/lcov.info` (382156 bytes), independently re-aggregated by this reviewer to 12432/13539 line and 4190/5000 branch.
- TypeScript baseline coverage artifact: N/A - zero `.ts`/`.tsx` files changed on this branch, so no TypeScript coverage artifact is required or produced by this feature.
- TypeScript post-change coverage artifact: N/A - zero `.ts`/`.tsx` files changed on this branch, so no TypeScript coverage artifact is required or produced by this feature.
- PowerShell baseline coverage artifact: N/A - zero `.ps1`/`.psm1`/`.psd1` files changed on this branch, so no PowerShell coverage artifact is required or produced by this feature.
- PowerShell post-change coverage artifact: N/A - zero `.ps1`/`.psm1`/`.psd1` files changed on this branch, so no PowerShell coverage artifact is required or produced by this feature.
- C# coverage artifact: N/A - zero `.cs` files changed on this branch.
- Per-language comparison summary: Python is the only language with changed files that carries a coverage obligation, and it clears both floors with zero movement; every other language has zero changed files of its own type, so no coverage obligation attaches.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.82% line and 83.80% branch. Post-change: 91.82% line and 83.80% branch. Change: 0.00 percentage points on both metrics; the branch adds zero production Python, so the measured denominator is unchanged at 13539 statements and 5000 branch destinations, and covered counts are identical at 12432 and 4190. Disposition: PASS (line 91.82% clears the 85% floor, branch 83.80% clears the 75% floor, and no changed production line exists to regress). Evidence: `artifacts/python/lcov.info` re-aggregated by this reviewer with `awk` over the `LF`/`LH`/`BRF`/`BRH` records, cross-checked against `evidence/baseline/baseline-pytest-coverage.2026-08-08T16-47.md`.
- TypeScript: Disposition: N/A - zero changed files of this type on the branch, so no coverage obligation attaches. Evidence: `git diff ee0626e8..aa987c12 --name-status -- '*.ts' '*.tsx'` returns zero paths. The one bundled resource this branch does change (`pack-manifests/core.json`) is gated instead by the pack-manifest completeness tests, re-run by this reviewer at 2 passed on the Python side.
- PowerShell: Disposition: N/A - zero changed files of this type on the branch, so no coverage obligation attaches. Evidence: `git diff ee0626e8..aa987c12 --name-status -- '*.ps1' '*.psm1' '*.psd1'` returns zero paths.
- C#: Disposition: N/A - zero changed files of this type on the branch, so no coverage obligation attaches. Evidence: `git diff ee0626e8..aa987c12 --name-status -- '*.cs'` returns zero paths.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | The CR-02 fix names one concrete invocation form rather than introducing an abstraction layer. The CR-01 fix removes a contradiction by reassigning an actor, adding no new mechanism. |
| Reusability | PASS | The new seam parsers reuse `read_repo_text`, `split_frontmatter`, `parse_frontmatter`, `collapse_whitespace`, and `string_sequence` from the existing surface test-support module rather than re-implementing them. |
| Extensibility | PASS | Grant-coverage predicates are separate pure functions (`write_grant_covers`, `bash_grant_covers`) parameterized by grant and target, so a new grant shape is a new predicate rather than an edit to the tests. |
| Separation of concerns | PASS | Parsers contain no assertion; the owning test performs every assertion. Verified by inspection of the support module's public surface. |
| Mandatory toolchain loop | PASS | Independently re-run in policy order: Black, Ruff, Pyright, Pytest — all clean in a single pass. See section 7. |
| File size limit (500 lines) | PASS | Largest added module is 496 lines. See section 8, Gap G3 for the headroom observation. |
| Error handling / fail fast | PASS | Malformed frontmatter propagates rather than degrading to an empty parse. Cardinality floors (`MINIMUM_PRESCRIBED_WRITE_TARGETS = 2`, `MINIMUM_PRESCRIBED_COMMAND_INVOCATIONS = 8`) convert a degenerate empty parse into a failure rather than a silent pass. |
| Naming | PASS | `snake_case` functions, `CONSTANT_CASE` module constants, descriptive names throughout. |
| No new dependencies | PASS | The added modules import only `re` and `typing` from the standard library plus in-repo test-support modules. |
| I/O boundaries | PASS | File reads are confined to the shared `read_repo_text` helper; parsing logic is pure over strings. |

## 3. Language-Specific Code Change Policy Compliance

**Python** (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Black formatting | PASS | `poetry run black --check .` -> "374 files would be left unchanged", exit 0. |
| Ruff lint | PASS | `poetry run ruff check .` -> "All checks passed!", exit 0. |
| Pyright type check | PASS | `poetry run pyright` -> "0 errors, 0 warnings, 0 informations". |
| Full type annotation | PASS | Every added function carries parameter and return annotations; `from __future__ import annotations` in both modules added this cycle. |
| No unauthorized suppressions | PASS | `grep -c -e noqa -e 'type: ignore'` returns 0 for both modules added this cycle. The Ruff TC003 finding raised during Phase 6 was fixed at root by moving the annotation-only `pathlib` import into a `TYPE_CHECKING` block rather than by adding the pre-authorized TCH003 suppression. This is the stronger of the two permitted responses under `.claude/rules/python-suppressions.md`. |
| Absolute imports | PASS | All imports are absolute (`from tests.scripts.dev_tools...`). |
| Docstring / commenting policy | PASS | Module, function, loop-intent, and branch-decision comments present per `.claude/rules/self-explanatory-code-commenting.md`; no numbered `NOTE n:` tags. |

**JSON** — one modified manifest, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Three entries added for the three new surface files. Governance analysis in section 8, Gap G1.

**Markdown** — 8 changed surface and doc files. Tone policy observed; no hyperbole, humor, or decorative metaphor detected in the three delivered runtime files.

**TypeScript / PowerShell / C#** — no changed files of these types; no language-specific code-change obligation attaches.

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Pytest as runner | PASS | Both modules added this cycle are plain pytest function tests. |
| One behavior per test | PASS | Three tests, three distinct seam properties. |
| Arrange-Act-Assert | PASS | Explicit `# Arrange` / `# Act` / `# Assert` comment blocks in all three tests. |
| Descriptive `test_` names | PASS | `test_every_prescribed_parent_write_target_has_a_persona_write_grant`, `test_every_prescribed_command_invocation_has_a_persona_bash_grant`, `test_manifest_validation_gate_prescribes_a_granted_command_invocation`. |
| Behavioral over implementation-detail assertions | PASS | Both sides of the seam are parsed at run time; no grant literal and no prescribed-target literal is restated as a test constant. The gate section is located by the library symbol it names (`MANIFEST_VALIDATION_SYMBOL`), not by a heading constant copied from the producer. |
| No sleeps / retries / timing hacks | PASS | None present. |
| No external dependencies | PASS | No network, database, subprocess, or runtime temp file. |
| Mirrored test layout | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |
| Tests not weakened | PASS | Test count 3004 -> 3007 (+3, zero removals); 0 skipped, 0 xfail. Independently measured. |

## 5. Test Coverage Detail

Python is the only language with a coverage obligation on this branch.

- Repo-wide line coverage: **91.82%** (12432 of 13539 statements) against an 85% floor.
- Repo-wide branch coverage: **83.80%** (4190 of 5000 branch destinations) against a 75% floor.
- New production Python files: **none**. All 5 added `.py` files are test or test-support modules under `tests/`, which policy places outside the measured denominator. The per-new-file threshold therefore has no subject on this branch.
- Modified production Python files: **none**. The no-regression-on-changed-lines requirement has no subject on this branch.
- Regression check: baseline and post-change counts are identical (12432/13539 line, 4190/5000 branch). Because the branch adds zero production Python, the denominator is structurally unchanged, so identical covered counts establish zero regression rather than merely suggesting it.

Reviewer verification method: per the required evidence-verification model, coverage generation was **not** re-run. This reviewer re-aggregated the `LF`/`LH` and `BRF`/`BRH` records of `artifacts/python/lcov.info` directly and reproduced 12432/13539 and 4190/5000 exactly.

## 6. Test Execution Metrics

| Suite | Command | Result |
| --- | --- | --- |
| Python, full | `poetry run pytest -q` | 3007 passed, 0 failed, 0 skipped, 4.19s |
| Python, the two parallel-orchestrator contract suites | `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -q` | 39 passed, 0.11s |
| Python, pack-manifest completeness | `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q` | 2 passed |
| PowerShell, the two suites named in the environment note | `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1, tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 -PassThru -Output None` | TOTAL=52, PASSED=51, FAILED=1 (the single failure pre-existing and non-attributable; see Gap G2) |

Test-count reconciliation: 3004 (remediation-cycle baseline) + 3 (added in remediation Phase 1) = 3007 expected; 3007 measured.

## 7. Code Quality Checks

| Check | Command | Result |
| --- | --- | --- |
| Formatting | `poetry run black --check .` | PASS - 374 files unchanged, exit 0 |
| Linting | `poetry run ruff check .` | PASS - "All checks passed!", exit 0 |
| Type checking | `poetry run pyright` | PASS - 0 errors, 0 warnings, 0 informations |
| Unit tests | `poetry run pytest -q` | PASS - 3007 passed, 0 failed, 0 skipped |
| Evidence locations | `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` | PASS - exit 0 |
| Frozen epic surface | `git diff --stat ee0626e8 -- .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/orchestrate/SKILL.md` | PASS - empty diff |
| Hooks and settings untouched | `git diff --stat ee0626e8 -- .claude/hooks .claude/settings.json` | PASS - empty diff |
| Bundled mirror parity | `sha256sum` over the 3 source/mirror pairs | PASS - all 3 pairs byte-identical |

**Toolchain loop integrity.** The executor reported that the Phase 6 final clean pass required two iterations, the first failing on a single Ruff TC003 finding in a new test-support module. This is the policy-conformant outcome, not a deviation: `.claude/rules/general-code-change.md` requires restarting from stage 1 whenever a stage fails, and the loop terminated only after all stages passed in a single pass. The fix was made at root — the annotation-only `pathlib` import was moved into a `TYPE_CHECKING` block — rather than by adding the pre-authorized `# noqa: TCH003` suppression. Independently confirmed: the module carries `from __future__ import annotations` plus a `TYPE_CHECKING`-guarded import, and both modules added this cycle contain zero suppressions of either kind.

**Policy rule `modified-workflow-needs-green-run`: does not fire.** `git diff ee0626e8..aa987c12 --name-only -- .github scripts/benchmarks` returns zero paths, so the branch modifies nothing under `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**`. No green-run evidence is required and no Blocking finding is emitted under this rule.

**Mirror parity, verified by hash.** The three delivered runtime files and their bundled mirrors are byte-identical:

```
b3b43f52...273d  .claude/agents/parallel-orchestrator.md   (and its mirror)
eb4892d5...4323  .claude/skills/parallel-orchestrate/SKILL.md   (and its mirror)
9fc7fe3a...6a90  .claude/skills/parallel-run/SKILL.md   (and its mirror)
```

## 8. Gaps and Exceptions

### Gap G1 - Plan tasks P4-T7 and P4-T8 name verification tools that cannot pass on their target path (Minor; not a branch regression)

**Finding.** The two plan tasks invoke `scripts/dev_tools/format_json --check` and `scripts/dev_tools/validate_json` against `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Both fail on that path, and both fail **identically at the merge base**:

| Invocation | HEAD `aa987c12` | Merge base `ee0626e8` |
| --- | --- | --- |
| `format_json --check <core.json>` | exit 1, "would reformat" | exit 1, "would reformat" |
| `validate_json <core.json>` | exit 1, "missing $schema" | exit 1, "missing $schema" |

The merge-base result was obtained by extracting the base blob with `git show ee0626e8:<path>` into the scratchpad and checking that copy directly. Because the outcome is identical on both sides, the failure cannot be attributed to this branch's edit.

**Attribution.** This is a plan-authoring defect, not a code defect. `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py:12-16` covers `scripts/**/*.json`, `docs/**/*.json`, and `examples/**/*.json` only, so `extensions/**` is ungoverned; passing the path explicitly bypasses that filter and subjects the file to a standard it was never held to. `validate_json` requires a `$schema` member that pack manifests do not carry, and `format_json` re-serializes with sorted keys, which would reorder `core.json`'s authored top-level key order. Neither condition touches the `paths` array, which is the only thing this branch modifies. Leaving P4-T7 and P4-T8 unchecked was the correct decision, and the executor's factual account is accurate in every particular this reviewer re-verified.

**The change is not ungated.** The real gate on `core.json` exists and passes: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q` returns 2 passed, asserting that every surface file the pack ships is present in the manifest.

**Recommendation.** Correct the two plan tasks to name the gates that actually govern this path, or record an explicit exception in the plan. Do **not** modify `core.json` to satisfy `format_json`: reordering its top-level keys would diverge the bundled resource from its authored form for no governed reason.

**Separate pre-existing defect worth its own entry.** The governed default `poetry run python -m scripts.dev_tools.format_json --check` reports "would reformat" on files this branch does not touch, including `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json` and seven files under `docs/discovery/templates/artifacts/`. That is a repo-wide condition, not this feature's, and should be tracked as a potential-bug entry.

### Gap G2 - Pre-existing Pester test-isolation defect (Minor; provably non-attributable)

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` fails one test, `allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. The suite invokes the hook without overriding its checkpoint path, so the hook resolves the real gitignored `artifacts/orchestration/orchestrator-state.json` and denies while an orchestrated run is in progress.

Non-attribution is established structurally rather than by accepting the environment note: the branch changes zero PowerShell files, and `git diff --stat ee0626e8 -- .claude/hooks/enforce-pr-author-skill.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is empty, so both the hook and its test are byte-identical to the merge base. A branch that changes neither the code under test nor the test cannot have caused the failure.

**Recommendation.** Track as a separate potential-bug entry: the suite should inject a test-supplied checkpoint path rather than reading the live checkpoint. Do not remediate under this feature.

### Gap G3 - Added test-support module sits 4 lines under the hard file-size limit (Nit)

`tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py` is 496 lines against the 500-line hard limit in `.claude/rules/general-code-change.md`. Compliant, but any subsequent addition forces a module split. Recommendation: record the constraint, or pre-emptively extract the sentence-scanning helpers into a sibling module.

### Gap G4 - Interpreter grant is broader than the write scoping it sits beside (Minor; accepted with rationale)

The CR-02 fix grants `Bash(poetry run python -c *)`. Because `python -c` accepts arbitrary source, that grant can in principle write any path, so it is not constrained by the persona's `Write(docs/features/parallel/**)` and `Write(artifacts/orchestration/**)` scoping — nor by the new contract test that enforces agreement with those grants. The permission model the test verifies is therefore narrower than the permission the persona actually holds.

Four considerations make this acceptable rather than blocking. First, the persona already holds `Bash(git *)`, which permits arbitrary working-tree mutation, so the scoped `Write` grants were never a hard containment boundary; the interpreter grant widens an already-soft boundary rather than breaching a hard one. Second, the grant is strictly **narrower** than the established sibling precedent: `.claude/agents/parallel-planner.md` holds a blanket `Bash(poetry run *)`, whereas this persona holds only the two `python -c` and `python -m` invocation prefixes. Verified negatively by reviewer probe: `poetry run pytest -q`, `poetry run black .`, `npm run build`, and `rm -rf /` are all uncovered by the granted set, while `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts x y` is covered. Third, `scripts/dev_tools/parallel_manifest_contract.py` genuinely exposes no CLI entry point, and `.claude/rules/parallel-orchestration.md` fixes manifest validation as a library call that is "deliberately not a third MCP `artifact_type`", so an interpreter invocation is the only mechanism available without modifying an upstream module this feature must not touch. Fourth, the skill documents the rationale explicitly at the point of use.

**Recommendation.** Non-blocking. When a later feature exposes the manifest check through a CLI or MCP surface, narrow this grant; consider recording that intent in the persona body so the widening is understood as transitional.

### Gap G5 - Housekeeping: duplicate uncommitted review artifact and a dirtied tracked test-output file (Nit)

Two working-tree conditions that are not policy violations but should be resolved before PR authoring:

1. `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/policy-audit.2026-08-08T20-04.md` is present and untracked. It is the output of an earlier re-audit attempt that was terminated by a transient API error before it could be reported. Its content is consistent with this audit, but two policy audits for one review cycle is ambiguous provenance. Recommendation: delete the `20-04` file, or commit it with an explicit note that `20-25` supersedes it.
2. `testResults.xml` is a tracked file showing as modified in the working tree. It is a Pester output file that any local test run rewrites; the branch's commits do not change it. This reviewer avoided compounding the condition by running Pester with `-Output None` and no `-CI`, which does not write the file. Recommendation: track as a separate potential-bug entry to gitignore the file, since a tracked test-output artifact produces spurious working-tree diffs for every contributor.

### Resolved in this cycle

| Item | Prior severity | Status | Verification |
| --- | --- | --- | --- |
| CR-01 - parent-side `remediation-inputs` write not covered by a `Write` grant | Major | RESOLVED | The capture and the finding write are reassigned to the child's `atomic-executor`, which works inside the item's own worktree (`parallel-orchestrate/SKILL.md:281-292`), matching the frozen epic precedent that the text now cites explicitly. Reviewer probe confirms `prescribed_parent_write_targets()` now returns only `docs/features/parallel/<slug>/parallel-status.md` and `artifacts/orchestration/parallel-orchestrator-state.json`, both covered; `docs/features/active/` is no longer a parent write target. |
| CR-02 - manifest-validation gate had no permitted mechanism | Major | RESOLVED | `Bash(poetry run python -c *)` granted (`parallel-orchestrator.md` frontmatter), and the gate section names the exact granted invocation (`parallel-orchestrate/SKILL.md:75-81`). The gate text is unweakened: "rejected before any kickoff", "Do not guess a repair", "do not silently skip the offending item", and "do not launch a partial cohort" are all retained, and the non-zero exit is defined as the rejection signal. |
| Recommended structural test closing the gap class | Recommendation | DELIVERED | `test_parallel_orchestrator_permission_contracts.py` (3 tests) plus `parallel_orchestrator_permission_seam_support.py`. Confirmed non-vacuous by reviewer probe, below. |

**Non-vacuity probe (reviewer-run).** The risk with a parser-driven contract test is that a weak parser makes the universally-quantified assertion vacuous. This reviewer imported the parsers directly and measured:

- `persona_write_grants()` returns `('docs/features/parallel/**', 'artifacts/orchestration/**')`.
- `persona_bash_grants()` returns `('git *', 'gh *', 'poetry run python -c *', 'poetry run python -m *')`.
- `prescribed_parent_write_targets()` returns 2 targets, 0 uncovered.
- `prescribed_command_invocations()` returns 14 invocations, 0 uncovered, including the full `python -c` manifest-validation form and `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>`.
- The grant-coverage predicate discriminates: `poetry run pytest -q`, `poetry run black .`, `npm run build`, and `rm -rf /` are all reported uncovered.

The parsed sets are non-empty, exceed both cardinality floors, and the predicate rejects out-of-grant commands, so the assertions are substantive rather than tautological.

## 9. Summary of Changes

74 files changed, 8596 insertions, 97 deletions versus `ee0626e838109fe8d3fe3904fb4631c71879baa3`, across commits `41633ad5` (feature) and `aa987c12` (remediation).

**Delivered runtime surface (3 new Markdown files, plus 3 byte-identical bundled mirrors)**
- `.claude/agents/parallel-orchestrator.md` - new agent persona; 9 required body headings present in order, `tools` allowlist excludes `Agent(pr-author)`, `SubagentStop` hook wired to `validate-orchestrator-output.ps1` with the parallel checkpoint path and artifact type.
- `.claude/skills/parallel-orchestrate/SKILL.md` - new procedure skill; exactly 16 top-level headings, the first 13 authored in spec R2.1 order and the final 3 reserved wave-4 placeholders in the required order.
- `.claude/skills/parallel-run/SKILL.md` - new entry-point skill; `context: fork`, `agent: parallel-orchestrator`, argument hint, and an explicit STOP path naming `/parallel-plan`.

**Templates and manifests**
- `docs/features/templates/parallel/parallel-status.md` - new generated-projection template opening with the HTML-comment generated-file banner.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` - 3 entries added for the new surface files.

**Tests (5 new modules, 1866 lines total, all under the 500-line limit)**
- `test_parallel_orchestrator_surface_contracts.py` (457), `parallel_orchestrator_surface_test_support.py` (465), `parallel_orchestrator_surface_expectations.py` (296) - structural contract tests over the delivered surface.
- `test_parallel_orchestrator_permission_contracts.py` (152), `parallel_orchestrator_permission_seam_support.py` (496) - added this cycle for the permission seam.

**Scoping documents** - `spec.md` R2.9 actor corrected with a dated correction note; `user-story.md` and `plan.2026-08-07T11-11.md` updated for AC check-off and plan progress.

**Prior-cycle review artifacts and the feature's evidence artifacts**, all in canonical `evidence/<kind>/` locations.

**Deliberately unchanged, verified by empty diff:** `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, everything under `.claude/hooks/`, and `.claude/settings.json`.

## 10. Compliance Verdict

**COMPLIANT.**

- Blocking findings: **0**.
- Major findings: **0** (both cycle-1 Major items resolved and independently verified).
- Minor findings: **3** (G1 plan-task mis-specification, G2 pre-existing non-attributable Pester failure, G4 interpreter-grant breadth).
- Nit findings: **2** (G3 file-size headroom, G5 housekeeping).
- Acceptance criteria: **33 of 33 PASS** (22 from `spec.md`, 11 from `user-story.md`).
- Coverage: Python PASS (91.82% line / 83.80% branch, zero regression); TypeScript, PowerShell, and C# each have zero changed files of their own type.

Remediation is **not** required. No condition in the workflow's remediation-trigger list is met: the policy audit contains no meaningful FAIL or PARTIAL, all toolchain checks pass, the code review contains no blocker, no acceptance criterion is FAIL or PARTIAL, coverage is above both floors with zero regression, and the coverage artifact is present for the one language with changed files. No `remediation-inputs` artifact is produced for this cycle.

**PR readiness: GO.** The two Minor items that are not this feature's responsibility (G1's repo-wide governed-scope JSON condition, G2's Pester test-isolation defect) and G5's two housekeeping items should be filed as separate potential-bug entries rather than gating this branch. G5 item 1 (the duplicate untracked policy audit) should be resolved before PR authoring so the cycle has one unambiguous verdict artifact.

## Appendix A: Test Inventory

**Added this cycle (3 tests, `test_parallel_orchestrator_permission_contracts.py`)**

| Test | Property asserted |
| --- | --- |
| `test_every_prescribed_parent_write_target_has_a_persona_write_grant` | Every write target the procedure prescribes for the parent is covered by a declared `Write` grant; floor of 2 parsed targets. |
| `test_every_prescribed_command_invocation_has_a_persona_bash_grant` | Every command invocation the procedure prescribes is covered by a declared `Bash` grant; floor of 8 parsed invocations. |
| `test_manifest_validation_gate_prescribes_a_granted_command_invocation` | The section naming `validate_parallel_manifest_text` prescribes at least one invocation the persona is granted, so the gate is enforceable rather than merely documented. Asserts exactly one section names the symbol. |

**Pre-existing on this branch (36 tests, `test_parallel_orchestrator_surface_contracts.py`)** — deliverable existence and frontmatter; the exact 16-heading count and the ordered heading tuple; the three reserved wave-4 headings with their one-line bodies; the literal `Parallel mode: true` and `PR base branch MUST be main` markers; negative literal assertions for `Epic mode: true`, `--base epic/`, and `integration-to-main`; and SHA-256 content-hash pinning of the frozen epic surface files.

**Supporting suite re-run by this reviewer** — `test_push_down_codex_and_agents_pack_manifest_completeness.py` (2 passed).

## Appendix B: Toolchain Commands Reference

All commands were run by this reviewer from the worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`.

```bash
# Scope resolution
git rev-parse HEAD                                              # aa987c1202da3c88807f6bfefc6ba4279468b06c
git merge-base HEAD epic/parallel-orchestration-integration      # ee0626e838109fe8d3fe3904fb4631c71879baa3
git log --oneline ee0626e838109fe8d3fe3904fb4631c71879baa3..aa987c1202da3c88807f6bfefc6ba4279468b06c
git diff ee0626e838109fe8d3fe3904fb4631c71879baa3..aa987c1202da3c88807f6bfefc6ba4279468b06c --shortstat

# Per-language changed-file census
git diff ee0626e8..aa987c12 --name-status -- "*.py" "*.json" "*.ts" "*.tsx" "*.ps1" "*.psm1" "*.psd1" "*.cs" "*.yml" "*.yaml"
git diff ee0626e8..aa987c12 --name-only -- .github scripts/benchmarks artifacts

# Python toolchain, in policy order
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest -q
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py \
                  tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -q
poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q

# Coverage verification from the existing artifact (generation deliberately not re-run)
awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{brf+=$2} /^BRH:/{brh+=$2} \
  END{printf "LINE %d/%d BRANCH %d/%d\n", lh, lf, brh, brf}' artifacts/python/lcov.info
grep -c '^SF:tests' artifacts/python/lcov.info                  # 0 - test files outside the denominator

# Permission-seam non-vacuity probe
PYTHONPATH=<worktree root> poetry run python <scratchpad>/probe_seam.py

# JSON governance (Gap G1)
sed -n '1,20p' scripts/dev_tools/json_config.py
poetry run python -m scripts.dev_tools.format_json --check extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
poetry run python -m scripts.dev_tools.validate_json extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
git show ee0626e8:extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json > <scratchpad>/core-base.json
poetry run python -m scripts.dev_tools.format_json --check <scratchpad>/core-base.json
poetry run python -m scripts.dev_tools.validate_json <scratchpad>/core-base.json
poetry run python -m scripts.dev_tools.format_json --check

# Immutability and parity
git diff --stat ee0626e8 -- .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md \
                            .claude/skills/orchestrate/SKILL.md .claude/hooks .claude/settings.json
git diff --stat ee0626e8 -- .claude/hooks/enforce-pr-author-skill.ps1 \
                            tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
sha256sum .claude/agents/parallel-orchestrator.md .claude/skills/parallel-orchestrate/SKILL.md \
          .claude/skills/parallel-run/SKILL.md \
          extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md \
          extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md \
          extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-run/SKILL.md

# Evidence locations
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .

# Acceptance-criteria structural checks
grep -n '^## ' .claude/skills/parallel-orchestrate/SKILL.md      # 16 headings
grep -n '^## ' .claude/agents/parallel-orchestrator.md           # 9 headings
grep -n -e 'Epic mode: true' -e 'integration-to-main' -e '--base epic/' \
  .claude/agents/parallel-orchestrator.md .claude/skills/parallel-orchestrate/SKILL.md \
  .claude/skills/parallel-run/SKILL.md                           # no matches, exit 1
grep -n -e 'EPIC_MERGE_GATE_BLOCKED' -e 'EPIC_WORKTREE_REMOVAL_BLOCKED' \
  -e 'ascending item-key order' -e 'PR base branch MUST be main' -e 'Parallel mode: true' \
  .claude/skills/parallel-orchestrate/SKILL.md
grep -c '^- \[x\]' docs/.../spec.md   # 22 ;  grep -c '^- \[ \]' -> 0
grep -c '^- \[x\]' docs/.../user-story.md   # 11 ;  grep -c '^- \[ \]' -> 0

# PowerShell environment-note verification (run without -CI so testResults.xml is not rewritten)
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1, \
  tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 -PassThru -Output None"

# Review-artifact validation
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <this file>
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review <code review>
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit <feature audit>
```

**Documented assumption.** This agent's tool allowlist contains no `mcp__drm-copilot__*` entries, so the workflow's MCP-mediated template resolution and MCP artifact validation were performed through their CLI and filesystem equivalents: the required artifact shapes were taken from the canonical bundled template assets and from the enforced validator contract in `scripts/dev_tools/validate_orchestration_review_artifacts.py` and `scripts/dev_tools/validate_policy_audit_artifact.py`, and validation used `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts`. The orchestrator should re-run the MCP validators against these three artifacts if that surface is available to it.

**Template fidelity note.** The bundled `feature-audit` template writes the heading `## Acceptance Criteria Check-Off`, while `scripts/dev_tools/validate_orchestration_review_artifacts.py:46` requires `## Acceptance Criteria Check-off`. The validator spelling was used, since it is the enforced contract.
