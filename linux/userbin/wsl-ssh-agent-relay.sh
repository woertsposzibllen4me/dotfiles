#!/bin/bash
# SSH agent socket path in WSL
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

# Full path to npiperelay
NPIPERELAY="$HOME/.local/bin/npiperelay.exe"

# Ensure directory has right permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Check if the forwarding is already running
ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe"; echo $?)

if [[ $ALREADY_RUNNING == "0" ]]; then
  echo "Relay process is already running"
else
  # Clean up old socket if it exists
  if [[ -S $SSH_AUTH_SOCK ]]; then
    echo "Removing existing socket file"
    rm -f $SSH_AUTH_SOCK
  fi
  # Start the SSH agent relay with explicit permissions
  echo "Starting SSH agent relay..."
  (umask 077 && setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$NPIPERELAY -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
  # Wait a bit and check if socket was created
  sleep 2
  if [[ -S $SSH_AUTH_SOCK ]]; then
    chmod 600 $SSH_AUTH_SOCK
    echo "Socket file created successfully"
    ls -la $SSH_AUTH_SOCK
  else
    echo "Failed to create socket file"
  fi
fi

# Try to list keys to verify connection
echo "Checking connection to SSH agent..."
ssh-add -l
