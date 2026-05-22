class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.6/doorman-0.1.6-aarch64-apple-darwin.tar.gz"
      sha256 "19a88baecf9d6e94643979b016c123198148d2e4e0095e110a2ba8a7e786349e"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.6/doorman-0.1.6-x86_64-apple-darwin.tar.gz"
      sha256 "4e786818e5427530d52972688072c2682d49049be30ee8116ed8f305c56ace52"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.6/doorman-0.1.6-aarch64-unknown-linux-musl.tar.gz"
      sha256 "840645129b79cb5b9123f0a7f4fa7d2ebfbfb8e58c41a9d690eb2d1baa1e185b"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.6/doorman-0.1.6-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e046ca2cf0a7610002fda80ed5308e60b68db1804310f770d7c91182bb3908ed"
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
