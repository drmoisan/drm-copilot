Timestamp: 2026-11-04T02-28
Command: docker run --rm --user root --security-opt seccomp=unconfined --mount type=bind,source=WORKSPACE,target=/workspaces/drm-copilot,readonly --mount type=bind,source=SCRATCH,target=/coverage -w /workspaces/drm-copilot --entrypoint bash vsc-drm-copilot-e593fee203d55a66ea1452f0c5df0aee6691b7b1807f1b2ccbad654ee8bf0557 -lc 'SHELL_QC_SHFMT_BIN=/coverage/issue-1069-shfmt bash scripts/bash/shell-qc.sh check'
EXIT_CODE: 1
Output Summary: github.com/docker/pinata/common/pkg/errordef.helper.Wrap
	github.com/docker/pinata/common/pkg/errordef/helper.go:60
github.com/docker/pinata/common/cmd/com.docker.backend/internal/engines/wsl.(*Engine).checkError
	github.com/docker/pinata/common/cmd/com.docker.backend/internal/engines/wsl/engine_windows.go:227
github.com/docker/pinata/common/cmd/com.docker.backend/internal/engines/wsl.(*Engine).Run.func1
	github.com/docker/pinata/common/cmd/com.docker.backend/internal/engines/wsl/engine_windows.go:168
github.com/docker/pinata/win/backend/wsl.Config.Run.func3
	github.com/docker/pinata/win/backend/wsl/config.go:89
golang.org/x/sync/errgroup.(*Group).Go.func1
	golang.org/x/sync@v0.24.0/errgroup/errgroup.go:93
runtime.goexit
	runtime/asm_amd64.s:1264


