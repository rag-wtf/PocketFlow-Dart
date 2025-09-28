# Spec: Python Parity

## Description

This document outlines the detailed plan to address the functional differences between the PocketFlow-Dart library and its original Python counterpart. A thorough review confirms that this plan is comprehensive and addresses all material functional differences identified during the gap analysis.

The core principle of the plan is to **Enhance, Don't Replace**. We will retain the superior architectural choices of the Dart port (e.g., deep cloning for state isolation, unified `Future`-based async model) while introducing the Python version's specific behaviors as new, clearly-named classes. This will make the Dart library a superset of the Python version's capabilities.

## Clarifications

### Session 1

No clarifications needed as the python-parity-plan.md is very detailed.

## 1. Review Outcome

This document outlines the detailed plan to address the functional differences between the PocketFlow-Dart library and its original Python counterpart. A thorough review confirms that this plan is comprehensive and addresses all material functional differences identified during the gap analysis.

The core principle of the plan is to **Enhance, Don't Replace**. We will retain the superior architectural choices of the Dart port (e.g., deep cloning for state isolation, unified `Future`-based async model) while introducing the Python version's specific behaviors as new, clearly-named classes. This will make the Dart library a superset of the Python version's capabilities.

## 2. High-Level Strategy: Enhance, Don't Replace

We will keep the robust Dart implementations and introduce new classes to provide the specific processing strategies found in the Python version. This will result in some breaking changes (class renames) that are necessary for the long-term clarity and maintainability of the library.

## 3. Detailed Plan to Address Functional Differences

### 3.1. Difference: `AsyncBatchFlow` Behavior

*   **The Difference:**
    *   **Python `AsyncBatchFlow`:** Iterates through a list of items and executes the entire flow for *each item*.
    *   **Current Dart `AsyncBatchFlow`:** Executes the flow *once*, passing the entire batch of items into the `shared` context, expecting the nodes to handle the list.

*   **The Plan:**
    1.  **Rename for Clarity (Breaking Change):** Rename the existing Dart `AsyncBatchFlow` to `StreamingBatchFlow`. This name better reflects its behavior of streaming a whole batch through a single flow execution.
    2.  **Implement Python-Equivalent Behavior:** Create a new class named `AsyncBatchFlow`. This class will extend `AsyncFlow` and its `run` method will replicate the logic from the current synchronous `BatchFlow`.

*   **The Outcome:** The Dart library will offer two distinct and clearly named async batch strategies: `AsyncBatchFlow` (parity with Python) and `StreamingBatchFlow` (for high-performance single-flow batch processing).

### 3.2. Difference: `AsyncParallelBatchFlow` Behavior

*   **The Difference:**
    *   **Python `AsyncParallelBatchFlow`:** Executes the *entire flow in parallel* for each item in a batch.
    *   **Current Dart `AsyncParallelBatchFlow`:** For each item, it executes the *nodes within the flow in parallel*.

*   **The Plan:**
    1.  **Rename for Clarity (Breaking Change):** Rename the existing Dart `AsyncParallelBatchFlow` to `ParallelNodeBatchFlow`.
    2.  **Implement Python-Equivalent Behavior:** Create a new class named `AsyncParallelBatchFlow` whose `run` method uses `Future.wait()` to execute `super.run()` for each item concurrently.

*   **The Outcome:** The Dart library will provide two powerful and distinct parallelization models: `AsyncParallelBatchFlow` (parallel workflows, parity with Python) and `ParallelNodeBatchFlow` (parallel nodes within a workflow).

### 3.3. Difference: `BatchNode` Concrete vs. Abstract Behavior

*   **The Difference:**
    *   **Python `BatchNode`:** A concrete class that automatically iterates over a batch and applies a single-item `exec` method with per-item retry logic.
    *   **Current Dart `BatchNode`:** An `abstract` class defining a contract.

*   **The Plan:**
    1.  **Keep Existing Dart Abstractions:** The current `BatchNode` contract and convenience wrappers (`AsyncBatchNode`) will be retained.
    2.  **Implement Python-Equivalent Behavior:** Create a new `abstract` class named `IteratingBatchNode<I, O>` that extends `Node`. This class will have a new `abstract` method `Future<O> execItem(I item)` and will override the `run` method to implement automatic iteration with **per-item retry logic**, exactly matching the Python behavior.

*   **The Outcome:** Developers will have multiple ways to create batch-processing nodes, including the automatic iteration pattern from Python (`IteratingBatchNode`).

## 4. Summary of Resolution

| Difference Category | How the Plan Addresses It | Confirmation |
| :--- | :--- | :--- |
| **`AsyncBatchFlow` Behavior** | Renames existing class and adds a new one with Python's behavior. | **Fully Addressed.** |
| **`AsyncParallelBatchFlow` Behavior** | Renames existing class and adds a new one with Python's behavior. | **Fully Addressed.** |
| **`BatchNode` Implementation** | Keeps existing abstractions and adds a new `IteratingBatchNode` with per-item logic to match Python. | **Fully Addressed.** |
| **State Isolation (Cloning)** | The plan is built upon Dart's superior deep cloning model. | **Retained by Design.** |
| **Unified Async Model** | The plan leverages Dart's `Future`-based architecture. | **Retained by Design.** |
| **Parameter Passing in `Flow`** | The superior Dart implementation (`shared['__node_params__']`) is intentionally preserved over the Python `set_params()` method. | **Considered and Intentionally Preserved.** |

This plan ensures the PocketFlow-Dart library will achieve full functional parity with its Python counterpart while retaining its own architectural strengths.

## 5. Value Analysis of Proposed Additions

It is important to critically evaluate whether adding complexity truly adds value. The proposed enhancements are not "better" in the sense of replacing the existing Dart implementations, but are "better" in that they make the library as a whole **more complete, flexible, and powerful** by offering developers more strategic choices.

The core principle of the plan is to add the Python behaviors as **alternatives**, not replacements.

### 5.1. `AsyncBatchFlow` (New) vs. `StreamingBatchFlow` (Renamed)

*   **Existing (`StreamingBatchFlow`):** Superior for **performance**. It runs the flow only once, making it ideal for high-throughput, low-overhead processing of batch-aware nodes.
*   **Proposed (`AsyncBatchFlow`):** Superior for **isolation and simplicity**. By cloning the flow for each item, it guarantees zero side effects and allows the use of simple, single-item nodes in a batch context.
*   **Verdict:** Neither is strictly "better"; they serve different use cases. Having both is a significant enhancement.

### 5.2. `AsyncParallelBatchFlow` (New) vs. `ParallelNodeBatchFlow` (Renamed)

*   **Existing (`ParallelNodeBatchFlow`):** A specialized tool, superior for reducing the latency of processing a **single item** by running its internal steps concurrently.
*   **Proposed (`AsyncParallelBatchFlow`):** A general-purpose tool, superior for increasing the throughput of processing **many items** by running the entire workflow for each item in parallel.
*   **Verdict:** These two classes solve completely different problems. The proposed addition fills a major functional gap. The library is unequivocally better with both options.

### 5.3. `IteratingBatchNode` (New) vs. `AsyncBatchNode` (Existing)

*   **Existing (`AsyncBatchNode`):** Superior when you need **full control** over the batch processing logic.
*   **Proposed (`IteratingBatchNode`):** Superior for **developer convenience and resilience**. It removes boilerplate for the common "do X to each item" pattern and adds a powerful, non-trivial feature: **per-item retry logic**.
*   **Verdict:** The proposed `IteratingBatchNode` is a higher-level abstraction that perfectly complements the existing, more flexible `AsyncBatchNode`.

### Conclusion

The plan correctly identifies that the functional differences are not matters of "better" or "worse," but of **different strategic choices for different problems.** By adding these patterns, the PocketFlow-Dart library will be more powerful, clearer, and more flexible, making it a true superset of its Python counterpart in both features and architectural quality.
