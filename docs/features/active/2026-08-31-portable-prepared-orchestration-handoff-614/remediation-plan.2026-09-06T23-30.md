# Remediation Plan: Portable Prepared Orchestration Handoff (Issue #614)

**Cycle timestamp:** 2026-09-06T23-30
**Author:** atomic-planner
**Feature folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614`
**Work mode:** `full-feature` (persisted marker at `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/issue.md` line 10, `- Work Mode: full-feature`)
**Requirements sources:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`
**Remediation inputs:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-06T23-30.md`
**Audit artifacts:** `policy-audit.2026-09-06T23-30.md`, `code-review.2026-09-06T23-30.md`, `feature-audit.2026-09-06T23-30.md` in the same folder
**Branch:** `feature/portable-prepared-orchestration-handoff-614`
**Head at plan authoring:** `a7b80f2df6d849aa65de416655fa58beb4412998`
**Base:** `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Merge base:** `1ed0964045febbb4d92f1cb92661d4b945153a40`
**Status:** revision 2 after preflight deltas

Revision 1 applied the preflight deltas D1 through D8 returned by `atomic-executor` on 2026-09-07,
together with the section 3.1 overflow reconciliation those deltas require; the task count, the task
identifiers, and the checklist state are unchanged. Revision 2 applied the preflight deltas D9
through D11 returned by `atomic-executor` on 2026-09-07, likewise without changing the task count,
the task identifiers, or the checklist state.

All evidence produced by this plan is written under
`docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/<kind>/`
with the `2026-09-06T23-30` timestamp. No task writes to `artifacts/baselines/`, `artifacts/baseline/`,
`artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`,
`artifacts/regression-testing/`, or `artifacts/post-change/`.

Every command in this plan runs from the workspace root
`C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29` unless the task states
`run from extensions/drm-copilot`, in which case the working directory is set with
`Set-Location extensions/drm-copilot` inside the same shell invocation.

---

## 1. Scope

### 1.1 In scope

This plan implements exactly three items from the remediation inputs: **R1**, **R2**, and **R3**,
including R3's "additional correction in the same area" (make the candidate re-validation failure
path and the atomic-replace failure path agree on the recovery contract).

**Authorized production paths (write):**

- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` (439 lines at
  `a7b80f2d`; R3 correction only)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts`
  (authorized by the orchestrator only if the correction requires the shared request module; the
  reference design in section 3.3 does not require it, and no task in this plan changes it)

**Authorized test paths (write):**

- `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py` (451 lines at `a7b80f2d`; R1)
- `tests/scripts/dev_tools/test_orchestration_handoff_contract.py` (100 lines at `a7b80f2d`; R2)
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts` (334 lines
  at `a7b80f2d`; R3)
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`
  (249 lines at `a7b80f2d`; R3 shared seams and path helpers)
- `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` — conditional entry,
  created only under the section 3.1 overflow rule. It does not exist at `a7b80f2d`, and P1-T1
  creates it only if the R1 addition would push
  `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py` past 500 lines. When the overflow
  rule does not apply, no task creates this file and it must not appear in any Phase 4 output.

**Authorized documentation path (write):**

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` — the AC10
  checkbox on line 360 only, re-checked from `- [ ]` to `- [x]` after the R3 tests exist and pass,
  under the `acceptance-criteria-tracking` skill.

**Authorized temporary mutation (must be reverted within its own task):**

- `scripts/dev_tools/orchestration_handoff_contract.py` line 68 — reordered for the R2 load-bearing
  check in P2-T2 and restored in the same task, with byte identity against `a7b80f2d` re-established
  and verified before the task is complete. The file is not a net change of this plan.

### 1.2 Out of scope (deferred; must not be executed by this plan)

R4, R5, R6, R7a, R7b, and R7c from the remediation inputs are deferred follow-ups. No task in this
plan may modify `.codex/hooks/` (or its published copy), `extensions/drm-copilot/jest.config.cjs`,
`scripts/dev_tools/orchestration_handoff_contract_support.py`, or the `PHASE_ORDER` and
`FAILURE_PRECEDENCE` literal construction in `scripts/dev_tools/orchestration_handoff_contract.py`.

Further prohibitions carried from the remediation inputs, each of which is verified by a Phase 4 gate:

- Do not change which failure code any condition returns (verified by P0-T3 and P3-T4 against the
  failure-code inventory of the materializer).
- Do not modify any file under `tests/fixtures/orchestration-handoff/`, `config/orchestration-handoff.schema.json`,
  or `config/orchestration-handoff-registry.json` (verified by P4-T12).
- Do not add a dependency; do not add a `coverageThreshold`, `coveragePathIgnorePatterns`, or
  `exclude` entry; do not lower a threshold (verified by P4-T14, which shows the changed-path set).
- Do not create or use temporary files in tests. All filesystem behavior is driven through the
  injected `HandoffFileSystemBoundary` fake in
  `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`.
- Do not expand into issue #467 or issue #543 surfaces.

### 1.3 Working-tree classification

`git status --porcelain=v1 --untracked-files=all` at plan authoring is expected to report only the
rows below. P0-T2 records the actual output and classifies every row against this table; P4-T14
repeats the classification at the end of execution. A row that matches no class fails the task.

| Class | Rows | Disposition |
|---|---|---|
| A — authorized edits | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`, `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`, `tests/scripts/dev_tools/test_orchestration_handoff_contract.py`, and `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` only when P1-T1 created it under the section 3.1 overflow rule | Absent at P0-T2; present as ` M` at P4-T14, except that the conditional overflow module is a new file and is present as `??` instead. |
| B — reviewer AC10 uncheck | ` M docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` | Present at P0-T2. P3-T5 restores the checkbox to `- [x]`, which returns the file to its `a7b80f2d` content, so the row is absent at P4-T14. |
| C — pre-existing untracked review artifacts | `policy-audit.2026-09-06T23-30.md`, `code-review.2026-09-06T23-30.md`, `feature-audit.2026-09-06T23-30.md`, `remediation-inputs.2026-09-06T23-30.md`, `evidence/qa-gates/review-artifact-validation.2026-09-06T23-30.md`, all under the feature folder | Authorized pre-existing state. No task modifies them. Present as `??` at P0-T2 and at P4-T14. |
| D — evidence written by this plan | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/{remediation-baseline,regression-testing,qa-gates,other}/*.2026-09-06T23-30.md` | Absent at P0-T2 except as created by Phase 0 itself; present as `??` at P4-T14. |
| E — this plan file | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-06T23-30.md` | Present as `??` at P0-T2 and at P4-T14. |
| F — ignored generated output | `artifacts/**` (ignored at `.gitignore:6`, `/artifacts`), `extensions/drm-copilot/coverage/**` (ignored at `.gitignore:60`), `.claude/state/**` (ignored at `.gitignore:68`) | Never appears in `--untracked-files=all` output because the paths are ignored. Handled by the `.claude/state/` precondition below. |

### 1.4 `.claude/state/` runtime-file precondition

Three tasks run pytest over suites that can regenerate a gitignored runtime file under
`.claude/state/` (P0-T7, P4-T4, P4-T15). Each of those tasks must:

1. Record `git status --porcelain=v1 --untracked-files=all -- .claude` before the run.
2. Record `Get-ChildItem -LiteralPath .claude/state -Recurse -File -ErrorAction SilentlyContinue`
   before the run.
3. Run the pytest command.
4. Record the same two observations after the run.
5. Remove any file present under `.claude/state/` after the run that was absent before it.
6. Confirm the two `git status --porcelain=v1 --untracked-files=all -- .claude` observations are
   byte-identical. No task in this plan modifies any file under `.claude/`, so the expected output of
   both observations is no rows.

---

## 2. Requirements traceability

The acceptance criteria this plan is accountable for are the six the remediation inputs name for
R1, R2, and R3. All other criteria in `spec.md` and `user-story.md` are already checked and are not
re-evaluated by this plan.

| ID | Source | Text anchor | Current state | This plan |
|---|---|---|---|---|
| SPEC-AC4 | `spec.md` line 340 | Adapters carry portable complexity, lifecycle, route, plan, and ownership semantics | `- [x]` | R1 adds the missing negative coverage of the guard that backs it; state unchanged. |
| SPEC-AC5 | `spec.md` line 343 | A destination projection resumes the exact recorded transition and rejects replay | `- [x]` | R1 as above; state unchanged. |
| SPEC-AC10 | `spec.md` line 360 | Materialization ... any failure leaves the source checkpoint intact and records no completed transition | `- [ ]` (unchecked by `feature-audit.2026-09-06T23-30.md`) | R3 proves the post-write failure behavior; P3-T5 re-checks to `- [x]`. |
| SPEC-AC11 | `spec.md` line 364 | Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered `HANDOFF_*` precedence | `- [x]` | R2 binds the Python precedence tuple to the registry; state unchanged. |
| US-3 | `user-story.md` line 94 | Adapters preserve logical complexity, route, lifecycle, plan, and ownership semantics | `- [x]` | R1; state unchanged. |
| US-10 | `user-story.md` line 115 | Unsupported versions, tampered source or history, ... each fail closed with the contract's deterministic primary code | `- [x]` | R2; state unchanged. |

---

## 3. Reference designs

These designs are normative. They exist so the line budgets in section 1.1 hold and so the
acceptance conditions below are satisfiable as written.

### 3.1 R1 — Python destination-projection integrity coverage

Target file: `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py` (451 lines).
Budget: 45 added lines, reaching 496 lines against a hard limit of 500. The 45 comprise the 42 lines
of the fenced block below, two blank lines separating the new constant from `SCHEDULED_CASES`, and
one line for `HandoffContractError,` in the import block. Every construct below carries a magic
trailing comma, so Black keeps each signature exploded and recovers none of that. The remaining
headroom is four lines: add no comment, no blank line, and no helper beyond what this section
specifies. If the file nonetheless exceeds 500 lines, move `PROJECTION_REJECTION_FIELDS`,
`_diverged_facts`, and the new test into
`tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` as a new sibling test
module importing the same names, rather than exceeding the cap or trimming the test.

Guard under test: `_validate_projection_facts` at `scripts/dev_tools/orchestration_handoff_adapters.py`
lines 191-217, invoked from `ClaudeToCodexAdapter.project` at line 330 and from
`CodexToClaudeAdapter.project` at line 404. The five uncovered rejection lines are 196, 198, 202,
210, and 215.

Add one module-level constant after `SCHEDULED_CASES` (line 53-56), one private helper, and one
parametrized test:

```python
PROJECTION_REJECTION_FIELDS = (
    "plan",
    "lifecycle",
    "scheduler_context",
    "envelope_sha256",
    "history_entry_sha256",
)


def _diverged_facts(
    envelope: HandoffEnvelope,
    field: str,
) -> PortableProjectionFacts:
    """Return projection facts whose single named field diverges from the envelope."""

    divergent: dict[str, Any] = {
        "plan": replace(envelope.plan, sha256="e" * 64),
        "lifecycle": replace(
            envelope.lifecycle,
            route_intent="prepared_child_to_ordinary_execution",
        ),
        "scheduler_context": _scheduled_envelope(
            "claude", "codex", "claude-to-codex-v1", "parallel", "cohort-1"
        ).scheduler_context,
        "envelope_sha256": "not-a-sha256-digest",
        "history_entry_sha256": "f" * 64,
    }
    return replace(_projection_facts(envelope), **{field: divergent[field]})


@pytest.mark.parametrize("field", PROJECTION_REJECTION_FIELDS)
def test_projection_facts_diverging_from_the_envelope_are_rejected(
    field: str,
) -> None:
    """Each projection-integrity guard raises with its documented field name."""

    envelope = _ordinary_envelope("claude", "codex", "claude-to-codex-v1")

    with pytest.raises(HandoffContractError) as raised:
        ClaudeToCodexAdapter().project(envelope, _diverged_facts(envelope, field))

    assert raised.value.field == f"projection.{field}"
```

`HandoffContractError` is added to the existing
`from scripts.dev_tools.orchestration_handoff_contract import (` block at lines 21-29. The exception
carries a `field` attribute assigned at
`scripts/dev_tools/orchestration_handoff_contract_support.py` line 19.

Each divergent value is constructible: `PortableProjectionFacts` is a plain frozen dataclass with no
`__post_init__` validation (`scripts/dev_tools/orchestration_handoff_adapters.py` lines 29-37);
`"e" * 64` satisfies `SHA256_PATTERN` and passes the `_require_sha256` check in the `PlanIdentity`
branch of `_validate_value` (`scripts/dev_tools/orchestration_handoff_contract.py` lines 225-229).
It must not be `"c" * 64`: the fixture at
`tests/scripts/dev_tools/validate_orchestrator_state_test_support.py` line 184 already sets
`plan.sha256` to that value, so `replace` would return a `PlanIdentity` equal to the envelope's and
the guard at `scripts/dev_tools/orchestration_handoff_adapters.py` line 195 would not fire.
`"prepared_child_to_ordinary_execution"` is a member of `ROUTE_INTENTS` and the `LifecycleState`
branch of `_validate_value` (lines 241-255) checks membership only, with no cross-field constraint
against `scheduler_context`; and the scheduler value is taken from an already-valid scheduled envelope rather
than constructed by `replace`, because `SchedulerContext` rejects a `kind` change that leaves the
scheduled fields unset (`scripts/dev_tools/orchestration_handoff_contract.py` lines 264-273).

### 3.2 R2 — Python failure-precedence parity binding

Target file: `tests/scripts/dev_tools/test_orchestration_handoff_contract.py` (100 lines). Budget:
approximately 6 added lines.

Add `FAILURE_PRECEDENCE` to the existing
`from scripts.dev_tools.orchestration_handoff_contract import (` block at lines 13-18, add a module
constant beside `SUPPORTED_CAPABILITIES` (line 28) using the same already-accepted pattern, and add
one test:

```python
REGISTRY_FAILURE_PRECEDENCE = tuple(REGISTRY["failure_precedence"])


def test_failure_precedence_matches_the_shared_registry() -> None:
    """The Python precedence tuple stays bound to the registry ordering."""

    assert FAILURE_PRECEDENCE == REGISTRY_FAILURE_PRECEDENCE
```

The assertion compares the full ordered sequence, because the ordering is the contract. It mirrors
`expect(HANDOFF_FAILURE_PRECEDENCE).toEqual(registry["failure_precedence"])` at
`extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts` line 267. The
registry array is at `config/orchestration-handoff-registry.json` lines 120-137 and holds sixteen
entries; the Python literal is at `scripts/dev_tools/orchestration_handoff_contract.py` lines 67-76.

### 3.3 R3 — TypeScript materialization recovery coverage and recovery-contract correction

**Support seams.** `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`
(249 lines) gains, all additive and defaulting to today's behavior:

- `readonly failReadFor?: (filePath: string) => boolean;` on `ScenarioOptions`, consulted at the top
  of the `readFile` fake (currently lines 152-157) and throwing when it returns `true`.
- `readonly removeFailure?: boolean;` on `ScenarioOptions`. The `removeFile` fake becomes a named
  `jest.fn` that throws when the flag is set and otherwise deletes the entry from `files`; the named
  mock is exposed on the returned scenario object beside `readFile`, `writeFile`, and `replaceFile`.
- `readonly candidateProjectionErrors?: readonly string[];` on `ScenarioOptions`. The
  `validateDestinationProjection` fake (currently lines 219-221) counts its calls and returns
  `candidateProjectionErrors` on the second and later calls when that option is defined, and
  `projectionErrors ?? []` otherwise. With the option undefined the fake returns exactly what it
  returns today, so no existing test changes behavior.
- `export function archivePathFor(sourceSha256: string): string` returning
  `` `C:/workspace/artifacts/orchestration/handoffs/sources/sha256/${sourceSha256}.json` ``, which is
  the path the existing success test builds inline at
  `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts` lines 229-231.
- `export function candidatePathFor(envelopeSha256: string): string` returning
  `` `C:/workspace/artifacts/orchestration/orchestrator-state.handoff-candidate-${envelopeSha256}.json` ``,
  which is the value that same test asserts at lines 246-249.
- `export async function materializedProjectionBytes(): Promise<Uint8Array>` which builds a
  materialize scenario, runs one transition, and returns the second recorded `writeFile` argument
  (the candidate payload), throwing when no second write was recorded. The projection is
  deterministic because the clock is injected, so a second scenario seeded with these bytes matches
  digest-for-digest.

Projected size: approximately 290 lines. Hard limit 500.

**Correction.** In `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`,
the candidate re-validation failure path (lines 413-424) attempts `removeFile` on the retained
candidate and reports `[preparation.candidatePath]`, while the adjacent atomic-replace failure path
(lines 430-436) attempts no cleanup and reports `[preparation.destinationPath]`. Make the two agree:

- Extract the existing inline cleanup at lines 414-418 into one private method placed immediately
  after `stageMaterialization`, named `discardCandidate`, taking the candidate path, calling
  `this.dependencies.fileSystem.removeFile`, and swallowing a removal failure under the existing
  comment `The blocked result names the retained candidate for explicit cleanup.`
- Call `discardCandidate` from the re-validation failure path in place of the inline try/catch.
- Call `discardCandidate` from the atomic-replace failure path and change its `affectedPaths` from
  `[preparation.destinationPath]` to `[preparation.candidatePath]`, so an operator recovering from a
  failed rename is told which file remains. The destination checkpoint is untouched on that path, so
  naming it gave the operator no actionable file.

Both paths keep `HANDOFF_VALIDATOR_UNAVAILABLE`. No other failure code, condition, or ordering
changes. Projected size: approximately 445 lines. Hard limit 500.

**Tests.** Seven tests are added to
`extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`, each using
`createScenario({ request: { mode: "materialize" } })` and each asserting the returned
`primaryFailureCode`, the returned `affectedPaths`, and that `status` is never `materialized`
(except the one idempotent case, which asserts `materialized`). Their exact names are:

1. `blocks when a pre-existing archive cannot be re-read`
2. `blocks a pre-existing candidate whose digest differs from the projection`
3. `materializes when a pre-existing candidate already holds the projection bytes`
4. `discards the candidate and blocks when re-validation rejects it`
5. `discards the candidate and blocks when the candidate cannot be re-read`
6. `blocks with the retained candidate when candidate removal also fails`
7. `discards the candidate and names it when the atomic replace fails`

Drivers, in the same order: seed `files` at `archivePathFor(scenario.sourceSha256)` and set
`failReadFor` to match the `/sources/sha256/` segment; seed `files` at
`candidatePathFor(scenario.envelopeSha256)` with unrelated bytes; seed the same path with the bytes
from `materializedProjectionBytes()`; set `candidateProjectionErrors`; set `failReadFor` to match the
candidate path; set `candidateProjectionErrors` together with `removeFailure`; set `replaceFailure`.

The remaining branch named in the remediation inputs, "pre-existing archive with a matching digest
proceeds rather than failing", is already exercised by the existing test
`atomically replaces the canonical checkpoint after candidate validation`, which seeds the archive
with the source bytes at line 232 and asserts both `status` `materialized` and that the archive bytes
are unchanged at line 245. No duplicate test is added for it; P3-T2 records that citation.

Projected size: approximately 464 lines. Hard limit 500.

---

## 4. Phases

Task identifiers are sequential within each phase. A task is complete only when its evidence artifact
exists and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Tasks tagged
`[expect-fail]` additionally carry `ExpectedExitCode:` and the expected failure signature.

### Phase 0 — Policy reads, baselines, and scope capture

- [x] [P0-T1] Read, in the order required by the `policy-compliance-order` skill: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, then the language rules for the files in scope, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, and then `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/architecture-boundaries.md`, and `.claude/rules/tonality.md`, and write `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/phase0-instructions-read.2026-09-06T23-30.md` containing `Timestamp:`, `Policy Order:` and the eleven file paths in the order read. Acceptance: the artifact exists and lists all eleven paths.

- [x] [P0-T2] Capture worktree and branch scope. Run `git rev-parse HEAD`, then `git status --porcelain=v1 --untracked-files=all`, then `git diff --name-only 1ed0964045febbb4d92f1cb92661d4b945153a40 a7b80f2df6d849aa65de416655fa58beb4412998`. Record all three outputs verbatim in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/worktree-and-scope.2026-09-06T23-30.md`, together with the row count of the third output and a classification of every status row against the table in section 1.3. Acceptance: `git rev-parse HEAD` prints `a7b80f2df6d849aa65de416655fa58beb4412998`, and every status row is assigned to class B, C, D, or E; a row assigned to no class fails the task.

- [x] [P0-T3] Capture the file-size and failure-code baseline. Run `Get-ChildItem -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts, tests/scripts/dev_tools/test_orchestration_handoff_adapters.py, tests/scripts/dev_tools/test_orchestration_handoff_contract.py | ForEach-Object { "$($_.Name) $((Get-Content -LiteralPath $_.FullName).Count)" }` and then `Select-String -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts -Pattern 'HANDOFF_[A-Z_]+' -AllMatches -CaseSensitive | ForEach-Object { $_.Matches.Value } | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }`. Record both outputs in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/line-count-and-failure-code-inventory.2026-09-06T23-30.md`. Acceptance: the five line counts are recorded and equal 439, 334, 249, 451, and 100 respectively, and the failure-code inventory is recorded as a sorted name-and-count list.

- [x] [P0-T4] Baseline Python formatting. Run `poetry run black --check .` and record the exit code and the printed `would be left unchanged` line in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/python-black.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the output contains no line beginning `would reformat`.

- [x] [P0-T5] Baseline Python linting. Run `poetry run ruff check .` and record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/python-ruff.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the output contains `All checks passed!`.

- [x] [P0-T6] Baseline Python type checking. Run `poetry run pyright` and record the summary line in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/python-pyright.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the recorded summary reports `0 errors`.

- [x] [P0-T7] Baseline Python tests and coverage under the section 1.4 precondition. Run `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing` and record, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/python-pytest-coverage.2026-09-06T23-30.md`: the passed and failed counts from the summary line, the `TOTAL` row of the terminal table exactly as printed including its single combined `Cover` percentage, the full `scripts/dev_tools/orchestration_handoff_adapters.py` row including its `Missing` column, and the four `.claude` precondition observations. The terminal table's `Name` column is written with the platform path separator, so that row reads `scripts\dev_tools\orchestration_handoff_adapters.py` rather than a forward-slash spelling; the same relative-path spelling is what `artifacts/python/lcov.info` records on its `SF:` lines. Acceptance: `EXIT_CODE: 0`, zero failed tests, the recorded `Missing` column for `scripts/dev_tools/orchestration_handoff_adapters.py` contains 196, 198, 202, 210, and 215, and the before and after `git status --porcelain=v1 --untracked-files=all -- .claude` observations are byte-identical.

- [x] [P0-T8] Baseline TypeScript formatting. Run from `extensions/drm-copilot`: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-prettier.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the output contains `All matched files use Prettier code style!`.

- [x] [P0-T9] Baseline TypeScript linting. Run from `extensions/drm-copilot`: `npm run lint`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-eslint.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and no recorded line contains the text `warning`. ESLint prints nothing when it reports no problem, and its exit code is non-zero on any error, so the pair of observations separates a clean run from a run carrying warnings only. The word `error` is not usable as a marker here because the npm banner echoes the script's `--no-error-on-unmatched-pattern` flag.

- [x] [P0-T10] Baseline TypeScript type checking. Run from `extensions/drm-copilot`: `npm run typecheck`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-tsc.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the recorded output is empty apart from the npm script banner.

- [x] [P0-T11] Baseline TypeScript tests and coverage. Run from `extensions/drm-copilot`: `npm run test:coverage`. That script passes `--coverageReporters=lcov --coverageReporters=text-summary`, so the run prints a coverage summary block and no per-file table; per-file data is read from `extensions/drm-copilot/coverage/lcov.info`. Record in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-jest-coverage.2026-09-06T23-30.md`: the suite and test counts, the `Statements`, `Branches`, `Functions`, and `Lines` lines of the coverage summary exactly as printed, and from the `SF:` record of `extensions/drm-copilot/coverage/lcov.info` whose value ends with the file name `orchestration-handoff-materializer.ts`, written with the platform separator as `src\lib\validate\orchestration-handoff-materializer.ts` and distinct from the three sibling records in the same directory, which are `orchestration-handoff-materializer-production.ts`, `orchestration-handoff-materializer-request.ts`, and `orchestration-handoff-materializer-support.ts`, the `LF:` value, the `LH:` value, and the ascending list of line numbers carrying a zero-hit `DA:` record. Acceptance: `EXIT_CODE: 0`, zero failed tests, and the recorded zero-hit list includes 358, 392, and 411.

- [x] [P0-T12] Baseline PowerShell as a no-regression surface. Invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the workspace root and no other argument. The tool returns only an ok flag and a one-sentence summary and prints no test counts and no coverage percentage, so the numbers are read from the run's own result artifacts: the root `testsuites` attributes and the per-`testcase` tally of `artifacts/pester/pester-junit.xml`, and the report-level `LINE` counter of `artifacts/pester/powershell-coverage.xml`, which is the `counter` element carrying `type="LINE"` whose parent is the root `report` element and which is the last such element in the file. That file carries 868 elements matching `counter type="LINE"`, one per method, class, and package in addition to the report-level total, so the report-level element is named here rather than left to selection. Record the MCP result verbatim, the total, passed, failed, errored, and skipped counts, and the `LINE` covered, missed, total, and percentage values in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/powershell-pester-coverage.2026-09-06T23-30.md`. Acceptance: the root `testsuites` element of `artifacts/pester/pester-junit.xml` carries `failures="0"` and `errors="0"`, and the `LINE` percentage is recorded as a number.

### Phase 1 — R1: Python destination-projection integrity coverage

- [x] [P1-T1] Add the constant, helper, and parametrized test of section 3.1 to `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`, adding `HandoffContractError` to its existing contract import block. Run `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_adapters.py -v` and `(Get-Content -LiteralPath tests/scripts/dev_tools/test_orchestration_handoff_adapters.py).Count`. The `-v` form is required because the acceptance reads node identifiers, which the quiet form does not print for passing tests. If the section 3.1 overflow rule applied and the new module was created, append `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` to the pytest invocation and record that module's line count as well. Record both in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r1-projection-integrity-tests.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0`, zero failed tests, the recorded output lists five `PASSED` lines whose node identifiers begin `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected`, or, when the section 3.1 overflow rule applied, `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py::test_projection_facts_diverging_from_the_envelope_are_rejected`, and every recorded line count is at most 500.

- [x] [P1-T2] Confirm the five guard lines are now covered. Run `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`, appending `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` to that invocation when the section 3.1 overflow rule created it, and record the full `scripts/dev_tools/orchestration_handoff_adapters.py` row of the terminal table, written with the platform separator as stated in P0-T7 and including its `Missing` column, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r1-projection-coverage.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the recorded `Missing` column contains none of 196, 198, 202, 210, or 215.

### Phase 2 — R2: Python failure-precedence parity binding

- [x] [P2-T1] Add the constant and test of section 3.2 to `tests/scripts/dev_tools/test_orchestration_handoff_contract.py`, adding `FAILURE_PRECEDENCE` to its existing contract import block. Run `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py -v` and `(Get-Content -LiteralPath tests/scripts/dev_tools/test_orchestration_handoff_contract.py).Count`. The `-v` form is required because the acceptance reads a node identifier, which the quiet form does not print for a passing test. Record both in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r2-registry-parity-test.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0`, zero failed tests, the recorded output lists a `PASSED` line for node identifier `tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry`, and the recorded line count is at most 500.

- [x] [P2-T2] `[expect-fail]` Prove the parity assertion is load-bearing, then restore byte identity. In `scripts/dev_tools/orchestration_handoff_contract.py`, replace line 68, whose exact current text is `    "HANDOFF_UNSUPPORTED_VERSION HANDOFF_SOURCE_HASH_MISMATCH "`, with the exact text `    "HANDOFF_SOURCE_HASH_MISMATCH HANDOFF_UNSUPPORTED_VERSION "`. Run `poetry run pytest "tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry" -q` and record its non-zero exit code and the assertion text. Then restore line 68 to its exact original text, run `git diff --exit-code a7b80f2df6d849aa65de416655fa58beb4412998 -- scripts/dev_tools/orchestration_handoff_contract.py` and `git status --porcelain=v1 -- scripts/dev_tools/orchestration_handoff_contract.py`, and re-run the same pytest node. Record every step in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r2-load-bearing-check.2026-09-06T23-30.md` with `ExpectedExitCode: 1` for the mutated run. Acceptance: the mutated run exits 1 with a failure naming `test_failure_precedence_matches_the_shared_registry`; after restoration `git diff --exit-code` exits 0, `git status --porcelain=v1` prints no row for that path, and the re-run of the pytest node exits 0.

### Phase 3 — R3: Materialization recovery coverage and recovery-contract correction

- [x] [P3-T1] Extend `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts` with the `failReadFor`, `removeFailure`, and `candidateProjectionErrors` options and the `archivePathFor`, `candidatePathFor`, and `materializedProjectionBytes` exports described in section 3.3, exposing the named `removeFile` mock on the returned scenario object. Run from `extensions/drm-copilot`: `npm run typecheck`, then `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts`, then `(Get-Content -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts).Count` from the workspace root. Record all three, including the exact passed-test count of the jest run, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r3-support-seams.2026-09-06T23-30.md`. Acceptance: the `npm run typecheck` command and the jest command each exit 0, the jest run reports zero failed tests, and the recorded line count is at most 500.

- [x] [P3-T2] Add the six recovery tests named 1 through 6 in section 3.3 to `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`, and record in the evidence two citations for branches that need no new test. First, a pre-existing archive whose digest matches is already exercised by the existing test `atomically replaces the canonical checkpoint after candidate validation` at lines 226-260 of that file, which seeds the archive at line 232 and asserts both `materialized` status and unchanged archive bytes at line 245. Second, a pre-existing archive whose digest differs is already exercised by the `archive write failure` entry at lines 163-168 of the parametrized test `blocks $name without mutation`, which asserts `HANDOFF_SOURCE_HASH_MISMATCH`; that entry supplies no `affectedPaths` value, so the archive-path half of the remediation input's bullet for this branch remains unasserted and is recorded here as an accepted deviation rather than closed. Run from `extensions/drm-copilot`: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts`, and from the workspace root `(Get-Content -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts).Count`. Record both in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r3-recovery-branch-tests.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0`, zero failed tests, the passed-test count is exactly six greater than the count recorded in P3-T1, and the recorded line count is at most 500.

- [x] [P3-T3] `[expect-fail]` Add the seventh test, named `discards the candidate and names it when the atomic replace fails`, asserting that the result carries `HANDOFF_VALIDATOR_UNAVAILABLE`, that `affectedPaths` equals `[candidatePathFor(scenario.envelopeSha256)]`, that the scenario's `removeFile` mock was called once with that same candidate path, and that the source checkpoint bytes are unchanged. Run from `extensions/drm-copilot`: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts`. Record the run, with `ExpectedExitCode: 1`, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r3-replace-recovery-red.2026-09-06T23-30.md`, including the received `affectedPaths` value and the received `removeFile` call count. Acceptance: the run exits 1 with exactly one failed test, that test is the newly added one, and the recorded failure shows the destination path where the candidate path was expected, the `removeFile` call count as 0, or both.

- [x] [P3-T4] Apply the production correction of section 3.3 to `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`: add the private method `discardCandidate` immediately after `stageMaterialization`, call it from the candidate re-validation failure path in place of the inline try/catch, call it from the atomic-replace failure path, and change that path's `affectedPaths` to the candidate path. Run from `extensions/drm-copilot`: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts`; then from the workspace root `(Get-Content -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts).Count` and `Select-String -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts -Pattern 'HANDOFF_[A-Z_]+' -AllMatches -CaseSensitive | ForEach-Object { $_.Matches.Value } | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }`. Record all three in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/r3-replace-recovery-green.2026-09-06T23-30.md`. Acceptance: the jest run exits 0 with zero failed tests and a passed count exactly seven greater than the count recorded in P3-T1; the recorded line count is at most 500; and the failure-code inventory is identical to the inventory recorded in P0-T3.

- [x] [P3-T5] Re-check spec AC10 under the `acceptance-criteria-tracking` skill. In `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md`, change line 360 from `- [ ] AC10:` to `- [x] AC10:` and change nothing else. Run `Select-String -LiteralPath docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md -Pattern '- [x] AC10:' -SimpleMatch` and `git diff a7b80f2df6d849aa65de416655fa58beb4412998 -- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md`. Record both outputs and the P3-T2 and P3-T4 evidence paths as the supporting proof in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/ac10-recheck.2026-09-06T23-30.md`. Acceptance: the search returns exactly one match, on line 360; and the recorded `git diff` output contains no hunk, which is the expected result because `feature-audit.2026-09-06T23-30.md` line 153 records that only the checkbox marker was changed by the audit. A non-empty diff fails the task and its content must be reported rather than reverted.

### Phase 4 — Final QA loop and gates

Run the stages in the order given. If any stage fails, or if any stage changes a tracked file,
correct the cause and restart Phase 4 from P4-T1. Do not record `EXIT_CODE: SKIPPED` for any task in
this phase; every task's command must be executed.

- [x] [P4-T1] Formatting, Python. Run `poetry run black --check .` and record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-format.2026-09-06T23-30.md`, including the printed `would be left unchanged` line. Acceptance: `EXIT_CODE: 0` and no line beginning `would reformat`.

- [x] [P4-T2] Linting, Python. Run `poetry run ruff check .` and record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-lint.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the output contains `All checks passed!`.

- [x] [P4-T3] Type checking, Python. Run `poetry run pyright` and record the summary line in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-typecheck.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the recorded summary reports `0 errors`.

- [x] [P4-T4] Unit tests and coverage, Python, under the section 1.4 precondition. Run `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing` and record, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-unit-coverage.2026-09-06T23-30.md`: the passed and failed counts, the `TOTAL` row exactly as printed, the `scripts/dev_tools/orchestration_handoff_adapters.py` row, written with the platform separator as stated in P0-T7 and including its `Missing` column, the four `.claude` precondition observations, and an explicit comparison against P0-T7. Acceptance: `EXIT_CODE: 0`, zero failed tests, the passed count is at least the count recorded in P0-T7 plus six, the `TOTAL` row's combined `Cover` percentage is at least the exact percentage recorded in P0-T7, the `Missing` column for the adapters module contains none of 196, 198, 202, 210, or 215, and the two `.claude` status observations are byte-identical.

- [x] [P4-T5] Confirm the Python coverage artifact agrees with the terminal table. Read `artifacts/python/lcov.info`, locate the record whose `SF:` line ends with the file name `orchestration_handoff_adapters.py`; that `SF:` value is written with the platform path separator, so it reads `scripts\dev_tools\orchestration_handoff_adapters.py` rather than a forward-slash spelling, and record its `LF:`, `LH:`, and the ascending list of zero-hit `DA:` line numbers in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-projection-lcov.2026-09-06T23-30.md`. This artifact is written by the `--cov-report=lcov:artifacts/python/lcov.info` entry of the project `addopts`, so it reflects the P4-T4 run. Acceptance: the recorded zero-hit list contains none of 196, 198, 202, 210, or 215.

- [x] [P4-T6] Formatting, TypeScript. Run from `extensions/drm-copilot`: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-format.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the output contains `All matched files use Prettier code style!`.

- [x] [P4-T7] Linting, TypeScript. Run from `extensions/drm-copilot`: `npm run lint`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-lint.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and no recorded line contains the text `warning`, for the reason stated in P0-T9.

- [x] [P4-T8] Type checking, TypeScript. Run from `extensions/drm-copilot`: `npm run typecheck`. Record the outcome in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-typecheck.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0` and the recorded output is empty apart from the npm script banner.

- [x] [P4-T9] Unit tests and coverage, TypeScript. Run from `extensions/drm-copilot`: `npm run test:coverage`. Record, in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-unit-coverage.2026-09-06T23-30.md`: the suite and test counts, the `Statements`, `Branches`, `Functions`, and `Lines` lines of the printed coverage summary, and from the `SF:` record of `extensions/drm-copilot/coverage/lcov.info` whose value ends with the file name `orchestration-handoff-materializer.ts`, written with the platform separator as `src\lib\validate\orchestration-handoff-materializer.ts`, the `LF:`, the `LH:`, and the ascending list of zero-hit `DA:` line numbers, together with the line number on which the text `private stageMaterialization(` occurs in `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`. Acceptance: `EXIT_CODE: 0`, zero failed tests, the test count is at least the count recorded in P0-T11 plus seven, the summary `Lines` percentage is at least the exact percentage recorded in P0-T11, the summary `Branches` percentage is at least the exact percentage recorded in P0-T11, and no zero-hit `DA:` line number for that module is greater than or equal to the recorded `private stageMaterialization(` line number.

- [x] [P4-T10] PowerShell no-regression surface. Invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the workspace root and no other argument. Read the numbers from the same two result artifacts named in P0-T12, using the same report-level `LINE` counter that task names, because the tool itself prints no counts and no coverage percentage. Record the MCP result verbatim, the total, passed, failed, errored, and skipped counts, and the `LINE` covered, missed, total, and percentage values in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-unit-coverage.2026-09-06T23-30.md`, with an explicit comparison against P0-T12. Acceptance: the root `testsuites` element of `artifacts/pester/pester-junit.xml` carries `failures="0"` and `errors="0"`, and the `LINE` percentage is at least the exact percentage recorded in P0-T12. No PowerShell file is changed by this plan, so an unchanged figure satisfies the floor.

- [x] [P4-T11] Architecture boundary and file size. Run `Get-ChildItem -LiteralPath extensions/drm-copilot/src -Recurse -File -Filter *.ts | Select-String -Pattern 'from\s+\S*dev_tools'`, then `Get-ChildItem -LiteralPath extensions/drm-copilot/src -Recurse -File -Filter *.ts | Select-String -Pattern 'require\(\S*dev_tools'`, then `Get-ChildItem -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts, tests/scripts/dev_tools/test_orchestration_handoff_adapters.py, tests/scripts/dev_tools/test_orchestration_handoff_contract.py | ForEach-Object { "$($_.Name) $((Get-Content -LiteralPath $_.FullName).Count)" }`, adding `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` to that `-LiteralPath` list, as a sixth enumerated path, only when P1-T1 created it under the section 3.1 overflow rule. The first two searches are scoped to module specifiers rather than to bare text: `extensions/drm-copilot/src` legitimately carries `scripts/dev_tools` and `scripts.dev_tools` in parity comments and in the push-down reference table at `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts`, so a bare text search matches those and can never return no match, while a forbidden `import ... from "…/dev_tools/…"` or `require("…/dev_tools/…")` is matched by these two patterns. This is the same boundary the earlier cycle recorded in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-architecture-and-structure.2026-09-03T00-07.md`. The recursive `Get-ChildItem` form is required because `Select-String -Path` does not expand a `**` segment. Record all three outputs in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/architecture-and-file-size.2026-09-06T23-30.md`. Acceptance: both module-specifier searches return no match, and each recorded line count — the five named paths, plus the conditional sixth path when P1-T1 created it under the section 3.1 overflow rule — is at most 500.

- [x] [P4-T12] Contract, schema, and fixture identity. Run `git diff --exit-code a7b80f2df6d849aa65de416655fa58beb4412998 -- config/orchestration-handoff.schema.json config/orchestration-handoff-registry.json extensions/drm-copilot/resources/config tests/fixtures/orchestration-handoff extensions/drm-copilot/jest.config.cjs .codex/hooks scripts/dev_tools`, and `git status --porcelain=v1 --untracked-files=all -- config tests/fixtures/orchestration-handoff .codex/hooks scripts/dev_tools`. Record both in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/contract-schema-and-fixture-identity.2026-09-06T23-30.md`. Acceptance: the diff exits 0, proving that the schema, both registry copies, every fixture, the jest configuration, the Codex hooks, and every Python production module are byte-identical to `a7b80f2d`; and the status command prints no row.

- [x] [P4-T13] Integration and installed-consumer parity, under the section 1.4 precondition. Run `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and record the result and the four `.claude` precondition observations in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/integration-parity.2026-09-06T23-30.md`. Acceptance: `EXIT_CODE: 0`, zero failed tests, and byte-identical before and after `git status --porcelain=v1 --untracked-files=all -- .claude` observations.

- [x] [P4-T14] Final scope boundary. Run `git status --porcelain=v1 --untracked-files=all`, then `git diff --name-only a7b80f2df6d849aa65de416655fa58beb4412998`, then `git diff --name-only 1ed0964045febbb4d92f1cb92661d4b945153a40`. Record all three outputs in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/final-scope-boundary.2026-09-06T23-30.md`, with every status row classified against the table in section 1.3. Acceptance: the second command lists exactly these five paths and nothing else: `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`, `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`, and `tests/scripts/dev_tools/test_orchestration_handoff_contract.py`. `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` are named in section 1.1 but are absent from this list by design: no task changes the first, and P3-T5 returns the second to its `a7b80f2d` content. The list carries `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py` as a sixth path only when P1-T1 created that module under the section 3.1 overflow rule, and then only once it has been staged, because an untracked file is invisible to `git diff --name-only`; unstaged, it appears instead as a `??` row of the first command's output and is classified there. When the section 3.1 overflow rule did not apply, the third command's output is byte-identical to the merge-base diff recorded in P0-T2, because all five authorized paths were already introduced by this branch. When that rule applied and the new module has not been staged, the output is likewise byte-identical, because an untracked file is invisible to this form as well. When that rule applied and the module has been staged, the output is that same list plus the single row `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py`, because a staged new file is reported by a diff taken against a commit; no other difference is permitted. Every status row is assigned to class A, C, D, or E, with no row assigned to class B and no unclassified row.

- [x] [P4-T15] Acceptance-criteria reconciliation. Write `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/acceptance-reconciliation.2026-09-06T23-30.md` recording, for each of SPEC-AC4, SPEC-AC5, SPEC-AC10, SPEC-AC11, US-3, and US-10, the checkbox state now present in `spec.md` or `user-story.md`, the evidence artifact path that supports it, and the section 2 mapping row. Run `Select-String -LiteralPath docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md -Pattern '- [ ] AC' -SimpleMatch -CaseSensitive` and record its output. Acceptance: the search returns no match, so every numbered `spec.md` acceptance criterion from AC1 through AC15 is checked; and each of the six identifiers carries an evidence path that exists on disk. `-CaseSensitive` is required rather than optional: `Select-String` is case-insensitive by default, and `spec.md` line 383 begins `- [ ] Acceptance criteria in both`, which a case-insensitive search for `- [ ] AC` matches. Under `-CaseSensitive` the search is scoped to the uppercase `AC` prefix, which correctly excludes the unchecked definition-of-done and test-plan list at lines 383 through 412; those twelve rows begin `Acceptance`, `Bidirectional`, `Schema`, `Unsupported`, `Provider`, `Structured`, `The`, `Schema`, `Hook`, `Published`, `End-to-end`, and `Parallel`, and none of them is an acceptance criterion or in this plan's scope.

---

## 5. Evidence index

| Kind | Directory |
|---|---|
| Baselines (Phase 0) | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/` |
| Red and targeted runs (Phases 1-3) | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/` |
| Acceptance-criteria update (Phase 3) | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/` |
| Final QA gates (Phase 4) | `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/` |

No commit, staging, push, or pull-request task is included in this plan. Task counts: Phase 0 has
twelve tasks, Phase 1 has two, Phase 2 has two, Phase 3 has five, and Phase 4 has fifteen, for a
total of thirty-six.
