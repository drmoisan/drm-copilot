/**
 * Prove every finalize_discovery_agent refusal happens before protected writes.
 *
 * Forged success, wrong gates, runtime drift, identity mismatches, activation
 * changes, input drift, output mismatches and invalid invocation states are
 * each driven through the shared scenario and asserted to write nothing.
 */

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  finalizeDiscoveryInvocation,
  type FinalizationOptions,
} from "../src/discovery-finalization";
import {
  DiscoveryInputManifestError,
  workspacePath,
} from "../src/discovery-input-manifest";
import {
  codeOf,
  entry,
  failingResult,
  finalizeOptions,
  MISSING,
  result,
  type Scenario,
  scenario,
  SOURCE,
  SOURCE_TEXT,
  WS,
} from "./discovery-finalization-test-support";
import { LOCATION, RUNTIME } from "./discovery-invocation-test-support";
import { digestOf } from "./discovery-store-test-helpers";
import { buildBlockingResult } from "./discovery-test-helpers";
describe("finalizeDiscoveryInvocation refusals", () => {
  function refused(
    scene: Scenario,
    overrides: Partial<FinalizationOptions>,
  ): string {
    const before = scene.io.writtenPaths().length;
    const code = codeOf(() =>
      finalizeDiscoveryInvocation(finalizeOptions(scene, overrides)),
    );
    expect(scene.io.writtenPaths()).toHaveLength(before);
    return code;
  }

  it.each([
    [
      "pass with blocking finding",
      (scene: Scenario) => ({
        ...result(scene),
        findings: buildBlockingResult().findings,
      }),
    ],
    [
      "pass with failed exit",
      (scene: Scenario) => ({
        ...result(scene),
        ok: false,
        exit_code: 1 as const,
      }),
    ],
    [
      "fail without findings",
      (scene: Scenario) => ({ ...failingResult(scene), findings: [] }),
    ],
    [
      "fail claiming ok",
      (scene: Scenario) => ({
        ...failingResult(scene),
        ok: true,
        exit_code: 0 as const,
      }),
    ],
    [
      "caller-minted receipt",
      (scene: Scenario) => {
        const base = result(scene);
        return {
          ...base,
          summary: {
            ...base.summary,
            receipt_ref: "receipt-forged-00000000001",
          },
        };
      },
    ],
    [
      "null verdict",
      (scene: Scenario) => {
        const base = result(scene);
        return {
          ...base,
          summary: { ...base.summary, validation_result: null },
        };
      },
    ],
  ])("refuses forged success: %s", (_label, build) => {
    const scene = scenario();
    expect(refused(scene, { result: build(scene) })).toBe(
      "FINALIZATION_RESULT_FORGED",
    );
  });

  it.each([
    [
      "other operation",
      (scene: Scenario) => ({
        ...result(scene),
        operation: "validate-all" as const,
      }),
    ],
    [
      "root mode",
      (scene: Scenario) => ({ ...result(scene), mode: "structural" as const }),
    ],
    [
      "other invocation",
      (scene: Scenario) => {
        const base = result(scene);
        return {
          ...base,
          summary: { ...base.summary, invocation_ref: "invocation-other" },
        };
      },
    ],
    [
      "no input manifest",
      (scene: Scenario) => ({ ...result(scene), input_manifest: null }),
    ],
  ])("refuses a result for the wrong gate: %s", (_label, build) => {
    const scene = scenario();
    expect(refused(scene, { result: build(scene) })).toBe("FINALIZATION_GATE");
  });

  it.each([
    ["build", { build_sha256: "1".repeat(64) }],
    ["policy version", { policy_version: 9 }],
    ["policy digest", { policy_sha256: "2".repeat(64) }],
    ["schema", { schema_version: "2.1.0" }],
    ["package", { package_version: "3.0.0" }],
  ])("refuses runtime drift in %s", (_label, change) => {
    const scene = scenario();
    expect(
      refused(scene, {
        result: result(scene, { runtime: { ...RUNTIME, ...change } }),
      }),
    ).toBe("FINALIZATION_RUNTIME_DRIFT");
    expect(refused(scene, { result: result(scene, { runtime: null }) })).toBe(
      "FINALIZATION_RUNTIME_DRIFT",
    );
  });

  it.each([
    [
      "wrong role",
      { role: "requirements-reconciler" },
      "FINALIZATION_IDENTITY",
    ],
    ["wrong host", { host: "claude-code" }, "FINALIZATION_IDENTITY"],
    [
      "wrong session",
      { session_id: "session-beta" },
      "FINALIZATION_INVOCATION_MISSING",
    ],
    [
      "wrong invocation",
      { invocation_id: "invocation-other" },
      "FINALIZATION_INVOCATION_MISSING",
    ],
  ])("refuses %s", (_label, change, code) => {
    const scene = scenario();
    const base = finalizeOptions(scene).identity;
    expect(refused(scene, { identity: { ...base, ...change } })).toBe(code);
  });

  it("refuses a changed activation workspace or profile binding", () => {
    const scene = scenario();
    const moved = {
      envelope: () => ({
        workspace: { ...WS, profile_sha256: "3".repeat(64) },
        activation_sha256: "e".repeat(64),
        generation: 2,
      }),
    };
    expect(refused(scene, { activation: moved })).toBe(
      "FINALIZATION_WORKSPACE_CHANGED",
    );
    const rooted = {
      envelope: () => ({
        workspace: { ...WS, workspace_root: "D:/Other" },
        activation_sha256: "e".repeat(64),
        generation: 2,
      }),
    };
    expect(refused(scene, { activation: rooted })).toBe(
      "FINALIZATION_WORKSPACE_CHANGED",
    );
  });

  it.each([
    [
      "edited input",
      (scene: Scenario) =>
        scene.reader.write(
          workspacePath(WS.workspace_root, SOURCE),
          "changed\n",
        ),
      ["edited"],
    ],
    [
      "deleted input",
      (scene: Scenario) =>
        scene.reader.files.delete(workspacePath(WS.workspace_root, SOURCE)),
      ["deleted"],
    ],
    [
      "new input",
      (scene: Scenario) =>
        scene.reader.write(
          workspacePath(WS.workspace_root, MISSING),
          "scope: all\n",
        ),
      ["appeared"],
    ],
    [
      "renamed input",
      (scene: Scenario) => {
        scene.reader.files.delete(workspacePath(WS.workspace_root, SOURCE));
        scene.reader.write(
          workspacePath(WS.workspace_root, MISSING),
          SOURCE_TEXT,
        );
      },
      ["deleted", "renamed"],
    ],
    [
      "edited profile",
      (scene: Scenario) =>
        scene.reader.write(
          workspacePath(WS.workspace_root, WS.profile_path),
          "name: other\n",
        ),
      ["edited", "profile-changed"],
    ],
  ])("refuses %s as input drift before writing", (_label, mutate, kinds) => {
    const scene = scenario();
    mutate(scene);
    const before = scene.io.writtenPaths().length;
    let caught: DiscoveryInputManifestError | undefined;
    try {
      finalizeDiscoveryInvocation(finalizeOptions(scene));
    } catch (error) {
      caught = error as DiscoveryInputManifestError;
    }
    expect(caught?.code).toBe("INPUT_DRIFT");
    expect(caught?.drift.map((item) => item.kind)).toEqual(kinds);
    expect(scene.io.writtenPaths()).toHaveLength(before);
  });

  it("refuses evidence replacement", () => {
    const scene = scenario();
    const evidence = "docs/evidence/run-1.json";
    scene.reader.write(
      workspacePath(WS.workspace_root, evidence),
      '{"run": 2}\n',
    );
    const base = result(scene);
    const manifest = base.input_manifest!;
    const withEvidence = {
      ...base,
      input_manifest: {
        ...manifest,
        entries: [
          ...manifest.entries,
          entry(evidence, '{"run": 1}\n', "evidence"),
        ],
      },
    };
    expect(refused(scene, { result: withEvidence })).toBe("INPUT_DRIFT");
  });

  it("refuses a malformed runtime manifest", () => {
    const scene = scenario();
    const base = result(scene);
    const broken = {
      ...base,
      input_manifest: {
        ...base.input_manifest!,
        entries: [{ path: "x", sha256: "nope", size: 1, category: "source" }],
      },
    };
    expect(refused(scene, { result: broken })).toBe("INPUT_MANIFEST_INVALID");
  });

  it.each([
    [
      "absent output file",
      (scene: Scenario) => {
        scene.reader.files.delete(
          workspacePath(WS.workspace_root, scene.outputPath),
        );
        return result(scene);
      },
      "FINALIZATION_OUTPUT_MISSING",
    ],
    [
      "unreported output",
      (scene: Scenario) => result(scene, { artifacts: [] }),
      "FINALIZATION_OUTPUT_MISSING",
    ],
    [
      "digest mismatch",
      (scene: Scenario) =>
        result(scene, {
          artifacts: [
            {
              path: scene.outputPath,
              kind: scene.outputKind,
              status: "created",
              sha256: "4".repeat(64),
            },
          ],
        }),
      "FINALIZATION_OUTPUT_MISMATCH",
    ],
    [
      "conflict status",
      (scene: Scenario) =>
        result(scene, {
          artifacts: [
            {
              path: scene.outputPath,
              kind: scene.outputKind,
              status: "conflict",
              sha256: digestOf(scene.outputText),
            },
          ],
        }),
      "FINALIZATION_OUTPUT_MISMATCH",
    ],
    [
      "extra artifact",
      (scene: Scenario) =>
        result(scene, {
          artifacts: [
            ...result(scene).artifacts,
            {
              path: "src/Orders/Order.cs",
              kind: "feature-contract",
              status: "updated",
              sha256: digestOf(SOURCE_TEXT),
            },
          ],
        }),
      "FINALIZATION_OUTPUT_UNEXPECTED",
    ],
    [
      "kind substitution",
      (scene: Scenario) =>
        result(scene, {
          artifacts: [
            {
              path: scene.outputPath,
              kind: "feature-contract",
              status: "created",
              sha256: digestOf(scene.outputText),
            },
          ],
        }),
      "FINALIZATION_OUTPUT_UNEXPECTED",
    ],
  ])("refuses %s", (_label, build, code) => {
    const scene = scenario();
    expect(refused(scene, { result: build(scene) })).toBe(code);
  });

  it("refuses an invalid request id or nonce", () => {
    const scene = scenario();
    expect(refused(scene, { requestId: "has space" })).toBe(
      "FINALIZATION_REQUEST_INVALID",
    );
    expect(refused(scene, { nonce: () => "Bad" })).toBe(
      "FINALIZATION_REQUEST_INVALID",
    );
  });

  it("refuses a revoked invocation", () => {
    const scene = scenario();
    const directory = invocationDirectory(
      LOCATION,
      "session-alpha",
      scene.invocationId,
    );
    const record = JSON.parse(
      scene.io.files.get(`${directory}/invocation.json`)!,
    ) as Record<string, unknown>;
    scene.io.files.set(
      `${directory}/invocation.json`,
      JSON.stringify({ ...record, state: "revoked" }),
    );
    expect(refused(scene, {})).toBe("FINALIZATION_INVOCATION_STATE");
  });
});
