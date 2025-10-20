class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.71.2.tar.gz"
  sha256 "54c619a2f6921981f276f01a12209bf2f2b5d94f580cd8699e93aa7c3e9ee9ba"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1c6b8622cfcb191256ab0b68471d339700b7286ab9778850d185de5cb32f01d8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "20b0dbfb3d0f542853dcdd87e31792c11a0d8c48b17b829d92bf7246ce419331"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "797898e8ab512848c07308b19d6de4ca0589a37fffb338104e4dfd6103791f4c"
    sha256 cellar: :any_skip_relocation, sequoia:       "3e3070de54131b6fc2aa7c3f72a8bc44cd94ef11afa882dbd5894b94cabce632"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0ef1e709efb7ed8a7c7adc22df97313f6f13c898eeaf9ebb903388f20083e045"
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
