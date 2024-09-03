from collections import deque
from functools import partial
from pathlib import Path
import sys
from threading import Thread
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot

import numpy as np
from deface.cli import main
from urllib.parse import urlparse, unquote
from urllib.request import url2pathname


class Backend(QObject):
    statusUpdated = Signal(int, float, arguments=["taskId", "currentProgress"])

    def __init__(self):
        super().__init__()
        self.queue = deque()
        self._thread = None
        self._running = True

    def _observer(self, task_id: int, progress: float, frame: np.array, out_path: str):
        self.statusUpdated.emit(task_id, progress)
        return self._running

    def _run(self):
        task_id = 0
        while self.queue and self._running:
            cmd, in_path, out_path, skip_existing = self.queue.popleft()
            self.statusUpdated.emit(task_id, 0)
            if skip_existing and out_path.exists():
                self.statusUpdated.emit(task_id, 1)
            else:
                main(cmd, partial(self._observer, task_id))
                self.statusUpdated.emit(task_id, 1)

            task_id += 1

    def stop(self):
        self._running = False

    @Slot(result=None)
    def start(self):
        self._thread = Thread(target=self._run).start()

    @Slot(str, str, float, float, int, int, int, float, str, result=str)
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
        audio: str = str,
    ):
        file_path = url2pathname(unquote(urlparse(file).path))
        in_path = Path(file_path).resolve()
        out_path = Path(file_path.replace(in_path.suffix, "_anonymized" + in_path.suffix)).resolve()
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
            "--audio",
            str(audio),
            "--output",
            str(out_path),
            str(in_path),
        ]
        self.queue.append((cmd, in_path, out_path, skip_existing))
        return out_path.as_uri()


if __name__ == "__main__":
    sys.argv += ["--style", "Material"]
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    backend = Backend()
    app_root_path = Path(__file__).parent
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("appRoot", app_root_path.as_uri())
    qml_file = app_root_path / 'data/gui.ui.qml'
    engine.load(qml_file.as_uri())
    if not engine.rootObjects():
        sys.exit(-1)
    exit_code = app.exec()
    backend.stop()
    del engine
    sys.exit(exit_code)
