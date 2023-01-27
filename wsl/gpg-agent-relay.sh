#!/usr/bin/env bash

killsocket() {
  local socketpath=$1
  if [[ -e $socketpath ]]; then
    local socketpid
    if socketpid=$(lsof +E -taU -- "$socketpath"); then
      timeout .5s tail --pid=$socketpid -f /dev/null &
      local timeoutpid=$!
      kill "$socketpid"
      if ! wait $timeoutpid; then
        die "Timed out waiting for pid $socketpid listening at $socketpath"
      fi
    else
      rm "$socketpath"
    fi
  fi
}

checkdeps() {
  local deps=(socat start-stop-daemon lsof timeout wslvar wslpath)
  local dep
  local out
  for dep in "${deps[@]}"; do
    if ! out=$(type "$dep" 2>&1); then
      printf -- "Dependency %s not found:\n%s\n" "$dep" "$out"
      return 1
    fi
  done
}

checkdeps

GNUPGHOME="$HOME/.gnupg"

npiperelay=$(wslpath -u "$(wslvar APPDATA)/npiperelay/npiperelay.exe")

wingnupghome="$(wslvar APPDATA)/gnupg"
wingnupghome="${wingnupghome//\\//}"

gpgagentsocket="$GNUPGHOME/S.gpg-agent"
sshagentsocket="$GNUPGHOME/S.gpg-agent.ssh"

run_gpgagentsocket=$(gpgconf --list-dirs agent-socket)
run_sshagentsocket=$(gpgconf --list-dirs agent-ssh-socket)

mkdir -p "~/.gnupg"
mkdir -p $(dirname "$run_sshagentsocket")

killsocket "$gpgagentsocket"
killsocket "$sshagentsocket"
killsocket "$run_gpgagentsocket"
killsocket "$run_sshagentsocket"

socat UNIX-LISTEN:"$run_gpgagentsocket,unlink-close,fork,umask=177" EXEC:"$npiperelay -ep -ei -s -a '${wingnupghome}/S.gpg-agent'",nofork &
RUN_GNUPID=$!

# shellcheck disable=SC2064
trap "kill -TERM $RUN_GNUPID" EXIT

socat UNIX-LISTEN:"$gpgagentsocket,unlink-close,fork,umask=177" EXEC:"$npiperelay -ep -ei -s -a '${wingnupghome}/S.gpg-agent'",nofork &
GNUPID=$!

# shellcheck disable=SC2064
trap "kill -TERM $GNUPID" EXIT

socat UNIX-LISTEN:"$sshagentsocket,unlink-close,fork,umask=177" EXEC:"$npiperelay /\/\./\pipe/\ssh-pageant" &
SSHPID=$!

set +e
# shellcheck disable=SC2064
trap "kill -TERM $GNUPID; kill -TERM $SSHPID" EXIT

socat UNIX-LISTEN:"$run_sshagentsocket,unlink-close,fork,umask=177" EXEC:"$npiperelay /\/\./\pipe/\ssh-pageant" &
RUN_SSHPID=$!

# shellcheck disable=SC2064
trap "kill -TERM $GNUPID; kill -TERM $RUN_SSHPID" EXIT

systemd-notify --ready 2>/dev/null
wait $GNUPID $RUN_GNUPID $SSHPID $RUN_SSHPID
trap - EXIT

