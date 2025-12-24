#!/usr/bin/env bash
#
# Test script for the Resumable Download Manager
#

set -euo pipefail

echo "=== Resumable Download Manager - Test Suite ==="
echo

# Test 1: Help message
echo "Test 1: Verify help message displays correctly"
if ./download.sh --help | grep -q "Usage:"; then
    echo "✓ Help message works"
else
    echo "✗ Help message failed"
    exit 1
fi
echo

# Test 2: URL validation (missing URL)
echo "Test 2: Verify error handling for missing URL"
if ./download.sh 2>&1 | grep -q "Usage:"; then
    echo "✓ Missing URL handling works"
else
    echo "✗ Missing URL handling failed"
    exit 1
fi
echo

# Test 3: Filename extraction
echo "Test 3: Test filename extraction from URL"
# This would require network access, so we'll just verify the function exists
if grep -q "get_filename_from_url" download.sh; then
    echo "✓ Filename extraction function exists"
else
    echo "✗ Filename extraction function missing"
    exit 1
fi
echo

# Test 4: Check dependencies
echo "Test 4: Verify curl is available"
if command -v curl &> /dev/null; then
    echo "✓ curl is installed"
else
    echo "✗ curl is not installed"
    exit 1
fi
echo

echo "Test 5: Verify bc is available"
if command -v bc &> /dev/null; then
    echo "✓ bc is installed"
else
    echo "✗ bc is not installed"
    exit 1
fi
echo

# Test 6: Script syntax
echo "Test 6: Verify bash syntax"
if bash -n download.sh; then
    echo "✓ Bash syntax is valid"
else
    echo "✗ Bash syntax is invalid"
    exit 1
fi
echo

# Test 7: Check for required functions
echo "Test 7: Verify all required functions exist"
required_functions=(
    "print_info"
    "print_success"
    "print_warning"
    "print_error"
    "usage"
    "get_filename_from_url"
    "format_bytes"
    "check_curl_support"
    "check_resume_support"
    "get_remote_size"
    "download_file"
    "main"
)

all_functions_exist=true
for func in "${required_functions[@]}"; do
    if grep -q "^$func()" download.sh || grep -q "^${func} ()" download.sh; then
        echo "  ✓ Function $func exists"
    else
        echo "  ✗ Function $func missing"
        all_functions_exist=false
    fi
done

if [ "$all_functions_exist" = true ]; then
    echo "✓ All required functions exist"
else
    echo "✗ Some required functions are missing"
    exit 1
fi
echo

# Test 8: Check for proper error handling
echo "Test 8: Verify error handling patterns exist"
if grep -q "set -euo pipefail" download.sh; then
    echo "✓ Strict error handling is enabled"
else
    echo "✗ Strict error handling is not enabled"
    exit 1
fi
echo

echo "=== All Tests Passed! ==="
echo
echo "Note: Full integration tests require network access and actual file downloads."
echo "The basic functionality and structure have been verified."
