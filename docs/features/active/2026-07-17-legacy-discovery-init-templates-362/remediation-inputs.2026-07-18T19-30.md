# Remediation Inputs — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T19-30
- Remediation cycle: 4 (merge-conflict capture only; no content resolved)
- Feature branch: `feature/legacy-discovery-init-templates-362` (HEAD `f17f1af08c67568fbc14140a25882c068a50d2b0`)
- Integration branch: `epic/legacy-discovery-and-parity-integration` (`origin/epic/legacy-discovery-and-parity-integration` at `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3` at fetch time)
- Merge base: `85e7bea2bd2695114c9feffb2a4963da9f37c9ad` (this is the same tip the branch was last merged against in remediation cycle 2 — see `remediation-inputs.2026-07-18T15-35.md`)
- Source signal: `gh pr view 380 --json mergeable` reports `CONFLICTING` for PR #380 (base `epic/legacy-discovery-and-parity-integration`) after the epic branch advanced with an additional merged sibling feature (#363, analyzer-framework) since cycle 2.
- Diagnostic commands run (working tree restored to clean at HEAD afterward — see step 5 below):
  - `git fetch origin epic/legacy-discovery-and-parity-integration` — fetched tip `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3`.
  - `git merge --no-commit origin/epic/legacy-discovery-and-parity-integration` — exited non-zero (`1`) with `Auto-merging pyproject.toml` / `CONFLICT (content): Merge conflict in pyproject.toml`.
  - `git diff --name-only --diff-filter=U` — one conflicted file.
  - `git merge --abort` — restored the working tree to a clean state at `f17f1af0...`.

Severity: **Blocking**. PR #380 cannot merge into `epic/legacy-discovery-and-parity-integration` until this conflict is resolved. This document is diagnostic capture only; no conflict content has been resolved and no commit was made during capture.

## Conflicted File List (1 file)

- `pyproject.toml`

## R1 — `pyproject.toml` `[tool.poetry.scripts]` conflict: adjacent `dev.discovery.*` line insertions (cycle 4 recurrence, new sibling)

- **Root cause:** Both branches inserted a new `dev.discovery.*` console-script alias immediately after the shared line `"dev.discovery.profile" = ...` boundary in `[tool.poetry.scripts]` — wait, more precisely, at the insertion point immediately following `"dev.discovery.generate-acceptance-scenarios" = ...` and immediately before `"dev.discovery.profile" = ...` — so git's line-based 3-way merge cannot resolve the region automatically:
  - This feature branch (`feature/legacy-discovery-init-templates-362`) carries `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` (this feature's own CLI entry point, unchanged since cycle 2; issue #362).
  - The integration branch has now pulled in a second sibling feature since cycle 2: **#363, analyzer-framework** (`feat(discovery): add analyzer framework and inventory analyzer`, commit `054eaa06`), fanned in via merge commit `1d31dcd0` (`merge: integrate epic/legacy-discovery-and-parity-integration into feature/legacy-discovery-analyzer-framework-363`) and PR merge commit `a13adb8b` (`Merge pull request #378 from drmoisan/feature/legacy-discovery-analyzer-framework-363`). That feature added `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"` at the same insertion point.
  - This is a repeat of the cycle-2 conflict shape (same file, same insertion point, same key `dev.discovery.init` on our side) but with a **different sibling on the other side**: cycle 2's conflicting sibling was #364 (`dev.discovery.generate-acceptance-scenarios`, commit `688c99dd`), which has since been fanned into this feature branch itself (visible in `git log --oneline -- pyproject.toml` as `688c99dd feat(discovery): add deterministic acceptance-scenario generator (#364)` on our own branch history) and is therefore no longer a source of conflict. The new conflicting sibling is #363.
  - Both lines (`dev.discovery.init` and `dev.discovery.inventory`) are legitimate, independent additions — this is a true adjacent-insertion conflict, not a semantic disagreement about the same key. No content deletion or edit is involved; the correct resolution is expected to be additive (keep both lines), but that determination is left to the resolution task, not this capture task.
- **Evidence:**
  - `git diff --name-only --diff-filter=U` → `pyproject.toml` (only file).
  - `grep -n '<<<<<<<\|=======\|>>>>>>>' pyproject.toml` → lines `60`, `62`, `64` respectively.
  - `git log --oneline HEAD..origin/epic/legacy-discovery-and-parity-integration -- pyproject.toml` shows the epic-side commits that touched this file since this feature branch's last merge (cycle 2, at `85e7bea2`):
    - `a13adb8b` — `Merge pull request #378 from drmoisan/feature/legacy-discovery-analyzer-framework-363`
    - `1d31dcd0` — `merge: integrate epic/legacy-discovery-and-parity-integration into feature/legacy-discovery-analyzer-framework-363`
    - `054eaa06` — `feat(discovery): add analyzer framework and inventory analyzer` (the commit that actually inserted the `"dev.discovery.inventory" = ...` line and the `"^\s*\.\.\.\s*$"` coverage-exclude-lines entry; confirmed via `git show 054eaa06 -- pyproject.toml`)
  - `git show 054eaa06 -- pyproject.toml` confirms exactly two hunks added by the sibling commit: the `dev.discovery.inventory` script alias (at the conflicting insertion point) and an additional `[tool.coverage.report] exclude_lines` entry `"^\\s*\\.\\.\\.\\s*$"` appended at the end of that list. The `exclude_lines` addition merged cleanly (no conflict); only the script-alias insertion conflicted.
  - Our own branch's competing insertion is commit `48d16f6f` (`feat(discovery): add dev.discovery.init command and workspace templates`, Refs #362), confirmed via `git log -p -S'dev.discovery.init' -- pyproject.toml`.
- **Raw conflict-marker excerpt** (`pyproject.toml`, with surrounding context; line numbers are from the in-progress merge's working-tree copy captured during this task, before abort):

  ```
  47	[build-system]  (section header shown for orientation; actual [tool.poetry.scripts] block below)
  ...
  55	# Dev Tools Aliases
  56	"dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"
  57	"dev.clean-devcontainer" = "scripts.dev_tools.clean_devcontainer:main"
  58	"dev.collect-commit-context" = "scripts.dev_tools.collect_commit_context:main"
  59	"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
  60	<<<<<<< HEAD
  61	"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
  62	=======
  63	"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
  64	>>>>>>> origin/epic/legacy-discovery-and-parity-integration
  65	"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
  66	"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
  67	"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
  68	"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
  69	"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
  70	"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
  71	"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
  72	"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
  73	"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
  74	"dev.fix-all" = "scripts.dev_tools.fix_all:main"
  ```

  `HEAD` in the excerpt above is this feature branch (`feature/legacy-discovery-init-templates-362` at `f17f1af08c67568fbc14140a25882c068a50d2b0`); the lower side is `origin/epic/legacy-discovery-and-parity-integration` (at `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3`).

  Note: line 59 (`dev.discovery.generate-acceptance-scenarios`) is no longer part of the conflicted region — it merged cleanly because this feature branch already carries that entry (fanned in during a prior cycle via commit `688c99dd`, visible on this branch's own `git log -- pyproject.toml`). Only the `dev.discovery.init` vs. `dev.discovery.inventory` adjacent-insertion pair is in conflict this cycle.

- **Not performed by this task (reserved for the resolution step):** determining the final merged content of lines 60–64, editing `pyproject.toml`, running `poetry lock`/`poetry check` or any toolchain command against the resolved file, committing the merge, or re-checking PR #380 mergeability. This capture task intentionally leaves the conflict unresolved in content and aborts the merge (see below) so the working tree returns to a clean pre-conflict state.

## Required Fix (for the later resolution task — not performed here)

1. Resolve `pyproject.toml` lines 60–64 by keeping both `"dev.discovery.init"` and `"dev.discovery.inventory"` script entries (in either order), removing the conflict markers, so the merged `[tool.poetry.scripts]` block contains every entry from both sides with no duplicate keys.
2. Confirm the sibling's clean (non-conflicting) `[tool.coverage.report] exclude_lines` addition (`"^\\s*\\.\\.\\.\\s*$"`, from commit `054eaa06`) is present in the merged file — it should already be carried through automatically since it did not conflict, but verify no manual conflict-marker cleanup accidentally dropped it.
3. Re-run `poetry check` (and `poetry lock --check` if the repo's lock policy requires it) against the resolved `pyproject.toml`.
4. Re-attempt the merge/rebase of `feature/legacy-discovery-init-templates-362` onto `origin/epic/legacy-discovery-and-parity-integration` and confirm `gh pr view 380 --json mergeable` reports `MERGEABLE` (or the merge completes cleanly if performed via merge commit rather than through the PR UI).
5. Re-run this feature's full toolchain loop (format, lint, type-check, test) after the resolution, since `pyproject.toml` changes can affect dependency resolution and script registration.
6. Because this is the second consecutive cycle in which the epic branch advanced with a new sibling feature and reopened this same conflict shape, the resolution/remediation plan should consider re-checking `gh pr view 380 --json mergeable` immediately before merge-commit creation (not just before planning) to reduce the chance of a third recurrence from a further sibling fan-in between plan approval and merge.

## Re-Verification Checklist for the Remediation Plan

1. Apply the fix in "Required Fix" above on a dedicated resolution commit (not part of this capture task).
2. Confirm `git diff --name-only --diff-filter=U` is empty after resolution.
3. Confirm `gh pr view 380 --json mergeable` reports `MERGEABLE`.
4. Re-run `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing` and capture fresh evidence under `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/`.
