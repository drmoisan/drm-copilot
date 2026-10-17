# plan-validator-accepts-bare-scratch-paths (Spec)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Research:** `research/2026-10-15T19-52-bare-scratch-plan-gate-research.md` (authoritative). The copy named `research/bare-scratch-plan-gate.2026-10-15T19-52.md` is a stale duplicate and is not an input.

> Authoring note: every literal example of an unnamespaced SCRATCH definition in this document is placed inside a fenced code block. G10 skips fenced blocks, so this document and any plan that quotes it do not define SCRATCH in the bare form.

## Problem Statement

Issue #900 (PR #922) introduced a scratch-location rule: every plan that uses scratch files must point the `SCRATCH` token at a per-issue directory, `<session scratchpad>/issue-<issue-num>/`, so that concurrent child runs in one session do not collide. The rule is stated in the atomic-planner and atomic-executor personas and skills, but it has no plan-preflight enforcement:

1. A plan that defines `SCRATCH` as the bare session scratchpad passes the plan validator (`validate_orchestration_artifacts.py` and the TypeScript MCP port). The only remaining safeguard is the executor-side reinterpretation rule.
2. The guard test `tests/scripts/dev_tools/test_scratch_location_contracts.py` relies on `FORBIDDEN_SCRATCH_PATHS`, a fixed denylist of six literals. It cannot detect any other bare form and has never been shown to fail on one (the #900 code review recorded this gap).
3. The Codex agent definitions (`.codex/agents/atomic-planner.toml`, `.codex/agents/atomic-executor.toml`, their variants, and the bundle copies) do not carry the `## Scratch Location` section at all.

Root cause: the existing plan-acceptance gates G1 through G9 evaluate only commands attributed to a task (`P#-T#`). A SCRATCH definition is prose in a plan preamble or terms list, which the command extractor drops (`plan_gate_commands.py:355-356`). No document-level rule exists, and adding one required an operator-approved edit to `.claude/rules/plan-acceptance-gates.md`. That approval has been granted for this item.

Expected behavior: plan preflight rejects a SCRATCH definition that is not namespaced by issue number.

## Scope

### In scope

- A new plan-acceptance gate, **G10**, on the Blocking channel, context-free and document-level, implemented in:
  - `scripts/dev_tools/plan_gate_scratch.py` (Python authority), and
  - `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (TypeScript twin),
  - called from `evaluate_plan_gates` in `scripts/dev_tools/plan_gate_discrimination.py` and `evaluatePlanGates` in `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`.
- Unit, parity, dispatcher, CLI, and MCP-service tests for G10 in both runtimes, and a jest per-file coverage threshold entry for the new TypeScript module.
- Replacement of the `FORBIDDEN_SCRATCH_PATHS` literal denylist in `tests/scripts/dev_tools/test_scratch_location_contracts.py` with a pattern check that reuses the production G10 detector plus a scratchpad-root regex, and a parametrized self-test that demonstrates failure on bare forms.
- Addition of the `## Scratch Location` section to the Codex atomic-planner and atomic-executor agent definitions, their generated variants, and their bundle copies, and registration of the two base TOMLs as rule sources in the scratch contract test.
- Policy documentation updates (operator-approved for this item):
  - `.claude/rules/plan-acceptance-gates.md` and its byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`.
  - `.claude/skills/atomic-plan-contract/SKILL.md` and its byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` (shipped-set sentence only; a related fix inside this item).
- Docstring and JSDoc corrections in `plan_gate_discrimination.py` and `plan-gate-discrimination.ts` that describe the gate set and the context-free Blocking list.

### Out of scope / non-goals

- Editing any historical committed plan or remediation plan. Committed plans that define SCRATCH in the bare form remain as they are; no CI job, test, or hook validates committed plans.
- Checking that the issue number in a namespaced definition matches the plan's own issue (recorded as a known false-negative class).
- Detecting `SCRATCHPAD`, `<SCRATCHPAD>`, or `<SCRATCH>` tokens, or root paths written under those tokens, in plans (recorded as a known false-negative class).
- Detecting a SCRATCH definition that is made by reference to another plan, or a definition placed inside a fenced code block (known false-negative classes).
- Changes to `validate_orchestration_artifacts.py`, `plan_gate_observability.py`, `plan-gate-observability.ts`, `.github/**`, `.agents/skills/atomic-plan-contract/SKILL.md`, or the Codex pack manifests.
- Rebuilding or reinstalling the VS Code extension so that the installed MCP tool enforces G10. That is a release step outside this item.
- Running `generate_codex_agent_variants` in write mode. Variant consistency is verified through its `--check` mode.

## Functional Requirements

- **FR-1 (G10 gate).** The plan validator reports one Blocking finding for each logical line of a plan that matches the G10 definition predicate and does not carry an accepted namespace.
- **FR-2 (context-free).** G10 runs whether or not a `PlanGateContext` / plan-gate context is supplied. Its findings are identical in both cases, and therefore reach `validate_plan_text`, `validate_plan_text_with_warnings`, the Python CLI, `validateArtifactWithWarnings`, and the MCP service call.
- **FR-3 (severity constant).** Each runtime declares a module-level G10 severity constant: Python `G10_SEVERITY = BLOCKING_CHANNEL`; TypeScript `G10_SEVERITY: string = "blocking"`. Channel placement follows the constant.
- **FR-4 (module layout).** The Python module declares its own channel constants (following the `plan_gate_observability.py` precedent) and imports report types under `TYPE_CHECKING` only, so the import graph stays acyclic. It exposes a pure function `bare_scratch_definitions(text) -> list[tuple[int, str]]` and `evaluate_scratch_gate(report, text)`. The TypeScript module exposes `G10_SEVERITY`, `bareScratchDefinitions`, and `evaluateScratchGate`, imports only types from `plan-gate-rules.ts`, and is re-exported from `plan-gate-discrimination.ts`.
- **FR-5 (shared detector).** The scratch contract test imports `bare_scratch_definitions` from the production Python module, so the plan gate and the normative-surface scan use one detector.
- **FR-6 (Codex parity of the rule).** The Codex atomic-planner and atomic-executor agent definitions state the same `## Scratch Location` rule text as `.claude/agents/atomic-planner.md` and `.claude/agents/atomic-executor.md`, placed with the same anchors (planner: between `## Requirements` and `## Preflight Validation`; executor: between `## Toolchain Commands` and `## Preflight Validation`).
- **FR-7 (policy documentation).** The rule file states G10, its severity rationale, its message-prefix exception, the shipped set G1 through G10, its enforcement surfaces, and its known false-negative classes.

## G10 Detection Contract

### Logical lines

1. Lines inside fenced code blocks are skipped. Fence recognition uses the same fence regex as the command extractor (`_FENCE_RE` in `plan_gate_commands.py`, `^\s*` followed by three backticks) and its TypeScript equivalent.
2. A logical line is a non-fenced physical line plus each immediately following physical line that is non-blank and begins with whitespace. Continuation stops at a fence line (an indented fence included) and at any line that does not begin with whitespace; a Markdown ATX heading or task line written at column 0 therefore ends the logical line, and an indented heading or task line is absorbed into it.
3. The reported line number is the 1-based physical line number of the first line of the logical line.
4. The logical line is normalized for matching and for the message by joining each run of the shared whitespace class defined in item 6 with a single space and trimming the ends. The continuation test in item 2 uses the same class, and both runtimes declare that class with an identical pattern string, so they produce byte-identical text.
5. Physical lines are split on the CR LF, LF, and CR terminators only, in both runtimes and in the command extractor (remediation cycle 1).
6. The blank-line test, the continuation test, and whitespace normalization use one explicit whitespace class, `PLAN_WHITESPACE_CLASS`, with an identical pattern string in both runtimes: tab, line feed, vertical tab, form feed, carriage return, space, the Unicode space separators, and the Unicode line and paragraph separators. NEL, the information separators, and the byte-order mark are not whitespace for these tests. The fence test keeps the command extractor's pattern (item 1) (remediation cycle 2).

### Predicate

Step 1, definition match. The same pattern is used in both runtimes. It contains no lookbehind, so the Python and JavaScript regex dialects agree:

```text
(?:^|[^A-Za-z0-9_<>$/.-])`?SCRATCH`?(?:\*\*)?[ \t]*(?:means\b|:=|=|:|is (?:the|a|an)\b|resolves to\b|abbreviates\b|denotes\b|refers to\b|stands for\b)
```

- The preceding-character class excludes word characters, `<`, `>`, `$`, `/`, `.`, and `-`. As a result `<SCRATCH>`, `$SCRATCH`, `SCRATCHPAD`, `X_SCRATCH`, and path usage such as `SCRATCH/x` never match.
- The connector `is` matches only as `is the`, `is a`, or `is an`, so property statements such as "SCRATCH is never committed" do not match.

Step 2, namespace accept. The logical line is accepted when the text after the definition match contains:

```text
issue-(?:<issue-num>|[0-9]+)
```

This accepts the `issue-<issue-num>` placeholder, a concrete `issue-<digits>` segment, and the run-unique `issue-<n>-<yyyy-MM-ddTHH-mm>` form (which begins with an accepted prefix). A bare-digit segment such as `889/` is not accepted.

Step 3, finding. A logical line that matches Step 1 and is not accepted by Step 2 produces exactly one G10 finding, regardless of how many definition matches it contains.

### Examples: accepted (no finding)

```text
- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`.
- `SCRATCH` means `<session scratchpad>/issue-900/`.
- `SCRATCH` = `<session scratchpad>/issue-932-2026-10-15T19-52/`.
```

### Examples: rejected (one finding each)

These reproduce the corpus forms recorded in the research (forms A through E and G):

```text
- SCRATCH means the executor's session scratchpad directory, outside the repository.
SCRATCH is the session scratchpad outside the repository.
- `SCRATCH` = the executor session scratchpad directory
- `SCRATCH` = the `889/` subdirectory of the session scratchpad
**SCRATCH:** `SCRATCH` abbreviates the absolute directory `<executing worktree root>/SCRATCH`
- SCRATCH := <session scratchpad>
- SCRATCH means the session scratchpad and is never
  committed to the repository.
```

The final two-line example is one logical line and produces one finding reported against its first physical line.

### Examples: not definitions (no finding)

```text
Write the report to SCRATCH/932/cov.txt.
SCRATCH is never committed.
Redacted path: <SCRATCH>/x and <SCRATCHPAD>/derive-worklists.ps1
`SCRATCHPAD` = the session scratchpad root
echo "$SCRATCH"
```

A definition that appears only inside a fenced code block in a plan is also not reported.

## Error Message Contract

Each G10 finding is exactly:

```text
Line {n}: SCRATCH definition `{normalized logical line}` is not namespaced by issue number; define SCRATCH as `<session scratchpad>/issue-<issue-num>/`.
```

- `{n}` is the 1-based first physical line number of the logical line.
- `{normalized logical line}` is the normalized logical line from the detection contract, rendered between backticks verbatim. No `repr()`, `!r`, or `pythonRepr(` formatting is used; an apostrophe in the line appears unescaped.
- The string is byte-identical in Python and TypeScript for the same input.
- The finding uses the `Line N: ` prefix rather than the `[P#-T#] ` prefix that G1 through G9 use, because a SCRATCH definition sits outside any task window. This matches the structural-error prefix in the same error channel and is documented as an explicit exception in the rule file.
- Through the Python CLI, a G10 finding is printed as an error and the process exits 1. Through the MCP service call, a G10 finding causes the call to throw with the message included.

## Severity Governance

- G10 ships on the Blocking channel.
- The plan for this item writes down, before its corpus-measurement task, the two-conjunct decision rule used for G5 through G9 (Blocking if and only if the measurement records findings > 0 and false positives = 0) and the false-positive definition it applies (a flagged logical line that is not a SCRATCH definition, or that defines SCRATCH in the canonical issue-namespaced form).
- The plan's measurement result (finding count and false-positive count over the committed plan corpus) is recorded as evidence under the feature folder's `evidence/` tree.
- The rule file's G10 severity subsection records both the measurement and the fact that severity was also set by operator-approved scope for issue #932, because the research observed the corpus before the measurement was taken.
- The corpus counts are not fixed in this specification; the corpus changes with every merged plan.

## Acceptance Criteria

### G10 implementation (Python)

- [x] `scripts/dev_tools/plan_gate_scratch.py` exists and exposes `G10_SEVERITY`, `bare_scratch_definitions`, and `evaluate_scratch_gate`; `G10_SEVERITY` equals the module's `BLOCKING_CHANNEL`. Verified by `tests/scripts/dev_tools/test_plan_gate_scratch.py::test_g10_severity_is_blocking`.
- [x] `bare_scratch_definitions` returns no finding for the accepted forms in the detection contract (placeholder `issue-<issue-num>`, concrete `issue-<digits>`, run-unique `issue-<n>-<yyyy-MM-ddTHH-mm>`). Verified by the parametrized `test_plan_gate_scratch.py::test_bare_scratch_definitions_accepts_namespaced_forms`.
- [x] `bare_scratch_definitions` returns exactly one finding for each rejected form in the detection contract, including the backticked, bold, `:=`, `=`, `:`, and bare-digit (`889/`) variants. Verified by the parametrized `test_plan_gate_scratch.py::test_bare_scratch_definitions_flags_unnamespaced_forms`.
- [x] `bare_scratch_definitions` returns no finding for the non-definition forms in the detection contract (`SCRATCH/<path>` usage, "SCRATCH is never committed", `<SCRATCH>`, `SCRATCHPAD`, `<SCRATCHPAD>/<name>`, `$SCRATCH`) or for a bare definition inside a fenced code block. Verified by the parametrized `test_plan_gate_scratch.py::test_bare_scratch_definitions_ignores_non_definitions`.
- [x] A bare definition wrapped across a bullet and an indented continuation line yields one finding whose line number is the first physical line, and continuation stops at a heading, fence, or task line. Verified by `test_plan_gate_scratch.py::test_wrapped_definition_reports_first_line` and `test_plan_gate_scratch.py::test_logical_line_stops_at_heading_fence_and_task_line`.
- [x] The G10 message equals the frozen string in the error message contract for fixtures that include an apostrophe and a tab character. Verified by `test_plan_gate_scratch.py::test_g10_message_matches_frozen_string`.
- [x] `evaluate_plan_gates` in `plan_gate_discrimination.py` places G10 findings in `report.blocking` both with and without a context, and the G10 findings are identical in both cases. Verified by `test_plan_gate_scratch.py::test_evaluate_plan_gates_reports_g10_with_and_without_context`.
- [x] Running `validate_orchestration_artifacts.main` on a plan containing a bare SCRATCH definition exits 1 and prints the `Line N:` G10 message; the same plan with a namespaced definition produces no G10 finding. Verified by `test_plan_gate_scratch.py::test_cli_rejects_bare_scratch_definition` and `test_plan_gate_scratch.py::test_cli_accepts_namespaced_scratch_definition`.

### G10 implementation (TypeScript)

- [x] `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` exists, exports `G10_SEVERITY: string = "blocking"`, `bareScratchDefinitions`, and `evaluateScratchGate`, and is re-exported from `plan-gate-discrimination.ts`. Verified by `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`.
- [x] `plan-gate-scratch.test.ts` covers the same accepted, rejected, non-definition, wrapped-line, and fenced fixtures as the Python suite and asserts the same frozen G10 message strings.
- [x] `evaluatePlanGates` places G10 findings in the Blocking list with and without a context, `validateArtifactWithWarnings` returns the G10 message as an error for a plan with a bare definition, and the MCP service call in `validate-orchestration-service-call.ts` throws with the G10 message included. Verified by named cases in `plan-gate-scratch.test.ts` (dispatcher level) and the validate-orchestration service-call test suite (throw path).

### Parity and coverage configuration

- [x] `test_plan_gate_scratch.py::test_g10_severity_constant_matches_typescript` passes, asserting that the TypeScript `G10_SEVERITY` literal equals the Python constant.
- [x] `plan_gate_scratch.py` is listed in `_PYTHON_GATE_MODULES` in `tests/scripts/dev_tools/test_plan_gate_parity.py`, and `test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages` passes.
- [x] `plan-gate-scratch.ts` is listed in the module list scanned by the no-`pythonRepr(` check in `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`, and that test passes.
- [x] `extensions/drm-copilot/jest.config.cjs` contains a per-file `coverageThreshold` entry for `./src/lib/validate/plan-gate-scratch.ts` with 85% lines and 75% branches.

### Scratch contract test

- [x] `FORBIDDEN_SCRATCH_PATHS` no longer exists in `tests/scripts/dev_tools/test_scratch_location_contracts.py`, and the normative-surface scan applies the production `bare_scratch_definitions` detector and the scratchpad-root regex (a `<...scratchpad...>/` segment not followed by `issue-`) to every normative surface. Verified by the passing scan test in that file.
- [x] A parametrized self-test in `test_scratch_location_contracts.py` shows that the pattern check flags `<scratchpad>/run-ps.sh`, `<SCRATCHPAD>/derive-worklists.ps1`, and a bare SCRATCH definition, and accepts `<session scratchpad>/issue-<issue-num>/run-ps.sh`.
- [x] `.codex/agents/atomic-planner.toml` and `.codex/agents/atomic-executor.toml` are listed in `RULE_SOURCES`, `.codex/agents/atomic-executor.toml` is listed in `EXECUTOR_SOURCES`, and the rule-statement, forbidden-shape, placement, and pre-rule-plan tests in `test_scratch_location_contracts.py` pass for those entries.

### Codex agent definitions

- [x] `.codex/agents/atomic-planner.toml` and `.codex/agents/atomic-executor.toml` contain the `## Scratch Location` section text from `.claude/agents/atomic-planner.md` and `.claude/agents/atomic-executor.md` respectively, at the anchors stated in FR-6.
- [x] Every generated variant and bundle copy of the atomic-planner and atomic-executor Codex families matches generator output. Verified by `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` passing, including its `--check` (no drift) case.
- [x] The Codex parity and schema suites pass: `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_codex_agent_role_schema.py`, and `test_push_down_codex_and_agents_resource_contracts.py`.

### Policy documentation

- [x] `.claude/rules/plan-acceptance-gates.md` contains a G10 row in the rule table, a G10 subsection under `## Severity Decisions` that states the two-conjunct decision rule, the measurement result, and the operator-approved scope for issue #932, an explicit exception to the `[P#-T#]` prefix statement for the G10 `Line N:` prefix, a shipped-set statement naming G1 through G10, G10 in the `## Enforcement` section, and G10 known false-negative classes (wrong issue number, `SCRATCHPAD`-family tokens, definition by reference, fenced definitions).
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` is byte-identical to the repository rule file, and `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy both state the shipped set as G1 through G10 and are byte-identical to each other. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing in CI.
- [x] The module docstring and the `evaluate_plan_gates` docstring in `plan_gate_discrimination.py`, and the `evaluatePlanGates` JSDoc in `plan-gate-discrimination.ts`, name the gate set through G10 and no longer state that the Blocking list is unchanged when no context is supplied.
- [x] `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` passes, confirming the rule file's `paths:` frontmatter reaches both new modules.

### Governance, scope, and quality

- [x] The plan for this item states the two-conjunct severity decision rule and the false-positive definition in a task that precedes its corpus-measurement task, and the measurement result is recorded under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/evidence/`.
- [x] The plan for this item passes plan validation with no G10 finding.
- [x] `git diff --name-only origin/main...HEAD` lists no plan or remediation-plan file outside this feature folder.
- [x] The Python toolchain passes in one pass on all changed Python files: `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` (strict), and `poetry run pytest` for the G10, parity, discrimination, observability-boundary, validate-orchestration-artifacts, scratch-contract, push-down, Codex, and rules-frontmatter suites.
- [x] The TypeScript toolchain passes in one pass from `extensions/drm-copilot/`: `npx prettier --check`, `npx eslint`, `npx tsc -p ./ --noEmit`, `npx tsc -p tsconfig.jest.json --noEmit`, and the full `npx jest --config jest.config.cjs --coverage` run.
- [x] Line coverage is at least 85% and branch coverage at least 75% for `scripts/dev_tools/plan_gate_scratch.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, and changed lines of `plan_gate_discrimination.py` and `plan-gate-discrimination.ts` show no coverage regression against the Phase 0 baseline. Python coverage is measured with dotted module names and `--cov-report=term-missing`; the figures are recorded under the feature folder's `evidence/qa-gates/`.
- [x] Every created or changed production, test, or script file is at most 500 lines, and no new or changed test creates a temporary file.

## Non-Functional Requirements

- **NFR-1 (determinism).** G10 is a pure function of the plan text. It reads no file, clock, environment variable, or git state.
- **NFR-2 (runtime parity).** For any input, the Python and TypeScript detectors return the same line numbers and byte-identical messages. The definition and namespace regexes use only constructs that behave identically in both dialects (no lookbehind).
  - Remediation cycle 1 to 3 note: line splitting is aligned on the CR LF, LF, and CR terminators in both runtimes, in the command extractor, and in the G6 cross-line check (cycle 2). The blank-line test, the continuation test, and whitespace normalization share one explicit whitespace class, `PLAN_WHITESPACE_CLASS`, with an identical pattern string in both runtimes (cycle 2), so NEL, the information separators, and the byte-order mark no longer produce different G10 results. G6 normalizes tracked lines, its sliding-window join, and the search literal with the same class, and the class and its normalizer are declared once per runtime in the command extractor module (cycle 3), so those characters no longer produce different G6 results either. The plan-quotation exoneration keeps each runtime's native class. The fence test keeps the command extractor's fence pattern, whose leading whitespace is each runtime's native class; that difference is shared with G1 through G9 and is documented in `.claude/rules/plan-acceptance-gates.md`.
- **NFR-3 (performance).** G10 runs in a single linear pass over the plan lines. It adds no measurable latency relative to the existing gates for plans of typical size.
- **NFR-4 (file size).** No production, test, or script file exceeds 500 lines. G10 lives in new sibling modules because `plan_gate_observability.py`, `plan-gate-observability.ts`, `validate_orchestration_artifacts.py`, and `test_plan_gate_parity.py` are close to that limit; G10 frozen strings and severity parity therefore live in `test_plan_gate_scratch.py`, and `test_plan_gate_parity.py` changes only its module list.
- **NFR-5 (quality tiers).** `scripts/dev_tools` is T4 and `extensions/drm-copilot` is T3 under `quality-tiers.yml`; no property or mutation tests are required. Coverage thresholds are 85% line and 75% branch, uniform.
- **NFR-6 (tone and paths).** All new prose follows the repository tonality policy. No artifact records an absolute host path; plans and evidence use the literal token `SCRATCH`.
- **NFR-7 (location independence).** Any reference to a prior item's feature folder (for example #900) accepts either `docs/features/active/` or `docs/features/archive/` as its location.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| The #932 plan flags itself by quoting bare definitions as fixture text. | Fixture text is placed in fenced blocks or referred to by test file; an acceptance criterion requires the plan to pass validation with no G10 finding. |
| In-flight plans with bare definitions fail re-validation during preflight or remediation. | The fix is a one-line definition edit inside a plan revision. The executor-side reinterpretation rule is unchanged. |
| The installed MCP tool keeps accepting bare definitions until the extension is rebuilt and reinstalled. | The Python CLI enforces G10 at merge; the TypeScript behavior is verified by jest. Rebuild is a separate release step. |
| Python and TypeScript detectors drift. | Frozen G10 message strings in both suites, a severity-constant regex test, shared fixtures, and the no-`repr` / no-`pythonRepr(` module lists. |
| G10 whitespace handling could differ between runtimes because the Python and JavaScript native whitespace classes differ on NEL, the information separators, and the byte-order mark. | G10 normalizes whitespace and detects continuation with one explicit shared whitespace class (detection contract item 6), declared with an identical pattern string in both runtimes and pinned by a parity test; frozen fixtures cover NEL, the unit separator (U+001F), the byte-order mark, and the no-break space. |
| A colon connector matches non-definition prose (for example, "the token SCRATCH" followed by a colon). | No corpus instance exists; the case is documented in the rule file as a possible false positive. |
| The local #510 gitignored-state failure appears in `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. | Accept only that known signature locally; the acceptance criterion is verified in CI. |
| Running the Codex generator in write mode on Windows rewrites the pack manifests with CRLF. | Apply identical Edit-tool insertions and verify with the generator's `--check` mode through pytest. |

## Known False-Negative Classes (documented, not fixed)

- A namespaced definition whose issue number differs from the plan's own issue.
- `SCRATCHPAD`, `<SCRATCHPAD>`, and `<SCRATCH>` tokens and root paths under them.
- A SCRATCH definition made by reference to another plan.
- A SCRATCH definition inside a fenced code block.
- Any `issue-<digits>` or `issue-<issue-num>` token after the definition match, including a cross-reference that is not the scratch location.

## References

- Issue #932: https://github.com/drmoisan/drm-copilot/issues/932 and `issue.md` in this folder.
- Research: `research/2026-10-15T19-52-bare-scratch-plan-gate-research.md` in this folder (Q1 through Q6, Recommended Approach, Risks, Candidate Write-Set).
- Origin of the rule: issue #900 / PR #922; feature folder `*-concurrent-children-share-scratchpad-file-names-900/` under `docs/features/active/` or `docs/features/archive/`, including `code-review.2026-10-12T17-38.md` and `feature-audit.2026-10-12T17-38.md`.
- Policy: `.claude/rules/plan-acceptance-gates.md`; `.claude/skills/atomic-plan-contract/SKILL.md`; `.claude/agents/atomic-planner.md` and `.claude/agents/atomic-executor.md` (`## Scratch Location`).
- Code: `scripts/dev_tools/plan_gate_commands.py`, `scripts/dev_tools/plan_gate_discrimination.py`, `scripts/dev_tools/validate_orchestration_artifacts.py`, `scripts/dev_tools/generate_codex_agent_variants.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`, `orchestration-artifacts.ts`, `validate-orchestration-service-call.ts`.
- Tests: `tests/scripts/dev_tools/test_scratch_location_contracts.py`, `test_plan_gate_parity.py`, `test_generate_codex_agent_variants.py`, `test_push_down_claude_resource_contracts.py`; `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`.
