# TypeScript / Python Parity Inspection [P6-T1]

Timestamp: 2026-08-20T20-08

Side-by-side inspection of `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` against `scripts/dev_tools/new_active_feature_folder_flow.py`. Line numbers are post-change.

## Per-Site Table

| Site | TypeScript (`flow.ts`) | Python (`new_active_feature_folder_flow.py`) | Match |
| --- | --- | --- | --- |
| **Containment predicate** | `isPromotedPotentialSource(potentialPath, workspacePath)` at `:460`, delegating to the pre-existing `isRelativeTo(child, root)` against `joinPosix(workspacePath, "docs/features/potential/promoted")`. `isRelativeTo` matches on `child === root \|\| child.startsWith(`${root}/`)`. | `_is_promoted_potential_source(potential_file, workspace_path)` at `:43`, using `potential_file.relative_to(promoted_root)` in a `try`/`except ValueError`, against `workspace_path / "docs" / "features" / "potential" / "promoted"`. | **Yes.** Both require a `<root>/` boundary; neither is prefix-only. The Python `try`/`except ValueError` form follows the pattern already used for the auto-resolve check in the same file, and the TypeScript `isRelativeTo` JSDoc states it "mirrors Python `Path.relative_to` used as a containment check". |
| **Disposition decision** | `const retainsPotentialSource = potentialFile !== null && isPromotedPotentialSource(potentialFile, workspacePath);` at `:178-180`, computed once immediately after the potential file is resolved and its content read. | `retains_potential_source = potential_file is not None and (_is_promoted_potential_source(potential_file, workspace_path))` at `:141-142`, in the same position relative to the resolution and content read. | **Yes.** Decided once from the RESOLVED source path in both languages, never from the requested feature name, and never recomputed at a later site. |
| **Placement — minor-audit branch** | `:289-293`: `if (retainsPotentialSource) { filesystem.copyFile(potentialFile, potentialIssuePath); } else { filesystem.move(potentialFile, potentialIssuePath); }` (was the unconditional `filesystem.move` at the pre-change `:283`) | `:235-238`: `if retains_potential_source: filesystem.copy_file(...)` / `else: filesystem.move(...)` (was the unconditional `filesystem.move` at the pre-change `:206`) | **Yes.** Same branch, same operations. The read-back and `upsertWorkModeMarker` / `upsert_work_mode_marker` write that follow are unchanged in both languages. |
| **Placement — full branch** | `:362-366`: same conditional (was the unconditional `filesystem.move` at the pre-change `:346`) | `:303-306`: same conditional (was the unconditional `filesystem.move` at the pre-change `:266`) | **Yes.** |
| **Emission — minor-audit branch** | `:355-357`: `retainsPotentialSource ? \`Copied potential file to ${potentialIssuePath}\` : \`Moved potential file to ${potentialIssuePath}\`` | `:297-300`: `if retains_potential_source: print(f"Copied potential file to {potential_issue_path}")` / `else: print(f"Moved potential file to {potential_issue_path}")` | **Yes.** Byte-identical wording. Both read the same `retainsPotentialSource` / `retains_potential_source` flag that the placement above used, rather than recomputing the disposition, so the reported verb cannot disagree with the operation performed. |
| **Emission — full branch** | `:373-375`: same conditional expression | `:312-315`: same conditional | **Yes.** Byte-identical wording. |

## Emitted-Line Wording (INV-6 byte parity)

Both languages emit exactly one of these two strings per run, for the same input:

- Copy branch: `Copied potential file to <path>`
- Move branch: `Moved potential file to <path>`

The move-branch string is unchanged from the pre-change behavior in both languages, so no existing consumer of that line is affected. The copy-branch string is new in both languages and is introduced with identical wording.

Test coverage of the wording in both arms and both languages:

| Language | Copy arm | Move arm |
| --- | --- | --- |
| TypeScript | `flow.promoted-disposition.test.ts` — full mode and minor-audit mode cases each assert `Copied potential file to ${issuePath}` | `flow.promoted-disposition.test.ts` prefix-sibling case asserts `Moved potential file to ${issuePath}`; the unmodified `flow.test.ts:254-286` case also asserts it |
| Python | `test_new_active_feature_folder_part5.py::test_create_feature_folder_copies_promoted_potential` asserts `Copied potential file to <path>` on stdout | `test_new_active_feature_folder_part5.py::test_create_feature_folder_moves_unpromoted_potential` asserts `Moved potential file to <path>` on stdout |

## Receipt Post-Condition — Deliberately TypeScript-Only (INV-6)

The receipt existence post-condition added by P3-T2 and P3-T4 has **no Python analogue, by design**. The reason is structural, not an omission:

- The TypeScript service-call layer (`new-active-feature-folder-service-call.ts`, `potential-to-issue-service-call.ts`) constructs a receipt record — `tool`, `workspaceRoot`, `summary`, `destinationPath`, `artifacts` — that the MCP surface renders to a caller. A receipt naming an absent path is a false success, which is what the post-condition prevents.
- The Python CLI emits **no receipt**. `create_active_folder` returns an `ActiveFolderResult` to an in-process caller and prints human-readable lines to stdout; there is no record whose reported paths could be asserted against, and no `ok: true` / `ok: false` surface to render. Adding an existence assertion there would guard nothing.

This asymmetry is confined to the receipt layer. The disposition rule and the emitted-line wording — the behavior a user or a downstream tool observes — are mirrored exactly, which is what INV-6 requires.

## Scope Confirmation

- Only the two flow files were changed in this parity pair. `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` and `scripts/dev_tools/new_active_feature_folder_io.py` are both unmodified (`git diff --stat` returns no output for either), so `findPotentialFile` / `find_potential_file` retain identical discovery behavior in both languages (INV-1).
- `scripts/dev_tools/potential_to_issue.py` is unmodified, so the Python promotion path is untouched.
