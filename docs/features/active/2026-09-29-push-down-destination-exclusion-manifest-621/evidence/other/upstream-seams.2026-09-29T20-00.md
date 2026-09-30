# Upstream #507 and #508 Seams — Issue #621

Task: [P1-T1]
Branch: feature/push-down-destination-exclusion-manifest-exec-621
HEAD: 93ba40f1 (base 9438bdf5, which contains #507 via PR #777 and #508 via PR #778)

## Command 1 (blocking)

Timestamp: 2026-09-29T20-00
Command: grep -n -e 'ROOT_FOLDERS' scripts/dev_tools/push_down_claude_customizations.py
EXIT_CODE: 0
Output Summary: Three matched lines:

```
115:ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))
133:    "ROOT_FOLDERS",
319:        root_folders=ROOT_FOLDERS,
```

The `ROOT_FOLDERS` assignment line (115) contains `config`. The #507 config root is present; the blocking condition is satisfied.

## Command 2 (recorded, not blocking)

Timestamp: 2026-09-29T20-00
Command: grep -rn -e 'class RoutingMergeFileSystem' scripts/dev_tools
EXIT_CODE: 1
Output Summary: Empty output (grep exit 1 means no match). No class of that name exists; #507 chose a different name. Not blocking, because no #621 code references this symbol.

## Command 3 (recorded, not blocking)

Timestamp: 2026-09-29T20-00
Command: grep -rn -F -e 'blast-radius.json' scripts/dev_tools --include=push_down_claude_*.py
EXIT_CODE: 0
Output Summary: 15 matched lines across four files:
- `scripts/dev_tools/push_down_claude_blast_radius_derive_core.py`: lines 7, 63 (`BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json"`), 198
- `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`: lines 6, 251
- `scripts/dev_tools/push_down_claude_customizations.py`: line 229 (docstring)
- `scripts/dev_tools/push_down_claude_destination_writes.py`: lines 7, 13, 24 (`#508 extends MERGED_RELATIVE_PATHS by registering config/blast-radius.json`), 111, 112, 128 (`"config/blast-radius.json": merge_blast_radius_overlay,`), 134 (`"config/blast-radius.json": "config/blast-radius.local.json",`), 293
Not blocking, because no #621 code references the #508 blast-radius handling.

## Command 4 (recorded; #507 parity test path per plan section 2 item 16)

Timestamp: 2026-09-29T20-00
Command: grep -rln -e 'ROOT_FOLDERS' tests/scripts/dev_tools --include=test_push_down_claude_*parity*.py
EXIT_CODE: 0
Output Summary: `tests/scripts/dev_tools/test_push_down_claude_parity.py`. This is the #507 parity test path; the integration branch can reconcile it with the dedicated #621 parity modules. No task edits it.
