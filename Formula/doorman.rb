class Doorman < Formula
  desc "HTTP proxy that keeps API keys away from untrusted agents"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.11/doorman-0.1.11-aarch64-apple-darwin.tar.gz"
      sha256 "a5cea803fe19c9aa8433cd359a1c5de16e963fea27de66624b7b67e7f955df51"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.11/doorman-0.1.11-x86_64-apple-darwin.tar.gz"
      sha256 "4bfc633855243015c2361800be0e58f8c60926f44312e491af2722f15649b92a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.11/doorman-0.1.11-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7796111e4bb093213234974a89ca839dcb9a65fca9b0c3c6f6602f0a21b5053d"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.11/doorman-0.1.11-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a492c90b913ee0bb2a3ee4b6feb5b913734dfe53901a233ec9b58c2d5e0fe6f0"
    end
  end

  def install
    bin.install "doormand"
    pkgshare.install "examples"
    pkgshare.install "README.md"
  end

  post_install_steps do
    mkdir_p "log/doorman", base: :var
    mkdir_p "doorman", base: :etc
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
