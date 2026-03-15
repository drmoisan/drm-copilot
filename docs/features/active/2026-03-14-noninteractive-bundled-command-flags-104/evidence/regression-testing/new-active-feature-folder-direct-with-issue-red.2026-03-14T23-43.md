Timestamp: 2026-03-14T23-43
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.new-active-feature-folder.test.ts --testNamePattern="newActiveFeatureFolder direct invocation forwards issue number without prompts"
EXIT_CODE: 1
Output Summary:
System.Management.Automation.RemoteException
  ΓùÅ drm-copilot newActiveFeatureFolder command ΓÇ║ newActiveFeatureFolder direct invocation forwards issue number without prompts
System.Management.Automation.RemoteException
    expect(jest.fn()).not.toHaveBeenCalled()
System.Management.Automation.RemoteException
    Expected number of calls: 0
    Received number of calls: 1
System.Management.Automation.RemoteException
    1: ["epic", "feature", "refactor", "bug"], {"ignoreFocusOut": true, "prompt": "Choose the feature folder type.", "title": "drm-copilot: New Active Feature Folder"}
System.Management.Automation.RemoteException
    [0m [90m 186 |[39m     ])[33m;[39m
     [90m 187 |[39m
    [31m[1m>[22m[39m[90m 188 |[39m     expect(showQuickPickMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m     |[39m                                   [31m[1m^[22m[39m
     [90m 189 |[39m     expect(showInputBoxMock)[33m.[39mnot[33m.[39mtoHaveBeenCalled()[33m;[39m
     [90m 190 |[39m     [36mconst[39m [[33m,[39m args] [33m=[39m childProcessMock[33m.[39mspawn[33m.[39mmock[33m.[39mcalls[[35m0[39m] [36mas[39m [string[33m,[39m string[]][33m;[39m
     [90m 191 |[39m     expect(args)[33m.[39mtoContain([32m"--feature-name"[39m)[33m;[39m[0m
System.Management.Automation.RemoteException
      at Object.<anonymous> (test/extension.new-active-feature-folder.test.ts:188:35)
System.Management.Automation.RemoteException
Test Suites: 1 failed, 1 total
Tests:       1 failed, 8 skipped, 9 total
Snapshots:   0 total
Time:        0.309 s, estimated 1 s
Ran all test suites within paths "test/extension.new-active-feature-folder.test.ts".
