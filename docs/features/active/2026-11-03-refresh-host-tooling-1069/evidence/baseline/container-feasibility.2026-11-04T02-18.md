Timestamp: 2026-11-04T02-18
Command: docker run --rm --entrypoint python mcr.microsoft.com/devcontainers/python:3.13-bookworm --version; docker run --rm --entrypoint python python:3.13.17-bookworm --version; Invoke-WebRequest https://deb.nodesource.com/node_26.x/dists/nodistro/main/binary-amd64/Packages; Invoke-WebRequest https://packages.microsoft.com/debian/12/prod/dists/bookworm/main/binary-amd64/Packages
EXIT_CODE: 0
Output Summary: Actual devcontainer minor image Python3.13.12. Official python:3.13.17-bookworm downloaded and reports Python3.13.17; linux/amd64 digest sha256:a3799099b64fd333f262768c7a64733f6e4edb7bc569813710a100214bdcf278. Use verified Python-install stage /usr/local copy into unchanged devcontainer minor base. NodeSource26.13.0-1nodesource1 and MicrosoftPowerShell7.6.9-1.deb available amd64. Initial package probe incorrectly treated byte Content as text; UTF8 decoding corrected it.

