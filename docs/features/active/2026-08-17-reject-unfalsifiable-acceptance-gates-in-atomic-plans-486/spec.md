# 2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans — Spec

- **Issue:** #486
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-17T18-15
- **Status:** Ready for Planning
- **Version:** 1.0

## Overview

Atomic plans express acceptance criteria as concrete shell commands. Some of those commands produce the same result whether or not the work was done, so the gate does not discriminate between a completed task and an untouched one. A gate that cannot fail provides no verification; a gate that cannot pass produces a false blocking finding. Both are invisible at authoring time, because the command is syntactically valid and runs without error.

The #479 preflight run made the cost concrete. It required three iterations and produced 13 blocking findings, of which at least two were defects in the gates rather than in the code under review, and one plan assertion was empirically disproved by the executor. Each such gate consumes a full preflight iteration before anyone can determine that the code was never the problem.

Three failure modes are confirmed:

- **Phrase-wrapping greps.** An acceptance grep searches for a multi-word phrase that exists in the source but wraps across a line boundary, or is broken by formatter-inserted wrapping. `git grep` matches within a single line, so the search returns zero matches regardless of whether the phrase is present in the file.
- **Interpolated-literal greps.** An acceptance grep searches for an error message that the source constructs through f-string interpolation. The literal never appears contiguously in the source, so the search returns zero matches regardless of whether the message is produced at runtime.
- **Path-form coverage thresholds.** A plan asserted a per-file coverage threshold using a `--cov` value that names a filesystem path rather than an importable module. The executor established empirically that this form collects no coverage data at all. The reported figure is therefore not a measurement of the named file, and the threshold is unenforceable.

The common property is that the command's output is invariant with respect to the state of the work. Whether that surfaces as a false pass or a false blocking finding depends only on which direction the acceptance condition points.

This feature adds mechanical detection of that invariance to the existing mandatory plan-acceptance gate, so the defect is caught before execution rather than after preflight has consumed iterations. It does not judge whether a gate tests the right thing.

## Behavior

The check runs unconditionally inside the existing `plan` artifact-type route. It extracts acceptance commands from the plan document, attributes each to a plan task identifier, and evaluates a fixed rule set. Each finding carries a severity: **Blocking** findings fail the gate; **Warnings** are surfaced to the author and do not fail the gate.

### Command extraction and attribution

- Commands are carried as Markdown inline code spans, both on task title lines and on `- Acceptance…:` continuation bullets. Fenced code blocks are also scanned; they are rare but not excluded.
- A command is attributable to `P#-T#` if and only if it appears on a task line matching the canonical task regex, or on a subsequent line that is not itself a task line and that is not separated from the task line by an intervening Markdown heading (`^#{1,6} `). Commands in the document preamble, in a phase preamble, or in trailing sections are **not analysed at all**. They cannot name a task identifier, and attributing them to a neighbouring task would produce exactly the class of misdirected finding this feature exists to prevent.
- Extraction hazards are handled by silent skip, never by analysing a truncated remainder:
  - A code span truncated by an inner backtick yields unbalanced quoting; the command is skipped.
  - A command with no pattern operand (a bare fragment used as prose, such as `` `grep -r` ``) is skipped.
  - Word splitting uses a POSIX-style shell-word splitter that handles double quotes, single quotes, and backslash escapes. A regex-only splitter is insufficient.
- The extractor is a reusable module returning a command value object; see [Deferred Dependency](#deferred-dependency--expected-exit-code-out-of-scope).

### Rule set

Rule identifiers are the research identifiers G1 through G6 so that the plan, the tests, and the feature audit can cite them without ambiguity.

| ID | Rule | Severity | Repository context required |
|---|---|---|---|
| G1 | `--cov=<value>` where `<value>`, truncated at the first `::`, ends in `.py`, and contains no placeholder or interpolation marker | Blocking | no |
| G2 | `--cov=<value>` containing a path separator, where `<value> + ".py"` is a tracked file | Blocking | yes |
| G3 | `--cov=<value>` containing a path separator that resolves to neither a tracked file nor a tracked directory | Warning | yes |
| G4 | `--cov` supplied with a space-separated value rather than `--cov=<value>` | Warning | no |
| G5 | Checkable search literal absent from the tracked tree **and** absent from the plan document text | Blocking or Warning, fixed by measurement (see below) | yes |
| G6 | Checkable search literal present only in the whitespace-normalised join of adjacent lines, on no single line, and not quoted contiguously in the plan document | Warning | yes |
| — | Word-count wrap heuristic | not shipped (see Non-Goals in `user-story.md`) | — |

`--cov` values are accepted without a finding when they are a dotted module or package name, a tracked directory, `.`, an empty value, or when they contain a placeholder or shell-interpolation marker (`<`, `>`, `${`, `$(`, `%`).

### Checkable literal definition

A search pattern is a *checkable literal* only when either the command carries `-F`, or the pattern contains none of `. * [ ] ^ $ \ ( ) { } | + ?`. This condition is conservative in POSIX BRE, POSIX ERE, PCRE, and the Rust regex dialect simultaneously, so no dialect-selection logic is required. Every other pattern is skipped silently. Matching is delegated to `git grep -F -l` over the whole tracked tree through an injected command runner; the check never reimplements matching, because a matcher that disagrees with the command under validation would create the same defect class the feature exists to remove. The command's own pathspec is deliberately ignored: presence of the literal anywhere in the tree exonerates the pattern.

### G5 severity is fixed by a pre-declared measurement

The research pass could not measure G5's false-positive rate (it was read-only). Shipping G5 as Blocking without that measurement risks creating exactly the false-rejection generator the issue warns against. The rule is therefore pre-declared so the outcome is deterministic and not a judgement call at implementation time:

> The implementation runs G5 against the acceptance-line grep commands in the committed plan corpus, records the true-positive and false-positive split in an evidence artifact under `<FEATURE>/evidence/qa-gates/`, and ships **G5 as Blocking if and only if the total G5 finding count is greater than 0 and the measured false-positive count is 0** (the two-conjunct rule). Otherwise G5 ships as a Warning.

A false positive is a G5 finding on a command whose literal the plan instructs the executor to create, expressed in paraphrase rather than quotation.

**Deviation note (remediation cycle 1, issue #486, R2).** The one-conjunct wording above ("Blocking if and only if the measured false-positive count is 0") did not account for the vacuous zero-finding case: a false-positive count of 0 over a total G5 finding count of 0 measures nothing, because there are no findings to have been miscategorized either way. Plan task `[P5-T3]` implemented, and the measurement artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` recorded, the two-conjunct rule stated above — Blocking requires both a non-zero total finding count and a zero false-positive count — which is correct and was shipped unchanged; only this spec paragraph required reconciliation to match the shipped rule.

### G6 ships as a Warning (deliberate, revisitable)

The research recommends G6 as Blocking, and the argument is recorded here in full because it is sound: cross-line presence is decidable and exact. Normalising runs of whitespace across a sliding window of at most four adjacent non-blank lines and finding the literal in the window join but on no single line is a *proof* that the command as written returns zero matches against the current tree, and it carries an exact remedy (search a shorter single-line token). The research also records the residual false-positive case: a task that rewrites exactly the wrapped line so the literal becomes contiguous, without quoting the resulting text in the plan, is falsely rejected.

The issue's own constraint states that the wrapping case "may only be reportable as a warning, not a rejection." That constraint is binding and overrides the research recommendation. **G6 ships as a Warning.** The Blocking argument and its residual false-positive case are recorded here so a later feature can revisit the severity with measured evidence rather than re-deriving the analysis.

## Inputs / Outputs

- **Inputs**
  - The plan document text. This is the validator's only mandatory input and its signature today.
  - An optional repository context object `{ workspace_root, file_system, git }`, mirroring the existing `EpicReadinessContext` shape. The `git` member is a protocol-typed adapter backed by an injected command runner; unit tests supply a stub.
  - CLI: a new `--workspace-root` option on the `plan` subparser, defaulting to `.`, mirroring the existing `epic-planner-state` subparser. No other CLI flag is added.
  - MCP: no new parameter. The `plan` route begins using the `artifactPath`, `fs`, `root`, and `runner` values that `validate-orchestration-service-call.ts` already passes into `validateArtifact` on every route and that the `plan` case currently discards.
- **Outputs**
  - Blocking findings, appended to the existing plan-validator error list.
  - Warnings, carried on a separate channel (see Data & State).
  - An evidence artifact under `<FEATURE>/evidence/qa-gates/` recording the G5 corpus measurement described above.
- **Config keys and defaults**
  - None. There is no configuration file, no severity override switch, and no exemption list. Severity is fixed in code by this specification.
- **Versioning and backward compatibility**
  - The seven existing plan-validator error strings are unchanged in text and in emission order.
  - `validate_plan_text(text)` and `validatePlanText(text)` keep their existing signatures and their existing return type, and return only errors.
  - The MCP tool input schema for `validate_orchestration_artifacts` is unchanged; no property is added and `additionalProperties: false` is untouched.
  - No new `artifact_type` value is introduced.

## API / CLI Surface

### Python

- New module `scripts/dev_tools/plan_gate_discrimination.py`, exposing:
  - `extract_plan_commands(text) -> list[PlanCommand]` — the reusable extractor.
  - `evaluate_plan_gates(text, *, context=None) -> PlanGateReport`, where `PlanGateReport` carries `blocking: list[str]` and `warnings: list[str]`.
- `scripts/dev_tools/validate_orchestration_artifacts.py`:
  - `validate_plan_text(text)` — signature and return type unchanged; returns existing structural errors plus G-rule Blocking findings.
  - `validate_plan_text_with_warnings(text, *, context=None) -> tuple[list[str], list[str]]` — new; returns `(errors, warnings)`. `validate_plan_text` delegates to it and returns element 0.
  - `main` prints error lines to stderr exactly as today, then prints each warning to stderr on its own line prefixed with the stable token `PLAN GATE WARNING: `. The exit code is derived from the error list alone.
- Example:

  ```text
  $ poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/.../plan.md
  [P3-T4] --cov argument `scripts/dev_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.
  # exit 1
  ```

  ```text
  $ poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/.../plan.md
  PLAN GATE WARNING: [P2-T1] search literal `only after every cohort` is present only across adjacent lines of a tracked file and matches no single line; a line-oriented search returns zero matches. Search a shorter single-line token.
  plan validation passed: docs/features/.../plan.md
  # exit 0
  ```

### TypeScript

- New module `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`, exposing `extractPlanCommands` and `evaluatePlanGates` with the same semantics.
- `orchestration-artifacts.ts`:
  - `validatePlanText(text)` and `validateArtifact(input)` keep their signatures and their `string[]` return type, and return only errors. Every existing caller is unaffected.
  - New sibling `validateArtifactWithWarnings(input) -> { errors: string[]; warnings: string[] }`. `validateArtifact` delegates to it and returns `.errors`.
- `validate-orchestration-service-call.ts` calls the sibling. On errors it throws with the existing message format, then appends one line per warning prefixed `PLAN GATE WARNING: `; when there are no warnings the thrown message is byte-identical to today. On success it returns the existing result object with the existing `summary` string plus an optional `warnings` array, present only when non-empty.
- `mcp-tools.ts` projects the optional field with a conditional spread, so a result with no warnings produces a byte-identical tool result object.

### Message contract

Every finding, Blocking or Warning, begins with the attributed task identifier in square brackets, states the specific mechanical reason, and states the mechanical remedy. Offending values are rendered inside backticks. `repr()` and `!r` in Python, and `pythonRepr` in TypeScript, are prohibited in these messages; see Constraints & Risks.

## Data & State

- **Placement.** The rules extend the existing `plan` route in both runtimes. No new `artifact_type`, no new MCP flag, no MCP schema change, no new call site. Because `.claude/skills/atomic-plan-contract/SKILL.md` already makes the `plan` artifact type a mandatory gate before a plan can be reported as approved, a rule that runs unconditionally inside that route is automatic by construction. An opt-in flag would fail the automatic-invocation criterion and is rejected.
- **Context object and graceful degradation.** With no context supplied, only the context-free rules G1 and G4 run; G2, G3, G5, and G6 produce no findings, and the returned error list is byte-identical to the pre-change output for the same text. This preserves every existing pure-text unit test. With a context supplied, all six rules run. If the injected git adapter raises, returns a non-zero exit, or is otherwise unavailable, the context-requiring rules are skipped and produce no findings; a validation run never fails because the repository could not be queried.
- **Blocking / Warning separation mechanism.** This is the load-bearing contract, because the existing return channel is a single `list[str]` whose non-emptiness is the failure signal (`validate_orchestration_artifacts.py` exit path, and the throw in `validate-orchestration-service-call.ts`). Emitting Warnings into that list would make every Warning a rejection, contradicting the G5 and G6 severity decisions. The separation is therefore a second return channel, not a message prefix inside the existing one:
  1. `evaluate_plan_gates` / `evaluatePlanGates` return a two-field report (`blocking`, `warnings`). Severity is decided inside the rule module and is never re-derived by parsing message text.
  2. The existing entry points (`validate_plan_text`, `validatePlanText`, `validateArtifact`) return **only** the concatenation of the existing structural errors and the `blocking` list. Warnings never enter that list.
  3. The `warnings` list reaches callers through the new sibling entry points (`validate_plan_text_with_warnings`, `validateArtifactWithWarnings`), which the CLI `main` and the MCP service call use.
  4. Failure remains defined exactly as today: the CLI exits non-zero if and only if the error list is non-empty, and the MCP service call throws if and only if the error list is non-empty. The warnings list is never consulted for either decision.
  5. Warnings are surfaced on stderr (CLI) and on the result object's `warnings` field (MCP), each line prefixed with the stable token `PLAN GATE WARNING: `. stdout is not used for warnings, so the clean-plan stdout line is unchanged.
- **Byte-identity guarantee.** For any plan that produces no G-rule findings: the returned error list, the CLI stdout, the CLI stderr, the CLI exit code, the MCP success summary string, and the MCP tool result object are byte-identical to the pre-change behaviour. For a structurally invalid plan with no G-rule findings, the emitted error lines are byte-identical.
- **No persistence, no cache, no migration.** The check is a pure function of the plan text plus a live `git grep` query. Nothing is written by the validator.

## Constraints & Risks

- **False rejection risk.** A pattern legitimately absent at authoring time *because the task creates it* is the normal case and is common in the corpus. Whole-tree absence alone is the identical observation for (i) an interpolated message that can never match and (ii) a message the task is about to write verbatim, so absence alone is not decidable. G5 therefore requires the two-condition form: absent from the tracked tree **and** absent from the plan document text. If the plan tells the executor to write the text, the plan quotes it and the gate is exonerated. If the literal appears nowhere in the tree and nowhere in the instructions, nobody has been told to create it, so the gate cannot pass whatever the executor does. Residual risk: a plan that instructs an edit in paraphrase and then asserts a grep for a sentence it never quoted. That residual rate is unmeasured, which is why G5's severity is fixed by the pre-declared measurement above.
- **Polarity independence.** No shipped rule needs to know whether the author intended matches or no matches. A negative gate whose literal is absent from the tree and un-creatable is equally non-discriminating; it passes vacuously. This is the property that makes the rule set shippable without the deferred expected-exit-code field.
- **Parity: Python and TypeScript ship together.** The `plan` route is dispatched from `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, which is inside the established parity surface. Both runtimes must be updated in the same change, and both must produce the same finding strings for the same inputs.
- **Parity: the PowerShell hook must not be touched.** `.claude/hooks/validate-planner-output.ps1` already duplicates plan-structure validation. Adding these rules there would create a third implementation requiring `git grep` invocation and tracked-file resolution from PowerShell, multiplying the drift surface for no gain, because the MCP validator gate is already mandatory. This feature makes no change to that file.
- **Parity: the one live divergence class.** Of the three recorded Python/TypeScript divergence classes, only `pythonRepr` quote selection applies here: Python's `repr` switches to double quotes when the value contains a single quote, while the TypeScript helper always single-quotes, and grep patterns in the corpus do contain single quotes. It is neutralised by construction: offending values are rendered in backticks in both runtimes, and `repr()`, `!r`, and `pythonRepr` are prohibited in these messages. Integral-float and boolean/integer divergence do not apply, because the plan artifact is Markdown and no JSON value round-trip occurs.
- **Parity: tracked-file answers must agree.** Both runtimes must shell out to the same `git` binary through their existing runner seams and must reuse the existing line-splitting behaviour (Python `str.splitlines()`, TypeScript `/\r\n|\n|\r/`), which already agree on LF, CRLF, and lone CR. Neither runtime may reimplement matching or line splitting for the window-join logic.
- **Historical plan artifacts must not be blocked, and no exemption mechanism is added.** The plan validator only ever runs against the single artifact passed to it. No CI job and no test sweeps the committed plan corpus. A committed plan is therefore never re-validated unless a human explicitly points the tool at it. Scope of invocation already satisfies the requirement, so no date-based, path-based, or version-based exemption is introduced; the repository has no such precedent, and adding one would create a suppression channel with no bounded owner. This argument is recorded in the rule file so a later reader does not add an exemption mechanism.
- **File-size ceiling.** `scripts/dev_tools/validate_orchestration_artifacts.py` is near the 500-line ceiling, so the new rules and their helpers belong in a separate module in each runtime, following the existing split pattern.
- **`git grep` reads the working tree, not a fixed commit.** Two runs of the same plan can disagree if the tree changed between them. This is acceptable for an authoring-time gate but means a verdict is not reproducible from the plan text alone.
- **Extraction is not fully solved.** The backtick-truncation hazard is real and appears in the corpus. Skipping unbalanced commands is safe but silently drops some real gates. This is an accepted limitation, not a defect to be worked around by analysing truncated text.

## Deferred Dependency — Expected Exit Code (out of scope)

The issue's fourth Proposed-Behavior bullet — "Require every acceptance command to declare its acceptance condition explicitly, including the expected exit code" — is **out of scope for #486**. It depends on an evidence-schema change tracked separately as `2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit.md`. No acceptance criterion in this feature requires an expected-exit-code field to exist, and no shipped rule reads one.

The seam where that later feature attaches is fixed here so no rework is required. The extractor must be authored as a reusable module returning a command value object of shape `{ task_id, source_line, raw_span, argv[], kind }`, where `kind` is one of `grep`, `pytest_cov`, or `other`, rather than as inline logic inside the rule functions. The later feature adds an `expected_exit_code: int | None` field populated from a declared acceptance condition, and the polarity-dependent rules become expressible on top of it. Every rule shipped here is polarity-independent, so none of them requires revision when that field arrives.

## Implementation Strategy

- **Scope of change.** Two new modules (one per runtime) carrying the extractor and the rule set; small edits to the two existing validator entry points to add the sibling warning-bearing functions and to thread the context; one CLI option; one conditional field projection in the MCP tool result; a new rule file `.claude/rules/plan-acceptance-gates.md` recording the rules, the severity decisions, and the no-grandfathering argument; a cross-reference from `.claude/skills/atomic-plan-contract/SKILL.md`.
- **New units.** Python: `extract_plan_commands`, `evaluate_plan_gates`, `PlanCommand`, `PlanGateReport`, `validate_plan_text_with_warnings`. TypeScript: `extractPlanCommands`, `evaluatePlanGates`, `validateArtifactWithWarnings`.
- **Dependencies.** None added. `git` is reached through existing runner seams.
- **Logging/telemetry.** None. The validator's only output channels are its return values, stdout, and stderr.
- **Rollout.** No feature flag. The rules are live on the `plan` route from the moment they land; the context-free rules run everywhere, and the context-requiring rules run wherever a context is supplied. The graceful-degradation path is the fallback.
- **Tests.** New sibling test modules in both runtimes, following the existing split convention. Fixtures are in-memory strings and stub runners; no temporary files. Coverage commands use the dotted-module form.

## Definition of Done

- [x] Every acceptance criterion below is checked off, with the named test or observable command recorded.
- [x] The G5 corpus measurement artifact exists under `<FEATURE>/evidence/qa-gates/` and G5's shipped severity matches the two-conjunct rule applied to the recorded finding count and false-positive count: `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` records a total G5 finding count of 0 and a false-positive count of 0, so the "total finding count greater than 0" conjunct fails and G5 correctly ships as a Warning.
- [x] Python and TypeScript ship in the same change and produce identical finding strings for the shared fixture set.
- [x] `.claude/hooks/validate-planner-output.ps1` is unmodified.
- [x] `.claude/rules/plan-acceptance-gates.md` exists and records the G1-G6 rule set, both severity decisions, and the scope-of-invocation argument against a grandfathering mechanism; `.claude/skills/atomic-plan-contract/SKILL.md` cross-references it.
- [x] Unit tests cover every row of the `--cov` classification table, every literal-checkability branch, both attribution-window boundaries, and the graceful-degradation path.
- [x] Line coverage >= 85% and branch coverage >= 75% for the new modules in both runtimes, measured with the dotted-module form on the Python side.
- [x] Full toolchain pass in both runtimes (format, lint, type-check, test) with no stage auto-fixing files on the final pass.

## Acceptance Criteria

- [x] **AC1 (G5, two-condition form).** A plan whose acceptance command searches for a checkable literal that is absent from the tracked tree **and** absent from the plan document text produces a G5 finding naming the task identifier and the literal; a plan whose literal is absent from the tree but appears contiguously in the plan document produces no G5 finding. Verified by two named tests per runtime — one asserting the finding, one asserting the exoneration — each supplied with a stub git adapter returning an empty file list.
- [x] **AC2 (G1).** A plan containing `--cov=scripts/dev_tools/foo.py` produces a Blocking finding whose message contains the dotted remedy `scripts.dev_tools.foo` and does not contain the string `.py` in the remedy clause. Verified by a named test per runtime that runs without any repository context.
- [x] **AC3 (no-finding byte identity).** For a plan that produces no G-rule findings, the validator's returned error list, the CLI stdout, the CLI stderr, and the CLI exit code are unchanged; the seven existing structural error strings are unchanged in text and order. Verified by a named test per runtime that asserts the seven exact error strings and asserts that a clean plan returns an empty list both without a context and with a stub context supplied. The with-context assertion cannot be authored against the pre-change API, so the test fails to compile or import before the change.
- [x] **AC4 (automatic invocation, no surface growth).** A G1 finding is produced by the existing `plan` route with no new flag, option, or artifact type; and the property-key set of the `validate_orchestration_artifacts` MCP input schema is unchanged. Verified by a named dispatch test per runtime plus a named test asserting the schema property-key set.
- [x] **AC5 (task attribution).** Every finding string, Blocking or Warning, begins with the `[P#-T#]` identifier of the task the command is attributed to; a command in the document preamble, a command in a phase preamble, and a command after an intervening Markdown heading each produce no finding. Verified by four named tests per runtime.
- [x] **AC6 (Warnings do not fail the gate).** A plan whose only G-rule finding is a Warning yields exit 0 and the unchanged success line on stdout from the CLI, does not throw from the MCP service call, and surfaces the warning text on stderr and on the result object's warnings field respectively. Verified by a named test per runtime.
- [x] **AC7 (G5 severity fixed by measurement, two-conjunct form).** An evidence artifact under `<FEATURE>/evidence/qa-gates/` records the G5 run over the acceptance-line grep commands of the committed plan corpus, including the command, the exit code, the number of candidate literals evaluated, and the true-positive and false-positive counts; and G5's shipped severity is Blocking if and only if the recorded total G5 finding count is greater than 0 and the recorded false-positive count is 0. Verified by reading the artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` (166 plan files scanned, 100 candidate literals evaluated, total G5 finding count 0, false-positive count 0 — the zero total finding count means the false-positive-count-zero conjunct alone measures nothing, so the first conjunct correctly gates Blocking off) together with the `G5_SEVERITY` constant, which is `"warning"` in both `scripts/dev_tools/plan_gate_discrimination.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`.
- [x] **AC8 (G6 is a Warning).** A plan whose checkable literal is present only in the whitespace-normalised join of adjacent tracked-file lines and on no single line produces a Warning and exit 0, not a Blocking finding. Verified by a named test per runtime using a stub file reader.
- [x] **AC9 (parity, including the quote-selection class).** For a shared fixture set, the two runtimes return identical finding strings, including for a `--cov` value and a search literal that each contain a single-quote character. Verified by paired named tests asserting the same expected strings in both runtimes.
- [x] **AC10 (graceful degradation).** With no context supplied, G2, G3, G5, and G6 produce no findings and the error list is identical to the pure-text result; with a context whose git adapter raises or returns a non-zero exit, those rules are skipped and no finding is produced and no exception escapes. Verified by two named tests per runtime.
- [x] **AC11 (reusable extractor seam).** The extractor is importable independently of the rule functions and returns records carrying exactly the fields `task_id`, `source_line`, `raw_span`, `argv`, and `kind`, with `kind` drawn from `grep`, `pytest_cov`, and `other`. Verified by a named test per runtime asserting the record field set and the `kind` values.
- [x] **AC12 (PowerShell hook untouched).** `.claude/hooks/validate-planner-output.ps1` does not appear in `git diff --name-only <base>...<head>` for this feature branch.

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: pattern-absence detection against a controlled tracked-file set; `--cov=` argument-form classification for path, module, and package forms; the plan-task identifier attached to each rejection; the no-violation path producing an empty result.
- [x] Integration scenarios: a synthetic plan carrying one instance of each of the three confirmed failure modes produces three distinct findings at their specified severities; a clean plan from the existing corpus passes. Verified by `test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation` (`[P4-T1]`) and `produces one G1 Blocking finding and two Warnings (G5, G6) in a single combined-plan evaluation` (`[P4-T2]`).
- [x] CLI/API examples: exit-code and message-format contract for the check, including the zero-violation case and the warning-only case.
