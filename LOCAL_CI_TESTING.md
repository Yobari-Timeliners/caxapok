# Testing GitHub Actions Locally

Test the CI workflow locally before pushing to GitHub.

## Method 1: Local Script (Recommended)

Run all CI checks:

```bash
chmod +x scripts/run_ci_locally.sh
./scripts/run_ci_locally.sh
```

The script runs:
- Code formatting verification
- Static analysis
- Tests with coverage
- Coverage verification (80% minimum)
- Pana analysis (pub.dev scoring)

### Prerequisites

Optional (for HTML coverage reports):
```bash
# macOS
brew install lcov

# Linux
sudo apt-get install lcov
```

## Method 2: Using Act (Run Actual GitHub Actions)

[Act](https://github.com/nektos/act) runs GitHub Actions locally using Docker.

### Install Act

```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Run Workflows

```bash
# Run all workflows
act

# Run specific job
act -j analyze
act -j test
act -j pana

# Run on pull request event
act pull_request

# Run with verbose output
act -v
```

### Troubleshooting
If act fails, you might need Docker desktop running, or use a smaller image:
```bash
act -P ubuntu-latest=node:16-buster-slim
```

## Method 3: Individual Commands

Run each check separately:

```bash
# Get dependencies
dart pub get

# Check formatting
dart format --set-exit-if-changed .

# Run analysis
dart analyze --fatal-infos

# Run tests with coverage
dart test --coverage=coverage

# Format coverage data
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib

# Run pana analysis
dart pub global activate pana
dart pub global run pana --no-warning
```

## Quick Pre-Push Check

```bash
./scripts/run_ci_locally.sh && echo "Ready to push!"
```

## CI Workflow

The GitHub Actions workflow includes:

1. **Analyze Job**
   - Format verification
   - Static analysis with very_good_analysis
   
2. **Test Job**
   - Run all tests
   - Generate coverage reports
   - Verify minimum 80% code coverage
   
3. **Pana Job**
   - Analyze pub.dev score
   - Check package quality

All jobs run in parallel for faster feedback.
