/**
 * Unit tests for the push-down decision-table comparator (issue #1029).
 *
 * One case per row of spec `### Decision Table`; each asserts the action and
 * whether an apply run writes the file.
 */

import {
  classifyPayloadFile,
  type PayloadComparisonInput,
  PUSH_DOWN_ACTION_REASONS,
  type PushDownAction,
  UNMANAGED_OVERWRITE_REASON,
} from "../../../src/lib/push-down/push-down-plan-comparator";

const D = "d".repeat(64);
const M = "e".repeat(64);
const P = "f".repeat(64);

/** Build a comparator input with the opt-in off. */
function input(
  destinationHash: string | undefined,
  manifestHash: string | undefined,
  payloadHash: string,
): PayloadComparisonInput {
  return {
    destinationHash,
    manifestHash,
    payloadHash,
    overwriteUnmanaged: false,
  };
}

describe("classifyPayloadFile", () => {
  const rows: ReadonlyArray<
    readonly [PushDownAction, PayloadComparisonInput, boolean]
  > = [
    ["create", input(undefined, undefined, P), true],
    ["deleted-locally", input(undefined, M, P), false],
    ["unchanged", input(M, M, M), false],
    ["update", input(M, M, P), true],
    ["converged", input(P, M, P), false],
    ["conflict", input(D, M, P), false],
    ["adopt", input(P, undefined, P), false],
    ["unmanaged-conflict", input(D, undefined, P), false],
  ];

  it.each(rows)("classifies %s", (action, comparison, write) => {
    const result = classifyPayloadFile(comparison);
    expect(result.action).toBe(action);
    expect(result.write).toBe(write);
    expect(result.reason).toBe(PUSH_DOWN_ACTION_REASONS[action]);
  });

  it("overwrites unmanaged-conflict when overwriteUnmanaged is true", () => {
    const result = classifyPayloadFile({
      destinationHash: D,
      manifestHash: undefined,
      payloadHash: P,
      overwriteUnmanaged: true,
    });
    expect(result).toEqual({
      action: "unmanaged-conflict",
      write: true,
      recordHash: P,
      reason: UNMANAGED_OVERWRITE_REASON,
    });
  });

  it("returns the payload hash for create, update, adopt and converged", () => {
    expect(classifyPayloadFile(input(undefined, undefined, P)).recordHash).toBe(
      P,
    );
    expect(classifyPayloadFile(input(M, M, P)).recordHash).toBe(P);
    expect(classifyPayloadFile(input(P, undefined, P)).recordHash).toBe(P);
    expect(classifyPayloadFile(input(P, M, P)).recordHash).toBe(P);
  });

  it("keeps the previous manifest hash for conflict", () => {
    expect(classifyPayloadFile(input(D, M, P)).recordHash).toBe(M);
    expect(classifyPayloadFile(input(undefined, M, P)).recordHash).toBe(M);
    expect(classifyPayloadFile(input(M, M, M)).recordHash).toBe(M);
  });

  it("records no hash for a non-opted unmanaged-conflict", () => {
    expect(
      classifyPayloadFile(input(D, undefined, P)).recordHash,
    ).toBeUndefined();
  });
});
