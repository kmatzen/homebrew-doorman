class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.9/doorman-0.1.9-aarch64-apple-darwin.tar.gz"
      sha256 "dfd07df3c33b589b6e271c83d2535758f6ed1affd639546a952fbb22e8e4b2a5"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.9/doorman-0.1.9-x86_64-apple-darwin.tar.gz"
      sha256 "cc7c3030183e391e2401635d23f0a9f56508177fce3526e1e44c4a4f13dd3263"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.9/doorman-0.1.9-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8e1578b2ef1bea33c7a82362677ad7ae55a1c3bd7a3e5d0bdf09046db09d9fa4"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.9/doorman-0.1.9-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2e42fd32cf3275efaac74f6cbfd373a46735ede4925a6896906b9e36ec4e49cd"
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
