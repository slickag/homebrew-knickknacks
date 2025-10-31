cask "progressive-downloader@dev" do
  version "8.4"
  sha256 :no_check

  url "https://www.macpsd.net/update/development/PSD.dmg"
  name "Progressive Downloader"
  desc "Download manager"
  homepage "https://www.macpsd.net/"

  livecheck do
    url :homepage
    regex(%r{href=.*?/(\d+(?:\.\d+)+)/PSD[^"' >]*?\.dmg}i)
  end

  auto_updates true
  conflicts_with cask: "progressive-downloader"
  depends_on macos: ">= :big_sur"

  app "Progressive Downloader.app"

  zap trash: [
    "~/Library/Application Support/Progressive Downloader Data",
    "~/Library/Caches/com.PS.Downloader",
    "~/Library/Caches/com.PS.PSD",
    "~/Library/Containers/com.PS.Downloader",
    "~/Library/Containers/com.PS.HashCheck",
    "~/Library/Containers/com.PS.PSD",
    "~/Library/Preferences/com.PS.PSD.plist",
  ]
end
