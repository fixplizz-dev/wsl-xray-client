#!/usr/bin/env bats

# Tests for scripts/generate-config.sh functionality (User Story 1)
load test_helper

@test "generate-config script exists and is executable" {
    # This test will fail until we create the generate-config script
    [ -f "$PROJECT_ROOT/scripts/generate-config.sh" ]
    [ -x "$PROJECT_ROOT/scripts/generate-config.sh" ]
}

@test "generate-config script shows help with --help flag" {
    skip "Not implemented yet - generate-config script help"

    run "$PROJECT_ROOT/scripts/generate-config.sh" --help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "generate-config.sh" ]]
}

@test "generate-config fails when .env missing" {
    skip "Not implemented yet - generate-config .env validation"

    # Ensure no .env file exists
    rm -f "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 10 ]  # Missing .env file
    [[ "$output" =~ ".env file not found" ]]
}

@test "generate-config creates valid JSON for VLESS protocol" {
    skip "Not implemented yet - generate-config VLESS JSON generation"

    # Create valid VLESS .env
    create_test_env "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 0 ]

    # Check that output is valid JSON
    echo "$output" | jq . >/dev/null

    # Check VLESS-specific fields
    [[ "$output" =~ '"protocol":"vless"' ]]
    [[ "$output" =~ '"port":1080' ]]  # SOCKS port
    [[ "$output" =~ '"port":443' ]]   # Server port
}

@test "generate-config creates valid JSON for VMess protocol" {
    skip "Not implemented yet - generate-config VMess JSON generation"

    # Create VMess .env
    cat > "$PROJECT_ROOT/.env" << 'EOF'
XRAY_PROTOCOL=vmess
XRAY_SERVER_HOST=test.example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=12345678-abcd-1234-efgh-123456789abc
XRAY_SECURITY=tls
XRAY_SNI=test.example.com
XRAY_LOCAL_SOCKS_PORT=1080
XRAY_LOCAL_HTTP_PORT=8080
EOF
    chmod 600 "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 0 ]
    echo "$output" | jq . >/dev/null
    [[ "$output" =~ '"protocol":"vmess"' ]]
}

@test "generate-config creates valid JSON for Trojan protocol" {
    skip "Not implemented yet - generate-config Trojan JSON generation"

    # Create Trojan .env
    cat > "$PROJECT_ROOT/.env" << 'EOF'
XRAY_PROTOCOL=trojan
XRAY_SERVER_HOST=test.example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=my-trojan-password
XRAY_SECURITY=tls
XRAY_SNI=test.example.com
XRAY_LOCAL_SOCKS_PORT=1080
EOF
    chmod 600 "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 0 ]
    echo "$output" | jq . >/dev/null
    [[ "$output" =~ '"protocol":"trojan"' ]]
    [[ "$output" =~ '"password":"my-trojan-password"' ]]
}

@test "generate-config includes Reality configuration when specified" {
    skip "Not implemented yet - generate-config Reality support"

    # Create Reality VLESS .env (using our test template)
    create_test_env "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 0 ]
    echo "$output" | jq . >/dev/null

    # Check Reality-specific fields
    [[ "$output" =~ '"security":"reality"' ]]
    [[ "$output" =~ '"publicKey"' ]]
    [[ "$output" =~ '"shortId"' ]]
    [[ "$output" =~ '"fingerprint":"chrome"' ]]
    [[ "$output" =~ '"serverName":"www.cloudflare.com"' ]]
}

@test "generate-config includes HTTP inbound when XRAY_LOCAL_HTTP_PORT set" {
    skip "Not implemented yet - generate-config HTTP inbound"

    create_test_env "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 0 ]
    echo "$output" | jq . >/dev/null

    # Should include both SOCKS and HTTP inbounds
    [[ "$output" =~ '"protocol":"socks"' ]]
    [[ "$output" =~ '"protocol":"http"' ]]
    [[ "$output" =~ '"port":8080' ]]  # HTTP port from test env
}

@test "generate-config validates environment before generation" {
    skip "Not implemented yet - generate-config environment validation"

    # Create invalid .env (invalid protocol)
    cat > "$PROJECT_ROOT/.env" << 'EOF'
XRAY_PROTOCOL=invalid
XRAY_SERVER_HOST=test.example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=12345678-abcd-1234-efgh-123456789abc
XRAY_LOCAL_SOCKS_PORT=1080
EOF
    chmod 600 "$PROJECT_ROOT/.env"

    run "$PROJECT_ROOT/scripts/generate-config.sh"

    [ "$status" -eq 11 ]  # Invalid value format
    [[ "$output" =~ "Invalid protocol" ]]
}

@test "generate-config requires jq dependency" {
    skip "Not implemented yet - generate-config jq dependency"

    create_test_env "$PROJECT_ROOT/.env"

    # Mock jq to be missing
    run bash -c "
        export PATH='$TEST_TEMP_DIR:$PATH'
        '$PROJECT_ROOT/scripts/generate-config.sh' 2>&1
    "

    [ "$status" -ne 0 ]
    [[ "$output" =~ "jq" ]] && [[ "$output" =~ "install" ]]
}

@test "generate-config outputs to specified file" {
    skip "Not implemented yet - generate-config file output"

    create_test_env "$PROJECT_ROOT/.env"

    local output_file="$TEST_TEMP_DIR/xray.json"

    run "$PROJECT_ROOT/scripts/generate-config.sh" "$output_file"

    [ "$status" -eq 0 ]
    [ -f "$output_file" ]

    # Verify it's valid JSON
    jq . "$output_file" >/dev/null
}