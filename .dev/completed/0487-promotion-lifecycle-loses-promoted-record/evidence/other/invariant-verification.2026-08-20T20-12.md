# Invariant Verification [P6-T2], [P6-T3], [P6-T5], [P6-T6]

Timestamp: 2026-08-20T20-12

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

---

## Invariant Results [P6-T2]

| Invariant | Verdict | File and location | Verifying test or command |
| --- | --- | --- | --- |
| **INV-1** — discovery contract unchanged | **PASS** | `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` `findPotentialFile` (`:98-130`) and `scripts/dev_tools/new_active_feature_folder_io.py` `find_potential_file` (`:35-55`) | `git diff --stat ffa03095 -- <both io files>` returns **no output**: neither file was modified. Both retain the two-directory scan order (`docs/features/potential` then `docs/features/potential/promoted`), the `promoted/` fallback, `_`-to-`-` normalization, the `.md` filter, the `EXCLUDED_POTENTIAL_NAMES` exclusion set, and the name-descending tie-break. The unmodified discovery cases at `io.test.ts:26-76` pass in the P2-T6 run. |
| **INV-2** — unpromoted sources still move | **PASS** | `flow.ts:362-366` and `new_active_feature_folder_flow.py:303-306` (the `else` arm of each placement site) | TypeScript: `flow.promoted-disposition.test.ts` › `takes the move branch for a sibling path that is only a string prefix of the promoted root` (passes before AND after the fix), plus the unmodified `flow.test.ts:254-286` case asserting `expect(fs.files.has(potential)).toBe(false)` and `Moved potential file to <path>`. Python: `test_new_active_feature_folder_part5.py::test_create_feature_folder_moves_unpromoted_potential`, plus the entire unmodified `_part2.py` and `_part3.py` suites, all green in the P4-T8 run. |
| **INV-3** — `issue.md` bytes unchanged for the same input | **PASS** | `flow.ts:289-299` and `:362-372`; `new_active_feature_folder_flow.py:235-244` and `:303-311` | Only the operation that PLACES the file at `<targetDir>/issue.md` changed (`move` → `copyFile` on the promoted branch). The destination content is identical either way, and the subsequent read-back plus `upsertWorkModeMarker` / `upsert_work_mode_marker` write is byte-for-byte unchanged in both languages. Verified by the content assertions in `flow.promoted-disposition.test.ts` (`toContain("- Work Mode: full-bug")`, `toContain("- Work Mode: minor-audit")`), by `promotion-lifecycle-sequence.test.ts` (`toContain("- Work Mode: full-feature")`), and by the pre-existing unmodified assertions at `flow.test.ts:254-286` and in `test_new_active_feature_folder.py` (which asserts the seeded `user-story.md` content and `#63` propagation) — all passing unmodified. |
| **INV-4** — no interface growth | **PASS** | `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts` `FolderFileSystem` (`:91-125`), `scripts/dev_tools/new_active_feature_folder_models.py` `FileSystem` (`:53`), `extensions/drm-copilot/src/lib/potential-to-issue/promotion-filesystem.ts` `PotentialFileSystem` (`:27-39`) | `git diff --stat ffa03095 -- models.ts new_active_feature_folder_models.py promotion-filesystem.ts promotion.ts gh-client.ts` returns **no output**. No seam gained a member. `copyFile` was already declared on `FolderFileSystem` at `models.ts:99` and `copy_file` on the Python protocol at `new_active_feature_folder_models.py:53`; the fix consumes existing members rather than adding any. |
| **INV-6** — byte parity between the two languages | **PASS** | `flow.ts` vs `new_active_feature_folder_flow.py`, all four sites | Recorded in full in `evidence/other/ts-python-parity-inspection.2026-08-20T20-08.md` (P6-T1). The disposition predicate, the single-decision placement, both placement branches, and both emission branches match. Emitted wording is byte-identical: `Copied potential file to <path>` / `Moved potential file to <path>`. The receipt post-condition is deliberately TypeScript-only because the Python CLI emits no receipt; that asymmetry is recorded and justified in the parity artifact. |
| **INV-7** — MCP surface unchanged | **PASS** | `extensions/drm-copilot/src/mcp-tools.ts` `toMcpToolResult` (`:88-108`), `toFailureToolResult` (`:110-123`) | `git diff --stat ffa03095 -- extensions/drm-copilot/src/mcp-tools.ts` returns **no output**: the file is unmodified. Both functions keep their current shape. No MCP tool signature, no `artifact_type`, and no orchestrator-state field changed. The new post-condition surfaces through the existing thrown-`Error` path that `toFailureToolResult` already renders as `ok: false`, so it required no MCP-surface change. |
| **INV-8** — no temporary files and no `gh` in tests | **PASS** | The five test files touched or created in Phases 1 and 4 | A grep for `tmpdir\|tmp_path\|mkdtemp\|TemporaryDirectory\|NamedTemporary\|os.tmpdir` across all five files returned **no matches** (exit 1). A grep for `\bgh\b\|spawnSync\|child_process\|subprocess` returned only two doc-comment mentions and one `FakeGhClient` construction (`promotion-lifecycle-sequence.test.ts:229`) — an injected in-memory fake, not a real `gh` invocation. Every test uses a `Map`-backed / `dict`-backed in-memory filesystem, a fixed `nowProvider` / `now_provider`, and a fake `codeLauncher` / `FakeCodeLauncher`. No test touches the real `docs/features/` tree. |

---

## Changed-File Set [P6-T3]

Command: `git diff --stat ffa03095c9a338695be47974ebe150be245ee3b3`

EXIT_CODE: 0

`ffa03095c9a338695be47974ebe150be245ee3b3` is the branch HEAD at the start of this execution (recorded in `evidence/baseline/baseline-git-state.2026-08-20T18-54.md`), so this diff isolates exactly what this plan execution changed.

### Production files — 4, exactly as planned

| File | Change |
| --- | --- |
| `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | +60/-? (Phase 2) |
| `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | +32/-? (Phase 3) |
| `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | +16/-? (Phase 3) |
| `scripts/dev_tools/new_active_feature_folder_flow.py` | +51/-? (Phase 4) |

### Test files — 8, exactly as planned

| File | Change |
| --- | --- |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` | +1 (P1-T3) |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` | new, +165 (P1-T1, P1-T2, P1-T4) |
| `extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts` | new, +260 (P1-T5) |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | +126 (P1-T6) |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | +90 (P1-T7) |
| `tests/scripts/dev_tools/test_new_active_feature_folder.py` | +2/-2 (P1-T8) |
| `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | +1/-1 (P1-T9) |
| `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` | new, +122 (P4-T5, P4-T6) |

### Documentation files named in Phase 5 — 4

| File | Change |
| --- | --- |
| `docs/engineering/Feature Playbook.md` | +1/-1 (P5-T1) |
| `docs/features/potential/README.md` | +1/-1 (P5-T2) |
| `docs/research/2026-07-09-potential-entries-duplicate-audit.md` | +19 appended (P5-T3) |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | +6 (P5-T4) |

### Process-tracking files — 2

| File | Change | Note |
| --- | --- | --- |
| `docs/features/active/.../plan.2026-08-17T15-01.md` | checkbox state only | Task check-offs written to disk as each task's verification passed, per the execution protocol. |
| `docs/features/active/.../spec.md` | checkbox state only | AC check-offs, per the `acceptance-criteria-tracking` skill. No criterion text was altered. |

### Evidence artifacts — 20 under `evidence/`

All reside under `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/<kind>/`. Audited independently at P7-T13.

**No unexpected file is present.** The changed-file set is exactly the four production files, the eight test files, the four Phase 5 documentation files, the two process-tracking files, and the evidence artifacts. Nothing outside that set was touched.

---

## No Hand-Repair or Backfill of Lost Promoted Records [P6-T5]

**Confirmed: no hand-repair or backfill of any previously lost promoted record was performed.**

Specifically, `docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md` **remains absent**, as required.

Verification:

```
$ ls docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md
ls: cannot access 'docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
EXIT=2
```

A directory listing of `docs/features/potential/promoted/` confirms 29 entries, none of which is `2026-08-17-promotion-lifecycle-loses-promoted-record.md`. The record was destroyed by the very defect this change fixes, during the run that created this feature folder. Its absence is **retained evidence** of the defect and is deliberately not repaired: research decision 5 records that retroactive repair of previously lost promoted records is out of scope, and the plan forbids recreating this file.

The diff confirms no file was added anywhere under `docs/features/potential/promoted/`.

---

## No Policy Files Modified [P6-T6]

**Confirmed: no file under `.claude/rules/` or `.github/instructions/` was modified.**

Verification:

```
$ git diff --stat ffa03095c9a338695be47974ebe150be245ee3b3 -- .claude/rules/ .github/instructions/
(no output)
EXIT=0
```

The command returned no output, meaning zero files under either path differ from the pre-execution branch HEAD. This satisfies the hard constraint in the `policy-compliance-order` skill ("Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`") and `CLAUDE.md` ("These files are the canonical policy source. Do not modify them.").

The one `.claude/` file this change does modify is `.claude/skills/feature-promotion-lifecycle/SKILL.md` (P5-T4). That is a **skill** file, not a policy file, and it lies outside both prohibited paths.
