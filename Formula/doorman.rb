class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.10/doorman-0.1.10-aarch64-apple-darwin.tar.gz"
      sha256 "7b4214d08604e33462c5cf1323b3312fbc8044a97c04ece6271dc0598ef86d4b"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.10/doorman-0.1.10-x86_64-apple-darwin.tar.gz"
      sha256 "0c5279e67660ed20ef74306e3d1d97bff4ac968900ec52872ac2f58ade11886b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.10/doorman-0.1.10-aarch64-unknown-linux-musl.tar.gz"
      sha256 "9a993682e4d458fe4def101e28e74b6f7ad3aff567b40880fdb030b6793f81e8"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.10/doorman-0.1.10-x86_64-unknown-linux-musl.tar.gz"
      sha256 "16e751d11d8f5105e4d942daa3f52a46b12a1b62ae34770a9a0f22593d931f16"
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

      Security note: brew runs doorman under your own login uid, not a
      separate service account. File permissions (mode 0400) keep *other*
      users out but do NOT isolate the plaintext secrets from other code
      running as you (a shell, cron, an AI coding agent) — which can read
      them directly and bypass the proxy (see issue #39). doorman prints a
      startup warning in this case; pass `--allow-same-uid` to acknowledge
      and silence it. For a real boundary — doorman under a dedicated uid
      your app code never runs as — deploy via the upstream service path:
        macOS:  scripts/install-darwin.sh  (creates the `_doorman` account)
        Linux:  the systemd unit from `doormand install-service`  (User=doorman)
    EOS
  end

  test do
    assert_match "doormand", shell_output("#{bin}/doormand --help 2>&1")
  end
end
