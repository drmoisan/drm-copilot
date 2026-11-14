Timestamp: 2026-11-05T03-09
Started: 2026-11-05T03:09:45.4351419Z
Command: docker exec --user vscode --workdir REPO 40c5007b16b3 kcov --include-pattern=REPO/.devcontainer/post-create.sh SCRATCH/issue-1082-kcov-postcreate bash .devcontainer/post-create.sh
EXIT_CODE: 255
Output Summary:

```text
Can't set personality: Operation not permitted
kcov: error: Can't start/attach to /usr/bin/bash
Child hasn't stopped: ff00
kcov: error: Can't start/attach to /usr/bin/bash
```

Raw output: SCRATCH/issue-1082-shell-postcreate-coverage.log
