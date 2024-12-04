{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Vinícius Daniel";
    userEmail = "dannful@gmail.com";
    extraConfig = { pull = { rebase = true; }; };
  };
}
