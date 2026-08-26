# https://modrinth.com/app
{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  libsoup_3,
  webkitgtk_4_1,
  glib-networking,
  jdk17,
  openal,
  libpulseaudio,
}:
stdenvNoCC.mkDerivation rec {
  pname = "modrinth-app";
  version = "0.18.2";

  src = fetchurl {
    url = "https://launcher-files.modrinth.com/versions/${version}/linux/Modrinth%20App_${version}_amd64.deb";
    hash = "sha256-l4XC3N3MS74JvqLKIE1terwFtdiGi/UXXJ89n8m3r6g=";
  };

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    libsoup_3
    webkitgtk_4_1
    glib-networking
  ];

  installPhase = ''
    runHook preInstall
    mv -v usr $out
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeSearchPath "bin/java" [ jdk17 ]}
      --set LD_LIBRARY_PATH ${
        lib.makeLibraryPath [
          openal
          libpulseaudio
        ]
      }
    )
  '';
}
