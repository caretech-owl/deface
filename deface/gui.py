import base64
from collections import deque
from functools import partial
import io
from pathlib import Path
import sys
import os
from threading import Thread
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot
from time import sleep

import numpy as np
from deface.cli import main
from urllib.parse import urlparse


class Backend(QObject):
    statusUpdated = Signal(int, float, str, str, arguments=["taskId", "currentProgress", "frame", "outPath"])

    def __init__(self):
        super().__init__()
        self.queue = deque()
        self._thread = None
        self._running = True

    def _observer(self, task_id: int, progress: float, frame: np.array, out_path: str):
        from PIL import Image
        ext = out_path.rsplit(".", 1)[-1]
        image_base64 = ""
        image = Image.fromarray(frame)
        buffered = io.BytesIO()
        if ext == "jpg" or ext not in ("jpeg", "png"):
            ext = "jpeg"
        image.save(buffered, format=ext.upper())
        image_base64 = base64.b64encode(buffered.getvalue()).decode("utf-8")
        self.statusUpdated.emit(task_id, progress, f"data:image/{ext.lower()};base64," + image_base64, "file://" + out_path)
        return self._running

    def _run(self):
        task_id = 0
        while self.queue and self._running:
            cmd, in_path, out_path, skip_existing = self.queue.popleft()
            self.statusUpdated.emit(task_id, 0, "", out_path.as_uri())
            if skip_existing and out_path.exists():
                self.statusUpdated.emit(task_id, 1, "", out_path.as_uri())
            else:
                main(cmd, partial(self._observer, task_id))
                self.statusUpdated.emit(task_id, 1, "", out_path.as_uri())

            task_id += 1

    def stop(self):
        self._running = False

    @Slot(result=None)
    def start(self):
        self._thread = Thread(target=self._run).start()

    @Slot(str, str, float, float, int, int, int, float, result=str)
    def submit(
        self,
        file: str,
        replace_with: str,
        thresh: float,
        scale: float,
        offset_x: int,
        offset_y: int,
        mosaic_size: int,
        skip_existing: float,
    ):
        url = urlparse(file)
        assert url.scheme == "file"
        in_path = Path(url.path)
        out_path = Path(in_path.as_posix().replace(in_path.suffix, "_anonymized" + in_path.suffix))
        cmd = [
            "--replacewith",
            str(replace_with),
            "--thresh",
            str(thresh),
            "--mask-scale",
            str(scale),
            "--offset-x",
            str(offset_x),
            "--offset-y",
            str(offset_y),
            "--mosaicsize",
            str(mosaic_size),
            "--keep-audio",
            "--output",
            out_path.as_posix(),
            in_path.as_posix(),
        ]
        self.queue.append((cmd, in_path, out_path, skip_existing))
        return out_path.as_uri()


if __name__ == "__main__":
    sys.argv += ["--style", "Material"]
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    with open(f"{os.path.dirname(__file__)}/gui.ui.qml", "rt", encoding="utf-8") as f:
        engine.loadData(f.read().encode("utf-8"))
    if not engine.rootObjects():
        sys.exit(-1)
    exit_code = app.exec()
    print("Exiting...")
    backend.stop()
    del engine
    sys.exit(exit_code)
