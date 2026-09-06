# frozen_string_literal: true

class Totsuka < Formula
  desc "Local-first orchestrator that dispatches dev tasks to AI coding agents"
  homepage "https://github.com/tomoya-k31/totsuka"

  # `version` is declared before `url` so the URL can be derived from it. The
  # release workflow then only ever rewrites `version` and `sha256`, and the
  # URL — the one string carrying the tag twice — cannot drift from the tag.
  # `brew audit --strict` calls the explicit `version` redundant with the one
  # it scans out of the URL; that is the trade taken here, deliberately, in
  # exchange for the automation never touching a URL string.
  version "0.6.4"
  url "https://github.com/tomoya-k31/totsuka/releases/download/v#{version}/totsuka-v#{version}-macos-universal.tar.gz"
  sha256 "e163ac9715b53d7b309862d15042cad7697af80940d60d54055d83cf67724a41"
  license "MIT"

  # macOS only: the notifier plugin drives osascript, secrets default to the
  # Keychain, and no Linux artifact is built.
  depends_on :macos

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    # This layout is load-bearing, not a style choice. totsuka locates its
    # bundled plugins by probing, relative to the directory holding the running
    # executable — both as invoked and symlink-resolved, because current_exe()
    # does not resolve symlinks on macOS:
    #
    #   1. <exe dir>/plugins
    #   2. <exe dir>/../libexec/totsuka/plugins
    #
    # Real binary in bin/ and plugins in libexec/totsuka/ makes (2) resolve
    # from both $(brew --prefix)/bin/totsuka and the Cellar path, with no flag
    # and no path from the user.
    #
    # Do NOT flatten the plugins next to the binary to hit (1): bin/ is linked
    # into the Homebrew prefix, so a `plugins` directory there would be linked
    # in alongside it.
    bin.install "totsuka"
    (libexec/"totsuka").install "plugins"
    doc.install "README.md", "LICENSE"

    # `totsuka completion <shell>` writes to stdout and is short-circuited
    # before any config or environment is resolved, so it is safe to run here.
    generate_completions_from_executable(bin/"totsuka", "completion")
  end

  def caveats
    <<~CAVEATS
      totsuka orchestrates agents but does not bundle one. Install herdr (0.7.5
      or newer) or orca first, then run:

        totsuka setup

      setup never handles secret values — it prints one ready-to-paste command
      per secret and finishes by running `totsuka doctor`.
    CAVEATS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/totsuka --version")

    # The plugins in libexec must be discoverable from the installed layout
    # with no path and no flag. This is the same command `totsuka setup` runs,
    # and the same one the release workflow smoke-tests against the tarball —
    # it is the only check that the install layout above still matches what the
    # binary probes for.
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    ENV["XDG_DATA_HOME"]   = testpath/"data"
    ENV["XDG_STATE_HOME"]  = testpath/"state"
    ENV["XDG_CACHE_HOME"]  = testpath/"cache"
    system bin/"totsuka", "plugin", "install", "--bundled", "--all", "--yes"
    assert_match "github", shell_output("#{bin}/totsuka plugin list --json")
  end
end
