# Research: promotion receipt destination verification (Issue #623, item 2)

- Issue: #623 (consolidated scope: item 2 only)
- Branch: `bug/promotion-receipt-destination-unverified-623`
- Work mode: full-bug
- Research timestamp: 2026-09-29T19-15
- Out of scope: item 1 (PoshQC zero coverage, #527) and item 3 (bug-route tool-name mismatch, #405)

All line numbers below were read from the current worktree tree. "Verified" means the statement was confirmed by reading the cited file. "Unverified" marks statements that could not be confirmed with the available tools.

## 1. Current State Analysis

### 1.1 Dispatch chain (TypeScript MCP path)

| Step | File | Lines | Behavior |
| --- | --- | --- | --- |
| MCP dispatch | `extensions/drm-copilot/src/mcp-tools.ts` | 228-230 | `case "potential_to_issue"` -> `toMcpToolResult(await handlePotentialToIssue(...))` |
| Failure shaping | `extensions/drm-copilot/src/mcp-tools.ts` | 141-154, 345-346 | Any thrown error becomes `ok: false` with `summary = error.message` |
| Success shaping | `extensions/drm-copilot/src/mcp-tools.ts` | 106-139 | `ok: true` unconditionally; `destination_path` copied from `result.destinationPath` (119-121) |
| Handler | `extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts` | 28-34 | `resolvePotentialToIssueToolInput(rawInput)` then `service.potentialToIssue(input)` |
| Input resolution | `extensions/drm-copilot/src/mcp-tool-inputs-potential-to-issue.ts` | 30-60 | `workspace_root` required (no `process.cwd()` fallback for MCP); a relative `potential_path` is joined to `workspace_root`; an absolute one is kept unchanged (`workflow-command-arguments.ts:314-324`). `workspace_root` itself is not resolved or existence-checked (`workflow-command-arguments.ts:294-308`). |
| Service method | `extensions/drm-copilot/src/repo-automation-service.ts` | 258-276 | Delegates to `potentialToIssueServiceCall` with no injected filesystem (production uses `RealPotentialFileSystem`) |
| Service-call helper | `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 163-238 | Resolves repo slug first (170-174, fails closed), hoists one filesystem instance (189), runs `promotePotential` (191-199), throws `Command exited with code <n>.` plus messages on non-zero outcome (204-208), **asserts the destination exists** (219-226), builds the receipt (228-237) with `destinationPath: normalizeGeneratedPath(outcome.destination)` |
| Workflow | `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` | 291-443 | Validates, creates the issue, rewrites metadata (414-428), then moves the file (433-442) |
| Filesystem seam | `extensions/drm-copilot/src/lib/potential-to-issue/promotion-filesystem.ts` | 27-40 (interface), 49-91 (real) | `exists` already exists (31, 67-69: `fs.existsSync`); `move` is `mkdirSync(dirname(dest), {recursive:true})` then `renameSync(src, dest)` (87-90) |

### 1.2 How `destination_path` is built

1. `promotion.ts:433-436`: `promotedDir = posixJoin(workspacePath, "docs/features/potential/promoted")`, where `workspacePath` is the service input `workspaceRoot` (`promotion.ts:307`). The promoted directory is derived from `workspace_root`, **not** from the directory of the potential file.
2. `promotion.ts:438`: `destPath = posixJoin(promotedDir, posixBasename(resolved))`. `posixJoin` (166-170) converts backslashes to forward slashes.
3. `promotion.ts:439-442`: `filesystem.move(resolved, destPath)`, emits `Moved potential file to promoted folder: <destPath>`, returns `{ exitCode: 0, messages, destination: destPath }`. There is no existence check inside the workflow.
4. `potential-to-issue-service-call.ts:219-226`: `if (outcome.destination !== undefined && !fileSystem.exists(outcome.destination)) throw new Error("potential_to_issue reported a path that does not exist: <destination>")`.
5. `potential-to-issue-service-call.ts:233-235`: `destinationPath = normalizeGeneratedPath(outcome.destination)` (`repo-automation-service-support.ts:70-72`, backslash-to-slash only).
6. `mcp-tools.ts:119-121`: `destination_path` in the MCP receipt.

### 1.3 Key finding: the receipt post-condition already exists

The consolidation comment cites `promotion.ts:437-442` and `promotion-filesystem.ts:89` and states that nothing checks existence after the rename. That is accurate for those two files, but the service-call layer already enforces the post-condition (`potential-to-issue-service-call.ts:215-226`). The guard was added by issue #487 (`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/spec.md`, "Receipt post-condition contract (normative)", lines 230-241; AC-6 at line 364, checked). The spec deliberately placed it in the service-call layer rather than in `promotion.ts` to avoid a divergence from the Python parity source (spec lines 240, 181).

Consequently, in the current tree an MCP `potential_to_issue` call cannot return `ok: true` with a `destination_path` that `fs.existsSync` reports absent at the moment the receipt is built. What the current tree does not have:

- A check at the point of the move in the workflow layer (`promotion.ts`) or in the Python parity source (`scripts/dev_tools/potential_to_issue.py`).
- When the service-call guard fires, the thrown message names only the absent path. The emitted messages (including the created issue URL) are not included, so the caller is not told that a GitHub issue was already created.

### 1.4 Existing tests and fakes

| File | Lines | Relevant content |
| --- | --- | --- |
| `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` | 171 lines | `FakePotentialFileSystem` (19-58): Map-backed; `exists` = `files.has`; `move` throws on missing source, records `moves` |
| `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts` | 468 lines | Success case asserts `outcome.destination` and `fs.moves` (107-154); failure case asserts no move (193-194) |
| `extensions/drm-copilot/test/lib/potential-to-issue/promotion.matrix.test.ts` | 128 lines | Matrix scenarios |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | 397 lines | Post-condition cases (332-397): `throws when the promoted destination is absent` asserts `toThrow("potential_to_issue")` and `toThrow(DESTINATION)`; positive case |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts` | 149 lines | `BlockedPathPotentialFileSystem` (94-109): `exists(blockedPath)` always false |
| `extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts` | 260 lines | #487 sequenced `promotePotential` -> `createActiveFolder` retention test |
| `tests/scripts/dev_tools/test_potential_to_issue.py` | 1076 lines | Python `FakeFileSystem` (fake `move` at 51-58); already over the 500-line limit |
| `tests/scripts/dev_tools/test_potential_to_issue_branches.py` | 408 lines | Own `FakeFileSystem(mod.FileSystem)` (22-62) and `FakeGhClient` (65-105) |
| `tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py` | 430 lines | Own fake `move` at 180 |

`RealPotentialFileSystem` (TS) and `RealFileSystem` (Python) have no direct unit tests (grep for `RealPotentialFileSystem` under `extensions/drm-copilot/test` and `RealFileSystem` in `tests/scripts/dev_tools/test_potential_to_issue*.py` returned no matches). `promotion-filesystem.ts` and `promotion.ts` have no per-file entry in `extensions/drm-copilot/jest.config.cjs` `coverageThreshold` (entries for the cluster exist only for `gh-client.ts`, `repo-slug.ts`, and `potential-to-issue-service-call.ts`, lines 295-306).

## 2. Plausible Causes of the Missing File

| # | Candidate cause | Evidence | Assessment |
| --- | --- | --- | --- |
| C1 | The #487 lifecycle defect: `new_active_feature_folder` moved (not copied) the promoted record into `<active>/issue.md`. | The originating TaskMaster report (#554) was created 2026-08-14 per the GitHub page fetched during this research (WebFetch summary; the local `issue.md` line 24 records 2026-09-02, which matches the #623 creation date, not #554). #487's controlled reproduction (spec lines 50-57) shows exactly the reported signature: source absent, promoted record absent, receipt naming the promoted path. #487's fix (copy for promoted sources, `new-active-feature-folder/flow.ts:290`, `:363`; message `Copied potential file to ...` at `:356`, `:374`) and the receipt guard were completed on 2026-08-20 (#487 QA artifacts), after the TaskMaster observation. #487 observations 1-3 had the same "intermittent" appearance because probes were taken at inconsistent times relative to the second call (`#487 issue.md` lines 74-87). | **Supported as the most likely cause; not proven for the TaskMaster instance.** The TaskMaster report carries no tool-call sequence or extension version (WebFetch summary), so attribution cannot be confirmed. |
| C2 | Forward-slash path from `posixJoin` not resolving on Windows. | Node `fs` on Windows accepts forward slashes; the service-call guard calls `existsSync` on the same forward-slash string that `renameSync` used, so both refer to the same location. | **Not supported.** |
| C3 | `workspace_root` differs from the tree containing an absolute `potential_path` (for example a main checkout versus a worktree). | Code-verified: `promotedDir` is derived from `workspace_root` (`promotion.ts:433-436`), and an absolute `potential_path` is not required to lie under `workspace_root` (`workflow-command-arguments.ts:320-322`). The file is then moved into the other tree's `promoted/`; the receipt path exists there, so the service-call guard passes, while the caller's own tree shows neither file. | **Code-consistent, not evidenced.** It would produce "source gone, not in my promoted folder", but `destination_path` itself would exist. No report shows mismatched roots. A containment guard is a candidate follow-up, not part of this fix. |
| C4 | `workspace_root` given in MSYS form (`/c/Users/...`) on Windows. | `nodePath.resolve` would map it to `C:\c\Users\...`. In the current tree `resolveRepoSlug` runs `gh repo view` with `cwd: workspaceRoot` (`repo-slug.ts:169-172`) and fails closed on a non-existent directory before any move. | **Not supported for the current tree.** Whether the pre-#525 tree used by TaskMaster had this guard is unverified. |
| C5 | `renameSync` returning success without the destination existing. | libuv `uv_fs_rename` on Windows is a single `MoveFileExW` call; a cross-volume rename fails with an error (propagated as `ok: false`) and leaves the source in place. No mechanism was found by which a normal return leaves no destination. | **Not supported.** |
| C6 | An external actor (sync client, antivirus, concurrent agent, cleanup) removes the file after the rename. | No evidence either way. A check between the rename and the receipt covers only the window before the receipt; nothing can cover removal after it. | **Unverified; cannot be excluded.** |

## 3. Python Promotion Path Verdict

**Verdict: Yes, the Python path has the same gap.**

- `scripts/dev_tools/potential_to_issue.py:273-275`: `RealFileSystem.move` = `dest.parent.mkdir(parents=True, exist_ok=True)` then `shutil.move(str(src), str(dest))`.
- `scripts/dev_tools/potential_to_issue.py:548-554`: `ensure_dir(promoted_dir)`, `filesystem.move(resolved, dest_path)`, emits `Moved potential file to promoted folder: {dest_path}`, returns `PromotionOutcome(exit_code=0, ..., destination=dest_path)`. No existence check follows the move.
- `main()` (`:621-635`) exits with `outcome.exit_code`, so the CLI reports success (exit 0 and the "Moved" line) whether or not the destination exists.

Exposure (verified): the Python path is not reached from MCP (`repo-automation-service.ts:265-275` calls the in-process TypeScript port). It is reachable through the Poetry script `dev.potential-to-issue` (`pyproject.toml:78`) and the VS Code task "Dev: 2 Promote Potential to GitHub Issue" (`.vscode/tasks.json:886-900`). Agent shell invocation is blocked by `.claude/hooks/enforce-promotion-mcp-only.ps1:93-98`. The Python module is not bundled: no `potential_to_issue*` file exists under `extensions/drm-copilot/resources/`.

Parity constraint: `promotion.ts:12-16` declares that every `PromotionError` message, emitted line, and decision branch is byte-identical to the Python source. A Python-only change would break that declared parity, so a Python fix must be mirrored in `promotion.ts`.

## 4. Bundled Mirrors and Parity Pins

- No in-scope source file has a tracked copy under `extensions/drm-copilot/resources/`. The only `resources/` matches for `potential_to_issue` are skills, agents, hooks, config, and agent memory (27 files), none of which contain the workflow code.
- The MCP bundle is emitted to `out/mcp-server.js` (`extensions/drm-copilot/esbuild-mcp-server.cjs:28-32`), and `out` is gitignored (`.gitignore:1`), so no tracked build artifact needs updating.
- No automated test pins `promotion.ts` to `potential_to_issue.py` byte for byte. Parity is declared in comments and was verified by inspection in #487 (`evidence/other/ts-python-parity-inspection.2026-08-20T20-08.md`).
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` step 4b (lines 74-77) and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md` (lines 71-76) already describe the #487 behavior. The recommended fix does not change them.

## 5. Candidate Approaches and Recommendation

### Approach A (recommended): verify at the move in both workflow layers and fail with a non-zero outcome

- In `promotePotential` (`promotion.ts`), after `filesystem.move(resolved, destPath)`: if `!filesystem.exists(destPath)`, emit `Promoted file missing after move: <destPath>` and return `{ exitCode: 1, messages }` with no `destination`. Otherwise emit the existing "Moved" line and return as today.
- Mirror the same branch and message in `promote_potential` (`potential_to_issue.py`), returning `PromotionOutcome(exit_code=1, messages=messages)`.
- Keep the service-call guard (`potential-to-issue-service-call.ts:215-226`) unchanged as the receipt-level contract from #487.

Rationale:

- Both paths that perform the move then verify it, which is what issue #623's Expected Behavior asks for, and the declared byte parity is preserved because both languages change identically. #487's objection to a workflow-layer check (INV-6) applied to a TypeScript-only check; it does not apply when Python is changed the same way.
- A non-zero outcome, rather than a thrown `PromotionError`, uses the existing failure path (`promotion.ts:387-396`; `potential-to-issue-service-call.ts:204-208`; Python `main` `:635`). The service call then throws `Command exited with code 1.` followed by all emitted messages, which include the created issue URL and the missing-path line. The caller learns both that the file is missing and that an issue now exists. A thrown `PromotionError` would lose the issue URL.
- The check uses the existing `exists` member on both seams, so no interface grows (`PotentialFileSystem.exists`, Python `FileSystem.exists`) and the check is testable with Map-backed fakes.

Source preservation: do not attempt restoration. A successful `renameSync`/`shutil.move` removes the source; if the destination is then absent there is nothing to copy back, and a failed rename already leaves the source in place and raises. The failure message should name the destination path. Adding the resolved source path to the message is optional; the "Updated potential file with issue metadata: <resolved>" line already records it when metadata was written.

Error text (proposed, identical in both languages): `Promoted file missing after move: <dest>`. In Python, `<dest>` renders with host separators, which matches how the existing "Moved" line already differs between the languages.

### Rejected alternatives

- **B. No production change (treat as already fixed by #487).** Leaves the Python gap the task defines as in scope, and leaves the TypeScript workflow without a check at the move. Kept only as the fallback if the planner decides the Python CLI is out of scope.
- **C. Check inside the real filesystem adapters (`RealPotentialFileSystem.move`, `RealFileSystem.move`).** Workflow fakes do not reach it. Testing it would require temp files (prohibited) or module-level `node:fs`/`shutil` mocking, and it adds a third layer of the same check.
- **D. Throw `PromotionError` from the workflow.** The created issue URL would be dropped from the failure surface (`potential-to-issue-service-call.ts:204-208` includes messages only on the non-zero-exit path).

## 6. Behavior Semantics

- Success: the move returns and `exists(dest)` is true -> unchanged behavior, including the "Moved" line, `exitCode 0`, `destination` set, and an `ok: true` receipt.
- Missing destination after the move: emit `Promoted file missing after move: <dest>`, `exitCode 1`, no `destination`. MCP: `ok: false`, and `summary` contains `Command exited with code 1.` plus every emitted line. Python CLI: lines printed, `SystemExit(1)`.
- Move raises (for example cross-volume or permission): unchanged. The error propagates, the source stays in place, and MCP returns `ok: false`.
- Ordering: the check runs after the move and before the "Moved" line is emitted, so the "Moved" line appears only when the file exists. The service-call guard still runs after a successful workflow return.
- Known residual: the GitHub issue has already been created when the check fails. Reordering the move ahead of issue creation would change parity-bound control flow and is out of scope.

## 7. Required File Changes

### Production

| File | Current lines | Change |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` | 443 | Add post-move `exists` branch at 439-442 (about 6-8 lines; stays under 500) |
| `scripts/dev_tools/potential_to_issue.py` | 639 | Mirror the branch at 551-554 (about 4-6 lines) |

**File-size constraint (planner decision required):** `potential_to_issue.py` is already over the 500-line limit (tracked as #406; `docs/features/potential/promoted/2026-07-24-potential-to-issue-python-files-oversized.md`), and #487 recorded that it must not be worsened. Any added line conflicts with that. Option that offsets the growth: move `FileSystem`/`RealFileSystem` (`:194-275`, about 82 lines) into a new `scripts/dev_tools/potential_to_issue_filesystem.py` and re-export both names from `potential_to_issue.py`. This mirrors the TypeScript `promotion-filesystem.ts` extraction. The re-export is required because three test files subclass `mod.FileSystem` (for example `test_potential_to_issue_branches.py:22`). The result is roughly 560 lines, a net reduction but still over 500. Full compliance remains #406's scope. If the planner rejects the extraction, the alternative is to record an explicit, bounded exception naming #406.

### Tests (mirrored `test/` / `tests/` trees; no temp files; injected fakes only)

| File | Change |
| --- | --- |
| `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` (171) | Add a `DroppingMovePotentialFileSystem` fake whose `move` removes the source without writing the destination |
| New: `extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts` | Fail-before case: exit code 1, `destination` undefined, last message `Promoted file missing after move: /workspace/docs/features/potential/promoted/sample.md`, messages include the `Created:` URL line, and no "Moved" line. Positive control: the normal fake still returns exit 0. `promotion.test.ts` is at 468 lines and should not receive these cases. |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` (397) | Add: the dropping fake yields a throw containing `Command exited with code 1.` and the missing-path line (which also carries the issue URL). **Adjust the existing `throws when the promoted destination is absent` case (335-371):** with `BlockedPathPotentialFileSystem`, the new workflow check fires first, and its message does not contain `potential_to_issue`, so the `toThrow("potential_to_issue")` assertion at 359 would fail and the service-call guard's true branch would become unreachable. |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts` (149) | Replace or add a fake that reports the blocked path present on its first `exists` query and absent afterwards, so the service-call guard (219-226) keeps its true-branch coverage |
| `tests/scripts/dev_tools/test_potential_to_issue_branches.py` (408) or a new `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py` | Python mirror: a dropping-move fake subclassing `mod.FileSystem`; assert `exit_code == 1`, `destination is None`, and the message; add a positive control. A new file is preferable to avoid pushing the branches file toward 500. Do not add to `test_potential_to_issue.py` (1076 lines). |
| If the extraction is adopted: new `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` is **not** required for behavior, but `RealFileSystem` would then be the new module's only content, and its coverage relies on the uniform threshold. Coverage is unverified; measure it before deciding whether a `monkeypatch`-based test of `RealFileSystem.move` is needed. | |

Jest threshold map: add per-file entries for `./src/lib/potential-to-issue/promotion.ts` (changed file) to `extensions/drm-copilot/jest.config.cjs` only if current coverage meets 85/75. Current per-file coverage is unverified; the implementer must read `coverage/lcov.info` before adding the entry.

## 8. Testing Implications

- Fail-before: the new TypeScript and Python dropping-move cases must fail before the production change (today the workflow returns exit 0 with a destination). Record the failing runs under `<FEATURE>/evidence/regression-testing/` and the passing runs under `<FEATURE>/evidence/qa-gates/`.
- Regression guard: the existing `promotion.test.ts` success case (107-154), the `promotion-lifecycle-sequence.test.ts` sequence test, and the #487 service-call positive case must pass unmodified.
- Determinism: fakes only, fixed gh outputs, and no clock, network, or temp files.

## 9. Toolchain Commands

TypeScript, from `extensions/drm-copilot/` (`package.json:202-212`):

1. `npm run format` (prettier over `src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`)
2. `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`)
3. `npm run typecheck` (`tsc -p ./ --noEmit`)
4. Architecture stage: no `.dependency-cruiser*` exists anywhere in the worktree (verified by glob). Record absence as #487 did (`final-ts-architecture.2026-08-20T20-23.md`).
5. `npm run test:coverage` (wraps `node run-jest.cjs --coverage ...`; do not call bare `npx jest`)

Python, from the repository root (as used in #487 final QA):

1. `poetry run black .`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `poetry run pytest --cov --cov-branch --cov-report=term-missing` (bare `--cov`; a `--cov=<file>.py` form measures nothing)

`quality-tiers.yml` is absent at the repository root (verified by glob), so the tier-dependent gates have no classification source; the uniform gates apply.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed as a `spec.md` acceptance criterion by this research. Line counts above are descriptive (obtained by a line-count grep) and are not proposed as acceptance-criterion assertions. If the spec author adds a numeric AC (for example, "exactly N existence checks"), a full derivation record is required first.

## Automation Feasibility

Fully automatable with no human interaction. All changes are source edits plus unit tests against injected Map-backed fakes; no test invokes `gh`, the network, or the real filesystem. A live end-to-end re-run of `potential_to_issue` is not required. It would create a real GitHub issue, so it should remain optional supplementary evidence only.

## Open Items for the Planner

1. Decide the `potential_to_issue.py` file-size handling (extraction offset versus a recorded exception under #406).
2. Decide whether a `workspace_root` containment guard (cause C3) should be filed as a separate potential entry. It is not evidenced and not part of this fix.
3. The TaskMaster #554 date discrepancy (local `issue.md` says 2026-09-02; the GitHub page summary says 2026-08-14) should be corrected in `issue.md` if confirmed. The WebFetch summary is produced by a secondary model and is marked unverified.
