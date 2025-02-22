class Z4hTmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "http://10.0.0.5/AG/tmux/archive/tmux-3.5a.tar.gz"
  sha256 "54f186984a26dea1625a8e86255dfde5ae861ac6ce0f8e887ed0208d0ed95204"
  license "ISC"

  livecheck do
    url :stable
    regex(/v?(\d+(?:\.\d+)+[a-z]?)/i)
    strategy :github_latest
  end

  keg_only :provided_by_macos

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "z4h-ncurses"

  uses_from_macos "bison" => :build # for yacc

  # Old versions of macOS libc disagree with utf8proc character widths.
  # https://github.com/tmux/tmux/issues/2223
  on_system :linux, macos: :sierra_or_newer do
    depends_on "utf8proc"
  end

  def install
    system "sh", "autogen.sh"

    args = %W[
      --enable-sixel
      --sysconfdir=#{etc}
    ]

    # tmux finds the `tmux-256color` terminfo provided by our ncurses
    # and uses that as the default `TERM`, but this causes issues for
    # tools that link with the very old ncurses provided by macOS.
    # https://github.com/Homebrew/homebrew-core/issues/102748
    args << "--with-TERM=screen-256color" if OS.mac? && MacOS.version < :sonoma
    args << "--enable-utf8proc" if OS.linux? || MacOS.version >= :high_sierra

    ENV.append_to_cflags "-Wall -Wmissing-prototypes -DNDEBUG -flto -fno-strict-aliasing"
    ENV.append "DLLDFLAGS", "-shared"
    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args, *std_configure_args

    system "make", "install"

  end

  test do
    system bin/"tmux", "-V"

    require "pty"

    socket = testpath/tap.user
    PTY.spawn bin/"tmux", "-S", socket, "-f", File::NULL
    sleep 10

    assert_path_exists socket
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end
