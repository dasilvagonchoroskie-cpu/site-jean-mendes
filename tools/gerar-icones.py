# Gera os ícones do aplicativo (site e painel) para a pasta indicada.
# Uso: python3 tools/gerar-icones.py _site
import os
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

DEST = sys.argv[1]
FONTES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf",
]
OURO = [(0.0, (255, 243, 184)), (0.3, (246, 213, 106)), (0.55, (197, 138, 34)), (0.75, (244, 213, 120)), (1.0, (140, 92, 16))]


def fonte(tam):
    for f in FONTES:
        if os.path.exists(f):
            return ImageFont.truetype(f, tam)
    return ImageFont.load_default(tam)


def fundo(S, painel):
    topo, base = ((10, 116, 128), (2, 31, 36)) if not painel else ((5, 85, 95), (2, 22, 26))
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    for y in range(S):
        t = y / (S - 1)
        d.line([(0, y), (S, y)], fill=tuple(int(topo[i] + (base[i] - topo[i]) * t) for i in range(3)))
    brilho = Image.new("L", (S, S), 0)
    ImageDraw.Draw(brilho).ellipse((-S * 0.3, -S * 0.4, S * 0.7, S * 0.5), fill=120)
    brilho = brilho.filter(ImageFilter.GaussianBlur(S // 5))
    img.paste(Image.new("RGB", (S, S), (31, 224, 224)), (0, 0), brilho)
    return img


def gradiente_ouro(S):
    g = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(g)
    for y in range(S):
        t = min(max((y - S * 0.08) / (S * 0.84), 0), 1)
        for (a, ca), (b, cb) in zip(OURO, OURO[1:]):
            if a <= t <= b:
                k = (t - a) / (b - a)
                d.line([(0, y), (S, y)], fill=tuple(int(ca[i] + (cb[i] - ca[i]) * k) for i in range(3)))
                break
    return g


def icone(S, painel):
    img = fundo(S, painel)
    letras = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(letras)
    d.text((S / 2, S * 0.27), "J", font=fonte(int(S * 0.46)), fill=255, anchor="mm")
    d.text((S / 2, S * 0.70), "M", font=fonte(int(S * 0.50)), fill=255, anchor="mm")
    sombra = letras.filter(ImageFilter.GaussianBlur(S * 0.012)).point(lambda v: int(v * 0.7))
    deslocada = Image.new("L", (S, S), 0)
    deslocada.paste(sombra, (0, int(S * 0.018)))
    img.paste(Image.new("RGB", (S, S), (1, 18, 22)), (0, 0), deslocada)
    img.paste(gradiente_ouro(S), (0, 0), letras)
    if painel:
        ImageDraw.Draw(img).rounded_rectangle((S * 0.26, S * 0.90, S * 0.74, S * 0.93), radius=S * 0.015, fill=(232, 185, 74))
    return img


for pasta, painel in (("icons", False), ("painel/icons", True)):
    destino = os.path.join(DEST, pasta)
    os.makedirs(destino, exist_ok=True)
    grande = icone(1024, painel)
    for nome, tam in (("icon-512.png", 512), ("icon-192.png", 192), ("apple-touch-icon.png", 180)):
        grande.resize((tam, tam), Image.LANCZOS).save(os.path.join(destino, nome), optimize=True)
print("icones gerados em", DEST)

def previa():
    W, H = 1200, 630
    base = fundo(W, False).crop((0, 285, W, 285 + H))
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    d.text((235, 180), "J", font=fonte(190), fill=255, anchor="mm")
    d.text((235, 425), "M", font=fonte(205), fill=255, anchor="mm")
    d.text((805, 235), "ADVOGADO", font=fonte(40), fill=255, anchor="mm")
    d.text((805, 325), "Jean Mendes", font=fonte(84), fill=255, anchor="mm")
    d.text((805, 415), "OAB-GO 58.257 · Goiatuba (GO)", font=fonte(34), fill=255, anchor="mm")
    sombra = mask.filter(ImageFilter.GaussianBlur(5)).point(lambda v: int(v * 0.7))
    desl = Image.new("L", (W, H), 0)
    desl.paste(sombra, (0, 6))
    base.paste(Image.new("RGB", (W, H), (1, 18, 22)), (0, 0), desl)
    base.paste(gradiente_ouro(W).resize((W, H)), (0, 0), mask)
    ImageDraw.Draw(base).line([(445, 170), (445, 460)], fill=(232, 185, 74), width=3)
    base.save(os.path.join(DEST, "icons", "og.png"), optimize=True)


previa()

