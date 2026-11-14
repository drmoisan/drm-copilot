# Fixture hook for tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1 (issue #1159).
# Reads the payload from stdin, writes its length to stdout, and exits 2 when the payload
# contains the token "deny", otherwise 0. It writes no file.
$payload = [Console]::In.ReadToEnd()
[Console]::Out.WriteLine($payload.Length)
if ($payload.Contains('deny')) { exit 2 }
exit 0
