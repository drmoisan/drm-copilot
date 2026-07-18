# Policy Audit — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T13-00
- Branch: `feature/legacy-discovery-init-templates-362` (HEAD `48d16f6f953c82383d993b0b69b61a2c90800e3a`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Merge-base: `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`
- Audit scope: full branch diff (`git diff f18c1c16f3eb111f0acef5eb3c46be1fb563aac0..HEAD`) — 23 tracked files changed (929 insertions, 108 deletions): 4 production Python modules in `scripts/dev_tools/discovery/` (`init_cli.py`, `init_flow.py`, `init_models.py`, plus a rewrite of the pre-existing `__init__.py`), 4 new test modules, one `pyproject.toml` line, one committed template file (`docs/discovery/templates/domain-profile/domain-profile.yaml`), and feature-folder docs/evidence.
- A material, independently-discovered gap exists between this list and the feature's actual working-tree deliverable: see "Untracked Template Files" below.

## Language Scope

Changed files by language: Python (production + tests), TOML (`pyproject.toml` config line), YAML (one committed template), Markdown (feature docs/evidence). TypeScript, PowerShell, C#, and GitHub Actions workflows: zero changed files on the branch — no coverage or toolchain verdict required for those languages. No workflow files were touched, so `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` do not apply to this diff.

## Rejected Scope Narrowing

None. The orchestrator's delegation prompt explicitly instructed independent judgment on the upstream-dependency-divergence fact pattern rather than narrowing scope away from it ("Evaluate whether this divergence constitutes a Blocking, Partial, or non-blocking finding given the plan's own explicitly recorded open questions on this point, and record your independent determination"). This is not an attempted scope narrowing; it is engaged below under "Upstream Contract Divergence (9001/9002)". No other narrowing instruction was detected in the delegation prompt. The full branch diff against the resolved base was audited.

## Untracked Template Files (Blocking)

**FAIL.** Seven of the eight required template files are not part of the committed branch diff. `.gitignore` line 6 is the bare token `artifacts` (no leading `/`, no trailing `/`), which git matches against any path component named `artifacts` anywhere in the tree — not only the top-level `artifacts/` directory. This silently ignores `docs/discovery/templates/artifacts/**`, the exact location this feature's spec (`spec.md` "Template location") mandates for the seven artifact templates.

Verification performed:
- `git ls-tree -r HEAD --name-only | grep docs/discovery` returns only `docs/discovery/templates/domain-profile/domain-profile.yaml`.
- `git status --porcelain --ignored=matching` reports `!! docs/discovery/templates/artifacts/` (ignored, untracked).
- A detached `git worktree add` at the branch head (`48d16f6f`) was created and inspected: `find <worktree>/docs/discovery -type f` returns only the one committed `domain-profile.yaml` file. The seven `*.template.json` files exist only in this reviewer's working tree as leftover, ignored artifacts from the executor's local run; they do not exist in the actual commit and would not exist in any fresh clone or CI checkout of this branch.

Impact: `dev.discovery.init` cannot function as specified against a clean checkout — `validate_template_set` would raise `FileNotFoundError` for the seven missing artifact templates before writing anything, and `tests/scripts/dev_tools/discovery/test_domain_neutrality.py` (which reads `docs/discovery/templates/**` directly from disk via `pathlib.Path.read_text`) would raise `FileNotFoundError` on a clean checkout's test run, not merely report a wrong result.

## Upstream Contract Divergence (9001/9002) — Independent Determination: Blocking

The delegation prompt asked for an independent judgment on whether the flagged divergence (9001 now uses a nested domain-profile structure; 9002's schemas live at `schemas/discovery/v1/*.schema.json` with additional required fields, not `docs/discovery/schemas/v1/`) is Blocking, Partial, or non-blocking, given the plan's own recorded open questions.

**Independent determination: Blocking**, for a reason distinct from — and stronger than — a normal "forward dependency accepted as an open risk": both upstream features had already been merged into this feature's own merge-base *before* this feature's plan and spec were authored, so the divergence was discoverable by reading the already-present code, not a genuinely unresolved parallel-track risk.

Evidence:
- `git log --oneline -3 -- scripts/dev_tools/discovery/domain_profile.py schemas/discovery/v1/feature-contract.schema.json` shows both files were added by commits `a5209a71` (#360, legacy-discovery-config-contract) and `b69a84e1` (#359, legacy-discovery-schemas), both of which are ancestors of the merge-base `f18c1c16` — i.e., already merged into the base this feature's plan (dated the same day, 2026-07-17) was written against.
- `spec.md` "Upstream Dependencies" states 9001 "has not yet resolved whether the parser is real PyYAML or the repository's existing hand-rolled frontmatter regex convention... confirmed unresolved by research" and that 9002 has "No schema files exist in the repository as of this writing." Both statements are factually incorrect as of the plan's own authoring date, given the file evidence above.
- Reviewer ran the real, already-merged 9001 loader (`parse_domain_profile_text`) against the committed template content of `docs/discovery/templates/domain-profile/domain-profile.yaml` and obtained a hard failure: `DomainProfileError: 8 profile error(s)` — unknown top-level keys `legacy_source_path`/`target_path`/`artifact_output_dir`; missing required `profile_version`/`legacy_source`/`target`/`artifacts`; `technology_stack` present as a string where a mapping is required.
- Reviewer ran `jsonschema.validate` with the real, already-merged 9002 schema (`schemas/discovery/v1/feature-contract.schema.json`) against the template instance (`docs/discovery/templates/artifacts/feature-contract.template.json`, present only in the working tree per the untracked-files finding above) and obtained: `Additional properties are not allowed ('version' was unexpected)`. The instance is also missing every one of the schema's required fields except `$schema`/`id` (`schema_version`, `title`, `description`, `status`, `acceptance_criteria` are all absent; the template uses `version` where the schema requires `schema_version`).
- The template's `"$schema": "../../schemas/v1/feature-contract.schema.json"` resolves, per `validate_json.py`'s documented no-scheme `_load_schema` rule (`base_path.parent / uri`), to `docs/discovery/schemas/v1/feature-contract.schema.json` — a path that does not exist anywhere in the repository. The real schemas live at repo-root `schemas/discovery/v1/`, a different directory this feature's spec never names.
- Compounding the same root cause: `test_schema_conformance_pending_issue_9002` (`tests/scripts/dev_tools/discovery/test_init_flow.py`) is skipped with the stated reason "no schema files exist in the repository yet," which is false — 9002's schemas already exist in the repository and did so before this feature's own plan was authored. Un-skipping and running this test's intended assertion body against the real schemas reproduces the `jsonschema.validate` failure above.

Rationale for Blocking (not Partial or non-blocking): the plan's own "Design Notes Carried Into Implementation" and "Open Questions" sections explicitly frame this as an accepted, unresolved forward dependency owned by 9001/9002 and "not resolved by this feature," which would ordinarily support a Partial or non-blocking classification for a genuinely-parallel, not-yet-landed dependency. That framing does not hold here because both dependencies were concrete, merged, and inspectable in this exact repository at the time this feature's own research, spec, and plan were produced. This is a research-completeness defect that produced two independently reproduced functional failures (the generated domain-profile config cannot be parsed by the real loader; the generated artifact instances cannot be validated against the real schema), not a deferred risk. The base branch for this PR is the epic integration branch where 9001 and 9002 already live as real, working code — this feature's deliverable is demonstrably incompatible with its immediate neighbors in that same tree.

## Public API Compatibility (`scripts/dev_tools/discovery/__init__.py`)

**FAIL.** This feature's diff replaces the pre-existing `scripts/dev_tools/discovery/__init__.py` (added by #360) — which re-exported `DomainProfile`, `LegacySourceConfig`, `TargetConfig`, `TechnologyStackConfig`, `ArtifactsConfig`, `DomainProfileError`, `parse_domain_profile_text`, `load_domain_profile`, `DEFAULT_PROFILE_FILENAME` — with a bare one-line docstring and no exports. Verified: `poetry run python -c "from scripts.dev_tools.discovery import DomainProfile"` raises `ImportError: cannot import name 'DomainProfile' from 'scripts.dev_tools.discovery'`.

This is a breaking change to a public API with no caller update, no compatibility note, and no mention anywhere in this feature's spec/plan/commit message. It directly reverses an acceptance criterion feature #360 itself declared: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md:81` — "Acceptance: `from scripts.dev_tools.discovery import DomainProfile, DomainProfileError, load_domain_profile, parse_domain_profile_text, DEFAULT_PROFILE_FILENAME` succeeds." No test in the current suite covers the package-level re-export, so the regression is untested and was not caught by the toolchain loop. This violates `.claude/rules/general-code-change.md` ("Public APIs and Compatibility": "Avoid breaking public APIs. If a breaking change is necessary, update all callers in-repo and call it out clearly in the change description.").

## Domain-Neutrality Invariant (epic-wide)

**PASS** (for the content actually present). The committed `domain-profile.yaml` and the working-tree-only artifact templates contain none of the banned identifiers (`taskmaster`, `tmw`, `outlook`, `vsto`), verified by reviewer grep and by `test_domain_neutrality_templates_contain_no_disallowed_tokens` / `test_domain_neutrality_rendered_output_contains_no_disallowed_tokens` (both pass in this working tree). This PASS is scoped to token content only; it does not offset the Blocking findings above regarding the templates' committed presence and structural correctness.

## Coverage (Python — mandatory, uniform tier rule per `.claude/rules/quality-tiers.md`)

**PASS.** Independently re-verified by the reviewer:

- Package scope: `poetry run pytest tests/scripts/dev_tools/discovery --cov=scripts/dev_tools/discovery --cov-branch --cov-report=term-missing` — exit 0, 80 passed, 1 skipped. New/changed files: `init_cli.py` 100%/100% (line/branch, n/a for 0-branch), `init_flow.py` 100%/100%, `init_models.py` 86% line (branch partials on `Protocol` ellipsis-body lines, not executable logic).
- Repo-wide: `poetry run pytest --cov --cov-branch --cov-report=term-missing` — exit 0, 1704 passed, 1 skipped, TOTAL line coverage 9951/11287 = 88.16% (>= 85%), branch coverage 3350/4246 = 78.90% (>= 75%). Matches the executor's own evidence (`evidence/qa-gates/phase6-pytest.md`, `phase6-coverage-delta.md`) exactly.
- No regression relative to baseline: executor's `evidence/qa-gates/phase6-coverage-delta.md` records baseline 88.07%/78.87% -> post-change 88.16%/78.90% (improved, not regressed).
- Coverage artifact present: `artifacts/python/lcov.info` exists and was regenerated by the reviewer's re-run.

Other languages: zero changed files on the branch — no coverage verdict required for TypeScript, PowerShell, or C# on this diff.

## Coverage Exclusion Policy

**PASS.** No coverage-tool configuration or `exclude` entry was changed by this diff.

## Suppressions

**PASS.** Zero `# noqa`, `# type: ignore`, `# pyright: ignore`, or `# pragma: no cover` directives in any file added by this branch (grep-verified over `scripts/dev_tools/discovery/{init_cli,init_flow,init_models}.py` and `tests/scripts/dev_tools/discovery/{test_init_cli,test_init_flow,test_init_models,test_domain_neutrality}.py`).

## Test-File Location Mirroring

**PASS.** `tests/scripts/dev_tools/discovery/{test_init_cli,test_init_flow,test_init_models,test_domain_neutrality}.py` mirrors `scripts/dev_tools/discovery/{init_cli,init_flow,init_models}.py` plus the template-content regression test; no colocated test files in the production tree.

## No Temporary Files in Tests

**PASS.** All new tests use the in-memory `FakeFileSystem`/`_FakeFileSystem` test doubles (dict/set-backed) or read fixed in-repo files via `pathlib.Path.read_text`; no `tmp_path`, `tempfile`, or `NamedTemporaryFile` usage (grep-verified).

## File-Size Limit (<= 500 lines)

**PASS.** `init_cli.py` 66, `init_flow.py` 91, `init_models.py` 81, `test_init_cli.py` 129, `test_init_flow.py` 243, `test_init_models.py` 94, `test_domain_neutrality.py` 76. All well under 500.

## Toolchain (Python: format -> lint -> type-check -> test)

**PASS** for the stages that ran and were independently re-verified. Reviewer re-run, all exit 0:
- Black `--check` (package scope): "14 files would be left unchanged."
- Ruff (package scope): "All checks passed!"
- Pyright (package scope): "0 errors, 0 warnings, 0 informations."
- Pytest (repo-wide): 1704 passed, 1 skipped.

These results match the executor's own evidence (`evidence/qa-gates/phase6-black.md`, `phase6-ruff.md`, `phase6-pyright.md`, `phase6-pytest.md`) exactly. No architecture-boundary or contract/schema gate is configured for `scripts/dev_tools` beyond `validate_json.py`'s governed-glob mechanism, which this feature's own broken `$schema`/field-shape defects would fail if the schema-conformance test were un-skipped (see "Upstream Contract Divergence" above) — the toolchain's green result does not contradict that finding, because the relevant check (schema conformance) is the one test in the suite that is skipped rather than executed.

## Dependency Policy

**PASS.** No dependency added or changed.

## Evidence Location Compliance

**PASS.** All evidence produced for this feature lives under the canonical `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/<kind>/` tree (`baseline/`, `qa-gates/`). `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violations. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` was found in the branch diff.

## Tone Policy

**PASS.** All agent-authored documentation and evidence in the diff use neutral, factual language consistent with `.claude/rules/tonality.md`.

## Verdict Summary

| Policy area | Verdict |
|---|---|
| Untracked template files (`.gitignore` collision) | FAIL — Blocking |
| Upstream contract divergence (9001 domain-profile shape) | FAIL — Blocking |
| Upstream contract divergence (9002 `$schema` path and required fields) | FAIL — Blocking |
| Public API compatibility (`discovery/__init__.py` re-export removed) | FAIL — Blocking |
| Domain-neutrality invariant (token content only) | PASS |
| Coverage thresholds (Python, line >= 85% / branch >= 75%) | PASS |
| No coverage exclusion of production files | PASS |
| No prohibited suppressions | PASS |
| Test-file location mirroring | PASS |
| No temp files in tests | PASS |
| File-size limit | PASS |
| Toolchain clean pass (format/lint/type/test stages that ran) | PASS |
| Dependency policy | PASS |
| Evidence location compliance | PASS |

- FAIL findings: 4 (all Blocking)
- Blocking PARTIAL findings: 0
- Remediation required: YES — see `remediation-inputs.2026-07-18T13-00.md`.
