# P3-T4 independent probe fixture diagnostic

Timestamp: 2026-10-18T15-41
Command: poetry run python SCRATCH/issue-980-p3t4-review-probes.py
EXIT_CODE: 1
Output Summary: Ten checks passed before the custom-client fixture failed accepted profile validation. The remaining checks did not execute. This is a verifier fixture failure, not a production failure or task pass.

The probe constructed a `legacy-source` profile with a client targeting its own source-only repository. The accepted loader raised `ProfileError: /clients/0/target_repository: Unknown target repository: workspace-example` while capturing that fixture. The executed checks covered deterministic contract bytes, null unknowns, exact unresolved links, absent evidence/approval, optional offline/mobile requirements, a real planner positive, missing exact grants, and three prohibited summary promotions.

Corrective action: change only the SCRATCH fixture role to `combined`, which permits that explicit local target client. No production, test, schema, policy, plan, or AC file changed. The run exited before its final source-binding/result publication and therefore is not final-byte acceptance evidence.
