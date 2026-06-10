---
name: implement-task
description: Use this skill when asked to implement a task that has already been refined into a clear implementation plan.
---

To implement a task, follow these steps:
- Create a new branch for the task using the skill `create-branch`.
- Evaluate if the task is well suited for test driven development (TDD). If so, use the `tdd` skill to implement the task using TDD principles. Most new features and bug fixes should be implemented using TDD.
- Once the implementation is complete, use the `run-tests` skill to run the tests and check that everything works as expected. This includes running the tests, type checks and linting. If the tests fail, debug the implementation and fix any issues until the tests pass.
- If the tests pass, commit the progress using the `commit-progress` skill.
