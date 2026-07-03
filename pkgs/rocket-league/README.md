# Rocket League

Installer for Epic Games version of [Rocket League](https://www.rocketleague.com/). [legendary](https://github.com/derrod/legendary) is used for authentication and launching the game.

## How to use

Make sure you have logged in with legendary, you don't have to have legendary available in your system, if that is the case, you can temporarily enable it and log in;
```bash
$ nix shell nixpkgs#legendary-gl
$ legendary auth
```

After logging in you can add rocket-league to your `home.packages` or `environment.systemPackages` by adding `nix-gaming` to your inputs.

After executing `nixos-rebuild switch` you should have `rocket-league` available to your system.

# Bakkesmod

Bakkesmod only works with EAC disabled. Enabling it adds a **second** command,
`bakkesmod`, alongside the plain `rocket-league` one, so a single install gives
you both:

- `rocket-league` - unmodified game, EAC enabled
- `bakkesmod` - launches the game with EAC disabled and injects BakkesMod (for
  offline/local modded play)

The `bakkesmod` command launches the game through legendary with a `--wrapper`
that starts the BakkesMod injector and the game inside a single umu/proton
session, so the injector can attach to the game. Running both in one session
avoids the [upstream umu-launcher
issue](https://github.com/Open-Wine-Components/umu-launcher/issues/194) with two
competing `umu-run` invocations.

## Enabling bakkesmod

You can enable bakkesmod by overriding rocket-league like that;
```nix
  home-manager.users.emrebicer = {
    home.packages = with pkgs; [
      (inputs.nix-gaming.packages.${pkgs.system}.rocket-league.override {
        enableBakkesmod = true;
      })
    ];
  };
```

After rebuilding, run the `bakkesmod` command (or its desktop entry). On the
first launch the BakkesMod injector is downloaded automatically, and BakkesMod
detects the Epic install through legendary's `installed.json` (no Epic Games
Launcher required). Press `F2` in-game to open the BakkesMod menu. If BakkesMod
does not inject automatically, disable `Safe mode` in the BakkesMod settings.
