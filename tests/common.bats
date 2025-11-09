#!/usr/bin/env bats

# Tests for lib/common.sh functionality
load test_helper

@test "log_info produces correct format" {
    # Test that log_info follows the required format: TIMESTAMP LEVEL script FUNCTION message
    source "$PROJECT_ROOT/lib/common.sh"

    # Capture stderr (where structured logs go)
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && log_info 'test message' 2>&1"

    [ "$status" -eq 0 ]

    # Check log format: timestamp, level INFO, script name, function, message
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ INFO\ [^\ ]+\ [^\ ]+\ test\ message ]]
}

@test "log_error produces correct format" {
    source "$PROJECT_ROOT/lib/common.sh"

    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && log_error 'error message' 2>&1"

    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ ERROR\ [^\ ]+\ [^\ ]+\ error\ message ]]
}

@test "log_warn produces correct format" {
    source "$PROJECT_ROOT/lib/common.sh"

    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && log_warn 'warning message' 2>&1"

    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ WARN\ [^\ ]+\ [^\ ]+\ warning\ message ]]
}

@test "load_env fails with missing .env file" {
    # This test should FAIL initially (before implementation) and PASS after
    source "$PROJECT_root/lib/common.sh"

    # Try to load non-existent .env file
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && load_env '$TEST_TEMP_DIR/nonexistent.env'"

    [ "$status" -eq 10 ]  # Exit code 10 for missing required variable/file
    [[ "$output" =~ \.env\ file\ not\ found ]]
}

@test "load_env succeeds with valid .env file" {
    # This test should FAIL initially and PASS after implementation
    source "$PROJECT_ROOT/lib/common.sh"

    # Create valid .env file
    local env_file="$(create_test_env)"

    # Load .env file
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && load_env '$env_file' && echo \$XRAY_PROTOCOL"

    [ "$status" -eq 0 ]
    [ "$output" = "vless" ]
}

@test "load_env fails with invalid .env syntax" {
    # This test should FAIL initially and PASS after implementation
    source "$PROJECT_ROOT/lib/common.sh"

    # Create invalid .env file
    local env_file="$(create_invalid_env)"

    # Try to load invalid .env file
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && load_env '$env_file'"

    [ "$status" -eq 11 ]  # Exit code 11 for invalid value format
    [[ "$output" =~ Invalid\ \.env\ file\ syntax ]]
}

@test "require_env fails with missing variable" {
    source "$PROJECT_ROOT/lib/common.sh"

    # Test with unset variable
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && require_env NONEXISTENT_VAR"

    [ "$status" -eq 1 ]
    [[ "$output" =~ Required\ environment\ variable\ not\ set:\ NONEXISTENT_VAR ]]
}

@test "require_env succeeds with set variable" {
    source "$PROJECT_ROOT/lib/common.sh"

    # Test with set variable
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && export TEST_VAR='test_value' && require_env TEST_VAR"

    [ "$status" -eq 0 ]
}

@test "check_required_env fails with multiple missing variables" {
    source "$PROJECT_ROOT/lib/common.sh"

    # Test with multiple missing variables
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && check_required_env VAR1 VAR2 VAR3"

    [ "$status" -eq 10 ]  # Exit code 10 for missing required variables
    [[ "$output" =~ Missing\ required\ environment\ variables ]]
    [[ "$output" =~ VAR1 ]]
    [[ "$output" =~ VAR2 ]]
    [[ "$output" =~ VAR3 ]]
}

@test "filter_secrets removes sensitive information" {
    source "$PROJECT_ROOT/lib/common.sh"

    # Test that filter_secrets removes UUIDs and passwords
    local test_input="UUID: 12345678-abcd-1234-efgh-123456789012 password=secret123 key=mykey"
    local expected_output="UUID: **UUID** password=**HIDDEN** key=**HIDDEN**"

    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && echo '$test_input' | filter_secrets"

    [ "$status" -eq 0 ]
    [[ "$output" =~ \*\*UUID\*\* ]]
    [[ "$output" =~ \*\*HIDDEN\*\* ]]
    [[ ! "$output" =~ 12345678-abcd-1234-efgh-123456789012 ]]
    [[ ! "$output" =~ secret123 ]]
}

@test "get_localized_message returns correct language" {
    source "$PROJECT_ROOT/lib/common.sh"

    # Test English (default)
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && export XRAY_CLIENT_LANG=en && get_localized_message 'install.success'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Installation completed successfully" ]]

    # Test Russian
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && export XRAY_CLIENT_LANG=ru && get_localized_message 'install.success'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Установка завершена успешно" ]]
}

# This is a foundational checkpoint test - it should pass when foundation is complete
@test "foundational phase checkpoint - all basic functions work" {
    # Test that we can source both libraries and basic functions work
    run bash -c "
        source '$PROJECT_ROOT/lib/common.sh' &&
        source '$PROJECT_ROOT/lib/validate.sh' &&
        log_info 'Foundation test' &&
        echo 'Foundation phase complete'
    "

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Foundation phase complete" ]]
}