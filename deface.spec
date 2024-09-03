# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['deface/deface.py'],
    pathex=[],
    binaries=[],
    datas=[("deface/data/centerface.onnx", "deface/data"), ("deface/data/defaced.svg", "deface/data"), ("deface/data/delete.svg", "deface/data")],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='deface',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='deface',
)
