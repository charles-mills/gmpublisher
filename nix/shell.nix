{
  lib,
  stdenv,
  mkShell,
  gmpublisher,
  clippy,
  rust-analyzer,
  rustfmt,
  glib-networking,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
}:

mkShell {
  inputsFrom = [ gmpublisher ];

  packages = [
    clippy
    rust-analyzer
    rustfmt
  ];

  shellHook = lib.optionalString stdenv.hostPlatform.isLinux ''
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
    export LD_LIBRARY_PATH=$PWD/src-tauri/lib/steam_api/redistributable_bin/linux64:$LD_LIBRARY_PATH
    export GST_PLUGIN_SYSTEM_PATH_1_0=${
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
        with gst_all_1;
        [
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
        ]
      )
    }
    export GIO_EXTRA_MODULES=${glib-networking}/lib/gio/modules
  '';
}
