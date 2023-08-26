_: {
  # Thunderbird configuration
  programs.thunderbird = {
    enable = true;
    profiles."nico" = {
      isDefault = true;
      settings = {
        "calendar.timezone.local" = "Europe/Berlin";
        "calendar.timezone.useSystemTimezone" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "font.name.sans-serif.x-western" = "Fira Sans";
        "mail.incorporate.return_receipt" = 1;
        "mail.markAsReadOnSpam" = true;
        "mail.spam.logging.enabled" = true;
        "mail.spam.manualMark" = true;
        "offline.download.download_messages" = 1;
        "offline.send.unsent_messages" = 1;
      };
    };
  };
}
