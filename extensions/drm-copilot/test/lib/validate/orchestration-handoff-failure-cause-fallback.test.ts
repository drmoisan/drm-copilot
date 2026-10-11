/**
 * Issue #844: blocked handoff results that follow an envelope-parse failure or
 * a destination-projection failure carry a redaction-safe `<stage>: <token>`
 * failure cause, and the shared envelope-parse helper keeps the authority
 * service and the production validator in agreement on code and cause.
 */
import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type { CommandRunner } from "../../../src/lib/subprocess-runner";
import {
  HandoffContractError,
  type HandoffEnvelope,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import { OrchestrationHandoffMaterializer } from "../../../src/lib/validate/orchestration-handoff-materializer";
import { createProductionHandoffMaterializer } from "../../../src/lib/validate/orchestration-handoff-materializer-production";
import { describeEnvelopeParseFailure } from "../../../src/lib/validate/orchestration-handoff-materializer-request";
import { createScenario } from "./orchestration-handoff-materializer-test-support";

describe("describeEnvelopeParseFailure", () => {
  it.each([
    {
      label: "F1 a HandoffContractError keeps its code and names it",
      error: new HandoffContractError(
        "handoff",
        "is invalid",
        "HANDOFF_HISTORY_INVALID",
      ),
      expected: {
        code: "HANDOFF_HISTORY_INVALID",
        failureCause: "envelope-parse: HANDOFF_HISTORY_INVALID",
      },
    },
    {
      label:
        "F2 a TypeError falls back to HANDOFF_UNSUPPORTED_VERSION and names the class",
      error: new TypeError("x"),
      expected: {
        code: "HANDOFF_UNSUPPORTED_VERSION",
        failureCause: "envelope-parse: TypeError",
      },
    },
    {
      label: "F3 a thrown string is a non-error value",
      error: "boom",
      expected: {
        code: "HANDOFF_UNSUPPORTED_VERSION",
        failureCause: "envelope-parse: non-error value",
      },
    },
  ])("$label", ({ error, expected }) => {
    // Arrange
    const caught: unknown = error;

    // Act
    const failure = describeEnvelopeParseFailure(caught);

    // Assert
    expect(failure).toEqual(expected);
  });
});

describe("envelope-parse failure cause pass-through", () => {
  it("F4 production validateEnvelope returns the envelope-parse cause for malformed JSON", () => {
    // Arrange
    const fileSystem = {
      glob: () => [],
      isFile: () => false,
      exists: () => false,
      isDirectory: () => false,
      listDirectory: () => [],
      readTextFile: () => "",
      writeTextFile: () => undefined,
      ensureDir: () => undefined,
    } satisfies FileSystem;
    const runner: CommandRunner = {
      run: () => ({ stdout: "", stderr: "", code: 0 }),
    };
    const materializer = createProductionHandoffMaterializer(
      fileSystem,
      runner,
    );

    // Act
    const validation =
      materializer.dependencies.validator.validateEnvelope("{");

    // Assert
    expect(validation).toMatchObject({
      envelope: null,
      primaryFailureCode: "HANDOFF_UNSUPPORTED_VERSION",
      failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION",
    });
  });

  it("F5 the materializer forwards a validation failureCause to the blocked result", async () => {
    // Arrange
    const scenario = createScenario();
    const materializer = new OrchestrationHandoffMaterializer({
      ...scenario.dependencies,
      validator: {
        ...scenario.dependencies.validator,
        validateEnvelope: () => ({
          envelope: null,
          primaryFailureCode: "HANDOFF_UNSUPPORTED_VERSION",
          affectedPaths: [],
          unsupportedCapabilities: [],
          failureCause: "envelope-parse: TypeError",
        }),
      },
    });

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
    expect(result.failureCause).toBe("envelope-parse: TypeError");
  });
});

describe("destination-projection failure cause", () => {
  it("F6 a projection error without a code yields destination-projection: TypeError", async () => {
    // Arrange
    const scenario = createScenario({
      transformEnvelope: (e) => ({
        ...e,
        lifecycle: undefined as unknown as HandoffEnvelope["lifecycle"],
      }),
    });
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.failureCause).toBe("destination-projection: TypeError");
  });

  it("F7 a projection error with a code yields destination-projection: HANDOFF_UNSUPPORTED_VERSION", async () => {
    // Arrange
    const scenario = createScenario({
      transformEnvelope: (e) => ({
        ...e,
        source: {
          ...e.source,
          expressionSchemaId: "codex.orchestrator-state",
        },
      }),
    });
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
    expect(result.failureCause).toBe(
      "destination-projection: HANDOFF_UNSUPPORTED_VERSION",
    );
  });
});
