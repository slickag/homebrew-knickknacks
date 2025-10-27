class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v13.0.2/forgejo-src-13.0.2.tar.gz"
  sha256 "6731d5e73a025c1a04aba0f84caf80886d5be0031f4c154ac63026e7fe30918a"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a540308446aab9170fc3ecfc7befc993d32b3ae9036a35ca048d095b9cb4e68a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f99a4390b7f4ddcdcbc748e62bc0c7113e4476260059f0ef94b8bdf1ce1ac6e6"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "07dbefc9b50c2423980af67a86aa2cd33879f101d5b83b391b6951b55b39d6d6"
    sha256 cellar: :any_skip_relocation, sequoia:       "35a56a424aea1da83d17b35eda711b74492e1e4484fd702058a3aff4edc6b3c4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ba65efd2c085cb4540f9b645fd2e7215e8452194963df22cdad357b23a7476e2"
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
