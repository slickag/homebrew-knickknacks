class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "ffecb5cd7a4970ba005f7625b37aa3769fb6e20c01a2e14bbbe1d0592e67e577"
    sha256 cellar: :any,                 arm64_sequoia: "f62c4f9c3b999b7b5601538358fe54979fa4a658b4a6d7fe6f89fbabba64f16e"
    sha256 cellar: :any,                 arm64_sonoma:  "3b73a40374886073b5a9db9e53af3c56a96b5082ea0e92fdfa122469602952e9"
    sha256 cellar: :any,                 sequoia:       "d181228e12bc518d5b387e6b3d39e0ca4d4da6d3d383582e24f97d3e0f96665f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b6470e42d4ae87694bda98124f576972399789dc6e8338de363bf67b156e64d7"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build

  depends_on "c-ares"
  depends_on "libssh2"
  depends_on "sqlite"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "openssl@3"
  end

  def install
    ENV.cxx11

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --enable-metalink
      --enable-bittorrent
      --with-libcares
      --with-libssh2
      --with-libxml2
      --with-libz
      --without-gnutls
      --without-libgcrypt
      --without-libgmp
      --without-libnettle
    ]
    if OS.mac?
      ENV.clang
      args << "--with-appletls"
      args << "--without-openssl"
    else
      args << "--without-appletls"
      args << "--with-openssl"
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end
