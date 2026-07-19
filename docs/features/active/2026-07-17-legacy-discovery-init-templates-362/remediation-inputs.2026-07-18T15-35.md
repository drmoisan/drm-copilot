# Remediation Inputs — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T15-35
- Feature branch: `feature/legacy-discovery-init-templates-362` (HEAD `7610bf2539f62bba5e4489f559ed486fb368043a`)
- Integration branch: `epic/legacy-discovery-and-parity-integration` (`origin/epic/legacy-discovery-and-parity-integration` at `85e7bea2` at fetch time)
- Merge base: `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`
- Source signal: `gh pr view 380 --json mergeable` reports `CONFLICTING` for PR #380 (base `epic/legacy-discovery-and-parity-integration`).
- Diagnostic commands run (working tree restored to clean at HEAD afterward — see step 5 below):
  - `git fetch origin epic/legacy-discovery-and-parity-integration`
  - `git merge --no-commit origin/epic/legacy-discovery-and-parity-integration` — exited non-zero (`1`) with `CONFLICT (content): Merge conflict in pyproject.toml`.
  - `git diff --name-only --diff-filter=U` — one conflicted file.
  - `git merge --abort` — restored the working tree to a clean state at `7610bf25...`.

Severity: **Blocking**. PR #380 cannot merge into `epic/legacy-discovery-and-parity-integration` until this conflict is resolved. This document is diagnostic capture only; no conflict content has been resolved and no commit was made during capture.

## Conflicted File List (1 file)

- `pyproject.toml`

## R1 — `pyproject.toml` `[tool.poetry.scripts]` conflict: adjacent `dev.discovery.*` line insertions

- **Root cause:** Both branches inserted a new `dev.discovery.*` console-script alias immediately after the shared line `"dev.discovery.init" = ...` / `"dev.discovery.profile" = ...` boundary in `[tool.poetry.scripts]`, at the same insertion point relative to the merge-base content, so git's line-based 3-way merge cannot resolve the region automatically:
  - This feature branch (`feature/legacy-discovery-init-templates-362`) added `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` (this feature's own CLI entry point, added in the commits building the init-templates feature).
  - The integration branch pulled in sibling feature #364 (`feat(discovery): add deterministic acceptance-scenario generator`, commit `688c99dd`) via fan-in commit `d1530986` (`merge(epic): fan in prepared feature legacy-discovery-validators (#379)`), which added `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"` at the same location.
  - Both lines are legitimate, independent additions — this is a true adjacent-insertion conflict, not a semantic disagreement about the same key. No content deletion or edit is involved; the correct resolution is expected to be additive (keep both lines), but that determination is left to the resolution task, not this capture task.
- **Evidence:**
  - `git diff --name-only --diff-filter=U` → `pyproject.toml` (only file).
  - `grep -n "<<<<<<<\|=======\|>>>>>>>" pyproject.toml` → lines `59`, `61`, `63` respectively.
  - `git log --oneline HEAD..origin/epic/legacy-discovery-and-parity-integration -- pyproject.toml` shows the epic-side commits that touched this file since the feature branched: `d1530986` (fan-in of #379), `688c99dd` (#364, the acceptance-scenario generator), `66d7da4a` (Poetry console-script registration/domain-neutrality phase).
- **Raw conflict-marker excerpt** (`pyproject.toml`, with surrounding context; line numbers are from the in-progress merge's working-tree copy captured during this task, before abort):

  ```
  47	[tool.poetry.scripts]
  48	atomic-executor = "scripts.dev_tools.atomic_executor.cli:main"
  49	codex-native-converter = "scripts.dev_tools.codex_native_converter.cli:main"
  50	shell-qc = "scripts.dev_tools.shell_qc:main"
  51	shell-qc-check = "scripts.dev_tools.shell_qc:main_check"
  52	shell-qc-format = "scripts.dev_tools.shell_qc:main_format"
  53	shell-qc-test = "scripts.dev_tools.shell_qc:main_test"
  54	
  55	# Dev Tools Aliases
  56	"dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"
  57	"dev.clean-devcontainer" = "scripts.dev_tools.clean_devcontainer:main"
  58	"dev.collect-commit-context" = "scripts.dev_tools.collect_commit_context:main"
  59	<<<<<<< HEAD
  60	"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
  61	=======
  62	"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
  63	>>>>>>> origin/epic/legacy-discovery-and-parity-integration
  64	"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
  65	"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
  66	"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
  67	"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
  68	"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
  69	"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
  70	"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
  71	"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
  72	"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
  73	"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
  74	"dev.fix-all" = "scripts.dev_tools.fix_all:main"
  ```

  `HEAD` in the excerpt above is this feature branch (`feature/legacy-discovery-init-templates-362` at `7610bf2539f62bba5e4489f559ed486fb368043a`); the lower side is `origin/epic/legacy-discovery-and-parity-integration`.

- **Not performed by this task (reserved for the resolution step):** determining the final merged content of lines 59–63, editing `pyproject.toml`, running `poetry lock`/`poetry check` or any toolchain command against the resolved file, committing the merge, or re-checking PR #380 mergeability. This capture task intentionally leaves the conflict unresolved in content and aborts the merge (see below) so the working tree returns to a clean pre-conflict state.

## Required Fix (for the later resolution task — not performed here)

1. Resolve `pyproject.toml` lines 59–63 by keeping both `"dev.discovery.init"` and `"dev.discovery.generate-acceptance-scenarios"` script entries (in either order), removing the conflict markers, so the merged `[tool.poetry.scripts]` block contains every entry from both sides with no duplicate keys.
2. Re-run `poetry check` (and `poetry lock --check` if the repo's lock policy requires it) against the resolved `pyproject.toml`.
3. Re-attempt the merge/rebase of `feature/legacy-discovery-init-templates-362` onto `origin/epic/legacy-discovery-and-parity-integration` and confirm `gh pr view 380 --json mergeable` reports `MERGEABLE` (or the merge completes cleanly if performed via merge commit rather than through the PR UI).
4. Re-run this feature's full toolchain loop (format, lint, type-check, test) after the resolution, since `pyproject.toml` changes can affect dependency resolution and script registration.

## Re-Verification Checklist for the Remediation Plan

1. Apply the fix in "Required Fix" above on a dedicated resolution commit (not part of this capture task).
2. Confirm `git diff --name-only --diff-filter=U` is empty after resolution.
3. Confirm `gh pr view 380 --json mergeable` reports `MERGEABLE`.
4. Re-run `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing` and capture fresh evidence under `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/`.
