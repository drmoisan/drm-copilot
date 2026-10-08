# Research: completion-consistency Codex copy and fail-open divergence (Issue #736, child C5a of epic #852)

- Date: 2026-10-08
- Branch: bug/completion-consistency-codex-copy-and-fail-open-divergence-736 (based on epic/enforcement-hook-precision-integration)
- Method note: this session had no shell tool (Bash disabled). All findings come from Read/Grep/Glob and one WebFetch. `git log`/`git blame` were not run; the #708 history was read from `docs/features/completed/completion-consistency-edit-reads-relative-checkpoint-708/` (research, follow-ups). No toolchain command was executed. Whether the fixtures named in section 6 are git-tracked was inferred (they are used by committed tests and `.gitignore` ignores only the root-anchored `/artifacts`), not confirmed with `git ls-files`.

## 1. Current state, re-derived against this tree

### 1.1 Claude hook: `.claude/hooks/enforce-completion-consistency.ps1` (423 lines)

- `Get-CheckpointFileContent` (69-90): returns `$null` when `Test-Path -LiteralPath $Path -PathType Leaf` is false; otherwise `Get-Content -LiteralPath -Raw -ErrorAction Stop`, so an unreadable file throws.
- `Resolve-EditedCheckpointContent` (266-322): takes `-CheckpointPath` (mandatory, added by #708). Returns `$null` for: no/empty `old_string` (299-301), reader returns null/empty (309-312), `old_string` absent (315-318). Applies `String.Replace` (321), which replaces every occurrence. `replace_all` is never read.
- `Invoke-CompletionConsistencyDecision` (324-412): envelope anomaly -> deny (345-356). No `file_path` or non-checkpoint path -> allow (359-367, `Test-IsCheckpointPath` at 92-101 matches `(^|/)artifacts/orchestration/orchestrator-state\.json$`). `content` empty/absent -> `Resolve-EditedCheckpointContent`; a `$null` result -> **allow** (373-380). Patched/written content that is not JSON -> allow (382-389). Evidence deny reason begins `COMPLETION_CONSISTENCY_BLOCKED:` (404).
- Entrypoint (414-423): no `try/catch`. An exception from the default reader (unreadable file) escapes the script. The Payload suite's own comment records that an uncaught throw is exit 1, which Claude Code treats as non-blocking. So "unreadable" is fail-open on Claude by two mechanisms (null -> allow, throw -> non-blocking error).
- Distinguishing Write from Edit is implicit: a Write with `content` of `''` is indistinguishable from an Edit because the test is `if (-not $content)` (373). A Write that empties the checkpoint is therefore allowed on Claude.
- Registered in `.claude/settings.json:128-165` under matcher `Write|Edit`.

### 1.2 Codex hook: `.codex/hooks/enforce-completion-consistency.ps1` (438 lines)

- `Resolve-EditedCheckpointContent` (270-322) has no `-CheckpointPath` parameter. Line 308 reads the literal `'artifacts/orchestration/orchestrator-state.json'` (defect 1). Line 321 uses `String.Replace` (defect 2).
- `Invoke-CompletionConsistencyDecision` (324-411): a null/empty resolve result is **denied** (370-378, reason "the canonical checkpoint cannot be deleted, emptied, or replaced through an unresolved patch."). Invalid JSON content is denied (380-388, "must remain valid JSON"). Parses `file_path` from the mapped record (356). Calls `Resolve-EditedCheckpointContent` at 371 without the path.
- Entrypoint (418-438): reads stdin, `ConvertFrom-CodexPreToolUsePayload`, then `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath` (424-425), calls the decision per mapped record, and catches all exceptions to `exit 2`. An unreadable file therefore still blocks on Codex, via stderr rather than a structured deny.
- Header (32-36) is stale: it says Edit calls are allowed, which the code contradicts.
- Registered in `.codex/config.toml:230-234` under matcher `^(apply_patch|Edit|Write)$` (matcher line 186).

### 1.3 Codex payload shape (verified from vendor docs, WebFetch of the Codex hooks page)

The hook input always reports `tool_name: "apply_patch"` and carries the patch in `tool_input.command`; `Edit` and `Write` are matcher aliases only, and there is no separate Edit tool. Consequences:

- The live Codex surface reaches this hook through `apply_patch`. `ConvertTo-CodexFileEditInput` (`.codex/hooks/codex-pretooluse-file-mapping.ps1:146-319`) reconstructs an Update's full post-patch content via `Resolve-CodexUpdatedFileContent` (393-474) and returns a record with `content` set, so the hook's `Resolve-EditedCheckpointContent` branch is not used for live traffic. A reconstruction failure yields empty `content` (426-428, 431-435, 466-469), which reaches the Edit branch, has no `old_string`, and is denied (already fail-closed).
- The Edit-shaped branch (`file_path` + `old_string` + `new_string`) is reachable only for payloads that carry a `file_path` (direct mapping, file-mapping 240-258, which copies every property including `replace_all`). The #415 research (`docs/features/completed/2026-07-25-codex-pretooluse-hook-transport-415/research/...:193`) records that live Edit/Write field names were never captured. Codex has no Edit-equivalent with Edit semantics; the Edit branch exists for contract parity and for tests.
- Adjacent finding, outside the four named defects: `Resolve-CodexUpdatedFileContent` reads the apply_patch source with a relative `Test-Path -LiteralPath $SourcePath` (426) against the hook process cwd. This is the live-path instance of the same cwd defect class and affects `enforce-checkpoint-monotonic.ps1` as well. The Codex payload carries a `cwd` field that neither entrypoint uses. See open question OQ-3.

### 1.4 Claude Edit tool semantics (verified from the Edit tool schema loaded in this session)

- `file_path`: absolute path to the file.
- `old_string` must match exactly and be unique; otherwise the edit fails.
- `replace_all` (boolean, default false): when true, every occurrence is replaced.
- The tool itself therefore rejects: zero occurrences, and more than one occurrence without `replace_all`. The hook's decision for those two cases cannot change file content (the Edit fails regardless); the choice is purely about hook output.
- Not verifiable from this session (recalled behavior, treat as unverified): Edit may normalize curly quotes when matching; may treat an empty `old_string` on a missing/empty file as file creation; may remove a trailing newline when `new_string` is empty. None of these can change the JSON meaning of a checkpoint except possible false "not found" results, handled by the fail-closed reason in section 4.

### 1.5 Shared helper files

`.claude/hooks/enforce-completion-helpers.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` are both 163 lines with identical headers and content in every region read (a full diff was not run). They hold `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder`, `Test-RouteRequiresPrGate` only. They have no entrypoint and are dot-sourced by both hooks (Claude 52-53, Codex 56-57). `Resolve-EditedCheckpointContent`, `Get-CheckpointFileContent`, `ConvertFrom-CheckpointJson`, `Test-IsCheckpointPath`, `Get-CheckpointStringValue`, `Test-CompletionAsserted`, `Get-MissingCompletionEvidence` are duplicated verbatim-or-near in the two hooks (Codex lacks only `-CheckpointPath`).

## 2. Root causes

1. Codex defect 1: #708 / PR #726 was scoped to the Claude surface (decision D-series in its spec); the Codex copy was recorded as follow-up 1. The Claude fix added `-CheckpointPath $filePath` at call site 374 and the mandatory parameter at 292; the Codex copy at 308/371 was never changed, and `codex-pretooluse-transport.Tests.ps1:395-406` pins the literal.
2. Defect 2: `String.Replace` was chosen without modeling the tool's uniqueness rule or `replace_all`. The payload field is never read.
3. Defect 3: the two hooks encode different policies for the same state, and the unresolved-patch result is a bare `$null` with no cause. Claude maps `$null` to allow (378); Codex maps it to deny (372-377). On Claude the default reader can additionally throw outside any handler.
4. Defect 4: `enforce-completion-consistency.Tests.ps1:47-51` omits `-CheckpointReader` and uses a relative path, so the default reader runs against whatever file exists at cwd. In this worktree `artifacts/orchestration/orchestrator-state.json` exists locally (gitignored), so the result depends on live orchestration state. No Claude test drives the default reader.

## 3. Candidate approaches (single-occurrence semantics and shared code)

- **A (recommended): pure edit-reconstruction helper in `enforce-completion-helpers.ps1` of each tree, I/O wrapper stays in the hooks.** Each runtime surface keeps its own byte-identical copy of the helper (the two helper files are already identical copies, and each is mirrored to its own bundle). No cross-tree dot-sourcing, which respects the "`.claude` and `.codex` are separate runtime surfaces; skills/agents/rules are self-contained" constraint in CLAUDE.md. Hooks stay under the cap and shrink in duplicated logic.
- B: add the logic inline to each hook. Claude would reach roughly 465 lines and Codex roughly 480 (estimates, not measured), leaving little room and repeating the duplication that caused this divergence.
- C: a new shared module under `.claude/lib/` imported by both. Rejected: `.codex/hooks` must not import from the Claude tree, and a new file needs pack-manifest entries (`pack-manifests/core.json` lists both hook files individually, codex core.json lines 53-54) plus new mirrors.

Rejected alternatives in brief: B (size/duplication), C (cross-tree dependency, new mirrors and manifest entries).

## 4. Recommended design

### 4.1 New pure functions in both `enforce-completion-helpers.ps1` copies (identical)

- `Get-EditReplaceAllFlag -ToolInput`: returns `$true` only when `replace_all` is the boolean `$true` or a string equal (case-insensitive, trimmed) to `true`. Must not cast with `[bool]`, because `[bool]'false'` is `$true` in PowerShell. Absent or any other value -> `$false`.
- `Invoke-SingleOccurrenceEdit -Text -OldString -NewString -ReplaceAll`: returns `[pscustomobject]@{ Content; Failure }`. Normalize `\r\n` to `\n` in `Text`, `OldString`, and `NewString` first (precedent: `codex-pretooluse-file-mapping.ps1:431`; the consumer only parses JSON so whitespace is immaterial, and this avoids a false "not found" on a CRLF checkpoint). Then use ordinal `IndexOf`. Zero hits -> `Failure = 'old_string-not-found'`. With `ReplaceAll` -> `Text.Replace(Old, New)` (ordinal in .NET). Without it, a second ordinal `IndexOf` starting at `first + OldString.Length` (non-overlapping count) -> `Failure = 'old_string-ambiguous'`; otherwise splice at the single index (`Substring`, no regex, so `$` in `new_string` stays literal).

### 4.2 `Resolve-EditedCheckpointContent` (same shape on both surfaces)

- Signature: `-ToolInput`, `-CheckpointReader`, `-CheckpointPath` (mandatory on both; Codex gains it, call site 371 passes `$filePath`).
- Returns `[pscustomobject]@{ Content; Failure }` instead of `$null`/string. All in-repo callers are the decision function and tests (grep over `tests/` shows only the Claude and Codex suites listed in section 6). Failure causes: `no-old_string` (absent or empty), `checkpoint-missing` (reader returns `$null`), `checkpoint-empty` (reader returns `''`), `checkpoint-unreadable` (reader throws; wrap the call in `try/catch` and convert, keeping the exception message as context), plus the two causes from 4.1.
- The path is passed to the reader unchanged (raw, including backslash spelling); `EditTarget.Tests.ps1:100-140` already pins this for Claude.

### 4.3 Decision function (defect 3)

- Gate order is unchanged: payload/envelope check, empty `file_path` -> allow, non-checkpoint path -> allow. The reader is therefore never invoked for non-checkpoint targets, so no new denial reaches them. This must be asserted with a reader that throws if invoked.
- For checkpoint targets: if `tool_input` has a `content` property (even empty) it is a Write: `content` empty -> deny (aligns with Codex "emptied"); non-empty -> current behavior. Otherwise it is an Edit: call the resolver; any `Failure` -> **deny** on both surfaces.
- Deny reason: `COMPLETION_CONSISTENCY_BLOCKED: the canonical checkpoint cannot be deleted, emptied, or replaced through an unresolved patch (<cause>).` Keep the leading token and the substring `replaced through an unresolved patch`, because `codex-pretooluse-transport.Tests.ps1:216` matches it on the subprocess path and line 437 matches `unresolved patch`. Extract a small `New-CompletionDenyDecision -Reason` helper only if line budget demands it.
- Rationale for denying zero/multiple-occurrence cases rather than passing through: the Edit tool will reject these anyway, so a deny costs nothing, preserves existing Codex behavior, matches the repository fail-closed norm, and guards against a stale or divergent on-disk read.
- Claude unreadable: the `try/catch` in 4.2 converts the throw into a structured deny with exit 0, replacing the non-blocking exit 1.
- Decision to record in the spec: "Fail-closed on a missing, empty, unreadable, or unresolvable targeted checkpoint on both surfaces (supersedes #708 spec D6 for the Claude surface)."

### 4.4 Out of the four defects; decide explicitly and leave unchanged unless the user widens scope

- Invalid-JSON content: Claude allows (385-389; pinned by `enforce-completion-consistency.Tests.ps1:31-37` and 447-453), Codex denies. Not in the epic's C5a statement. Recommend leaving as is and recording it (OQ-1).
- `enforce-checkpoint-monotonic.ps1` has the same Claude-allow (Edit "allowed", Claude lines 233-236) versus Codex-deny (transport row 201-205) split. Not in C5a scope (OQ-2).

## 5. Bundled mirrors and parity enforcement

| Canonical | Mirror | Byte-equality enforced by |
| --- | --- | --- |
| `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1` | same names under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (whole `.claude/**` tree, text equality; local-only paths excluded via `filter_distributable_claude_paths`; memory notes a local false failure on gitignored state, issue #510) |
| `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1` | same names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (whole `.codex` + `.agents` tree) and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1:61-78` (SHA-256 of both Codex files) |

Sync is a manual copy; there is no repo-to-bundle sync script (confirmed by the #708 research and by a grep of `scripts/`; the `push_down_*` scripts publish the bundle to consumer repos). `codex-pretooluse-file-mapping.ps1` is also mirrored but is not expected to change. If a new production file is introduced it needs `pack-manifests/core.json` entries in both bundles (both files are listed individually today); recommended design adds none.

## 6. Test inventory and cwd dependence

Suites that exercise this hook (line counts measured by Grep line count):

| Suite | Lines | Surface | cwd/state dependent? |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 491 | Claude, in-process | **Yes**: lines 47-51 (default reader, relative path). Other rows use the default `FolderExistsCheck` (relative `docs/features/active/...`) but their outcome is a deny for another reason, so they are invariant. |
| `.../enforce-completion-consistency.EditTarget.Tests.ps1` | 227 | Claude, #708 | No (path-keyed injected readers; asserts raw path pass-through). Lines 142-152, 167-213 pin allow-on-unresolved and must flip to deny. |
| `.../enforce-completion-consistency.Payload.Tests.ps1` | 75 | Claude envelope | No |
| `.../enforce-completion-consistency-codex.Tests.ps1` | 79 | Codex hook plus bundle SHA-256 | No |
| `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1` | 168 | Codex evidence branches | No |
| `.../enforce-completion-consistency-epic-scope.Tests.ps1` | 151 | Codex, #707 | No (all seams injected; file header says no row asserts the reader path) |
| `.../codex-pretooluse-transport.Tests.ps1` | 492 | Codex, in-process plus subprocess | In-process rows 366-406 pin the relative literal (defect 1) and inject readers. Subprocess Edit row 216-220 sets `WorkingDirectory` to the repo root and reads the live gitignored checkpoint, but its sentinel `old_string` makes the outcome a deny either way. Row 322-331 already drives the default reader against a real tracked file (the hook script by absolute path): precedent for the defect-4 fix. |
| Also touching the hook: `legacy-codex-hook-contracts.Tests.ps1` (apply_patch Add/Delete only), `codex-pretooluse-integration.Tests.ps1` (benign README Edit), `claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (Write deny shape) | n/a | both | No; unaffected by the change |

No numeric acceptance criterion is proposed from these counts, so a Numeric Derivation Evidence section is not required. The suite list was derived two ways that agreed on the dedicated suites: name glob `tests/scripts/**/*ompletion-consistency*` (6 files) and content grep for `Invoke-CompletionConsistencyDecision|Resolve-EditedCheckpointContent|Get-CheckpointFileContent` (adds transport, schema contract, and unrelated validate-orchestrator-output suites that share the helper name).

## 7. Test strategy per defect (no temporary files)

Existing seams: `-CheckpointReader` (scriptblock), `-FolderExistsCheck`, `-RoutingMatrixReader` on `Invoke-CompletionConsistencyDecision`; `-CheckpointReader` on the resolver. Default reader: `Get-CheckpointFileContent -Path`.

- Defect 1 (Codex path): new Codex suite `tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1` mirroring Claude `EditTarget` (absolute, relative, backslash path pass-through; path-keyed map readers; decision follows targeted content, not the relative literal). Delete the six resolver rows at transport 366-406 and re-home them there, so the 492-line transport file shrinks (cap is 500).
- Defect 2 (replace semantics): a table over {0, 1, 2 occurrences} x {`replace_all` absent, `$false`, `$true`, `'true'`, `'false'`} on the pure helper, plus overlapping occurrences (`aa` in `aaa`), `$` and regex metacharacters in `new_string`, CRLF text with LF `old_string`. At decision level: ambiguous without `replace_all` -> deny; same patch with `replace_all` true -> evaluated on the all-replaced content; single occurrence -> evaluated on spliced content; and a case whose allow/deny differs between replace-all and single-occurrence results. Each surface gets its own copy of these rows (the helper files are separate).
- Defect 3 (fail-closed): reader returns `$null` (missing), `''` (empty), throws (unreadable), `old_string` absent, no `old_string`, and Write with empty `content` -> deny containing the leading token and `unresolved patch`, on both surfaces. A non-checkpoint `file_path` with a throwing reader -> allow, reader never invoked (proves no new denial). Replace Claude rows `Tests.ps1:374-401` and `EditTarget.Tests.ps1:142-152,167-213`. Add an entrypoint-level row for Claude that an unreadable checkpoint produces a deny decision and exit 0 (use the `Invoke-ConsistencyEntrypoint` StringReader pattern at transport 295-319 adapted to Claude's `Read-ClaudeHookRawPayload`, or assert at the decision level if the Claude entrypoint cannot be driven in-process).
- Defect 4 (hermetic default reader): remove the default-reader row at `Tests.ps1:47-51` (replace with an injected-reader row) and add default-reader rows that resolve **committed fixtures via `$PSScriptRoot`**, never cwd. Existing tracked fixtures whose paths end in `artifacts/orchestration/orchestrator-state.json` and therefore satisfy `Test-IsCheckpointPath`:
  - non-empty: `tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json` (has `"next_step": "S8_create_pr"` and `"step8_status": "in_progress"` once each, `"step9_status"`/`"step10_status"` both `"not_started"` so that token occurs twice, issue-num `901`, no `ci_gate`);
  - empty: `tests/fixtures/worktree-resolution/shared/item-own-empty/...` (zero bytes);
  - invalid JSON: `.../shared/item-own-invalid-json/...`;
  - missing: a sibling directory name that does not exist under the same fixtures root.
  Rows: Edit flipping `next_step` to `complete` -> deny naming `ci_gate` (proves the default reader read the file; an unresolved patch would give the other reason); Edit to a non-completion value -> allow; `"not_started"` -> `"pending"` without `replace_all` -> deny (ambiguous), with `replace_all` -> allow; empty fixture -> deny (empty); missing path -> deny (missing). Add a precondition `It` asserting the fixture still contains the expected tokens so a fixture change fails with a clear message. Dedicated new fixtures are not recommended: a Write of an empty file or any file ending in `artifacts/orchestration/orchestrator-state.json` is itself intercepted by the monotonic and completion hooks (empty content is denied by both), so reusing the existing tracked fixtures is the practical route.
  Optional cwd row: `Push-Location` to the fixture root inside `try/finally` and pass the relative path, to document that relative paths intentionally resolve against cwd.
- Property tests: not required (T3/T4 hook glue); the `.codex` and `.claude` helper pair is pure, but `quality-tiers.yml` classification was not read in this session (OQ-5).
- Optional parity row: assert the two `enforce-completion-helpers.ps1` files are byte-identical to each other (no such test exists today); this overlaps C5b's parity theme and can be deferred.
- Banned in tests: temp files, `Start-Sleep`, wall-clock waits.

## 8. File inventory and 500-line cap

| File | Lines now | Expected change | Cap risk |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-completion-consistency.ps1` | 423 | resolver rewrite, decision branches, header update | Low with approach A (net roughly flat after moving logic to helpers; estimate) |
| `.codex/hooks/enforce-completion-consistency.ps1` | 438 | add `-CheckpointPath`, same rewrite, header fix | Low with approach A; highest of the production files, so verify |
| `.claude/hooks/enforce-completion-helpers.ps1` | 163 | add two functions (~50-60 lines) | None |
| `.codex/hooks/enforce-completion-helpers.ps1` | 163 | identical addition | None |
| Four bundled mirrors (the two hooks and two helpers per surface) | 423 / 163 / 438 / 163 | byte copy | Same as canonical |
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` | 474 | none planned | Do not add content (26 lines of headroom) |
| `.codex/hooks/enforce-checkpoint-monotonic.ps1` | 339 | none | n/a |
| `.claude/lib/hook-payload/HookPayload.psm1` | 497 | none | Do not touch (3 lines of headroom) |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 491 | remove/replace rows 47-51 and 374-401; **must not grow** | **High**: only 9 lines of headroom. Put new rows in new sibling files |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 492 | remove rows 366-406, update marker if needed | **High**: only 8 lines of headroom; net must shrink |
| `.../enforce-completion-consistency.EditTarget.Tests.ps1` | 227 | flip allow rows to deny | Low |
| New: Claude `enforce-completion-consistency.EditSemantics.Tests.ps1` (pure helper table plus decision rows plus default-reader fixture rows; split into a second file if it nears 450) | n/a | new | Plan two files if needed |
| New: Codex `enforce-completion-consistency-edit-target.Tests.ps1` (and a second file for semantics/default-reader rows) | n/a | new | Same |

Production PowerShell files touched: four hooks/helpers plus their four mirrors. Per `.claude/rules/powershell.md`, more than three production PowerShell files belongs on the orchestrated large path; the epic child run is already orchestrated.

## 9. Toolchain and constraints

- Order: format -> analyze -> test (type check n/a). MCP tools: `mcp__drm-copilot__run_poshqc_format`, `..._analyze`, `..._test`; repo settings `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (CodeCoverage enabled, JUnit and CoverageGutters outputs under `artifacts/pester/`, no `CodeCoverage.Path` list).
- Coverage population since #527 comes from `config/poshqc-coverage.json`, roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. Both hooks and both helper files are inside the denominator; the bundled mirrors are not. Gates: line >= 85% (no branch gate for PowerShell), no regression on changed lines.
- Self-hosted invocation (cross-check, per memory note `mcp-poshqc-test-reads-installed-extension-settings`, dated 2026-08-25 and possibly partly superseded by #527; verify rather than assume): `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/codex-hooks')"`. Parse per-file coverage by the enclosing `package` path, because the same hook filename exists under both `.claude/hooks` and `.codex/hooks`. In an isolated agent worktree `pwsh` may be text-denied; use the PowerShell tool.
- Constraints confirmed: no Python in hooks (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks`; C5b extends it to `.codex/hooks`); fail-closed; deny reasons keep the leading `COMPLETION_CONSISTENCY_BLOCKED:` token; the two legacy markers (`COMPLETION_CONSISTENCY_BLOCKED`, `replaced through an unresolved patch`) must continue to match.
- Downstream: C5b (#737) discovery guards will cover the suites rewritten here. Keep new suites hermetic (no relative-path reads, no live checkpoint reads) and named with `completion-consistency` so name-based discovery finds them.

## 10. Risks

- Denying previously allowed Claude Edits (missing/empty/not-found) is a behavior change; mitigated because the Edit tool rejects those same cases itself, and Edit requires a prior Read so the target exists. A false deny is possible only if the hook's read diverges from the tool's view (CRLF, curly-quote normalization, concurrent change); LF normalization addresses the first, the others are accepted and documented.
- Changing the resolver return type breaks any out-of-tree caller; none was found in this tree.
- Mirror drift: the four mirrors are manual copies; the byte-equality tests catch it only at test time. Bundle-parity python test has a known local false failure on gitignored state (#510).
- Test-file headroom (491/500 and 492/500) makes accidental growth a cap violation.
- Reordering the Write/Edit discrimination (`content` property presence) changes Claude behavior for Write with empty content (now deny).
- `MultiEdit` is not matched by `.claude/settings.json` (`Write|Edit`) and no hook handles it; whether Claude Code still exposes it was not verified. Pre-existing and out of scope.
- The default `FolderExistsCheck` is cwd-relative on both surfaces (`Test-Path docs/features/active/...`), another instance of the defect class at runtime; not changed here.

## 11. Open questions

- OQ-1: Should invalid-JSON patched/written content also become deny on Claude to match Codex? Not named by the epic; recommended: no, record only.
- OQ-2: Should the monotonic hook's Claude-allow versus Codex-deny Edit divergence be handled in a follow-up? Recommended: yes, file a follow-up.
- OQ-3: Should relative apply_patch source paths and relative Edit `file_path` on Codex be resolved against the payload `cwd`? Recommended: out of C5a; raise with C5b/C3 since it also affects the monotonic hook.
- OQ-4: Empty `old_string` on a missing/empty checkpoint (possible Edit-as-create): recommended deny with the `no-old_string` cause; confirm acceptable since Write remains the supported creation route.
- OQ-5: Tier classification of the hooks in `quality-tiers.yml` (not read) decides whether property-based tests are mandatory for the two new pure helpers.
- OQ-6: Whether to add a helper-pair byte-parity test now or leave to C5b.
