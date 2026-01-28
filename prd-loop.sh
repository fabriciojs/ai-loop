#!/bin/bash
#
# PRD Implementation Loop Script
# Iteratively calls Claude CLI to implement user stories from a PRD file
#
# Usage: ./scripts/prd-loop.sh <prd-file>
# Example: ./scripts/prd-loop.sh tasks/100-prd-website-pricing-revamp.md
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROMPT_FILE="scripts/loop-prompt.md"
MAX_ITERATIONS=50  # Safety limit
ITERATION=0

# Check arguments
if [ -z "$1" ]; then
    echo -e "${RED}Error: PRD file path required${NC}"
    echo "Usage: $0 <prd-file>"
    echo "Example: $0 tasks/100-prd-website-pricing-revamp.md"
    exit 1
fi

PRD_FILE="$1"

# Validate PRD file exists
if [ ! -f "$PRD_FILE" ]; then
    echo -e "${RED}Error: PRD file not found: $PRD_FILE${NC}"
    exit 1
fi

# Validate prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: Prompt file not found: $PROMPT_FILE${NC}"
    echo "Expected at: $PROMPT_FILE"
    exit 1
fi

# Function to count incomplete user stories
count_incomplete_stories() {
    # Count US-XXX sections that have unchecked boxes
    grep -E "^### US-[0-9]+" "$PRD_FILE" | while read -r line; do
        us_id=$(echo "$line" | grep -oE "US-[0-9]+")
        # Get the section content until next ### or ## (sed '$d' removes last line - works on macOS)
        section=$(sed -n "/^### $us_id/,/^##/p" "$PRD_FILE" | sed '$d')
        # Check if there are unchecked boxes
        if echo "$section" | grep -q "\- \[ \]"; then
            echo "$us_id"
        fi
    done | wc -l | tr -d ' '
}

# Function to get next incomplete user story ID
get_next_incomplete_story() {
    grep -E "^### US-[0-9]+" "$PRD_FILE" | while read -r line; do
        us_id=$(echo "$line" | grep -oE "US-[0-9]+")
        # Get the section content until next ### or ## (sed '$d' removes last line - works on macOS)
        section=$(sed -n "/^### $us_id/,/^##/p" "$PRD_FILE" | sed '$d')
        # Check if there are unchecked boxes
        if echo "$section" | grep -q "\- \[ \]"; then
            echo "$us_id"
            break
        fi
    done
}

# Function to display user story status summary
show_story_status() {
    echo ""
    echo -e "${BLUE}User Story Status Summary:${NC}"
    echo -e "${BLUE}──────────────────────────${NC}"

    grep -E "^### US-[0-9]+" "$PRD_FILE" | while read -r line; do
        us_id=$(echo "$line" | grep -oE "US-[0-9]+")
        us_title=$(echo "$line" | sed "s/^### $us_id: //")

        # Get the section content (sed '$d' removes last line - works on macOS)
        section=$(sed -n "/^### $us_id/,/^##/p" "$PRD_FILE" | sed '$d')

        # Count checkboxes (grep -c outputs 0 when no matches, || true prevents exit on no match)
        total=$(echo "$section" | grep -c "\- \[.\]" || true)
        checked=$(echo "$section" | grep -c "\- \[x\]" || true)

        # Determine status
        if [ "$total" -eq 0 ]; then
            status="${YELLOW}⏳ No criteria${NC}"
        elif [ "$checked" -eq "$total" ]; then
            status="${GREEN}✅ Complete${NC}"
        elif [ "$checked" -gt 0 ]; then
            status="${YELLOW}🔄 In Progress ($checked/$total)${NC}"
        else
            status="${RED}⏳ Pending (0/$total)${NC}"
        fi

        echo -e "  $us_id: $status"
    done
    echo ""
}

# Function to show what the subagent will be doing
show_next_story_preview() {
    local us_id="$1"
    echo -e "${BLUE}Preview of $us_id:${NC}"
    echo -e "${BLUE}──────────────────────────${NC}"

    # Get the section and show acceptance criteria (sed '$d' removes last line - works on macOS)
    section=$(sed -n "/^### $us_id/,/^##/p" "$PRD_FILE" | sed '$d')

    # Show the title
    title=$(echo "$section" | head -n 1)
    echo -e "${GREEN}$title${NC}"

    # Show unchecked acceptance criteria
    echo -e "\n${YELLOW}Pending acceptance criteria:${NC}"
    echo "$section" | grep "\- \[ \]" | head -5 | while read -r criteria; do
        echo -e "  $criteria"
    done

    remaining=$(echo "$section" | grep -c "\- \[ \]" || true)
    if [ "$remaining" -gt 5 ]; then
        echo -e "  ${YELLOW}... and $((remaining - 5)) more${NC}"
    fi
    echo ""
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PRD Implementation Loop${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "PRD File: ${GREEN}$PRD_FILE${NC}"
echo -e "Prompt File: ${GREEN}$PROMPT_FILE${NC}"

# Show initial status summary
show_story_status

# Initial count
INITIAL_INCOMPLETE=$(count_incomplete_stories)
echo -e "Found ${YELLOW}$INITIAL_INCOMPLETE${NC} incomplete user stories"
echo ""

if [ "$INITIAL_INCOMPLETE" -eq 0 ]; then
    echo -e "${GREEN}All user stories are already completed!${NC}"
    exit 0
fi

# Main loop
while true; do
    ITERATION=$((ITERATION + 1))

    # Safety check
    if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
        echo -e "${RED}Safety limit reached ($MAX_ITERATIONS iterations). Stopping.${NC}"
        exit 1
    fi

    # Check for remaining incomplete stories
    REMAINING=$(count_incomplete_stories)

    if [ "$REMAINING" -eq 0 ]; then
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}🎉 All user stories completed!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "Total iterations: $ITERATION"
        echo ""
        show_story_status
        exit 0
    fi

    NEXT_STORY=$(get_next_incomplete_story)

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Iteration $ITERATION / Remaining: $REMAINING${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Show what the subagent will be working on
    show_next_story_preview "$NEXT_STORY"

    echo -e "${YELLOW}Subagent will now:${NC}"
    echo -e "  1. 📖 Read and understand ${GREEN}$NEXT_STORY${NC} requirements"
    echo -e "  2. 🔍 Explore codebase for patterns"
    echo -e "  3. 💻 Implement the changes"
    echo -e "  4. ✅ Run validation (pint, phpstan, tests)"
    echo -e "  5. 📝 Update PRD checkboxes"
    echo -e "  6. 📦 Commit changes"
    echo ""

    # Read the prompt template
    PROMPT_TEMPLATE=$(cat "$PROMPT_FILE")

    # Substitute variables in the prompt
    PROMPT="${PROMPT_TEMPLATE//\{\{PRD_FILE\}\}/$PRD_FILE}"
    PROMPT="${PROMPT//\{\{USER_STORY\}\}/$NEXT_STORY}"

    # Call Claude CLI with the prompt
    # Using --dangerously-skip-permissions to allow autonomous operation
    # The prompt instructs Claude to be careful and run tests
    echo -e "${YELLOW}Calling Claude CLI...${NC}"
    echo ""

    if claude --dangerously-skip-permissions -p "$PROMPT"; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ Claude CLI completed iteration for $NEXT_STORY${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ Claude CLI exited with error. Stopping loop.${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        show_story_status
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}Checking progress...${NC}"

    # Show updated status summary
    show_story_status

    sleep 2  # Brief pause before next iteration
done
