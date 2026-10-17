# quality-tiers-yml-missing-and-unenforced (Spec)

- **Issue:** #734 (consolidates closed issues #336 and #511)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T22-10
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this `spec.md` only)
- **Research:** `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/research/2026-09-29T21-55-quality-tiers-yml-research.md`

## Context
`quality-tiers.yml` does not exist at the repository root on `main`. `.claude/rules/quality-tiers.md` says every project must be classified there, and that CI's `tier-classification` stage fails when a project is unclassified. Research verified that no such stage exists: `.github/workflows/ci.yml` composes nine jobs, none of which implements tier classification, and a case-insensitive search for `tier` over `.github/` matches only the word "Prettier".

The same rule (line 9) names `docs/ci.research.md` section 1 as the tier system's source of truth. That document does not exist (#511). The tier definitions and gate matrix are stated inline in the rule itself; no other document defines them.

The operator consolidated #336 (same root cause as this issue) and #511 (broken citation) into #734 on 2026-09-29. The "Consolidated Scope" section of `issue.md` is authoritative for this change.

Environment:
- OS/version: any
- Python version: 3.10-3.13 (the `quality-checks7` job matrix)
- Command/flags used: `git ls-files --error-unmatch quality-tiers.yml` on main (fails: "did you forget to git add?"); `git ls-tree --name-only origin/main | grep -i tier` (no match)
- Data source or fixture: main at 2026-09-27

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The tier-dependent gates (mutation score, property-test density, determinism budgets) cannot be applied reliably without the classification source. Plans currently assume a tier; #706 assumed T4 "because quality-tiers.yml was absent", and reviewers on #707, #708, and #710 flagged the gap independently.


## Repro & Evidence
Steps to Reproduce:
1. Check out main.
2. Look for `quality-tiers.yml` at the root: it is absent.
3. CI is green, so no stage enforces the documented requirement.
4. Open `.claude/rules/quality-tiers.md` line 9 and follow the `docs/ci.research.md` citation: the file does not exist.

Expected:
`quality-tiers.yml` classifies every project (T1-T4). CI fails when the file is missing, malformed, contains an invalid tier, or omits a discovered project. The rule cites a document that exists and defines the tier system.

Actual:
The file is absent, no CI stage checks it, and the rule cites a nonexistent document. Prior features recorded the absence and assumed tiers (`docs/features/completed/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.2026-08-07T19-58.md`, `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-quality-tiers-gap.md`).

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #706 spec (tier assumption); the #707, #708 and #710 reports.


## Scope & Non-Goals
- In scope:
  - Author `quality-tiers.yml` at the repository root, classifying every project discovered by the five discovery rules in "Technical specifications", using the T3/T4 assignments in "Tier assignments".
  - Add a pure validation core `scripts/dev_tools/quality_tiers_contract.py` and a CLI wrapper `scripts/dev_tools/check_quality_tiers.py`.
  - Add a step named `tier-classification` to the existing `quality-checks7` job in `.github/workflows/_quality-checks.yml`.
  - Add unit tests `tests/scripts/dev_tools/test_quality_tiers_contract.py` and `tests/scripts/dev_tools/test_check_quality_tiers.py`.
  - Correct the `docs/ci.research.md` citation in the four files listed in "Policy-document edits (operator-directed)", keeping repository copies and bundled copies byte-identical.
- Out of scope / non-goals:
  - T1 or T2 elevation of any project. Candidates are recorded as a follow-up (see "Rollout & Follow-up"). Rationale: elevation imposes property-test density and mutation-score obligations (`.claude/rules/quality-tiers.md` gate matrix), and the repository has no approved property-test or mutation tooling (no `fast-check`, `stryker`, or `hypothesis` usage was found).
  - Adding property-test or mutation tooling.
  - The separate broken citation `.agents/skills/quality-tiers.md` in `.agents/skills/general-code-change/SKILL.md` (line 32), `.agents/skills/general-unit-test/SKILL.md` (lines 29 and 92), and their bundled copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. The correct path is `.agents/skills/quality-tiers/SKILL.md`. This is recorded as a separate follow-up because it falls outside the operator's citation-only scope for #511.
  - Any other wording change to policy or skill files, including the sentences stating that CI fails on an unclassified project (these become accurate once this change lands).
  - Historical and other-feature documents under `docs/features/completed/**`, `docs/features/active/<other features>/**`, `docs/features/potential/**`, `docs/features/epics/**`, `docs/features/parallel/**`, and `docs/research/**`. These retain their `docs/ci.research.md` and `quality-tiers.yml` mentions unchanged.
  - Adding a CI `actionlint` job (the documented job is absent from `ci.yml`; recorded as a follow-up candidate).
  - Supplying `quality-tiers.yml` or the validator to consumer workspaces that receive the pushed-down rule.
- Explicitly excluded systems, integrations, or datasets:
  - `.github/instructions/*` and every other file under `.github/` other than `_quality-checks.yml`. A search of `.github/` for `ci.research`, `quality-tiers`, and `rigor tier` returned zero matches, so the `.github/` mirror set named in the consolidated scope is empty and no `.github/instructions/*` file is edited.
  - `.codex/` (zero citation matches).
  - Test data strings that mention `docs/ci.research.md` or `quality-tiers.yml` as arbitrary fixture values (for example `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` line 249, `tests/fixtures/blast_radius/**`, and the blast-radius Python and TypeScript tests). These are not citations.
  - `config/blast-radius.json` and its bundled copy (no edit).

## Root Cause Analysis
The tier rule was imported from another codebase. Its examples (SpamBayes, TaskMaster, Outlook, Office.js) name systems that do not exist in this repository, and it cites a source document (`docs/ci.research.md`) and a root classification file (`quality-tiers.yml`) that were never created here. Because the rule text asserts that CI enforces classification, no author added the file or the stage, and the absence did not surface as a CI failure. The same sentence was copied verbatim into the Codex/agents mirror (`.agents/skills/quality-tiers/SKILL.md`) and into both bundled resource trees, so the broken citation exists in four files.


## Proposed Fix

### Design summary (what changes where):
1. `quality-tiers.yml` (new, repository root): a list-of-entries document with one entry per discovered project, each carrying `path`, `tier`, and `rationale`.
2. `scripts/dev_tools/quality_tiers_contract.py` (new): pure core. Parses YAML text into frozen dataclasses, discovers projects from a supplied tracked-file list, and returns accumulated classification errors. Performs no I/O.
3. `scripts/dev_tools/check_quality_tiers.py` (new): CLI and I/O boundary. Reads `quality-tiers.yml` with `Path.read_text`, obtains the tracked-file list through an injectable runner that calls `git ls-files -z`, invokes the core, prints errors to stderr, and returns an exit code.
4. `.github/workflows/_quality-checks.yml`: a new step named `tier-classification` in the `quality-checks7` job, placed after "Verify Codex agent deployment profiles" and before "Run tests with Pytest".
5. Four policy/skill files: citation correction only (see "Policy-document edits (operator-directed)").

### Boundaries and invariants to preserve:
- Repository copies and bundled copies of the edited policy files remain byte-identical, enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) and `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`).
- `.claude/rules/quality-tiers.md` frontmatter is unchanged; it remains one of the unconditional rules checked by `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`.
- The `quality-checks7` job structure is unchanged apart from the added step, per `.github/instructions/github-actions.instructions.md` ("Do not change the overall job structure unless explicitly requested"). No new job, no new required-check context.
- The validator fails closed: a git failure never produces an empty project set that passes (QT009).
- No `.claude/hooks` file gains a Python invocation (the enforcement-hook no-Python rule is unaffected because the validator is a CI script, not a hook).
- New module names avoid the `scripts/dev_tools/validate_*.py` shared-surface glob in `config/blast-radius.json`.

### Dependencies or blocked work:
- None blocking. PyYAML (`>=6.0`) and Poetry are already present in `pyproject.toml` and in the `quality-checks7` job.
- The item's plan writes `quality-tiers.yml`, which `config/blast-radius.json` lists as a shared surface and mandate read. Per `.claude/rules/parallel-orchestration.md`, the plan must append it explicitly to its declared blast radius.
- Merge requires a green run of the modified workflow on the branch head (`.claude/rules/ci-workflows.md`, rule `modified-workflow-needs-green-run`).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
| File | Change |
|---|---|
| `quality-tiers.yml` | New |
| `scripts/dev_tools/quality_tiers_contract.py` | New (pure core) |
| `scripts/dev_tools/check_quality_tiers.py` | New (CLI) |
| `tests/scripts/dev_tools/test_quality_tiers_contract.py` | New |
| `tests/scripts/dev_tools/test_check_quality_tiers.py` | New |
| `.github/workflows/_quality-checks.yml` | Add `tier-classification` step to `quality-checks7` |
| `.claude/rules/quality-tiers.md` | Citation correction, line 9 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` | Citation correction, line 9 (byte-identical to repo copy) |
| `.agents/skills/quality-tiers/SKILL.md` | Citation correction, line 12 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` | Citation correction, line 12 (byte-identical to repo copy) |

No sync script exists for the bundled copies; they are edited by hand in the same commit as the repository copies.

#### Functions/classes/CLI commands impacted:
- `quality_tiers_contract.py` (names are normative; signatures may add keyword-only parameters with defaults):
  - `QualityTierEntry` (frozen dataclass: `path: str`, `tier: str`, `rationale: str`).
  - `QualityTierManifest` (frozen dataclass: `version: int`, `entries: tuple[QualityTierEntry, ...]`).
  - `QualityTierError` (frozen dataclass: `code: str`, `message: str`, optional `path: str | None`), rendered as `QTnnn: <message>`.
  - `parse_quality_tiers(text: str) -> tuple[QualityTierManifest | None, list[QualityTierError]]`: loads with a `yaml.SafeLoader` subclass that rejects duplicate mapping keys, then applies schema checks.
  - `discover_projects(tracked_paths: Iterable[str]) -> frozenset[str]`: applies discovery rules R1-R5.
  - `find_classification_errors(manifest: QualityTierManifest, projects: frozenset[str]) -> list[QualityTierError]`: QT004-QT008.
  - A single module-level constant holds the discovery roots and exclusions.
- `check_quality_tiers.py`:
  - `main(argv: Sequence[str] | None = None) -> int`, with optional `--file` (default `quality-tiers.yml`) and `--repo-root` (default current directory).
  - The tracked-file runner is an injectable callable (default: `git` resolved via `shutil.which`, invoked as `git ls-files -z`). The subprocess call carries the pre-authorized suppression `# noqa: S603 - static analysis can't verify runtime validation`; S607 is not suppressed.
  - Invocation: `poetry run python -m scripts.dev_tools.check_quality_tiers`.

#### Data flow and validation changes:
1. CLI reads `quality-tiers.yml` text. Missing or unreadable file yields QT001 and exit 1.
2. Core parses the text. Invalid YAML, a duplicate mapping key, or a non-mapping root yields QT002. QT001 and QT002 stop evaluation after reporting.
3. Core validates the schema (QT003), tier values (QT004), duplicate paths (QT005), and path form (QT006).
4. CLI obtains the tracked-file list. A missing `git` executable or non-zero exit yields QT009 and exit 1.
5. Core discovers projects and compares: entries that are not discovered projects yield QT007; discovered projects without entries yield QT008.
6. All QT003-QT009 errors are accumulated and reported in one run.

#### Error handling and logging updates:
- Each error is written to stderr on its own line as `QTnnn: <message>`, naming the offending path or key where applicable.
- A successful run prints a single summary line to stdout (entry count and discovered-project count) and exits 0.
- No broad exception handlers except at the CLI boundary, where `OSError` from the file read maps to QT001 and `OSError`/non-zero exit from the git runner maps to QT009.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the change; removing the workflow step alone disables enforcement without affecting other steps.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Schema for `quality-tiers.yml`:

```yaml
version: 1
projects:
  - path: extensions/drm-copilot
    tier: T3
    rationale: VS Code extension and MCP server; glue over host APIs.
  # one entry per discovered project
```

- Top-level keys: exactly `version` (integer, must equal `1`) and `projects` (non-empty list). Any other top-level key is rejected (QT003).
- Entry keys: exactly `path`, `tier`, and `rationale`, all non-empty strings. Missing or unknown keys are rejected (QT003).
- `tier` must be one of `T1`, `T2`, `T3`, `T4` (QT004).
- `path` is repository-relative POSIX: `.` for the root; no leading `/`, no drive letter, no `\`, no trailing `/`, and no `..` or `.` segments other than the bare root (QT006).
- A list (not a path-keyed mapping) is used because `yaml.safe_load` silently keeps the last value for duplicate mapping keys. The duplicate-key-rejecting loader additionally prevents a repeated top-level `projects:` key from hiding entries.

Project discovery rules (applied to `git ls-files` output, after exclusions):
- Exclusions, applied first to every rule: any path under `tests/`, `docs/`, `extensions/drm-copilot/resources/` (bundled payload copies), or `node_modules/`. Gitignored paths (for example `.venv/`, `.claude/worktrees/`) are excluded because they are not tracked.
- R1, manifest roots: the directory of every tracked `package.json` or `*.csproj`.
- R2, PowerShell module roots: the directory of every tracked `*.psd1` that has a tracked sibling `<same-stem>.psm1` (settings `.psd1` files are therefore not projects).
- R3, script roots: every immediate child directory `scripts/<name>` that directly contains at least one tracked `.py`, `.ps1`, `.psm1`, or `.sh` file.
- R4, runtime library roots: every immediate child directory `.claude/lib/<name>` that contains a tracked file.
- R5, hook roots: `.claude/hooks` and `.codex/hooks` when they contain a tracked file.
- Nested projects are permitted (`scripts/powershell/PoshQC` inside `scripts/powershell`); a file belongs to the most specific enclosing project.
- Loose scripts outside these roots (`.devcontainer/*.sh`, `.github/codex/*.sh`, `.codex/codex-web-setup.sh`) are not projects under this definition.

Failure codes:

| Code | Condition |
|---|---|
| QT001 | `quality-tiers.yml` missing or unreadable |
| QT002 | Invalid YAML, duplicate mapping key, or root not a mapping |
| QT003 | Schema violation (bad/missing `version`, `projects` not a non-empty list, entry not a mapping, missing or unknown key, non-string or empty value) |
| QT004 | `tier` not in {T1, T2, T3, T4} |
| QT005 | Duplicate `path` entries |
| QT006 | Malformed `path` (absolute, drive letter, backslash, trailing slash, `..` or `.` segment) |
| QT007 | Entry `path` is not a discovered project (stale entry or nonexistent path) |
| QT008 | Discovered project has no entry (unclassified) |
| QT009 | `git ls-files` unavailable or failed (fail closed) |

Exit codes: `0` valid; `1` any QT error; `2` argparse usage error (same contract as `scripts/dev_tools/check_python_coverage_thresholds.py`).

Tier assignments (adopted as proposed by research; no T1/T2 elevations):

| Path | Rule | Tier | Rationale |
|---|---|---|---|
| `.` | R1 | T4 | Root TypeScript scaffold and tool configuration only |
| `extensions/drm-copilot` | R1 | T3 | VS Code extension and MCP server; glue over the VS Code API, MCP SDK, and subprocesses |
| `packages/mcp-server` | R1 | T4 | npm packaging manifest plus esbuild/prepack scripts; no source of its own |
| `scripts/powershell/PoshQC` | R2 | T3 | QC module bundled into the extension; wraps PSScriptAnalyzer and Pester |
| `scripts/dev_tools` | R3 | T4 | Repository-internal Python dev tooling (validators, CLIs); not published by push-down |
| `scripts/dev-tools` | R3 | T4 | PowerShell release, bootstrap, and developer scripts |
| `scripts/bash` | R3 | T4 | Shell QC and coverage scripts |
| `scripts/powershell` | R3 | T4 | Extension build/publish script |
| `.claude/hooks` | R5 | T3 | Enforcement hooks shipped to consumers; adapters over the Claude Code hook payload API |
| `.codex/hooks` | R5 | T3 | Enforcement hooks shipped to consumers; adapters over the Codex hook API |
| `.claude/lib/bash` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/blast-radius` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/ci-gate` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/cleanup-manifest` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/codex-routing` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/discovery-validation` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/hook-payload` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/mermaid` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/model-routing` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/orchestrator-state` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/parallel-drift` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/project-file-merge` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/requirements` | R4 | T3 | Runtime library shipped in the `.claude` bundle |
| `.claude/lib/worktree-resolution` | R4 | T3 | Runtime library shipped in the `.claude` bundle |

Classification principle: T3 when the project ships into consumer workspaces or the VS Code host and wraps a host API the team does not own; T4 when it is repository-internal tooling or scaffolding. `scripts/` is not shipped (`scripts/dev_tools/skill_bundle_contract.py` records `PUBLISHED_ROOT_FOLDERS = (".claude", "config")`). The table reflects the tree at research time; the validator, not this table, is authoritative for the discovered set at implementation time. If the implementation-time discovery differs, the implementer classifies any additional project using the same principle and records the difference in the plan evidence.

The new modules sit in `scripts/dev_tools` (T4), so no property tests or mutation score are required for them. The uniform coverage floors still apply.

#### Required configuration keys and defaults:
- `quality-tiers.yml`: `version: 1`, `projects: [...]` as above. No defaults; every key is required.
- CLI defaults: `--file quality-tiers.yml`, `--repo-root .`.

#### Backward-compatibility expectations:
- No existing public API changes. The workflow gains one step; existing steps and job names are unchanged.
- The corrected citation keeps the surrounding sentences unchanged, so documents that quote "every project must be classified in `quality-tiers.yml`" remain accurate.

#### Performance constraints (latency/throughput/memory):
- The CLI runs one `git ls-files -z` call and in-memory set operations. No explicit budget; it is expected to complete in seconds on the CI runner.
- Python 3.10 compatibility is mandatory (the job matrix runs 3.10-3.13, while Pyright is pinned to 3.12 and will not detect 3.11+ API use). Do not use `tomllib`, `typing.Self`, or other 3.11+ APIs.

## Policy-document edits (operator-directed)

The operator consolidated this scope explicitly on 2026-09-29 in a comment on #734, folding in #511. Edits are limited to the citation correction below. No other text in these files changes.

Exact old text (substring, identical in all four files):

``The tier system source of truth is `docs/ci.research.md` section 1; the file `quality-tiers.yml` at the repository root maps every project to a tier.``

Exact new text (substring, identical in all four files):

``The tier definitions and gate matrix in this document are the tier system's source of truth; the file `quality-tiers.yml` at the repository root maps every project to a tier.``

| File | Line |
|---|---|
| `.claude/rules/quality-tiers.md` | 9 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` | 9 |
| `.agents/skills/quality-tiers/SKILL.md` | 12 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` | 12 |

Notes:
- The `.github/` mirror set was searched and is empty: no file under `.github/` references `docs/ci.research.md`, `quality-tiers`, or `rigor tier`. No `.github/instructions/*` file is edited.
- The replacement text does not name the validator script, so it introduces no script reference that the skill bundle contract or push-down would need to carry.
- The sentence that follows the citation ("Adding a project without a tier classification fails CI.") and the "Source of Truth" bullets stating that every project must be classified in `quality-tiers.yml` and that the `tier-classification` stage fails on an unclassified project already describe the post-fix state correctly. No other text changes.
- The same holds for `.claude/rules/general-code-change.md` ("Every project must be classified in `quality-tiers.yml` at repo root") and its mirrors; they are not edited.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `actions/checkout@v7` at its default shallow depth supports `git ls-files`.
  - `git` is on PATH in CI and in local developer environments; when it is not, the validator fails with QT009 rather than passing.
  - The tier assignments above are accepted as the operator's decision for this change.
- Constraints (budget, performance, compatibility):
  - Python 3.10 compatibility.
  - No file over 500 lines.
  - No temporary files in tests; no external processes in unit tests.
  - Policy edits limited to the citation correction.
  - Ruff suppressions limited to the pre-authorized S603 form.
- External dependencies (services, libraries, releases):
  - PyYAML (already approved). No new dependencies.

## Data / API / Config Impact
- User-facing or API changes: new CLI `python -m scripts.dev_tools.check_quality_tiers`; new CI step `tier-classification`.
- Data or migration considerations: new root file `quality-tiers.yml`. Adding a new project root (for example a new `package.json` or `.claude/lib/<name>`) now requires a matching entry, or CI fails with QT008.
- Logging/telemetry updates (if any): stderr error lines with QT codes; one stdout summary line on success.
- Compatibility notes (CLI flags, config schemas, versioning): schema `version: 1`. A future schema change increments `version`, and the validator rejects unknown versions (QT003).

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: author `quality-tiers.yml` covering every project (extension, mcp-server, scripts, .claude libs, hooks), using the examples in the rules doc; add or repair a CI stage that fails when the file is missing, a project is unclassified, or a tier is invalid.
- [ ] Integration scenario to retest: removing a project's entry makes CI fail.
- [ ] Manual verification notes: coordinate with #511 (now consolidated into this issue).

- Regression tests to add or update:
  - `tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt008_when_entry_removed`: supplies the committed-style YAML text with one entry removed and an injected tracked-file list containing that project; asserts exit 1 and a QT008 line naming the removed path.
  - `tests/scripts/dev_tools/test_quality_tiers_contract.py::test_committed_quality_tiers_yml_matches_live_tree`: reads the committed `quality-tiers.yml` text from the checkout (the same read-only pattern as `test_claude_rules_frontmatter.py`), asserts that it parses with no QT002-QT006 errors, and asserts that each entry path is an existing directory in the checkout. The complete discovery comparison against `git ls-files` (QT007/QT008) is performed by the `tier-classification` CI step and the integration run, because unit tests may not start external processes.
- Unit tests (pytest) for the fixed behavior and boundaries (all inputs injected as in-memory strings and path lists; no temporary files; the git runner is a fake callable):
  - Positive: a valid file matching the discovered set yields no errors; `main` returns 0 and prints the summary line.
  - One named test per failure code: QT001 (missing file via injected reader raising `FileNotFoundError`), QT002 (invalid YAML; duplicate top-level key; non-mapping root), QT003 (missing `version`; `version` not 1; `projects` empty or not a list; entry not a mapping; missing key; unknown key; non-string or empty value; unknown top-level key), QT004 (tier `T5`, lowercase `t3`), QT005 (repeated list entry), QT006 (absolute, drive letter, backslash, trailing slash, `..` segment), QT007 (entry for a non-discovered path), QT008 (unclassified project), QT009 (runner raises `OSError`; runner returns non-zero; `git` not found).
  - Accumulation: a file with QT004 and QT008 violations reports both in one run.
  - Discovery boundaries: settings `.psd1` without a sibling `.psm1` is not a project; paths under `extensions/drm-copilot/resources/**`, `tests/fixtures/**/*.csproj`, `docs/**`, and `node_modules/**` are ignored; `scripts/<name>` with no direct code file is not a project; `scripts/powershell/PoshQC` and `scripts/powershell` are both discovered; `.claude/hooks` and `.codex/hooks` are discovered only when they contain a tracked file; root `package.json` yields `.`.
  - CLI: argparse usage error returns 2.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): covered by the parametrized QT003/QT006 matrices above; empty tracked-file list with a non-empty manifest yields QT007 for every entry (never a silent pass).
- Error handling and logging verification: assert stderr lines begin with the expected `QTnnn:` prefix and name the path; assert stdout is empty on failure.
- Coverage impact and targets for changed lines/modules: `scripts/dev_tools/quality_tiers_contract.py` and `scripts/dev_tools/check_quality_tiers.py` each at >= 85% line and >= 75% branch; overall Python coverage thresholds unchanged. No production file is excluded from coverage.
- Toolchain commands to run (format → lint → type-check → test):
  1. `poetry run black .`
  2. `poetry run ruff check .`
  3. `poetry run pyright`
  4. Architecture-boundary stage: not applicable (no Python architecture-boundary tool is configured in `pyproject.toml`).
  5. `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing` (dotted `--cov` form; a `--cov=<path>.py` form measures nothing), then the full suite: `poetry run pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing` and `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
  6. Contract/schema stage: the two bundled-payload parity tests and `test_claude_rules_frontmatter.py` (included in the full suite).
  7. Integration: `poetry run python -m scripts.dev_tools.check_quality_tiers` (expect exit 0).
  - Workflow: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1` on `.github/workflows/_quality-checks.yml`.
- Manual validation steps (if required):
  - In an uncommitted working copy, remove one entry from `quality-tiers.yml`, run `poetry run python -m scripts.dev_tools.check_quality_tiers`, confirm exit 1 with a QT008 line naming that path, then restore the entry.
  - Confirm the `tier-classification` step appears and passes in the CI run on the branch head.
  - Evidence is written under `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/evidence/<kind>/`.


## Acceptance Criteria
- [x] `quality-tiers.yml` exists at the repository root, uses the `version: 1` list-of-entries schema, carries `path`, `tier`, and `rationale` on every entry, and assigns the tiers listed in "Tier assignments" with no T1 or T2 entries.
- [x] `poetry run python -m scripts.dev_tools.check_quality_tiers` exits 0 against the committed tree, with evidence recorded under the feature `evidence/` folder.
- [x] `scripts/dev_tools/quality_tiers_contract.py` performs no I/O and implements discovery rules R1-R5 and failure codes QT002-QT008; `scripts/dev_tools/check_quality_tiers.py` implements QT001, QT009, stderr reporting, and exit codes 0/1/2.
- [x] Each failure code QT001 through QT009 is covered by at least one named test in `tests/scripts/dev_tools/test_quality_tiers_contract.py` or `tests/scripts/dev_tools/test_check_quality_tiers.py`, and each discovery boundary listed in "Test Strategy" is covered by a named test.
- [x] `test_main_returns_one_with_qt008_when_entry_removed` passes, asserting exit 1 and a QT008 line naming the removed path.
- [x] `test_committed_quality_tiers_yml_matches_live_tree` passes against the committed `quality-tiers.yml`.
- [x] The manual negative check (remove one entry in the working copy, run the CLI, observe exit 1 with QT008, restore) is performed and recorded as evidence.
- [x] Tests use no temporary files and start no external processes; file contents and the tracked-file list are injected as inputs.
- [x] `.github/workflows/_quality-checks.yml` job `quality-checks7` contains a step named `tier-classification` that runs `poetry run python -m scripts.dev_tools.check_quality_tiers` with `continue-on-error: false`, placed before "Run tests with Pytest", and no other job structure changes.
- [x] The `tier-classification` step runs and passes in a CI run on the branch head.
- [x] `actionlint` reports no findings on the modified `.github/workflows/_quality-checks.yml`.
- [x] The citation in `.claude/rules/quality-tiers.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, `.agents/skills/quality-tiers/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` is replaced with the exact new text in "Policy-document edits (operator-directed)", and no other line in those files changes.
- [x] `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` pass.
- [x] A search for `ci.research.md` outside `docs/` returns only the test fixture string in `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1`, and no file under `.github/` is edited other than `.github/workflows/_quality-checks.yml`.
- [x] The Python toolchain (Black, Ruff, Pyright, full Pytest suite) passes in a single pass, and the new modules each meet >= 85% line and >= 75% branch coverage with the repository-wide `check_python_coverage_thresholds` gate passing.
- [x] The new modules use no Python 3.11+ APIs and pass in the 3.10 matrix leg of `quality-checks7`.
- [x] Follow-ups are recorded for the `.agents/skills/quality-tiers.md` broken citation and for the deferred T1/T2 elevation candidates.

Note on counts: no acceptance criterion asserts a numeric project count. The research record's numeric derivation does not independently cover the complete discovery family (its Complete Family and cross-check strategy omit `*.csproj`, the cross-check does not verify the R3 "directly contains" condition, and both derivations enumerate the filesystem rather than `git ls-files`). Completeness is instead enforced by the validator (QT007/QT008) at implementation time.

## Risks & Mitigations
- Technical or operational risks:
  - Tier assignments are a policy decision; a later elevation changes gate obligations for the affected project.
  - Discovery rules R3-R5 use fixed roots. A new code root outside them with no manifest would not be discovered.
  - The pushed-down rule continues to tell consumer workspaces that CI fails on an unclassified project; those workspaces have neither the file nor the validator.
  - Bundled copies drift from repository copies if edited separately.
  - Python 3.11+ API use would pass Pyright (pinned to 3.12) and fail only in the 3.10 CI leg.
- Mitigations and rollbacks:
  - T1/T2 candidates are recorded as a follow-up that must travel with a tooling decision.
  - R1 detects any new `package.json` or `*.csproj` anywhere; the rule list is a single constant in the pure core and is covered by boundary tests.
  - Consumer-workspace wording is recorded as a follow-up candidate; it is out of scope under the citation-only constraint.
  - All four policy files are edited in one commit; the two parity tests gate drift.
  - The 3.10 matrix leg in CI is the gate; the spec forbids 3.11+ APIs explicitly.
  - Rollback: revert the change, or remove the workflow step to disable enforcement.

## Rollout & Follow-up
- Release/rollout steps:
  - Land all changes in one PR from `bug/quality-tiers-yml-missing-and-unenforced-734`, with a green CI run on the branch head that includes the `tier-classification` step.
  - The bundled rule and skill changes ship in the next extension release through the existing push-down payload.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (potential bug): `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, and their bundled copies cite `.agents/skills/quality-tiers.md`, which does not exist; the correct path is `.agents/skills/quality-tiers/SKILL.md`.
  - Follow-up (decision): T1/T2 elevation candidates `.claude/lib/cleanup-manifest` and `.claude/lib/worktree-resolution` (worktree removal can lose uncommitted work, which fits the T1 harm model) and `extensions/drm-copilot` push-down (writes into consumer workspaces; T2 candidate). Deferred because elevation imposes property-test density and mutation obligations for which the repository has no approved tooling; any elevation must travel with a tooling decision.
  - Follow-up candidate: `.github/instructions/github-actions.instructions.md` states a CI `actionlint` job exists in `ci.yml`; none does.
  - Follow-up candidate: the pushed-down rule's CI-enforcement statement in consumer workspaces.
- Links: issue #734 (https://github.com/drmoisan/drm-copilot/issues/734); consolidated #336 and #511; research `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/research/2026-09-29T21-55-quality-tiers-yml-research.md`.
