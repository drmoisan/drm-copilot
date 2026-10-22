# P9-T1 Shared native authority, payload and freshness primitives contract

Timestamp: 2026-10-22T14-41
Task: [P9-T1] Share narrow native authority, payload, and freshness primitives.
Result: PASS

## Modules delivered (`.claude/lib/discovery-validation/`)

- `DiscoveryAuthority.psd1` (new): module manifest, version 2.0.0, root module DiscoveryAuthority.psm1, nested DiscoveryEncoding/DiscoveryManifest/DiscoveryPayload, 24 exported functions.
- `DiscoveryAuthority.psm1` (new): `Resolve-DiscoveryAuthorityLocation` (platform state roots: LocalApplicationData, ~/Library/Application Support, $XDG_STATE_HOME or ~/.local/state; `<root>/drm-copilot/discovery/workspaces/<sha256(canonical workspace)>`; Windows hashes the invariant-lowercase native spelling; authority inside the workspace, relative roots, parent references and a missing Windows state root fail with AUTHORITY_* codes), `Get-DiscoveryTrustedHostEnvironment`, digest partitions (`Get-DiscoveryPartitionName`, session and invocation directories, activation record path), `Test-DiscoveryProtectedPath` (inside the protected directory and outside the workspace), `Test-DiscoveryRelativePath`, `ConvertFrom-DiscoveryActivationRecord` (eight exact keys, schema 2.0.0, activate/deactivate, positive integer generation checked textually, lowercase digests, workspace-relative profile path, all-or-nothing bindings; ACTIVATION_INVALID / ACTIVATION_WORKSPACE) and `Read-DiscoveryActivationState` (missing / invalid / inactive / active through a ReadText seam).
- `DiscoveryEncoding.psm1` (new; split out so DiscoveryAuthority.psm1 stays under 500 lines after formatting): `Get-DiscoverySha256Hex`, `Get-DiscoveryBytesSha256Hex`, `ConvertTo-DiscoveryCanonicalJson` (ordinal key order, compact, trailing LF, non-ASCII literal, control characters escaped by code point, integers only).
- `DiscoveryManifest.psm1` (new): `ConvertFrom-DiscoveryInputManifest` (strict keys, categories, digests, sizes, relative paths, repository references, uniqueness, missing-versus-entry conflict), `Get-DiscoveryInputManifestDigest`, `Get-DiscoveryWorkspacePath`, `Compare-DiscoveryInputManifest` (edited, evidence-replaced, deleted, appeared, renamed, profile-changed drift over an injected ReadBytes seam) and `Assert-DiscoveryInputsFresh` (INPUT_DRIFT naming every moved input).
- `DiscoveryPayload.psm1` (new): `ConvertFrom-DiscoveryHostEnvelope` / `ConvertFrom-DiscoveryHostPayloadText` (Claude Code and Codex snake_case envelopes, GitHub Copilot camelCase with snake_case fallback; anomalies UnsupportedHost, EmptyEnvelope, MissingSessionId, MissingEvent, NonObjectToolInput), `Get-DiscoveryTrustedPrincipal` (attributed only when the attested DRM_DISCOVERY_HOST and DRM_DISCOVERY_SESSION_ID equal the envelope; agent identity only when both DRM_DISCOVERY_AGENT_ID and _ROLE are present; parent values pass through; nothing in tool input supplies identity), `Get-DiscoveryHostEnvironmentValueTable`, `Get-DiscoveryPayloadAnomalyReason`, `Test-DiscoverySupportedHost`.

## Cross-runtime parity proven

- `tests/fixtures/discovery_authority/authority-vectors.json`: all 7 location vectors resolve to the shared workspace, digest and directory; all 5 invalid locations fail before I/O; all 4 activation records decode to the shared record and encoded digest; all 15 invalid records fail with the shared code (ACTIVATION_INVALID / ACTIVATION_WORKSPACE).
- `tests/fixtures/discovery_host/tool-authorizations.json`: all 9 digest vectors reproduce `sha256(canonical_json({inputs, operation, tool}))`, including unicode paths, nested arrays and the control-character escape vector (the first implementation matched control characters with culture-aware string comparison, which treats them as ignorable; the escaper now switches on the integer code point).

## Tests (Pester v5)

- `LPTEST/DiscoveryAuthority.Tests.ps1` (46 cases), `LPTEST/DiscoveryManifest.Tests.ps1` (16), `LPTEST/DiscoveryPayload.Tests.ps1` (20): in-memory envelopes, byte stores and read seams; no temporary file, process, network or clock.
- `LPTEST/DiscoveryValidation.Manifest.Tests.ps1`: ExpectedPaths now lists the five helper files plus the compatibility module; the on-disk assertion covers .psm1 and .psd1; a new Describe proves each helper is stored byte-identically under `extensions/drm-copilot/resources/lib/discovery-validation/` and listed as `.codex/lib/discovery-validation/<name>` in the Codex core.json.
- Folder result: 148 of 149 Pester cases pass (the three new suites, the manifest suite, the compatibility module suites and the Claude library convention suite). The single failure is pre-existing and outside this task: `ClaudeLibModuleConvention.Tests.ps1` reports that `.claude/lib/codex-routing/CodexDiscoveryRouting.psm1` (created by P7-T4) lacks the fail-fast convention sentence in its help block. All five new modules satisfy the convention (guard line, -ErrorAction Stop sibling imports, convention sentence, <= 500 lines).

## Publication

- Claude bundle: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/` carries the five files byte-identically; `claude-customizations/pack-manifests/core.json` lists them.
- Codex bundle: `extensions/drm-copilot/resources/lib/discovery-validation/` stores the five files once; the P8-T9 directory mapping publishes them to `.codex/lib/discovery-validation/`; `codex-and-agents-customizations/pack-manifests/core.json` lists the five destinations. `test_codex_core_manifest_closure`, both pack-manifest completeness suites, both resource-contract suites, the virtual-path suite and the dependency-closure suite pass.
- The existing `.claude/lib/discovery-validation` T3 tier covers the new files; `test_quality_tiers_contract` and `_classification` pass (no QT007/QT008).

## Acceptance statement

All hosts share the same narrow location, activation, digest, freshness and principal semantics through one PowerShell library that mirrors the TypeScript gateway and Python runtime rules; altered, added, missing, deleted, renamed or untrusted authority inputs produce typed failures (AUTHORITY_*, ACTIVATION_*, INPUT_MANIFEST_INVALID, INPUT_DRIFT, unattributed principal). Every new helper has a current published mirror and manifest entry in both bundles, and classification produces no QT007/QT008 at this boundary. GitHub hook population is introduced with the first tracked hook in P9-T2.

## Deviation and carried notes

- The plan names four CL files; a fifth, `DiscoveryEncoding.psm1`, was split from DiscoveryAuthority.psm1 because Invoke-Formatter expanded the module to 595 lines. It is registered in the psd1, both core manifests, the manifest test and both mirrors.
- Pre-existing convention defect in `.claude/lib/codex-routing/CodexDiscoveryRouting.psm1` (missing convention sentence) is recorded for the P11 closing review; it is not a file of this task.
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` was extended to resolve directory-mapped Codex resources; without it the test could not read the new `.codex/lib` entries.
