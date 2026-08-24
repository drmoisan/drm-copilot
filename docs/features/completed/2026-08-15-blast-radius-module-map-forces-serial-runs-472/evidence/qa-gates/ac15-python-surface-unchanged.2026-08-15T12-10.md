# AC15 Gate — Python Push-Down Surface Unchanged (issue #472)

Timestamp: 2026-08-15T12-10

All four checks required by [P6-T1] were executed and all four pass. AC15 is
satisfied: the Python push-down surface is byte-identical and no Python
derivation module was introduced.

---

## Check (a1) — no committed change against `main`

Command: `git diff main...HEAD --stat -- scripts/dev_tools/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_customizations.py`

EXIT_CODE: 0

Output Summary: empty output. Neither file differs from `main` in any commit on
this branch.

## Check (a2) — no working-tree change

Command: `git status --porcelain -- scripts/dev_tools/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_customizations.py`

EXIT_CODE: 0

Output Summary: empty output. Neither file is modified, staged, or untracked in
the working tree.

This second check is load-bearing: while the item's work is uncommitted, check
(a1) alone would pass vacuously because there is nothing on the branch to
diff. The empty porcelain output is what actually proves the files are
untouched right now.

## Check (b) — `ROOT_FOLDERS` and the pinned assertion

Command: `grep -n "ROOT_FOLDERS" scripts/dev_tools/push_down_claude_customizations.py` and inspection of `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80`

EXIT_CODE: 0

Output Summary:

```
scripts/dev_tools/push_down_claude_customizations.py
101:ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)
116:    "ROOT_FOLDERS",
278:        root_folders=ROOT_FOLDERS,
```

The Python surface still publishes `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)` —
it does not carry the `config` tree, unlike the TypeScript surface. The pin at
`tests/scripts/dev_tools/test_push_down_claude_customizations.py:80` is
unmodified:

```python
    assert module.ROOT_FOLDERS == (Path(".claude"),)
```

## Check (c) — no new Python push-down module exists

Command: `ls scripts/dev_tools/push_down_claude_blast_radius.py` and `ls scripts/dev_tools/push_down_claude_routing_merge.py`

EXIT_CODE: 2 for each (file not found), which is the required outcome.

Output Summary:

```
ls: cannot access 'scripts/dev_tools/push_down_claude_blast_radius.py': No such file or directory
ls: cannot access 'scripts/dev_tools/push_down_claude_routing_merge.py': No such file or directory
```

Neither a config-carriage, routing-merge, nor derivation module was added to the
Python surface. This matches plan binding constraint 1 and the owner decision
`derivation_scoped_to_typescript_surface_only`.

## Check (d) — the pinned Python test passes

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py`

EXIT_CODE: 0

Output Summary:

```
collected 8 items
tests\scripts\dev_tools\test_push_down_claude_customizations.py ........ [100%]
============================== 8 passed in 0.08s ==============================
```

All 8 tests pass, including the `ROOT_FOLDERS` pin.
