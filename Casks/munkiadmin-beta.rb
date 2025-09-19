cask "munkiadmin-beta" do
  version "1.10.0b6"
  sha256 "63b709338473551119424b55058e989b198ae72efb42d7fcd001cdb7c4152411"

  url "https://github.com/hjuutilainen/munkiadmin/releases/download/v#{version}/MunkiAdmin-#{version}.dmg",
      verified: "github.com/hjuutilainen/munkiadmin/"
  name "MunkiAdmin"
  desc "Tool to manage Munki repositories"
  homepage "https://hjuutilainen.github.io/munkiadmin/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)*)$/i)
  end

  conflicts_with cask: "munkiadmin"

  app "MunkiAdmin.app"

  zap trash: [
    "~/Library/Application Support/MunkiAdmin",
    "~/Library/Caches/com.hjuutilainen.MunkiAdmin",
    "~/Library/Logs/MunkiAdmin",
    "~/Library/Preferences/com.hjuutilainen.MunkiAdmin.plist",
  ]
end
