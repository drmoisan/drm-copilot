# Research — Reject Unfalsifiable Acceptance Gates in Atomic Plans (Issue #486)

- **Issue:** #486
- **Feature folder:** `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`
- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`
- **Timestamp:** 2026-08-17T16-00
- **Scope:** Proposed-Behavior bullets 1–3 only. Bullet 4 (explicit acceptance condition including expected exit code) is out of scope; see [Deferred Dependency](#deferred-dependency--bullet-4-expected-exit-code).

---

## A. Where Plan Acceptance Happens Today

### A.1 The three existing implementations of plan validation

There are **three independent implementations** of atomic-plan structural validation in this repository. Any new rule must decide explicitly which of the three it lands in.

| # | Runtime | Module | Entry point | Notes |
|---|---|---|---|---|
| 1 | Python | `scripts/dev_tools/validate_orchestration_artifacts.py` | `validate_plan_text(text: str) -> list[str]` (`:69-148`) | Pure text function. Regexes at `:40-43`. |
| 2 | TypeScript | `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | `validatePlanText(text: string): string[]` (`:73-151`) | Declared port of #1; regexes at `:56-60`. |
| 3 | PowerShell | `.claude/hooks/validate-planner-output.ps1` | `Get-PlanStructureValidationReport` (`:113-227`) | SubagentStop hook for `atomic-planner`. **Superset** of #1/#2 — it additionally requires Phase 0, a policy-read task, a baseline task, an explicit path token per task, and QA work in the final phase (`:203-224`). |

Dispatch and CLI surface:

- Python CLI subparser: `validate_orchestration_artifacts.py:177-186` registers `plan` (with a single positional `path`) alongside `policy-audit`, `code-review`, `feature-audit`, `epic-kickoff`, `parallel-kickoff`. Dispatch at `:309-310`. Exit contract at `:388-394` (errors to stderr, one per line, exit 1; success line to stdout, exit 0).
- TypeScript dispatcher: `orchestration-artifacts.ts:191-284`, `case "plan": return validatePlanText(input.text)` (`:196-197`).
- MCP wiring: `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts:66-115`. Reads the artifact through the injected `FileSystem` (`:75`), calls `validateArtifact`, throws on any error with the message `Validation failed for {artifactType} artifact at '{artifactPath}':\n{errors}` (`:102-107`).
- MCP tool schema: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:327-...`. `artifact_type` is a closed `enum` including `"plan"`; `additionalProperties: false`; boolean flags `require_complete`, `require_model_routing`, `require_codex_model_routing`, `require_codex_topology`, `require_ready_for_execution`.

### A.2 What the plan validator checks today (existing invariants)

`validate_plan_text` emits exactly these six error strings. Any new check must be **appended** without altering these.

| Invariant | Error string | Source |
|---|---|---|
| Phase heading shape | ``Line {n}: phase heading must match `### Phase N — <Title>`.`` | `:102-106` |
| Task line shape | ``Line {n}: task line must match `- [ ] [P#-T#] <Title>`.`` | `:117-120` |
| Task before phase | `Line {n}: task appears before a canonical phase heading.` | `:125-129` |
| Task/phase mismatch | `Line {n}: task phase P{a} does not match current phase {b}.` | `:132-135` |
| Task numbering | `Line {n}: expected task number T{e} for phase {p}, found T{a}.` | `:137-141` |
| Corpus emptiness | `Plan does not contain any canonical phase headings.` / `Plan does not contain any canonical task lines.` | `:144-147` |

The validator does **not** parse task bodies, continuation bullets, code spans, or commands. It walks the document line by line and only reacts to lines beginning `### Phase ` or `- [`.

Notably absent from the Python/TS validators (present only in the PowerShell hook): Phase 0 requirements, per-task explicit-path requirement, and the final-phase QA requirement.

### A.3 What "invoked automatically as part of plan acceptance" means mechanically

Plan acceptance in this repository is a chain of four gates. For the new check to be automatic rather than opt-in, it must attach at gate (2) or (3):

1. **Planner ↔ executor preflight loop.** `.claude/skills/atomic-plan-contract/SKILL.md:142-150`. Text protocol only (`DIRECTIVE: PREFLIGHT VALIDATION ONLY`, `PREFLIGHT: ALL CLEAR` / `PREFLIGHT: REVISIONS REQUIRED`). No mechanical enforcement of *content*.
2. **Validator gate (mandatory).** `.claude/skills/atomic-plan-contract/SKILL.md:22` and `:152-158`: "Plans must pass the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` … before they can be reported as approved" and "reject the plan if that validator exits non-zero". **This is the single mandated mechanical gate on plan content.**
3. **SubagentStop hook.** `.claude/settings.json:233-241` registers `.claude/hooks/validate-planner-output.ps1` for matcher `atomic-planner`. This hook blocks planner termination and independently re-validates the advertised plan file.
4. **Orchestration checkpoint gates.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` gates implementation on checkpoint readiness, not on plan content.

**Mechanical conclusion.** Because the atomic-plan-contract skill already makes the `plan` artifact type a mandatory gate, a rule that runs **unconditionally inside the existing `plan` route** is automatic by construction — no new flag, no new call site, no MCP schema change. A new boolean flag (`require_discriminating_gates`) would be opt-in and would fail AC4.

**Critical enabling fact:** `validate-orchestration-service-call.ts:94-97` already passes `artifactPath`, `fs`, and `root` into `validateArtifact` on **every** route, including `plan`. The `plan` case currently discards them (`:196-197`). Repository-aware plan validation on the MCP path therefore requires **no MCP schema change and no caller change** — only that the `plan` case stop discarding the context it already receives.

**Negative evidence — no CI job validates the plan corpus.**
- `SearchScope:` `.github/workflows/**`
- `SearchPatterns:` `validate_orchestration_artifacts`, `artifact_type.*plan`
- `SearchResult:` none

**Negative evidence — no test iterates the committed plan corpus.**
- `SearchScope:` `tests/**`
- `SearchPatterns:` `plan\.\*?\.md`, `plan\*\.md`, `rglob`, `glob\(.*plan`
- `SearchResult:` `tests/scripts/dev_tools/atomic_executor/test_plan_discovery.py` and `tests/scripts/dev_tools/test_plan_progress_report.py` only, both of which assert the *glob pattern string* against mocked `Path.rglob`; neither reads a committed plan.

---

## B. Plan Document Structure and Acceptance-Command Extraction

### B.1 Canonical structure

- Phase heading: `### Phase N — <Title>` (em dash U+2014). Regex: `validate_orchestration_artifacts.py:40`.
- Task line: `- [ ] [P#-T#] <Title>` or `- [x] …`. Regex: `:41-43`.
- Line separators: the TS port accepts LF, CRLF, and lone CR (`orchestration-artifacts.ts:82`, delivered by feature #434). Python uses `str.splitlines()` (`:98`), which also accepts all three.

**Template divergence (pre-existing, not in scope).** `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md:30` writes `### Phase 0: Compliance & Context` with a colon, which the canonical validator rejects (`test_validate_plan_text_rejects_noncanonical_phase_heading`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py:251-263`). The stub plan for this feature (`.../486/plan.2026-08-17T15-00.md:30`) inherits that defect. Recorded so the new check's own plan does not trip it.

### B.2 How acceptance commands are actually expressed — measured distribution

Corpus: 164 files matching `docs/features/**/plan*.md`.

| Form | Measured count | Notes |
|---|---|---|
| `- Acceptance…:` continuation bullet (regex `^\s*-\s+\*{0,2}Acceptance\*{0,2}\s*(\(…\))?\s*:`) | **3,882 occurrences across 96 files** | Dominant form. Variants observed: `- Acceptance:`, `- Acceptance (AC4):`, `- **Acceptance:**`. |
| Fenced code blocks (`^\`\`\``) anywhere in a plan | **10 occurrences across 3 files** | Negligible. `2026-07-25-orchestrator-completion-hook-false-block-413`, `2026-07-04-release-flow-wait-for-ci-310`, `2026-06-27-harden-claude-pretooluse-hook-schema-259`. |
| Inline-backtick grep-family commands (`` `git grep …` ``, `` `grep …` ``, `` `rg …` ``) | **100 occurrences across 24 files** | |
| …of which sit on an `- Acceptance…` line | **63 occurrences across 20 files** | |
| `--cov=` occurrences | **120 occurrences across 40 files** | |

**Finding:** commands are carried as **inline code spans**, both inside `- Acceptance…:` continuation bullets and inside the task-title line itself. There is no `Command:` line convention inside plans (that convention belongs to *evidence* artifacts, per `.claude/skills/atomic-plan-contract/SKILL.md:34`). Fenced blocks can be ignored as a rounding error but should still be scanned for completeness.

### B.3 Attribution to a `P#-T#` identifier

Attribution is **reliable for content between a task line and the next task line**, and **unreliable everywhere else**. Three unattributable regions exist and all three carry commands in the real corpus:

1. **Document preamble / "Normative Context".** `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md:17` and `:22` carry a "Search-command rule" and a full "Command inventory" with dozens of backticked commands, all *before* the first `### Phase` heading.
2. **Phase preamble.** Same file `:57` and `:96-97` — prose paragraphs after a `### Phase` heading and before that phase's first task. Attributing these to the previous phase's last task would be wrong.
3. **Trailing sections** (`## Test Plan`, `## Open Questions / Notes` in the template, `:44-53`).

**Recommended attribution rule:** a command is attributable to `P#-T#` if and only if it appears on a task line matching `PLAN_TASK_RE`, or on a subsequent line that is not itself a task line and does not follow an intervening `^#{1,6} ` heading. Commands outside that window are **not analysed at all** — they cannot satisfy AC5 ("every rejection identifies the plan task identifier"), and silently attributing them would produce exactly the class of misdirected finding this feature exists to prevent.

### B.4 Extraction hazards (each is a real false-positive source)

1. **Backticks inside commands truncate the code span.** `plan.2026-08-16T22-09.md:72` writes:
   `` `grep -F "Every cohort transition, meaning every \`current_cohort\` increment" .claude/skills/parallel-orchestrate/SKILL.md` ``
   Markdown inline code has no backslash escape, so the span terminates at the first inner backtick. A naive extractor sees the fragment `grep -F "Every cohort transition, meaning every \` — an unterminated quoted pattern. **The check must skip any extracted command with unbalanced quoting rather than analyse the truncated remainder.**
2. **Bare command fragments used as prose.** `` `grep -r` `` and `` `git grep -c` `` appear as references with no operands (`:91`, `:74`). Skip commands with no pattern operand.
3. **Quoting variety.** Double-quoted, single-quoted, and `\"`-escaped-in-double all occur (`plan.2026-07-22T07-54.md:…` uses `grep -n "\"fast-uri\"" package.json`). A POSIX-ish shell-word splitter is required, not a regex.
4. **Multiple commands per acceptance bullet**, separated by `;`, `and`, or prose. Each code span is an independent unit; do not attempt to parse the surrounding prose as shell.

---

## C. Detection Mechanics per Failure Mode

### C.1 `--cov=` argument form

**Authoritative behaviour.** coverage.py 7.13.2 documentation (`https://coverage.readthedocs.io/en/7.13.2/source.html`): *"The value is a comma- or newline-separated list of **directories or importable names (packages or modules)**."* A `.py` file path is neither. pytest-cov 7.0.0 documentation describes `--cov` as *"Path or package name to measure during execution (multi-allowed)."* Versions confirmed at `poetry.lock:413-414` (coverage 7.13.2) and `:2621-2623` (pytest-cov 7.0.0).

**Consequence.** A `--cov` value that is neither an existing directory nor an importable dotted name is treated as a module name that is never imported. coverage emits `CoverageWarning: Module <X> was never imported. (module-not-imported)` and `CoverageWarning: No data was collected. (no-data-collected)`, and the process still exits 0. The threshold is unenforceable.

**In-repo empirical confirmation (three independent occurrences, all pre-existing):**

| Evidence artifact | Line | Observation |
|---|---|---|
| `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/kickoff-contract-test-run.2026-08-08T14-20.md` | `:13-25` | Planned `--cov=scripts/dev_tools/parallel_kickoff_contract` ran, exit 0, `Module … was never imported`, no data. Re-run with the dotted form produced real numbers (`:29-41`). |
| `docs/features/completed/2026-06-24-relocate-research-canonical-location-227/evidence/baseline/python.2026-06-24T13-09.md` | `:22` | "That slash form yields 'module never imported / no data' … The dotted-module `--cov` target is the mechanically equivalent form". |
| `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/qa-gates/p3-lane-assertion-coverage.2026-08-17T01-30.md` | `:30-36` | "The path forms `--cov=scripts/dev_tools/parallel_lane_assertion` and `…​.py` resolve no module and collect no data". |

**Important generalisation.** The issue names only the `.py` form, but the corpus evidence shows the *slash-path-without-`.py`* form is the more common and equally vacuous defect. Both must be covered.

**Recommended classification rule** (applied to the value `V` after `--cov=`):

| # | Condition on `V` | Verdict | Rationale |
|---|---|---|---|
| 0 | `V` contains `<`, `>`, `${`, `$(`, or `%` | **skip** | Placeholder or shell interpolation; not a literal argument. Required to exempt the single corpus hit (see C.1 counts). |
| 1 | `V` (after truncating at the first `::`) ends with `.py` | **Blocking** | Never a directory, never an importable name. Purely syntactic, time-invariant. Message must name the dotted form. |
| 2 | `V` contains `/` or `\`, and `V + ".py"` is a tracked file | **Blocking** | Path spelling of a module. Decidable, and the suggested fix is exact: `V` with separators replaced by `.`. |
| 3 | `V` contains `/` or `\`, and `V` is a tracked directory (some tracked path starts with `V + "/"`) | **accept** | Legitimate directory source, the dominant corpus form. |
| 4 | `V` contains `/` or `\`, and neither 2 nor 3 | **Warning** | Cannot resolve; may be a directory that does not exist yet, or a typo. Existence is time-varying, so not Blocking. |
| 5 | `V` matches `[A-Za-z_]\w*(\.[A-Za-z_]\w*)*` | **accept** | Dotted module/package form. |
| 6 | `V` is `.` or `` (empty, i.e. `--cov=`) | **accept** | `.` is a directory; `--cov=` explicitly disables source filtering per pytest-cov docs. |
| 7 | `--cov` appears with a **space-separated** value | **Warning only** | pytest-cov declares `--cov` with `nargs="?"`, so `pytest --cov tests/foo` consumes `tests/foo` as the source. This is genuinely ambiguous with a test-path operand and must never be Blocking. Recommend the message "use `--cov=<module>`". |

Edge cases requested, resolved by the table: `--cov=scripts/dev_tools/foo.py` → rule 1 Blocking; `--cov=scripts.dev_tools.foo` → rule 5 accept; `--cov=scripts/dev_tools` → rule 3 accept; `--cov=.` → rule 6 accept; `--cov` + separate argument → rule 7 Warning; `--cov=src/foo.py::something` → truncate at `::`, rule 1 Blocking.

**Retroactive corpus counts (measured):**

- Rule 1 (`--cov=…​.py`): **1 occurrence, 1 file** — `plan.2026-08-16T22-09.md:128`, and it is the literal string `--cov=<path>.py` inside explanatory prose. Rule 0 exempts it. **Net retroactive Blocking findings from rule 1: 0.**
- Rule 2 (slash path whose `+".py"` is tracked): **11 occurrences across 5 files** —
  `2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md:109` (`scripts/dev_tools/parallel_kickoff_contract`);
  `2026-07-03-two-axis-model-selection-286/plan.2026-07-03T16-19.md:59, :65, :97 ×2` (`compute_complexity_floor`, `resolve_delegation_model`, `_orchestrator_state_complexity`, `_orchestrator_state_model_routing`);
  `2026-06-16-propagate-claude-ecosystem-hardening-187/plan.2026-06-16T11-00.md:53, :99, :125` (`validate_orchestrator_state`);
  `2026-06-24-relocate-research-canonical-location-227/plan.2026-06-24T13-09.md:62, :98, :157` (`validate_evidence_locations`).
  All six named modules verified to exist as tracked `.py` files. **All 11 are true positives** — two of the five plans carry executor evidence confirming the gate collected nothing. Rule 2 has a measured 100% precision on the corpus.
- Rule 4 (unresolvable path): includes `--cov=extensions/drm-copilot/resources/scripts/dev_tools` and `--cov=extensions/drm-copilot/resources/templates` (`2026-03-14-bundle-hard-lock-resolver-into-extension-103/plan.2026-03-14T22-49.md:122-123`, `2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md:40-41, :138-139`), which are **not present today** (`Glob(extensions/drm-copilot/resources/scripts/dev_tools/*)` → no files). This is direct proof that filesystem-existence checks are time-varying and must not be Blocking.

### C.2 Never-matching search literals

**Regex dialect.** The check must assume the dialect the command itself selects:

| Command | Default dialect | Flag overrides |
|---|---|---|
| `git grep` | POSIX BRE | `-F` fixed, `-E` ERE, `-P` PCRE |
| GNU `grep` | POSIX BRE | `-F` fixed, `-E` ERE, `-P` PCRE |
| `rg` | Rust regex (ERE-like, `+ ? ( ) { } |` all active) | `-F` fixed |

Corpus confirms all three appear: `-F` at `2026-05-06-publish-mcp-server-to-npm-173/plan.2026-05-06T21-36.md` (multiple), `-E` at `2026-04-26-codex-native-converter-164/v2/plan.2026-04-30T19-56.md`, plain BRE throughout `plan.2026-08-16T22-09.md`.

**Recommended handling: do not attempt to reason about regex semantics.** Classify a pattern as a *checkable literal* only when either
(a) the command carries `-F`, or
(b) the pattern contains **none** of `. * [ ] ^ $ \ ( ) { } | + ?`.
Condition (b) is conservative in every dialect simultaneously, so no dialect-selection logic is needed. Everything else is **skipped silently**.

Corpus impact of this conservatism, from the sampled grep commands: skipped patterns include `^` (line-count idiom `grep -c ^ <file>`), `"recolor_unstarted("`, `'"9"\|found: 9\| 9,'`, and `-E "a|b"`. Checkable patterns include `"pinned items occupy"`, `"through 32"`, `"MAX_CONCURRENCY = 8"`, `"only after every cohort"`, `"@hono/node-server"`, `'MIT License'`. That is a usable majority.

**Recommended matching mechanism: delegate to `git grep -F -l` itself, through an injected `CommandRunner`.** Reimplementing matching would create a fourth implementation that can disagree with the command being validated. Using the same tool guarantees the check's verdict and the gate's verdict are produced by the same matcher. The seam already exists: `scripts/dev_tools/pr_context/git.py:15-24` (`CommandRunner` Protocol) and `:98-99` (`run(["git", …])`); `epic_planner_git_integrity.py:36-48` shows the adapter pattern (`GitReadinessRepository(workspace_root, runner)`).

**Scope of the absence test:** the **whole tracked tree**, deliberately ignoring the command's own pathspec. Presence anywhere in the repository exonerates the pattern. This makes the check maximally conservative and correctly exonerates pathspec-scoped negative regression guards such as `git grep -n "through 32" -- <three python files>` (`plan.2026-08-16T22-09.md:101`), where the literal is present elsewhere in the tree.

### C.3 Phrase wrapping

**What signal is actually available.**

- *Formatter wrap column* is available only for machine-formatted languages: Black/Ruff `line-length = 88` (`pyproject.toml:85, :89`); Prettier default `printWidth` 80 for the extension's `format` glob `"src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (`extensions/drm-copilot/package.json:207`). **No `.prettierrc*` exists anywhere in the repo** (`SearchScope:` repo root recursive; `SearchPatterns:` `**/.prettierrc*`; `SearchResult:` none), and Markdown is not in the Prettier glob. Markdown wrapping is authorial, not mechanical — and Markdown is exactly where the #479 failure occurred (`.claude/skills/parallel-add/SKILL.md:89-90`, hand-wrapped at ~100 columns). **The wrap-column signal is therefore unusable for the observed failure mode.**
- *Word count* ("pattern spans a word-boundary count high enough that wrapping is plausible", per the issue) is a pure heuristic with no ground truth. On the sampled corpus it would fire on `"Every cohort transition, meaning every …"`, `"only after every cohort"`, `"pinned items occupy"` — of which only some actually wrap. False-positive rate is essentially the fraction of long literals that happen to sit on one line, which is high.
- *Cross-line presence* is decidable and exact: normalise runs of whitespace to a single space across a sliding window of consecutive non-blank lines; if the literal is contained in some window's normalised join but in **no single line**, the command provably returns zero matches against the current tree.

**Recommendation, split into two rules:**

- **C3a — cross-line presence (Blocking).** Literal absent from every single line but present in the whitespace-normalised join of ≤ 4 adjacent non-blank lines of some tracked file. This is a *proof* that the command as written returns zero matches now, and it carries an exact remedy: search a shorter single-line token (precisely the repair `plan.2026-08-16T22-09.md:80` and `:107` document — "the two-token tail `through 8` is used deliberately: the phrase wraps across `parallel-orchestrate/SKILL.md:67-68`"). **False-positive risk: low but non-zero** — a task that rewrites exactly that wrapped line to be contiguous would be falsely rejected. Mitigation: exonerate when the literal appears contiguously anywhere in the plan document itself (i.e. the plan quotes the text it will write). Residual risk after mitigation: a plan that unwraps a line without quoting the result.
- **C3b — word-count heuristic (Warning only, or omit).** I recommend **omitting** C3b entirely rather than shipping it as a warning. It has no evidentiary basis, and a warning stream with a high false-positive rate trains readers to ignore the whole report — which is the failure mode this feature is meant to remove. If the feature owner wants coverage of "this might wrap after the executor edits the file", the defensible form is authoring guidance in `.claude/skills/atomic-plan-contract/SKILL.md`, not a validator rule. **I am recording this as a recommendation against a bullet the issue explicitly asks for; the decision belongs to the feature owner.**

---

## D. The False-Rejection Problem

This is the load-bearing question. A pattern legitimately absent at authoring time *because the task creates it* is the normal case, and the corpus is full of it.

### D.1 What information is actually available at plan-acceptance time

Exactly three sources, all present and all cheap:

1. **The tracked file set at the plan's HEAD** — via `git grep` / `git ls-files` through the injected runner.
2. **The plan document text itself** — already in hand; it is the validator's only argument today.
3. **The command's own flags and operands** — dialect, fixed-string mode, pathspec.

Nothing else. In particular the validator has **no** access to: the executor's future edits, the spec/issue documents (not passed to the `plan` route), or the diff the task will produce.

### D.2 Verifying the issue's claim that the interpolated case is "detectable structurally"

**The claim is only partially true as stated.** Two candidate structural signals exist; one is sound and one is not.

**Candidate 1 — interpolation-boundary alignment (sound but narrow).** Take the literal `L`. Find the longest prefix `P` of `L` that matches on a single line of a tracked file. Check whether the character immediately following `P` on that line opens an interpolation: `{` inside an f-string, `${` in TypeScript/bash, `$(`, `%s`, `{}`. If so, and if the remainder of `L` after the interpolation's closing delimiter also matches on that same line, the literal is provably non-contiguous **for that file today**. Worked example from #479: the plan's expected error text `… from 1 through 32; found: 33.` against `scripts/dev_tools/validate_parallel_orchestrator_state.py:146-148`, which the plan itself records as f-string interpolated (`plan.2026-08-16T22-09.md:100`: "The three error messages … interpolate `MAX_CONCURRENCY` via f-strings").
*Limitation:* this signal requires the surrounding template to already exist in the tree. When the task **creates** the interpolated message, the signal is unavailable. It is therefore a detector for "you wrote the rendered string but the template is already interpolated", which is the #479 case, and nothing broader.

**Candidate 2 — whole-tree absence alone (NOT sound).** "Literal absent from every tracked file" is exactly the same observation for (i) an interpolated message that can never match and (ii) a message the task is about to write verbatim. **The distinction is not decidable from absence alone.** The issue's AC1 ("a plan containing an acceptance grep for a literal absent from every tracked file is rejected") is, taken literally, a false-rejection generator.

### D.3 Recommended resolution — the plan-quotation exoneration

Reject on absence **only when the plan itself never mentions the literal**:

> **Rule D — unsatisfiable literal (Blocking).** A checkable literal `L` (per C.2) is Blocking when *both*:
> (i) `git grep -F -l -- L` over the whole tracked tree returns no file, **and**
> (ii) `L` does not occur contiguously anywhere in the plan document outside the acceptance command span itself.

Rationale: the canonical plan style already quotes insert text verbatim — `plan.2026-08-16T22-09.md:71` ("containing verbatim: \"An item may start only when every conflicting neighbour …\""), `:79` ("The reworded text must not use the phrase \"pinned items\" in either file, so the acceptance grep below is a real detector"). If the plan tells the executor to write text `L`, condition (ii) fails and the gate is exonerated. If `L` appears nowhere in the tree and nowhere in the instructions, **nobody has been told to create it**, so the gate cannot pass no matter what the executor does. That is a genuine proof of non-discrimination.

**Polarity does not need to be parsed.** A negative gate (acceptance = zero matches) whose literal is absent from the tree *and* un-creatable is also non-discriminating — it passes vacuously. Rule D is therefore correct in both directions and does not require reading the acceptance prose to determine whether the author wanted matches or no matches. **This is the property that makes the rule shippable without the deferred expected-exit-code field.**

**Honest statement of residual false-positive risk.** Rule D falsely rejects when a plan instructs an edit in paraphrase ("add the per-edge rule") and then asserts a grep for the exact sentence it never quoted. I estimate this is uncommon in the recent corpus and common in the older corpus. I did **not** measure it: computing it requires executing `git grep` per literal across ~63 candidate acceptance commands, and this research pass is read-only with no shell tool available. **This count is unknown and should be measured during implementation before the rule is set to Blocking.** If the measured false-positive rate exceeds a small handful, Rule D should ship as a Warning in its first release.

### D.4 Sub-cases I recommend be Warnings, stated plainly

| Sub-case | Verdict | Why not Blocking |
|---|---|---|
| `--cov=` path that resolves to neither tracked file nor tracked directory (C.1 rule 4) | Warning | Existence is time-varying; proven by the vanished `extensions/drm-copilot/resources/templates` path. |
| `--cov` with a space-separated value (C.1 rule 7) | Warning | Genuinely ambiguous with a pytest test-path operand. |
| Literal absent from tree **and** quoted in the plan (Rule D condition (ii) fails) | silent accept | The normal "task will create it" case. |
| Long multi-word literal with no cross-line evidence (C3b) | omit | No evidentiary basis; recommend authoring guidance instead. |
| Command with unbalanced quoting after code-span extraction (B.4 hazard 1) | silent skip | Extraction artefact, not a plan defect. |
| Pattern containing any regex metacharacter without `-F` (C.2) | silent skip | Dialect-dependent; conservative refusal. |

---

## E. Parity and Corpus Constraints

### E.1 Must the check ship in both runtimes?

**Yes for Python and TypeScript. No for PowerShell.**

- `.claude/rules/parallel-orchestration.md` (Enforcement section) establishes the standing expectation: "The TypeScript parity port … reproduces the same invariants and is dispatched from `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`". The `plan` route is dispatched from that same file, so it is inside the parity surface.
- `.claude/rules/orchestrator-state.md` establishes that enforcement is validator logic plus prose, never an imported JSON Schema. Applies here too: the new rules must be expressed as prose in a rule file and as validator logic, not as a schema.
- The issue's own Constraints section: "If the check lands in a surface that has both a Python implementation and a TypeScript port, both must be updated together."
- **PowerShell must be left alone.** Persistent-memory feedback recorded 2026-08-15 ("Enforcement hooks must not use Python; bash preferred, PowerShell acceptable") exists precisely because a hook that reaches a second implementation of a rule drifts from it. `.claude/hooks/validate-planner-output.ps1` already duplicates plan-structure validation; adding a third copy of the new rules there — which would require `git grep` invocation and tracked-file resolution from PowerShell — multiplies the drift surface for no gain, because the MCP validator gate is already mandatory (`atomic-plan-contract/SKILL.md:152-158`). **Recommendation: do not touch `validate-planner-output.ps1`.**

### E.2 Which recorded divergence classes could bite this check

`.claude/rules/parallel-orchestration.md` records three known Python↔TypeScript divergence classes. Assessment for this check:

| Divergence class | Applies here? | Reasoning |
|---|---|---|
| **`pythonRepr` quote selection** (`parallel-state-shared.ts:112-132` always single-quotes; Python `repr` switches to double quotes when the value contains a single quote) | **YES — live risk** | New error messages will embed the offending pattern or `--cov` value. Grep patterns in the corpus contain single quotes (e.g. `grep -F 'MIT License'`, and prose literals with apostrophes). If the Python side formats with `!r` and the TS side with `pythonRepr`, quoting diverges. **Mitigation: format offending values in backticks, never with `repr()`/`!r`, in both runtimes.** This neutralises the class by construction. |
| **Integral floats** (`JSON.parse` erases Python's `int`/`float` distinction) | No | The plan artifact is Markdown, not JSON. No numeric round-trip occurs. |
| **Boolean/integer equality** (`parallel-state-structures.ts:228` uses `===` where Python's `True == 1` holds) | No | Same reason: no JSON value coercion in this route. |

One **new** divergence risk not on that list: the two runtimes must produce the same tracked-file answer. Both should shell out to the same `git` binary through their respective runner seams (`scripts/dev_tools/pr_context/git.py` / `extensions/drm-copilot/src/lib/subprocess-runner.ts`, already wired for the epic route at `orchestration-artifacts.ts:250-256`), and neither should reimplement matching. Line-ending handling must also match: the Python `str.splitlines()` and the TS `/\r\n|\n|\r/` split (`orchestration-artifacts.ts:82`) already agree; the new window-join logic must reuse the same split.

### E.3 The "must not block on historical artifacts" requirement

**Negative evidence — no grandfathering mechanism exists.**
- `SearchScope:` `scripts/**`, `.claude/**`
- `SearchPatterns:` `grandfather`, `legacy_exempt`, `historical artifact`, `retroactive`, `pre-existing plans`, `exempt`
- `SearchResult:` only semantic uses of "exempt" for withdrawn parallel items (`validate_parallel_orchestrator_state.py:242`, `_parallel_state_structures.py:64`, `_parallel_orchestrator_state_mode_completion.py:86`) and one comment about historical routing behaviour (`OrchestratorStateRoutingMatrix.psm1:275`). **No date-based, path-based, or version-based exemption precedent exists.**

**The de facto mechanism is scope of invocation.** The plan validator only ever runs against the one artifact passed to it (`validate_orchestration_artifacts.py:305-310`; `validate-orchestration-service-call.ts:72-75`). No CI job and no test sweeps the corpus (see A.3 negative evidence). A committed plan is therefore never validated again unless a human explicitly points the tool at it. **This satisfies "must not block on historical artifacts" with no new mechanism.**

The nearest structural precedent for "gate at authoring time, not by corpus scan" is `.claude/hooks/enforce-evidence-locations.ps1`, which inspects the `Write`/`Edit` tool input rather than scanning existing files (`:1-39`).

**Recommendation: add no exemption mechanism.** Record the scope-of-invocation argument in the rule file so a later reader does not add one. Measured retroactive impact if someone *does* point the tool at every committed plan: 0 Blocking findings from C.1 rule 1, 11 from C.1 rule 2 across 5 plans (all true positives), and an unmeasured number from Rule D and C3a.

---

## F. Test Surface

### F.1 Where tests live and their conventions

| Runtime | Test file | Conventions observed |
|---|---|---|
| Python | `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` | Module-level `import scripts.dev_tools.validate_orchestration_artifacts as validator`; builder functions returning fixture text (`build_valid_policy_audit_text`, `:57`); plan tests build text with `"\n".join((...))` (`:251-279`); assertions use `any(<substring> in error for error in errors)`. Companion modules exist for split concerns: `test_validate_orchestration_artifacts_dispatch.py`, `..._state_shape.py`, `..._parallel_dispatch.py`, `..._model_routing.py`, `..._codex_topology_cli.py`. **A new sibling module (e.g. `test_validate_orchestration_artifacts_gate_discrimination.py`) is the established pattern and avoids the 500-line ceiling.** |
| TypeScript | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | `VALID_PLAN` const array joined with `\n` (`:10-17`); `describe`/`it`; explicit `// Arrange / Act / Assert` comments; `it.each` for matrices (`:25-34`). |
| PowerShell | `tests/scripts/claude-hooks/*.Tests.ps1` | Not in scope per E.1. |

### F.2 Coverage obligations

- `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`: **line ≥ 85%, branch ≥ 75%, uniform across T1–T4**, for both Python (pytest-cov) and TypeScript (Jest/lcov).
- Coverage Exclusion Policy: no production file may be excluded. Any new module under `scripts/dev_tools/` or `extensions/drm-copilot/src/` is in the denominator.
- **Negative evidence — the tier map is missing.** `SearchScope:` repo root recursive. `SearchPatterns:` `**/quality-tiers.yml`. `SearchResult:` none. `.claude/rules/quality-tiers.md` states `quality-tiers.yml` at repo root is the source of truth and that an unclassified project fails CI. Since the thresholds are uniform, the absence does not change this feature's obligation, but it is a pre-existing gap worth reporting separately.
- File-size ceiling: 500 lines for any production or test file (`.claude/rules/general-code-change.md`). `validate_orchestration_artifacts.py` is currently 399 lines — **101 lines of headroom**, which is not enough for the new rules plus their helpers. Plan for a new helper module (Python) and a new `src/lib/validate/*.ts` module, mirroring the existing split pattern (`_parallel_state_records.py`, `parallel-state-records.ts`).
- **Coverage command form:** use the dotted module form. `poetry run pytest … --cov=scripts.dev_tools.<new_module>`. Do **not** write `--cov=scripts/dev_tools/<new_module>.py` — that is the exact defect this feature exists to prevent, and it appears in the corpus 11 times.

### F.3 Fixtures without temporary files

`.claude/rules/general-unit-test.md` and `.claude/rules/python.md:87` prohibit runtime temp files outright. Three established patterns cover everything needed:

1. **Plan text fixtures:** in-memory string constants, exactly as `test_validate_orchestration_artifacts.py:251-279` and `orchestration-artifacts.test.ts:10-17` already do. No file needed.
2. **Controlled tracked-file set:** inject a fake `CommandRunner` / git repository. Precedent: `epic_planner_git_integrity.py:20-34` (`ReadinessGitRepository` Protocol) and `epic_planner_readiness.py:30-71` (`ReadinessFileSystem` Protocol + `LocalReadinessFileSystem`). The unit test supplies a stub whose `git grep -F -l` returns a canned file list and whose file reads return canned text. This satisfies "no external processes in unit tests" while keeping the production path identical to the command under validation.
3. **In-memory `Path` when a real `Path` API is required:** `tests/conftest.py:145-171` provides the `mem_fs_path` fixture. `tests/scripts/dev_tools/test_validate_evidence_locations.py:31-117` shows the alternative of mocking `rglob` on a `MagicMock` root with an explicit docstring noting "No temporary filesystem access is used in these tests".

TypeScript equivalent: the injected `FileSystem` and `CommandRunner` interfaces already threaded through `validateArtifact` (`orchestration-artifacts.ts:172-176`, `250-256`).

### F.4 Required scenario matrix

- `--cov` classification: one case per row of the C.1 table, including the placeholder-skip row and the `::` truncation row (parametrized).
- Literal absence: present-in-tree accept; absent-from-tree-but-quoted-in-plan accept; absent-from-both reject; metacharacter pattern skipped; `-F` pattern checked; unbalanced-quote extraction skipped.
- Cross-line: single-line present accept; cross-line-only reject; cross-line present but quoted contiguously in plan accept; window boundary (5 lines apart) not joined.
- Attribution: rejection message names `P#-T#`; command in document preamble not analysed; command in phase preamble not analysed; command after a `##` heading not analysed.
- Zero-violation path: every plan in the sampled clean set returns `[]`; the pre-change error list for a structurally invalid plan is **byte-identical** before and after (AC3).
- Dispatcher: `plan` route with and without an injected repository context; without context, output is byte-identical to today.
- CLI: exit 0 with the existing success line on the clean path; exit 1 with one line per error on the violation path (`validate_orchestration_artifacts.py:388-394`).

---

## Recommended Design (Summary)

**Placement.** Extend the existing `plan` route in both runtimes. No new `artifact_type`, no new MCP flag, no MCP schema change.

- Python: new module `scripts/dev_tools/plan_gate_discrimination.py` exposing `validate_plan_gate_discrimination(text, context=None) -> list[str]`; called from `validate_plan_text` (or from `_validate_from_args` for the context-bearing form). Add `--workspace-root` (default `.`) to the `plan` subparser, mirroring `epic-planner-state` (`:250-254`).
- TypeScript: new module `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`; called from the `case "plan"` branch, which begins using the `fs`, `root`, and `runner` it already receives (`validate-orchestration-service-call.ts:94-97`).
- Context object mirrors `EpicReadinessContext` (`epic_planner_readiness.py:73-99`): `{ workspace_root, file_system, git }`, with a `git grep`-backed adapter and a Protocol for tests.
- **Graceful degradation:** with no context, only C.1 rules 0/1/5/6/7 (pure syntax) run. With context, C.1 rule 2/3/4, Rule D, and C3a additionally run. Existing pure-text unit tests keep producing byte-identical output.

**Rule set shipped.**

| ID | Rule | Severity | Context needed |
|---|---|---|---|
| G1 | `--cov=…​.py` (after `::` truncation), no placeholder | Blocking | no |
| G2 | `--cov=<slash path>` where `<path>.py` is tracked | Blocking | yes |
| G3 | `--cov=<slash path>` resolving to nothing | Warning | yes |
| G4 | `--cov` with space-separated value | Warning | no |
| G5 | Checkable literal absent from tracked tree **and** from the plan text | Blocking | yes |
| G6 | Checkable literal present only across adjacent lines (normalised join), not on any single line, and not quoted contiguously in the plan | Blocking | yes |
| — | Word-count wrap heuristic | **not shipped** | — |

**Message contract.** Every message begins with the task identifier and states the specific reason and the mechanical remedy, e.g.
`[P3-T4] --cov argument 'scripts/dev_tools/foo.py' names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.`
Offending values are rendered in the message **without `repr()`/`!r`**, to avoid the recorded `pythonRepr` quote-selection divergence.

**Prose home.** Record the rules and the "no grandfathering, scope-of-invocation is the exemption" argument in a new rule file (`.claude/rules/plan-acceptance-gates.md`) and cross-reference it from `.claude/skills/atomic-plan-contract/SKILL.md`, following the precedent that enforcement is prose plus validator logic, never an imported schema.

### Rejected alternatives

- **New MCP flag `require_discriminating_gates` (opt-in).** Rejected: an opt-in flag cannot satisfy AC4 ("invoked automatically … not only on explicit request"), and it adds an MCP schema field for no behavioural gain.
- **New `artifact_type: "plan-gates"`.** Rejected: splits the mandated gate into two calls, so a caller can run one and skip the other.
- **Implement in the PowerShell SubagentStop hook.** Rejected: creates a third implementation of the rules that must be kept in parity with two others, contradicting recorded feedback about hook implementations drifting; and the hook cannot reach a `git grep` result without either Python (prohibited) or new PowerShell git plumbing.
- **Reimplement pattern matching inside the validator.** Rejected: a matcher that disagrees with `git grep` would produce exactly the class of defect this feature exists to prevent.
- **Reject on whole-tree absence alone (literal AC1 reading).** Rejected: not decidable against "the task will create it"; see D.2/D.3.

---

## Deferred Dependency — Bullet 4 (Expected Exit Code)

Out of scope for #486; tracked by `2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit.md`. **The seam where a later feature attaches it:**

The command record produced by the extractor in B.3/B.4 is the attachment point. It should be a value object of the shape `{ task_id, source_line, raw_span, argv[], kind }` where `kind ∈ {grep, pytest_cov, other}`. A later feature adds an `expected_exit_code: int | None` field populated from a declared acceptance condition, and the polarity-dependent rules (which this feature deliberately avoids needing — see D.3) become expressible on top of it.

**This design does not foreclose that field, and does not require it:** Rule G5 is polarity-independent by construction, so no rule shipped here needs to be revisited when the field arrives. The extractor must be authored as a reusable module returning that value object rather than as inline logic inside the rule functions.

---

## Automation Feasibility

**This feature is fully automatable with no human-interaction requirement.** Every artifact it touches (Python validator, TypeScript port, unit tests, a rule file, a skill cross-reference) is editable by the standard agent toolchain, and every gate it must pass (Black, Ruff, Pyright, pytest+coverage, Prettier, ESLint, tsc, Jest) is runnable locally on this host.

Specifically checked for blockers, none found:
- No PowerShell change is required (E.1), so no `run_poshqc_*` MCP dependency arises.
- No bash change is required, so the CI-dispatch verification path (`_shell-coverage.yml`) that no delegate can run locally is not needed.
- No MCP schema change is required (A.3), so no extension rebuild/bundle step is forced.
- No new third-party dependency is required; `git` is already reached through existing runner seams.

**One exception found, and it is a measurement, not an interaction:** the false-positive rate of Rule G5 against the committed corpus (D.3) is currently unmeasured and requires executing `git grep` per candidate literal. That is an automatable measurement task for the executor; it does not require a human decision unless the measured rate is high, in which case the severity of G5 (Blocking vs Warning) becomes a scope decision for the feature owner.

---

## Open Questions / Risks

1. **Rule G5's corpus false-positive rate is unknown.** I could not execute `git grep` in this read-only pass. This is the single largest uncertainty in the design. **Recommendation: the plan must include an explicit measurement task that runs G5 over all 63 acceptance-line grep commands in the corpus and records the true/false-positive split, before G5's severity is fixed.** If the false-positive count exceeds roughly 3, ship G5 as Warning.
2. **C3b (word-count wrap heuristic) is a bullet in the issue that I recommend not implementing.** I am confident the heuristic has no evidentiary basis for Markdown targets (no formatter wrap column exists), and moderately confident that shipping it as a warning would degrade the report's signal. This is a recommendation against a stated requirement and needs the feature owner's decision.
3. **Whether the plan-quotation exoneration (D.3 condition (ii)) should compare normalised or raw text is undecided.** Raw comparison misses a plan that quotes the sentence across its own line wrap (plans wrap too). Normalised comparison is more forgiving but slightly weaker. I lean normalised, matching C3a's normalisation, but have not validated it against examples.
4. **Command extraction from Markdown inline code is not fully solved.** The backtick-truncation hazard (B.4 hazard 1) is real and appears in the corpus. The recommended response (skip unbalanced commands) is safe but silently drops real gates, including at least one in the #479 plan. There is no cheap general fix; CommonMark multi-backtick spans would fix it only if authors adopt them.
5. **Sliding-window size for C3a (recommended 4 adjacent lines) is a guess.** The observed #479 case wrapped across 2 lines. A larger window increases recall and false-positive risk. I have not measured the distribution of wrap depths.
6. **`--cov` space-separated detection interacts with pytest positional test paths.** `pytest --cov tests/foo.py` is genuinely ambiguous. G4 is a Warning for this reason, but the warning itself may be noisy. I did not measure how often the space-separated form appears in the corpus.
7. **`git grep` from the validator runs against the working tree, not a fixed commit.** Two runs of the same plan can disagree if the tree changed between them. This is acceptable for an authoring-time gate but means the check is **not** reproducible from the plan text alone. Consider recording the HEAD sha in the message so a later reader can reproduce the verdict.
8. **The PowerShell hook remains a divergent third implementation of plan structure.** This feature does not make that worse, but it also does not fix it. Worth filing separately.
9. **The plan template's `### Phase 0:` colon form is invalid against the canonical validator** (B.1). Pre-existing; the stub plan for this very feature inherits it and will fail the validator until corrected. Worth filing separately.
10. **`quality-tiers.yml` is absent from the repository root** despite `.claude/rules/quality-tiers.md` declaring it the source of truth and declaring that an unclassified project fails CI. Pre-existing; does not change this feature's uniform thresholds. Worth filing separately.
