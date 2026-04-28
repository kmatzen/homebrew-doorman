class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.5/doorman-0.1.5-aarch64-apple-darwin.tar.gz"
      sha256 "be1ad9b6899289c1c0b9c4edacd16e7c5021bb0ae0af21739628d53bc363bb7e"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.5/doorman-0.1.5-x86_64-apple-darwin.tar.gz"
      sha256 "5eaea27f4e75d58e6ca45a9d86182b5b60e7ea332aac12b344ace94d596dc06d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.5/doorman-0.1.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "583d6793b3d1b5662034db72fdd0ad6772b82cdd19cb5cb2999cbde8f866c3de"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.5/doorman-0.1.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1a950620ab7854f90ad4f3983ec45dfd7aaebadf3b41bfdb9c885dc4d2c66363"
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
