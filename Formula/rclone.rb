class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.71.1.tar.gz"
  sha256 "a3aa14e37047081f9770d7c58a0f13e665ed99600259884246b1884fc4b30b6c"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2004b27614bed3bc4abc68596f52010cc53ef250adb93915d38d11a5eb1751e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bd23b3d9d62acd79b16cf56fe19299a2c90fecbee24fee998b49659e6eec63df"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"
    ENV["CGO_FLAGS"] = "-g -O3"
    args = ["GOTAGS=cmount"]

    if OS.mac?
      system "/bin/bash", "-c", "/Users/runner/work/homebrew-knickknacks/homebrew-knickknacks/cmd/fuse-t-install"
      system "/bin/bash", "-c", "/Users/runner/work/homebrew-knickknacks/homebrew-knickknacks/cmd/fuse-t-links-add"
    end

    system "make", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
