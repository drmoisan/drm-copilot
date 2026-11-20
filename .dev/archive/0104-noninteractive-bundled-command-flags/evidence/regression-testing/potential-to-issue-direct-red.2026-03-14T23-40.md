Timestamp: 2026-03-14T23-40
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.potential-to-issue.test.ts --testNamePattern="potentialToIssue direct invocation skips active-editor and prompt UI"
EXIT_CODE: 1
Output Summary:
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot potentialToIssue command ΓÇ║ potentialToIssue direct invocation skips active-editor and prompt UI
System.Management.Automation.RemoteException
    expect(jest.fn()).not.toHaveBeenCalled()
System.Management.Automation.RemoteException
    Expected number of calls: 0
    Received number of calls: 1
System.Management.Automation.RemoteException
    1: {"canSelectMany": false, "defaultUri": {"fsPath": "C:/workspace/docs/features/potential"}, "filters": {"Markdown": ["md"]}, "openLabel": "Select potential file"}
System.Management.Automation.RemoteException
    [0m [90m 214 |[39m     ])[33m;[39m
     [90m 215 |[39m
    [31m[1m>[22m[39m[90m 216 |[39m     expect(showOpenDialogMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m     |[39m                                    [31m[1m^[22m[39m
     [90m 217 |[39m     expect(showQuickPickMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m 218 |[39m     [36mconst[39m [[33m,[39m args] [33m=[39m childProcessMock[33m.[39mspawn[33m.[39mmock[33m.[39mcalls[[35m0[39m] [36mas[39m [string[33m,[39m string[]][33m;[39m
     [90m 219 |[39m     expect(args)[33m.[39mtoContain([32m"--potential-path"[39m)[33m;[39m[0m
System.Management.Automation.RemoteException
      at Object.<anonymous> (test/extension.potential-to-issue.test.ts:216:36)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 11 skipped, 12 total
Snapshots:   0 total
Time:        0.287 s, estimated 1 s
Ran all test suites within paths "test/extension.potential-to-issue.test.ts".
