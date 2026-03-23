use dirs;
use std::{
    io,
    process::{Command, Stdio},
};

fn main() -> io::Result<()> {
    let search_path = std::env::var("RJ_ROOT").unwrap_or_else(|_| {
        dirs::home_dir()
            .map(|p| p.to_string_lossy().into_owned())
            .unwrap_or_else(|| ".".to_string())
    });

    let fd_output = Command::new("fd")
        .args([
            "--type",
            "d",
            "--hidden",
            "--exclude",
            ".git",
            ".",
            &search_path,
        ])
        .stdout(Stdio::piped())
        .spawn()?;

    let fzf_output = Command::new("fzf")
        .arg("--reverse")
        .arg("--height=40%")
        .stdin(fd_output.stdout.unwrap())
        .stdout(Stdio::piped())
        .spawn()?
        .wait_with_output()?;

    if fzf_output.status.success() {
        let selected_path = String::from_utf8_lossy(&fzf_output.stdout)
            .trim()
            .to_string();
        if !selected_path.is_empty() {
            println!("{}", selected_path);
        }
    }

    Ok(())
}
