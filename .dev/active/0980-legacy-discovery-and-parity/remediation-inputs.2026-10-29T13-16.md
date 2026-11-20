# Remediation Inputs — feature review 2026-10-29T13-16 (issue #980)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Timestamp: 2026-10-29T13-16
Branch: `feature/legacy-discovery-and-parity-980`, head `c88235db0dacf1c0da1e540bec6bf7de559a7120`
Base for diffs: `52587a0eeaa04a0519801452235608a72b5eba5c` (merge base with `origin/main`)
Source artifacts:
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/policy-audit.2026-10-29T13-16.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-29T13-16.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/feature-audit.2026-10-29T13-16.md`

The mode line covers the three autonomous findings (R1 to R3). Each of them can be fixed within files already in the branch diff plus their tests, mirrors and evidence. R4 needs a user decision before any plan can address it.

## Blocking findings

### R1 — TypeScript coverage artifact absent

Remediability: autonomous
Remediability-Evidence: The fix is to run the existing coverage command on the branch head and keep its output at the canonical path; no design choice or outside party is involved.

- Files: `coverage/lcov.info` (absent); `extensions/drm-copilot/coverage/lcov.info` (dated 2026-10-23T13:49Z, before Phase 12); `extensions/drm-copilot/jest.config.cjs`; `extensions/drm-copilot/jest.discovery-coverage.json`.
- Problem: The P14-T7 runs wrote coverage only to unretained SCRATCH directories. 10 changed executable production files have no per-file threshold: `extensions/drm-copilot/src/lib/codex-native-converter/{classifier-claude,classifier,inventory,mapping,pipeline-render,rewrites-rules,rewrites}.ts`, `extensions/drm-copilot/src/lib/validate/{codex-topology-resolver,orchestrator-state-codex-model-routing}.ts`, `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
- Expected behavior: canonical `lcov.info` exists for the remediated head. A per-file summary is retained under `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/`. Every one of the 47 changed TypeScript production files is at or above 85% lines and 75% branches, with no regression on changed lines. Executable files without per-file thresholds should either get threshold entries or be shown to meet the floors in the retained summary.
- Verification: `npm run test:unit:coverage` (repository root) and `npm run test:unit:coverage` in `extensions/drm-copilot`; parse both `lcov.info` files per file.

### R2 — Evidence-location validator exits nonzero

Remediability: autonomous
Remediability-Evidence: The two reported files are local, gitignored residue from P7-T3 in this worktree; deleting them is a local action with no outside dependency.

- Files: `artifacts/coverage/issue-980-p7t3-coverage.json`, `artifacts/coverage/issue-980-p7t3-devtools-coverage.json` (untracked, not in the branch diff).
- Expected behavior: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0. Move any content still needed to `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/` first.
- Verification: the validator command above.

### R3 — Capability probe attests trusted attribution from its own synthetic environment

Remediability: autonomous
Remediability-Evidence: The defect and its fix are confined to the probe module, its host entry points, their bundled mirrors and Pester tests, all of which are already in the branch diff.

- Files: `.claude/lib/discovery-validation/DiscoveryCapability.psm1` lines 82-101 and 244-250, and its mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/DiscoveryCapability.psm1` and `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1`; the three probe hooks (`.claude/hooks/discovery-capability-probe.ps1`, `.codex/hooks/discovery-capability-probe.ps1`, `.github/hooks/discovery-capability-probe.ps1`) and their mirrors; `scripts/dev-tools/Test-DiscoveryHostCapability.ps1`; tests under `tests/scripts/claude-lib/discovery-validation/`.
- Problem: `trusted_attribution` and `forbidden_tools_denied` are derived from the sentinel decision evaluated over `Get-DiscoverySentinelEnvironment`, a table the probe itself constructs. The control is true on any host where the module logic is intact, including a host that never places `DRM_DISCOVERY_*` in its hook processes.
- Expected behavior: `trusted_attribution` is true only when the host itself supplies attribution. Examples are the probing process's own host-supplied `DRM_DISCOVERY_HOST` and `DRM_DISCOVERY_SESSION_ID`, or a sentinel envelope delivered through the registered hook rather than evaluated in-process. A probe run in a process without host-supplied identity values returns `status: unsupported` with a `DISCOVERY_ENFORCEMENT_UNAVAILABLE` finding naming `trusted_attribution`.
- Verification: new Pester case for the missing-identity process; PoshQC format, analyze and full Pester; mirror parity of every touched file; logical line count at or below 500 for each touched file.

### R4 — No production supplier of the trusted agent identity

Remediability: human_decision_required
Remediability-Evidence: Choosing how an unmodified Claude Code, Codex or Copilot host conveys the specialist identity to hook and MCP processes is an architectural choice; the user must select the mechanism before a plan can implement it.

- Files: `.claude/lib/discovery-validation/DiscoveryPayload.psm1:200-280`, `DiscoveryAuthorization.psm1:385-389`, `DiscoveryStart.psm1:285-293`, `DiscoveryStop.psm1:280`; `extensions/drm-copilot/src/discovery-authority-provider.ts:56-65, 110-130`; `extensions/drm-copilot/src/mcp-discovery-authorization-gate.ts:132-135`; `extensions/drm-copilot/src/repo-automation-service-discovery-identity.ts:56-61`; `extensions/drm-copilot/src/discovery-invocation.ts:171`; `docs/engineering/legacy-discovery-and-parity/enforcement.md`; `handoff.md`; `completion-report.md`.
- Problem: Every native control reads the host, session and agent identity only from `DRM_DISCOVERY_*` process environment values, and no file in the repository sets them. The P12-T12 proof exported them from SCRATCH launcher scripts.
- Failure scenario on an unmodified host: `prepare_discovery_agent` refuses; the specialist start is denied `IDENTITY`; if the host still runs the specialist, its tool gate returns `allow` for every call, and its MCP calls without `invocation_ref` run as `local-user` in structural mode with `human` attribution.
- Decision needed: the identity source for hook processes (for example the envelope's agent fields) and for the MCP gate (for example a per-agent launch or a host-provided caller identity). After the decision, implement it, document it in `enforcement.md`, and repeat the installed-host smoke inside unmodified host sessions. Until then, qualify the `handoff.md` and `completion-report.md` statements "observed on Claude Code, Codex and the Copilot Local harness" as harness-simulated host events.

## Non-blocking items (fix inside the cycle when they touch the same files)

- `packages/discovery-runtime/src/drm_copilot_discovery/protected_records.py:290-295` and `gateway_host.py:254-271`: Python re-admits a consumed grant on every call and does not check `expires_at`. Add a Python-side use latch or a short window, with a replay test (code review, Major).
- `tests/discovery_runtime/test_schema_validation.py`: `after == before` compares one shared object with itself. Deep-copy `before` or compare against `catalog.schema(...)`, and assert one registry object across calls.
- `tests/discovery_runtime/test_gateway_host_main.py:243`: assert the identity-refusal finding per row, not only exit code 2.
- `artifacts/pester/powershell-coverage.xml`: regenerate from a full run (currently a partial run at 63.60%).
- `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py:312-327`: re-check the resolved read target against `selected_paths`.
- `spec.md:6-7`, `user-story.md:5-6`: update the stale status lines.
- `.claude/skills/execution-environment/SKILL.md` `## Test Runtime` fourth bullet and its five copies: clarify the shared-fixture wording, keeping all six byte-identical.

## Do not do

- Do not lower any coverage threshold, add a coverage exclusion for a production path, or add a `config/file-size-baseline.json` entry.
- Do not weaken or delete existing assertions; strengthen the two weak assertions instead.
- Do not edit policy files under `.claude/rules/` or `.github/instructions/`.
- Do not implement an R4 mechanism before the user decides it.
- Do not change the 1.1.22 artifact records in `handoff.md` and `completion-report.md`; the user confirmed they are accurate.
- Keep bundled mirrors byte-identical, and keep every touched covered file at or below 500 logical lines.

## Exit gate

A reaudit by `feature-review` shows no blocking finding for R1 to R3, and R4 is either resolved after the user decision or carried as the only open item. Criteria 7, 60, 65 and 66 are re-evaluated against the new head.
