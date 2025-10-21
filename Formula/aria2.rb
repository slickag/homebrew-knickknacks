class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/slickag/knickknacks"
    rebuild 2
    sha256 cellar: :any,                 arm64_tahoe:   "99ee8714e51c7e1e4e9ebb3018a736bc0c57c9a5616b7429a969a058ef2c92d4"
    sha256 cellar: :any,                 arm64_sequoia: "90e5d65dce46f9d32935d502a4737d41aead8127d499ebe5762bddefcd4b3475"
    sha256 cellar: :any,                 arm64_sonoma:  "aee3aa141f70641aae27eccad2d159e9caae931f90e678a988956558302b4f4a"
    sha256 cellar: :any,                 sequoia:       "0c3c393f404ceef8327ad593c3a6a50bc9d12f7f38935234437a23b7dc92901e"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2c380ad6b8a945179650b1f58d4cbcea02aec2642c9acd5a86ef9d736cd9ecb3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2a4af9f069edbb7b486e6a2dd9c5d65156abdf21b5d7cbb6fe0dd95ce09b4d48"
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
