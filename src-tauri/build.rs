fn main() {
	if cfg!(target_os = "linux") {
		println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN:$ORIGIN/../lib/gmpublisher");
	}

	tauri_build::build()
}
