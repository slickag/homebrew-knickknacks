class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server with HTTP/3 support using quiche"
  homepage "https://curl.se"
  license "curl"

  stable do
    url "https://curl.se/download/curl-8.16.0.tar.bz2"
    mirror "https://github.com/curl/curl/releases/download/curl-8_16_0/curl-8.16.0.tar.bz2"
    mirror "http://fresh-center.net/linux/www/curl-8.16.0.tar.bz2"
    mirror "http://fresh-center.net/linux/www/legacy/curl-8.16.0.tar.bz2"
    sha256 "9459180ab4933b30d0778ddd71c91fe2911fab731c46e59b3f4c8385b1596c91"

    resource "quiche" do
      url "https://github.com/cloudflare/quiche.git",
      tag:      "0.24.6",
      revision: "020a43a0a5eed76f57dd3ce5012149aa576c594d"
      mirror "http://www.surge.box.ca/files/quiche-0.24.6.tar.bz2"
      sha256 "a5161fb0488a23ec2e31f85662ea8fb81875bea2358a3c26e2442e1605b72635"
    end
  end

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    resource "quiche" do
      url "https://github.com/cloudflare/quiche.git", branch: "master"
    end
  end

  keg_only :provided_by_macos

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "brotli"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on :macos
  depends_on "rtmpdump"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"
  uses_from_macos "zlib", since: :sierra

  on_macos do
    depends_on "rust" => :build
  end

  on_monterey :or_older do
    depends_on "libidn2"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(/github\.com/).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    # Use our `curl` formula with `wcurl`
    inreplace "scripts/wcurl", 'CMD="curl "', "CMD=\"#{opt_bin}/curl \""

    # Build with quiche:
    #  https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version
    quiche = buildpath/"quiche/quiche"
    quiche_pc_path = buildpath/"quiche/target/release/quiche.pc"
    resource("quiche").stage quiche.parent
    cd "quiche" do
      # Build static libs only
      inreplace "./Cargo.toml", /^debug = true/, "debug = false"
      inreplace "quiche/Cargo.toml", /^crate-type = .*/, "crate-type = [\"staticlib\"]"

      system "curl", "-o", buildpath/"quiche/quiche.sh", "https://www.surge.box.ca/files/quiche.sh"
      chmod "+x", buildpath/"quiche/quiche.sh"
      system buildpath/"quiche/quiche.sh"
      (quiche/"deps/boringssl/src/lib").install Pathname.glob("target/release/build/*/out/build/lib{crypto,ssl}.a")
      rm buildpath/"quiche/quiche.sh"
    end

    if build.head?
      ENV["CFLAGS"] = "-march=native -O3 -pipe -flto=auto"
      ENV["CXXFLAGS"] = "-march=native -O3 -pipe -flto=auto"
      ENV["LDFLAGS"] = "-Wl,-O1 -Wl, -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %W[
      --disable-silent-rules
      --with-ssl=#{quiche}/deps/boringssl/src
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-default-ssl-backend=openssl
      --with-gssapi
      --with-librtmp
      --with-libssh2
      --without-libpsl
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}
      --with-quiche=#{quiche.parent}/target/release
      --enable-alt-svc
      --enable-ech
    ]

    args += if MacOS.version >= :ventura
      %w[
        --with-apple-idn
        --without-libidn2
      ]
    else
      %w[
        --without-apple-idn
        --with-libidn2
      ]
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
    lib.install quiche.parent/"target/release/libquiche.a"
    include.install quiche/"include/quiche.h"
    inreplace quiche_pc_path do |s|
      s.gsub!(/includedir=.+/, "includedir=#{include}")
      s.gsub!(/libdir=.+/, "libdir=#{lib}")
    end
    (lib/"pkgconfig").install quiche_pc_path
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli GSS-API HTTP2 HTTP3 IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS RTMP SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    with_env(PKG_CONFIG_PATH: lib/"pkgconfig") do
      system "pkgconf", "--cflags", "libcurl"
    end
  end
end
