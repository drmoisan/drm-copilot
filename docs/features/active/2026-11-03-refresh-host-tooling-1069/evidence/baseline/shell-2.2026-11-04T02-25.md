Timestamp: 2026-11-04T02-25
Command: wsl -d Ubuntu -- bash -lc 'shellcheck .devcontainer/post-create.sh .devcontainer/verify-container.sh'
EXIT_CODE: 1
Output Summary:
In .devcontainer/verify-container.sh line 24:
    . /etc/os-release
      ^-------------^ SC1091 (info): Not following: /etc/os-release was not specified as input (see shellcheck -x).

For more information:
  https://www.shellcheck.net/wiki/SC1091 -- Not following: /etc/os-release wa...
