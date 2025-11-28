$entry = "Host ${hostname}`n    HostName ${hostname}`n    User ${user}`n    IdentityFile ${identityfile}"
Add-Content -Path "$HOME/.ssh/config" -Value $entry
