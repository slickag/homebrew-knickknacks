class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "311a7a3fb39cfbf478bd0a9ac2c6b5cc5fc509383edad223b119ec89f7ef66b5"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "85bed6d61aa63d44ed6aae42737c3886d36db41ca066a1206e8e126fae0c0dfa"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9e16f519a8cc4be51010860676f51c0efd1fffc1fffe8eed24446d4b85863943"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "16b5602abf4c06a3300815f6d6815661d8a17850b2535c4e6fd20c5986f028b0"
    sha256 cellar: :any_skip_relocation, sequoia:       "885a3b48ec8949f09b6f2fbc619af5c1edf39a9482ebec455e5ae51c16c536ff"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7df9208d5c330f3fe093f945398dfe304a983db1a9c7c686d35a349f24afebdc"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
