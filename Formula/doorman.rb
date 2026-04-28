class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.4/doorman-0.1.4-aarch64-apple-darwin.tar.gz"
      sha256 "3d330d123cd1dcdf3e27943448f25bc462770a1dc82e38cc0fbe14b2b7fc2452"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.4/doorman-0.1.4-x86_64-apple-darwin.tar.gz"
      sha256 "497dbacf19c80eac90f8d7125a6543372a72cc86a1a9ab67df379e988ab9d863"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.4/doorman-0.1.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4c72e67bab8f8f3bb422c44842580054a885199d200b98f49fa1344e944da4dd"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.4/doorman-0.1.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c81ada4ca6ae5597f69a4b25e4f6087d92c42b5904c88688ed00c2289af99418"
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
