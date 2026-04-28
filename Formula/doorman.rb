class Doorman < Formula
  desc "HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong"
  homepage "https://github.com/kmatzen/doorman"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.3/doorman-0.1.3-aarch64-apple-darwin.tar.gz"
      sha256 "a2a3953275f4ee14c1f658448c524f70c897226c579eac5ea596fd353383c627"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.3/doorman-0.1.3-x86_64-apple-darwin.tar.gz"
      sha256 "775a7ad5dcad619ae8e6c573b0dcf3deac1f615e93a819ce89baa16e6a181872"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.3/doorman-0.1.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3e1998dc7e3d486c98a4bdb30eb0353a6bad05a88d2550308ea4b65551f43ea0"
    end
    on_intel do
      url "https://github.com/kmatzen/doorman/releases/download/v0.1.3/doorman-0.1.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "93fdd6ea898222c54bb3434e02d85218de9d408ae0709386d6da1165ad85eb99"
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
