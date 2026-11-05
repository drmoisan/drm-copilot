Timestamp: 2026-11-05T03-33
Started: 2026-11-05T03:33:27.4536087Z
Command: docker exec --user vscode --workdir /workspaces/drm-copilot 40c5007b16b3 kcov --include-pattern=/workspaces/drm-copilot/.devcontainer/lib/workspace.sh,/workspaces/drm-copilot/scripts/bash/container_versions.sh SCRATCH/issue-1082-kcov-p1-helpers bats tests/shell/test_devcontainer_workspace.bats tests/shell/test_container_versions.bats
EXIT_CODE: 0
Output Summary:

```text
\/\w\o\r\k\s\p\a\c\e\ \w\i\t\h\ \s\p\a\c\e\s\
* ]]
/other
/workspace
/another
 != *\
\/\w\o\r\k\s\p\a\c\e\
* ]]
/workspace-child
 != *\
\/\w\o\r\k\s\p\a\c\e\
* ]]
/another-workspace
 != *\
\/\w\o\r\k\s\p\a\c\e\
* ]]
sudo chown 1000:1000 /workspace/node_modules
sudo chown 1000:1000 /workspace/extensions/drm-copilot/node_modules
sudo chown 1000:1000 /workspace/packages/mcp-server/node_modules != *\-\R* ]]
find /workspace/.venv -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + == *\f\i\n\d\ \/\w\o\r\k\s\p\a\c\e\/\.\v\e\n\v\ \-\m\i\n\d\e\p\t\h\ \1\ \-\m\a\x\d\e\p\t\h\ \1\ \-\e\x\e\c\ \r\m\ \-\r\f\ \-\-\ \{\}\ \+* ]]
find /workspace/.venv -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + != *\
\r\m\ * ]]
rm -rf -- /workspace with spaces/.venv == *\r\m\ \-\r\f\ \-\-\ \/\w\o\r\k\s\p\a\c\e\ \w\i\t\h\ \s\p\a\c\e\s\/\.\v\e\n\v* ]]
1..21
ok 1 Git trust adds only the exact workspace when no value exists
ok 2 Git trust preserves an already registered workspace and other entries
ok 3 Git trust does not confuse a parent path with the exact workspace
ok 4 Git configuration read errors stop setup without writing configuration
ok 5 Git configuration write failures propagate
ok 6 ordinary dependency directories receive no ownership changes
ok 7 dependency mount preparation adjusts all four mount roots without recursion
ok 8 dependency preparation changes only actual mount roots
ok 9 an ownership failure stops before later dependency mounts
ok 10 missing virtual environments require no cleanup
ok 11 healthy virtual environments are retained
ok 12 broken mounted virtual environments retain the volume root
ok 13 broken non-mounted environments are removed within the workspace
ok 14 virtual environment cleanup failures propagate
ok 15 container versions accept every pinned tool and optional v prefixes
ok 16 container Python accepts its minimum and later patches within 3.13
ok 17 container Python rejects stale patches wrong minors and malformed versions
ok 18 container versions reject stale or different pinned tool releases
ok 19 container Git accepts its minimum and newer installed releases
ok 20 container Git rejects stale incomplete and malformed versions
ok 21 container versions reject unknown missing and malformed tool inputs
```

Raw output: SCRATCH/issue-1082-p1-helpers-coverage.log
