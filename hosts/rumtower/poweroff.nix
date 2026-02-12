{pkgs, ...}: {
  # Webhook service for remote shutdown
  services.webhook = {
    enable = true;
    port = 8080;
    openFirewall = true;
    hooks = {
      shutdown = {
        execute-command = "/run/wrappers/bin/sudo";
        pass-arguments-to-command = [
          {source = "string"; name = "systemctl";}
          {source = "string"; name = "poweroff";}
        ];
        response-message = "Shutting down rumtower...";
      };
    };
  };

  # Allow webhook user to run poweroff without password
  security.sudo.extraRules = [
    {
      users = ["webhook"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl poweroff";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Shutdown reminder notification at 9 PM
  systemd.services.shutdown-reminder = {
    description = "Remind to shut down rumtower";
    serviceConfig.Type = "oneshot";
    path = [pkgs.curl];
    script = ''
      curl -X POST \
        -H "Title: Shutdown Reminder" \
        -H "Priority: high" \
        -H "Tags: computer,warning" \
        -H "Actions: http, Shutdown, http://rumtower:8080/hooks/shutdown, method=POST, clear=true" \
        -d "rumtower is still running at 9 PM. Shut it down?" \
        http://rumnas:8888/monitoring
    '';
  };

  systemd.timers.shutdown-reminder = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 21:00:00";
      Persistent = true;
    };
  };
}
