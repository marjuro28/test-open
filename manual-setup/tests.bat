#!/usr/bin/env bats

# Define container names as variables (match your workflow)
MASTER_CONTAINER="mymaster"
CLIENT_CONTAINER="myclient"
MASTER_USER="mymaster"
CLIENT_USER="myclient"

# --------------------
# Test 1: Master container exists
# --------------------
@test "Master container is created" {
  run docker ps -a --filter "name=$MASTER_CONTAINER" --format "{{.Names}}"
  [ "$status" -eq 0 ]                  
  [ "$output" = "$MASTER_CONTAINER" ]  
}

# --------------------
# Test 2: Client container exists
# --------------------
@test "Client container is created" {
  run docker ps -a --filter "name=$CLIENT_CONTAINER" --format "{{.Names}}"
  [ "$status" -eq 0 ]                  
  [ "$output" = "$CLIENT_CONTAINER" ]  
}

# --------------------
# Test 3: Master user exists inside master container
# --------------------
@test "Master user exists inside master container" {
  run docker exec $MASTER_CONTAINER id -u $MASTER_USER
  [ "$status" -eq 0 ]   # Command succeeded
  [[ "$output" =~ ^[0-9]+$ ]]  # Output is a UID number
}

# --------------------
# Test 4: Client user exists inside client container
# --------------------
@test "Client user exists inside client container" {
  run docker exec $CLIENT_CONTAINER id -u $CLIENT_USER
  [ "$status" -eq 0 ]   
  [[ "$output" =~ ^[0-9]+$ ]]  
}

# --------------------
# Test 5: SSH runtime directory exists in master container
# --------------------
@test "SSH runtime directory exists in master container" {
  run docker exec $MASTER_CONTAINER test -d /var/run/sshd
  [ "$status" -eq 0 ]
}

# --------------------
# Test 6: SSH client is installed in client container
# --------------------
@test "SSH client is installed in client container" {
  run docker exec $CLIENT_CONTAINER sh -c "command -v ssh"
  [ "$status" -eq 0 ]
  [[ "$output" == */ssh ]]
}

# --------------------
# Test 7: Master .ssh directory exists
# --------------------
@test "Master .ssh directory exists" {
  run docker exec $MASTER_CONTAINER test -d /home/$MASTER_USER/.ssh
  [ "$status" -eq 0 ]
}

# --------------------
# Test 8: Client .ssh directory exists
# --------------------
@test "Client .ssh directory exists" {
  run docker exec $CLIENT_CONTAINER test -d /home/$CLIENT_USER/.ssh
  [ "$status" -eq 0 ]
}

# --------------------
# Test 9: File for Master authorized_keys exists
# --------------------
@test "File for Master authorized_keys exists" {
  run docker exec $MASTER_CONTAINER test -f /home/$MASTER_USER/.ssh/authorized_keys
  [ "$status" -eq 0 ]
}

# --------------------
# Test 10: sudo is installed in master container
# --------------------
@test "sudo is installed in master container" {
  run docker exec $MASTER_CONTAINER sh -c "command -v sudo"
  [ "$status" -eq 0 ]
}

# --------------------
# Test 11: Master user is member of sudo group
# --------------------
@test "Master user belongs to sudo group" {
  run docker exec $MASTER_CONTAINER sh -c "groups $MASTER_USER"
  [ "$status" -eq 0 ]
  [[ "$output" == *sudo* ]]
}

# --------------------
# Test 12: Sudoers file for master user exists and is correct
# --------------------
@test "Sudoers rule for master user exists" {
  run docker exec $MASTER_CONTAINER grep -Fx "$MASTER_USER ALL=(ALL) NOPASSWD: ALL" /etc/sudoers.d/$MASTER_USER
  [ "$status" -eq 0 ]
}

# --------------------
# Test 13: Bats is installed
# --------------------
@test "Bats is installed" {
  run command -v bats
  [ "$status" -eq 0 ]
}
