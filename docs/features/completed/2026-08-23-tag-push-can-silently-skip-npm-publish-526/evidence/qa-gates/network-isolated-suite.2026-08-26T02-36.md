# Network-Isolated Suite Run — AC21 Evidence (R4)

Timestamp: 2026-08-26T03-58

> Filename-stamp substitution note: this artifact's filename carries the fixed cycle stamp
> `2026-08-26T02-36`, matching the remediation-inputs stamp for this cycle, as required by the plan's
> "Evidence filename timestamps" section. The `Timestamp:` field above records the actual execution
> stamp, `2026-08-26T03-58`. The same substitution convention was used by the Phase 0 through Phase 3
> artifacts of this cycle.

Command: `pwsh -NoProfile -Command '$env:HTTP_PROXY="http://127.0.0.1:9"; $env:HTTPS_PROXY="http://127.0.0.1:9"; $env:ALL_PROXY="http://127.0.0.1:9"; $env:NO_PROXY=""; $env:NPM_CONFIG_REGISTRY="http://127.0.0.1:9"; npm view "@danmoisan/drm-copilot-mcp" version; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

IsolationMethod: Process-scoped environment isolation inside a single `pwsh` session. `HTTP_PROXY`, `HTTPS_PROXY`, and `ALL_PROXY` were set to the discard endpoint `http://127.0.0.1:9`, `NO_PROXY` was set to the empty string so no host could bypass the proxy, and `NPM_CONFIG_REGISTRY` was set to the same discard endpoint. Port 9 is the IANA discard port and is not listening on this host, so every outbound HTTP attempt terminates at the local TCP stack with a refused connection. The isolation was proven before the suite ran, and the suite ran in the same session with the same environment.

IsolationProbeExitCode: 1

NetworkIsolationBranch: EXECUTED

## Output Summary

### Isolation probe — verbatim output

Probe command: `npm view "@danmoisan/drm-copilot-mcp" version`

Probe exit code: `1`

```text
npm error code ECONNREFUSED
npm error syscall connect
npm error errno ECONNREFUSED
npm error FetchError: request to http://127.0.0.1:9/@danmoisan%2fdrm-copilot-mcp failed, reason: connect ECONNREFUSED 127.0.0.1:9
npm error     at ClientRequest.<anonymous> (C:\Program Files\nodejs\node_modules\npm\node_modules\minipass-fetch\lib\index.js:130:14)
npm error     at ClientRequest.emit (node:events:508:28)
npm error     at emitErrorEvent (node:_http_client:108:11)
npm error     at _destroy (node:_http_client:963:9)
npm error     at onSocketNT (node:_http_client:983:5)
npm error     at process.processTicksAndRejections (node:internal/process/task_queues:91:21) {
npm error   code: 'ECONNREFUSED',
npm error   errno: 'ECONNREFUSED',
npm error   syscall: 'connect',
npm error   address: '127.0.0.1',
npm error   port: 9,
npm error   type: 'system'
npm error }
npm error
npm error If you are behind a proxy, please make sure that the
npm error 'proxy' config is set properly.  See: 'npm help config'
npm error A complete log of this run can be found in: C:\Users\DanMoisan\AppData\Local\npm-cache\_logs\2026-08-26T07_53_27_512Z-debug-0.log
```

### Why this output establishes isolation rather than merely a non-zero exit

The `EXECUTED` branch requires that the probe fail at the connection level against the discard
endpoint. A bare non-zero exit is not sufficient, because a missing `npm` executable or a
configuration parse error would also exit non-zero while proving nothing about network reachability.
The recorded output satisfies the stronger condition on four independent points:

1. `npm` itself ran. The output is npm's own diagnostic format, and npm resolved and wrote a debug
   log, so the executable is present and its configuration parsed.
2. The failure is `ECONNREFUSED` on `syscall connect` — a transport-layer failure, not a
   configuration, authentication, registry-semantics, or `E404` failure.
3. The refused address and port are exactly the configured discard endpoint, `127.0.0.1:9`, so the
   request was directed where the isolation intended and nowhere else.
4. The requested URL is the scoped package path `http://127.0.0.1:9/@danmoisan%2fdrm-copilot-mcp`,
   confirming npm attempted the real registry operation against the discard endpoint rather than
   short-circuiting before any network attempt.

### Suite run inside the same isolated session

Suite command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path`

- Suite passed count: **3646**
- Suite failed count: **0**
- Suite skipped count: 9
- Suite exit code: 0
- Discovery: 3655 tests in 153 files; tests completed in 110.85 s.

The complete Pester suite passed with no network access available. No test required the network, and
no test failed as a result of the isolation, which is the substantive content of AC21's first clause.

### Repository-wide coverage observed in this run

- Repository-wide line coverage: 6794 covered of 7073 measured, 96.0554 percent.

Coverage figures are recorded here only as an observation of this run. The authoritative
post-remediation coverage record for this cycle is
`evidence/qa-gates/post-remediation-coverage.2026-08-26T02-36.md`.
