class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.7/doorman-0.1.7-aarch64-apple-darwin.tar.gz"
      sha256 "a60849195fddd122b792a04c19acf18d7eb7dbdb2e6495d0c3d35b0a98aed58d"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.7/doorman-0.1.7-x86_64-apple-darwin.tar.gz"
      sha256 "41f19ce1a4ab5f401e41a62355f4223eb2296c03bde24d876b437f9467b70265"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.7/doorman-0.1.7-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7f3eec1bc7c387ea0b044b56e2c71ccd05e90a87b454b4326aebd5719bd4b5c7"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.7/doorman-0.1.7-x86_64-unknown-linux-musl.tar.gz"
      sha256 "333b569ba93d64a232f9af2800d0bb1eafefdbd5842f8e814b06da1fc9bfb32c"
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
