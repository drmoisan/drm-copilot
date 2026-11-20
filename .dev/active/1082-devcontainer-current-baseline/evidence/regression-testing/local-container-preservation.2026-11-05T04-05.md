Timestamp: 2026-11-05T04-05
Started: 2026-11-05T04:05:50.5087620Z
Command: pwsh -NoLogo -NoProfile -File SCRATCH\issue-1082-preservation.ps1
EXIT_CODE: 0
Output Summary:

```text
.venv/Scripts/python.exe Length=255320 SHA256=6A74478B20739A9C814DCDB465A68CDF384B43447910399E02776D66A2BD1635
node_modules/.package-lock.json Length=252186 SHA256=7DB9A42460E5D49835493222ACCD403E0545143996D867D784EBDD08BD368ECE
extensions/drm-copilot/node_modules/.package-lock.json Length=217762 SHA256=4733D753DC46BCDFFF6FD6DAB637C80F8B83C6AB5CF781CD2B9A07CCE58C5BC3
packages/mcp-server/node_modules/.package-lock.json Length=43335 SHA256=ED66C4093C692B6589DEED3CE6460C7CCD034F129BDA144B188150719A918FAA
Host core.fsmonitor=true
drm-copilot-workspace 2026-11-05T02:03:32Z
d121cd8769a9f6e7048f513bb96993ca5eb631aaad9e92a65a45e27b21d70500 exited
[{"Type":"bind","Source":"C:\\Users\\DanMoisan\\repos\\drm-copilot","Destination":"REPO","Mode":"","RW":true,"Propagation":"rprivate"},{"Type":"volume","Name":"drm-copilot-workspace-bg","Source":"/var/lib/docker/volumes/drm-copilot-workspace-bg/_data","Destination":"REPO-bg","Driver":"local","Mode":"z","RW":true,"Propagation":""},{"Type":"bind","Source":"/var/run/docker.sock","Destination":"/var/run/docker-host.sock","Mode":"","RW":true,"Propagation":"rprivate"},{"Type":"volume","Name":"issue-1082-local-fresh-venv","Source":"/var/lib/docker/volumes/issue-1082-local-fresh-venv/_data","Destination":"REPO/.venv","Driver":"local","Mode":"z","RW":true,"Propagation":""},{"Type":"volume","Name":"issue-1082-local-fresh-node-modules","Source":"/var/lib/docker/volumes/issue-1082-local-fresh-node-modules/_data","Destination":"REPO/node_modules","Driver":"local","Mode":"z","RW":true,"Propagation":""},{"Type":"volume","Name":"issue-1082-local-fresh-extension-node-modules","Source":"/var/lib/docker/volumes/issue-1082-local-fresh-extension-node-modules/_data","Destination":"REPO/extensions/drm-copilot/node_modules","Driver":"local","Mode":"z","RW":true,"Propagation":""},{"Type":"volume","Name":"issue-1082-local-fresh-mcp-node-modules","Source":"/var/lib/docker/volumes/issue-1082-local-fresh-mcp-node-modules/_data","Destination":"REPO/packages/mcp-server/node_modules","Driver":"local","Mode":"z","RW":true,"Propagation":""}]
```

Raw output: SCRATCH/issue-1082-local-container-preservation.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
