class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.8/doorman-0.1.8-aarch64-apple-darwin.tar.gz"
      sha256 "d29d43b92e8f1d3adb754acd3374777ee4a18322345479d93781e993cefdee8f"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.8/doorman-0.1.8-x86_64-apple-darwin.tar.gz"
      sha256 "1b25188aa3d90051825d15a453ee6f88c6ff64fd8a855bf414bc81f568988078"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.8/doorman-0.1.8-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ed42a7f9785f7ec95e04af543bb7b068f70ac357176917a7531ede5de149fc4f"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.8/doorman-0.1.8-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d56b8dc9fe77d214151b61efa0f696ab7301a2c9357fe227b91ec73ff1129599"
    end
  end

  def install
    bin.install "doormand"
    pkgshare.install "examples"
    pkgshare.install "README.md"
  end

  def post_install
    (var/"log/doorman").mkpath
    (etc/"doorman").mkpath
  end

  service do
    run [opt_bin/"doormand", "run",
         "--config", etc/"doorman/doorman.yaml",
         "--audit",  var/"log/doorman/audit.log"]
    keep_alive crashed: true
    log_path       var/"log/doorman.stderr.log"
    error_log_path var/"log/doorman.stderr.log"
  end

  def caveats
    <<~EOS
      doorman expects a config at #{etc}/doorman/doorman.yaml (mode 0400).

      Get started:
        [ -e #{etc}/doorman/doorman.yaml ] || cp #{pkgshare}/examples/doorman.yaml #{etc}/doorman/doorman.yaml
        $EDITOR #{etc}/doorman/doorman.yaml
        chmod 0400 #{etc}/doorman/doorman.yaml

      Then start the service:
        brew services start doorman

      Logs (launchd-captured stdout/stderr):
        #{var}/log/doorman.stderr.log

      Audit log:
        #{var}/log/doorman/audit.log

      If the service won't stay running, the stderr log above is where
      doorman's startup error will be — typically a missing or wrong-mode
      config file.

      Note: brew runs doorman under your user uid, not a separate `_doorman`
      uid. For hardened production deployment with uid separation and
      LaunchDaemon-level isolation, install via the install-darwin.sh
      script in the upstream repo instead.
    EOS
  end

  test do
    assert_match "doormand", shell_output("#{bin}/doormand --help 2>&1")
  end
end
