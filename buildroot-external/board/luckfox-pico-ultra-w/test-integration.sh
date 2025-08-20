#!/bin/bash
# Luckfox Pico Ultra W Integration Test Script
# This script tests the integration and verifies all components are in place

set -e

BOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RASPMATIC_DIR="$(cd "${BOARD_DIR}/../../.." && pwd)"

echo "=========================================="
echo "Luckfox Pico Ultra W Integration Test"
echo "=========================================="

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test function
test_check() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL"
        echo "  Expected: $expected_result"
    fi
}

echo "Running integration tests..."
echo ""

# Test 1: Board directory structure
test_check "Board directory structure" \
    "[ -d '${BOARD_DIR}' ]" \
    "Board directory exists"

# Test 2: Kernel configuration
test_check "Kernel configuration" \
    "[ -f '${BOARD_DIR}/kernel.config' ]" \
    "Kernel configuration file exists"

# Test 3: U-Boot configuration
test_check "U-Boot configuration" \
    "[ -f '${BOARD_DIR}/uboot.config' ]" \
    "U-Boot configuration file exists"

# Test 4: Post-build script
test_check "Post-build script" \
    "[ -f '${BOARD_DIR}/post-build.sh' ]" \
    "Post-build script exists"

# Test 5: Post-image script
test_check "Post-image script" \
    "[ -f '${BOARD_DIR}/post-image.sh' ]" \
    "Post-image script exists"

# Test 6: Build script
test_check "Build script" \
    "[ -f '${BOARD_DIR}/build-luckfox.sh' ]" \
    "Build script exists"

# Test 7: Boot commands
test_check "Boot commands" \
    "[ -f '${BOARD_DIR}/boot.cmd' ]" \
    "Boot commands file exists"

# Test 8: Kernel patches
test_check "Kernel patches" \
    "[ -d '${BOARD_DIR}/kernel-patches' ]" \
    "Kernel patches directory exists"

# Test 9: README files
test_check "README files" \
    "[ -f '${BOARD_DIR}/README.md' ]" \
    "README file exists"

# Test 10: Integration summary
test_check "Integration summary" \
    "[ -f '${BOARD_DIR}/INTEGRATION_SUMMARY.md' ]" \
    "Integration summary exists"

# Test 11: Main configuration
test_check "Main configuration" \
    "[ -f '${RASPMATIC_DIR}/buildroot-external/configs/raspmatic_luckfox-pico-ultra-w.config' ]" \
    "Main configuration file exists"

# Test 12: Script permissions
test_check "Script permissions" \
    "[ -x '${BOARD_DIR}/build-luckfox.sh' ]" \
    "Build script is executable"

# Test 13: Configuration content
test_check "Kernel config content" \
    "grep -q 'CONFIG_ARM=y' '${BOARD_DIR}/kernel.config'" \
    "Kernel config contains ARM configuration"

# Test 14: U-Boot config content
test_check "U-Boot config content" \
    "grep -q 'CONFIG_ARCH_ROCKCHIP=y' '${BOARD_DIR}/uboot.config'" \
    "U-Boot config contains Rockchip configuration"

# Test 15: Post-build script content
test_check "Post-build script content" \
    "grep -q 'Luckfox Pico Ultra W' '${BOARD_DIR}/post-build.sh'" \
    "Post-build script contains board identification"

echo ""
echo "=========================================="
echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL tests passed"
echo "=========================================="

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "🎉 All tests passed! Integration is complete and ready."
    echo ""
    echo "Next steps:"
    echo "1. Ensure Luckfox source is in tmp/luckfox-pico/"
    echo "2. Run: make PRODUCT=raspmatic_luckfox-pico-ultra-w all"
    echo "3. Or use the helper script: ./buildroot-external/board/luckfox-pico-ultra-w/build-luckfox.sh"
else
    echo "⚠️  Some tests failed. Please check the integration."
    echo ""
    echo "Failed tests indicate missing or incorrect files."
    echo "Review the test output above and fix any issues."
fi

echo ""
echo "Integration test completed."
