---
name: yo-goal
description: "Review goals (milestones) and their progress, or define a new goal for a final outcome"
argument-hint: "Optional: a goal to review, or the outcome you want to reach"
agent: Work Buddy
---
Work with goals in the GitHub Project. Input: ${input:goal}

1. Run `./scripts/yo-gh goals` and `./scripts/yo-gh today`.
2. If the input names an existing goal, or is empty: report each goal with due date, "done when", open/closed counts, and its items grouped by Status; flag goals with no due date, no "done when", or no open items, and goals past their due date.
3. If the input describes a new outcome: propose a title (follow the existing style), a due date, and a one-sentence "done when"; list existing issues that would belong to it and tasks still missing. After the human agrees, run `./scripts/yo-gh goal-create` and assign the issues with `./scripts/yo-gh milestone`.
4. Never close a goal; only the human does.
