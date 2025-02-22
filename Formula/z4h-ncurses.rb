class Z4hNcurses < Formula
  desc "Text-based UI library"
  homepage "https://invisible-island.net/ncurses/announce.html"
  url "https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz"
  mirror "https://invisible-mirror.net/archives/ncurses/ncurses-6.5.tar.gz"
  mirror "ftp://ftp.invisible-island.net/ncurses/ncurses-6.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/ncurses/ncurses-6.5.tar.gz"
  sha256 "136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6"
  license "MIT"

  keg_only :provided_by_macos

  depends_on "pkgconf" => :build

  on_linux do
    depends_on "gpatch" => :build
  end

  def install
    # Workaround for
    # macOS: mkdir: /usr/lib/pkgconfig:/opt/homebrew/Library/Homebrew/os/mac/pkgconfig/12: Operation not permitted
    # Linux: configure: error: expected a pathname, not ""
    (lib/"pkgconfig").mkpath

    args = [
      "--prefix=#{prefix}",
      "--with-pkg-config-libdir=#{lib}/pkgconfig",
      "--disable-pc-files",
      "--disable-mixed-case",
      "--disable-rpath",
      "--disable-bsdpad",
      "--disable-termcap",
      "--disable-rpath-hack",
      "--enable-root-environ",
      "--without-manpages",
      "--without-tack",
      "--without-tests",
      "--without-pc-suffix",
      "--without-debug",
      "--without-dlsym",
      "--without-pcre2",
      "--enable-sigwinch",
      "--enable-widec",
      "--without-shared",
      "--without-cxx-shared",
      "--with-gpm=no",
      "--without-ada",
    ]
    args << "--with-terminfo-dirs=#{share}/terminfo:/etc/terminfo:/lib/terminfo:/usr/share/terminfo" if OS.linux?

    ENV.prepend_path "PATH", "/tmp/fake-bin"
    system "./configure", *args
    system "make", "install"

    # Avoid hardcoding Cellar paths in client software.
    inreplace bin/"ncursesw6-config", prefix, opt_prefix
  end

  test do
    system "echo", "Done!"
  end
end
