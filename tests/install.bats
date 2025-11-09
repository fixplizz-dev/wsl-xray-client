#!/usr/bin/env bats

# Tests for scripts/install.sh functionality (User Story 1)
load test_helper

@test "install script exists and is executable" {
    # This test will fail until we create the install script
    [ -f "$PROJECT_ROOT/scripts/install.sh" ]
    [ -x "$PROJECT_ROOT/scripts/install.sh" ]
}

@test "install script shows help with --help flag" {
    skip "Not implemented yet - install script help"

    # Test will fail until install.sh is created with --help support
    run "$PROJECT_ROOT/scripts/install.sh" --help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "install.sh" ]]
}

@test "install script fails with exit code 10 when .env missing" {
    skip "Not implemented yet - install script missing .env validation"

    # Remove .env file if it exists
    rm -f "$PROJECT_ROOT/.env"

    # Run install script
    run "$PROJECT_ROOT/scripts/install.sh"

    [ "$status" -eq 10 ]  # Missing required variable/file
    [[ "$output" =~ ".env file not found" ]]
}

@test "install script fails with exit code 10 when required variables missing" {
    skip "Not implemented yet - install script environment validation"

    # Create .env with missing required variables
    cat > "$PROJECT_ROOT/.env" << 'EOF'
XRAY_PROTOCOL=vless
# Missing XRAY_SERVER_HOST and other required vars
EOF
    chmod 600 "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/install.sh"

    [ "$status" -eq 10 ]  # Missing required variables
    [[ "$output" =~ "Missing required environment variables" ]]
}

@test "install script validates protocol and shows helpful error" {
    skip "Not implemented yet - install script protocol validation"

    # Create .env with invalid protocol
    cat > "$PROJECT_ROOT/.env" << 'EOF'
XRAY_PROTOCOL=invalid_protocol
XRAY_SERVER_HOST=test.example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=12345678-abcd-1234-efgh-123456789abc
XRAY_LOCAL_SOCKS_PORT=1080
EOF
    chmod 600 "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/install.sh"

    [ "$status" -eq 11 ]  # Invalid value format
    [[ "$output" =~ "Invalid protocol" ]]
    [[ "$output" =~ "Supported protocols: vless, vmess, trojan" ]]
}

@test "install script checks Xray binary download source" {
    skip "Not implemented yet - install script Xray download"

    # Create valid .env
    create_test_env "$PROJECT_ROOT/.env"

    # Mock curl to simulate download failure
    # This test checks that install script handles download failures gracefully

    # For now, just check that install script attempts to validate download source
    run bash -c "
        export PATH='$TEST_TEMP_DIR:$PATH'
        echo '#!/bin/bash\nexit 1' > '$TEST_TEMP_DIR/curl'
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/install.sh' 2>&1
    "

    [ "$status" -eq 12 ]  # Download failure
    [[ "$output" =~ "download" ]] || [[ "$output" =~ "failed" ]]
}

@test "install script requires jq dependency" {
    skip "Not implemented yet - install script dependency check"

    create_test_env "$PROJECT_ROOT/.env"

    # Mock jq to be missing
    run bash -c "
        export PATH='$TEST_TEMP_DIR:$PATH'
        # Don't create jq in PATH
        '$PROJECT_ROOT/scripts/install.sh' 2>&1
    "

    [ "$status" -ne 0 ]
    [[ "$output" =~ "jq" ]] && [[ "$output" =~ "install" ]]
}

@test "install script creates systemd service file" {
    skip "Not implemented yet - install script systemd integration"

    create_test_env "$PROJECT_ROOT/.env"

    # Mock successful installation (without actually installing)
    # This test will verify that install script creates proper systemd unit

    # For now, just ensure the test framework is ready
    [ -f "$PROJECT_ROOT/systemd/xray-wsl.service.template" ]
}

@test "install script supports --force flag for regeneration" {
    skip "Not implemented yet - install script force flag"

    create_test_env "$PROJECT_ROOT/.env"

    # Test that --force flag is recognized and handled
    run "$PROJECT_ROOT/scripts/install.sh" --force --help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "--force" ]] || [[ "$output" =~ "regenerate" ]]
}