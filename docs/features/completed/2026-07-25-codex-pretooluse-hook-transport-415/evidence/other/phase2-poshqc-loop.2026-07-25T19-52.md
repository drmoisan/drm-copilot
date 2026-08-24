# Phase 2 — PoshQC Loop and Parity Gates (Issue #415)

Timestamp: 2026-07-25T19-52

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53` for every stage, followed by the two targeted pytest parity modules. **All stages passed in one uninterrupted pass**; no stage failed and no stage changed a file.

## Command / EXIT_CODE per stage

### Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format`
EXIT_CODE: 0

Files changed: **none.** `git status --porcelain` immediately after the format stage listed only this feature's own intended changes. Root/bundle SHA256 parity for the new module was re-verified after the format stage and still held (`ParityAfterFormat=True`), confirming the formatter did not reformat one copy and not the other.

### Stage 2 — Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze`
EXIT_CODE: 0

Findings: **0 errors, 0 warnings, 0 information** (`ok: true`).

### Stage 3 — Test

Command: `mcp__drm-copilot__run_poshqc_test`
EXIT_CODE: 0

### Stage 4 — pytest parity gates

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
EXIT_CODE: 0

```
........                                                                 [100%]
8 passed in 0.11s
```

## Output Summary

**Test counts:** `tests="1358"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="36.230"`.

The count rose from 1356 to 1358 because `[P2-T3]` split the former single `It 'reads stdin and contains no legacy Claude environment-variable dependency'` into two separately-scoped assertions and added one new manifest assertion (net +2 tests). Zero failures.

**Line-coverage headline:** `LINE missed="233" covered="2150"` → total 2383 → **90.22%**, unchanged from baseline and above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

**Both pytest parity modules pass (8/8).** This is the check `[P2-T3]` acceptance calls out explicitly: `test_bundled_codex_files_are_listed_in_some_pack_manifest` enumerates the bundle `.codex/hooks` directory on disk (`test_push_down_codex_and_agents_pack_manifest_completeness.py:179-183`) and requires every bundled hook to appear in some pack manifest. The `[P2-T2]` mirror without the `core.json` entry added by `[P2-T3](b)` would have failed it; with both applied it passes.

## Work delivered in this phase

**`[P2-T1]` — new shared module `.codex/hooks/codex-pretooluse-file-mapping.ps1`.**

- 474 lines (`(Get-Content -LiteralPath $path).Count`), within the 500-line cap.
- Parses cleanly: `[System.Management.Automation.Language.Parser]::ParseFile` reports 0 errors.
- Entrypoint-free: only script-scoped constants and function definitions, following the `enforce-completion-helpers.ps1` precedent. Confirmed it contains no stdin read and no legacy Claude environment read (both regexes return no match), which is what lets it be excluded from the stdin-presence assertion while remaining inside the legacy-environment-absence assertion.

Public semantics were verified directly before mirroring:

| Behaviour required by `[P2-T1]` | Verified result |
|---|---|
| `ConvertFrom-CodexPreToolUsePayload` throws on empty input | `my-hook hook input is empty.` |
| ... on whitespace-only input | `my-hook hook input is empty.` |
| ... on invalid JSON | `my-hook hook input is malformed JSON: ...` |
| ... on missing `tool_input` | `my-hook hook input is missing tool_input.` |
| ... on null `tool_input` | `my-hook hook input is missing tool_input.` |
| ... on a bare JSON `null` payload | `my-hook hook input is missing tool_input.` |
| every thrown message begins with `-HookName` | confirmed for all of the above, and `budget hook input is missing session_id.` for the `-RequireSessionId` case |
| `-RequireSessionId` rejects a missing `session_id` | throws |
| without `-RequireSessionId`, a missing `session_id` is accepted | no throw |
| **no `tool_name` assertion of any kind** | an unadmitted tool name parses without throwing |
| `Edit` maps via `file_path` carrying `old_string`/`new_string` | `count=1 file_path=README.md op=Edit old=a new=b` |
| `Write` maps via `file_path` carrying `content` | `count=1 file_path=README.md op=Write content=safe` |
| unmapped `apply_patch` `{command:''}` returns an EMPTY array | `count=0` |
| unmapped `apply_patch` `{command:'noop'}` returns an EMPTY array | `count=0` |
| unadmitted tool name (`Bash`) returns an EMPTY array | `count=0` |
| admitted tool name with no `file_path` returns an EMPTY array | `count=0` |
| `*** Add File:` parsed with added-line content | `fp=tests/unit/test_bad.py op=Add content=[import tempfile]` |
| `*** Delete File:` detected, empty content | `op=Delete contentLen=0` |
| `*** Move to:` destination captured, source retained | `fp=artifacts/research/moved.md source=README.md` |
| multi-file patch yields one record per file | `count=2 paths=a.txt,b.txt` |
| Update reconstruction runs only under `-ResolveUpdateContent` for `-GovernedPath` | governed update reconstructed and byte-compared equal to the LF-normalized on-disk file (`contentMatches=True`) |
| ungoverned Update yields NO record (allow, Interpretation I2) | `count=0` |
| ungoverned Update with a missing on-disk source yields NO record instead of failing | `count=0` — this is the latent-defect fix (`spec.md:98`) |
| governed Update whose hunk does not apply yields one record with EMPTY content | `count=1 contentLen=0` — routes to the existing fail-closed deny, never exit 2 (Interpretation I2) |

The verification harness was a throwaway script held in the session scratchpad outside the repository working tree, consistent with Interpretation I1 and Hard Constraint 5; it created no temporary files inside the repo.

**`[P2-T2]` — bundle mirror.** SHA256 of both copies equal: `4951858193773BCB4A36548B6F01CAE40BD81412A723AFACC4E9D12CB3899E7D`.

**`[P2-T3]` — parity lists and manifest.**

- Added `$script:SharedModuleNames` and `$script:StaticCheckNames` to `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. The shared module is now inside the parse-check + 500-line list and the root/bundle hash-parity list, inside the legacy-environment-absence assertion, and deliberately outside the stdin-presence assertion and outside every process-level invocation loop (`ignores poisoned Claude variables ...` still iterates `$script:PreToolHookNames`; `fails closed with exit 2 ...` still iterates `$script:AllHookNames`).
- Added `.codex/hooks/codex-pretooluse-file-mapping.ps1` to the `paths` array of `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Added the Pester assertion `lists every shared hook module in the core pack manifest`.
- Test file length after the edit: **267 lines**, within the 500-line cap.

No edit was needed in `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`: its 500-line gate enumerates `.codex/hooks/*.ps1` from disk with `Get-ChildItem`, so the new module is covered automatically (474 ≤ 500), as is its bundle-parity assertion.

## Recorded observations

**Observation 1 — internal helper functions.** `[P2-T1]` specifies two public functions. The delivered module defines those two plus three internal helpers (`ConvertTo-CodexAddedLineText`, `Test-CodexGovernedPath`, `Resolve-CodexUpdatedFileContent`). The public surface consuming hooks call is exactly the two specified functions; the helpers exist because `.claude/rules/general-code-change.md` requires long branching logic to be factored into small focused functions rather than inlined, and inlining them would have produced a single deeply-nested function. The file header labels the public surface and marks the three helpers INTERNAL, and each helper's `.SYNOPSIS` begins with `INTERNAL.`.

**Observation 2 — the new module is not coverage-measured.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` scopes `CodeCoverage.Path` to an explicit allow-list; only two `.codex/hooks` files are in it (`enforce-completion-consistency.ps1` and `enforce-completion-helpers.ps1`). The new shared module is therefore outside the measured set, which is why overall line coverage is unchanged at 90.22%. That allow-list is a pre-existing repository-wide configuration choice, it is not named in this plan's files-to-change, and no plan task authorizes editing it, so it was left unmodified. Consequence for `[P8-T8]`: changed-line coverage evidence will come from `enforce-completion-consistency.ps1`, which is both coverage-measured and rewired in Phase 6. This is carried forward to `[P8-T8]` for explicit treatment.

## Batch accounting (convention C2)

1 production unit (the new module plus its bundle mirror), 1 JSON manifest, 1 test file. Within C2 limits.
