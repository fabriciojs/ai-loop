# PRD Implementation Task

You are implementing user stories from a PRD file autonomously. Work through one user story at a time, ensuring quality and completeness before moving on.

## Current Context

- **PRD File:** {{PRD_FILE}}
- **Target User Story:** {{USER_STORY}}

## Your Mission

Implement **{{USER_STORY}}** completely, following all acceptance criteria in the PRD.

## Progress Tracking (REQUIRED)

**You MUST use TodoWrite to track your progress throughout implementation.** This provides visibility into what you're doing.

When starting, create todos for the main phases:
1. Understanding {{USER_STORY}} requirements
2. Exploring codebase for patterns
3. Implementing the changes
4. Running validation (pint, phpstan, tests)
5. Updating PRD checkboxes
6. Committing changes

Update todo status as you work - mark items `in_progress` when starting and `completed` when done. This is critical for visibility.

## Implementation Process

### 1. Understand the User Story

First, read the PRD file and locate {{USER_STORY}}:
- Read all acceptance criteria carefully
- Understand the visual/functional requirements
- Note any dependencies on other user stories
- Check if there are pre-implementation decisions required (if yes, flag them)

**→ Update TodoWrite:** Mark "Understanding requirements" as completed

### 2. Explore the Codebase

Before writing code:
- Search for existing patterns and components that can be reused
- Understand the current file structure for the area you're modifying
- Look for similar implementations to maintain consistency
- Check existing tests for patterns to follow

**→ Update TodoWrite:** Mark "Exploring codebase" as completed

### 3. Implement the Changes

**→ Update TodoWrite:** Mark "Implementing changes" as in_progress

**For UI/Frontend user stories:** Use the `/frontend-design` skill to guide implementation. This skill ensures distinctive, production-grade interfaces that avoid generic AI aesthetics. Invoke it by running the skill before implementing visual components:
- Hero sections, landing pages, pricing displays
- Navigation, footers, and layout components
- Any user-facing visual elements

Follow these principles:
- **Simplicity first:** Implement the minimum needed to satisfy acceptance criteria
- **Reuse existing:** Use existing components, styles, and patterns
- **No over-engineering:** Don't add features or abstractions not explicitly required
- **Safety:** Avoid introducing security vulnerabilities (XSS, injection, etc.)
- **Consistency:** Match the existing code style and conventions
- **Design quality:** For frontend work, commit to a bold aesthetic direction with intentional choices

**→ Update TodoWrite:** Mark "Implementing changes" as completed when done

### 4. Validate Your Changes

**→ Update TodoWrite:** Mark "Running validation" as in_progress

After implementing, run ALL quality checks, having restarted the local environment containers:

```bash
# Start/Restart local containers
kool start app cache database s3local

# Code style - must pass
kool run pint

# Static analysis - must pass
kool run phpstan

# Unit/Feature tests - must pass
kool run reset-test
kool run test

# Browser tests - must pass (for UI changes)
kool run reset-test:browser
kool run test:browser
```

**Important:** Fix any failures before proceeding. The implementation is not complete until all checks pass green. That includes possibly extending/adding more test coverage as deemed necessary.

**→ Update TodoWrite:** Mark "Running validation" as completed when all checks pass

### 5. Update the PRD (STANDARDIZED FORMAT)

**→ Update TodoWrite:** Mark "Updating PRD checkboxes" as in_progress

Once the implementation passes all checks, update the PRD with the standardized completion format:

#### User Story Completion Rules:

1. **Acceptance Criteria Checkboxes:**
   - Change `- [ ]` to `- [x]` for each completed criterion
   - Only mark items that are truly implemented AND verified by tests

2. **User Story Status Line:**
   After the user story title line (e.g., `### US-001: Hero Section`), ensure there is a status line:
   - If ALL acceptance criteria are checked `[x]`: Add or update to `**Status: ✅ Complete**`
   - If SOME criteria are checked: Add or update to `**Status: 🔄 In Progress**`
   - If NONE are checked: `**Status: ⏳ Pending**`

3. **Example format:**
   ```markdown
   ### US-001: Hero Section
   **Status: ✅ Complete**

   **Acceptance Criteria:**
   - [x] First criterion completed
   - [x] Second criterion completed
   ```

4. **Do NOT:**
   - Mark criteria as complete if tests are failing
   - Partially mark a criterion (it's either done or not)
   - Forget to update the Status line after marking all criteria complete

**→ Update TodoWrite:** Mark "Updating PRD checkboxes" as completed

### 6. Review Your Work

Before committing, verify:
- All acceptance criteria for {{USER_STORY}} are marked complete with `[x]`
- The Status line shows `✅ Complete`
- The feature works as specified
- No regressions in existing functionality
- Code follows project conventions

### 7. Commit the Changes

**→ Update TodoWrite:** Mark "Committing changes" as in_progress

Create a semantic commit with all changes for this user story:

```bash
git add -A
git commit -m "feat: <brief description> ({{USER_STORY}})

<detailed description of what was implemented>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

Use appropriate prefix: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`

**→ Update TodoWrite:** Mark "Committing changes" as completed - ALL TODOS SHOULD NOW BE COMPLETE

## Quality Standards

### Code Quality
- Follow existing patterns in the codebase
- Use strict types where the codebase uses them
- Maintain multi-tenancy scope (always consider team context)
- Use soft deletes consistently with other models

### Testing
- Add tests for new functionality when appropriate
- Browser tests for public-facing UI changes
- Ensure existing tests continue to pass

### UI/UX (for frontend changes)
- Mobile-responsive (test at 375px, 768px, 1280px)
- Respect `prefers-reduced-motion` for animations
- Use existing color palette (kool-blue, pink-800, etc.)
- Use existing typography (Nunito font family)
- Follow accessibility best practices

## Decision Making

When facing trade-offs:
- **Prefer simplicity** over flexibility
- **Prefer existing patterns** over new abstractions
- **Prefer explicit code** over clever shortcuts
- **Prefer completeness** over partial implementation

If a user story has unresolved decisions (marked TBD in the PRD):
- Flag the decision needed
- Make a reasonable default choice
- Document your choice in the commit message
- Continue with implementation

## Error Recovery

If tests fail:
1. Read the error message carefully
2. Fix the root cause (not just symptoms)
3. Re-run tests until green
4. If stuck after 3 attempts, leave a note in the PRD about the blocker

If you encounter blockers:
- Document what's blocking in the PRD
- Commit any partial progress with clear notes
- Move to the next user story if possible

## Files to Reference

- **CLAUDE.md** - Project conventions and commands
- **tests/CLAUDE.md** - Testing patterns and commands
- **app/CLAUDE.md** - Code patterns and architecture
- **database/CLAUDE.md** - Schema and relationships

## Available Skills

- `/frontend-design` - Use for UI/visual implementation. Creates distinctive, production-grade interfaces with bold aesthetic choices. Invoke before implementing any user-facing components.
- `/prd` - Generate PRD documents (not typically needed during implementation)

## Important Reminders

- This is autonomous implementation - be thorough and careful
- All git and kool commands are safe to run locally
- Quality checks MUST pass before marking anything complete
- One user story at a time - focus and complete
- Update the PRD checkboxes to track progress accurately
- **CRITICAL: After committing, you are DONE. Do not continue or wait for further input. Exit immediately.**

Now, proceed to implement {{USER_STORY}} from {{PRD_FILE}}.

**When finished:** After the commit is complete and all todos are marked done, stop immediately. Do not ask follow-up questions or wait for input.
