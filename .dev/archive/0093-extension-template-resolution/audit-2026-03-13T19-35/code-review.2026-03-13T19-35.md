# Code Review — extension-template-resolution (#93)

## Executive summary

Relative to `origin/feature/expose-placeholder-commands-92`, this branch fixes the core extension bug by bundling feature templates under `extensions/drm-copilot/resources/feature-templates/`, injecting an explicit template-root from `extensions/drm-copilot/src/extension.ts`, and teaching the Python/PowerShell entry scripts to prefer bundled templates while keeping workspace fallback behavior. It also adds focused unit tests for argument wiring and template-root resolution, and it removes tracked extension coverage output from the repo.

**Feature folder selection rule:** I reviewed `docs/features/active/2026-03-12-extension-template-resolution-93/` because `artifacts/pr_context.summary.txt` points to that active folder and its suffix matches issue `#93`.

**Top 3 risks**
1. The acceptance-mandated integration scenario for `drmCopilotExtension.newPotentialEntry` is still missing, so the highest-risk runtime path is only covered at the unit/mocked boundary.
2. The branch contains substantial unrelated prompt/agent/customization churn, which increases review surface and regression risk beyond the bugfix itself.
3. Bundled markdown templates are now duplicated into extension resources without an automated parity check against the canonical repo templates, so future drift is a realistic maintenance risk.

**PR readiness:** **No-Go** until the open integration acceptance criterion is implemented/verified and the branch is narrowed or explicitly justified.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/test/extension.integration.test.ts` | suite at line 172; no `newPotentialEntry` scenario | The branch still does not automate the acceptance criterion that runs `newPotentialEntry` in a workspace lacking `docs/features/templates/` and proves the bundled templates are used successfully. | Add an integration-level Jest case that exercises `drmCopilotExtension.newPotentialEntry` against a workspace fixture without local templates and asserts successful creation via the bundled `resources/feature-templates` path. | This is the only remaining unchecked criterion in `issue.md`, and it is the closest thing to the original production failure mode. | `issue.md` leaves the criterion unchecked; `extension.test.ts:637-650` only verifies `-TemplateRoot` argument injection; `extension.integration.test.ts` contains no corresponding runtime scenario. |
| Minor | `scripts/dev_tools/new_potential_bug_entry.py`; `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` | lines 25, 33, 47, 52, 64, 104, 148, 163 in each file | Newly added/modified Python helper functions are missing the robust function docstrings required by the repo’s intent-first commenting policy for agent-authored Python. | Add contract-level docstrings to each helper and keep the bundled mirror in sync, or generate the bundled copy from the canonical source to avoid double maintenance. | This is a direct repo-policy requirement and improves reviewability for future maintenance of mirrored scripts. | Functions such as `validate_short_name`, `default_git_config_lookup`, `render_content`, `create_bug_entry`, `parse_args`, and `main` lack function docstrings in both files. |
| Minor | Multiple: `.github/agents/*`, `.github/skills/*`, `.github/prompts/review-feature.prompt.md`, mirrored customization copies | branch diff overview | The branch mixes the bug fix with broad agent/prompt/customization changes unrelated to issue `#93`. | Split unrelated automation-doc changes into a separate branch/PR, or explicitly justify them in the PR description and review them independently. | Narrow diffs reduce reviewer load and hidden-regression risk, especially for a bugfix branch intended to be minor-audit scoped. | `artifacts/pr_context.appendix.txt` lists 83 changed files, including 41 docs/templates/agents/tooling files outside the direct bugfix surface. |
| Minor | `extensions/drm-copilot/resources/feature-templates/**` | new bundled template tree | The new bundled template copies have no automated parity check against the canonical repo templates they are meant to mirror. | Add a small sync/parity verification step or test that compares bundled templates to canonical template sources. | Without a parity guard, future template changes can silently diverge between the repo and the extension bundle. | The branch adds 10 new bundled template files under `resources/feature-templates/` while preserving the canonical templates elsewhere in the repo. |

## Typed Python audit

### Strengths

- **No new production `Any`:** The changed Python production files use precise `Path | None`, `Callable`, `Protocol`, and dataclass-based seams. The only visible `Any` use is test-only monkeypatch plumbing.
- **No type-check weakening:** No broad `# type: ignore`, `# noqa`, or config loosening was introduced, and `poetry run pyright` passed cleanly.
- **Good boundary design:** `FileSystem` protocols plus `RealFileSystem` fakes keep file I/O testable without touching disk.
- **Explicit error handling:** The changed scripts raise/convert `ValueError` and `FileNotFoundError` explicitly, avoiding naked `except` blocks.

### Watch items

- **Docstring completeness:** The helper-level docstring gap called out above is the main Python-policy miss in the changed code.
- **Mirrored code maintenance:** The repo carries both canonical Python scripts and bundled extension mirrors; any future Python fix must keep both copies aligned unless generation/sync becomes automated.

## Test quality audit

- **Deterministic and isolated:** New tests use in-memory filesystems and mocked subprocess/VS Code APIs.
- **Fast:** Fresh execution stayed quick (`Pytest 2.97s`, `Jest 1.053s`, `Pester 5.93s`).
- **Readable:** Test names clearly express scenario and expected outcome.
- **Gap:** The acceptance-critical integration scenario for `newPotentialEntry` is still absent. Current coverage proves argument wiring and fallback logic, but not the end-to-end workspace behavior that originally failed in production.

## Security and correctness checks

- **Secrets:** No secrets or credentials were added.
- **Subprocess usage:** Runtime invocations remain explicit argv-array calls in TypeScript and bounded CLI calls in Python/PowerShell. That is good from an injection-resistance standpoint.
- **Input validation:** Short-name and feature-name validation remains explicit in the extension and Python/PowerShell scripts.
- **Correctness improvement:** The branch now fails missing-template cases clearly instead of silently “succeeding” against a non-existent workspace template path.

## Recommendation

This branch is **not ready to merge** yet. The implementation direction is sound and the fresh QA run is clean, but the review should stay red until:

1. the missing `newPotentialEntry` integration criterion is automated and evidenced, and
2. the Python helper docstring policy gap is closed,
3. preferably with unrelated prompt/agent churn removed from this bugfix branch.
