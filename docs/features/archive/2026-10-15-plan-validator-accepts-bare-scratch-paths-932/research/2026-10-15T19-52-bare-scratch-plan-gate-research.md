# Research: Plan-Acceptance Gate for Bare SCRATCH Definitions (Issue #932)

- **Issue:** #932 (bug, full-bug)
- **Branch:** bug/plan-validator-accepts-bare-scratch-paths-932 (based on origin/main adb9aa5f0)
- **Timestamp:** 2026-10-15T19-52 (UTC)
- **Researcher:** task-researcher
- **Scope:** Research only. No file other than this artifact was written. The stale copy under the non-conforming name `bare-scratch-plan-gate.2026-10-15T19-52.md` in this folder should be deleted.

All paths are repository-relative to the worktree root. Line numbers were taken from the current tree with the Read and Grep tools in this session.

## Tooling Limitation

The session had Read, Grep, Glob, Write, Edit, and WebFetch only. No shell was available, so:

- `git grep`, `git show`, `wc -l`, and the toolchain could not be run. Corpus searches used ripgrep (the Grep tool) over the working tree. `git status` at session start reported the worktree clean, so the working tree equals the tracked tree at `3a81781a4`.
- Line counts were taken with a Grep `^` count per file.
- The host clock could not be read. The filename timestamp `2026-10-15T19-52` came from `https://timeapi.io/api/Time/current/zone?timeZone=UTC` (returned `2026-10-15T19:52:34`). This is a network clock, not the host clock that the evidence conventions require. The orchestrator may rename the file if a host-clock stamp is required.
- No current coverage baseline was produced (see Q6).

## Summary of Findings

1. The #900 rule is in four primary sources and their four bundle copies. It is not in `.github/`, `.codex/`, or any rule file. Canonical form: `` `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` ``. A run-unique variant is `issue-<issue-num>-<yyyy-MM-ddTHH-mm>`.
2. G1 through G9 decide **commands that are attributed to a task**. A SCRATCH definition is prose in a plan preamble or terms list, so the extractor never sees it. G10 therefore needs a new document-level, context-free rule in a new module in each runtime. `plan_gate_observability.py` (477 lines), `plan-gate-observability.ts` (494), `validate_orchestration_artifacts.py` (498), and `test_plan_gate_parity.py` (493) are all close to the 500-line limit.
3. A statically decidable pattern exists. In the committed corpus, 18 plan files define `SCRATCH`. Under the recommended predicate, 17 of them would be flagged and 1 (#900's own plan) accepted. No CI job, test, or hook validates committed plans, so a Blocking G10 breaks no existing test.
4. Only `.claude/rules/plan-acceptance-gates.md` and `.claude/skills/atomic-plan-contract/SKILL.md` (plus one bundle copy of each) state the shipped gate set. Byte or text parity is pinned by `test_push_down_claude_resource_contracts.py`.
5. The atomic-executor persona's Bash allowlist does not include `poetry run python`, so it cannot run the Codex generator in write mode. Recommended route: make the same Edit-tool insertion in all 24 TOML files, then verify with the generator's `--check` mode through pytest.

## Q1 — The #900 Scratch Rule

### Surfaces (verified by `Grep SCRATCH` over the whole tree excluding `docs/**`)

| Surface | Section and lines |
|---|---|
| `.claude/agents/atomic-planner.md` | `## Scratch Location` at 58; rule bullets 62-66; between `## Requirements` (50) and `## Preflight Validation` (68) |
| `.claude/agents/atomic-executor.md` | `## Scratch Location` at 85; bullets 89-94; between `## Toolchain Commands` and `## Preflight Validation` (96) |
| `.agents/skills/atomic-planner/SKILL.md` | `## Scratch Location` at 37; bullets 41-45; before `## Mandatory Preflight Loop` (47) |
| `.agents/skills/atomic-executor/SKILL.md` | `## Scratch Location` at 58; bullets 62-67; before `## Non-Negotiable Constraints` (69) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` | 62-65 (copy) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` | 89-93 (copy) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md` | 41-44 (copy) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md` | 62-66 (copy) |

No `SCRATCH` text exists in `.github/**`, `.codex/**`, `.claude/rules/**`, or `.claude/skills/**`.

### Exact planner text (`.claude/agents/atomic-planner.md:60-66`)

```text
Concurrent child runs in one session share one session scratchpad, so every plan places its scratch files in a directory unique to the child.

- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`, where `<issue-num>` is the plan's canonical issue number. Every plan that uses scratch files defines `SCRATCH` this way.
- Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`. Subdirectories such as `SCRATCH/stage/` are permitted.
- A plan never directs a scratch file to the scratchpad root or to a fixed shared name outside `SCRATCH`.
- Plans and evidence artifacts record the literal token `SCRATCH`, never a host path.
- If two runs for the same issue can execute at once, the run-unique form `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` replaces `issue-<issue-num>`.
```

The executor text (`.claude/agents/atomic-executor.md:87-94`) has the same first, second, fifth, and sixth bullets, plus:

- "Create `SCRATCH` before the first scratch write. Never write a scratch file to the scratchpad root or to a fixed shared name outside `SCRATCH`."
- "When a plan written before this rule defines `SCRATCH` as the bare session scratchpad, treat that definition as `<session scratchpad>/issue-<issue-num>/`. This is a mechanical micro-action, not replanning."

### Canonical form

`SCRATCH` = `<session scratchpad>/issue-<issue-num>/`. A plan can write the concrete form, for example `issue-900`, as #900's own plan did at `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/plan.2026-10-11T10-38.md:20`. Concrete form when runs are concurrent: `issue-<issue-num>-<yyyy-MM-ddTHH-mm>`.

### Contract-test pins on that text (`tests/scripts/dev_tools/test_scratch_location_contracts.py`, 275 lines)

- `PINNED_RULE_PHRASE` (70), `ISSUE_DIRECTORY_SEGMENT` (71), `SCOPE_PHRASE` (72), `LITERAL_MARKER_PHRASE` (73), `PLANNER_NO_ROOT_PHRASE` (74-76), `EXECUTOR_CREATE_PHRASE` (77), `EXECUTOR_PRE_RULE_PHRASE` (78-80).
- `NORMATIVE_SURFACE_GLOBS` (88-92): `.claude/agents/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`.
- `FORBIDDEN_SCRATCH_PATHS` (93-100): `SCRATCH/run-ps.sh`, `SCRATCH/changed-line-coverage.ps1`, `SCRATCH/cov-final.txt`, `SCRATCH/cov-final.xml`, `SCRATCH/region-probe.ps1`, `<scratchpad>/`.
- The scan test is `test_normative_surfaces_name_no_bare_fixed_scratch_path` (258-275).

## Q2 — Plan-Gate Architecture

### Python authority

| Module | Lines | Role |
|---|---|---|
| `scripts/dev_tools/plan_gate_commands.py` | 365 | Extracts task-attributed command spans (`extract_plan_commands`, 292-365). `PLAN_GATE_TASK_RE` (20-22), `_FENCE_RE = ^\s*```` (26). Spans outside a task window are dropped (355-356). |
| `scripts/dev_tools/plan_gate_coverage.py` | 243 | G1-G4 cascade (`cov_values`, `evaluate_cov_value`, `is_placeholder`). |
| `scripts/dev_tools/plan_gate_discrimination.py` | 392 | `BLOCKING_CHANNEL`/`WARNING_CHANNEL` (49-50), `G5_SEVERITY` (59), `PlanGateReport` (62-77), `PlanGateContext`, `GitPlanGateRepository`, G5/G6 (283-348). Entry point `evaluate_plan_gates(text, *, context=None)` (351-392): cov rules, then `evaluate_observability_gates`, then the literal rules when a context is present. |
| `scripts/dev_tools/plan_gate_observability.py` | 477 | G7/G8/G8b/G9. Declares its own channel constants (55-56) to avoid an import cycle. `G7_SEVERITY`..`G9_SEVERITY` (63-66). Per-rule `_append(report, severity, finding)` (204-208). |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | 498 | `PLAN_GATE_WARNING_PREFIX = "PLAN GATE WARNING: "` (52). `validate_plan_text` (78-100) is single-channel and context-free. `validate_plan_text_with_warnings` (103-131) returns `structure_errors + report.blocking` and `report.warnings`. `_plan_channels` builds the context (369-374). `main` prints errors, then warnings with the prefix, and exits 1 only on errors (481-494). |

Registration is by direct call. There is no registry or ID table. Each rule appends to `report.blocking` or `report.warnings` according to its module-level `G#_SEVERITY` constant.

Finding format: every G1-G9 message starts with `[P#-T#] ` and renders the offending value between backticks. `repr()`, `!r`, and `pythonRepr(` are prohibited (`.claude/rules/plan-acceptance-gates.md:231-242`). Structural errors use a `Line N: ` prefix (`validate_orchestration_artifacts.py:150-187`).

### TypeScript twins (`extensions/drm-copilot/src/lib/validate/`)

| Module | Lines | Role |
|---|---|---|
| `plan-gate-commands.ts` | 443 | Extractor port. |
| `plan-gate-rules.ts` | 437 | Shared predicates, `BLOCKING_CHANNEL`, `emptyPlanGateReport`, G1-G4. |
| `plan-gate-discrimination.ts` | 284 | `G5_SEVERITY = "warning"` (80), `CommandRunnerPlanGateRepository`, G5/G6, `evaluatePlanGates(text, context?)` (260-284), re-exports (38-69). |
| `plan-gate-observability.ts` | 494 | G7-G9 and their severity constants. |
| `orchestration-artifacts.ts` | 369 | `validatePlanText` (79-157, structure only). `validateArtifactWithWarnings` (228-243) concatenates `validatePlanText` and `report.blocking`. `buildPlanGateContext` (197-213). |
| `validate-orchestration-service-call.ts` | 134 | MCP surface. `PLAN_GATE_WARNING_PREFIX` (63). Throws on errors (112-124). The optional `warnings` field (128-133). |

There are **no bundled copies of the validator code** under `extensions/drm-copilot/resources/`: Glob for `*plan*gate*` and `validate_orchestration_artifacts*` under `resources/`, `dist/`, `out/`, and `lib/` found only the rule-file copy. The MCP tool runs the TypeScript port from the built extension, so after merge G10 reaches the MCP route only after the extension is rebuilt and reinstalled.

### Parity and pin tests

| Test | What it pins |
|---|---|
| `tests/scripts/dev_tools/test_plan_gate_parity.py` (493 lines) | Frozen finding strings for G1-G9 (121-205). Severity-constant parity by regex over the TS sources (61-65, 416-470). The no-`repr` check over `_PYTHON_GATE_MODULES` (45-49, 473-486). Extractor task-regex equality (489-493). |
| `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` (389 lines) | The same fixtures and strings. The no-`pythonRepr(` check over the module list at 315-318 (380-386). |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:80-83, 415-422` | `plan-acceptance-gates.md` `paths:` must reach both dispatchers. The existing globs `scripts/dev_tools/plan_gate_*` and `extensions/drm-copilot/src/lib/validate/plan-gate-*` already match the new module names proposed below. |
| `extensions/drm-copilot/jest.config.cjs:359-384` | Per-file 85/75 thresholds for each `plan-gate-*.ts`. The map has no `global` key, so a new file without an entry is ungated (comment at 413-415). |
| Other gate suites | `test_plan_gate_commands.py`, `test_plan_gate_discrimination_{context,cov,literals}.py`, `test_plan_gate_observability{,_boundaries}.py`, `test_validate_orchestration_artifacts_plan_gates.py` (449), and the matching `*.test.ts` files. None contains the token `SCRATCH`; the Grep for `SCRATCH` outside `docs/` found it only in the scratch contract test. |

### Next gate ID and severity

- Next ID: **G10**. G8b is the only suffixed ID, and the next free integer is 10.
- Recommendation: **Blocking**. The issue expects preflight rejection. The detector is context-free and deterministic, and the corpus classification below records 0 false positives under the predicate's stated claim.
- Precedent caveat: `plan-acceptance-gates.md:62-66, 86-99` fixes each new rule's severity with a decision rule that is written down before the corpus measurement (Blocking iff findings > 0 and false positives = 0). This research has already observed the corpus, so a measurement taken later cannot be blind. Recommended handling: the plan writes down the same two-conjunct rule and the false-positive definition before its measurement task, and the rule file records that severity was also set by operator-approved scope (issue #932), with the measurement as supporting evidence.

## Q3 — Detection Design

### How plans define SCRATCH in practice

The corpus is every `*plan.*.md` under `docs/` (active, completed, archive, epics, parallel). Archive plans contain no `SCRATCH` token. Observed definition forms:

| Form | Example (path:line) | Namespaced? |
|---|---|---|
| A. `- SCRATCH means the executor's session scratchpad directory, ...` | `.../690/plan.2026-09-29T22-17.md:94` (origin; 13 copies) | No |
| B. `SCRATCH is the session scratchpad outside the repository` | `.../690/remediation-plan.2026-09-30T02-00.md:43` | No |
| C. `` `SCRATCH` = the executor session scratchpad directory `` inside a symbols list | `.../647/remediation-plan.2026-10-02T00-06.md:28` | No |
| D. `` `SCRATCH` = the `889/` subdirectory of ... scratchpad `` | `.../889/plan.2026-10-11T08-31.md:32` | Bare digits, not canonical |
| E. `` **SCRATCH:** `SCRATCH` abbreviates the absolute directory `<executing worktree root>/SCRATCH` `` | `.../887/plan.2026-10-11T08-29.md:57` | No (worktree-local) |
| F. `` `SCRATCH` means `<session scratchpad>/issue-900/` `` | `.../900/plan.2026-10-11T10-38.md:20` | Yes (canonical) |
| G. Wrapped bullet: `- SCRATCH means ... and never` / `  committed. ...` | `.../762/plan.2026-09-28T23-50.md:128-129`; `.../722/plan.2026-09-27T12-16.md:28-29` | No |

Forms that are **not** SCRATCH definitions:

- `SCRATCH/<n>/` usage with no definition (`.../886/...:45`, `.../894/...:40`, `.../895/...:23`, `.../899/...:42`, `.../543/...:63`).
- Definition by reference to another plan (`.../776/remediation-plan.2026-09-29T20-15.md:21`).
- The distinct tokens `SCRATCHPAD` / `<SCRATCHPAD>` / `<SCRATCH>`, used as host-data redaction placeholders or in root paths such as `<SCRATCHPAD>/derive-worklists.ps1` (`.../786/plan.2026-10-08T13-54.md:275`) and `` `SCRATCHPAD` = ... `` (`.../824/plan.2026-10-08T13-53.md:22`).

No corpus plan defines `SCRATCH` inside a fenced code block, as a shell assignment (`SCRATCH=`), or as `$SCRATCH`.

### Proposed predicate (G10)

Evaluate **logical lines**. A logical line is a non-fenced line plus each following line that is non-blank and begins with whitespace, stopping at a fence, a heading, or a task line. Lines inside ```` ``` ```` fences are skipped, using the same fence regex as the extractor.

1. **Definition match** (used in both runtimes; no lookbehind, so the dialects agree):
   `(?:^|[^A-Za-z0-9_<>$/.-])` `` `? `` `SCRATCH` `` `? `` `(?:\*\*)?[ \t]*(?:means\b|:=|=|:|is (?:the|a|an)\b|resolves to\b|abbreviates\b|denotes\b|refers to\b|stands for\b)`
   - The preceding-character class excludes `<`, `$`, `/`, `-`, and word characters. As a result `<SCRATCH>`, `$SCRATCH`, `SCRATCH/x`, `SCRATCHPAD`, and `X_SCRATCH` never match.
   - The bare connector `is` is narrowed to `is the|a|an`, so property statements such as "SCRATCH is never committed" do not match.
2. **Namespace accept**: the text after the match contains `issue-(?:<issue-num>|[0-9]+)`. This prefix also accepts the run-unique `issue-<n>-<timestamp>` form.
3. A logical line that matches 1 but not 2 produces one finding. The line number is the first line of the logical line.

Proposed message (both runtimes, byte-identical, backtick-rendered, no `repr`):

```text
Line {n}: SCRATCH definition `{normalized logical line}` is not namespaced by issue number; define SCRATCH as `<session scratchpad>/issue-<issue-num>/`.
```

`Line N:` is used rather than `[P#-T#]` because definitions sit outside task windows. This matches the structural-error prefix in the same error channel. The rule file's statement that "Every finding string begins with the square-bracketed `P#-T#`" (`plan-acceptance-gates.md:29`) needs an explicit G10 exception.

### False-positive analysis

- **Quoted bare definitions in prose**: a plan that discusses a bare definition outside a fence is flagged, for example the #932 plan describing its own regression fixtures. Mitigations: fences are skipped, and the #932 plan must put such fixture text in a fenced block or refer to the test file. In the corpus, every flagged line is a real definition.
- **Non-canonical but collision-free definitions**: #889 (`889/`) and #887 (a worktree-local `SCRATCH`). The predicate's claim is "not in the canonical issue-namespaced form", and the persona rule requires "defines `SCRATCH` this way", so both are classified as true positives. If the claim were worded "not namespaced at all", #889 would be a false positive (see Open Question 1).
- **Colon connector**: a sentence such as "the token SCRATCH: ..." would match. There are no corpus instances.

### False-negative analysis

- **Definition by reference** to another plan (#776 remediation) is not detected.
- **Root paths under other tokens** (`<SCRATCHPAD>/name`, `` `SCRATCHPAD` = ... ``) are out of G10's scope by design.
- **Implicit use** of `SCRATCH/<fixed>` with no definition is not a definition, so the executor's reinterpretation rule still applies.
- **Wrong issue number** (`issue-123` in a plan for #932) is accepted, because the validator receives text only and plans have no uniform issue header.
- **Fenced definitions** are skipped. There are 0 corpus instances.

### Historical impact

17 committed plan files would be flagged (derivation below). No CI job, test, or hook runs the plan validator over committed plans:

- `.claude/rules/plan-acceptance-gates.md:21` states this.
- Grep for `validate_orchestration_artifacts` in `.github/workflows` and in `.claude/hooks`: 0 matches.
- Grep over `tests/` for plan-corpus globs found only synthetic fixtures.
- No fixture under `tests/` or `extensions/drm-copilot/test/` contains a `SCRATCH` definition.

A Blocking G10 therefore breaks no existing test. Residual risk: an in-flight plan that is re-validated during preflight or a remediation round fails until its definition line is edited.

## Numeric Derivation Evidence

The counts are reported for planning context. Do not put them into a `spec.md` acceptance criterion as a fixed number, because the corpus changes with every merged plan.

**Claim: committed plans that define SCRATCH, and those G10 flags**

- **Complete Family:** every `*plan.*.md` (plan and remediation-plan) under `docs/` that defines the token `SCRATCH`.
- **Exhaustive Search Scope:** `docs/**/*plan.*.md` in the working tree at `3a81781a4` (clean), covering the active, completed, archive, epics, and parallel trees.
- **Inclusion Rules:** a line matching the Q3 definition pattern (Grep approximation `(^|[^A-Za-z0-9_<$/-])` `` `? `` `SCRATCH` `` `? `` `\**\s*(means\b|is\b|=|:|resolves\b|abbreviates\b|denotes\b|refers\b|stands\b)`).
- **Exclusion Rules:** `SCRATCHPAD`, `<SCRATCH>`, `<SCRATCHPAD>`, pure `SCRATCH/<path>` usage, and definition by reference.
- **Primary Search Strategy:** the definition regex above. Files matched (18):
  - 769 plan.2026-09-29T13-19:71
  - 690 remediation-plan.2026-09-30T02-00:43
  - 690 plan.2026-09-29T22-17:94
  - 773 plan.2026-09-29T17-45:74
  - 850 plan.2026-10-08T13-54:114
  - 762 plan.2026-09-28T23-50:128
  - 647 remediation-plan.2026-10-02T00-06:28
  - 741 plan.2026-09-29T22-26:26
  - 763 plan.2026-09-29T14-14:113
  - 787 plan.2026-10-08T13-54:80
  - 776 plan.2026-09-29T18-10:23
  - 841 plan.2026-10-08T22-17:145
  - 842 plan.2026-10-08T22-17:26
  - 889 plan.2026-10-11T08-31:32
  - 887 plan.2026-10-11T08-29:57
  - 722 remediation-plan.2026-09-27T18-49:66 (completed)
  - 722 plan.2026-09-27T12-16:28 (completed)
  - 900 plan.2026-10-11T10-38 (lines 20, 93, 216, 435, 449, 457; all carry `issue-`)
- **Primary Count:** 18 defining files. Flagged = 18 − 1 (#900) = **17**.
- **Cross-check Search Strategy:** enumerate every plan file carrying a non-`SCRATCHPAD` token, `SCRATCH($|[^P])`, which gives 24 files. Then read the `SCRATCH` lines of each file not in the primary set and classify them by hand.
- **Cross-check Member Set:** 24 − 6 = 18. The 6 excluded files have no definition:
  - 776 remediation (by reference)
  - 886:45, 894:40, 895:23, 899:42, and 543:63 (`SCRATCH/<n>/` usage only)
- **Cross-check Count:** 18 defining files. Of these, 17 lack an `issue-` token on the definition line. Only #900 has one.
- **Member-set Comparison:** the primary and cross-check sets are identical (18 = 18, same paths).
  - A third, narrower strategy (lines where `SCRATCH` and `scratchpad` co-occur) recovers 16 of the 17 flagged lines. It misses #887 by construction, because #887's definition names a worktree directory and does not contain the word "scratchpad".
  - The flagged counts agree (17).

## Q4 — Rule-File and Skill Surfaces Stating the Gate Set

### `.claude/rules/plan-acceptance-gates.md` (258 lines) and its mirrors

- The only mirror is `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. It is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:89`, which is path-only and needs no change.
- There is no `.github/instructions`, `.agents`, or `.codex` counterpart. Grep for `plan-acceptance-gates` outside `docs/` found only references from `parallel-orchestration.md`, `BlastRadiusTokenShape.psm1`, `_blast_radius_token_shapes.py`, and a blast-radius fixture. None of these needs to change.
- Parity pin: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (89-110, text equality). The known local #510 gitignored-state failure signature applies.
- Gate-set statements to update:
  - frontmatter `description` (10)
  - title (13), which names G1-G6 and is explained at 44
  - the rule table (31-42), which needs a G10 row
  - "G1 through G9 are the complete shipped set" (44)
  - context-free/seam paragraph (50)
  - the `[P#-T#]` prefix statement (29)
  - the Enforcement list (254-257)
  - a new G10 severity subsection under `## Severity Decisions`
  - the known false-negative classes
- No test pins the title, the description wording, or the "complete shipped set" sentence. Grep for those phrases in `tests/`, `extensions/drm-copilot/test/`, and `scripts/` found 0 matches.

### `atomic-plan-contract` skill

- `.claude/skills/atomic-plan-contract/SKILL.md:196` names "G1 through G6". Line 198 ends "The complete shipped set is therefore G1 through G9."
- Its bundle copy, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md:196, 198`, is pinned by the same parity test.
- `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, and their bundle copies name no G rule. Grep for `G[1-9]` returned only `validate_orchestration_artifacts` hits.
- Constraint: this skill is a normative surface for the scratch contract-test scan (`.claude/skills/**/SKILL.md`). Any G10 authoring guidance added there must not contain a literal bare definition or a scratchpad-root path, or the new pattern check fails.
- The code docstrings and comments that describe the set are `plan_gate_discrimination.py:4` (already stale: "G1 through G6"), its docstring 359-361, and `plan-gate-discrimination.ts:254-256`. Both docstrings state that the Blocking list is byte-identical when there is no context. G10 runs without context, so that statement must be amended.

## Q5 — Codex TOMLs

### Current content

- `.codex/agents/atomic-planner.toml` (96 lines): `## Requirements` at 61-67, `## Preflight Validation` at 69. No scratch text.
- `.codex/agents/atomic-executor.toml` (154 lines): `## Toolchain Commands` at 85-94, `## Preflight Validation` at 96. No scratch text.
- Bodies are `developer_instructions = '''...'''` literal strings. The proposed section contains no `'''`, so TOML parsing is unaffected.
- Recommended insertion: the planner `## Scratch Location` section from `.claude/agents/atomic-planner.md:58-66` before TOML line 69, and the executor section from `.claude/agents/atomic-executor.md:85-94` before TOML line 96. The Claude and `.agents` texts are identical, and neither contains a `.claude/`-specific path.

### Generator

- Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`; `--check` reports drift (`scripts/dev_tools/generate_codex_agent_variants.py:271-290`).
- `_synchronize` (221-268) does the following for every family in `GENERATED_AGENT_FAMILIES`:
  - re-renders the root base (C3 alias) and writes it to `.codex/agents/<family>.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<family>.toml`;
  - writes the 5 variants (`-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`) under both roots;
  - rewrites all 6 pack manifests under `.../codex-and-agents-customizations/pack-manifests/`: `core.json`, `python.json`, `powershell.json`, `typescript.json`, `csharp-modern.json`, and `csharp-legacy.json`.
- For this change, content differs only for the two edited families, which gives 2 × (2 base + 10 variants) = **24 files**. Manifests gain no path, because every path already exists.
- `render_agent_variant` (123-170) changes only the `name`, `model`, and `model_reasoning_effort` lines that precede `developer_instructions`. Each variant body is therefore byte-identical to the base body.

### Execution route (recommended)

- `.claude/agents/atomic-executor.md:11-20` allows `poetry run black|ruff|pyright|pytest`, `npx ...`, `pwsh`, and `git`. It does **not** allow `poetry run python`.
- Recommended: apply the same Edit-tool insertion to all 24 files. Then verify with `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, which runs `main(["--check"])` at 181-184.
- This also avoids a Windows-only side effect. `render_manifest` output is written with `Path.write_text` (267) without `newline=""`, so a write-mode run on Windows rewrites the 6 manifests with CRLF. `.gitattributes:1` (`* text=auto eol=lf`) normalizes this on commit, but the working tree shows churn.
- If the orchestrator runs the generator instead, confirm afterwards with `git status --porcelain` that only the 24 TOML paths changed.

### Tests that check them

- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py:76-98, 100-120`: root equals bundle, plus handoff phrases.
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:82-84` (root equals bundle per agent), `87-109`, and `112-129` (phrase fragments).
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py:92` (checked-in variants match generator output in both surfaces) and `181-184` (`--check` reports no drift).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:55-68` (required bundled files; all `.agents`/`.codex` text parity at 215-228 per #900 research).
- `tests/scripts/dev_tools/test_codex_agent_role_schema.py:260` (variant keys and pins match canonical).
- TypeScript push-down tests under `extensions/drm-copilot/test/lib/push-down/` (`codex-agents-customizations.test.ts`, `codex-bundle-publish.integration.test.ts`, `codex-pack-selection.test.ts`).
- Recommended contract extension: add both TOMLs to `RULE_SOURCES`, and the executor TOML to `EXECUTOR_SOURCES`, in `test_scratch_location_contracts.py`. The placement anchors are the same as the Claude personas (`## Requirements`/`## Preflight Validation` and `## Toolchain Commands`/`## Preflight Validation`).

## Q6 — Toolchain Commands and Baselines

Repository facts:

- `quality-tiers.yml` exists. `scripts/dev_tools` is T4 (16-17) and `extensions/drm-copilot` is T3 (7-8). No property or mutation tests are required. Coverage is 85% line and 75% branch, uniform; the root `CLAUDE.md` states no thresholds.
- `pyproject.toml:116` has `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. That is an LCOV reporter only, so G9 applies: always pass `--cov-report=term-missing`. Coverage source is `src` and `scripts/dev_tools` (120).
- No architecture-boundary tool is configured: no import-linter in `pyproject.toml`, and no dependency-cruiser script in `extensions/drm-copilot/package.json:202-214`.

Python (repository root):

- `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py`
- `poetry run ruff check <same paths>`
- `poetry run pyright <same paths>` (strict mode, `pyproject.toml:143-144`)
- `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing` (dotted module names only)
- Contract and parity set: `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`

TypeScript (run from `extensions/drm-copilot/`; npx forms match the executor allowlist):

- `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (the `format` script at 207 uses `--write`)
- `npx eslint --no-error-on-unmatched-pattern src test`
- `npx tsc -p ./ --noEmit` and `npx tsc -p tsconfig.jest.json --noEmit`
- `npx jest --config jest.config.cjs test/lib/validate` (`run-jest.cjs` adds `--config jest.config.cjs` and rejects `--passWithNoTests`, `--onlyChanged`, and `--lastCommit`)
- Coverage: run the **full** suite, `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, which is equivalent to `npm run test:coverage`. A subset run with `--coverage` triggers the per-file thresholds in `jest.config.cjs` for files the subset does not exercise. Add a `./src/lib/validate/plan-gate-scratch.ts` entry (85/75).

Baselines: no current-tree coverage figure was produced in this session (no shell). Historical reference only, not a baseline: #519 final QA recorded `plan_gate_discrimination.py` 95% and `plan_gate_observability.py` 96% (`docs/features/completed/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-test-final.2026-08-24T00-00.md:28-31`). The plan must capture fresh baselines in Phase 0.

## Recommended Approach

Add G10 as a context-free, document-level rule in new sibling modules, called from both `evaluate_plan_gates` entry points after the existing groups:

- Python: `scripts/dev_tools/plan_gate_scratch.py`. Contents: its own `BLOCKING_CHANNEL`/`WARNING_CHANNEL` copies (the observability precedent); `G10_SEVERITY = BLOCKING_CHANNEL`; the two regexes; a pure `bare_scratch_definitions(text) -> list[tuple[int, str]]`; and `evaluate_scratch_gate(report, text)`. Report types are imported under `TYPE_CHECKING` only, so the import graph stays acyclic.
- TypeScript: `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` with the same exports (`G10_SEVERITY: string = "blocking"`, `bareScratchDefinitions`, `evaluateScratchGate`). It imports only types from `plan-gate-rules.ts`. It is re-exported from `plan-gate-discrimination.ts`.
- G10 runs whether or not a context is supplied. It therefore reaches `validate_plan_text`, the CLI, and the MCP route.
- `test_scratch_location_contracts.py` replaces `FORBIDDEN_SCRATCH_PATHS` with two checks:
  1. `bare_scratch_definitions` imported from the production module and applied to every normative surface, so the plan gate and the contract test share one detector.
  2. A scratchpad-root regex, `(?i)<[^>\n]*scratchpad[^>\n]*>/(?!issue-)`.
- The contract test also adds a parametrized self-test. It shows that the pattern flags `<scratchpad>/run-ps.sh`, `<SCRATCHPAD>/derive-worklists.ps1`, and a bare definition, and accepts `<session scratchpad>/issue-<issue-num>/run-ps.sh`. This supplies the failing demonstration the #900 code review noted was missing (`code-review.2026-10-12T17-38.md:23`).
- All current normative surfaces pass both checks. Every `scratchpad>/` occurrence in `.claude/agents`, `.claude/skills`, and `.agents/skills` is followed by `issue-`, which was verified by Grep.

Rejected alternatives:

- **Adding G10 to an existing module.** The 500-line limit rules this out (Q2 table).
- **A command-extractor-based rule.** Definitions sit outside task windows and are dropped by the extractor (`plan_gate_commands.py:355-356`).
- **Warning severity.** Does not meet the issue's "preflight rejects" expectation.
- **Keeping the six-literal denylist alongside the pattern.** The five `SCRATCH/<name>` literals are valid under the #900 rule, because `SCRATCH` is per-child, so they no longer describe a defect.

## Open Questions (with recommended answers)

1. Should a bare-digit namespace (`SCRATCH/889/`, `` `889/` subdirectory ``) be accepted? **Recommend no.** Accept only `issue-<issue-num>`, `issue-<digits>`, and the run-unique prefix form. The persona rule says "defines `SCRATCH` this way", and a digits-only segment also matches year or date directories.
2. Should G10 check that the issue number matches the plan's own issue? **Recommend no.** The validator receives text only, and plans carry no uniform issue header. Record this as a known false-negative class.
3. Should G10 also cover `SCRATCHPAD` and `<SCRATCHPAD>/<name>` root paths in plans? **Recommend no** for this item; record it as a known false-negative class. `<SCRATCHPAD>` is mostly used as a host-path redaction placeholder, so a plan-side rule would need its own false-positive study.
4. Should `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy be edited? The operator approval names only the rule file. **Recommend yes.** Line 198 states "The complete shipped set is therefore G1 through G9", which becomes false once G10 ships. The edit should be confirmed as within the approved "document the new gate" scope.
5. Severity governance (see Q2). **Recommend Blocking**, with the two-conjunct rule and the false-positive definition written into the plan before its measurement task. The rule file should note that severity was also set by operator scope.
6. How should the Codex TOMLs be produced? **Recommend** the 24 identical Edit-tool insertions, verified by the `--check` test (Q5). The alternative is an orchestrator-run generator followed by a `git status` check.

## Risks

- **#932 plan self-flagging**: the plan's own text must not contain an unfenced bare definition. Fixture text goes in fenced blocks, or the plan refers to the test file.
- **In-flight plans**: active plans with bare definitions fail re-validation. The fix is a one-line definition edit inside a revision.
- **MCP lag**: until the extension is rebuilt and reinstalled, the MCP tool keeps accepting bare definitions. The Python CLI enforces G10 at merge.
- **Parity drift**: mitigated by frozen G10 message strings in both runtimes and a severity-constant regex test. Add `plan_gate_scratch.py` to `_PYTHON_GATE_MODULES` (`test_plan_gate_parity.py:45-49`, 493 → 494 lines) and `plan-gate-scratch.ts` to the TypeScript module list (`plan-gate-parity.test.ts:315-318`).
- **Local #510 failure**: the gitignored-state failure in `test_bundled_claude_payload_contains_all_repo_runtime_contracts` can appear locally. The plan should accept only that signature.
- **Whitespace normalization**: Python `str.split()` and JS `split(/\s+/)` differ on rare control characters. Use the same normalization as the existing `windowJoin`/`_window_join` pair, and include a fixture with a tab.

## Candidate Write-Set

Create:

1. `scripts/dev_tools/plan_gate_scratch.py`
2. `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`
3. `tests/scripts/dev_tools/test_plan_gate_scratch.py` (unit tests, frozen G10 strings, severity-constant parity, CLI exit-code case through `validate_orchestration_artifacts.main`)
4. `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` (unit tests, the same frozen strings, a dispatcher-level case through `validateArtifactWithWarnings`)

Edit:

5. `scripts/dev_tools/plan_gate_discrimination.py` (import and call; docstrings at 4 and 359-361)
6. `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` (import, re-export, call; JSDoc 254-256)
7. `tests/scripts/dev_tools/test_plan_gate_parity.py` (`_PYTHON_GATE_MODULES`)
8. `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` (module list 315-318)
9. `extensions/drm-copilot/jest.config.cjs` (threshold entry)
10. `.claude/rules/plan-acceptance-gates.md`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` (byte-identical copy)
12. `.claude/skills/atomic-plan-contract/SKILL.md` (Open Question 4)
13. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` (byte-identical copy)
14. `tests/scripts/dev_tools/test_scratch_location_contracts.py`
15. `.codex/agents/atomic-planner.toml`
16. `.codex/agents/atomic-executor.toml`
17. `.codex/agents/atomic-planner-{c1,c2,c3,c3-elevated,c4}.toml` (5)
18. `.codex/agents/atomic-executor-{c1,c2,c3,c3-elevated,c4}.toml` (5)
19. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` and `atomic-executor.toml` (2)
20. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-{c1,c2,c3,c3-elevated,c4}.toml` and `atomic-executor-{...}.toml` (10)
21. Feature-folder documents: `spec.md`, the plan, `issue.md` AC check-offs, and `evidence/**`

Do not edit:

- historical plans
- pack manifests (path-only)
- `.github/**`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `validate_orchestration_artifacts.py` (498 lines; needs no change, because G10 enters through `evaluate_plan_gates`)
- `plan_gate_observability.py` and `.ts` (near the limit)

## Testing Implications

- **Phase 2 `[expect-fail]`:** add the G10 unit and parity tests first. They fail before the modules exist. Rewrite `test_scratch_location_contracts.py` with the pattern check and the self-test; the self-test fails until the shared detector exists. Add the TOML rule-source cases; they fail until the TOML sections exist.
- **Scenario coverage:**
  - Positive (canonical, concrete `issue-900`, run-unique form).
  - Negative: each corpus form A-E, the wrapped bullet G, backticked and bold variants, `:=`/`=`/`:`.
  - Non-definitions: `SCRATCH/<n>/` usage, `<SCRATCH>`, `SCRATCHPAD`, `$SCRATCH`, "SCRATCH is never committed", a fenced definition.
  - Context-free run versus context run (identical G10 output).
  - Channel placement per `G10_SEVERITY`.
  - Apostrophe-bearing line for backtick rendering.
  - CLI exit 1 with the `Line N:` message.
  - MCP service-call throw path including the message.
- Coverage targets: 85% line and 75% branch on both new modules and on changed lines of `plan_gate_discrimination.py` / `.ts`.

## Automation Feasibility

No human interaction is required to implement or verify this item:

- All code, prose, and TOML edits are agent-editable.
- Verification runs through `poetry run black|ruff|pyright|pytest` and `npx prettier|eslint|tsc|jest`, all of which are in the `atomic-executor` allowlist (`.claude/agents/atomic-executor.md:11-20`).
- Codex variant consistency is checked through pytest (`--check` mode). The generator write mode is not needed (Q5).
- Operator approval for editing `.claude/rules/plan-acceptance-gates.md` and the Codex TOMLs is already recorded in the delegation.
- The atomic-plan-contract skill edit (Open Question 4) needs confirmation that it falls inside the approved scope.
- Rebuilding and reinstalling the extension so the MCP route enforces G10 is a release step outside this item. It is not needed for verification, because the TypeScript behavior is exercised by jest.
