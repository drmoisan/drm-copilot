Timestamp: 2026-11-04T02-30
Command: docker run --rm --user root --security-opt seccomp=unconfined --mount type=bind,source=WORKSPACE,target=/workspaces/drm-copilot,readonly --mount type=bind,source=SCRATCH,target=/coverage -w /workspaces/drm-copilot --entrypoint bash vsc-drm-copilot-e593fee203d55a66ea1452f0c5df0aee6691b7b1807f1b2ccbad654ee8bf0557 -lc 'SHELL_QC_SHFMT_BIN=/coverage/issue-1069-shfmt bash scripts/bash/shell-qc.sh check'
EXIT_CODE: 0
Output Summary: 

