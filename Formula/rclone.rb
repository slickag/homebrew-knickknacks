class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.71.1.tar.gz"
  sha256 "a3aa14e37047081f9770d7c58a0f13e665ed99600259884246b1884fc4b30b6c"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8f739eb25fd8b4dce8022c5384b99eb025bdc4f51bab8e725007d976dc7ed00b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "60d27adb0c722d80407a9af28cd9293c8c4616bd7cdbee15964bd3852b7dc826"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d11195ab20f5c42ee60da8387eabadfb00b3a86560bc1c07b295f2e8bb0fc431"
    sha256 cellar: :any_skip_relocation, sequoia:       "241cb72829382fa7587481623ab293ee329547bebf1d57ac79129346643e675e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "65ba1a6ba897643e29ec96d1153a8d3152baf94dd20938a392a353c5d222c700"
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
