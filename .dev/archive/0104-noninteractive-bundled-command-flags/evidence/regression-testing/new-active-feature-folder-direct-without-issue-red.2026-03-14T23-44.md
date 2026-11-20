Timestamp: 2026-03-14T23-44
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.new-active-feature-folder.test.ts --testNamePattern="newActiveFeatureFolder direct invocation omits issue number without prompts"
EXIT_CODE: 1
Output Summary:
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot newActiveFeatureFolder command ΓÇ║ newActiveFeatureFolder direct invocation omits issue number without prompts
System.Management.Automation.RemoteException
    expect(jest.fn()).not.toHaveBeenCalled()
System.Management.Automation.RemoteException
    Expected number of calls: 0
    Received number of calls: 1
System.Management.Automation.RemoteException
    1: ["epic", "feature", "refactor", "bug"], {"ignoreFocusOut": true, "prompt": "Choose the feature folder type.", "title": "drm-copilot: New Active Feature Folder"}
System.Management.Automation.RemoteException
    [0m [90m 215 |[39m     ])[33m;[39m
     [90m 216 |[39m
    [31m[1m>[22m[39m[90m 217 |[39m     expect(showQuickPickMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m     |[39m                                   [31m[1m^[22m[39m
     [90m 218 |[39m     expect(showInputBoxMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m 219 |[39m     [36mconst[39m [[33m,[39m args] [33m=[39m childProcessMock[33m.[39mspawn[33m.[39mmock[33m.[39mcalls[[35m0[39m] [36mas[39m [string[33m,[39m string[]][33m;[39m
     [90m 220 |[39m     expect(args)[33m.[39mtoContain([32m"--feature-name"[39m)[33m;[39m[0m
System.Management.Automation.RemoteException
      at Object.<anonymous> (test/extension.new-active-feature-folder.test.ts:217:35)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 9 skipped, 10 total
Snapshots:   0 total
Time:        0.312 s, estimated 1 s
Ran all test suites within paths "test/extension.new-active-feature-folder.test.ts".
