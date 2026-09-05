{
  symlinkJoin,
  writeShellScriptBin,
  curl,
  pname ? "rocket-league",
  location ? "$HOME/Games/${pname}",
  umu-launcher-git,
}:
let
  bakkesmodDir = "${location}/drive_c/Program Files/BakkesMod";
  bakkesmodExePath = "${bakkesmodDir}/BakkesMod.exe";

  # Downloads the BakkesMod injector into the wine prefix.
  bakkesmodInstaller = writeShellScriptBin "install-bakkesmod" ''
    mkdir -p "${bakkesmodDir}"
    ${curl}/bin/curl -L \
      https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/latest/download/BakkesMod.exe \
      --output "${bakkesmodExePath}"
  '';

  # legendary `--wrapper` target. legendary invokes this as:
  #   bakkesmod-wrapper <linux path to Launcher.exe> <epic auth args...> [-noeac]
  # We run BakkesMod.exe and Launcher.exe in a single umu/proton session so the
  # injector can inject into RocketLeague.exe, while still receiving legendary's
  # live Epic auth arguments. This sidesteps
  # https://github.com/Open-Wine-Components/umu-launcher/issues/194 (which
  # affects two competing umu-run invocations).
  bakkesmodWrapper = writeShellScriptBin "bakkesmod-wrapper" ''
    set -euo pipefail

    # Install the injector on first launch.
    [ -f "${bakkesmodExePath}" ] || ${bakkesmodInstaller}/bin/install-bakkesmod

    # BakkesMod detects the Epic install through legendary's own installed.json,
    # which it looks for under the wine profile's ~/.config/legendary. Expose the
    # host config there so detection succeeds (fixes "installation not detected").
    mkdir -p "${location}/drive_c/users/steamuser/.config"
    ln -sfn "$HOME/.config/legendary" "${location}/drive_c/users/steamuser/.config/legendary"

    # First arg is Launcher.exe (linux path); the rest are Epic auth args.
    launcher="$1"
    shift
    win_launcher="Z:$(printf '%s' "$launcher" | tr '/' '\\')"

    # Build a batch that starts BakkesMod, then Launcher.exe with all auth args,
    # so both run inside the same umu session.
    bat="${location}/drive_c/bm-launch.bat"
    {
      printf '@echo off\r\n'
      printf 'start "" "C:\\Program Files\\BakkesMod\\BakkesMod.exe"\r\n'
      printf '"%s"' "$win_launcher"
      for a in "$@"; do printf ' %s' "$a"; done
      printf '\r\n'
    } > "$bat"

    exec ${umu-launcher-git}/bin/umu-run 'c:/bm-launch.bat'
  '';
in
symlinkJoin {
  name = "bakkesmod";
  paths = [
    bakkesmodInstaller
    bakkesmodWrapper
  ];

  meta = {
    description = "Rocket League mod";
    homepage = "https://www.bakkesmod.com";
    platforms = [ "x86_64-linux" ];
  };
}
