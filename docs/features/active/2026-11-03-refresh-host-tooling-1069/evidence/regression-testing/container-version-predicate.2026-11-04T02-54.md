Timestamp: 2026-11-04T02-54
Command: shfmt -w/-d scripts/bash/container_versions.sh tests/shell/test_container_versions.bats; shellcheck scripts/bash/container_versions.sh; docker run cached image kcov --include-pattern=/scripts/bash/container_versions.sh --exclude-pattern=/tests/ SCRATCH/issue-1069-versions-initial /usr/bin/bats tests/shell/test_container_versions.bats
EXIT_CODE: 0
Output Summary: Five deterministic Bats tests passed; predicate16/16=100%lines. Covers allpins,Pythonminor/patchboundaries,stale/newer/malformed/missing/unknown inputs; no nativeversionquery or testfilecreation.

