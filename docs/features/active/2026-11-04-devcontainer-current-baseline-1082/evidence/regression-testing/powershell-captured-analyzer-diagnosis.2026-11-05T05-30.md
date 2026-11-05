Timestamp: 2026-11-05T05-30
Started: 2026-11-05T05:30:23.7967816Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-current-powershell.sh analyze
EXIT_CODE: 1
Output Summary:

```text
                                                 nvelope.Te
                                                 sts.ps1
PSUseDeclaredVarsMoreThanAssignment Warning      validate-p 16    The variable 'originalJoinPath' is assigned but
s                                                lanner-out       never used.
                                                 put.Covera
                                                 ge.Tests.p
                                                 s1
PSUseDeclaredVarsMoreThanAssignment Warning      validate-r 17    The variable 'originalJoinPath' is assigned but
s                                                equired-ar       never used.
                                                 tifact-out
                                                 put.Envelo
                                                 pe.Tests.p
                                                 s1
PSUseDeclaredVarsMoreThanAssignment Warning      validate-t 16    The variable 'originalJoinPath' is assigned but
s                                                ask-resear       never used.
                                                 cher-outpu
                                                 t.Coverage
                                                 .Tests.ps1
PSUseDeclaredVarsMoreThanAssignment Warning      enforce-co 16    The variable 'originalTestPath' is assigned but
s                                                dex-model-       never used.
                                                 routing.Co
                                                 verage.Tes
                                                 ts.ps1
PSUseDeclaredVarsMoreThanAssignment Warning      enforce-ep 15    The variable 'originalTestPath' is assigned but
s                                                ic-root-in       never used.
                                                 vocation.C
                                                 overage.Te
                                                 sts.ps1
PSUseDeclaredVarsMoreThanAssignment Warning      enforce-ep 16    The variable 'originalTestPath' is assigned but
s                                                ic-wave-ba       never used.
                                                 rrier.Cove
                                                 rage.Tests
                                                 .ps1
PSUseDeclaredVarsMoreThanAssignment Warning      hook-depen 38    The variable 'originalJoinPath' is assigned but
s                                                dency-fail       never used.
                                                 ure.Codex.
                                                 Tests.ps1
PSUseDeclaredVarsMoreThanAssignment Warning      hook-impor 29    The variable 'originalJoinPath' is assigned but
s                                                t-failure-       never used.
                                                 exemptions
                                                 .FailClose
                                                 d.Tests.ps
                                                 1

Analyzer findings=16
```

Raw output: SCRATCH/issue-1082-powershell-captured-analyzer-diagnosis.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
