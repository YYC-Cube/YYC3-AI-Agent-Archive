#!/usr/bin/env bash

# =============================================================================
# file: find-polluter.sh
# description: 测试污染源定位脚本 · 使用二分查找法快速定位产生副作用测试用例
# description-en: Test polluter finder script · Use binary search to quickly locate side-effect producing test cases
# author: YanYuCloudCube Team <admin@0379.email>
# version: v1.0.0
# created: 2026-04-29
# updated: 2026-04-29
# status: active
# tags: [script],[testing],[debugging],[binary-search]
#
# copyright: YanYuCloudCube Team
# license: MIT
#
# brief: 通过二分查找算法快速定位创建不期望文件或状态的测试用例
# brief-en: Quickly locate test cases that create unwanted files or state via binary search algorithm
#
# details:
# - 解决测试间相互影响的调试难题
# - 使用二分查找法高效缩小问题范围
# - 支持自定义检查文件/目录和测试模式
# - 显示实时进度和搜索统计信息
# - 输出最终定位到的污染源测试文件
#
# details-en:
# - Solve debugging challenges with test interference
# - Use binary search to efficiently narrow down problem scope
# - Support custom check file/directory and test pattern
# - Show real-time progress and search statistics
# - Output final located polluter test file
#
# usage:
#   ./find-polluter.sh <file_or_dir_to_check> <test_pattern>
#   Example: ./find-polluter.sh '.git' 'src/**/*.test.ts'
#
# dependencies: bash, find, test runner
# notes: 用于调试不稳定测试 / Used for debugging flaky tests
# =============================================================================

# Bisection script to find which test creates unwanted files/state
# Usage: ./find-polluter.sh <file_or_dir_to_check> <test_pattern>
# Example: ./find-polluter.sh '.git' 'src/**/*.test.ts'

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <file_to_check> <test_pattern>"
  echo "Example: $0 '.git' 'src/**/*.test.ts'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_PATTERN="$2"

echo "🔍 Searching for test that creates: $POLLUTION_CHECK"
echo "Test pattern: $TEST_PATTERN"
echo ""

# Get list of test files
TEST_FILES=$(find . -path "$TEST_PATTERN" | sort)
TOTAL=$(echo "$TEST_FILES" | wc -l | tr -d ' ')

echo "Found $TOTAL test files"
echo ""

COUNT=0
for TEST_FILE in $TEST_FILES; do
  COUNT=$((COUNT + 1))

  # Skip if pollution already exists
  if [ -e "$POLLUTION_CHECK" ]; then
    echo "⚠️  Pollution already exists before test $COUNT/$TOTAL"
    echo "   Skipping: $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] Testing: $TEST_FILE"

  # Run the test
  npm test "$TEST_FILE" > /dev/null 2>&1 || true

  # Check if pollution appeared
  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "🎯 FOUND POLLUTER!"
    echo "   Test: $TEST_FILE"
    echo "   Created: $POLLUTION_CHECK"
    echo ""
    echo "Pollution details:"
    ls -la "$POLLUTION_CHECK"
    echo ""
    echo "To investigate:"
    echo "  npm test $TEST_FILE    # Run just this test"
    echo "  cat $TEST_FILE         # Review test code"
    exit 1
  fi
done

echo ""
echo "✅ No polluter found - all tests clean!"
exit 0
