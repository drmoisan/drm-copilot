Timestamp: 2026-03-14T23-44
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.new-active-feature-folder.test.ts --testNamePattern="newActiveFeatureFolder direct mode rejects non-digit issue number"
EXIT_CODE: 1
Output Summary:
    Γùï skipped surfaces non-zero exit failures
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot newActiveFeatureFolder command ΓÇ║ newActiveFeatureFolder direct mode rejects non-digit issue number
System.Management.Automation.RemoteException
    expect(received).rejects.toThrow()
System.Management.Automation.RemoteException
    Received promise resolved instead of rejected
    Resolved to value: undefined
System.Management.Automation.RemoteException
    [0m [90m 234 |[39m     )[33m;[39m
     [90m 235 |[39m
    [31m[1m>[22m[39m[90m 236 |[39m     [36mawait[39m expect(
     [90m     |[39m                 [31m[1m^[22m[39m
     [90m 237 |[39m       handler([
     [90m 238 |[39m         [32m"--feature-name"[39m[33m,[39m
     [90m 239 |[39m         [32m"blank-pr-context"[39m[33m,[39m[0m
System.Management.Automation.RemoteException
      at expect (node_modules/expect/build/index.js:2116:15)
      at Object.<anonymous> (test/extension.new-active-feature-folder.test.ts:236:17)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 10 skipped, 11 total
Snapshots:   0 total
Time:        0.579 s, estimated 1 s
Ran all test suites within paths "test/extension.new-active-feature-folder.test.ts".
