_: let
  forwardPostgres = "-L 5432:127.0.0.1:5432";
  hetznerStoragebox = "your-storagebox.de";
  immortalis = "immortalis.kanyu-bushi.ts.net";
  user = "nico";
in {
  # Import individual configuration snippets
  imports = [./email.nix];

  # I'm working with git a lot
  programs = {
    # Bash receives aliases
    bash = {
      enable = true;
      shellAliases = {
        "b1" = "ssh -p23 u342919@u342919.${hetznerStoragebox}";
        "b2" = "ssh -p23 u358867@u358867.${hetznerStoragebox}";
        "g" = "mosh ${user}@google-dragon.emperor-mercat.ts.net";
        "g1" = "ssh -p 666 ${user}@${immortalis}";
        "g2" = "ssh ${user}@${immortalis}";
        "g3" = "ssh -p 223 ${user}@116.202.208.112";
        "g4" = "ssh -p 224 ${user}@${immortalis}";
        "g5" = "ssh -p 225 ${user}@${immortalis}";
        "g6" = "ssh -p 226 ${user}@${immortalis}";
        "g7" = "ssh -p 227 ${user}@116.202.208.112";
        "g8" = "ssh -p 222 ${user}@${immortalis}";
        "g9" = "ssh -p 229 ${user}@${immortalis} ${forwardPostgres}";
        "m" = "mosh ${user}@garuda-mail.kanyu-bushi.ts.net";
        "o" = "mosh ${user}@oracle-dragon.emperor-mercat.ts.net";
      };
    };
    # Fish receives auto-expanding abbreviations (much cooler!)
    fish = {
      enable = true;
      shellAbbrs = {
        "b1" = "ssh -p23 u342919@u342919.${hetznerStoragebox}";
        "b2" = "ssh -p23 u358867@u358867.${hetznerStoragebox}";
        "g" = "mosh ${user}@google-dragon.emperor-mercat.ts.net";
        "g1" = "ssh -p 666 ${user}@${immortalis}";
        "g2" = "ssh ${user}@${immortalis}";
        "g3" = "ssh -p 223 ${user}@116.202.208.112";
        "g4" = "ssh -p 224 ${user}@${immortalis}";
        "g5" = "ssh -p 225 ${user}@${immortalis}";
        "g6" = "ssh -p 226 ${user}@${immortalis}";
        "g7" = "ssh -p 227 ${user}@116.202.208.112";
        "g8" = "ssh -p 222 ${user}@${immortalis}";
        "g9" = "ssh -p 229 ${user}@${immortalis} ${forwardPostgres}";
        "m" = "mosh ${user}@garuda-mail.kanyu-bushi.ts.net";
        "o" = "mosh ${user}@oracle-dragon.emperor-mercat.ts.net";
      };
    };
    git = {
      diff-so-fancy.enable = true;
      enable = true;
      extraConfig = {
        color.ui = "auto";
        help.autocorrect = 10;
        pull.rebase = true;
      };
      signing = {
        key = "D245D484F3578CB17FD6DA6B67DB29BFF3C96757";
        signByDefault = true;
      };
      userEmail = "root@dr460nf1r3.org";
      userName = "Nico Jensch";
    };
  };
}
