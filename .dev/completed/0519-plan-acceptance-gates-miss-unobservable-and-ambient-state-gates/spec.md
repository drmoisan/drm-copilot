# 2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates (Spec)

- **Issue:** #519
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-55
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** `full-bug` — `spec.md` is the sole acceptance-criteria source; `user-story.md` is absent by design.

## Context
The G1-G6 acceptance-gate rules inspect only two things: `--cov` argument values and search literals. Across five preflight cycles on a single atomic plan, 25 acceptance conditions were found that could not fail, and the validator passed the plan cleanly on all six runs. None of the 25 fell into a category G1-G6 examine. The rule set is sound for what it covers and blind to at least five further classes of unfalsifiable gate.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: Python 3.13 under Poetry; ruff 0.15.12, black 26.1.0, pyright 1.1.409, pytest 9.0.2
- Command/flags used: `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=plan`, six runs across five plan revisions
- Data source or fixture: the atomic plan for issue #502 at `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`; 76 tasks, roughly 44 acceptance clauses naming a count, line, field, status, or threshold

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. The consequence is not a broken build but a false assurance: a plan carrying gates that cannot fail passes review and executes, and every one of those gates reports success regardless of what the executor did. The rule file's own framing — that such a condition "reads as a verification step and gates nothing" — is exactly the harm, and it is currently reachable through five routes the validator does not inspect.

Severity is bounded by the fact that a thorough human or agent reviewer *can* find these, as this exercise demonstrates. But it took five cycles and roughly 1.4 million subagent tokens on one plan, and the yield depended entirely on the sweep method.

Not a Blocker: no gate produces a *false failure*, and no incorrect code is admitted directly. The damage is to the verification argument.


## Repro & Evidence
Steps to Reproduce:
1. Take an atomic plan whose acceptance conditions include commands other than `pytest --cov` invocations and fixed-string searches — for example formatter invocations, `git diff` and `git status` observations, and prose conditions over "the diff".
2. Run the plan validator against it. Record the Blocking findings and Warnings.
3. Independently walk every acceptance condition and, for each, name a reachable state in which it fails. Record every condition for which no such state exists.
4. Compare the two sets.

Expected:
`.claude/rules/plan-acceptance-gates.md` opens by stating its own purpose: "a plan can state an acceptance condition that cannot fail... Such a condition reads as a verification step and gates nothing." A validator built for that purpose should catch a representative sample of the class, or the rule file should record which sub-classes it deliberately does not cover so a reviewer knows what still needs human attention.

Actual:
Step 2 produced, on every one of six runs, exit 0 with exactly two G4 Warnings and zero Blocking findings. Step 3 produced 25 conditions that could not fail. The intersection is empty.

The 25 sort into five classes, none of which G1-G6 inspect:

1. **Output the command does not emit in the success case.** `black .` prints no `reformatted ` line when nothing was rewritten, so a gate requiring "the reformatted-file line recorded verbatim" is unsatisfiable on a clean run and, under a fail-closed evidence rule, can never pass. `run_poshqc_analyze` returns only an ok flag and a one-sentence summary and writes no report file, so a gate demanding a zero-diagnostic count names a value that has no source. `pytest --cov-branch --cov-report=term-missing` prints one combined `Cover` column, so a gate demanding separate line and branch percentages reads two numbers that are never printed. A coverage gate whose command omits `--cov-report=term-missing` prints no table at all when the project's `addopts` supplies only an LCOV reporter.

2. **Write-mode tooling gated on exit code.** A formatter or fixing linter exits 0 when it rewrites a file, so "exit 0" cannot observe the rewrite. This affected `black`, Prettier via `npm run format`, the PoshQC formatter, and `ruff check` — the last because `pyproject.toml` sets `fix = true`, recorded separately as [[ruff-check-is-write-mode-and-exits-zero-after-fixing]].

3. **Ambient state the plan does not pin.** `git diff --exit-code -- <path>` compares worktree to index, so it passes vacuously once a change is committed. Anchoring to a ref fixes that but introduces the mirror-image blindness: `git diff` never reports untracked files, so an anchored diff omits every file the plan creates and a "no new function signature" audit passes without seeing the modules that add signatures. `git diff --name-only` likewise never lists untracked files, so a gate asserting it lists four newly created fixtures always sees an empty list. `git status --porcelain` covers untracked but goes empty once committed — the two are complementary and each alone is wrong in one state.

4. **Task-ordering dependencies inside the plan.** A gate that runs a test path containing deliberately-failing cases added by an earlier task, before the later task that makes them pass, cannot exit 0. A baseline captured *after* a write-mode formatter has already repaired pre-existing drift becomes either a blanket waiver or makes the later gate unsatisfiable.

5. **Evidence the executor selects.** Two conditions asked the executor to identify "the known-genuine pair" and to choose a survivor list. An executor free to pick the evidence it is judged against cannot fail. Separately, a probe list fixed in the plan but never measured against the corpus contained two entries with zero carriers, one of which was structurally unreachable — it appeared in both `shared_surfaces` and `mandate_reads`, so mandate-read exclusion strips it from every harvest.

Classes 1 and 2 share a property that makes them invisible to review: they cannot be detected by reading the plan, the rules, or the tool documentation. Only running the tool and observing its success-case output reveals them. Four careful review cycles missed class 1 entirely; it surfaced only when the reviewer ran black, ruff, pyright, the analyzer and the corpus derivation.

Class 3 has a second property worth recording: each fix introduced its own mirror-image defect. The bare form was replaced by an anchored form that was blind to untracked files; a porcelain form that fixed untracked-blindness was blind to the committed state. Three successive cycles each corrected the previous cycle's correction.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Per-cycle finding counts: 5, 2, 3, 3, 1. Cycle 3 additionally self-found 11 when instructed to walk all 76 conditions individually instead of grepping for patterns — the single largest yield of any cycle, and evidence that the detection method matters more than reviewer effort.
- Validator output was identical on all six runs: `ok: true`, two G4 Warnings for the bare `--cov` space-separated form in the mandated canonical pytest command, no Blocking findings.


## Scope & Non-Goals

- In scope:
  - Three new acceptance-gate rules in the plan validator, one per surviving candidate from the research assessment, added to both the Python runtime and the TypeScript parity port:
    - **G7 — write-mode command register.** A command that rewrites tracked source, appearing in a task whose attributed text carries none of that register entry's observation markers.
    - **G8 — bare `git diff` with no ref operand.** A `git diff` invocation with no non-flag operand ahead of the pathspec separator and no staged-comparison flag, which compares worktree against index and is therefore commit-state dependent. Sub-rule **G8b** covers the mirror-image case: an anchored name-listing diff in a task whose attributed text carries neither a staging span nor a porcelain-status span, so it cannot observe a file the plan creates.
    - **G9 — coverage invocation with no terminal reporter.** A coverage command that supplies no terminal reporter where the project's `addopts` supplies none either, so no coverage table is printed and an acceptance condition asserting over a printed percentage reads a value with no source.
  - A `task_text` field on the extracted command record, populated from the attribution window the extractor already maintains, so a rule can read the owning task's text without re-implementing that window.
  - Amendment of `.claude/rules/plan-acceptance-gates.md` to carry the new rule-table rows, the per-rule severity decisions with their measurement citations, the register exclusions and their reasons, the known limitation that a single-token tool-name span is never extracted, and an explicit record of the sub-classes deliberately left uncovered.
  - Amendment of `.claude/skills/atomic-plan-contract/SKILL.md` to carry the matching authoring-side bullets, including a requirement that a plan author observe a command's success-case output before asserting over it, and the authoring guidance that replaces the rejected executor-choice heuristic.
  - Byte-identical mirroring of both policy files into the bundled payload under `extensions/drm-copilot/resources/claude-customizations/`, which the push-down contract test requires.
  - A per-rule corpus measurement recorded as an evidence artifact, and a severity assignment derived from that measurement under a pre-declared decision rule.
  - Correction of the stale citation in `.claude/rules/plan-acceptance-gates.md` that names the G5 corpus-measurement artifact under the active feature tree; the referenced feature has been archived and the artifact now sits under the completed tree.

- Out of scope / non-goals:
  - **The executor-choice heuristic is rejected as a validator rule and must not be revived without new evidence.** The proposal was to flag selection vocabulary — "any", "a suitable", "the known", "choose" — in acceptance text. That vocabulary is ordinary plan prose used in roles carrying no selection semantics; the research recorded a corpus instance in which the word "any" appears inside a prohibition rather than a selection. A keyword scan over prose is not statically decidable for the property the rule would claim to detect, and the rule file's own guidance is to weigh a new rule on its authoring-time false-positive rate. The concern is real and is addressed in the authoring skill as prose guidance instead.
  - **Class 1 in general (output the command does not emit in the success case) is not fully covered.** G7 and G9 cover the two decidable slices. The remainder requires knowledge of a tool's success-case output and is addressed by an authoring requirement, not a rule.
  - **Class 4 (task-ordering dependencies inside the plan) is not covered by any rule.** Detecting it requires intra-plan dependency reasoning across phases. It is recorded in the rule file as a deliberately uncovered sub-class so a reviewer knows it still needs human attention.
  - **No change to the extractor's two-word minimum-argv floor.** The floor drops any command span shorter than two shell words and is pinned by an existing test. Relaxing it would newly admit a single-word coverage-argument span into the G1 and G4 scan and would change existing output, which this fix forbids. The consequence — that a tool invoked as a bare single-token name is invisible to G7 — is a stated limitation, not a promise deferred.
  - **No sweep over the committed plan corpus.** No CI job, scheduled task, or committed test may scan the plan corpus. The corpus measurement is a throwaway driver, run once, recorded, and deleted.
  - **No grandfathering list, exemption marker, per-plan suppression comment, or allowlist file.** With no sweep there is no existing corpus to protect, so the only reachable use of a suppression surface would be to silence a finding on the plan being authored, which is the case the gate exists to report.
  - **No change to the MCP tool contract.** New findings flow through the two existing channels; the input-schema property-key set and the optional warnings field are unchanged.
  - **No new runtime dependency.** In particular, no TOML parser is added on either runtime.

- Explicitly excluded systems, integrations, or datasets:
  - `.github/copilot-instructions.md` and every file under `.github/instructions/`. These are the canonical Copilot policy surface that `CLAUDE.md` declares unmodifiable, and neither carries any statement of the acceptance-gate rules.
  - `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md`, and `.claude/rules/general-unit-test.md`. This fix consumes them and does not amend them.
  - `quality-tiers.yml`. The file does not exist at the repository root in this worktree, so no tier lookup is performed and no acceptance condition here depends on one.
  - The CLI and MCP dispatch modules `scripts/dev_tools/validate_orchestration_artifacts.py` and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`. Both route the existing plan artifact type through the two-channel entry point and need no change.
  - The G1 through G4 coverage cascade module and the shared-predicate module. They are imported, not edited.

## Root Cause Analysis
- G1-G4 target `--cov` values and G5-G6 target search literals. Both were chosen because they are decidable context-free or with a cheap repository lookup. The five classes above are harder: class 1 needs tool behavior, classes 3 and 4 need intra-plan reasoning, class 5 needs corpus measurement. The gap is a natural consequence of picking the tractable cases first, not an oversight in the existing rules.
- Not everything here is automatable, and the rule file's own guidance is to weigh a new rule on its false-positive rate at authoring time. Realistic candidates, roughly in order of value per unit of effort:
  - **A write-mode command register.** A static list of commands known to write, with a requirement that any acceptance condition invoking one carry an observation beyond the exit code. This is cheap, has a near-zero false-positive rate, and covers class 2 completely. The inventory already exists: `black .`, `ruff check` without `--no-fix`, `run_poshqc_format`, `npm run format`, `npm ci`, `git add -A` write; `black --check`, `ruff check --no-fix`, `pyright`, `pytest`, `run_poshqc_analyze`, `run_poshqc_test`, `npm run lint`, `npm run typecheck` do not.
  - **A bare-`git diff` rule.** Flag `git diff --exit-code` or `git diff --name-only` with no ref argument, since both are commit-state-dependent, and flag any `git diff` gate asserting over created paths without a preceding stage. Mechanical and decidable from the command text.
  - **A coverage-reporter rule.** Flag a `--cov` invocation whose acceptance demands a printed percentage when neither the command nor the project `addopts` supplies a terminal reporter. Decidable by reading `pyproject.toml`.
  - **An executor-choice heuristic.** Flag acceptance text containing selection language — "any", "a suitable", "the known", "choose" — over evidence the condition is asserted against. Higher false-positive risk; would need measuring before shipping as Blocking.
- Class 1 in general is not statically decidable and probably should be addressed by documentation rather than a rule: a prose requirement in `.claude/skills/atomic-plan-contract/SKILL.md` that a plan author must observe a command's success-case output before asserting over it, plus the write-mode register above.
- The rule file's "Scope of Invocation" section argues against grandfathering because no sweep exists over the committed plan corpus. That reasoning holds for any rule added here too, and is worth re-reading before adding one.


## Proposed Fix

### Design summary (what changes where):

Add three rules — G7, G8 (with sub-rule G8b), and G9 — to the plan acceptance-gate rule set, implemented in a new rule module per runtime and invoked from the single existing rule-invocation seam in each runtime's public entry point. G7 and G8 are context-free and run on every invocation. G9 requires the repository seam and runs only when a context is supplied, inside the existing graceful-degradation guard.

G7 needs one input the extractor does not currently supply: the text of the task a command span is attributed to. That is added as a trailing field with a default on the extracted command record, populated from the attribution window the extractor already maintains. Re-walking the plan text inside the rule module was rejected because it would produce a second implementation of the attribution-window invariant.

G9 reads the project's pytest `addopts` value through the existing tracked-text repository seam and extracts the assignment with a regular expression restricted to the construct subset common to both runtimes' regex dialects. No TOML parser is added: the standard-library parser requires a Python version above the declared floor, and the TypeScript runtime has none.

The rule set and its authoring-side statement are prose-enforced as well as code-enforced, so both policy files are amended and both bundled mirrors are updated in the same change.

### Boundaries and invariants to preserve:

- **Existing G1 through G6 output does not change.** No finding string, no severity, and no finding count produced by an existing rule may differ before and after this change, for any input. This is an invariant, not a preference.
- **The context-free / context-requiring split holds.** With no context supplied, the blocking channel must be byte-identical to the pre-change output for the same text.
- **The two-word minimum-argv extraction floor stays at two.** It is load-bearing: it prevents a backticked file path from being read as a command, and lowering it would change existing coverage-rule output.
- **Graceful degradation.** A repository seam that raises or reports a non-zero exit causes every context-requiring rule to be skipped, producing no finding and letting no exception escape the evaluation entry point.
- **Message formatting.** Every offending value renders between backticks. Python `repr` and the `!r` conversion are prohibited in gate messages; the TypeScript single-quoting helper is prohibited in gate modules. The reason is byte-identity across the two runtimes for values containing an apostrophe.
- **Attribution window.** A command span in the document preamble, in a phase preamble, or after an intervening heading belongs to no task and is dropped rather than reported.
- **The 500-line file limit.** The TypeScript shared-predicate module `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` is 437 lines against a 500-line hard limit, leaving insufficient headroom for three rules and their documentation. A new module per runtime is therefore mandatory, not a stylistic choice.
- **Policy-file byte-identity.** Each amended policy file has a bundled mirror held byte-identical by a push-down contract test. Amending one without the other fails that test.
- **No rule ships Blocking on assertion alone.** Severity is fixed by a pre-declared decision rule applied to a recorded corpus measurement, following the precedent that fixed the G5 severity.

### Dependencies or blocked work:

None blocking. Every input required by this fix is present in the repository: the rule modules, the extractor, the parity test harness, the push-down contract test, the `addopts` value, and the regression corpus. No external service, credential, or third-party interface is involved.

The regression corpus is recoverable from git history. The plan for issue #502 has six authored revisions at commits `e2aa6446` (revision 0), `eff8f196`, `30414365`, `e913e0a9`, `ceacb5a5`, and `5a8ede0f` (revision 5). The file has since been archived under the completed-features tree, so extraction must use the active-tree path as it stood at each of those commits. The research artifact proposed a history-independent reconstructed-fixture fallback because it could not confirm recoverability; that fallback is unnecessary and is not adopted as the primary check.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Policy and documentation, two mirrored pairs:

1. `.claude/rules/plan-acceptance-gates.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
3. `.claude/skills/atomic-plan-contract/SKILL.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`

Python runtime:

5. `scripts/dev_tools/plan_gate_observability.py` — new module carrying G7, G8, G8b, and G9 with their severity constants.
6. `scripts/dev_tools/plan_gate_discrimination.py` — one import and one rule-group call appended at the existing invocation seam.
7. `scripts/dev_tools/plan_gate_commands.py` — trailing `task_text` field with a default, populated from the attribution window.

TypeScript runtime:

8. `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` — new module, port of item 5.
9. `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` — mirror of item 6, plus re-export of the new public surface.
10. `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` — mirror of item 7.

Tests, Python:

11. `tests/scripts/dev_tools/test_plan_gate_observability.py` — new.
12. `tests/scripts/dev_tools/test_plan_gate_parity.py` — new gate module registered in the module list; one severity-constant assertion per new rule; new parity fixtures including apostrophe-bearing values.
13. `tests/scripts/dev_tools/test_plan_gate_commands.py` — record-field test updated for `task_text`; new coverage of window population and of the empty value outside any window.

Tests, TypeScript:

14. `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts` — new, mirroring item 11 case for case.
15. `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` — mirror of item 12.
16. `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts` — mirror of item 13.

Files deliberately not changed, recorded so the boundary is explicit: `scripts/dev_tools/validate_orchestration_artifacts.py`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, `scripts/dev_tools/plan_gate_coverage.py`, and `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`. The last is imported by the new TypeScript module for its report shape and seam interfaces; if an added export proves unavoidable it must not push that file past the 500-line limit.

#### Functions/classes/CLI commands impacted:

- `evaluate_plan_gates` (Python) and `evaluatePlanGates` (TypeScript) — one appended rule-group call each. The two-channel return shape is unchanged.
- `extract_plan_commands` (Python) and its TypeScript counterpart — populate the new record field. Extraction behaviour, including the two-word floor and the attribution window, is unchanged.
- The `PlanCommand` record (Python dataclass, TypeScript interface) — one trailing optional field.
- New per-rule evaluation functions and per-rule severity constants in the two new modules.
- No CLI command, flag, subcommand, or MCP tool parameter is added, removed, or renamed.

#### Data flow and validation changes:

Plan text flows through the existing extractor to command records that now carry the owning task's text. The entry point evaluates the coverage cascade, then the literal rules, then the new observability rules, appending findings to the existing blocking and warning channels. G9 additionally reads one tracked file's text through the repository seam. No new artifact type, no new file written at validation time, and no state carried between invocations.

#### Error handling and logging updates:

No new logging surface. Every context-requiring rule sits inside the existing guard: a seam that raises or reports a non-zero exit results in the rule being skipped, zero findings produced, and no exception escaping the evaluation entry point. A validation run must never fail because the repository could not be queried.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. The rule set has no runtime toggle by design, consistent with the prohibition on suppression surfaces. Rollback is reversion of the change; because the rules ship at the severity the corpus measurement licenses, an over-firing rule surfaces as a Warning rather than a merge blocker in the interval before reversion.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: plan document text, plus an optional repository context supplying the workspace root, a file-system seam, and a git seam.
- Output: the existing two-channel report. Blocking findings raise the validator exit code; warnings are printed to standard error behind the existing warning prefix on the CLI and carried on the optional warnings field of the MCP result.
- Every finding string begins with the square-bracketed phase-and-task identifier of the task the command is attributed to and renders the offending value between backticks.

#### Required configuration keys and defaults:

None. No configuration file gains a key, and no default is introduced. The write-mode register is a constant in the rule module, duplicated across the two runtimes and pinned equal by a parity assertion, not a configuration file.

#### Backward-compatibility expectations:

- A plan that produced no finding before this change may now produce a new-rule finding. That is the intended behaviour change and the only one.
- No existing finding string, severity, or count changes.
- The added record field is trailing and defaulted, so any construction that omits it continues to work.
- The MCP input schema and result shape are unchanged.

#### Performance constraints (latency/throughput/memory):

G7, G8, and G8b are text predicates over already-extracted command records and their attributed task text; they add no repository access. G9 adds at most one tracked-file read per validation run, and the extracted value is reused across every coverage command in the run rather than re-read per command. No measurable change to validator latency is expected, and none is asserted; there is no performance gate on this path.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The six commits named under **Dependencies or blocked work** are present in the local clone and readable with ordinary git history commands. This was verified before the spec was written. If a commit proves unreadable at execution time, the shortfall is recorded with the command and its output rather than silently substituted.
  - The write-mode classification of each register entry holds as verified against this repository's own configuration and source: the formatter rewrites in place with no check-only default configured; the linter is configured with fix enabled; the PoshQC formatter, the PoshQC analyzer autofix tool, and the PoshQC composite suite tool all write; the Prettier script passes an explicit write flag. The one entry established from a third-party command's documented contract rather than from repository configuration is the package-install command, and it is excluded from the register for a separate reason.
  - The project's pytest `addopts` supplies exactly one non-terminal coverage reporter, so a coverage command that does not itself request a terminal reporter prints no table. This is recorded as an executed observation in a prior feature's baseline evidence, not only as a reading of the tool's contract.
  - No file at the repository root maps projects to rigor tiers in this worktree, so no acceptance condition here performs a tier lookup and the test set is justified against the general unit-test policy alone.

- Constraints (budget, performance, compatibility):
  - The two-word minimum-argv extraction floor is fixed. The register therefore cannot detect a tool invoked as a bare single-token name, which is the form plans commonly use for MCP tools including the PoshQC formatter, the PoshQC analyzer autofix tool, and the PoshQC composite suite tool. The limitation is stated in the rule file rather than papered over.
  - Existing G1 through G6 output must not change in any respect.
  - Both runtimes must produce byte-identical finding strings. The regular expression used to extract the `addopts` value is the first gate predicate to run a pattern over file content, so it is restricted to constructs whose behaviour is identical in both dialects: literal text, character classes, and the `*`, `+`, `?`, and non-greedy quantifiers.
  - No production or test file may exceed 500 lines.
  - Line coverage at or above 85 percent and branch coverage at or above 75 percent for both runtimes.
  - This fix's own acceptance conditions must carry an observation beyond the exit code wherever they invoke a write-mode tool. Running the repaired-against defect while repairing it would be a self-inflicted instance of the bug.

- External dependencies (services, libraries, releases):
  - None. No package is added to either runtime. No network access, credential, external service, vendor console, or interactive approval is required at any point.

## Data / API / Config Impact

- User-facing or API changes:
  - The plan validator may report new findings on plan documents that previously produced none. No command, flag, subcommand, artifact type, MCP tool, MCP parameter, or result field is added, removed, or renamed.
  - The two policy files gain new prose sections. Because both are published in the extension payload, the change is user-visible in a destination workspace after the next push-down.

- Data or migration considerations:
  - None. The validator is stateless, writes no data at validation time, and reads no persisted artifact of its own. There is nothing to migrate and no stored format to version.

- Logging/telemetry updates (if any):
  - None. Findings are returned on the two existing channels; no logging statement, counter, or telemetry event is added.

- Compatibility notes (CLI flags, config schemas, versioning):
  - No configuration schema changes; no configuration key is added to any file.
  - The extracted command record gains one trailing defaulted field, so existing constructions remain valid.
  - The bundled policy mirrors must be updated in the same change as their repository originals, or the push-down contract test fails.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas — per new rule, positive cases from the 25 conditions catalogued above (they are real, measured instances, not synthetic) and negative cases from the corrected forms that replaced them, so a rule that fires on the fix is caught.
- [x] Integration scenario to retest — run any new rules against the #502 plan at each of its six revisions. Expect zero findings at revision 5 and a non-zero count at revision 0 for whichever classes the new rules cover. A rule set that finds nothing at revision 0 is not exercising the case it was written for.
- [x] Manual verification notes — measure the false-positive rate over the committed plan corpus before assigning any rule Blocking severity, following the precedent set for G5, where a corpus measurement of zero findings decided that rule's severity. Record the measurement as an artifact.

- Regression tests to add or update:
  - New Python test module `tests/scripts/dev_tools/test_plan_gate_observability.py` and its TypeScript twin `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts`, mirroring each other case for case.
  - Parity test amendments in both runtimes: the new gate module registered in the module list that the message-formatting prohibition iterates, one severity-constant assertion per new rule, and new parity fixtures duplicated verbatim across the two files together with their expected finding strings.
  - Extractor test amendments in both runtimes for the added record field.
  - The existing test that pins the two-word minimum-argv floor must remain unmodified and passing; it is the guard against the rejected relaxation.
  - The push-down contract test that asserts byte-identity between each repository policy file and its bundled mirror must pass after the amendments.

- Unit tests (pytest) for the fixed behavior and boundaries:
  - Per rule: one positive case drawn from the catalogued defects, one negative case drawn from the corrected form that replaced it, and one exoneration case exercising the rule's marker or companion mechanism.
  - Register completeness: every entry of the write-mode register is reachable by at least one fixture, so an entry cannot be added without a corresponding test.
  - Register exclusion: the staging command and the package-install command are absent from the register, and a task invoking either with no observation marker produces no G7 finding.
  - Record-field behaviour: the attributed task text equals the owning task's text, and is empty for a span that belongs to no task.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Git-diff boundaries: a staged-comparison invocation, an invocation with a pathspec but no ref, an invocation with a ref, and an anchored name-listing invocation accompanied in the same task by a staging span and separately by a porcelain-status span.
  - Coverage boundaries: a command carrying a terminal reporter, a command carrying a fail-under threshold, and a command carrying neither where the project value also carries neither.
  - Attribution boundaries: a write-mode command in the document preamble, in a phase preamble, and after an intervening heading, each producing no finding.
  - Extraction boundary: a single-token tool-name span produces no finding, asserted explicitly so the stated limitation is pinned by a test rather than left to prose.
  - Malformed and empty input: an empty plan document, a plan with no task lines, and a command span with no operand.

- Error handling and logging verification:
  - Graceful degradation for the context-requiring rule, verified in both runtimes with two distinct fault injections: a repository seam that raises, and one that reports a non-zero exit. Each must produce zero findings and allow no exception to escape the evaluation entry point.
  - Absent-context behaviour: with no context supplied, the blocking channel is byte-identical to the pre-change output for the same text.
  - No logging assertion is required because no logging surface is added.

- Coverage impact and targets for changed lines/modules:
  - Line coverage at or above 85 percent and branch coverage at or above 75 percent for both new rule modules and for every changed line in the modules they are invoked from, measured in both runtimes.
  - Coverage is asserted from a printed terminal report, obtained by passing a terminal reporter explicitly. The project's configured reporter is non-terminal, so a coverage command without an explicit terminal reporter prints no table — the exact defect class G9 exists to report.

- Toolchain commands to run (format → lint → type-check → test):
  - Python: the formatter, the linter, the type checker, and pytest, in that order, restarting from the formatter whenever any stage rewrites a file.
  - TypeScript: the format script, the lint script, the typecheck script, and the test script, under the same restart discipline.
  - PowerShell is not in scope for this change; no PoshQC stage is required beyond what the repository's standard loop already imposes.
  - Because the formatter, the linter, and the format script all rewrite files and still exit 0, each of their acceptance conditions in this feature's own plan must record an observation beyond the exit code.

- Manual validation steps (if required):
  - The corpus measurement is performed once with a throwaway driver, recorded as an evidence artifact under `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/`, and the driver is then deleted with its deletion evidenced. The measurement follows the procedure the G5 precedent established: enumerate the corpus, enumerate candidates, apply the shipped predicate in the shipped order rather than a paraphrase, record findings and true-positive and false-positive counts with each false positive named, declare the measurement invalid if the finding count is zero, and re-examine the driver for a defect before accepting a zero.
  - The regression check against the six revisions of the issue #502 plan is recorded under `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/regression-testing/`, with the per-revision finding count for each new rule and the extraction command used for each of the six commits.


## Acceptance Criteria

Rule behaviour — each criterion below is satisfied only when the named assertion holds in **both** runtimes, Python and TypeScript.

- [x] **G7 positive.** A plan fixture containing a register-listed write-mode command in a task whose attributed text carries none of that entry's observation markers produces exactly one G7 finding. The finding string begins with the owning task's square-bracketed phase-and-task identifier and renders the offending command between backticks.
- [x] **G7 exoneration.** The same fixture, amended only by adding one of that entry's observation markers to the task's attributed text, produces zero G7 findings.
- [x] **G7 register membership.** The write-mode register includes the PoshQC analyzer autofix tool and the PoshQC composite suite tool, both of which were absent from the inventory in `issue.md`. A test asserts that every register entry is exercised by at least one fixture, so an entry cannot be added without a corresponding test.
- [x] **G7 register exclusions.** The staging command and the package-install command are not register members. A test asserts that a task invoking each of them, with no observation marker present, produces zero G7 findings, and `.claude/rules/plan-acceptance-gates.md` records both exclusions together with the reason for each.
- [x] **G7 register wording.** The rule-file entry for G7 states the register criterion as "rewrites tracked source", and records that the Python test runner and the PoshQC test tool write files under the artifacts tree without being register members.
- [x] **G8 positive and negative.** A `git diff` span with no non-flag operand ahead of the pathspec separator and no staged-comparison flag produces exactly one G8 finding, including the form that carries a pathspec but no ref. A span carrying a ref operand, and a span carrying a staged-comparison flag, each produce zero G8 findings.
- [x] **G8 pairing exoneration.** A bare `git diff` span in a task whose attributed text carries a second `git diff` or `git status` span produces zero G8 findings.
- [x] **G8b positive and exoneration.** An anchored name-listing diff in a task whose attributed text carries neither a staging span nor a porcelain-status span produces exactly one G8b finding; the same fixture with either companion span present produces zero.
- [x] **G9 positive and negative.** A coverage command carrying no terminal reporter, evaluated against a project value that carries none either, produces exactly one G9 finding. A command carrying a terminal reporter, and a command carrying a fail-under threshold, each produce zero G9 findings.
- [x] **G9 message content.** The G9 finding string states the remedy — adding an explicit terminal reporter — and does not assert that the acceptance condition is unfalsifiable, because that second claim depends on prose the rule does not read.
- [x] **G9 graceful degradation.** Two distinct fault injections — a repository seam that raises, and one that reports a non-zero exit — each produce zero findings from G9 and allow no exception to escape the evaluation entry point.
- [x] **Context-free split preserved.** With no repository context supplied, G7, G8, and G8b evaluate and G9 does not run, and the blocking channel for a fixed fixture set is byte-identical to the pre-change output for the same text.
- [x] **Extraction-floor limitation pinned by test.** A test asserts that a single-token tool-name span produces zero findings from every new rule, and the existing test that pins the two-word minimum-argv floor is unmodified in the branch diff and passes.
- [x] **Attribution boundaries.** A write-mode command placed in the document preamble, in a phase preamble, and after an intervening Markdown heading each produce zero findings from every new rule.

Invariants and parity.

- [x] **Existing G1 through G6 output is unchanged.** An anchored diff against the merge base shows no modification to `tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py`, `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`, `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts`, or `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`, and all four pass. No pre-existing expected finding string in either parity test file is modified or deleted.
- [x] **Attributed task text is additive.** The extracted command record gains one trailing field with a default; tests assert it equals the owning task's attributed text for an in-window span and is empty for a span belonging to no task, in both runtimes.
- [x] **File-size limit respected.** Every file created or modified by this change is at most 500 lines, including `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`, which must remain at or below that limit.
- [x] **Message-formatting prohibitions hold.** `scripts/dev_tools/plan_gate_observability.py` is registered in the Python parity test's gate-module list and contains neither the `!r` conversion nor a `repr(` call; `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` is registered in the TypeScript parity test's gate-module list and contains no `pythonRepr(` call. Both prohibition tests pass.
- [x] **Apostrophe parity fixtures.** For each new rule that renders an offending value, the parity fixture set includes an apostrophe-bearing value whose expected finding string is asserted identically in both runtimes.
- [x] **Severity constants exist and agree.** Each of G7, G8, G8b, and G9 has exactly one named severity constant per runtime, and a per-rule parity assertion — in the same shape as the existing G5 assertion — verifies the Python and TypeScript values agree.
- [x] **No dispatch or MCP contract change.** An anchored diff against the merge base shows no modification to `scripts/dev_tools/validate_orchestration_artifacts.py` or `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and the MCP input-schema property-key set for the plan artifact type is unchanged.

Severity discipline — no rule ships Blocking on assertion alone.

- [x] **Corpus measurement recorded.** An evidence artifact under `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/` records, per new rule and before the counts, the pre-declared severity decision rule verbatim, and then the corpus file count, the candidate count, the finding count, the true-positive count, and the false-positive count with each false positive named by plan path and offending value.
- [x] **Vacuity declared where it applies.** For any rule whose recorded finding count is zero, the artifact carries an explicit invalid-measurement declaration and the four driver-integrity checks the G5 precedent established: non-vacuous candidate enumeration, a working repository seam, a self-hit on every sampled lookup, and predicate-order equivalence with the shipped rule.
- [x] **Shipped severity follows the measurement.** Each rule's shipped severity constant equals the value its pre-declared decision rule yields from the recorded counts. No rule ships Blocking unless its measurement is non-vacuous and its recorded false-positive count is zero.
- [x] **Measurement driver deleted, no sweep introduced.** The throwaway driver is deleted and its deletion is evidenced. The branch diff adds no workflow file, no scheduled task, and no committed test that scans the plan corpus.
- [x] **No suppression surface introduced.** The branch diff adds no grandfathering list, exemption marker, per-plan suppression comment, allowlist file, or runtime toggle for any acceptance-gate rule.

Regression against the measured defects.

- [x] **Six-revision regression run recorded.** The new rules are run against all six authored revisions of the issue #502 plan at commits `e2aa6446`, `eff8f196`, `30414365`, `e913e0a9`, `ceacb5a5`, and `5a8ede0f`, extracted from the active-tree plan path as it stood at each commit. An artifact under `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/regression-testing/` records the extraction command and its output for each commit and the per-revision, per-rule finding count.
- [x] **The rules exercise the case they were written for.** The total new-rule finding count at commit `e2aa6446` is strictly greater than the total at commit `5a8ede0f`. A rule set that finds no more in the earliest revision than in the final one is not exercising the defects it was authored against.
- [x] **Corrected forms do not fire.** Every corrected acceptance-condition form named in the final revision of the issue #502 plan produces zero findings from the new rules, so a rule that fires on the fix is caught.

Policy documentation.

- [x] **Rule file amended.** `.claude/rules/plan-acceptance-gates.md` carries a rule-table row for each of G7, G8, G8b, and G9 with its shipped severity, a severity-decision subsection per rule citing the corpus-measurement artifact by path, the single-token extraction limitation stated in the style of the existing known-false-negative section, and an explicit record of the deliberately uncovered sub-classes: the general unobservable-success-output class beyond what G7 and G9 reach, the task-ordering class, and the rejected executor-choice heuristic together with the reason for its rejection.
- [x] **Authoring skill amended.** `.claude/skills/atomic-plan-contract/SKILL.md` carries, in its mandatory authoring section, one bullet per new rule plus a requirement that a plan author observe a command's success-case output before asserting over that output, and the authoring guidance that replaces the rejected executor-choice heuristic.
- [x] **Bundled mirrors byte-identical.** `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` are byte-identical to their repository originals, and the push-down contract test that asserts this passes.
- [x] **Stale citation corrected.** The citation of the G5 corpus-measurement artifact in `.claude/rules/plan-acceptance-gates.md` names the artifact's current location under the completed-features tree, and the same correction is present in the bundled mirror.

Delivery quality.

- [x] **Coverage thresholds met.** Line coverage is at or above 85 percent and branch coverage at or above 75 percent for both new rule modules and for every changed line in the modules they are invoked from, in both runtimes, read from a printed terminal coverage report obtained by passing a terminal reporter explicitly.
- [x] **Full toolchain passes in a single pass.** The Python stages (format, lint, type-check, test) and the TypeScript stages (format, lint, typecheck, test) each complete without error and without any stage rewriting a file, in one uninterrupted pass.
- [x] **This feature's own gates observe more than an exit code.** For every write-mode tool this feature runs — the Python formatter, the Python linter, and the TypeScript format script — the recorded evidence carries an observation beyond the exit code that would distinguish a run that rewrote a file from one that did not.
- [x] **Mode integrity.** `spec.md` is the sole acceptance-criteria source for this feature and no `user-story.md` exists in the feature folder, consistent with the `full-bug` work mode recorded in `issue.md`.

## Risks & Mitigations

- Technical or operational risks:
  - **False positives on correctly authored plans.** G7 fires on a paraphrased observation that its marker set does not spell, and on a write-mode command run as setup in a task whose acceptance concerns something else. G8b carries the highest false-positive surface of the set: it cannot distinguish an anchored name-listing diff auditing modifications to pre-existing tracked files, which needs no staging companion, from one asserting over created paths, which does. G9 fires on a coverage run whose only purpose is to produce a machine-readable report for a downstream consumer.
  - **The regression comparison may not show the expected direction.** The prediction that the earliest revision yields more findings than the final one is a prediction, not an established fact. It is asserted as an acceptance criterion precisely so that a failure is visible.
  - **The corpus measurement may be vacuous for one or more rules.** The G5 measurement was vacuous for structural reasons that do not transfer here, but a zero count remains possible.
  - **Cross-runtime divergence in the pattern used to extract the project coverage configuration.** This is the first gate predicate to run a pattern over file content, and the two runtimes' pattern dialects differ in several constructs.
  - **Byte-identity drift between a policy file and its bundled mirror**, which fails the push-down contract test late in the toolchain loop rather than at authoring time.
  - **Self-application failure.** This fix's own plan could state exit-code-only acceptance conditions over the formatter and the linter, both of which rewrite files and still exit 0 — shipping the repaired defect inside the repair.

- Mitigations and rollbacks:
  - Ship every rule at the severity its measurement licenses, and default to Warning wherever the measurement is vacuous. A Warning surfaces the finding without failing the gate, which bounds the cost of a false positive to reviewer attention.
  - Exclude the staging command and the package-install command from the register outright and record both exclusions with their reasons, removing the largest identified false-positive source before it can fire.
  - Give G8 and G8b companion-span exonerations, and give G9 a fail-under exoneration, each reusing the same attributed-task-text input rather than inventing a new mechanism.
  - Treat a failed regression-direction comparison as a signal to revise the rule predicates, not as a criterion to waive. The purpose of the comparison is to detect a rule set that does not reach the defects it was written for.
  - Restrict the configuration-extraction pattern to the construct subset common to both dialects, and add a parity fixture whose configuration value exercises quoting and whitespace variation.
  - Amend each policy file and its bundled mirror in the same change, and run the push-down contract test as part of the loop rather than at the end.
  - State explicitly in this spec, and assert as an acceptance criterion, that every write-mode tool invocation in this feature's evidence carries an observation beyond the exit code.
  - Rollback is reversion of the change. There is no persisted state, no migration, and no configuration key to unwind.

## Rollout & Follow-up

- Release/rollout steps:
  - Merge is the rollout for the repository-side rules: the validator applies them on the next invocation of the existing plan artifact type, with no flag, no migration, and no operator action.
  - The policy amendments reach a destination workspace through the existing push-down of the bundled payload. No separate release step is required and no version pin changes.

- Post-fix monitoring or clean-up tasks:
  - Confirm the throwaway measurement driver is absent from the merged tree.
  - Re-examine each rule's severity against a fresh measurement, taken by the same procedure, if the rule set is later revised. A severity may be changed only against a new measurement, never by argument.
  - Reconsider G8b specifically once findings from real use exist. If its observed false-positive rate is high, the correct remedy is to demote it to authoring guidance in the skill rather than to add a suppression mechanism.
  - Revisit the single-token extraction limitation only together with a plan for the coverage-rule output change that relaxing the two-word floor would cause; the two cannot be separated.
  - The rejected executor-choice heuristic is closed, not deferred. Reviving it requires new evidence about its false-positive rate on plan prose, not a restatement of the original proposal.

- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/519
  - Rule under repair: `.claude/rules/plan-acceptance-gates.md`
  - Authoring-side statement: `.claude/skills/atomic-plan-contract/SKILL.md`
  - Research: `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/research/2026-08-23T23-45-unobservable-and-ambient-state-gates-research.md`
  - Severity precedent: the G5 corpus-measurement artifact under the completed-features tree for issue #486.
  - Regression corpus: the six authored revisions of the plan for issue #502.
