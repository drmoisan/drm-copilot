Timestamp: 2026-11-04T02-30
Command: docker run --rm --user root --security-opt seccomp=unconfined --mount type=bind,source=WORKSPACE,target=/workspaces/drm-copilot,readonly --mount type=bind,source=SCRATCH,target=/coverage -w /workspaces/drm-copilot --entrypoint bash vsc-drm-copilot-e593fee203d55a66ea1452f0c5df0aee6691b7b1807f1b2ccbad654ee8bf0557 -lc 'shellcheck .devcontainer/post-create.sh .devcontainer/verify-container.sh'
EXIT_CODE: 1
Output Summary: 
In .devcontainer/verify-container.sh line 24:
    . /etc/os-release
      ^-------------^ SC1091 (info): Not following: /etc/os-release was not specified as input (see shellcheck -x).

For more information:
  https://www.shellcheck.net/wiki/SC1091 -- Not following: /etc/os-release wa...


