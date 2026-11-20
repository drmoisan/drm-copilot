Timestamp: 2026-03-14T23-40
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.potential-to-issue.test.ts --testNamePattern="potentialToIssue direct mode rejects unknown flag"
EXIT_CODE: 1
Output Summary:
    Γùï skipped surfaces non-zero exit failures
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot potentialToIssue command ΓÇ║ potentialToIssue direct mode rejects unknown flag
System.Management.Automation.RemoteException
    expect(received).rejects.toThrow()
System.Management.Automation.RemoteException
    Received promise resolved instead of rejected
    Resolved to value: undefined
System.Management.Automation.RemoteException
    [0m [90m 232 |[39m     )[33m;[39m
     [90m 233 |[39m
    [31m[1m>[22m[39m[90m 234 |[39m     [36mawait[39m expect(
     [90m     |[39m                 [31m[1m^[22m[39m
     [90m 235 |[39m       handler([
     [90m 236 |[39m         [32m"--potential-path"[39m[33m,[39m
     [90m 237 |[39m         [32m"C:/workspace/docs/features/potential/direct.md"[39m[33m,[39m[0m
System.Management.Automation.RemoteException
      at expect (node_modules/expect/build/index.js:2116:15)
      at Object.<anonymous> (test/extension.potential-to-issue.test.ts:234:17)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 12 skipped, 13 total
Snapshots:   0 total
Time:        0.435 s, estimated 1 s
Ran all test suites within paths "test/extension.potential-to-issue.test.ts".
