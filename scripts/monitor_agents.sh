#!/bin/bash

PROJECT_DIR="/Volumes/sourcecode/personal/sheet-scanner"
SESSION_PREFIX="golden-record-consumer"
AGENT_COUNT=4
AGENT_COUNTER=5  # Start numbering new agents at 5

# Function to check if a session has completed work
check_session_complete() {
  local session=$1
  # Check if the session is still alive and if it shows signs of being idle
  # A simple check: if the last output contains "ready", "finished", or "completed"
  local output=$(tmux capture-pane -t "$session" -p 2>/dev/null | tail -5)
  
  if [[ $output == *"ready to begin"* ]] || [[ $output == *"standing by"* ]]; then
    return 0  # Session is idle/done
  fi
  return 1  # Session is still working
}

# Function to kill and restart an agent
restart_agent() {
  local old_session=$1
  local new_session=$SESSION_PREFIX-$AGENT_COUNTER
  
  echo "[$(date +'%H:%M:%S')] Killing $old_session and starting $new_session"
  
  # Kill old session
  tmux kill-session -t "$old_session" 2>/dev/null
  sleep 1
  
  # Create and start new session
  tmux new-session -d -s "$new_session" -c "$PROJECT_DIR"
  sleep 1
  
  tmux send-keys -t "$new_session" "amp --dangerously-allow-all" Enter
  sleep 3
  
  # Send introduction and coordination prompt
  PROMPT="Before you do anything else, introduce yourself to the other agents via agent mail. Then coordinate to work on the remaining beads."
  tmux send-keys -t "$new_session" "$PROMPT" Enter
  
  echo "[$(date +'%H:%M:%S')] Started $new_session"
  ((AGENT_COUNTER++))
  
  return 0
}

# Main monitoring loop
echo "[$(date +'%H:%M:%S')] Starting agent monitor"

while true; do
  for i in {1..4}; do
    session="$SESSION_PREFIX-$i"
    
    # Check if session exists
    if ! tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -q "^${session}$"; then
      echo "[$(date +'%H:%M:%S')] Session $session no longer exists"
      continue
    fi
    
    # Check if idle
    if check_session_complete "$session"; then
      restart_agent "$session"
      # Update the counter to reflect we replaced agent $i
      AGENT_COUNTER=$((i + 4 + 1))
    fi
  done
  
  sleep 10  # Check every 10 seconds
done
