{
  lib,
  stdenv,
  rustPlatform,
  cargo-tauri,
  nodejs,
  importNpmLock,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  gst_all_1,
  gtk3,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gmpublisher";
  version = (lib.importJSON ../src-tauri/tauri.conf.json).version;

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../.cargo
      ../app
      ../i18n
      ../public
      ../src-tauri
      ../jsconfig.json
      ../package.json
      ../package-lock.json
      ../svelte.config.js
      ../vite.config.js
    ];
  };

  strictDeps = true;

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";
  cargoLock.lockFile = ../src-tauri/Cargo.lock;

  npmDeps = importNpmLock { npmRoot = ../.; };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    importNpmLock.npmConfigHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gtk3
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  postInstall =
    if stdenv.hostPlatform.isDarwin then
      ''
        cp src-tauri/lib/steam_api/redistributable_bin/osx/libsteam_api.dylib \
          "$out/Applications/gmpublisher.app/Contents/MacOS/"
        mkdir -p $out/bin
        ln -s "$out/Applications/gmpublisher.app/Contents/MacOS/gmpublisher" $out/bin/gmpublisher
      ''
    else
      ''
        install -Dm644 src-tauri/lib/steam_api/redistributable_bin/linux64/libsteam_api.so \
          -t $out/lib
      '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath $out/lib $out/bin/gmpublisher
  '';

  meta = {
    description = "Workshop Publishing Utility for Garry's Mod, written in Rust & Svelte and powered by Tauri";
    homepage = "https://github.com/WilliamVenner/gmpublisher";
    license = lib.licenses.gpl3Only;
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "gmpublisher";
  };
})
