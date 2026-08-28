Timestamp: 2026-08-28T21-05

## P2-T1: raw-socket-vs-proxy-isolation probe

Command:
```powershell
$env:HTTP_PROXY = 'http://127.0.0.1:9'
$env:HTTPS_PROXY = 'http://127.0.0.1:9'
$env:ALL_PROXY = 'http://127.0.0.1:9'
$env:NPM_CONFIG_REGISTRY = 'http://127.0.0.1:9'
$connected = $false
try {
    $client = [System.Net.Sockets.TcpClient]::new()
    $client.Connect('registry.npmjs.org', 443)
    $connected = $client.Connected
    $client.Close()
} catch {
    $connected = $false
}
Write-Output "RAW_SOCKET_CONNECTED=$connected"
```
EXIT_CODE: 0
Output Summary: `RAW_SOCKET_CONNECTED=True`. This reproduces the #526 reaudit's R4 probe (`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/policy-audit.2026-08-26T04-33.md:395-406`): a raw `TcpClient` connection to `registry.npmjs.org:443` succeeds from inside the same proxy-isolated session class (`HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY`/`NPM_CONFIG_REGISTRY` all redirected to an unreachable discard endpoint at `127.0.0.1:9`) on this same Windows 11 workstation environment. This confirms the proxy-environment-variable mechanism does not block a raw socket.

## P2-T2: AC21 clause 2 reaffirmation

Command:
```
git grep -nE '&\s+(npm|gh|git)\s' -- tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
```
EXIT_CODE: 1
Output Summary: No match across any of the four release-verification test files (the three pre-existing files plus the new `Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` added in Phase 1 of this fix). This reaffirms AC21 clause 2: no test added or modified by #526 invokes `npm`, `gh`, or `git` as a real external process. All four files isolate external executable calls behind the wrapper-function seam (`Invoke-GitExe`, `Invoke-GhExe`, `Invoke-NpmExe`) and mock the wrapper, never the executable itself.

## Corrected claim

The complete Pester suite passes with all proxy-aware network clients redirected to an unreachable discard endpoint; a raw socket is not blocked by this mechanism. This is the narrower, accurate claim that replaces AC21's original wording ("no network access available"), which overstated the isolation mechanism's depth. AC21 clause 2 (no test invokes `npm`, `gh`, or `git` as a real external process) is unaffected by this correction and independently reaffirmed above.
