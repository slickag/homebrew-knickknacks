class Forgejo < Formula
  desc "Painless self-hosted all-in-one software development service"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v12.0.1/forgejo-src-12.0.1.tar.gz"
  sha256 "792f0435e9e4620da96a92305ed752f54b47ebc23d5f8e08a70299bac2245dd9"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  conflicts_with "gitea", because: "both install `gitea` binaries"

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea"
    bin.install "environment-to-ini"
    bin.install_symlink "gitea" => "forgejo"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path "/tmp/forgejo.out.log"
    error_log_path "/tmp/forgejo.err.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = fork do
      exec bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s
    end
    sleep 5
    sleep 10 if OS.mac? && Hardware::CPU.intel?

    output = shell_output("curl -s http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl -s http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
