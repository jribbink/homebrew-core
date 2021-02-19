class Kumactl < Formula
  desc "Kuma control plane command-line utility"
  homepage "https://kuma.io/"
  url "https://github.com/kumahq/kuma/archive/1.0.8.tar.gz"
  sha256 "ed986cb996900d5428e3a6b84930686becc032cc07f9ed8e449dd93006c240a0"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "081bb135aed244b555ae2db51d6836863ac452762770e4de7427102e9d5696a2"
    sha256 cellar: :any_skip_relocation, big_sur:       "cc2b391f4b208e0d6e5ec7803672ce02e67dab7c04eccd5062deb891bddddf6b"
    sha256 cellar: :any_skip_relocation, catalina:      "db83514dc95c824c85793c03ebd6d9336c1da9e5e13cac986c84ebfb670bb140"
    sha256 cellar: :any_skip_relocation, mojave:        "2278328f6b727d1f50428149b090560e03602d5b899fa1be04184ad17666af7a"
  end

  depends_on "go" => :build

  def install
    srcpath = buildpath/"src/kuma.io/kuma"
    srcpath.install buildpath.children

    cd srcpath do
      system "make", "build/kumactl", "BUILD_INFO_VERSION=#{version}"
      bin.install Dir["build/artifacts-*/kumactl/kumactl"].first
    end

    output = Utils.safe_popen_read("#{bin}/kumactl", "completion", "bash")
    (bash_completion/"kumactl").write output

    output = Utils.safe_popen_read("#{bin}/kumactl", "completion", "zsh")
    (zsh_completion/"_kumactl").write output

    output = Utils.safe_popen_read("#{bin}/kumactl", "completion", "fish")
    (fish_completion/"kumactl.fish").write output
  end

  test do
    assert_match "Management tool for Kuma.", shell_output("#{bin}/kumactl")
    assert_match version.to_s, shell_output("#{bin}/kumactl version 2>&1")

    touch testpath/"config.yml"
    assert_match "Error: no resource(s) passed to apply",
    shell_output("#{bin}/kumactl apply -f config.yml 2>&1", 1)
  end
end
