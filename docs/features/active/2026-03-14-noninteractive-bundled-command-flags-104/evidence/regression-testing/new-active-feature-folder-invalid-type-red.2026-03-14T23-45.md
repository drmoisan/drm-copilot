Timestamp: 2026-03-14T23-45
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.new-active-feature-folder.test.ts --testNamePattern="newActiveFeatureFolder direct mode rejects invalid type"
EXIT_CODE: 1
Output Summary:
    Γùï skipped surfaces non-zero exit failures
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot newActiveFeatureFolder command ΓÇ║ newActiveFeatureFolder direct mode rejects invalid type
System.Management.Automation.RemoteException
    expect(received).rejects.toThrow()
System.Management.Automation.RemoteException
    Received promise resolved instead of rejected
    Resolved to value: undefined
System.Management.Automation.RemoteException
    [0m [90m 258 |[39m     )[33m;[39m
     [90m 259 |[39m
    [31m[1m>[22m[39m[90m 260 |[39m     [36mawait[39m expect(
     [90m     |[39m                 [31m[1m^[22m[39m
     [90m 261 |[39m       handler([
     [90m 262 |[39m         [32m"--feature-name"[39m[33m,[39m
     [90m 263 |[39m         [32m"blank-pr-context"[39m[33m,[39m[0m
System.Management.Automation.RemoteException
      at expect (node_modules/expect/build/index.js:2116:15)
      at Object.<anonymous> (test/extension.new-active-feature-folder.test.ts:260:17)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 11 skipped, 12 total
Snapshots:   0 total
Time:        0.363 s, estimated 1 s
Ran all test suites within paths "test/extension.new-active-feature-folder.test.ts".
