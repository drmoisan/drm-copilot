# Implementation Deviations from spec.md's Proposed Fix — Issue #272

Timestamp: 2026-07-02T19-35

## 1. Coverage-allowlist infrastructure fix (new, out-of-spec file edit)

**What:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` were edited to add `.claude/hooks/enforce-pr-author-skill.ps1` to the `CodeCoverage.Path` allowlist. The locally-installed VS Code extension package's own copy of this settings file (outside the git repository, under the local `.vscode-server-insiders` profile) was also edited for this session so the `mcp__drm-copilot__run_poshqc_test` MCP tool could produce numeric coverage for the target file.

**Why:** The plan's Phase 0/4 baseline and final coverage tasks (P0-T16, P4-T11, P4-T12) mandate numeric coverage evidence for `enforce-pr-author-skill.ps1`. Prior to this feature, that file was not in the `CodeCoverage.Path` allowlist at all, so the MCP toolchain produced zero coverage data for it — the mandatory evidence could not be produced without this fix. This is not out-of-scope creative work; it is the established, self-documented pattern already used in this same settings file for other hooks (see the file's own "Issue #214" comment for the identical pattern).

**Not in spec.md's file list:** spec.md's "Files/modules to change" list does not name this settings file, because it is infrastructure required to observe coverage, not application behavior.

## 2. Test file split into two Pester files (not literally "extend, do not replace")

**What:** `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (476 -> 487 lines) retains all pre-existing tests plus the passing-preflight mocks required by the new check. The new preflight-specific tests (mocked pass/fail scenarios, direct-seam unit tests of `Invoke-OrchestratorStatePreflight`, and the real-subprocess end-to-end test) were placed in a **new sibling file**, `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (129 lines).

**Why:** Adding all new tests directly to the primary file would have pushed it to 556 lines, over the repository's 500-line cap. Per spec.md's own file-size mitigation guidance ("if the test file would exceed the cap, extract shared `BeforeAll` fixtures... before adding new `Context` blocks"), and per the established, pre-existing repo pattern of splitting large Pester suites by concern (`tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` / `PoshQC.Comprehensive.Tests.ps1` / `PoshQC.EntryPoints.Tests.ps1` / `PoshQC.ScanFolders.Tests.ps1`), a new sibling test file — not a shared fixture helper file — was the correct mitigation. Both files still test the same `enforce-pr-author-skill.ps1` hook and satisfy the test-file-location convention.

## 3. Preflight check requires 10 test contexts' `BeforeEach` extended, not just `'allowed commands'`

**What:** spec.md's Test Strategy names only `Context 'allowed commands'` as needing a passing-preflight mock. In practice, because the preflight check runs on every `--body-file`-with-context-artifact-present path (per spec's own explicit ordering: "after Case C... before the five existing receipt checks"), all five `receipt - *` contexts plus the `Get-PrAuthorBypassReason helper` and `Test-PrAuthorBypassRequired helper` contexts also needed the same mock added — 10 tests total across 7 additional `Context`/helper blocks, not 2.

**Why:** This is a direct, mechanical consequence of spec's own specified check ordering, not a design deviation; the alternative (not adding the mocks) would have left 8 pre-existing tests failing, violating the AC that all pre-existing tests continue passing unmodified.

## 4. End-to-end preflight test uses a real-seam override, not a literal `CLAUDE_TOOL_INPUT`-only invocation

**What:** spec.md's Test Strategy describes "one new `It` exercising a real `pwsh` process invocation for the preflight-block case." The implemented test spawns a real, separate `pwsh` process but dot-sources the hook and overrides `$script:PrContextArtifactPath` to point at a real, permanently-existing file (the hook script itself) before replaying the entrypoint logic, rather than invoking the hook file directly via `-File` with only `CLAUDE_TOOL_INPUT` set.

**Why:** Reaching the preflight branch via the unmodified real entrypoint requires `artifacts/pr_context.summary.txt` to exist (Case C precedence, which spec explicitly preserves). That file is intentionally gitignored and does not exist in a fresh checkout. Creating it — even temporarily — would violate the repository's hard, no-exceptions prohibition on temporary file creation in tests (`.claude/rules/general-unit-test.md`). The implemented approach reuses the exact "real seam, stand-in existing file" pattern already established elsewhere in the same test file (e.g., `Get-PrContextSummaryLastWriteUtc real seam`) and still exercises the real, unmocked `Invoke-OrchestratorStatePreflight` default `$Invoker`, which still shells out to the real Python validator against the real checkpoint path — satisfying the intent (a genuine, real-subprocess end-to-end test) without violating the no-temp-files rule.

## 5. Codex mirror body is not literally byte-identical to the root hook (one intentional line)

**What:** spec.md's Technical Specifications state the Codex mirror body should be "byte-identical to the root hook's new body." After running the authoritative `codex_native_converter` CLI directly (P4-T7/P4-T8) against a scratch destination, the converter's own output showed it rewrites `.claude/hooks/validate-orchestrator-output.ps1` to `.codex/hooks/validate-orchestrator-output.ps1` inside the new `Invoke-OrchestratorStatePreflight` docstring's cross-reference — an intentional, existing converter behavior for cross-ecosystem path references, not specific to this feature.

**Why:** The repository's own governing mechanism (the converter itself) produces this one-line divergence; matching it exactly is more correct than a naive byte-copy that would silently drift from what the authoritative tool would regenerate. The mirror was corrected to match the converter's exact output (confirmed via `diff --strip-trailing-cr` against a fresh converter run), which is a truer reading of spec's underlying intent (the mirror should be what the converter produces) than the literal "byte-identical" phrasing, since spec.md's phrasing predates this research finding (research explicitly flagged this as an open question: "presumably validated via the codex_native_converter pipeline's own test suite... rather than the resource-contract test").

## 6. AC #7 (orchestrator-recorded `pr_author_preflight` checkpoint field) left unchecked

**What:** spec.md's Acceptance Criteria bullet #7 ("The orchestrator invokes the orchestrator-state validator before delegating to `Agent(pr-author)` and records the result under a new `pr_author_preflight` field...") was left unchecked in `spec.md`.

**Why:** This bullet describes runtime behavior of a live orchestrator session, not a one-time code artifact. This implementation delegation documented the required mechanism and field shape in `orchestrate/SKILL.md` and `orchestrator.md` (mandatory reading for any future orchestrator session), but did not itself run a live orchestrator delegation to `Agent(pr-author)` that would populate a real `pr_author_preflight` field — PR creation/delegation is explicitly out of scope for this executor delegation per the calling agent's own instructions. This is intentionally left unchecked rather than falsely marked complete.
