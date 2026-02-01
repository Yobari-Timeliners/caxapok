#!/bin/bash

# Script to run CI checks locally (same as GitHub Actions)
set -e

echo "Running CI checks locally..."
echo ""

echo "Installing dependencies..."
dart pub get
echo ""

echo "Checking formatting..."
dart format --set-exit-if-changed .
echo "Formatting passed!"
echo ""

echo "Analyzing code..."
dart analyze --fatal-infos
echo "Analysis passed!"
echo ""

echo "Running tests..."
dart test --coverage=coverage
echo "Formatting coverage data..."
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib 2>/dev/null || echo "Warning: Coverage tool not found, install with: dart pub global activate coverage"
echo "Tests passed!"
echo ""

echo "Checking code coverage..."
if [ -f coverage/lcov.info ]; then
    # Parse coverage data
    lines_found=$(grep -c "^LF:" coverage/lcov.info 2>/dev/null || echo "0")
    lines_hit=$(grep "^LH:" coverage/lcov.info 2>/dev/null | awk -F: '{sum += $2} END {print sum}' || echo "0")
    lines_total=$(grep "^LF:" coverage/lcov.info 2>/dev/null | awk -F: '{sum += $2} END {print sum}' || echo "0")
    
    if [ "$lines_total" -gt 0 ]; then
        coverage=$(awk "BEGIN {printf \"%.2f\", ($lines_hit / $lines_total) * 100}")
        echo "Code coverage: ${coverage}%"
        if [ "$(echo "$coverage < 80" | bc)" -eq 1 ]; then
            echo "Error: Coverage is below 80% (found: ${coverage}%)"
            exit 1
        else
            echo "Coverage meets minimum threshold (80%)"
        fi
    else
        echo "Warning: No coverage data found"
        exit 1
    fi
else
    echo "Error: Coverage file not found"
    exit 1
fi
echo ""

echo "Running pana analysis (pub.dev score)..."
if ! command -v pana &> /dev/null; then
    echo "Installing pana..."
    dart pub global activate pana
fi
dart pub global run pana --no-warning --exit-code-threshold 0
echo "Pana analysis passed!"
echo ""

echo "All CI checks passed successfully!"
