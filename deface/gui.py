import multiprocessing
from pathlib import Path
import sys


def main():
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlApplicationEngine
    from deface.gui_backend import Backend

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


if __name__ == "__main__":
    multiprocessing.freeze_support()
    main()
    
