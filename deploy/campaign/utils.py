def removeprefix(text, prefix):
    if text.startswith(prefix):
        return text[len(prefix):]
    return text

def removesuffix(text, suffix):
    if text.endswith(suffix):
        return text[:-len(suffix)]
    return text
