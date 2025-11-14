from openai_harmony import load_harmony_encoding

# GPT-OSS에서 사용하는 Harmony 인코딩 이름
enc = load_harmony_encoding("HarmonyGptOss")
print("Loaded encoding:", enc)