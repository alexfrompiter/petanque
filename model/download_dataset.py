from roboflow import Roboflow
rf = Roboflow(api_key="bYVsgz8qpufZfSd2UAB9")
project = rf.workspace("ptsi-aux-lazaristes").project("tipe-petank")
version = project.version(2)
dataset = version.download("yolov8")
