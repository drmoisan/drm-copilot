# AC-50 No Temporary Files in New Test Files (P12-T18)

Timestamp: 2026-09-30T01-24
Command: git grep -n -F -e "New-TemporaryFile" -e "GetTempFileName" -e "GetTempPath" -e "TestDrive" -e "Set-Content" -e "Out-File" -e "New-Item" -e "Remove-Item" -e "Copy-Item" -e "Move-Item" -- <T-SIG, T-RUN, T-REC, T-ESR, G1A, G1B, G2-G7, GUARDH>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- git grep exited 1 and printed no output.
