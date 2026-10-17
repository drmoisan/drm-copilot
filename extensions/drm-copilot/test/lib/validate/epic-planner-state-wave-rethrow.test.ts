import { describe, expect, it, jest } from "@jest/globals";

jest.mock("../../../src/lib/validate/epic-wave-computation", () => ({
  ...jest.requireActual<Record<string, unknown>>(
    "../../../src/lib/validate/epic-wave-computation",
  ),
  computeWaveNumbers: () => {
    throw new RangeError("wave computation failed");
  },
}));

import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

describe("validateEpicPlannerStateText wave computation failure", () => {
  it("rethrows a wave computation error that is not a cycle", () => {
    const text = JSON.stringify({ features: [] });

    const validate = () => validateEpicPlannerStateText(text);

    expect(validate).toThrow("wave computation failed");
  });
});
