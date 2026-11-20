Timestamp: 2026-11-05T03-31
Started: 2026-11-05T03:31:14.3507335Z
Command: docker exec --user vscode --workdir /workspaces/drm-copilot 40c5007b16b3 bash -c shfmt -d .devcontainer/lib/workspace.sh .devcontainer/post-create.sh && shfmt -ln bats -d tests/shell/test_devcontainer_workspace.bats && shellcheck .devcontainer/lib/workspace.sh .devcontainer/post-create.sh && bats tests/shell/test_devcontainer_workspace.bats
EXIT_CODE: 0
Output Summary:

```text
1..14
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
```

Raw output: SCRATCH/issue-1082-p1-workspace-shell.log
