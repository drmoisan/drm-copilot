# Atomic Implementation Plan — Orchestration Enforcement Hardening (Issue #253)

- **Issue:** #253
- **Feature folder:** `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253`
- **Work Mode:** full-feature
- **Plan timestamp:** 2026-06-26T15-50
- **Evidence root:** `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/`

## Authoritative inputs

- Research: `docs/research/20260626-orchestration-enforcement-hardening-research.md` (file-change list §4, acceptance criteria §5).
- Spec / Definition of Done: `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/spec.md`.
- User story (AC1–AC7): `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/user-story.md`.

## Scope and sequencing rationale

Gap 6 (audit trail) is OUT of scope (deferred). The three unrelated working-tree changes under
`tests/scripts/claude-hooks/*.Tests.ps1` (pwsh-runner-independence) are NOT in this plan's scope.

Sequencing: Python validator + config first (so the PowerShell Gap-1 subprocess seam has a stable CLI
target), then PowerShell hooks, then full cross-language verification. Per-language toolchain isolation
is preserved by separate phases. PowerShell production-file batches respect the per-batch cap (max 3
production + 3 test files).

Verified pre-conditions (read during planning):
- `scripts/dev_tools/validate_orchestration_artifacts.py` ALREADY exposes a `__main__` CLI with the
  subcommand `orchestrator-state <path> --require-complete` (lines 136–246). Gap 1's "add `__main__` if
  absent" is therefore a verification-only task; no new CLI entry is required. The subprocess seam target
  is `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete`.
- `.claude/hooks/enforce-completion-consistency.ps1` is 301 lines. Adding Gaps 2, 3, and 4 will exceed the
  500-line limit, so a dot-sourced helper script (`enforce-completion-helpers.ps1`) is planned.
- `scripts/dev_tools/validate_orchestrator_state.py` is 506 lines; removing `ISSUE_232`/`ISSUE_232_BRANCH`
  and the branch-name check offsets the small Gap-5 additions and must keep the file under 500 lines.

### Acceptance-criteria map

| AC | Phase/Task |
|---|---|
| AC1 (routing validator wired at SubagentStop) | P3-T1, P3-T2 |
| AC2 (sentinel rejection helpers) | P4-T1, P4-T2 |
| AC3 (Edit-tool read-then-validate) | P4-T3 |
| AC4 (remove `"232"` literals; route-driven pr_gate) | P2-T1, P4-T4, P5-T1, P5-T2 |
| AC5 (route membership + phase completeness) | P2-T2, P2-T3 |
| AC6 (real agent names; byte-identical mirror) | P1-T1 |
| AC7 (all four toolchains pass; no coverage regression) | P0-T2, P0-T3, P6-T1, P6-T2 |

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read repository policy files in the required order and record a Phase 0 policy-read evidence
  artifact at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/other/phase0-instructions-read.2026-06-26T15-50.md`.
  Read, in order: `.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`;
  `.github/instructions/general-unit-test.instructions.md`;
  `.github/instructions/python-code-change.instructions.md`;
  `.github/instructions/python-unit-test.instructions.md`;
  `.github/instructions/powershell-code-change.instructions.md`;
  `.github/instructions/powershell-unit-test.instructions.md`;
  `.github/instructions/github-actions.instructions.md` (config JSON parity is exercised via Pytest, not
  GH Actions, so the GH Actions file is informational). Artifact MUST include `Timestamp:`, `Policy Order:`,
  and the explicit list of files read.
  **Acceptance:** the policy-read artifact exists and lists every file above with `Timestamp:` and
  `Policy Order:` fields populated.

- [x] [P0-T2] Capture the Python baseline toolchain state and write one baseline artifact per command at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/baseline/python-baseline.2026-06-26T15-50.md`.
  Run and record each command's `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`:
  `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`;
  `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`.
  The pytest `Output Summary:` MUST record the numeric baseline line-coverage and branch-coverage headline
  values for `scripts/dev_tools` (overall percent and the per-module percent for
  `validate_orchestrator_state.py`, `_orchestrator_state_routing.py`, and `validate_orchestration_artifacts.py`).
  **Acceptance:** the artifact contains four command blocks, each with all four schema fields, and the
  pytest block records numeric coverage percentages (not placeholders).

- [x] [P0-T3] Capture the PowerShell baseline toolchain state and write one baseline artifact per command at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/baseline/powershell-baseline.2026-06-26T15-50.md`.
  Run and record each command's `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` using the MCP
  toolchain: `mcp__drm-copilot__run_poshqc_format` (check mode) over the three hook files and their tests;
  `mcp__drm-copilot__run_poshqc_analyze` over the same set;
  `mcp__drm-copilot__run_poshqc_test` for
  `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` with coverage enabled.
  The test `Output Summary:` MUST record numeric line and branch coverage headline values for the three hook
  scripts in scope.
  **Acceptance:** the artifact contains one block per command with all four schema fields, and the Pester
  block records numeric coverage percentages for the three hook scripts.

---

### Phase 1 — Routing-Matrix Config (both JSON files in lockstep)

- [x] [P1-T1] In `config/orchestration-routing.json` AND its byte-identical mirror
  `extensions/drm-copilot/resources/config/orchestration-routing.json`, apply the following edits to the
  `large` route only, keeping the two files byte-identical:
  (a) add a top-level boolean field `"requires_pr_gate": true` to the `large` route object;
  (b) in `large.required_agents`, replace `"feature-reviewer"` with `"feature-review"`;
  (c) in `large.required_agents`, replace `"commit-steward"` with `"pr-author"`.
  Do NOT add `requires_pr_gate` to `small` or `remediation` (absent means `false`). Make no other changes.
  After editing, verify byte-identity by reading both files and confirming identical content.
  Run the parity guard to confirm no drift:
  `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`.
  Record the parity run as a QA-gate artifact at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/qa-gates/config-parity.2026-06-26T15-50.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  **Acceptance (AC4 partial, AC6):** `large` route contains `"requires_pr_gate": true`,
  `required_agents` contains `feature-review` and `pr-author` and contains neither `feature-reviewer`
  nor `commit-steward`; both JSON files are byte-identical; the parity test exits 0.

---

### Phase 2 — Python Validator Changes (Gap 4 Python, Gap 5, Gap 1 CLI verification)

- [x] [P2-T1] In `scripts/dev_tools/validate_orchestrator_state.py`, remove the issue-232 hardcoding and
  drive the PR gate from the routing matrix:
  (a) delete the module constants `ISSUE_232 = "232"` (line 98) and
  `ISSUE_232_BRANCH = "feature/harden-orchestrate-skill-232"` (line 99);
  (b) in `_validate_completion_pr_gate`, remove the `if state.get("issue-num") == ISSUE_232:` branch and
  its `head_branch != ISSUE_232_BRANCH` check (lines 229–235);
  (c) change `_validate_completion_pr_gate` so that the `pr_gate` requirement is applied only when the
  checkpoint's route has `requires_pr_gate == true`. Read the route via
  `state.get("route_id", state.get("path_selected"))`, look it up in the routing matrix loaded by
  `load_routing_matrix()` (imported from `_orchestrator_state_routing`), and treat a missing route or a
  missing/false `requires_pr_gate` as "pr_gate not required" (return no `pr_gate` errors);
  (d) remove the unconditional `_validate_completion_pr_gate(state_map)` call from the `require_complete`
  block (line 500) only if it becomes redundant; otherwise keep the call but ensure the function itself is
  route-gated. Preserve the existing `_validate_completion_ci_gate` behavior.
  Confirm the literal `"232"` no longer appears in any condition; remove now-unused imports such as `cast`
  if they become orphaned. Keep the file under 500 lines.
  Add/update Python tests in `tests/scripts/dev_tools/test_validate_orchestrator_state.py`:
  a test asserting `pr_gate` IS required when the checkpoint route resolves to a route with
  `requires_pr_gate == true` (e.g., `large`); a test asserting `pr_gate` is NOT required for a route
  without `requires_pr_gate` (e.g., `small`); a test asserting no `ISSUE_232_BRANCH` head-branch error is
  produced for any issue number. Update or remove any existing #232 branch-name assertions in
  `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`.
  Run the full Python toolchain loop in order and restart on any failure or file change:
  `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`;
  `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`.
  **Acceptance (AC4 partial):** `ISSUE_232` and `ISSUE_232_BRANCH` are absent from
  `validate_orchestrator_state.py`; the literal `"232"` appears in no condition; `pr_gate` enforcement is
  route-driven; the named Pytest cases pass; all four Python stages pass in a single clean loop.

- [x] [P2-T2] In `scripts/dev_tools/_orchestrator_state_routing.py`, add a new pure function
  `validate_route_membership(state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None) -> list[str]`
  that: reads `route_id` (falling back to `path_selected`) from `state`; returns one error string when the
  value is absent, not a string, or empty/whitespace-only; loads the matrix via `load_routing_matrix()`
  when `routing_matrix` is None; returns one error string when the route id is not a key in
  `matrix["routes"]` (message must name the offending route, e.g., the fabricated
  `direct_powershell_engineer_remediation`); returns an empty list otherwise. The function must not call
  `sys.exit` and must not write to disk.
  Add Pytest cases in `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (or a
  new sibling test module that mirrors the source): unknown route rejected (including
  `direct_powershell_engineer_remediation`); missing route id rejected; valid `small`/`large` route accepted.
  Run the full Python toolchain loop in order (black, ruff, pyright, pytest with coverage), restarting on
  any failure or file change.
  **Acceptance (AC5 partial):** `validate_route_membership` exists, rejects unknown and missing routes with
  named errors, accepts valid routes, performs no `sys.exit`/disk write; the named Pytest cases pass; all
  four Python stages pass in a single clean loop.

- [x] [P2-T3] In `scripts/dev_tools/_orchestrator_state_routing.py`, add a new pure function
  `validate_phase_completeness(state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None) -> list[str]`
  that reads `completed_steps` and verifies the mandatory canonical phases for the selected route (for the
  `small` route the mandatory phases are `S3_promotion` and `S4_atomic_planning`); it returns one error
  string per missing mandatory phase and an empty list when all mandatory phases are present or the route is
  unknown (route membership is validated separately). Then in
  `scripts/dev_tools/validate_orchestrator_state.py`:
  (a) add a new keyword-only parameter `strict_route_membership: bool = False` to
  `validate_orchestrator_state_text`;
  (b) call `validate_route_membership(state_map)` UNCONDITIONALLY (before the `if require_complete:` block)
  but append its errors only when `strict_route_membership` is True, preserving backward compatibility for
  checkpoints without `route_id`/`path_selected`;
  (c) inside the existing `if require_complete:` block, append `validate_phase_completeness(state_map)`
  errors.
  Add Pytest cases in `tests/scripts/dev_tools/test_validate_orchestrator_state.py`:
  `validate_orchestrator_state_text(..., strict_route_membership=True)` rejects an unknown route;
  `strict_route_membership=False` (default) does not reject a checkpoint missing `route_id`/`path_selected`;
  phase-completeness pass case under `require_complete=True`; phase-completeness fail case under
  `require_complete=True` (missing `S3_promotion`).
  Run the full Python toolchain loop in order (black, ruff, pyright, pytest with coverage), restarting on
  any failure or file change.
  **Acceptance (AC5):** `validate_phase_completeness` exists and is pure; `validate_orchestrator_state_text`
  exposes `strict_route_membership: bool = False`, calls route-membership unconditionally (strict-gated) and
  phase-completeness under `require_complete`; the named Pytest cases pass; all four Python stages pass in a
  single clean loop.

- [x] [P2-T4] Verify the subprocess CLI target required by Gap 1 already exists and add a regression test.
  Confirm `scripts/dev_tools/validate_orchestration_artifacts.py` exposes a `__main__` entry and the
  subcommand contract `orchestrator-state <path> --require-complete` (verified present at lines 136–246; do
  NOT add a duplicate `__main__`). Add a Pytest case in
  `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` that invokes
  `main(["orchestrator-state", "<fixture-path>", "--require-complete"])` and asserts exit code 1 with errors
  printed for an invalid checkpoint and exit code 0 for a valid checkpoint (in-process call; no real
  subprocess, no temp files — use a repository fixture path or an in-repo sample checkpoint).
  Run the full Python toolchain loop in order (black, ruff, pyright, pytest with coverage), restarting on
  any failure or file change.
  **Acceptance (AC1 prerequisite):** the CLI subcommand contract is confirmed present and exercised by a
  passing in-process Pytest case; all four Python stages pass in a single clean loop.

---

### Phase 3 — PowerShell Gap 1: SubagentStop Routing Validator (1 production + 1 test file)

- [x] [P3-T1] (Regression / fail-before, tagged `[expect-fail]`) Add a Pester `It` to
  `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` that demonstrates the current gap:
  a structurally valid checkpoint that selects a fabricated route is NOT blocked by
  `Invoke-OrchestratorOutputValidation` before the Gap-1 change is applied. Run this single test in
  isolation, confirm it fails (the hook allows when it should block), and record the failing run as a
  fail-before artifact at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/regression-testing/gap1-fail-before.2026-06-26T15-50.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If a deterministic failing run is not
  achievable (for example because the new test cannot run before the seam exists), instead record a
  fail-before exception dossier at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/regression-testing/fail-before-exception.gap1.2026-06-26T15-50.md`
  containing `WhyFailingRunImpossible:` and an absence-of-enforcement proof (cite that
  `validate-orchestrator-output.ps1` lines 193–220 contain no routing-validator call).
  **Acceptance:** a fail-before artifact OR a schema-valid fail-before exception dossier exists under
  `evidence/regression-testing/` documenting the absence of the routing-validator call.

- [x] [P3-T2] In `.claude/hooks/validate-orchestrator-output.ps1`, add a function
  `Invoke-RoutingContractValidation` with an injectable subprocess scriptblock seam (parameter
  `[scriptblock] $Invoker` defaulting to a real call of
  `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <CheckpointPath> --require-complete`).
  The function returns a result object that reports whether the validator emitted errors and the error text.
  Insert a call to `Invoke-RoutingContractValidation` inside `Invoke-OrchestratorOutputValidation` AFTER the
  `human_interaction` check (after line 218) and BEFORE the final `return @{ Ok = $true; Message = $null }`
  (line 220). When the validator returns errors or a non-zero exit, return
  `@{ Ok = $false; Message = "ROUTING_CONTRACT_BLOCKED: <error list>" }`; when clean, fall through to the
  existing allow result. The seam default must produce the real call; tests inject a mock scriptblock so no
  Python process runs.
  Add Pester contexts to `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`:
  (a) subprocess seam returns errors -> result `Ok = $false` and `Message` begins with
  `ROUTING_CONTRACT_BLOCKED:`;
  (b) subprocess seam returns clean -> result `Ok = $true` (existing allow);
  (c) the seam is mockable without invoking Python (injected scriptblock);
  and convert the P3-T1 fail-before test into a passing assertion (the fabricated-route checkpoint is now
  blocked). Confirm all pre-existing tests in this file still pass.
  Run the PowerShell toolchain loop in order, restarting on any failure or file change:
  `mcp__drm-copilot__run_poshqc_format` (the hook file + its test);
  `mcp__drm-copilot__run_poshqc_analyze` (same set);
  `mcp__drm-copilot__run_poshqc_test` for
  `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` with coverage enabled.
  Confirm `validate-orchestrator-output.ps1` remains under 500 lines.
  **Acceptance (AC1):** `Invoke-RoutingContractValidation` exists with an injectable seam; the hook returns
  `ROUTING_CONTRACT_BLOCKED: ...` on routing errors and allows when clean; the three new Pester contexts and
  all pre-existing tests pass; format, analyze, and Pester (coverage-enabled) complete in a single clean loop.

---

### Phase 4 — PowerShell Gaps 2, 3, 4: Completion-Consistency Hook (max 3 production + 3 test files)

> Note on file-size limit: `enforce-completion-consistency.ps1` is 301 lines. The Gap 2/3/4 additions will
> exceed 500 lines, so the helper functions are extracted into a new dot-sourced script
> `.claude/hooks/enforce-completion-helpers.ps1`, following the existing `ConvertFrom-CheckpointJson` seam
> pattern. The production-file batch for this phase is: `enforce-completion-consistency.ps1` and
> `enforce-completion-helpers.ps1` (2 production files). Both stay under 500 lines.

- [x] [P4-T1] (Regression / fail-before, tagged `[expect-fail]`) Add Pester `It` blocks to
  `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` demonstrating the current sentinel
  gaps: a completion-asserting Write payload with `issue-num = "n/a"` (and full `feature-folder`/`ci_gate`
  evidence) is ALLOWED, and `feature-folder = "n/a"` is ALLOWED, before the Gap-2 change. Run these tests in
  isolation, confirm they fail (the hook allows sentinels), and record the failing run at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/regression-testing/gap2-fail-before.2026-06-26T15-50.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If a deterministic failing run is not
  achievable, record a fail-before exception dossier under `evidence/regression-testing/` citing lines
  157–171 (the `-not $issueNum`/`-not $featureFolder` truthiness checks).
  **Acceptance:** a fail-before artifact OR a schema-valid exception dossier exists documenting that
  sentinels currently pass the presence checks.

- [x] [P4-T2] Create the dot-sourced helper script `.claude/hooks/enforce-completion-helpers.ps1` containing
  two advanced functions:
  `Test-IsValidIssueNum -Value <string>` returning `[bool]` — returns `$false` when `Value` is in the
  sentinel set `{n/a, none, tbd}` (case-insensitive), is empty, is whitespace-only, or does not match
  `^\d+$`; returns `$true` only for digits-only strings;
  `Test-IsValidFeatureFolder -Value <string> [-FolderExistsCheck <scriptblock>]` returning `[bool]` —
  returns `$false` for the sentinel set / empty / whitespace; requires the value to start with
  `docs/features/active/` and to contain at least one additional non-empty path segment after that prefix;
  invokes the injectable `FolderExistsCheck` scriptblock (default
  `{ param($p) Test-Path -LiteralPath $p -PathType Container }`) and returns `$false` when it reports the
  folder does not exist. In `.claude/hooks/enforce-completion-consistency.ps1`, dot-source the helper script
  (guarded so dot-sourcing in tests does not re-execute the entrypoint) and replace the
  `if (-not $issueNum)` / `if (-not $featureFolder)` branches in `Get-MissingCompletionEvidence` (lines
  161–171) with calls to the new helpers; the missing-evidence message must name the invalid value
  explicitly (for example `issue-num value 'n/a' is not a valid issue number (must be digits-only)`).
  Add Pester cases to `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`:
  `issue-num` blocked for each of `n/a`, `none`, `tbd`, `"  "`, empty; `issue-num = "123"` allowed;
  `feature-folder = "n/a"` blocked; `feature-folder = "docs/features/active/my-feature-233"` allowed;
  `feature-folder = "docs/features/active/my-feature-233"` with injected `FolderExistsCheck` returning
  `$false` -> blocked; convert the P4-T1 fail-before tests to passing block assertions.
  Run the PowerShell toolchain loop in order (format, analyze, Pester with coverage) over
  `enforce-completion-consistency.ps1`, `enforce-completion-helpers.ps1`, and the test file; restart on any
  failure or file change. Confirm both production files remain under 500 lines.
  **Acceptance (AC2):** the two helpers exist with the specified contracts and the injectable
  `FolderExistsCheck` seam; sentinel `issue-num`/`feature-folder` values are blocked with named errors;
  digit-only issue numbers and valid `docs/features/active/...` folders are allowed; the named Pester cases
  pass; format, analyze, and coverage-enabled Pester complete in a single clean loop.

- [x] [P4-T3] In `.claude/hooks/enforce-completion-consistency.ps1`, close the Edit-tool bypass via
  read-then-validate. Add an injectable `CheckpointReader` scriptblock seam (default
  `Get-CheckpointFileContent` reading the on-disk checkpoint at the normalized checkpoint path). In
  `Invoke-CompletionConsistencyDecision`, when `$toolInput.content` is absent but `$toolInput.old_string`
  is present and the path is the checkpoint path:
  (1) read the current on-disk checkpoint via the seam;
  (2) apply the `old_string`->`new_string` replacement in memory (`[string]::Replace` / `-replace` with
  literal handling);
  (3) parse the patched string and run the existing `Test-CompletionAsserted` /
  `Get-MissingCompletionEvidence` logic;
  (4) block when the patched result asserts completion without evidence; allow otherwise;
  (5) allow (defer) when the on-disk file does not exist or `old_string` is not found in the on-disk content.
  Preserve the existing allow path for Edit calls on non-checkpoint paths. Add an `It` block first that fails
  before the change (an Edit producing a completion assertion without evidence is currently allowed) and
  record it at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/regression-testing/gap3-fail-before.2026-06-26T15-50.md`
  (or an exception dossier citing lines 251–254). Add Pester contexts:
  Edit patch that results in a completion assertion without evidence -> blocked (inject on-disk content via
  the `CheckpointReader` seam);
  Edit patch that does not result in a completion assertion -> allowed;
  on-disk file missing -> allowed;
  `old_string` not found in on-disk content -> allowed; Edit on a non-checkpoint path -> allowed.
  Run the PowerShell toolchain loop in order (format, analyze, Pester with coverage) over the hook, the
  helper script, and the test file; restart on any failure or file change. Confirm the production files
  remain under 500 lines.
  **Acceptance (AC3):** completion-asserting Edit patches are validated by reading the on-disk checkpoint
  and applying the patch in memory via the injectable `CheckpointReader` seam; allow on missing file or
  non-matching patch; a fail-before artifact or exception dossier exists; the named Pester contexts pass;
  format, analyze, and coverage-enabled Pester complete in a single clean loop.

- [x] [P4-T4] In `.claude/hooks/enforce-completion-consistency.ps1`, replace the issue-232 hardcoding with a
  routing-matrix lookup. Add an injectable routing-matrix reader seam (scriptblock default reading and
  parsing `config/orchestration-routing.json`). Replace the `if ($issueNum -eq '232')` block in
  `Get-MissingCompletionEvidence` (lines 191–211) with: resolve `route_id` from the payload (falling back to
  `path_selected`); look the route up in the routing matrix; apply the `pr_gate` requirement and the
  `ci_gate.head_sha`/`pr_gate.head_sha` match check only when the route's `requires_pr_gate == true`.
  Remove the `issue-num == '232'` message-enrichment branch in `Invoke-CompletionConsistencyDecision`
  (lines 274–276); generalize the block message so it does not reference issue 232. Confirm the literal
  `"232"` appears in no condition in the file.
  Add Pester cases to `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`:
  a checkpoint whose route resolves to a `requires_pr_gate == true` route (inject a matrix where `large` has
  `requires_pr_gate: true`) requires `pr_gate` and is blocked when `pr_gate` is absent;
  a checkpoint on the `small` route (no `requires_pr_gate`) does NOT require `pr_gate`; a non-232 route with
  `requires_pr_gate: true` enforces the gate (proving route-driven, not issue-driven, behavior).
  Run the PowerShell toolchain loop in order (format, analyze, Pester with coverage) over the hook, the
  helper script (if touched), and the test file; restart on any failure or file change. Confirm the file
  remains under 500 lines.
  **Acceptance (AC4 partial):** the literal `"232"` appears in no condition in
  `enforce-completion-consistency.ps1`; `pr_gate` enforcement is driven by the route's `requires_pr_gate`
  via an injectable matrix-reader seam; the named Pester cases pass; format, analyze, and coverage-enabled
  Pester complete in a single clean loop.

---

### Phase 5 — PowerShell Gap 4: Pre-implementation Gate De-hardcoding (1 production + 1 test file)

- [x] [P5-T1] In `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, remove the issue-232
  hardcoding:
  (a) delete the `$script:Issue232FeatureFolder` variable (line 9);
  (b) remove the `if ($issueNum -eq '232' -and $featureFolder -ne $script:Issue232FeatureFolder)` check in
  `Test-OrchestrationReady` (lines 116–118) — the existing
  `$featureFolder.StartsWith('docs/features/active/')` check covers the general case;
  (c) remove the `if ($issueNum -eq '232')` issue-232-specific block message in
  `Invoke-OrchestrationPreimplementationGateDecision` (lines 186–190) and fall through to the generalized
  block message that names the missing checkpoint fields rather than the issue number.
  Confirm the literal `"232"` appears in no condition in the file.
  **Acceptance (AC4 partial):** `$script:Issue232FeatureFolder` is removed; the literal `"232"` appears in
  no condition; the generalized block message names missing checkpoint fields.

- [x] [P5-T2] Update `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` to
  replace hardcoded-#232-path assertions with generalized assertions: a checkpoint with a valid
  `docs/features/active/<name>` feature folder, route metadata, and `lifecycle_ready` is allowed regardless
  of issue number; a checkpoint missing required fields is blocked with the generalized message (no `#232`
  reference). Confirm all pre-existing tests in the file still pass.
  Run the PowerShell toolchain loop in order (format, analyze, Pester with coverage) over
  `enforce-orchestration-preimplementation-gate.ps1` and its test file; restart on any failure or file change.
  Confirm the production file remains under 500 lines.
  **Acceptance (AC4 partial):** the generalized assertions pass, no test references issue 232, all
  pre-existing tests pass; format, analyze, and coverage-enabled Pester complete in a single clean loop.

---

### Phase 6 — Full Cross-Language QA Loop and Verification

- [x] [P6-T1] Run the complete Python toolchain loop in order and persist one final-QC artifact per command
  at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/qa-gates/python-final-qc.2026-06-26T15-50.md`.
  Commands (restart from the first stage on any failure or file change until a single clean pass):
  `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`;
  `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`.
  Each artifact block MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The pytest
  block MUST record post-change numeric line and branch coverage for `scripts/dev_tools` and the per-module
  percentages for `validate_orchestrator_state.py`, `_orchestrator_state_routing.py`, and
  `validate_orchestration_artifacts.py`. This task is unconditional; `SKIPPED` is not a valid outcome.
  **Acceptance (AC7 Python):** all four stages pass in a single clean loop; coverage is >= 85% line and
  >= 75% branch for changed modules with no regression versus the P0-T2 baseline; numeric values are
  recorded in the artifact.

- [x] [P6-T2] Run the complete PowerShell toolchain loop in order and persist one final-QC artifact per
  command at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/qa-gates/powershell-final-qc.2026-06-26T15-50.md`.
  Commands (restart from format on any failure or file change until a single clean pass):
  `mcp__drm-copilot__run_poshqc_format` over the four hook/helper production files
  (`validate-orchestrator-output.ps1`, `enforce-completion-consistency.ps1`,
  `enforce-completion-helpers.ps1`, `enforce-orchestration-preimplementation-gate.ps1`) and the three test
  files; `mcp__drm-copilot__run_poshqc_analyze` over the same set;
  `mcp__drm-copilot__run_poshqc_test` over
  `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` with coverage enabled.
  Each artifact block MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; the Pester
  block MUST record post-change numeric line and branch coverage for the four hook/helper scripts. This task
  is unconditional; `SKIPPED` is not a valid outcome.
  **Acceptance (AC7 PowerShell):** format, analyze, and coverage-enabled Pester pass in a single clean loop;
  coverage is >= 85% line and >= 75% branch for the changed scripts with no regression versus the P0-T3
  baseline; numeric values are recorded in the artifact.

- [x] [P6-T3] Run the cross-cutting verification gates and persist a verification artifact at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/qa-gates/cross-language-verification.2026-06-26T15-50.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` per check:
  (a) `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` exits 0
  (byte-identical mirror);
  (b) a grep/scan confirming the literal `"232"` appears in no condition in
  `.claude/hooks/enforce-completion-consistency.ps1` or
  `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, and that `ISSUE_232`/`ISSUE_232_BRANCH`
  are absent from `scripts/dev_tools/validate_orchestrator_state.py`;
  (c) a scan confirming `config/orchestration-routing.json` `large.required_agents` contains
  `feature-review` and `pr-author` and neither `feature-reviewer` nor `commit-steward`, and that
  `large.requires_pr_gate == true`;
  (d) confirm all four production hook/helper files and `validate_orchestrator_state.py` are each under 500
  lines.
  **Acceptance (AC4, AC6, AC7):** all four checks pass; the artifact records each command, exit code, and a
  result summary.

- [x] [P6-T4] Update the feature `issue.md` / Definition-of-Done checkboxes (AC1–AC7) to reflect verified
  status and mirror the update at
  `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/issue-updates/issue-253.2026-06-26T15-50.md`
  with `Timestamp:`, the exact text, and `PostedAs:`. Map each AC to the evidence artifact(s) that prove it
  (AC1 -> P3 evidence + Pester; AC2 -> P4-T2; AC3 -> P4-T3; AC4 -> P2-T1/P4-T4/P5/P6-T3; AC5 -> P2-T2/P2-T3;
  AC6 -> P1-T1/P6-T3; AC7 -> P6-T1/P6-T2).
  **Acceptance:** the DoD reflects only verified ACs, each mapped to an evidence artifact path; the
  issue-update mirror exists with the required fields.
