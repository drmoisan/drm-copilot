# Remediation Inputs: blast-radius bundled truth-table correction (#500)

**Timestamp:** 2026-08-22T00-52
**Authored by:** feature-review
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Head:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `59425465`
**Work Mode:** `full-bug`; acceptance-criteria source is `spec.md` only
**Cycle:** 1

---

## Trigger

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8 by the condition "required acceptance criteria are FAIL or PARTIAL". Two of the seventeen acceptance criteria in `spec.md` were evaluated PARTIAL and have been unchecked by this review.

No other trigger condition fired:

- Toolchain checks did not fail. All eleven runnable stages across Python, TypeScript, and PowerShell passed in a single uninterrupted reviewer-executed pass.
- Coverage did not regress and no threshold was breached in any language. Python 92.60% statements and 85.19% branches; TypeScript 96.66% lines and 90.04% branches; PowerShell 96.21% lines with no branch counter emitted by Pester. Every delta is 0.00.
- No coverage artifact is absent for any language with changed files.
- The `modified-workflow-needs-green-run` rule did not fire; zero changed paths match `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.
- No evidence-location violation exists; `validate_evidence_locations.py --root .` exits 0 and the diff writes nothing under a forbidden `artifacts/` evidence path.

**Blocking findings: 1.** The remediation below is documentation-only. No source code, no configuration data, and no test logic requires change to clear the blocking finding.

---

## Audit Artifacts That Produced These Findings

- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/policy-audit.2026-08-22T00-52.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/code-review.2026-08-22T00-52.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/feature-audit.2026-08-22T00-52.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T00-52.md`

---

## Enumerated Fix List

### R1 — Blocking. Correct the AC9 criterion text so it names the file that carries the gate

**File:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, `## Acceptance Criteria`, the ninth checkbox item, currently beginning:

```
- [ ] `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class key-partition
      gate, extending the existing two-copy `COMMITTED_CONFIGS` pattern at lines 474-499: Class 1
```

**Observed defect:** the criterion names `tests/scripts/dev_tools/test_blast_radius_config.py` as the file carrying the gate and names `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` as the verification. That file is untouched by the branch and stands at 499 lines. The named command collects 32 cases, none of which belongs to the gate. The gate was delivered in `tests/scripts/dev_tools/test_blast_radius_config_parity.py` with its declared constants and accessors in `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, under plan deviation PD-1 recorded in `artifacts/orchestration/orchestrator-state.json`. PD-1 is legitimate and forced by the hard 500-line ceiling in `.claude/rules/general-code-change.md`; only the criterion text was never amended to match.

**Expected behavior after the fix:** the criterion names `tests/scripts/dev_tools/test_blast_radius_config_parity.py` as the file carrying the three-class gate, states that it imports the shared helpers from `tests/scripts/dev_tools/test_blast_radius_config.py` and holds its declared constants and accessors in `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, records PD-1 and the 499-line ceiling as the reason for the sibling module, and cites `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` as the verification. The three-class content of the criterion is unchanged; only the file and command identifiers change. The checkbox is then set to `[x]`.

**Verification commands:**

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 0 and "14 passed"

git grep -n -F "test_blast_radius_config_parity.py" -- \
  docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
# expect at least one match inside the "## Acceptance Criteria" section
```

---

### R2 — Blocking. Correct the AC10 criterion text the same way

**File:** the same `spec.md`, the tenth checkbox item, currently beginning:

```
- [ ] The same file asserts that neither copy declares any of the five disqualified umbrella module
```

**Observed defect:** the criterion says "the same file" and "the same pytest invocation", inheriting both errors from AC9. The three assertions it names all exist and pass, in the sibling module.

**Expected behavior after the fix:** the criterion's "same file" and "same pytest invocation" references resolve to `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` after R1 lands. If R1 is written so that "the same file" no longer resolves correctly, restate the file name explicitly in AC10 rather than relying on the anaphor. The checkbox is then set to `[x]`.

**Verification commands:**

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 0 and "14 passed"; this selection contains the umbrella-denylist,
# separator-free, and non-vacuity cases the criterion names
```

---

### R3 — Minor, recommended in the same change. Correct the Class 2 mitigation sentence

**File:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, `## Risks & Mitigations`, the mitigation bullet reading:

```
Class 1 byte-equality and Class 2 portable-set equality both fail loudly when a future
self-hosted change does not reach the bundle.
```

**Observed defect:** the claim is true of Class 1 and false of Class 2. Demonstrated empirically: appending `Directory.Build.props` to the self-hosted `shared_surfaces` left the full 48-case selection at exit 0. Class 2 compares the bundled set against the hand-declared `PORTABLE_SHARED_SURFACES` constant and against `bundled <= self_hosted`, and a self-hosted-only addition violates neither.

**Expected behavior after the fix:** the sentence separates the two claims. Class 1 byte-equality fails loudly when a `mandate_reads`, `version`, or `over_breadth_fraction` change reaches only one copy. Class 2 portable-set equality fails on any unilateral change to the bundled set or to the declared constant, and does not observe the self-hosted set growing away from it; the catastrophic form of the fail-open defect, a published table with no separator-free shared surface, is instead blocked by the non-empty precondition in `test_every_separator_free_bundled_shared_surface_is_wildcard_free`.

**Verification command:**

```bash
git grep -n -F "Class 2 portable-set equality" -- \
  docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
# expect the revised wording, with no claim that Class 2 detects a self-hosted-only change
```

---

### R4 — Minor, optional in this cycle. Add the directional separator-free invariant

**Files:** `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (387 lines, 113 of headroom) and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (353 lines, 147 of headroom).

**Observed gap:** no assertion detects the self-hosted copy gaining a portable shared surface that never reaches the bundle. That is the direction that produced Cause B of this bug.

**Expected behavior after the fix:** a new case asserts that every separator-free entry in the self-hosted `shared_surfaces` is present in the bundled `shared_surfaces`, with a failure message naming the entries that are absent. The invariant is verified to hold at the current head and is verified to have failed against the pre-fix bundle, so it is falsifiable before it is committed. A mirrored Pester case follows the existing `Cross-copy key partition` `Context` pattern.

Historical justification, so the invariant is not speculative: at `a45a993b` the self-hosted separator-free set was exactly `poetry.lock`, `package-lock.json`, `quality-tiers.yml` while the bundled copy carried none. The invariant would have fired at that commit and it holds at `59425465`, where the bundled copy carries precisely those three.

**Verification commands:**

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 0 with the new case passing

git show fb30a9a58b8422e610a09b07361421e97367807a:extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json \
  > extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 1 with the new case failing, proving falsifiability
git checkout -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
```

If R4 is taken, `.claude/rules/parallel-orchestration.md` and its bundled mirror should record the invariant in the section added by this branch, and the mirror must stay byte-identical in the same commit.

---

### R5 — Minor, optional in this cycle. Record the `spec_text` argument in the measurement evidence

**File:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md`, the `Command:` block.

**Observed defect:** the recorded description states the script derives over every folder carrying a `plan*.md` but omits that each folder's `spec.md` was supplied as the `spec_text` argument to `derive_blast_radius`. Following the description as written yields 979 and 954 edges over the same 56-item set, not the recorded 1199 and 1182.

**Expected behavior after the fix:** the command description names all four positional arguments passed to `derive_blast_radius`, including that `spec.md` supplies `spec_text` and that `computed_at` was a fixed constant.

**Verification command:**

```bash
git grep -n -F "spec_text" -- \
  "docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md"
# expect at least one match inside the command description
```

---

### R6 — Minor, optional in this cycle. Replace the pipeline `ConvertTo-Json` in the Class 1 mirror

**File:** `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, the case `declares equal values for the runtime-describing keys in both copies`.

**Observed defect:** the comparison uses `$config[$key] | ConvertTo-Json -Depth 10 -Compress`. The pipeline form unrolls a collection, so a single-element list and a bare scalar both serialize to the same text, and an empty list serializes as `$null` exactly as an absent key does.

**Expected behavior after the fix:** the comparison uses `ConvertTo-Json -InputObject $config[$key] -Depth 10 -Compress` on both sides, which preserves the list-versus-scalar distinction.

**Verification commands:**

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCAnalyze -Root (Get-Location).ProviderPath   # expect exit 0, no findings
Invoke-PoshQCTest    -Root (Get-Location).ProviderPath   # expect exit 0, 3110 or more passed, 0 failed
```

---

## Priority and Minimum Sufficient Scope

| ID | Severity | Required to clear the blocking finding | Files touched |
|---|---|---|---|
| R1 | Blocking | Yes | `spec.md` |
| R2 | Blocking | Yes | `spec.md` |
| R3 | Minor | No | `spec.md` |
| R4 | Minor | No | two test files, optionally the rule and its mirror |
| R5 | Minor | No | one evidence artifact |
| R6 | Minor | No | one test file |

The minimum sufficient remediation is R1 and R2 alone, which touch one documentation file and change no executable behavior. R3 is strongly recommended alongside them because it corrects a false claim in the same document about the same gate. R4, R5, and R6 are recorded for the author's judgment and may be deferred to a follow-up.

If R4 or R6 is taken, the full toolchain loop must be rerun for the affected languages and the coverage figures recorded, because those changes touch test code.

---

## Do Not Do

- **Do not amend the substance of any acceptance criterion.** R1 and R2 change only the file and command identifiers and, in R1, add the PD-1 reason. The three-class content, the umbrella-denylist content, the separator-free requirement, and the non-vacuity floor requirement stay exactly as written.
- **Do not add, remove, or renumber acceptance criteria.** The count stays at seventeen.
- **Do not move the gate into `tests/scripts/dev_tools/test_blast_radius_config.py` to make the original text true.** That file stands at 499 of a permitted 500 lines and one added line would breach `.claude/rules/general-code-change.md`. The sibling-module design is correct.
- **Do not change `PAYLOAD_MODULES`, either truth table, or the rule text** as part of R1, R2, R3, or R5. Those are settled and verified.
- **Do not delete the bundled `modules` key.** `load_module_globs` raises `TypeError` on its absence and the gate calls that helper on the bundled copy. The retention is deliberate and is recorded in the rule.
- **Do not widen the bundled `shared_surfaces` set beyond the six declared portable entries** as part of R4. R4 adds an assertion; it does not change data. If the assertion fails after being added, that is a finding to report, not a licence to edit either copy.
- **Do not relax the Class 2 equality to a subset relation** in order to accommodate R4. Equality against the declared constant is what catches a silently added drm-copilot-specific entry, and losing it would trade one gap for another.
- **Do not weaken any assertion, delete any test, or add any suppression.** Zero `noqa`, `# type: ignore`, `eslint-disable`, `@ts-expect-error`, or PSScriptAnalyzer suppression exists in the branch today and none may be added.
- **Do not add a coverage `exclude` or `omit` entry.** None exists in the branch today.
- **Do not author, import, or read a JSON Schema** for either truth table. `.claude/rules/parallel-orchestration.md` prohibits it; enforcement remains prose plus validator and test logic.
- **Do not extend `SCOPED_ROOTS` in `test_push_down_claude_resource_contracts.py` to the `config` tree.** Research `## 4.4` rejected that as Option A because it would force drm-copilot-specific paths into every destination.
- **Do not open a new remediation cycle for the findings already listed here.** Any new finding discovered during execution begins cycle 2 with its own inputs artifact.
- **Do not write evidence anywhere but `<FEATURE>/evidence/<kind>/`.** Any instruction naming `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` must be rejected and the rejection recorded.
- **Do not modify any file under `.claude/rules/` or `.github/instructions/`** except the single `.claude/rules/parallel-orchestration.md` amendment and its byte-identical bundled mirror, and only if R4 is taken.

---

## Handoff

Plan authorship is routed to `atomic-planner` per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. That skill assigns authorship of `remediation-plan.md` to `atomic-planner` and prohibits the orchestrator from acting on the delta itself; `feature-review` likewise does not author the plan, so no plan stub was created by this review. The plan must conform to `.claude/skills/atomic-plan-contract/SKILL.md`, must pass `validate_orchestration_artifacts` with `artifact_type: "plan"`, and must clear `atomic-executor` preflight before execution.

Note on artifact layout: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` describes a folder-per-cycle layout of `remediation/<entry-ts>/` and `audit/<exit-ts>/`. The `feature-review` agent contract in force for this run specifies flat, timestamp-suffixed filenames at the feature root, and the delegating prompt asked for the artifacts in the active feature folder. This artifact and the three audit artifacts therefore use the flat form. Should the orchestrator adopt the folder-per-cycle layout for cycle 1, this file is the cycle-entry inputs artifact and `policy-audit.2026-08-22T00-52.md`, `code-review.2026-08-22T00-52.md`, and `feature-audit.2026-08-22T00-52.md` are the cycle-opening audit artifacts.

---

## Exit Condition for Cycle 1

Cycle 1 exits when a reaudit confirms all of the following:

1. `spec.md` AC9 names `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and cites a pytest invocation that collects the gate's cases, and its checkbox is `[x]`.
2. `spec.md` AC10 resolves to the same file and command, and its checkbox is `[x]`.
3. All seventeen acceptance criteria are checked and each is independently verifiable from its own stated command.
4. The full toolchain still passes in a single pass for every language with changed files, and coverage is unchanged or improved in all three coverage languages.
5. `blocking_count == 0`.
