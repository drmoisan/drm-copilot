# Batch-budget state portability (issue #596) — research

- Feature: `docs/features/active/2026-08-29-batch-budget-state-portability-596/`
- Epic: `claude-runtime-portability`, Feature B, wave 0, complexity C3
- Research date: 2026-08-29
- Timestamp note: the filename timestamp `2026-08-29T15-07` is derived from the session worktree
  marker `drm-copilot-wt-2026-08-29T15-07`. No wall-clock read was available to this agent
  (the Bash tool is disabled in this session), so a more precise minute could not be obtained.
- Run mode: preparation only. No implementation, no source or configuration change.

## 0. Citation re-derivation (every prompt citation checked against the current tree)

Every citation supplied in the delegation prompt was re-read in this worktree. Results:

| Prompt citation | Status | Observed |
| --- | --- | --- |
| `push-down-service-call.ts:166` = `pushDownClaudeCustomizationsServiceCall` | Confirmed | Function declaration begins at line 166; body runs to line 201. File is 201 lines. |
| `copilot-customizations-engine.ts:156` = `enumerateSourceFiles` | Confirmed | Declaration at line 156, body to line 175. |
| Copy loop "around `copilot-customizations-engine.ts:376`" | Confirmed | The `for (const sourcePath of enumerateSourceFiles(...))` header is at line 376; the loop body runs to line 425. |
| `render-pr-helpers.ts:422` is the only `gitignore` match under `extensions/drm-copilot/src/` | Confirmed | Case-insensitive search for `gitignore` across `extensions/drm-copilot/src` returns exactly one hit: `render-pr-helpers.ts:422`, a JSDoc comment about file-suffix extraction. |
| `enumerateSourceFiles` "walks the two root folders `.claude` and `config`, excluding only `.claude/settings.local.json`" | **Corrected (attribution)** | `enumerateSourceFiles` is generic and takes `rootFolders` as a parameter. The two roots are `ROOT_FOLDERS` in `claude-customizations.ts:50`; the single exclusion is `EXCLUDED_RELATIVE_PATHS` in `claude-customizations.ts:69-71`. The behaviour claim holds; the file/line attribution does not. |
| `enforce-powershell-batch-budget.ps1:157` = `[string] $SessionId = 'default'` | Confirmed | Exact text at line 157. |
| `enforce-powershell-batch-budget.ps1:248-250` assigns `'default'` | Confirmed | 248 `$sessionId = $env:CLAUDE_SESSION_ID`; 249 `if (-not $sessionId) {`; 250 `$sessionId = 'default'`; 251 `}`. |
| `enforce-powershell-batch-budget.ps1:193` composes `powershell-batch-budget.$SessionId.json` | Confirmed | Exact text at line 193. |
| `enforce-python-batch-budget.ps1` identical defect at lines 154, 190, 245-247 | Confirmed | 154 parameter default; 190 state-path composition; 245-247 the env read and `'default'` assignment (the closing brace is line 248). |
| Normalization only at PowerShell hook lines 122 and 183 | Confirmed | Both are `$normalized = $FilePath -replace '\\', '/'` / `$normalized = $filePath -replace '\\', '/'`. No `Resolve-Path`, no `GetFullPath`, no containment check anywhere in either hook. |
| `.gitignore:68` is `.claude/state/` | Confirmed | Line 68 exactly. Line 67 is `.claude/agent-memory`; line 21 is `.claude/worktrees`. |
| `.claude/state/` "does not exist in a fresh checkout" | Confirmed as a git statement; **corrected as a worktree statement** | The directory is git-ignored, so it is absent from a fresh checkout. It is **not** absent from this worktree: `.claude/state/python-batch-budget.default.json` exists on disk right now. The epic manifest's stronger claim ("`.claude/state/` does not exist in this worktree at all") was true when the epic was authored and is false now. |
| Hook line counts 284 and 281 | Confirmed | `enforce-powershell-batch-budget.ps1` = 284 lines; `enforce-python-batch-budget.ps1` = 281 lines. Bundle mirrors are 284 and 281 respectively. |
| Resource-contract test lines 101-126 | Confirmed | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` spans lines 101-126 inclusive. |

One additional prompt statement could not be confirmed and is reported as unknown: the claim that a
PreToolUse envelope carries a session identifier. See section B.1.

## 1. Current-state analysis

### 1.1 The two Claude batch-budget hooks

Both hooks are registered as `PreToolUse` command hooks on the `Write|Edit` matcher in
`.claude/settings.json` (lines 128-145: `enforce-python-batch-budget.ps1` at line 136,
`enforce-powershell-batch-budget.ps1` at line 144). Both are invoked as
`pwsh -NoProfile -File .claude/hooks/<name>.ps1`, i.e. with a **workspace-relative** script path,
which means the hook process inherits the Claude Code workspace directory as its current working
directory. That is why `[string] $Root = (Get-Location).Path` (PowerShell hook line 158, Python hook
line 155) resolves correctly today — but only incidentally, and only for the process CWD, not for
the paths inside the payload.

Structure of `enforce-powershell-batch-budget.ps1` (the Python hook is structurally identical with
`Python` substituted for `PowerShell` and `.py` for `.ps1|.psm1|.psd1`):

| Function | Lines | Role |
| --- | --- | --- |
| `Get-PowerShellBatchBudgetState` | 42-59 | Fresh state factory: `prodCap`, `testCap`, `prodFiles`, `testFiles`. |
| `ConvertTo-PowerShellBatchBudgetState` | 61-82 | Rehydrate persisted state over the fresh defaults. |
| `Get-PowerShellBatchBudgetBlockDecision` | 84-106 | Build the deny envelope. |
| `Invoke-PowerShellBatchBudgetDecision` | 108-150 | Pure decision: classify, dedupe, cap-check, record. |
| `Invoke-PowerShellBatchBudgetHook` | 152-215 | I/O orchestration behind four injected scriptblock seams. |
| `Invoke-PowerShellBatchBudgetEntryPoint` | 217-269 | Env reads (session id, caps), dispatch, deny-only emission. |
| entry-point wiring | 271-284 | Dot-source guard, explicit stdout write, `exit`. |

The four existing seams on `Invoke-*BatchBudgetHook` are `TestPathExists`, `EnsureDirectory`,
`ReadState`, `WriteState` (PowerShell hook lines 161-167). `Invoke-*BatchBudgetEntryPoint` has one
seam, `ReadPayload` (line 241). These are the extension points any new behaviour should use.

### 1.2 The persisted state-file schema (question B, third bullet)

The write path is PowerShell-hook lines 164-167 (the `WriteState` default) and lines 206-212 (its
invocation). The persisted document is exactly the ordered dictionary produced by
`Get-PowerShellBatchBudgetState` and mutated by `Invoke-*BatchBudgetDecision`, serialized with
`ConvertTo-Json -Depth 5`. The observed on-disk artifact in this worktree confirms the shape:

`.claude/state/python-batch-budget.default.json`

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-29T15-07/10460c0f-1dc1-4f43-8a37-0453379bc08a/scratchpad/make_negative_control.py"
  ],
  "testFiles": []
}
```

Two facts follow, both load-bearing:

1. **There is no timestamp material in the state file at all.** No `createdAt`, no `updatedAt`, no
   session marker. A TTL or reset-on-age rule therefore cannot be implemented by reading the current
   schema; it requires a schema addition plus a clock seam. `ConvertTo-*BatchBudgetState`
   (lines 61-82) copies only the four known keys, so an added key is silently dropped on rehydrate
   unless that function is extended too.
2. **The live artifact is itself the defect, demonstrated.** The single recorded `prodFiles` entry is
   an absolute path under the OS temp directory
   (`C:/Users/DANMOI~1/AppData/Local/Temp/claude/.../scratchpad/make_negative_control.py`), not a
   path in any worktree. It consumed one of three production Python slots for every subsequent
   session that resolves to the `default` session id. This is defect 3 (unscoped paths) and defect 2
   (shared never-resetting counter) observed together in a real artifact, without needing to
   construct a repro.

### 1.3 The push-down pipeline, end to end

Entry point (production, in-process):

1. `pushDownClaudeCustomizationsServiceCall` (`push-down-service-call.ts:166-201`).
   - `bundledSourceRoot(extensionRoot, "resources/claude-customizations")` (lines 169-172, helper at
     lines 78-81) — the source root is the **pre-built bundle**, not the repository tree.
   - `destinationRoot = toPosixPath(input.workspaceRoot)` (line 173).
   - `bundleRoot: sourceRoot` (line 186) — the bundle root and the source root are the same path for
     this call, as the comment at lines 174-175 states.
   - Calls `pushDownClaude` = `pushDownCustomizations` from `claude-customizations.ts`.
2. `claude-customizations.ts:235-315` — the Claude entry point. It composes three decorators over the
   injected adapter, innermost first:
   - `RoutingMergeFileSystem` (lines 270-274) — merges `config/orchestration-routing.json`.
   - `BlastRadiusDeriveFileSystem` (lines 280-287) — derives `config/blast-radius.json`.
   - `ExcludingFileSystem` (lines 290-302) — enumeration filtering (exclusions, pack selection,
     agent-memory scope, memory mode) and legacy-C# read redirection.
   Then delegates to the shared engine with `rootFolders: ROOT_FOLDERS` (line 310),
   `artifactDirectory: ARTIFACT_DIRECTORY` (line 311) and `rewriteReferences: passthroughRewrite`
   (line 312).
3. `pushDownCustomizations` (`copilot-customizations-engine.ts:343-448`) — the shared engine:
   - `validateDestination` (line 365).
   - `enumerateSourceFiles(fs, effectiveSource, effectiveRoots)` (lines 376-380).
   - copy loop, lines 376-425: derive `relativePath`, derive `destinationPath` (line 386), classify
     created/overwritten (lines 387-396), read (398), rewrite (399-400), `fs.ensureDir(destParent)`
     (line 416), `fs.writeTextFile(destinationPath, rewrittenText)` (line 417).
   - `writeSummaryArtifact` (lines 441-446).

**Where a destination-side write can be inserted without breaking the module's I/O boundary.** The
repository has already answered this question twice, for `config/orchestration-routing.json` and
`config/blast-radius.json`. The established answer is a **`PushDownFileSystem` decorator**, and the
rationale is written down at `claude-routing-merge.ts:14-19`: engine-level logic would leak into the
Copilot and Codex entry points, and `rewriteReferences` is the wrong hook because it sees only the
source text and never the destination's current content. That reasoning applies verbatim to a
`.gitignore` writer. The engine (`copilot-customizations-engine.ts`) must not be modified.

There is, however, a constraint the two existing decorators do not expose: `RoutingMergeFileSystem`
and `BlastRadiusDeriveFileSystem` both intercept `writeTextFile` for a path the engine *already*
writes, because both target paths are enumerated payload files. A decorator cannot manufacture a
write for a path that is not in the payload. That distinction is what separates options (i) and (ii)
below.

### 1.4 Toolchain and policy constraints in scope

- PowerShell: format → analyze → test via the PoshQC MCP functions (`.claude/rules/powershell.md`
  lines 15-20). PowerShell 7+ only. 500-line file cap (line 35). Per-batch change budget of 3
  production + 3 test PowerShell files (line 40) — see section D.3, this bites.
- TypeScript: format → lint → type-check → test (`.claude/rules/typescript.md` lines 13-18). Jest.
  Kebab-case filenames. No new runtime dependencies.
- Coverage: line >= 85% uniformly; branch >= 75% for languages whose tooling measures it. PowerShell
  (Pester) is exempt from the branch threshold only (`.claude/rules/quality-tiers.md`,
  "Uniform across all tiers"; `.claude/rules/powershell.md:64`). PowerShell files remain in the
  coverage denominator.
- `quality-tiers.yml` **does not exist** at the repository root. A repository-wide glob for
  `**/quality-tiers.y*ml` returns no files, although `.claude/rules/quality-tiers.md` states the file
  is the source of truth and that an unclassified project fails CI. No tier classification is
  therefore available for either the hooks or the push-down modules. This is unknown, not inferred.
  The uniform thresholds apply regardless of tier, so it does not block this feature; it is recorded
  because a planner may otherwise search for it.

## 2. Question A — destination-side ignore delivery

### A.1 The decisive `.claude/.gitignore` interaction question

The prompt asks two sub-questions and both are now answered from the tree.

**(a) Would a `.claude/.gitignore` file be picked up by `enumerateSourceFiles`? Yes.**

The production adapter is `RealPushDownFileSystem.listFiles`
(`filesystem-adapter.ts:111-144`). It walks with `fs.readdirSync(currentDir, { withFileTypes: true })`
(line 123) and pushes every entry for which `entry.isFile()` is true (lines 133-135). There is no
dotfile filter anywhere in that walk, and no dotfile filter in `enumerateSourceFiles`
(`copilot-customizations-engine.ts:156-175`), which only sorts. The in-memory test fake
(`push-down.test-helpers.ts:93-109`) likewise applies no name filter. A file named `.gitignore`
directly under the bundle's `.claude/` directory would therefore be enumerated with the
source-relative path `.claude/.gitignore` and written to `<destination>/.claude/.gitignore`.

**(b) Would it be excluded by this repository's own ignore rules? No.**

`.gitignore` in this repository is 70 lines. The only patterns that touch `.claude/` are line 21
(`.claude/worktrees`), line 67 (`.claude/agent-memory`) and line 68 (`.claude/state/`). None matches
`.claude/.gitignore`. There is no global `*.gitignore`-style rule and no `!`-negation that would
interact. A `.claude/.gitignore` at the repository root and its mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/.gitignore` would both be ordinary
tracked files.

**(c) Would the byte-parity resource-contract test pick it up? Almost certainly yes — verify before
relying on it.**

`list_scoped_files` (`test_push_down_claude_resource_contracts.py:34-43`) enumerates with
`scoped_path.rglob("*")` and keeps every `path.is_file()`. `pathlib`'s glob does not apply the
`glob` module's hidden-file suppression, so `rglob("*")` matches leading-dot names. On that basis a
repository-root `.claude/.gitignore` becomes a **required byte-identical bundle mirror**, exactly
like every other `.claude/**` file.

This is stated as high confidence rather than verified, for a specific reason: there is currently
**no leaf dotfile anywhere under `.claude/**` in either the repository tree or the bundle tree**
(globs for `.claude/**/.*` and
`extensions/drm-copilot/resources/claude-customizations/.claude/**/.*` both return no files), so no
existing test run demonstrates the behaviour empirically. The plan must include a one-command
empirical confirmation (run the contract test with the new file present and observe that removing
the bundle mirror fails it) before treating the mirror obligation as established.

**(d) The interaction that actually decides against option (i): the pack filter.**

`ExcludingFileSystem.isPackIncluded` (`claude-filesystem-adapter.ts:179-189`) drops any enumerated
path whose source-relative spelling is absent from `publishedPaths` whenever a pack selection is
active. `resolvePublishedPaths` (`claude-customizations.ts:173-197`) builds that set from the
manifests under `pack-manifests/`. A `.claude/.gitignore` that is not listed in a manifest is
therefore **silently dropped from every pack-scoped push-down** while working correctly on an
unscoped one.

The guard that would normally catch this does not cover the path.
`claude-pack-manifest-completeness.test.ts` enumerates only `agents/*.md` (lines 81-87),
`hooks/*.ps1` (88-94), `skills/*/SKILL.md` (95-104), `rules/*.md` (110-115), and a recursive walk of
`lib/**` (120-122), plus a separate bundle-root walk of `config/**` (163-167). A file sitting
directly at `.claude/.gitignore` matches none of those enumerations. The failure would be silent in
CI and would only show up as "the consumer repo that used `--packs` still tracks state files".

This is a solvable problem — add the path to `core.json` and extend the completeness test's
enumeration — but it is real work that must be in the plan, and it is the reason option (i) is not
free. Issue #462 hit precisely this and solved it the same way; see
`claude-config-carriage.test.ts:65-77` ("publishes both config files under a pack-scoped publish —
the R11 proof: a manifest-scoped run must not drop `config/`").

**(e) One unresolved packaging question.** `extensions/drm-copilot/.vscodeignore` (19 lines) does not
mention `.gitignore` and does not exclude `resources/claude-customizations/**`. A precedent for a
leaf dotfile surviving into `resources/` exists:
`extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json` is tracked. Whether `vsce`
packages a file literally named `.gitignore` inside `resources/**` is **unknown** — it was not
verified and cannot be verified without running a package build. Some packaging tools special-case
that filename. If option (i) is selected, the plan must include a `vsce ls`-equivalent check that the
file appears in the package manifest. This risk does not exist for option (ii), whose ignore text is
a string constant compiled into `src/`.

### A.2 Delivery designs

Common requirement, restated so each option is graded against it: **idempotency across repeat
push-downs.** A second push-down must leave the destination's ignore configuration byte-identical to
the state after the first, and must not accumulate duplicate lines.

---

#### Option (i) — ship a payload file `.claude/.gitignore`

Mechanism: add `.claude/.gitignore` to the repository tree and to the bundle. It flows through the
existing copy loop with **no new writer at all**; `copilot-customizations-engine.ts:417` writes it
like any other file.

Content would be scoped to the `.claude/` directory (git applies a nested `.gitignore` relative to
its own directory), e.g. a `state/` entry, plus whatever else the payload's runtime creates.

Destination-state matrix:

| Destination condition | Behaviour |
| --- | --- |
| Absent | Created with the payload bytes. |
| Present, byte-identical | Overwritten with the same bytes. No observable change. |
| Present, contains the entry plus destination-local additions | **Destination's local additions are silently destroyed.** This is a plain overwrite; there is no merge. |
| Present, contains a conflicting entry (e.g. `!state/`) | Overwritten; conflict resolved in the payload's favour, silently. |

Idempotency: achieved trivially and byte-exactly, because the same source bytes are written every
time. This is the strongest property of the option.

Cost: one new payload file plus its bundle mirror; one `core.json` manifest entry; an extension to
`claude-pack-manifest-completeness.test.ts`'s enumeration so the manifest entry is enforced rather
than incidental; empirical confirmation of the parity-test and `vsce` behaviours in A.1(c) and
A.1(e). No new TypeScript module.

Failure modes:
- Silent pack-scoped drop if the manifest entry is forgotten (A.1(d)).
- Silent destruction of a destination's own `.claude/.gitignore` content (row 3 above). Note that
  the repository has already ruled this outcome unacceptable once, for
  `config/orchestration-routing.json` — `claude-routing-merge.ts:5-8` exists specifically because
  "a destination workspace may already carry its own routing document with locally added routes.
  Overwriting it would silently discard them."
- `vsce` packaging behaviour for a file named `.gitignore` is unverified.
- **Scope limitation, and it may be disqualifying:** a nested `.gitignore` can only express patterns
  relative to `.claude/`. It cannot ignore anything outside that directory. If the payload ever needs
  a destination ignore entry outside `.claude/` — `.codex/state/` is already ignored at
  `.gitignore:69` in this repository, and `artifacts/orchestration/` is a runtime output directory —
  option (i) cannot express it and a second mechanism would be needed anyway.

---

#### Option (ii) — merge an entry into the destination repository-root `.gitignore`

Mechanism: net-new capability. A `GitignoreMergeFileSystem`-style decorator cannot be used as-is,
because the engine never writes a path called `<destination>/.gitignore` and a decorator only
observes writes the engine performs. Two viable shapes:

- **(ii-a) Post-copy step in the Claude entry point.** After `enginePushDown(...)` returns
  (`claude-customizations.ts:304-314`), call a new pure merge function and write through the
  injected `fs`. Pure text logic lives in a new module; the entry point does the one write.
- **(ii-b) Synthetic payload path.** Add a bundle file at a path that maps to `.gitignore` at the
  destination and let a decorator intercept it. This requires either a third root folder or a
  path-rewriting step, both of which perturb the enumeration-order contract that
  `renderPushDownSummary` and the config-carriage tests pin
  (`claude-config-carriage.test.ts:79`, "appends config after .claude in the enumeration-order
  contract"). Not recommended.

Take (ii-a) as the concrete form. Merge rule, by direct analogy with
`claude-routing-merge.ts:21-31`:

| Destination condition | Behaviour |
| --- | --- |
| Absent | Write a new file containing a marked block: a sentinel comment line, the managed entries, and a closing sentinel. |
| Present, no managed block, no matching entry | Append the marked block, preserving all existing content and its trailing-newline state. |
| Present, managed block present and identical | No write, or an identical rewrite. Byte-stable. |
| Present, managed block present but stale | Replace the block's contents in place; content outside the block is untouched. |
| Present, entry already exists outside the managed block (hand-added `.claude/state/`) | Do not duplicate. Either treat the existing line as satisfying the requirement and write nothing, or add the block without the already-present entry. Either choice must be pinned by a test; duplicate-line accumulation is the classic idempotency bug here. |
| Present, conflicting negation (`!.claude/state/`) further down the file | Git's last-match-wins semantics mean the negation still wins. The writer cannot fix this without reordering the destination's file, which it must not do. Correct behaviour is to leave it and surface it, not to silently reorder. |

Idempotency: achieved by the sentinel-delimited block plus the "already present outside the block"
rule. It is a design property that must be tested, not a free consequence of the mechanism — which
is the opposite of option (i).

Cost: one new `src/lib/push-down/*.ts` module (pure text merge, testable with no I/O), a call site in
`claude-customizations.ts`, a new entry in the `jest.config.cjs` `coverageThreshold` map (see D.5),
and new tests. Roughly the same size as `claude-routing-merge.ts` (311 lines) but likely smaller,
since `.gitignore` is line-oriented text rather than JSON with key-order preservation.

Failure modes:
- The write targets a path outside both payload roots, so it is invisible to the summary artifact's
  `files` list unless deliberately added. Whether it should appear there is a design decision:
  adding it changes `PushDownSummary` shape and the artifact contract; omitting it means a delivered
  file is unreported.
- `validateDestination` (`copilot-customizations-engine.ts:185-205`) only guarantees the destination
  is an existing directory that is not the source root. It does **not** guarantee the destination is
  a git repository. Writing a `.gitignore` into a non-repository directory is harmless but pointless;
  the writer should either not care or check for `.git`, and that choice must be explicit.
- A destination `.gitignore` with CRLF line endings will be rewritten to LF by
  `RealPushDownFileSystem.writeTextFile` (`filesystem-adapter.ts:188-194`), producing a whole-file
  diff in the consumer repository on the first push. This is a real and non-obvious consequence and
  should be called out in the spec, because it is exactly the kind of change a consumer notices.
- Unlike option (i), the ignore text is not visible to anyone reading the payload; it is a string
  constant in extension source. Discoverability is worse.

---

#### Option (iii) — other mechanisms considered and rejected

- **Do the exclusion at the source instead of the destination.** Nothing needs a `.gitignore` at the
  destination if the payload never delivers a state file. But the state file is created at the
  destination *at runtime by the hooks*, not delivered by the push-down, so a source-side exclusion
  cannot help. `EXCLUDED_RELATIVE_PATHS` is irrelevant here. Rejected on mechanism.
- **`.git/info/exclude` at the destination.** Achieves the ignore without touching a tracked file,
  and is trivially idempotent. Rejected because it is not committed, so it does not propagate to any
  other clone of the consumer repository — which is precisely the failure the issue describes ("a
  fresh clone of the consumer repository can carry a tracked batch-budget session-state file").
- **Relocate the state outside the repository entirely** (e.g. under the OS temp or user-state
  directory). This removes the need for any destination ignore file. Rejected as out of scope: it
  changes the state-file contract that the deny message, the tests, and the Codex sibling hooks all
  reference, and the epic's leading indicator is explicitly phrased as "a fresh clone of a consumer
  repository that received a push-down contains no tracked batch-budget session-state file" —
  which an ignore entry satisfies directly. Worth recording as a possible future simplification.

### A.3 Recommendation for A

**Recommend option (ii-a): a post-copy destination `.gitignore` merge with a sentinel-delimited
managed block.**

Justification, in order of weight:

1. Option (i)'s plain-overwrite semantics are the exact behaviour this repository already rejected
   for `config/orchestration-routing.json`. Adopting them for a file that consumer repositories are
   *more* likely to have edited by hand than a routing document is inconsistent with an established,
   documented decision (`claude-routing-merge.ts:14-31`).
2. Option (i) cannot express any ignore entry outside `.claude/`. The repository's own `.gitignore`
   already carries two runtime-state entries (`.claude/state/` at line 68 and `.codex/state/` at
   line 69), which is direct evidence that the destination-side ignore obligation is not confined to
   one directory.
3. Option (ii) has one unverified external dependency fewer: no `vsce` dotfile-packaging question,
   no `pathlib` dotfile-enumeration question, no pack-manifest-completeness gap.

The cost of the recommendation is real and should not be understated: it is net-new TypeScript, it
needs its own coverage-threshold entry, and its idempotency is a tested property rather than a free
one. That matches the epic's own C3 banding for this feature.

A defensible alternative exists. If the plan authors judge that consumer repositories will not carry
their own `.claude/.gitignore` and want the smallest possible change, option (i) is workable provided
all four of its failure modes are closed (manifest entry, completeness-test enumeration, parity-test
empirical confirmation, `vsce` packaging check). It is recorded here so the decision is made on
evidence rather than by omission.

### A.4 Existing tests and the exact seam a new writer is tested through

Push-down engine and service-call tests, with line counts:

| Path | Lines | Style |
| --- | --- | --- |
| `extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts` | 244 | In-memory fake |
| `extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts` | 198 | In-memory fake |
| `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts` | 288 | In-memory fake |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 460 | In-memory fake + one real-disk three-copy pin |
| `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` | 306 | In-memory fake |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | In-memory fake; has the idempotency precedent at lines 389-391 |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | 273 | **Real filesystem, deliberately** |
| `extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts` | 212 | Adapter unit tests |
| `extensions/drm-copilot/test/lib/push-down/push-down.test-helpers.ts` | 176 | Shared fake |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 224 | Shared seeding helpers |

Convention: **injected in-memory fake filesystem, no real I/O, no temp files.** The fake is
`InMemoryPushDownFileSystem` in `push-down.test-helpers.ts:43-143`, constructed via
`buildInMemoryFileSystem(seedFiles, seedDirs)` (lines 152-165). It records `writtenPaths` and
`ensuredDirs` for assertions. Determinism for timestamps comes from `fixedClock(isoInstant)`
(lines 173-176). Two suites deviate deliberately and say so:
`claude-pack-manifest-completeness.test.ts` (real bundle + real manifests, rationale at lines 5-40)
and the "three-copy pin" in `claude-config-carriage.test.ts` (rationale at lines 44-48).

**The exact seam a new writer is tested through: the `PushDownFileSystem` interface
(`filesystem-adapter.ts:29-53`), supplied as the `fs` option on `ClaudePushDownOptions`
(`claude-customizations.ts:203`), instantiated in tests as `InMemoryPushDownFileSystem`.** A merge
writer is exercised by seeding a destination `.gitignore` into the fake, calling
`pushDownCustomizations`, and reading the destination back with `fs.readTextFile(...)`. The
idempotency assertion has an exact template to copy: `claude-config-carriage.test.ts:241-263`
("is byte-stable across a second push" — publish, read, publish, read, `expect(afterSecond).toBe(afterFirst)`).

The pure merge function should additionally be unit-tested directly with no filesystem at all, the
way `mergeRoutingDocuments` (`claude-routing-merge.ts:191-219`) is exported separately from the
decorator that calls it.

## 3. Question B — session identity

### B.1 What identifiers are actually available to a PreToolUse hook here

**Environment.** `$env:CLAUDE_SESSION_ID` is read at PowerShell-hook line 248 and Python-hook
line 245. The variable is not ambient: it is provisioned by `.claude/hooks/persist-session-id.ps1`,
a `SessionStart` hook registered at `.claude/settings.json:84`. That script's own documentation
(lines 11-17) states the mechanism precisely: when `CLAUDE_ENV_FILE` is set it appends
`CLAUDE_SESSION_ID=<id>` to that file, and — this is the load-bearing sentence — "Variables persisted
there are exported to **subsequent Bash tool commands** in the session". When `CLAUDE_ENV_FILE` is
unset it instead writes the bare id to `.claude/state/current-session-id` (line 17, path composed at
line 150).

Two consequences follow. First, the `CLAUDE_ENV_FILE` channel exports into Bash-tool commands; a
`PreToolUse` command hook is spawned by Claude Code directly, not through the Bash tool, so there is
no evidence it inherits that variable. That is the most likely reason the `'default'` fallback fires
in practice, and it is consistent with the observed
`.claude/state/python-batch-budget.default.json`. Second, the fallback file
`.claude/state/current-session-id` **does not exist in this worktree** (a glob of `.claude/state/**`
returns only the python budget file), so the `CLAUDE_ENV_FILE`-unset branch did not run either.

**Payload.** `Resolve-ClaudeHookToolInput` (`HookPayload.psm1:439-482`) already returns the parsed
envelope root on an `Envelope` member (lines 476-481), and the module documents why: "enforce-epic-
invocation-origin.ps1 needs the envelope root (`agent_type`) alongside the nested tool_input"
(lines 446-449). `Get-ClaudeHookEnvelopeValue` (lines 304-328) is exported (line 489) and reads a
named key off the envelope StrictMode-safely. So **reading a root-level envelope field requires no
new API**, and it is established that PreToolUse envelopes in this runtime do carry root-level fields
beyond `tool_input` (`enforce-epic-invocation-origin.ps1:18-22` documents `agent_type` as one).

**Does the PreToolUse envelope carry a session id? Unknown for the Claude runtime; established for
the Codex runtime.** No `.claude/**` file reads `session_id` from a PreToolUse envelope, and no test
fixture under `tests/scripts/claude-hooks/` constructs one containing `session_id`. The only proven
`session_id`-bearing envelope on the Claude side is the **SessionStart** payload consumed by
`persist-session-id.ps1:55-56`. This is reported as unknown rather than inferred; a one-off
diagnostic capture of a live PreToolUse envelope is the cheapest way to settle it and should be a
plan precondition.

The Codex side of this repository has already solved the identical problem, and it is the strongest
available precedent:

`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`

```powershell
223  try {
224      # Transport and mapping come from the shared module. session_id is still
225      # required because the batch counter is keyed by it.
226      $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw ([Console]::In.ReadToEnd()) -HookName 'enforce-powershell-batch-budget' -RequireSessionId
227      $sessionId = ([string]$payload.session_id) -replace '[^A-Za-z0-9._-]', '_'
228      $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
```

`ConvertFrom-CodexPreToolUsePayload` (`.codex/hooks/codex-pretooluse-file-mapping.ps1`) documents
`-RequireSessionId` at lines 92-95 — "Only the batch-budget hooks need this, because they key
per-session state by `session_id`" — and enforces it at lines 139-141:
`throw "$HookName hook input is missing session_id."` Three things are already settled by that code:
the batch-budget hooks are the *only* hooks that need a session id; the correct posture on an absent
one is **fail closed**; and a session id used in a filename must be **sanitized** with
`-replace '[^A-Za-z0-9._-]', '_'` before path composition.

Note one nuance so it is not misread: the Codex hook still declares `[string] $SessionId = 'default'`
as a function parameter default (line 157). That default is inert, because the entry point always
passes an explicit sanitized id or throws first. The same shape is available on the Claude side: the
parameter default can stay for testability provided the entry point never falls back to it.

### B.2 Options for the unresolved-session-id case

| Option | Mechanism | Observable consequence on a legitimate second session | Cost / failure modes |
| --- | --- | --- | --- |
| **B-1. Fail closed** (Codex parity) | Deny with an explicit reason naming the missing identifier. On the Claude side this must be an emitted deny decision at exit 0, not a `throw` — `HookPayload.psm1:30-33` states that exit code 1 is non-blocking for PreToolUse, "so a throwing hook is itself a fail-open". | The second session is correct in the sense that it is never charged for the first session's work — but it cannot write **any** PowerShell or Python file at all until the identifier is available. If PreToolUse envelopes do not in fact carry `session_id` (B.1, unknown), this converts both hooks into unconditional denials of all PowerShell and Python edits. | Highest blast radius of any option. Must not be selected before the B.1 unknown is resolved empirically. |
| **B-2. Derive a stable per-process/per-worktree id** | Compose from material the hook can read without a session id: the parent process id, or a hash of the resolved worktree root, or both. | Two concurrent sessions in the *same* worktree still collide if the id is worktree-only. A parent-process-id component separates them, but a PreToolUse hook is a fresh short-lived `pwsh` process per invocation, so its own PID is useless and its parent PID is the Claude Code process — which does separate sessions, if two sessions are two processes. Whether they are is unknown. | Cheap. Fails open on collision rather than denying. Correctness depends on an unverified assumption about the process model. |
| **B-3. Fail open** (drop the budget when unidentified) | Treat an unresolved id as "no budget enforcement". | The second session is never falsely denied. But the budget stops enforcing anything in exactly the case that is currently most common, which removes the control the hooks exist to provide. | Cheapest, and a silent regression of the gate. Not recommended. |
| **B-4. TTL / reset on age** | Add a persisted timestamp; discard state older than a threshold. | The second session inherits the first session's counter until the TTL expires, then gets a clean one. Bounded harm rather than unbounded harm. The threshold is arbitrary and any value is wrong for some session. | Requires a schema addition (`ConvertTo-*BatchBudgetState` lines 61-82 must learn the new key or drop it), a clock seam for determinism (`.claude/rules/general-unit-test.md` "Determinism Infrastructure" forbids reading wall-clock time directly in code under test), and a new tested branch. Does **not** fix same-instant concurrent collision. |

### B.3 Recommendation for B

**Recommend a two-part resolution: B-1 conditional on the B.1 unknown, with B-4 as an independent
addition.**

1. **Resolve the unknown first.** Determine empirically whether a Claude Code PreToolUse envelope
   carries a session identifier. This is a plan precondition, not an implementation task.
2. **If it does:** read it from `$payload.Envelope` via the already-exported
   `Get-ClaudeHookEnvelopeValue`, sanitize it with `-replace '[^A-Za-z0-9._-]', '_'` exactly as the
   Codex hook does at line 227, and prefer it over `$env:CLAUDE_SESSION_ID`. Retain the environment
   variable as a secondary source. Fail closed only when **both** are unavailable, emitting a deny
   decision at exit 0 in the repository's existing deny shape (which
   `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:77` and `:89` already pin for
   both hooks).
3. **If it does not:** do not adopt B-1, because it would deny all PowerShell and Python edits.
   Fall back to B-2 keyed on the resolved worktree root (which section C establishes independently),
   and accept the documented residual: two concurrent sessions in the same worktree still share a
   counter.
4. **Independently, adopt B-4.** The absence of any reset is a defect in its own right — the hook's
   own deny message tells the operator to delete the file by hand (PowerShell hook line 139). A TTL
   bounds the damage regardless of which identity strategy is chosen, and it is the only one of the
   four options that helps a session that already inherited a poisoned counter. It requires a
   `Clock`-style seam and an extension to `ConvertTo-*BatchBudgetState`.

## 4. Question C — worktree scoping

### C.1 Deterministic worktree-root resolution, without Python and without `scripts/dev_tools`

**There is no existing helper under `.claude/lib/**` for this.** A search for `worktree` across
`.claude/lib` returns only two unrelated status-constant lines in
`.claude/lib/bash/parallel-common.sh` (lines 28 and 40). Nothing under `.claude/lib/**` resolves a
repository or worktree root. There is therefore nothing to reuse, and the honest answer to "do not
propose a new one if an existing one fits" is that none exists.

**Two in-repo precedents do exist, and they agree on the technique:**

- `.claude/hooks/enforce-completion-helpers.ps1:128` —
  `Join-Path $PSScriptRoot '../../config/orchestration-routing.json'`. A payload-root-relative path
  derived from `$PSScriptRoot`, with no CWD dependency and no external process.
- The Codex batch-budget hook, line 228 —
  `$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`. This is the same idea
  written as an explicit two-level ascent from `<root>/.codex/hooks/` to `<root>`. For a Claude hook
  at `<root>/.claude/hooks/`, the identical two-level ascent yields `<root>`.

This technique satisfies every stated constraint: no Python, no `scripts/dev_tools`, no `git`
invocation, no network, deterministic, and correct inside a git worktree (a worktree contains its own
`.claude/hooks/` directory, so `$PSScriptRoot` is already worktree-local). It is also strictly better
than the current `(Get-Location).Path` default, which is correct only because `.claude/settings.json`
happens to invoke the hooks with a relative `-File` path from the workspace root.

**Recommendation:** change the `$Root` parameter default on `Invoke-*BatchBudgetHook` from
`(Get-Location).Path` to a `$PSScriptRoot`-derived ascent, matching the Codex hook. Because it is a
parameter default, every existing test that passes `-Root '/repo'` explicitly is unaffected.

### C.2 Path canonicalization

`Resolve-Path` is used nowhere in `.claude/hooks/**` and should not be introduced. It throws on a
non-existent path, and a `PreToolUse` hook by definition sees paths that may not exist yet (a `Write`
creating a new file). `[System.IO.Path]::GetFullPath` is also unused across the hooks.

The established repository idiom for path containment in this directory is
`-replace '\\', '/'` then `.TrimEnd('/')` then `StartsWith(..., [System.StringComparison]::Ordinal)`.
Representative sites: `enforce-epic-worktree-removal-gate.ps1:181` and `:190`;
`enforce-parallel-worktree-removal-gate.ps1:104` and `:113`;
`enforce-parallel-cohort-barrier.ps1:105`; `enforce-completion-helpers.ps1:92-98`;
`enforce-orchestration-preimplementation-gate-modes.ps1:148`. `enforce-evidence-locations.ps1:61-62`
carries the explanatory comment: "Normalize separators so both absolute Windows paths and relative
POSIX paths match."

Two path shapes must both be handled, and the existing code already faces this: `file_path` in a
tool payload is sometimes absolute (the observed state file records an absolute temp path) and
sometimes relative (every existing test uses `scripts/tool.ps1`, `tests/scripts/example.Tests.ps1`).
A containment rule must classify a relative path as in-scope and an absolute path as in-scope only
when it is prefixed by the resolved worktree root. Windows case-insensitivity of drive letters and
directory names is a real edge case here and should be pinned by a test.

### C.3 What to do with an out-of-worktree path

| Treatment | Budget semantics | Consequence |
| --- | --- | --- |
| **Discard** — do not record it, allow the write | The path consumes no slot and never appears in `prodFiles`/`testFiles`. The counter tracks only work in this worktree. | Matches the issue's stated expectation ("a path from another worktree is discarded rather than counted"). Removes the observed defect exactly: the temp-directory path in the live state file would never have been recorded. Risk: an agent could evade the budget entirely by writing through absolute paths outside the worktree — but such writes are, by construction, not changes to this worktree's source, which is what the budget governs. |
| **Ignore** — record it but exclude it from the cap arithmetic | Requires a second list or a flag in the state schema. | Strictly more complexity for no additional signal. The recorded value is not actionable. Not recommended. |
| **Deny** — reject the write | An out-of-worktree write is blocked outright. | Wrong scope. The batch-budget hook exists to cap *how much* is changed per batch, not to police *where* writes land; `enforce-evidence-locations.ps1` is the hook that polices location. Denying here would also break legitimate scratchpad writes — the very case visible in the observed state file — and would be a behaviour change well outside issue #596. |

**Recommendation: discard.** It is the treatment the issue asks for, it is the minimal change, and it
requires no state-schema change. Note the interaction with B-4: discarding does not clean an
*already-poisoned* state file, because the offending entry is already persisted. Either the TTL
(B-4) or a rehydrate-time filter in `ConvertTo-*BatchBudgetState` (lines 61-82) is needed for that.
A rehydrate-time filter is the cheaper of the two for this specific problem and is worth considering
alongside B-4 rather than instead of it.

## 5. Question D — cross-cutting constraints

### D.1 The resource-contract assertion, exactly

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
**lines 101-126**. Supporting definitions: `REPO_ROOT` at line 16 (`parents[3]` of the test file),
`BUNDLED_ROOT` at lines 17-19, `SCOPED_ROOTS = (Path(".claude"),)` at line 20, `list_scoped_files` at
lines 34-43, `_is_agent_memory_path` at lines 71-98.

What it covers: every file found by `(<root>/.claude).rglob("*")` for which `is_file()` is true, at
both the repository root and the bundle root. For each such repository-relative path it asserts
(a) the path exists in the bundle list (lines 120-122) and (b) the two files' UTF-8 text is equal
(lines 123-126).

What it excludes: exactly two things — `Path(".claude/settings.local.json")` and any path under
`.claude/agent-memory/` (line 116, via `_is_agent_memory_path`).

What it does **not** exclude, which matters here: it applies no dotfile filter, no extension filter,
and no git-tracking check. It enumerates the working tree as it finds it. Two direct consequences:

1. A new `.claude/.gitignore` (option (i)) falls inside the parity scope and requires a byte-identical
   bundle mirror.
2. **The test is already exposed to runtime-created files under `.claude/`.** Nothing in it skips
   `.claude/state/`. If `.claude/state/powershell-batch-budget.<id>.json` is present on disk when the
   test runs from the repository root, the test fails with `Repo file missing from bundle:
   .claude/state/...`. That file is present in this worktree right now. The same exposure exists for
   `.claude/worktrees/**` (git-ignored at `.gitignore:21`) when the test is run from a root that has
   worktrees checked out beneath it. This is a pre-existing fragility, not something Feature B
   introduces, but it is adjacent enough that the plan should record it and decide whether to file a
   follow-up rather than absorb an unrelated fix.

### D.2 File-size posture against the 500-line cap

| File | Lines | Headroom |
| --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 284 | 216 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 281 | 219 |
| bundle mirror, PowerShell hook | 284 | 216 |
| bundle mirror, Python hook | 281 | 219 |
| `.claude/lib/hook-payload/HookPayload.psm1` | 494 | **6** |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 315 | 185 |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | 448 | 52 |
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 311 | 189 |
| `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` | 303 | 197 |
| `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` | 201 | 299 |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | 288 | 212 |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | 276 | 224 |

Assessment:

- **The two hooks fit.** 216 and 219 lines of headroom is ample for a session-id resolution helper, a
  worktree-containment predicate, an optional timestamp field, and their comment-based help.
  Extraction into a shared `.claude/lib/**` module is **not required by the line cap.**
- **`HookPayload.psm1` has 6 lines of headroom and must not be extended.** Any change that would add
  a function there forces a file split, and a split adds a new `.claude/lib/**` file that needs a
  bundle mirror, a `core.json` manifest entry, and a `claude-pack-manifest-completeness.test.ts`
  match (its `lib/**` walk at lines 120-122 is recursive and unfiltered, so a new lib file **is**
  caught by that test — unlike a `.claude/.gitignore`). Prefer composing the already-exported
  `Get-ClaudeHookEnvelopeValue` from the hooks over adding anything to this module.
- **`copilot-customizations-engine.ts` has 52 lines of headroom** and is the one TypeScript file that
  could not absorb a writer even if the I/O-boundary argument did not already exclude it.
- If duplication between the two hooks becomes objectionable (the session-id and containment logic
  would be written twice, as `prodCap`/`testCap`/decision logic already is), extraction to a new
  `.claude/lib/batch-budget/*.psm1` is a legitimate design choice — but it is a *reusability* choice,
  not a *size* obligation, and it triples the touched-file count (module + bundle mirror + manifest
  entry). Given the change-budget constraint in D.3, the smaller-footprint choice is to duplicate.

### D.3 The change budget will bind, and the hook being fixed is the one that enforces it

`.claude/rules/powershell.md:40`: "Per-batch cap in all modes: at most 3 production files and 3 test
files unless an explicit override has been approved."

The `.claude/**` files this feature must edit are the four enumerated in section 6 below. All four
are `.ps1` files and none matches the hook's test-file predicate
(`(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$`, PowerShell hook line 127), so **all four count against the
3-file production cap.** The two Pester test files add 2 against the 3-file test cap, which is fine.

This is not a theoretical problem. The hook is registered on `Write|Edit` and will deny the fourth
production `.ps1` edit in the same session. The plan must handle it explicitly by one of:

- splitting the four production edits across two batches (delete the state file between them, which
  is what the deny message itself instructs), or
- setting `CLAUDE_POWERSHELL_BUDGET_PROD` with approved scope before the session starts
  (PowerShell hook lines 255-257), or
- writing `{"prodCap": N}` into the state file (documented at hook lines 24-27).

If a shared `.claude/lib/batch-budget/*.psm1` module is introduced, the production count rises to six
and the constraint becomes correspondingly tighter. This reinforces the D.2 recommendation against
extraction.

### D.4 Existing tests for both hooks

| Path | Lines | Notes |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | 288 | Dot-sources the hook (lines 10-12) so the entry-point guard at hook line 272 suppresses execution. Injects `TestPathExists`/`EnsureDirectory`/`ReadState`/`WriteState` (lines 180-215). Asserts the composed state-file name at line 190. Clears all four environment variables in `AfterEach` (lines 24-29). Has an `entry-point dispatch` context (lines 247-287) covering exit code and deny-only emission. |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | 276 | Structurally identical; same seams, same `-SessionId 'session-a' -Root '/repo'` convention (lines 130-209). |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | 171 | Cross-hook deny-shape contract over 15 hooks; covers `enforce-python-batch-budget.ps1` (line 77) and `enforce-powershell-batch-budget.ps1` (line 89). Any change to the deny envelope must keep this green. |
| `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` | 200 | Relevant background for the session-id channel; not expected to change. |
| `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` | — | Codex siblings, out of scope per the epic's non-goals. |

No temp files are used anywhere in these suites, consistent with
`.claude/rules/general-unit-test.md` ("Creation and use of temporary files in tests is strictly
prohibited"). Every filesystem interaction goes through an injected scriptblock.

**Coverage posture is not determinable from static reading.** No coverage report for these two hooks
exists in the tree that I located, and the Pester coverage run could not be executed in this session
(the Bash tool is disabled and this is a research-only run). It is unknown, not inferred. A baseline
Pester coverage run for both hooks should be the plan's first evidence artifact, written to
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/`.

### D.5 Coverage thresholds

- **PowerShell:** line >= 85%. **The branch-coverage exemption applies**: Pester measures command
  (instruction) and line coverage only, so no branch gate exists for PowerShell
  (`.claude/rules/powershell.md:64`; `.claude/rules/quality-tiers.md`, "Rationale"). Both hook files
  remain in the coverage denominator; they may not be excluded.
- **TypeScript:** line >= 85% and branch >= 75%. `extensions/drm-copilot/jest.config.cjs` uses
  `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` (line 17) and a `coverageThreshold` map
  with **no `global` key** (lines 25-259), i.e. per-file gates only.
  **Any new production file under `src/lib/push-down/` must be added to that map** with
  `lines: 85, branches: 75`. The file's own comments establish this as the expected practice — see
  the entries at lines 185-193 (`parallel-state-records.ts`) and 227-235
  (`plan-gate-observability.ts`), both of which record that a newly split-out or newly added
  production file must sit behind the same per-file gate. Note that most existing push-down modules,
  including `claude-routing-merge.ts`, are *not* in the map; that is pre-existing and is not a licence
  to omit a new one.
- Coverage regression on changed lines is a blocking finding in both languages.

## 6. Numeric Derivation Evidence

One enumeration in this document is intended to be load-bearing for a `spec.md` acceptance criterion:
the set of `.claude/**` runtime files that carry the shared-counter defect and must therefore be
edited and mirrored. It is derived twice below, by two distinct search strategies, and the member
sets are compared.

### Claim under derivation

The `.claude/**` batch-budget hook family affected by the `'default'` session-id fallback comprises
exactly four files: the two repository hooks and their two bundle mirrors.

- **Complete Family:** every file under either `.claude/**` payload tree (the repository tree at
  `<root>/.claude/**` and the bundle tree at
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`) that implements a
  batch-budget PreToolUse gate keyed by a session identifier.
- **Exhaustive Search Scope:** the entire repository working tree, unrestricted by directory or file
  extension. Both derivations searched from the repository root with no path filter, so neither could
  miss a member by scoping.
- **Inclusion Rules:** the file must (a) live under a `.claude/` directory in either the repository
  tree or the Claude bundle tree, and (b) contain the session-id-keyed batch-budget implementation,
  evidenced by both the `'default'` fallback and the `<language>-batch-budget.$SessionId.json` state
  path composition.
- **Exclusion Rules:** exclude the Codex surface (`.codex/hooks/**` at the repository root and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/**`) — it is a
  different runtime payload and the epic's Non-Goals section explicitly scopes this epic to "only the
  `.claude/**` runtime surface, its bundle mirror, and the push-down code that publishes it".
  Exclude documentation and evidence files under `docs/**`, which quote the source text but are not
  the implementation.

#### Primary derivation

- **Primary Search Strategy or Query Expression:** regular-expression content search for the
  literal session-id fallback assignment in either of its two spellings, repository-wide with no path
  or type filter: `\$SessionId = 'default'|\$sessionId = 'default'`. This targets the *defect
  expression* directly and matches both the parameter-default spelling and the entry-point-assignment
  spelling, so it covers both syntactic forms in which the defect appears.
- **Primary Member Set** (after applying the exclusion rules to the 20 raw hits):
  1. `.claude/hooks/enforce-powershell-batch-budget.ps1` (hits at lines 157, 250)
  2. `.claude/hooks/enforce-python-batch-budget.ps1` (hits at lines 154, 247)
  3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` (hits at lines 157, 250)
  4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` (hits at lines 154, 247)
- **Primary Count:** 4.
- Excluded by rule, recorded for auditability: `.codex/hooks/enforce-powershell-batch-budget.ps1:157`,
  `.codex/hooks/enforce-python-batch-budget.ps1:155`,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1:157`,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1:155`
  (Codex surface, out of scope); and six `docs/**` files (`docs/features/potential/promoted/...`,
  `docs/features/active/...-596/spec.md`, `docs/features/active/...-596/issue.md`,
  `docs/features/completed/...-501/.../remediation-plan.2026-08-22T03-20.md`) which are prose, not
  implementation.

#### Cross-check derivation

- **Cross-check Search Strategy or Query Expression:** a structurally independent search on a
  different code construct — the state-path composition rather than the fallback assignment —
  again repository-wide with no path or type filter:
  `batch-budget\.\$SessionId\.json`. This matches the interpolated filename expression that keys the
  state file by session id. It shares no literal token with the primary expression other than the
  variable name, and it would find a hypothetical member that had already removed the `'default'`
  fallback but still composed a session-keyed path — a member the primary expression would miss.
- **Cross-check Member Set** (after applying the exclusion rules to the 12 raw hits):
  1. `.claude/hooks/enforce-powershell-batch-budget.ps1` (hit at line 193)
  2. `.claude/hooks/enforce-python-batch-budget.ps1` (hit at line 190)
  3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` (hit at line 193)
  4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` (hit at line 190)
- **Cross-check Count:** 4.
- Excluded by rule, recorded for auditability: the four Codex-surface files
  (`.codex/hooks/enforce-python-batch-budget.ps1:193`,
  `.codex/hooks/enforce-powershell-batch-budget.ps1:195`, and their two bundle mirrors at lines 193
  and 195); and four `docs/**` files, including one coverage-baseline artifact at
  `docs/features/completed/2026-08-25-...-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md:242`
  which embeds the source line as report text.

#### Member-set Comparison

Normalizing both member sets to repository-relative forward-slash paths and sorting:

```
.claude/hooks/enforce-powershell-batch-budget.ps1
.claude/hooks/enforce-python-batch-budget.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
```

The primary and cross-check normalized member sets are **identical**: same four members, no member
present in one and absent from the other. Both counts are 4 and agree. The two derivations used
distinct query expressions targeting distinct code constructs (fallback assignment versus state-path
composition), and both searched the unrestricted repository tree, so the exhaustive-scope requirement
is met for the declared family. The enumeration is therefore suitable for use in a `spec.md`
acceptance criterion.

## 7. Proposed design summary (feeds `spec.md`)

### 7.1 Files to change

`.claude/**` runtime surface (each requires a byte-identical bundle mirror under
`extensions/drm-copilot/resources/claude-customizations/`, per D.1):

1. `.claude/hooks/enforce-powershell-batch-budget.ps1` + mirror
2. `.claude/hooks/enforce-python-batch-budget.ps1` + mirror

TypeScript push-down surface (no bundle mirror; `src/**` is not part of the payload):

3. `extensions/drm-copilot/src/lib/push-down/<new-module>.ts` — pure `.gitignore` merge logic
4. `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` — post-copy call site
5. `extensions/drm-copilot/jest.config.cjs` — per-file coverage threshold entry for item 3

Tests:

6. `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`
8. `extensions/drm-copilot/test/lib/push-down/<new-module>.test.ts`
9. `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` **or** a new sibling
   suite, for the end-to-end delivery and second-push byte-stability assertions

If option (i) is selected instead of (ii), replace items 3-5 and 8-9 with: a new `.claude/.gitignore`
payload file plus its mirror, a `core.json` manifest entry, and an extension to
`claude-pack-manifest-completeness.test.ts`'s enumeration.

### 7.2 State model and transitions (hooks)

Session identity resolution, in order, with the first non-empty value winning:

1. envelope `session_id` via `Get-ClaudeHookEnvelopeValue -Envelope $payload.Envelope`
   (conditional on the B.1 unknown resolving positively)
2. `$env:CLAUDE_SESSION_ID`
3. unresolved → the strategy selected per B.3 (fail closed if step 1 is available; otherwise a
   worktree-derived id)

The resolved value is sanitized with `-replace '[^A-Za-z0-9._-]', '_'` before path composition, per
the Codex precedent at line 227.

Recorded-path admission, per file-path candidate:

1. normalize separators (`-replace '\\', '/'`) — already present at lines 122 and 183
2. resolve the worktree root from `$PSScriptRoot` (C.1)
3. if the candidate is absolute and not prefixed by the worktree root → **discard** (C.3): do not
   record, do not consume a slot, allow the write
4. otherwise proceed to the existing classify/dedupe/cap logic unchanged

State schema, if B-4 is adopted: add one timestamp key, extend `ConvertTo-*BatchBudgetState`
(lines 61-82) to carry it, and inject a clock seam so tests remain deterministic per
`.claude/rules/general-unit-test.md`.

### 7.3 Invariants to preserve

- The deny envelope shape pinned by `PreToolUseSchema.Contract.Tests.ps1` for both hooks.
- Exit code 0 on every path, including denials. Never `throw` from a Claude PreToolUse hook: per
  `HookPayload.psm1:30-33` a non-zero exit is non-blocking and is therefore a fail-open.
- The deny-only emission convention: an allow decision writes nothing to stdout.
- The `-SessionId` / `-Root` / four-scriptblock parameter surface of `Invoke-*BatchBudgetHook`, so the
  existing Pester suites continue to exercise the same seams.
- Byte-identical bundle mirrors for every `.claude/**` edit.
- The push-down enumeration-order contract (`.claude` then `config`) and the summary-artifact schema.

## 8. Test strategy (no test code written)

PowerShell (Pester 5.x, via the PoshQC MCP runner):

- Session-id resolution: envelope-supplied id preferred over the environment variable; environment
  variable used when the envelope carries none; the sanitization rule maps a hostile id to a safe
  filename component; the unresolved case produces exactly the decision selected in B.3.
- State-path composition: the composed filename reflects the resolved and sanitized id. Assert
  through the existing `WriteState` seam, following the precedent at
  `enforce-powershell-batch-budget.Tests.ps1:190`.
- Worktree containment: a relative path is admitted; an absolute path under the resolved root is
  admitted; an absolute path outside the root is discarded and consumes no slot; a Windows path with
  differing case is treated per the decided rule.
- Rehydrate behaviour: a persisted state file containing an out-of-worktree entry does not charge
  that entry against the cap.
- TTL, if adopted: state older than the threshold yields a fresh counter; state within it is
  retained. Drive the clock through an injected seam; no `Start-Sleep`, no wall-clock read.
- Regression guard: the existing deny-shape contract test remains green for both hooks.
- No temp files; every filesystem touch goes through the four existing scriptblock seams.

TypeScript (Jest):

- Pure merge function, no filesystem: absent destination; present without the entry; present with the
  entry inside the managed block; present with the entry outside the managed block (must not
  duplicate); present with a stale managed block; present with a trailing-newline variation.
- End-to-end through `pushDownCustomizations` with `InMemoryPushDownFileSystem`: the destination
  receives the ignore configuration on a plain publish and on a pack-scoped publish.
- Idempotency: publish, read, publish, read, assert byte equality — copy the template at
  `claude-config-carriage.test.ts:241-263`.
- Negative: a destination that is not a git repository, and a destination `.gitignore` that cannot be
  read, each producing the decided behaviour rather than an unhandled throw.
- Determinism: `fixedClock` for any timestamped output; no `Date.now()`.

Python (pytest): no new tests. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is
run unchanged as the mirror gate.

Baseline evidence, written to
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/`: a Pester
coverage run for both hooks and a Jest coverage run for the push-down module set, captured **before**
any edit, so the "no regression on changed lines" gate has something to compare against. D.4 records
that the current coverage posture is unknown.

## 9. Automation Feasibility

Most of this work is fully automatable. Three items are not, or are only partially so, and each is
named explicitly below with the smallest automatable substitute.

**9.1 Verifying a real push-down into an external consumer repository — not fully automatable.**
End-to-end proof requires a second, genuinely external git repository, a packaged and installed
`.vsix`, an invocation of the extension's push-down command from a VS Code session with that
workspace open, and an inspection of the resulting `.gitignore` and `git status` output. Installing a
`.vsix` and driving a VS Code command palette is human interaction that this repository's automation
does not perform. Prior evidence in this repository shows a related trap: a repo-side `resources/`
edit does not change what a push-down writes until the extension is rebuilt and reinstalled, so a
naive "run the push-down and look" check can validate stale bytes.
**Smallest automatable substitute:** a Jest suite that drives `pushDownClaudeCustomizationsServiceCall`
against `InMemoryPushDownFileSystem` with a seeded destination, asserts the destination ignore
configuration after the first publish, publishes a second time, and asserts byte equality. This
covers the entire code path from the service-call entry point down, and differs from the real thing
only in the adapter implementation — which has its own direct unit tests in
`filesystem-adapter.test.ts` (212 lines). Combined, the two give the same coverage as the manual run
for everything except packaging.

**9.2 Confirming `vsce` packages a file named `.gitignore` inside `resources/**` — partially
automatable, and only relevant if option (i) is selected.** The question is whether the packaging tool
special-cases that filename. It cannot be settled by reading `.vscodeignore` (19 lines, no relevant
entry). **Smallest automatable substitute:** run the packaging tool's dry-run file listing
(`vsce ls` or equivalent) and grep the output for the path. This is a single non-interactive command
and produces a durable evidence artifact. If option (ii) is selected, this item disappears entirely —
which is one of the three reasons option (ii) is recommended.

**9.3 Determining whether a live Claude Code PreToolUse envelope carries a session identifier —
automatable, but requires a live session.** No static read of this repository settles it (B.1), and
no fixture asserts it. **Smallest automatable substitute:** during a normal agent session, have one
PreToolUse hook append its raw payload to a file under the feature's `evidence/other/` directory,
trigger one `Write`, and inspect the captured envelope. This is a single-run diagnostic, not a
permanent change, and it converts the B.1 unknown into a fact before the implementation branch is
chosen. It should be a plan precondition, because the choice between B-1 and B-2 depends entirely on
its outcome and choosing wrongly would make both hooks deny every PowerShell and Python edit.

**9.4 Everything else is automatable.** Hook unit tests, push-down unit tests, the byte-parity
contract test, the pack-manifest completeness test, the deny-shape contract test, PoshQC
format/analyze/test, and Prettier/ESLint/tsc/Jest all run non-interactively. The one operational
wrinkle is not an automation gap but a sequencing one: the batch-budget hook being repaired will deny
the fourth production `.ps1` edit in a single session (D.3), so the plan must batch the edits or set
an approved cap override. That is a planning obligation, not a human-interaction requirement.

## 10. Open questions for the spec author

1. Which delivery option — (i) payload `.claude/.gitignore` or (ii) destination-root merge? Section
   A.3 recommends (ii) and states the cost of each. This is the single largest scope determinant.
2. Does a Claude Code PreToolUse envelope carry a session identifier (B.1)? The answer selects
   between B-1 (fail closed) and B-2 (derived id), and B-1 is unsafe if the answer is no.
3. Is the TTL (B-4) in scope for this feature, or deferred? It is an independent defect ("the hook
   has no TTL... its own deny message instructs the operator to delete the file by hand") and adding
   it expands the state schema.
4. Should the pre-existing exposure of the byte-parity test to runtime-created `.claude/state/**` and
   `.claude/worktrees/**` files (D.1, consequence 2) be fixed here or filed as a follow-up? It is
   adjacent, real, and currently latent in this worktree.
5. If option (ii) is selected: should the delivered `.gitignore` appear in the push-down summary
   artifact's `files` list? Including it changes the `PushDownSummary` contract; omitting it means a
   delivered file goes unreported.
