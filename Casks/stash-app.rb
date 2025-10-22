cask "stash-app" do
  version "0.29.0"
  sha256 "a853cac6de2bbfd534e54d556b90312a960c5094a51e38a250f9a44f3121bb7f"

  url "https://github.com/stashapp/stash/releases/download/v#{version}/Stash.app.zip",
      verified: "github.com/stashapp/stash/"
  name "Stash"
  desc "Organizer for your porn, written in Go"
  homepage "https://stashapp.cc/"

  depends_on macos: ">= :big_sur"

  app "Stash.app"

  # zap trash: [
  # ]
end
