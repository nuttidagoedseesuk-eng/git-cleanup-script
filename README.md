# Git Clean Safe

A professional, safe utility to clean up untracked files in Git repositories with preview mode, logging, and advanced filtering options.

## 🌟 Features

- ✅ **Preview Mode** - See what will be deleted before confirming
- ✅ **Logging** - Automatic logging with timestamps
- ✅ **Dry-run** - Test cleanup without making changes
- ✅ **Exclude Patterns** - Skip specific files/folders
- ✅ **Ignore Files Support** - Clean files listed in .gitignore
- ✅ **Color Output** - Beautiful, readable terminal output
- ✅ **Error Handling** - Comprehensive validation and error messages
- ✅ **Repository Info** - Shows current repo and branch
- ✅ **Force Mode** - Skip confirmations for automation

## 📋 Requirements

- Bash 4.0+
- Git 2.0+
- Linux or macOS

## 🚀 Quick Start

```bash
# Make script executable
chmod +x scripts/git-clean-safe.sh

# View help
./scripts/git-clean-safe.sh --help

# Preview what will be deleted
./scripts/git-clean-safe.sh --dry-run

# Clean up untracked files
./scripts/git-clean-safe.sh

# Clean with logging
./scripts/git-clean-safe.sh --log
```

## 📖 Usage Guide

For more details, see:
- [Basic Usage](./docs/basic-usage.md)
- [Advanced Usage](./docs/advanced-usage.md)

## 📄 License

MIT License - See LICENSE file for details
