#!/usr/bin/env bats

# Load test helpers
load test_helper

@test "bats is installed and working" {
    # This test ensures bats itself is working
    run echo "test"
    [ "$status" -eq 0 ]
    [ "$output" = "test" ]
}

@test "project structure exists" {
    # Test that required directories exist
    [ -d "$PROJECT_ROOT/lib" ]
    [ -d "$PROJECT_ROOT/configs" ]
    [ -d "$PROJECT_ROOT/scripts" ]
    [ -d "$PROJECT_ROOT/systemd" ]
    [ -d "$PROJECT_ROOT/tests" ]
}

@test "common.sh can be sourced" {
    # Test that common.sh loads without errors
    run bash -c "source '$PROJECT_ROOT/lib/common.sh'"
    [ "$status" -eq 0 ]
}

@test "validate.sh can be sourced" {
    # Test that validate.sh loads without errors
    run bash -c "source '$PROJECT_ROOT/lib/validate.sh'"
    [ "$status" -eq 0 ]
}

# This test should remain, don't implement yet
@test "check bats dependency installation guide" {
    skip "Test infrastructure validation - bats installation check"

    # This test verifies that our test infrastructure provides
    # clear guidance for bats installation if it's missing
    # The test_helper.bash should handle this check
}

# This is the implementation checkpoint test
@test "foundational phase completion marker" {
    skip "Foundational phase must be complete before user story implementation"

    # This test will be enabled once all foundational tasks are done
    # It serves as a gate before user story implementation can begin
}