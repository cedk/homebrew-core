class DmtxUtils < Formula
  desc "Read and write data matrix barcodes"
  homepage "https://github.com/dmtx/dmtx-utils"
  url "https://github.com/dmtx/dmtx-utils/archive/v0.7.5.tar.gz"
  sha256 "6fa365cd321609db40800f6b34a2387c0ac56ef4643f6101ac83cb762f5ce9ef"
  revision 4

  bottle do
    cellar :any
    sha256 "72b0245d54af619710bfa3550e970715cfbda41d149aeb4bd7e4e288a6560292" => :high_sierra
    sha256 "a58426de08b02d78e0b8889a69411a138ebed6f0966531f0a1752a14d5b509ed" => :sierra
    sha256 "9189a9c3db90dda83855437ed1da4a22c0668b0fd38f2cc0d4196826f6d18f94" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "imagemagick"
  depends_on "libdmtx"
  depends_on "libtool"

  resource "test_image12" do
    url "https://raw.githubusercontent.com/dmtx/libdmtx/ca9313f/test/rotate_test/images/test_image12.png"
    sha256 "683777f43ce2747c8a6c7a3d294f64bdbfee600d719aac60a18fcb36f7fc7242"
  end

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    testpath.install resource("test_image12")
    image = File.read("test_image12.png")
    assert_equal "9411300724000003", pipe_output("#{bin}/dmtxread", image, 0)
    system "/bin/dd", "if=/dev/random", "of=in.bin", "bs=512", "count=3"
    dmtxwrite_output = pipe_output("#{bin}/dmtxwrite", File.read("in.bin"), 0)
    dmtxread_output = pipe_output("#{bin}/dmtxread", dmtxwrite_output, 0)
    (testpath/"out.bin").atomic_write dmtxread_output
    assert_equal (testpath/"in.bin").sha256, (testpath/"out.bin").sha256
  end
end
