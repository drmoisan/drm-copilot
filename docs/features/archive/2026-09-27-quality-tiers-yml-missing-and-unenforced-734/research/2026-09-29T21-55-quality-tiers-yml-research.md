# Research: quality-tiers.yml missing and unenforced (Issue #734, consolidating #336 and #511)

- Timestamp: 2026-09-29T21-55
- Branch: `bug/quality-tiers-yml-missing-and-unenforced-734`
- Feature folder: `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734`
- Authoritative scope: `issue.md` section "Consolidated Scope (2026-09-29, authoritative)" (lines 68-79)
- File-name note: the orchestrator supplied `research/research.2026-09-29T21-55.md`. That name fails the
  SubagentStop filename check in `.claude/hooks/validate-task-researcher-output.ps1:95-98`
  (`^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$`), so this single artifact
  uses the conforming name `2026-09-29T21-55-quality-tiers-yml-research.md` in the same folder.

## 1. Current State (verified)

- `quality-tiers.yml` is absent. `Glob **/quality-tiers*` returns only `.claude/rules/quality-tiers.md`,
  its bundled copy, and two historical evidence files under `docs/features/completed/`.
- `docs/ci.research.md` is absent. `Glob docs/*ci*` returns no files.
- No CI stage named or implementing `tier-classification` exists. `.github/workflows/ci.yml:10-41`
  composes nine jobs (`quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`,
  `shell-coverage`, `drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate`). A
  case-insensitive `Grep tier` over `.github/` matches only the word "Prettier" in two files.
- The tier examples in the rule (SpamBayes, TaskMaster, Outlook, Office.js; `.claude/rules/quality-tiers.md:13-16`)
  name systems that do not exist in this repository. The rule was imported from another codebase, which
  matches the #511 note that it "was probably authored against a repository that carried both artifacts".
- No property-test or mutation tooling is present: `Grep fast-check|stryker|no-explicit-any` over the
  extension `package.json`/`eslint.config.mjs` returns nothing, and `Grep ^from hypothesis|^import hypothesis`
  over `tests/` returns 0 matches. This bears on tier selection (Section 4).
- Prior features recorded the absence and assumed tiers: `docs/features/completed/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.2026-08-07T19-58.md`
  (recorded-absence branch, property-test exemption) and `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-quality-tiers-gap.md`.

## 2. Question A: Every reference, classified

Search: `Grep "quality-tiers\.yml|tier-classification|ci\.research\.md"` over the entire worktree
(786 occurrences in 327 files; 290+ are under `docs/`). Non-`docs/` hits are listed individually below;
`docs/` hits are grouped.

### A.1 Files that carry the `docs/ci.research.md` citation (must be edited)

| File | Line | Text (abridged) | Class |
|---|---|---|---|
| `.claude/rules/quality-tiers.md` | 9 | "The tier system source of truth is `docs/ci.research.md` section 1; the file `quality-tiers.yml` at the repository root maps every project to a tier. Adding a project without a tier classification fails CI." | Canonical Claude rule |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` | 9 | identical to above | Bundled-resource copy (byte-identical parity) |
| `.agents/skills/quality-tiers/SKILL.md` | 12 | identical sentence | Codex/agents mirror ("Converted rule", line 6-8) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` | 12 | identical sentence | Bundled-resource copy (byte-identical parity) |

`.github/`: zero hits for `ci.research`, `quality-tiers`, `T1–T4`, `T1-T4`, or `rigor tier` (verified by
Grep over `.github/`). The consolidated scope's "mirrors under `.github/`" set is therefore empty; the
change must state this explicitly rather than invent a mirror. `.codex/`: zero hits.

### A.2 Files that reference `quality-tiers.yml` or `tier-classification` and need no edit

| File | Line(s) | Class | Effect of the fix |
|---|---|---|---|
| `.claude/rules/quality-tiers.md`, bundled copy, `.agents/skills/quality-tiers/SKILL.md`, bundled copy | 20-21 (rule) / 23-24 (skill) | Policy mirrors | Statements become true once the file and the `tier-classification` step exist; no edit (policy edits are limited to the citation) |
| `.claude/rules/general-code-change.md` and bundled copy | 29 | Policy mirror | Becomes true; no edit |
| `.agents/skills/general-code-change/SKILL.md` and bundled copy | 32 | Codex mirror | Becomes true; no edit (see A.4 for a separate broken citation on the same line) |
| `.claude/rules/parallel-orchestration.md` and bundled copy | 234, 256 | Policy mirror (mandate-read doctrine) | No edit |
| `.claude/skills/parallel-plan/SKILL.md` and bundled copy | 252 | Skill | No edit |
| `config/blast-radius.json` | 11 (`shared_surfaces`), 26 (`mandate_reads`) | Runtime config | No edit. This item's plan writes `quality-tiers.yml`, so per `.claude/rules/parallel-orchestration.md:253-258` the planner must append it explicitly to the declared radius |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | 9, 18 | Bundled config | No edit |
| `scripts/dev_tools/_blast_radius_normalization.py` | 70 | Comment | No edit |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 77-79 | Test support (portable shared surfaces) | No edit |
| `tests/scripts/dev_tools/test_blast_radius_{normalization,mergeable_paths,mandate_reads,invariants,extraction}.py` | various | Test data strings | No edit; none asserts file existence |
| `tests/scripts/claude-lib/blast-radius/*.Tests.ps1` (6 files) | various | Test data strings | No edit |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | 249 | Test fixture string `'docs/ci.research.md'` (arbitrary separator-bearing surface) | No edit; it is not a citation |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 80, 101, 110 | Test helper | No edit |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 110 | Test data | No edit |
| `tests/fixtures/blast_radius/**` (14 JSON files) | various | Test fixtures | No edit |

### A.3 Historical and other-feature documents (do not edit)

All remaining hits are under `docs/features/completed/**`, `docs/features/active/<other features>/**`
(#621, #763, #507, #762, #508), `docs/features/potential/**`, `docs/features/epics/**`,
`docs/features/parallel/**`, and `docs/research/**`. These are historical or owned by other features.

### A.4 Out-of-scope defect observed (record, do not fix here)

`.agents/skills/general-code-change/SKILL.md:32`, `.agents/skills/general-unit-test/SKILL.md:29,92`, and
their bundled copies cite `.agents/skills/quality-tiers.md`. That path does not exist (the skill is at
`.agents/skills/quality-tiers/SKILL.md`). This is a different broken citation from #511 and falls
outside the operator's "limited to the citation correction" scope. Recommend a follow-up potential-bug
entry.

### A.5 Parity and pin mechanisms that bind the edited files

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143`
  (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`): every repo `.claude/**` file must
  exist in `extensions/drm-copilot/resources/claude-customizations/` with identical text.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228`
  (`test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`): the same for `.agents/**`
  and `.codex/**`.
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:45-52,377-401`: `quality-tiers.md` must stay
  one of exactly four unconditional rules (`paths: ["**"]`). A line-9 edit does not touch frontmatter.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:72` and
  `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:118` pin
  membership only, not content.
- Frozen digest pins: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:143-152`
  pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. No
  SHA-256 pin covers any file this change edits (Grep for `sha256|digest` near `quality-tiers`,
  `general-code-change`, or `rules/` in `tests/`, `scripts/`, `extensions/drm-copilot/test/`, and `config/`
  returns nothing).
- There is no sync script. The bundled copies are maintained by hand in the same commit;
  `scripts/dev_tools/agentic_sync.py` syncs `.github/*` between two repos only (lines 24-29), and
  `scripts/dev_tools/generate_codex_agent_variants.py` does not touch `.agents/skills` or `rules/`.

## 3. Question B: What actually defines the tier system, and the corrected citation

The tier definitions (`.claude/rules/quality-tiers.md:11-16`) and the gate matrix (lines 23-48) are
stated inline in the rule itself. The `.agents` skill is a converted copy of the same text. No other
document defines tiers: `.github/instructions/*` has no tier content, and there is no `quality-tiers`
skill under `.claude/skills/` (the #336 triage comment's "the `quality-tiers` skill" is the `.agents`
Codex mirror). After this change the per-project assignment lives in `quality-tiers.yml`.

Recommended replacement, applied identically in all four files from A.1 (rule line 9, skill line 12):

- Old substring: ``The tier system source of truth is `docs/ci.research.md` section 1; the file `quality-tiers.yml` at the repository root maps every project to a tier.``
- New substring: ``The tier definitions and gate matrix in this document are the tier system's source of truth; the file `quality-tiers.yml` at the repository root maps every project to a tier.``

Rationale: the sentence stays valid inside both the rule and the converted skill ("this document"). It
does not name the validator script, so the rule text introduces no script reference that the skill
bundle contract (`scripts/dev_tools/skill_bundle_contract.py:43-68`) or push-down would need to carry.
The sentence that follows ("Adding a project without a tier classification fails CI.") and lines 20-21
stay unchanged.

## 4. Question C: Projects to classify

### 4.1 Deterministic definition of "project"

The validator derives projects from the tracked file list (`git ls-files`) using five fixed rules. The
exclusions are applied first: any path under `tests/`, `docs/`, `extensions/drm-copilot/resources/`
(bundled payload copies), or `node_modules/`.

1. R1, manifest roots: the directory of every tracked `package.json` or `*.csproj`.
2. R2, PowerShell module roots: the directory of every tracked `*.psd1` that has a tracked sibling
   `<same-stem>.psm1`. This excludes the settings `.psd1` files mechanically.
3. R3, script roots: every immediate child directory `scripts/<name>` that directly contains at least
   one tracked `.py`, `.ps1`, `.psm1`, or `.sh` file.
4. R4, runtime library roots: every immediate child directory `.claude/lib/<name>` that contains a
   tracked file.
5. R5, hook roots: `.claude/hooks` and `.codex/hooks` when they contain a tracked file.

Nested projects are allowed (`scripts/powershell/PoshQC` inside `scripts/powershell`). A file belongs
to the most specific enclosing project. Loose scripts outside these roots (`.devcontainer/*.sh`,
`.github/codex/*.sh`, `.codex/codex-web-setup.sh`) are not projects under this definition. The spec
should state this explicitly.

### 4.2 Proposed classification (operator confirmation required)

Principle: classify against the tier definitions (harm model), and use the "Adapters & UI" and
"Scaffolding" examples (build scripts, dev tooling, manifests) where they apply. A project is T3 when
it ships into consumer workspaces or the VS Code host and wraps a host API the team does not own. A
project is T4 when it is repository-internal tooling or scaffolding. `scripts/` is not shipped:
`scripts/dev_tools/skill_bundle_contract.py:38` records `PUBLISHED_ROOT_FOLDERS = (".claude", "config")`.

| Path | Rule | Tier | Rationale |
|---|---|---|---|
| `.` | R1 | T4 | Root TypeScript scaffold (`src/hello-typescript.ts`) and tool configuration only |
| `extensions/drm-copilot` | R1 | T3 | VS Code extension and MCP server; glue over the VS Code API, MCP SDK, and subprocesses |
| `packages/mcp-server` | R1 | T4 | npm packaging manifest plus esbuild/prepack scripts; no source of its own |
| `scripts/powershell/PoshQC` | R2 | T3 | QC module bundled into the extension (`extensions/drm-copilot/resources/powershell/PoshQC`); wraps PSScriptAnalyzer and Pester |
| `scripts/dev_tools` | R3 | T4 | Repository-internal Python dev tooling (validators, CLIs); not published by push-down |
| `scripts/dev-tools` | R3 | T4 | PowerShell release, bootstrap, and developer scripts |
| `scripts/bash` | R3 | T4 | Shell QC and coverage scripts |
| `scripts/powershell` | R3 | T4 | `Publish-DrmCopilotExtension.ps1` build/publish script |
| `.claude/hooks` | R5 | T3 | Enforcement hooks shipped to consumers; adapters over the Claude Code hook payload API |
| `.codex/hooks` | R5 | T3 | Enforcement hooks shipped to consumers; adapters over the Codex hook API |
| `.claude/lib/<name>` (14 directories, listed in Numeric Derivation Evidence) | R4 | T3 | Runtime libraries shipped in the `.claude` bundle and loaded by hooks and skills in consumer workspaces |

Deferred elevation candidates (record in the spec as an operator decision, not in this change's
default): `.claude/lib/cleanup-manifest` and `.claude/lib/worktree-resolution` (worktree removal can
lose uncommitted work: silent data loss fits T1), and `extensions/drm-copilot` push-down (writes into
consumer workspaces: T2 candidate). If any of these is raised to T1 or T2, it takes on property-test
density and mutation obligations for which the repository has no approved tooling (Section 1). The
elevation should therefore travel with an explicit tooling decision.

## 5. Question D: Enforcement design

### 5.1 Candidate approaches

- Selected: a Python validator under `scripts/dev_tools/` invoked as a named step
  (`tier-classification`) in the existing `quality-checks7` job of `.github/workflows/_quality-checks.yml`.
  - Precedent: the same job already runs `python -m scripts.dev_tools.generate_codex_agent_variants --check`
    (lines 69-72) and `python -m scripts.dev_tools.check_python_coverage_thresholds` (lines 82-87).
  - Poetry and PyYAML are already installed in that job.
  - `.github/instructions/github-actions.instructions.md:8` says "Do not change the overall job
    structure unless explicitly requested". A step added to an existing job complies. A new job would
    also create a new required-check context and trigger the rename procedure in
    `.github/workflows/README.md:24-65`.
- Rejected: a new reusable workflow `_tier-classification.yml` with its own job. It repeats the
  Poetry setup, changes the job DAG and branch-protection contexts, and requires README table edits.
- Rejected: a PowerShell or bash validator. Neither is required, because the enforcement-hook "no
  Python" constraint applies to `.claude/hooks` (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`),
  not to CI scripts. A second implementation would also have no parity partner.
- Rejected: a curated list with no discovery. It cannot detect an unclassified new project, which is
  the core acceptance requirement.

### 5.2 Schema for `quality-tiers.yml`

```yaml
version: 1
projects:
  - path: extensions/drm-copilot
    tier: T3
    rationale: VS Code extension and MCP server; glue over host APIs.
  # one entry per discovered project
```

- Top-level keys: exactly `version` (integer, must equal `1`) and `projects` (non-empty list). Any
  other key is rejected.
- Entry keys: exactly `path`, `tier`, and `rationale`, all non-empty strings. Unknown keys are rejected.
- `tier` must be one of `T1`, `T2`, `T3`, `T4`.
- `path` is repository-relative POSIX: `.` for the root; no leading `/`, no drive letter, no `\`, no
  trailing `/`, and no `..` or `.` segments other than the bare root.
- Use a list rather than a mapping keyed by path. `yaml.safe_load` silently keeps the last value for
  duplicate mapping keys, so a mapping schema cannot detect duplicate entries. Also load through a
  `yaml.SafeLoader` subclass that rejects duplicate mapping keys, so a repeated top-level `projects:`
  key cannot hide entries.

### 5.3 Validator

- Pure core: `scripts/dev_tools/quality_tiers_contract.py`. It contains schema parsing to frozen
  dataclasses, `discover_projects(tracked_paths: Iterable[str]) -> frozenset[str]` implementing
  R1-R5, and `find_classification_errors(...) -> list[QualityTierError]`. It does no I/O.
- CLI and I/O: `scripts/dev_tools/check_quality_tiers.py` with `main(argv) -> int`, invoked as
  `poetry run python -m scripts.dev_tools.check_quality_tiers`. The split follows
  `skill_bundle_contract.py` / `skill_bundle_contract_cli.py`.
- Naming: avoid a `validate_*` name. `config/blast-radius.json:15-19` makes
  `scripts/dev_tools/validate_*.py` a shared-surface glob, which would force contention with every
  item that touches a validator.
- File reads use `Path.read_text` only (the precedent in `check_python_coverage_thresholds.py:38-43`),
  which keeps the reader testable with the `mem_fs_path` fixture (`tests/conftest.py:146`).
- Tracked-file enumeration: an injected runner that calls `git ls-files -z`, with `git` resolved
  through `shutil.which`. The pre-authorized suppression is
  `# noqa: S603 - static analysis can't verify runtime validation` (`.claude/rules/python-suppressions.md:25-31`);
  S607 is not authorized (line 125-127). `git ls-files` excludes `node_modules/`, `.venv/`,
  `.claude/worktrees/`, and other gitignored state without an ad-hoc prune list. A filesystem walk
  would reproduce the gitignored-state false positives recorded for the bundle-parity test (#510).
- Python 3.10 compatibility is mandatory because the job matrix runs 3.10-3.13
  (`_quality-checks.yml:13`). Do not use `tomllib`, `typing.Self`, or other 3.11+ APIs. Pyright is
  pinned to 3.12 (`pyproject.toml:145`) and will not catch this.

Failure modes. All errors are accumulated and reported in one run, each on stderr and prefixed with
an error code:

| Code | Condition |
|---|---|
| QT001 | `quality-tiers.yml` missing or unreadable |
| QT002 | Invalid YAML, duplicate mapping key, or root not a mapping |
| QT003 | Schema violation (bad/missing `version`, `projects` not a non-empty list, entry not a mapping, missing or unknown key, non-string value) |
| QT004 | `tier` not in {T1, T2, T3, T4} |
| QT005 | Duplicate `path` entries |
| QT006 | Malformed `path` (absolute, backslash, trailing slash, `..`) |
| QT007 | Entry `path` is not a discovered project (stale entry or nonexistent path) |
| QT008 | Discovered project has no entry (unclassified) |
| QT009 | `git ls-files` unavailable or failed (fail closed; never an empty project set that passes) |

Exit codes: `0` when valid, `1` for any QT error, and `2` from argparse usage errors (the same
contract as `check_python_coverage_thresholds.py:243-320`). QT001 and QT002 stop evaluation after
reporting because no entries can be read. QT003-QT008 are collected together.

### 5.4 Workflow change

In `.github/workflows/_quality-checks.yml`, insert after the "Verify Codex agent deployment profiles"
step (lines 69-72) and before "Run tests with Pytest":

```yaml
      - name: tier-classification
        run: |
          poetry run python -m scripts.dev_tools.check_quality_tiers
        continue-on-error: false
```

`actions/checkout@v7` with its default shallow depth still supports `git ls-files`. The feature-review
rule `modified-workflow-needs-green-run` (`.claude/rules/ci-workflows.md:37`) requires a green run on
the branch head before merge.

## 6. Question E: Tests affected

- Must stay green with same-commit mirror edits: the two byte-identical payload tests in A.5. Edit
  all four A.1 files in one commit. No regeneration script exists.
- Unaffected: `test_claude_rules_frontmatter.py` (frontmatter unchanged), pack-manifest completeness
  tests (membership only), `PINNED_FROZEN_SURFACE_HASHES` (different files), and blast-radius tests
  (string data only; none asserts that `quality-tiers.yml` is absent).
- New: `tests/scripts/dev_tools/test_quality_tiers_contract.py` and
  `tests/scripts/dev_tools/test_check_quality_tiers.py`. These mirror the two new modules, following
  `.claude/rules/general-unit-test.md` "Test File Location".
- New repository contract test (reads committed text only, the same pattern as
  `test_claude_rules_frontmatter.py`): the committed `quality-tiers.yml` parses and passes the schema
  checks (QT002-QT006) without invoking git. Full discovery coverage stays with the CI step, because
  unit tests may not start external processes.

Test scenarios (no code). Each uses in-memory path lists and YAML text:

- Positive: a full valid file with the discovered set yields no errors and exit 0.
- The regression the issue requires: removing one entry yields QT008 naming that path, and exit 1.
- Each QT code has at least one negative case. Include both duplicate forms (repeated list entry, and
  a repeated top-level key).
- Discovery boundaries: a settings `.psd1` with no sibling `.psm1` is not a project; files under
  `extensions/drm-copilot/resources/**` and `tests/fixtures/**/*.csproj` are ignored;
  `scripts/<name>` without a direct code file is not a project; nested `scripts/powershell/PoshQC`
  and `scripts/powershell` are both discovered.
- Path normalization: backslash, trailing slash, `..`, and absolute path.
- CLI: a missing file returns 1 with QT001; a failed git runner returns 1 with QT009; a successful run
  returns 0.
- Tier-dependent obligation: the new modules sit in `scripts/dev_tools` (proposed T4), so no property
  tests are required. Coverage floors (85% line, 75% branch) still apply uniformly.

## 7. Question F: Toolchain commands

Python (`.claude/rules/python.md:13-18`; CI `_quality-checks.yml:54-87`):

1. `poetry run black .` (CI: `poetry run black --check .`)
2. `poetry run ruff check .`
3. `poetry run pyright`
4. Architecture-boundary stage: no Python architecture-boundary tool is configured in `pyproject.toml`
   (verified dependency list, lines 16-45). Record the stage as not applicable.
5. Targeted tests with coverage (dotted `--cov` form; a `--cov=<path>.py` form measures nothing):
   `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing`
6. Full suite with the coverage gate:
   `poetry run pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`
   then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`
7. Integration: `poetry run python -m scripts.dev_tools.check_quality_tiers` (expect exit 0). Then run
   the negative integration check on an uncommitted working-copy edit: remove one entry, expect exit 1
   with QT008, and restore the entry.

Workflow YAML: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1` (local). Observation:
`.github/instructions/github-actions.instructions.md:15` says a CI job `actionlint` exists in
`ci.yml`, but none does (verified at `ci.yml:10-41`). This is out of scope and a follow-up candidate.

Markdown mirrors: no formatter. The parity tests in A.5 are the gate.

## 8. Risks

- Tier assignments are a policy decision. The spec should present Section 4.2 for operator
  confirmation and record the deferred T1/T2 candidates.
- The pushed-down rule still tells consumer workspaces that CI fails on an unclassified project; those
  workspaces have neither the file nor the validator. This is out of scope under the citation-only
  constraint. Recommend a follow-up.
- Discovery rules R3-R5 use fixed roots. A new code root elsewhere (for example a new top-level
  directory with no manifest) would not be discovered. Mitigation: R1 catches any new
  `package.json`/`*.csproj` anywhere, and the rule list is a single constant in the pure core.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: `quality-tiers.yml` classifies exactly 24 discovered projects at the time of this change.
- Complete Family: package.json, .psd1, scripts/, .claude/lib/, .claude/hooks, .codex/hooks
- Exhaustive Search Scope: entire repository tree of the worktree, with the exclusions below applied to every rule
- Inclusion Rules: R1-R5 from Section 4.1 (package.json and csproj manifest directories; .psd1 with sibling .psm1; immediate scripts/ children with direct code files; immediate .claude/lib/ children; .claude/hooks and .codex/hooks directories)
- Exclusion Rules: paths under tests/, docs/, extensions/drm-copilot/resources/, node_modules/; .psd1 files without a same-stem .psm1; gitignored paths
- Primary Search Strategy or Query Expression: Glob enumeration by file name, with package.json via `**/package.json`, .psd1 via `**/{pyproject.toml,*.csproj,*.sln,*.slnx,*.psd1,Cargo.toml,go.mod}` checked against sibling .psm1 files, scripts/ children via `scripts/*/*.{py,ps1,psm1,sh,psd1,cjs,ts}` plus `scripts/[!d]*/**/*`, .claude/lib/ children via `.claude/lib/*/*`, and .claude/hooks plus .codex/hooks via `{.claude/hooks/*,.codex/hooks/*,.codex/*}`
- Primary Member Set: ., extensions/drm-copilot, packages/mcp-server, scripts/powershell/PoshQC, scripts/dev_tools, scripts/dev-tools, scripts/bash, scripts/powershell, .claude/hooks, .codex/hooks, .claude/lib/bash, .claude/lib/blast-radius, .claude/lib/ci-gate, .claude/lib/cleanup-manifest, .claude/lib/codex-routing, .claude/lib/discovery-validation, .claude/lib/hook-payload, .claude/lib/mermaid, .claude/lib/model-routing, .claude/lib/orchestrator-state, .claude/lib/parallel-drift, .claude/lib/project-file-merge, .claude/lib/requirements, .claude/lib/worktree-resolution
- Primary Count: 24
- Cross-check Search Strategy or Query Expression: Grep content search grouped by parent directory, with package.json via pattern `"name"\s*:` over glob `**/package.json`, .psd1 via pattern `RootModule` over glob `**/*.psd1`, scripts/ via pattern `^` files_with_matches over path scripts/ grouped by first segment, .claude/lib/ via pattern `^` files_with_matches over path .claude/lib/ grouped by directory, and .claude/hooks plus .codex/hooks via pattern `^` count mode over each hook path
- Cross-check Member Set: ., extensions/drm-copilot, packages/mcp-server, scripts/powershell/PoshQC, scripts/dev_tools, scripts/dev-tools, scripts/bash, scripts/powershell, .claude/hooks, .codex/hooks, .claude/lib/bash, .claude/lib/blast-radius, .claude/lib/ci-gate, .claude/lib/cleanup-manifest, .claude/lib/codex-routing, .claude/lib/discovery-validation, .claude/lib/hook-payload, .claude/lib/mermaid, .claude/lib/model-routing, .claude/lib/orchestrator-state, .claude/lib/parallel-drift, .claude/lib/project-file-merge, .claude/lib/requirements, .claude/lib/worktree-resolution
- Cross-check Count: 24
- Member-set Comparison: the normalized primary and cross-check member sets are identical (24 = 24). Supporting detail: package.json gave 3 files in both searches; RootModule matched `scripts/powershell/PoshQC/PoshQC.psd1` and the excluded bundled copy under `extensions/drm-copilot/resources/`; scripts/ first segments were bash, dev-tools, dev_tools, powershell in both; .claude/lib/ gave 14 directories from 56 files in both; `.claude/hooks` returned 47 files and `.codex/hooks` 33 files

## Automation Feasibility

The filename and the delegation carry no autonomous-execution or human-interaction token, so the hook
does not require this section; it is included for completeness. Every step is automatable in the
agent toolchain: the four mirror edits, the YAML authoring, the two Python modules and their tests,
and the workflow step. One step needs the operator: confirming the Section 4.2 tier assignments,
because tier choice is a policy decision.
