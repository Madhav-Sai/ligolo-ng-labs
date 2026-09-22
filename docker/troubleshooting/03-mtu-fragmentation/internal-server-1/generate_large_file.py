with open("/srv/www/large-file.bin", "wb") as f:
    f.write(b"A" * 500_000)
