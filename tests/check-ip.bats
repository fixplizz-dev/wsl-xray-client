#!/usr/bin/env bats

# Tests for scripts/check-ip.sh functionality (User Story 1)
load test_helper

@test "check-ip script exists and is executable" {
    # This test will fail until we create the check-ip script
    [ -f "$PROJECT_ROOT/scripts/check-ip.sh" ]
    [ -x "$PROJECT_ROOT/scripts/check-ip.sh" ]
}

@test "check-ip script shows help with --help flag" {
    skip "Not implemented yet - check-ip script help"

    run "$PROJECT_ROOT/scripts/check-ip.sh" --help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "check-ip.sh" ]]
}

@test "check-ip returns current IP address" {
    skip "Not implemented yet - check-ip basic functionality"

    run "$PROJECT_ROOT/scripts/check-ip.sh"

    [ "$status" -eq 0 ]

    # Should return an IP address (basic IPv4 format check)
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "check-ip shows detailed information with --verbose flag" {
    skip "Not implemented yet - check-ip verbose mode"

    run "$PROJECT_ROOT/scripts/check-ip.sh" --verbose

    [ "$status" -eq 0 ]

    # Should show more than just IP (country, ISP, etc.)
    [[ "$output" =~ "IP:" ]]
    [[ "$output" =~ "Country:" ]] || [[ "$output" =~ "Region:" ]]
}

@test "check-ip can compare with baseline" {
    skip "Not implemented yet - check-ip baseline comparison"

    # Create a baseline IP file
    echo "1.2.3.4" > "$TEST_TEMP_DIR/baseline.ip"

    # Mock curl to return different IP
    run bash -c "
        export PATH='$TEST_TEMP_DIR:\$PATH'
        cat > '$TEST_TEMP_DIR/curl' << 'EOF'
#!/bin/bash
if [[ \"\$1\" == *\"ipinfo.io\"* ]]; then
    echo '5.6.7.8'
else
    /usr/bin/curl \"\$@\"
fi
EOF
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/check-ip.sh' --baseline '$TEST_TEMP_DIR/baseline.ip'
    "

    [ "$status" -eq 0 ]
    [[ "$output" =~ "changed" ]] || [[ "$output" =~ "different" ]]
    [[ "$output" =~ "1.2.3.4" ]]  # Old IP
    [[ "$output" =~ "5.6.7.8" ]]  # New IP
}

@test "check-ip detects when IP hasn't changed" {
    skip "Not implemented yet - check-ip no change detection"

    # Create baseline with same IP that will be returned
    echo "1.2.3.4" > "$TEST_TEMP_DIR/baseline.ip"

    # Mock curl to return same IP
    run bash -c "
        export PATH='$TEST_TEMP_DIR:\$PATH'
        cat > '$TEST_TEMP_DIR/curl' << 'EOF'
#!/bin/bash
if [[ \"\$1\" == *\"ipinfo.io\"* ]]; then
    echo '1.2.3.4'
else
    /usr/bin/curl \"\$@\"
fi
EOF
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/check-ip.sh' --baseline '$TEST_TEMP_DIR/baseline.ip'
    "

    [ "$status" -eq 0 ]
    [[ "$output" =~ "same" ]] || [[ "$output" =~ "unchanged" ]]
}

@test "check-ip saves current IP as baseline" {
    skip "Not implemented yet - check-ip save baseline"

    local baseline_file="$TEST_TEMP_DIR/new_baseline.ip"

    # Mock curl to return known IP
    run bash -c "
        export PATH='$TEST_TEMP_DIR:\$PATH'
        cat > '$TEST_TEMP_DIR/curl' << 'EOF'
#!/bin/bash
echo '9.8.7.6'
EOF
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/check-ip.sh' --save-baseline '$baseline_file'
    "

    [ "$status" -eq 0 ]
    [ -f "$baseline_file" ]

    # File should contain the IP returned by mock curl
    local saved_ip="$(cat "$baseline_file")"
    [ "$saved_ip" = "9.8.7.6" ]
}

@test "check-ip handles network failure gracefully" {
    skip "Not implemented yet - check-ip network error handling"

    # Mock curl to fail
    run bash -c "
        export PATH='$TEST_TEMP_DIR:\$PATH'
        cat > '$TEST_TEMP_DIR/curl' << 'EOF'
#!/bin/bash
exit 1
EOF
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/check-ip.sh' 2>&1
    "

    [ "$status" -ne 0 ]
    [[ "$output" =~ "network" ]] || [[ "$output" =~ "connection" ]] || [[ "$output" =~ "failed" ]]
}

@test "check-ip requires curl dependency" {
    skip "Not implemented yet - check-ip curl dependency"

    # Mock curl to be missing
    run bash -c "
        export PATH='$TEST_TEMP_DIR:\$PATH'
        '$PROJECT_ROOT/scripts/check-ip.sh' 2>&1
    "

    [ "$status" -ne 0 ]
    [[ "$output" =~ "curl" ]] && [[ "$output" =~ "install" ]]
}

@test "check-ip supports localized output" {
    skip "Not implemented yet - check-ip localization"

    # Test Russian output
    run bash -c "
        export XRAY_CLIENT_LANG=ru
        # Mock curl for testing
        export PATH='$TEST_TEMP_DIR:\$PATH'
        cat > '$TEST_TEMP_DIR/curl' << 'EOF'
#!/bin/bash
echo '1.2.3.4'
EOF
        chmod +x '$TEST_TEMP_DIR/curl'
        '$PROJECT_ROOT/scripts/check-ip.sh'
    "

    [ "$status" -eq 0 ]
    # Should contain Russian text or at least handle the locale setting
}