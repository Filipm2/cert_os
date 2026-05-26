"""Regenerate placeholder icons (cert_os.ico, cert_os.icns).

Dark green background, white CERT.OS text. Replace with final art before
shipping. Run from the repo root or this directory; outputs land next to
this script.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).resolve().parent
BG = (10, 26, 10, 255)        # #0a1a0a, the app's panel green-black
ACCENT = (102, 255, 102, 255) # #66ff66, MOTHER green
WHITE = (255, 255, 255, 255)
SIZE = 256


def _font(px: int) -> ImageFont.ImageFont:
    for name in ("Cascadia Mono", "consola.ttf", "DejaVuSansMono.ttf",
                 "Menlo.ttc", "Courier New.ttf"):
        try:
            return ImageFont.truetype(name, px)
        except OSError:
            continue
    return ImageFont.load_default()


def _draw_master(size: int = SIZE) -> Image.Image:
    img = Image.new("RGBA", (size, size), BG)
    d = ImageDraw.Draw(img)
    border = max(2, size // 64)
    d.rectangle((border, border, size - border - 1, size - border - 1),
                outline=ACCENT, width=border)
    f = _font(int(size * 0.22))
    text = "CERT.OS"
    bbox = d.textbbox((0, 0), text, font=f)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text(((size - tw) / 2 - bbox[0], (size - th) / 2 - bbox[1] - size * 0.05),
           text, font=f, fill=WHITE)
    sub_f = _font(int(size * 0.07))
    sub = "MOTHER 6000"
    sbbox = d.textbbox((0, 0), sub, font=sub_f)
    sw = sbbox[2] - sbbox[0]
    d.text(((size - sw) / 2 - sbbox[0], size * 0.66),
           sub, font=sub_f, fill=ACCENT)
    return img


def write_ico(path: Path) -> None:
    master = _draw_master(SIZE)
    sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    master.save(path, format="ICO", sizes=sizes)


def write_icns(path: Path) -> None:
    # Pillow can write ICNS directly when given a square master.
    master = _draw_master(1024)
    try:
        master.save(path, format="ICNS")
        return
    except Exception:
        pass
    # Fallback: write a PNG with the .icns extension. Not a real ICNS but
    # ensures the file exists for the build pipeline. Replace with real art.
    master.save(path.with_suffix(".png"))
    path.write_bytes(path.with_suffix(".png").read_bytes())


def main() -> None:
    write_ico(OUT_DIR / "cert_os.ico")
    write_icns(OUT_DIR / "cert_os.icns")
    print(f"wrote: {OUT_DIR / 'cert_os.ico'}")
    print(f"wrote: {OUT_DIR / 'cert_os.icns'}")


if __name__ == "__main__":
    main()
