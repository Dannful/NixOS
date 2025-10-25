{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      pull = { rebase = true; };
      user = {
        name = "Vinícius Daniel";
        email = "dannful@gmail.com";
      };
    };
  };
}
