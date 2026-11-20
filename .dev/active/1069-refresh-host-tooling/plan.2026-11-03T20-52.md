# Refresh host tooling — Plan

- Issue: #1069
- Work Mode: full-feature
- Status: Pending delegated preflight
- Requirements: `issue.md`, `spec.md`, `user-story.md`; research: `research/2026-11-04T01-54-refresh-host-tooling-research.md`.
- Feature folder: `docs/features/active/2026-11-03-refresh-host-tooling-1069`. Evidence paths below are relative to this folder and resolve beneath `evidence/<kind>/` only. Each command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; coverage artifacts record numeric totals and changed-file results. Substitute write-time UTC for `<timestamp>`; consume the lexicographically greatest matching artifact.
- `SCRATCH` resolves to `<session scratchpad>/issue-1069/`; scratch filenames start with `issue-1069-`. Tracked evidence contains no host paths.
- Apply `.agents/skills/execution-environment/SKILL.md` for tool routes, launchers, enforcement, CI shape, evidence, and isolation conventions. Compare against the merge base of `origin/main` and `HEAD`.
- Do not upgrade the host or run bootstrap apply mode against it. Preserve package engines, Python compatibility entries, local mounts/features, Codespaces resources, and release-publishing workflows.

## Design

Keep `scripts/host-tools.manifest.json` as the Windows authority. Extend existing bootstrap helpers with optional minimum-version parameters. Missing tools retain installation behavior; installed managed tools are checked through existing version/native seams, stale tools use apply-only upgrades, unreadable versions fail explicitly, and equal/newer versions are preserved. Unmanaged/no-minimum callers retain current behavior. Poetry uses a minimum-constrained pip upgrade when needed.

Both containers provide Node.js 26.13.0/npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, actionlint 1.7.12, and Python at least 3.13.17 within 3.13. Inspect the real minor image before selecting a Python assertion/install; never invent a patch tag. A small pure shell predicate supplies shared verifier version decisions and deterministic Bats coverage without a configuration framework.

### Existing test dispositions

- Update `tests/scripts/host-tools.manifest.Tests.ps1`: `AC02-MINIMUM-VERSIONS-PINNED` and consumer fixtures assert new minima.
- Extend `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` only where optional-parameter signature parity or minimum-constrained fallback calls change assertions. Existing no-minimum helper tests, streamed output, PATH handling, and native failures remain unchanged.
- Update `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` committed-manifest previews/Poetry contexts for minimum propagation. Minimal fixtures without `minimumVersions` remain supported.
- Preserve and run `tests/scripts/dev-tools/HostTooling.Tests.ps1`, `HostVerification.Tests.ps1`, `HostVerification.Invoke.Tests.ps1`, `HostBootstrapWorkspace.Tests.ps1`, `bootstrap-host.Tests.ps1`, and `verify-host.Tests.ps1`: their parser, verification, workspace, and entry-point contracts remain unchanged.
- Preserve `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` compatibility/coverage conditions and `test_clean_devcontainer.py` cleanup behavior.
- Preserve `tests/shell/test_shell_qc_commands.bats`, `test_shell_qc_discovery.bats`, and `test_coverage_demo.bats`; formatter-only edits do not change behavior.

## Implementation Plan

### Phase 0 — Policies, feasibility, and baseline

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, applicable consolidated language/CI skills, and the execution-environment brief in required order. Record policy reads, host inventory, scope, and preserved values from both devcontainer JSON files, `pyproject.toml`, and package engines in `evidence/baseline/policy-and-scope.<timestamp>.md`.
  - Acceptance: the artifact maps AC1–AC7, identifies files read and installed versions, and maps absent legacy policy aliases to existing consolidated skills.

- [x] [P0-T2] Inspect the actual Python runtime in `mcr.microsoft.com/devcontainers/python:3.13-bookworm` and verify selected Linux package versions/architecture before Dockerfile edits. Record a real supported Python source in `evidence/baseline/container-feasibility.<timestamp>.md`.
  - Acceptance: the selected source provides Python at least 3.13.17 within 3.13. If the minor image lags, verify an existing official Python 3.13.17 Bookworm image for a Python-install stage copied into the devcontainer base; if no supported real source exists, stop before implementation with the concrete dependency. No knowingly failing assertion or invented image tag is accepted.

- [x] [P0-T3] Capture ordered PowerShell baselines for `scripts/dev-tools/HostBootstrap.psm1` and all host suites listed above, including numeric repository-population and HostBootstrap line coverage. Write separate format/analyzer/coverage-test artifacts under `evidence/baseline/host-*.<timestamp>.md`.
  - Acceptance: each command has a real result; coverage and measured population are numeric and explicit; existing failures are identified rather than described as passing.

- [x] [P0-T4] Capture ordered Python, root/extension Node, and shell baselines with one artifact per command under `evidence/baseline/`, including numeric Python/Jest/shell coverage and explicit `.devcontainer/post-create.sh`/`verify-container.sh` format/lint checks. Instrument the existing container-script runtime scenarios with kcov explicitly including these entrypoints, because ordinary shell QC coverage omits `.devcontainer`; record separate numeric per-file baseline coverage for each entrypoint that will change, including formatter-only changes.
  - Acceptance: real exit codes, coverage populations, per-entrypoint covered/total executable lines and percentages, and formatter delta are recorded. Existing formatter-only production scope is bounded to `scripts/bash/shell-qc.sh`, `shell_qc_lib.sh`, `kcov_trace_env.sh`, `coverage_lib.sh`, and `coverage_demo.sh`; reconcile unexpected additional files before edits. Baseline collection uses isolated disposable container setup and leaves the host environment unchanged.

### Phase 1 — Manifest-driven bootstrap

- [x] [P1-T1] Update `scripts/host-tools.manifest.json` and pinned expectations/consumer fixtures in `tests/scripts/host-tools.manifest.Tests.ps1` to Python 3.13.17, Node 26.13.0, PowerShell 7.6.9, and Poetry 2.3.2.
  - Acceptance: shape, IDs, command classifications, and module versions remain unchanged; pinned/consumer tests pass, satisfying AC1.

- [x] [P1-T2] Extend `Install-WithWinget` in `scripts/dev-tools/HostBootstrap.psm1` with an optional minimum and managed version decisions through existing `Get-CommandVersion`/native wrappers. Add `tests/scripts/dev-tools/HostBootstrap.Versions.Tests.ps1` for missing/stale/equal/newer/unreadable versions, dry run, upgrade argv, and native failure.
  - Acceptance: stale managed tools upgrade only in apply mode; unreadable versions fail; compliant versions invoke no installer; unmanaged/no-minimum messages and argv remain unchanged. Tests mock new seams and create no files.

- [x] [P1-T3] Extend `Install-PoetryWithPip` and the Poetry fallback in `scripts/dev-tools/HostBootstrap.psm1` with optional minimum handling and constrained pip upgrades. Extend `HostBootstrap.Versions.Tests.ps1` and affected fallback mocks in `HostBootstrap.Tests.ps1` with exact signature parity.
  - Acceptance: tests cover missing/below/equal/above/unreadable Poetry, dry run, absent Python, pip failure, and forwarded fallback minimum. Existing no-minimum streamed-output/PATH behavior is preserved.

- [x] [P1-T4] Thread optional manifest minima through `Invoke-BootstrapHost` in `scripts/dev-tools/HostBootstrap.psm1`, including Poetry after PATH refresh. Update `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` committed-manifest/Poetry contexts and minimum-propagation cases.
  - Acceptance: package names receive their declared minima; fixtures without minima remain StrictMode-safe; dry run mutates no installer/registry/clone/directory state; final verification remains intact. `bootstrap-host.ps1` remains thin.

- [x] [P1-T5] Verify the complete host suite inventory against `HostBootstrap.psm1`, `HostTooling.psm1`, and `HostVerification.psm1`; record targeted tests/new-line coverage in `evidence/regression-testing/host-behavior.<timestamp>.md`.
  - Acceptance: all named host suites pass without ambient executable calls; new bootstrap behavior reaches at least 90% line coverage and changed-line coverage does not regress. Correct phase-owned defects before advancing.

### Phase 2 — Both containers and executable verification

- [x] [P2-T1] Create pure `container_tool_version_supported` in `scripts/bash/container_versions.sh` and `tests/shell/test_container_versions.bats` for Python minimum-within-minor and exact pinned tool versions.
  - Acceptance: tests cover all tools, exact/stale versions, newer Python patch, wrong minor, malformed/empty values, and unknown tools without network, ambient commands, or temporary files; new helper coverage reaches at least 90%.

- [x] [P2-T2] Update `.devcontainer/codespaces/Dockerfile` using P0-T2's verified Python source and real NodeSource/Microsoft package versions; pin the selected Poetry, shfmt, ShellCheck, PowerShell, and development Node baseline.
  - Acceptance: AC4 versions are installable on the tested architecture; kcov, unrelated CLI pins, non-root user, and Codespaces JSON resources/features remain intact. Package/version assertions fail explicitly for stale installations.

- [x] [P2-T3] Update `.devcontainer/local/Dockerfile` to the same supported baseline and existing Codespaces kcov/actionlint/module installation strategy; correct its repository work directory and provide shared-verifier commands.
  - Acceptance: AC4 tooling matches Codespaces; local JSON mounts/Docker features remain preserved. Retain unrelated CLI pins, adding matching existing Claude/cswap installs only where the local image lacks required commands.

- [x] [P2-T4] Update `.devcontainer/verify-container.sh` to resolve/source `scripts/bash/container_versions.sh` relative to its own repository location and use the predicate for Python, Node, npm, Poetry, PowerShell, shfmt, ShellCheck, and actionlint. Correct stale Codespaces paths; change `.devcontainer/post-create.sh` only for necessary normalization/baseline setup consistency.
  - Acceptance: stale required versions cause failure and execution works from another directory; existing OS/venv/tool-presence/setup behavior is retained. Tests exercise pure version decisions and actual image verification exercises wiring. Changed `.devcontainer/verify-container.sh` and `.devcontainer/post-create.sh` remain in direct baseline/final coverage measurement; pure-helper coverage is not a substitute for entrypoint coverage.

- [x] [P2-T5] [expect-fail] Add `tests/scripts/dev_tools/test_host_environment_contracts.py` for manifest/Docker/development-CI/helper agreement, valid devcontainer references, and preserved compatibility/platform settings using committed-file reads and pure in-memory parsing.
  - Acceptance: tests detect inconsistent pins, preserve consumer engines and Python 3.11/3.12 entries, and protect both configs' platform settings without processes or temporary files. Existing quality-workflow and cleanup suites remain passing unchanged. Authoring and negative detection are verified here; the live CI parity mismatch is expected until P3-T1 updates the existing pins. Keep P2-T5 unchecked until that live agreement passes after P3-T1.

### Phase 3 — Development CI, documentation, and formatting

- [x] [P3-T1] Update development Node pins in `.github/workflows/_root-typescript-tests.yml`, `_drm-copilot-extension-tests.yml`, and `_npm-audit-gate.yml` to 26.13.0; pin Poetry 2.3.2 in `_quality-checks.yml`, `_build-check.yml`, `_security-scan.yml`; synchronize shfmt 3.14.1/ShellCheck 0.11.0 installation in `_shell-coverage.yml`.
  - Acceptance: new environment contracts, existing workflow contracts, and actionlint pass; job identities, Python compatibility/coverage conditions, and publishing workflows remain unchanged.

- [x] [P3-T2] Update developer guidance in `README.md`, `.devcontainer/README.md`, `.devcontainer/CONFIG-GUIDE.md`, `.devcontainer/CODESPACES-SETUP.md`, `.devcontainer/RECREATE-CODESPACE.md`, `.devcontainer/QUICKSTART.md`, and `.devcontainer/TROUBLESHOOTING.md` where affected by the baseline/config paths.
  - Acceptance: current setup/verification examples satisfy AC6 and distinguish development tools from preserved consumer/runtime compatibility; historical feature documents remain untouched.

- [x] [P3-T3] Reconcile changed environment facts in the six `execution-environment/SKILL.md` copies under `.agents/skills/`, `.claude/skills/`, `.github/skills/`, and their corresponding Codex/Claude/Copilot customization resource trees under `extensions/drm-copilot/resources/`.
  - Acceptance: all six remain byte-identical and describe the selected environment accurately; resource/generator contracts pass. Policy thresholds and routing rules are unchanged.

- [x] [P3-T4] Apply necessary shfmt 3.14.1 normalization to P0-T4's bounded existing shell inventory, new `scripts/bash/container_versions.sh`, its Bats tests, and both `.devcontainer` scripts. Record exact formatter-only files in `evidence/regression-testing/formatter-delta.<timestamp>.md`.
  - Acceptance: a second formatting pass makes no changes, shellcheck passes, and existing shell QC tests show unchanged behavior outside the explicit verifier changes.

### Phase 4 — Ordered QA, coverage, isolation, and image builds

- [x] [P4-T1] Run final ordered PowerShell QA for the changed host module/test inventory, including applicable architecture/contracts/integration stages. Write one format/analyzer/coverage-test artifact per command under `evidence/qa-gates/host-*.<timestamp>.md`.
  - Acceptance: a complete pass has no formatting changes, analyzer errors, or test failures; numeric repository-population/HostBootstrap coverage satisfies governing floors and changed lines do not regress against P0-T3. Restart from formatting after any fix.

- [x] [P4-T2] Run final ordered Python QA and coverage-enabled tests including `test_host_environment_contracts.py`, existing quality-workflow/cleanup/resource contracts, and the Codex generator check; write separate command artifacts under `evidence/qa-gates/python-*.<timestamp>.md`.
  - Acceptance: format/lint/type/applicable architecture/contracts/integration/test stages pass in a clean loop; numeric coverage satisfies governing line/branch floors. Python runtime compatibility remains unchanged.

- [x] [P4-T3] Run final ordered root and `extensions/drm-copilot` Node QA under Node 26.13.0/npm 11.20.0, including existing architecture/contracts/integration checks and coverage-enabled Jest suites; write separate artifacts under `evidence/qa-gates/node-*.<timestamp>.md`.
  - Acceptance: both packages pass without unapproved dependencies; numeric line/branch coverage remains compliant and the selected runtime is exercised directly.

- [x] [P4-T4] Run final shell format/lint/coverage-enabled Bats checks including the new helper; explicitly check both `.devcontainer` scripts and actionlint the modified workflows. Report numeric per-file covered/total lines and percentages for the shell-QC population, and inventory changed container entrypoints whose additional explicit measurements are required in P4-T6/P4-T7. Write one artifact per command under `evidence/qa-gates/shell-*.<timestamp>.md`; P4-T8 owns the final combined report after those runtime measurements exist.
  - Acceptance: one clean pass has no formatter delta, lint errors, or failed tests; measured shell/helper coverage meets governing line floors and changed-line no-regression. The artifact identifies every changed shell production file and its measurement owner without excluding container entrypoints or treating them as covered by helper tests. Final whole-population compliance remains the explicit P4-T8 acceptance, rather than a claim made before the container runs.

- [x] [P4-T5] Run isolation checks for the changed test inventory: three recorded seeded Pester file orders, fresh single-process `tests/scripts` Pester, concurrent Pester shards, reversed changed Python module order, concurrent Pytest, and a recorded seeded shuffled extension Jest suite. Store each under `evidence/regression-testing/isolation-*.<timestamp>.md`.
  - Acceptance: all runs pass and record seeds/file orders or module populations. Fix demonstrated state leakage on both contributing sides, rerun affected ordered QA, and repeat isolation before passing.

- [x] [P4-T6] Build `.devcontainer/local/devcontainer.json` including features, then execute actual version checks and `.devcontainer/verify-container.sh` in that image. Use a repository mount and isolated Linux `.venv` in a disposable runtime so the Windows workspace environment stays unchanged. Run the existing setup/verification scenarios under kcov with explicit inclusion of `.devcontainer/verify-container.sh` and `.devcontainer/post-create.sh` when changed, retaining numeric per-file reports for P4-T4/P4-T8. Record build/runtime and instrumented-scenario results separately under `evidence/qa-gates/local-container-*.<timestamp>.md`.
  - Acceptance: actual build and shared verification succeed with all AC4 versions; local mounts/features/work directory remain valid. The actual changed entrypoints are measured, including formatter-only changes, and scenario coverage reaches governing line floors without regressing changed lines against P0-T4. Exercise needed existing success/error/setup paths in the isolated runtime; no new generic harness or production exclusion is introduced. Concrete external failures leave AC4 unchecked until resolved.

- [x] [P4-T7] Build `.devcontainer/codespaces/devcontainer.json` including features and perform the same isolated actual version/shared-verifier checks with Codespaces environment selection. Instrument existing setup/verification scenarios with kcov explicitly including each changed `.devcontainer/verify-container.sh` and `.devcontainer/post-create.sh` entrypoint, and retain numeric per-file reports for the combined coverage comparison. Record build/runtime and instrumented-scenario results separately under `evidence/qa-gates/codespaces-container-*.<timestamp>.md`.
  - Acceptance: actual build/verification pass with AC4 versions and correct Codespaces paths; resources/features match P0-T1. Every changed entrypoint is measured with covered/total lines and percentages, governing line floors, and changed-line no-regression checked against P0-T4. Neither declarations, pure-helper tests, uninstrumented runs, nor local-image success substitute for this build and measurement.

- [x] [P4-T8] Compare baseline/final coverage and preserved invariants in `evidence/qa-gates/coverage-and-invariants.<timestamp>.md` for `HostBootstrap.psm1`, `container_versions.sh`, every changed existing shell production file including formatter-only files, changed `.devcontainer/verify-container.sh`/`.devcontainer/post-create.sh`, and both devcontainer configs. Combine the explicit container-entrypoint measurements with shell-QC reports and retain per-file evidence.
  - Acceptance: numeric baseline/post/new-code metrics, per-file covered/total lines and percentages, governing line floors, changed-line no-regression, and preserved compatibility/platform values are verified. No changed shell production entrypoint is omitted or represented only by helper coverage; no mandatory metric remains unknown and all changed code/tests/scripts satisfy the file-size gate.

### Phase 5 — Acceptance and self-review

- [x] [P5-T1] Verify AC1–AC7 from `issue.md`/`user-story.md` against actual test/build evidence; update delivered checkboxes and applicable `spec.md` DoD rows per acceptance-criteria-tracking. Write `evidence/qa-gates/p14-acceptance-criteria-checkoff.<timestamp>.md`.
  - Acceptance: each delivered AC has specific passing evidence, source checkboxes agree, and totals/delivered/remaining are reported. Missing evidence leaves the criterion open and prevents a completion claim.

- [x] [P5-T2] Walk all checklist items in `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the entire merge-base diff; write `evidence/qa-gates/self-review.<timestamp>.md`.
  - Acceptance: each item has PASS, FAIL, or reasoned N/A; fix every FAIL and repeat affected QA before rewriting. Return execution/QA summaries, evidence paths, numeric coverage deltas, and AC status to the orchestrator for commit, independent review, branch-head workflow validation, and PR/CI lifecycle.

## Pre-Mortem

- Review checklists: P5-T2 checks every canonical audit-template item against the complete diff before independent review; completed scaffolds are not verification.
- Coverage: P0-T3/P0-T4 and P4-T1–P4-T4 capture baseline/final numeric populations; P4-T6/P4-T7 explicitly instrument changed container entrypoints excluded from ordinary shell-QC discovery. P4-T8 combines/reports every changed shell production file, per-file floors, and changed-line deltas; pure-helper coverage never substitutes for entrypoint measurement. No production exclusion is added.
- Mirror parity: P3-T3 maintains all six execution-environment briefs when stated facts change; P4-T2 checks resource/generator contracts. Job identities and compatibility entries remain intact.
- File size: keep additions to `HostBootstrap.psm1` cohesive and verify changed files in P4-T8; no file exceeds the hard limit and legacy baselines do not grow.
- Test isolation: P4-T5 records seeded shuffled Jest, reversed changed Python modules, and shuffled touched Pester files with three recorded seeds, plus serial/concurrent runs; all new native seams are mocked before use.
- CI-only behavior: P0-T2 verifies real Linux packages/Python runtime before pins; P4-T6/P4-T7 build both configs with features. The orchestrator validates development workflows on the branch head; publishing workflows remain unchanged.
- Evidence: every baseline/final command writes its own canonical artifact with real exit code and write-time UTC; P5-T1 leaves criteria open for missing results and never substitutes declarations for image builds.

## Test Plan

- Host: existing host Pester suites plus `HostBootstrap.Versions.Tests.ps1` prove boundaries, errors, dry run, optional manifests, and legacy callers.
- Containers: `test_container_versions.bats` proves pure accepted/rejected versions; actual builds test installation/shared verifier wiring.
- Contracts: `test_host_environment_contracts.py` plus existing workflow/resource tests guard pins, platform settings, and compatibility.
- Coverage: baseline in `evidence/baseline/`, final/comparison in `evidence/qa-gates/`, isolation in `evidence/regression-testing/`.

## Handoff

The orchestrator delegates whole-plan preflight, permits trivial in-place corrections, and returns substantive defects to this exact plan at most once. Execution requires the independent executor's exact all-clear signal and successful canonical plan validation. No host upgrade, publishing, or completion without remaining orchestration gates is authorized.
