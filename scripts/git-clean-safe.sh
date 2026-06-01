#!/bin/bash

###############################################################################
# Git Safe Clean - Clean up untracked files with safety features
# Features:
#   - Preview mode before deletion
#   - Log cleanup actions
#   - Support for ignored files cleanup
#   - Dry-run option
#   - Exclude patterns
#   - Color output
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
CLEAN_IGNORED=false
VERBOSE=false
LOG_FILE=""
EXCLUDE_PATTERNS=()

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_LOG_FILE="${SCRIPT_DIR}/git-cleanup.log"

###############################################################################
# Functions
###############################################################################

# Print usage information
usage() {
    cat << EOF
${BLUE}Git Safe Clean${NC} - Clean up untracked files safely

${GREEN}Usage:${NC}
    $(basename "$0") [OPTIONS]

${GREEN}Options:${NC}
    -h, --help              Show this help message
    -d, --dry-run           Show what would be deleted without actually deleting
    -i, --ignore            Also clean ignored files (uses git clean -fdX)
    -l, --log [FILE]        Save cleanup log to file (default: $DEFAULT_LOG_FILE)
    -e, --exclude PATTERN   Exclude files matching pattern (can be used multiple times)
    -v, --verbose           Show detailed output
    -f, --force             Skip confirmation prompts (use with caution!)

${GREEN}Examples:${NC}
    # Preview what will be deleted
    $(basename "$0") --dry-run

    # Clean untracked files with log
    $(basename "$0") --log

    # Clean including ignored files, excluding node_modules
    $(basename "$0") --ignore --exclude 'node_modules' --log

    # Force clean without confirmation
    $(basename "$0") --force --dry-run

EOF
    exit 0
}

# Print colored message
print_msg() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print info message
info() {
    print_msg "$BLUE" "ℹ  $1"
}

# Print success message
success() {
    print_msg "$GREEN" "✓ $1"
}

# Print warning message
warn() {
    print_msg "$YELLOW" "⚠ $1"
}

# Print error message
error() {
    print_msg "$RED" "✗ $1"
}

# Log message to file
log_message() {
    local message=$1
    if [ -n "$LOG_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
    fi
}

# Check if it's a git repository
check_git_repo() {
    if [ ! -d ".git" ]; then
        error "Not a git repository!"
        error "Please run this script from the root of a git repository."
        exit 1
    fi
}

# Get git repository info
get_repo_info() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    info "Repository: $repo_root"
    info "Current branch: $branch"
}

# Build git clean command
build_git_clean_cmd() {
    local cmd="git clean"
    
    if [ "$DRY_RUN" = true ]; then
        cmd="$cmd -n"
    fi
    
    cmd="$cmd -fd"
    
    if [ "$CLEAN_IGNORED" = true ]; then
        cmd="$cmd -X"
    fi
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        cmd="$cmd -e '$pattern'"
    done
    
    echo "$cmd"
}

# Count files that will be deleted
count_files() {
    local cmd
    cmd=$(build_git_clean_cmd)
    cmd="${cmd//-n/-nd}"  # Use -nd for preview
    
    local count
    count=$(eval "$cmd" 2>/dev/null | wc -l)
    echo "$count"
}

# Show preview of files to be deleted
preview_cleanup() {
    local cmd
    cmd=$(build_git_clean_cmd)
    cmd="${cmd//-fd/-fnd}"  # Use -nd for preview
    
    info "Preview of files to be deleted:"
    echo ""
    
    if eval "$cmd" 2>/dev/null; then
        echo ""
    else
        warn "No untracked files found"
        return 1
    fi
}

# Perform cleanup
perform_cleanup() {
    local cmd
    cmd=$(build_git_clean_cmd)
    
    info "Starting cleanup..."
    
    if [ "$DRY_RUN" = true ]; then
        warn "DRY RUN MODE - No files will be deleted"
        eval "$cmd"
        success "Dry run completed."
    else
        if eval "$cmd"; then
            success "Cleanup completed successfully."
            log_message "Cleanup completed successfully"
        else
            error "Cleanup encountered an error"
            log_message "Cleanup failed"
            return 1
        fi
    fi
}

# Show cleanup summary
show_summary() {
    echo ""
    info "Cleanup Summary:"
    echo "  Dry-run mode: $([ "$DRY_RUN" = true ] && echo "Yes" || echo "No")"
    echo "  Clean ignored files: $([ "$CLEAN_IGNORED" = true ] && echo "Yes" || echo "No")"
    if [ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]; then
        echo "  Exclude patterns:"
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            echo "    - $pattern"
        done
    fi
}

# Ask yes/no question
ask_yes_no() {
    local question=$1
    local default=$2  # "y" or "n"
    local prompt
    
    if [ "$default" = "y" ]; then
        prompt="${question} [Y/n]: "
    else
        prompt="${question} [y/N]: "
    fi
    
    read -p "$(echo -e ${YELLOW}${prompt}${NC})" -r ans
    
    if [ -z "$ans" ]; then
        [ "$default" = "y" ] && return 0 || return 1
    fi
    
    [ "$ans" = "y" ] || [ "$ans" = "Y" ]
}

###############################################################################
# Main
###############################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -i|--ignore)
                CLEAN_IGNORED=true
                shift
                ;;
            -l|--log)
                LOG_FILE="${2:-$DEFAULT_LOG_FILE}"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    # Validate git repository
    check_git_repo
    
    echo ""
    print_msg "$BLUE" "╔════════════════════════════════════════╗"
    print_msg "$BLUE" "║     Git Safe Clean - File Cleanup      ║"
    print_msg "$BLUE" "╚════════════════════════════════════════╝"
    echo ""
    
    # Show repository info
    get_repo_info
    echo ""
    
    # Show summary
    show_summary
    echo ""
    
    # Initialize log file
    if [ -n "$LOG_FILE" ]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        log_message "Git cleanup started"
        log_message "Repository: $(git rev-parse --show-toplevel)"
        log_message "Branch: $(git rev-parse --abbrev-ref HEAD)"
        info "Log file: $LOG_FILE"
    fi
    
    # Check if there are files to clean
    local file_count
    file_count=$(count_files)
    
    if [ "$file_count" -eq 0 ]; then
        success "No untracked files found. Repository is clean!"
        log_message "No files to clean"
        exit 0
    fi
    
    info "Found $file_count untracked file(s)"
    echo ""
    
    # Show preview
    if ! preview_cleanup; then
        info "Nothing to clean"
        exit 0
    fi
    
    # Ask for confirmation
    echo ""
    if [ "${FORCE:-false}" = true ]; then
        warn "Running in force mode - skipping confirmation"
        proceed=true
    else
        if ask_yes_no "Proceed with deletion?" "n"; then
            proceed=true
        else
            info "Cancelled."
            log_message "Cleanup cancelled by user"
            exit 0
        fi
    fi
    
    if [ "$proceed" = true ]; then
        echo ""
        perform_cleanup
        echo ""
        success "Done!"
    fi
}

# Run main function
main "$@"
