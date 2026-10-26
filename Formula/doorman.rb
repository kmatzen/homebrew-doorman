class Doorman < Formula
  desc "HTTP proxy that keeps API keys away from untrusted agents"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.12/doorman-0.1.12-aarch64-apple-darwin.tar.gz"
      sha256 "3e07ed6e700f16265ae2cdd155176076cf12a6d5104bb37d5fe113709d057cba"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.12/doorman-0.1.12-x86_64-apple-darwin.tar.gz"
      sha256 "925066a5fc2a6685bcb6b9d8728657420be4e8289a661bb467a3d7826334e020"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.12/doorman-0.1.12-aarch64-unknown-linux-musl.tar.gz"
      sha256 "609606e37249dd8be5265935eef30dfb24178e018e8cc7f0272626ac02219f7d"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.12/doorman-0.1.12-x86_64-unknown-linux-musl.tar.gz"
      sha256 "fdbf40ced6ca70e6c319c5fdfc14ee14a8949c18a8c281127e1e22334e73804c"
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
