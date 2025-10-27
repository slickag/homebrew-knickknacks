class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v13.0.2/forgejo-src-13.0.2.tar.gz"
  sha256 "6731d5e73a025c1a04aba0f84caf80886d5be0031f4c154ac63026e7fe30918a"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7ff9e7095e0dc9cafd76f5713631f915917841d4c1d198eb0208555fa8a6317d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8675893e8b5e9ee0941e9bb80deef32a118cdbd982291dffe0af522d664b30fa"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e6435c8d7a27b26302c1466637e3b81426b810b418b8551c9bcb361c705814dc"
    sha256 cellar: :any_skip_relocation, sequoia:       "297a398b0d9c97045679f8a929617776558c75a58551c27285dbfbe69d6cc035"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "62ddb14571827a751630694aaa9a6c75ddcb60ae15967440e339e5017dad53c4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3ecfc3400612a8864bc30d476fb2d4c38b7f02542973ddb17b4bb7de7d2d51f0"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
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
