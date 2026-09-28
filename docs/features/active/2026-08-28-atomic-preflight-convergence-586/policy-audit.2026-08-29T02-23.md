# Policy Audit — atomic-preflight-convergence (Issue #586)

- Component: `.claude/skills/atomic-plan-contract` and `.claude/skills/remediation-handoff-atomic-planner` (plus bundled claude-customizations mirrors)
- Date: 2026-08-29
- Reviewer: feature-review
- Feature folder: `docs/features/active/2026-08-28-atomic-preflight-convergence-586`
- Branch: `feature/atomic-preflight-convergence-586`
- Base branch: `origin/main`
- Merge-base SHA: `1ff27b874154405f22001ad8e1e34062bbec625f`
- Branch head SHA: `0ad354c12b351ea2972dcd2a11718a60989dbf3b`
- Work mode: `minor-audit` (marker read from `issue.md` line 10)
- Diff shape: 24 files changed, 1450 insertions, 0 deletions

## Executive Summary

The branch is a documentation-only change to two Claude skill-contract Markdown files and their two byte-identical bundled mirrors. It adds four content blocks: a mandatory planner adversarial self-review section, a preflight review-depth and reporting block with a `CONVERGENCE:` signal pair, a cycle-document sweep-scope subsection, and an orchestrator iteration ceiling introducing a fourth `final_status` value.

All mechanical gates verified independently by this review pass: the change is strictly additive (0 deletions across all four production files), both bundled mirrors are byte-identical to their canonical targets, the payload-parity test passes at 10/10, the evidence-location validator exits 0, and all added prose complies with `.claude/rules/tonality.md`.

No coverage-bearing language has a changed file in the branch diff. All 24 changed paths are `.md`. Coverage verdicts are therefore recorded as N/A on the basis of zero changed files, not on the basis of a caller-supplied narrowing.

One category of finding is open: the branch introduces three statements into the skill contracts that are unreconciled with the agent definitions under `.claude/agents/`. All three were verified to be documentation-level only — no validator, hook, or test rejects the new values. The sharpest of the three (`.claude/agents/atomic-executor.md` restricting preflight to "format and structure validation" only) materially weakens the runtime effect of the feature's primary mechanism. It is recorded as a High-severity non-blocking finding requiring a follow-up issue, consistent with the deferral the issue author declared in `issue.md` "Constraints & Risks".

Overall verdict: **PASS with a required follow-up**. See section 10.

## Rejected Scope Narrowing

None detected. The caller prompt explicitly assigned scope determination to this agent ("Scope determination is your responsibility. Determine it from the branch diff against the merge-base") and supplied no instruction narrowing the audit to a plan, task, phase, or file subset, and no instruction marking any language out of scope. The audit was performed as a full feature-vs-base diff against `1ff27b874154405f22001ad8e1e34062bbec625f`.

## Evidence Location Compliance

PASS.

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- All 17 evidence artifacts on this branch are written under `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/baseline/` (6) and `.../evidence/qa-gates/` (11). Both are canonical `<FEATURE>/evidence/<kind>/` folders per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- The branch diff was scanned for writes under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/`. Zero occurrences. No FAIL-level evidence-location finding.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.
- Note: `evidence/baseline/phase0-instructions-read.md` carries no filename timestamp. This matches 113 prior instances of the same filename across the repository's feature tree and is established convention, not a deviation.

## 1. General Unit Test Policy Compliance

**Verdict: N/A (no code or test files changed).**

`.claude/rules/general-unit-test.md` governs unit test code. The branch adds and modifies only Markdown. No test file was added, modified, or deleted; no production source file in any coverage-bearing language was added, modified, or deleted.

- Coverage Exclusion Policy: PASS by inspection. No `exclude` entry was added or modified in any coverage configuration on this branch. No production source path was newly excluded from measurement.
- Test file location rule: N/A. No test file created or moved.
- Determinism infrastructure: N/A. No test code changed.

### 1.1 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| -------- | ------------- | ----- | ----------- | ----------------- | -------------------- | ----------------- |
| TypeScript | 0 | 0 | N/A | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |
| Python | 0 | 10 passed (parity gate only) | PASS | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |
| PowerShell | 0 | 0 | N/A | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |
| C# | 0 | 0 | N/A | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |
| Markdown | 24 | 0 | N/A | N/A — not a coverage language | N/A — not a coverage language | N/A — not a coverage language |

The Python row records 10 passing tests because this review ran the bundled-payload parity gate, which is implemented in pytest. That run exercises pre-existing test code against changed Markdown payload; it adds no Python line to the coverage denominator and removes none.

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A — the branch diff contains zero TypeScript files, so no TypeScript line enters or leaves measurement.
- TypeScript post-change coverage artifact: N/A — the branch diff contains zero TypeScript files, so no TypeScript line enters or leaves measurement.
- PowerShell baseline coverage artifact: N/A — the branch diff contains zero PowerShell files, so no PowerShell line enters or leaves measurement.
- PowerShell post-change coverage artifact: N/A — the branch diff contains zero PowerShell files, so no PowerShell line enters or leaves measurement.
- Per-language comparison summary: N/A — no coverage-bearing language has a changed file on this branch, so no baseline-to-post-change comparison exists to record.

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: N/A — zero changed files in the branch diff against `1ff27b87`.
- Python: N/A — zero changed files in the branch diff against `1ff27b87`.
- PowerShell: N/A — zero changed files in the branch diff against `1ff27b87`.
- C#: N/A — zero changed files in the branch diff against `1ff27b87`.

Every coverage-bearing language has zero changed files on this branch, so per the coverage-verdict rule an explicit `PASS`/`FAIL` verdict does not apply and `N/A` is the correct disposition. This is a property of the diff, verified by `git diff --name-status`, not an accepted caller assertion.

## 2. General Code Change Policy Compliance

**Verdict: PASS.**

| Rule | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | Four additive prose blocks. No new mechanism, format, or indirection introduced. |
| Reusability | PASS | The remediation-handoff file references the atomic-plan-contract preflight section rather than restating its rules (line 109), avoiding duplicated contract text. |
| Extensibility | PASS | New signals (`SELF-REVIEW:`, `CONVERGENCE:`) follow the existing directive-line convention already used by `DIRECTIVE:` and `PREFLIGHT:`, satisfying the issue's stated constraint. |
| Separation of concerns | PASS | Planner-side rules live in the planner section; executor-side review-depth rules live in the preflight section; orchestrator state-recording rules live in the remediation-handoff sub-loop. |
| File size limit (500 lines) | PASS | `.claude/skills/atomic-plan-contract/SKILL.md` is 240 lines; `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` is 128 lines. Markdown documentation is additionally exempt under the policy. |
| No policy-document modification | PASS | No file under `.claude/rules/` or `.github/instructions/` is touched by the branch diff. |
| Public API compatibility | PASS | Strictly additive: `git diff --numstat` records 0 deleted lines in all four production files. No existing rule is weakened or reworded. |
| Dependencies | PASS | No dependency added. |
| I/O boundaries | N/A | No executable code changed. |

### 2.1 Additive-Only Constraint

The issue states "Additive only: no existing rule in any of the four files may be weakened while these sections are added." Verified directly:

```
28	0	.claude/skills/atomic-plan-contract/SKILL.md
10	0	.claude/skills/remediation-handoff-atomic-planner/SKILL.md
28	0	extensions/.../claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
10	0	extensions/.../claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md
```

Zero deletions in every one of the four files. The constraint holds mechanically, not only by reading.

### 2.2 Bundled Mirror Parity

PASS. Both mirrors are byte-identical to their canonical targets at branch head, confirmed by two independent methods:

- Blob hash comparison: `atomic-plan-contract/SKILL.md` is `243fc8629eb4d168d385e583c805dc2c104437eb` in both locations; `remediation-handoff-atomic-planner/SKILL.md` is `1e944becfd8a31128fb1b7546b3c055e76a4d5a2` in both locations.
- Payload contract test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passed 10/10, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts byte equality for every `.claude/**` file.

The hashes recorded in the executor's evidence artifact `evidence/qa-gates/bundle-parity-test-final.2026-08-28T20-02.md` match the values this review recomputed at head. The evidence is current, not stale.

### 2.3 Tonality Compliance

PASS. All 38 added lines across the two canonical files were read against `.claude/rules/tonality.md`.

- Humor / banter / sarcasm: zero occurrences.
- Hyperbole and inflated claims: zero occurrences. The strongest claims are bounded and mechanism-bearing ("Stopping at the first defect is prohibited", "a target of at most two preflight rounds per plan").
- Metaphor: the coined terms "sibling invalidation" and "round inflation" are utilitarian labels for named failure mechanisms, each immediately defined in the same sentence. This satisfies the restricted-metaphor test rather than violating it.
- Evidence-first wording: each new rule states its failure mechanism rather than asserting importance. Example at line 169: the enumerate-every-defect rule states why a single-defect report inflates the round count.

This matters more than usual on this branch, because the change itself adds a rule requiring delta prose to comply with the policy it enforces. The added prose meets its own new standard.

## 3. Language-Specific Code Change Policy Compliance

**Verdict: N/A.**

No Python, TypeScript, PowerShell, or C# file appears in the branch diff. `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/rules/powershell.md`, and `.claude/rules/csharp.md` have no in-scope file to govern on this branch. Verified by `git diff --name-status 1ff27b87..HEAD`, which lists 24 paths, all with a `.md` extension.

## 4. Language-Specific Unit Test Policy Compliance

**Verdict: N/A.**

No test file in any language was added, modified, or deleted. The pytest module executed during this review is pre-existing and unmodified on this branch.

## 5. Test Coverage Detail

**Verdict: N/A — no coverage-bearing file changed.**

Coverage artifact inspection was performed per the mandatory verification procedure:

| Language | Coverage artifact path | Changed files on branch | Disposition |
| --- | --- | --- | --- |
| TypeScript | `coverage/lcov.info` | 0 | N/A — artifact not required; language has zero changed files |
| Python | `artifacts/python/lcov.info` | 0 | N/A — artifact not required; language has zero changed files |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | 0 | N/A — artifact not required; language has zero changed files |
| C# | `artifacts/csharp/coverage.xml` | 0 | N/A — artifact not required; language has zero changed files |

The rule "coverage artifact absent for a language that has changed files is a FAIL" is not triggered for any language, because no language has changed files. No remediation trigger arises from coverage.

## 6. Test Execution Metrics

| Suite | Command | Result | Notes |
| --- | --- | --- | --- |
| Bundled payload contracts | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q` | 10 passed in 0.11s | Re-run independently by this review; matches the executor's recorded result and the pre-change baseline count. |
| Evidence location validator | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | No violations. |

No test was skipped and none was recorded as `SKIPPED`. No `[expect-fail]` task exists in this plan.

## 7. Code Quality Checks

| Stage | Applicability | Verdict | Evidence |
| --- | --- | --- | --- |
| 1. Formatting | N/A | N/A | No formatter governs `.claude/**/*.md` in this repository's toolchain. |
| 2. Linting | N/A | N/A | No Markdown linter is wired into the repository toolchain for this path. |
| 3. Type checking | N/A | N/A | No typed source file changed. |
| 4. Architecture-boundary tests | N/A | N/A | No module boundary changed. |
| 5. Unit tests | PASS | PASS | Payload-parity suite 10/10 (section 6). |
| 6. Contract / schema compatibility | PASS | PASS | `scripts/dev_tools/validate_orchestrator_state.py` compares `preflight.final_status` only against the cleared constant; it does not enumerate the permitted value set, so the newly documented fourth value `blocked_preflight_iteration_limit` does not fail the validator. |
| 7. Integration tests | N/A | N/A | No integration surface changed. |

### 7.1 Runtime Enforcement Compatibility of the New Signals

This review verified that the newly required signal lines do not break the existing enforcement layer:

- `.claude/hooks/validate-executor-output.ps1` line 151 matches `^\s*PREFLIGHT:\s*(ALL CLEAR|REVISIONS REQUIRED)\s*$` and its failure message reads "preflight output must include". The check is presence-based, not exclusivity-based, so an output carrying a `CONVERGENCE:` line alongside the `PREFLIGHT:` signal still passes.
- `.claude/hooks/validate-planner-output.ps1` line 109 applies the same presence-based match, so a `SELF-REVIEW:` declaration line alongside the existing signals still passes.

No hook, validator, or test rejects the new lines. The change is runtime-safe.

### 7.2 modified-workflow-needs-green-run

Rule does not fire. The branch diff contains no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. No Blocking finding under this rule and no green-run evidence is required.

## 8. Gaps and Exceptions

### 8.1 Cross-file contract statements unreconciled with `.claude/agents/` (3 items)

The branch adds requirements to the skill contracts that three statements in the agent definitions contradict or under-specify. All three were checked against the enforcement layer and none causes a runtime failure. Each is documentation-level.

| # | Location of the conflicting statement | Nature | Severity | Runtime impact verified |
| --- | --- | --- | --- | --- |
| 1 | `.claude/agents/atomic-executor.md:87` — "perform only format and structure validation" | Contradiction. The revised contract at `atomic-plan-contract/SKILL.md:170` requires the executor to check delta prose against every rule the plan enforces, including `.claude/rules/tonality.md`. That is semantic content review, which the word "only" excludes. | High | No hook or validator failure. The risk is behavioral: an executor honoring the agent file's "only" would skip the delta self-check. |
| 2 | `.claude/agents/atomic-executor.md:87` — "Return exactly one of:" preceding the two `PREFLIGHT:` bullets | Ambiguity, not contradiction. The contract at `SKILL.md:178` states the convergence line is "a second required line accompanying the preflight signal, not a third value of the signal set". That reconciliation applies with equal force to the agent file's identically-scoped two-value bullet list. | Low | Verified none. The SubagentStop hook is presence-based (section 7.1). |
| 3 | `.claude/agents/orchestrator.md:104` and `:144` — `final_status` "is one of {clear, changes_requested, pending}" | Under-specification. `remediation-handoff-atomic-planner/SKILL.md:113` adds a fourth value `blocked_preflight_iteration_limit` and names the enumeration it extends, reconciling it within its own file but not in the agent definition that instructs the writing agent. | Medium | Verified none. `validate_orchestrator_state.py` tests only `final_status != 'clear'`; the enumeration is not enforced in code. `orchestrator.md:113` ("execution only when final_status == 'clear'") remains satisfied by the blocked value. |

**Disposition assessment.** The executor recorded all three as out-of-scope tensions rather than fixing them. This review evaluates that disposition as **correct but incomplete**:

- Correct, because `issue.md` "Constraints & Risks" line 45 declares item 1 out of scope in advance, with the carve-out "unless required for internal consistency". Acceptance criterion 5 scopes "internally consistent" to the two skill files ("Both files remain internally consistent with their existing sections"), and both files are internally consistent — each new block that touches an unchanged sibling statement explicitly names the statement it extends. The carve-out therefore does not trigger, and no acceptance criterion fails.
- Incomplete, because no follow-up issue has been filed for any of the three. Item 1 in particular reduces the runtime effect of the feature's primary mechanism: failure class 2 in the issue's Problem statement (a policy-compliance fix whose own prose violates the policy) is closed specifically by the delta self-check, and that is the rule the agent file's "only" excludes.

Recommended action: file one follow-up issue covering all three reconciliations before the next remediation cycle relies on the new behavior. Not a merge blocker for this branch.

### 8.2 New required signals carry no hook enforcement

Medium. `SELF-REVIEW: RE-DERIVED THIS PASS` and the `CONVERGENCE:` pair are stated as MUST requirements, but neither hook validates their presence, while their sibling `PREFLIGHT:` signals are enforced at lines 151 and 109 of the two hooks respectively. The new requirements are therefore advisory in practice. This is consistent with the change being scoped as documentation-only and is not a defect against any acceptance criterion, but it means the convergence bar cannot currently fail. Recommend folding hook coverage into the same follow-up.

### 8.3 Sweep scope omits the fifth cycle artifact

Low. `### Cycle-Document Sweep Scope` names four documents. The `## Required Artifacts` section immediately above it defines a cycle as exactly five artifacts; `remediation-inputs.md` is the fifth and is not named in the sweep scope. That artifact is orchestrator-authored prose that can carry the same self-referential violation class the subsection exists to catch. The omission matches acceptance criterion 4 exactly, which enumerates only those four, so this is a scoping observation for a future revision rather than a defect against the criterion.

### 8.4 Change lands on the Claude surface only

Informational, not a finding. `.agents/skills/` and `.github/skills/` carry separately maintained copies of both skills that are not updated by this branch, so the Copilot and Codex runtimes retain the pre-change convergence behavior. This review verified those copies were **already divergent at the merge-base** (`atomic-plan-contract/SKILL.md`: `e3b2198e` on `.claude/`, `3ed1f086` on `.agents/`, `90bab03b` on `.github/`), so they are surface-specific adaptations rather than byte-identical mirrors, and no parity contract is broken. The two most recent substantive changes to this contract (commits `88e7d5fc` for issue #519 and `04488789` for issue #486) each touched exactly the same file set as this branch. The file set matches established repository practice.

## 9. Summary of Changes

| File | Change | Lines |
| --- | --- | --- |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Adds `## Planner Adversarial Self-Review (Mandatory)` (line 142) with two rules and a two-value `SELF-REVIEW:` declaration; extends `## Preflight Validation (Planner ↔ Executor)` with four review-depth rules and a two-value `CONVERGENCE:` signal pair. | +28 / -0 |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Adds `### Cycle-Document Sweep Scope` (line 84) under `## Required Artifacts`; adds a cross-file reference, a convergence-field recording rule, and an iteration ceiling to `## Preflight Sub-Loop`. | +10 / -0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | Byte-identical mirror of the above. | +28 / -0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Byte-identical mirror of the above. | +10 / -0 |
| `docs/features/active/2026-08-28-atomic-preflight-convergence-586/**` | Feature scoping docs, plan, and 17 evidence artifacts. | +1321 / -0 |
| `docs/features/potential/promoted/2026-08-28-atomic-preflight-convergence.md` | Promotion lifecycle record. | +53 / -0 |

## 10. Compliance Verdict

**PASS with a required follow-up.**

| Area | Verdict |
| --- | --- |
| General unit test policy | N/A — no test or coverage-bearing file changed |
| General code change policy | PASS |
| Language-specific code change policy | N/A — no typed source file changed |
| Language-specific unit test policy | N/A — no test file changed |
| Coverage (TypeScript / Python / PowerShell / C#) | N/A — zero changed files in each |
| Tonality policy | PASS |
| Evidence location invariant | PASS |
| Additive-only constraint | PASS |
| Bundled mirror parity | PASS |
| Runtime enforcement compatibility | PASS |
| modified-workflow-needs-green-run | Not triggered |
| Cross-file contract reconciliation | PARTIAL — three unreconciled statements, all documentation-level, follow-up required |

No FAIL result was recorded. The single PARTIAL is documentation-level, causes no validator, hook, or test failure, and was declared out of scope in advance by the issue author with a carve-out that does not trigger. It does not meet the "meaningful FAIL or PARTIAL" bar for remediation handoff, so no remediation plan is generated by this review. A follow-up issue is required and is recorded as a condition on the go recommendation.

## Appendix A: Test Inventory

| Test module | Cases | Result | Relevance |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 10 | 10 passed | Asserts byte equality between every repository `.claude/**` file and its bundled copy, and asserts `REQUIRED_BUNDLED_FILES` membership for `atomic-plan-contract/SKILL.md`. This is the gate that would fail on a mirror drift. |

No new test was authored by this branch. None was required: the change adds no executable behavior, and the existing payload-parity module already covers the only mechanical invariant the change can break.

## Appendix B: Toolchain Commands Reference

Commands executed by this review pass, in order. All are check-only; no command mutated the working tree.

```bash
# Scope determination — full feature-vs-base diff
git diff --stat 1ff27b874154405f22001ad8e1e34062bbec625f..HEAD
git diff --name-status 1ff27b874154405f22001ad8e1e34062bbec625f..HEAD
git diff --shortstat 1ff27b874154405f22001ad8e1e34062bbec625f..HEAD
git diff 1ff27b874154405f22001ad8e1e34062bbec625f..HEAD -- .claude/skills/ extensions/

# Additive-only verification (deletion count per production file)
git diff --numstat 1ff27b874154405f22001ad8e1e34062bbec625f..HEAD -- .claude/ extensions/

# Bundled mirror parity — blob hash comparison at head
git hash-object .claude/skills/atomic-plan-contract/SKILL.md
git hash-object extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
git hash-object .claude/skills/remediation-handoff-atomic-planner/SKILL.md
git hash-object extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md

# Bundled mirror parity — payload contract test
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q

# Evidence location invariant
python scripts/dev_tools/validate_evidence_locations.py --root .

# Cross-surface divergence check at merge-base vs head
git rev-parse 1ff27b874154405f22001ad8e1e34062bbec625f:.claude/skills/atomic-plan-contract/SKILL.md
git rev-parse 1ff27b874154405f22001ad8e1e34062bbec625f:.agents/skills/atomic-plan-contract/SKILL.md
git rev-parse 1ff27b874154405f22001ad8e1e34062bbec625f:.github/skills/atomic-plan-contract/SKILL.md

# Cross-surface sync practice on prior contract changes
git log --format=%H -5 origin/main -- .claude/skills/atomic-plan-contract/SKILL.md
git show --name-only --format="" 88e7d5fcf3b85aa267536f7599d9dd555a124796

# Section placement and heading inventory
grep -n "^#\{1,3\} " .claude/skills/atomic-plan-contract/SKILL.md
grep -n "^#\{1,3\} " .claude/skills/remediation-handoff-atomic-planner/SKILL.md

# Cross-file tension verification
grep -n -i "preflight|format and structure|Return exactly one of" .claude/agents/atomic-executor.md
grep -n "final_status" .claude/agents/orchestrator.md
grep -n "PREFLIGHT|CONVERGENCE|SELF-REVIEW" .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1
grep -rn "preflight" scripts/dev_tools/validate_orchestrator_state.py
```

Commands not run, with reasons:

- Formatter, linter, and type-checker commands for Python, TypeScript, PowerShell, and C# were not run. Each language has zero changed files in the branch diff, so each stage has no in-scope file to evaluate.
- Coverage generation was not run for any language. Per the verification procedure, coverage is verified by inspecting pre-existing artifacts rather than by regenerating; and no language has a changed file that would require a coverage artifact.
- The MCP tools `resolve_policy_audit_template_asset` and `validate_orchestration_artifacts` are outside this review session's tool allowlist and could not be invoked. This artifact was instead structured directly against the canonical section list in `.claude/skills/policy-audit-template-usage/SKILL.md` step 5 and against the heading and evidence constants enforced by `scripts/dev_tools/validate_policy_audit_artifact.py`. Structural conformance was confirmed by running that validator module against this file.
