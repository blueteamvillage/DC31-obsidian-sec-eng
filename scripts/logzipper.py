"""
This script assumes log directories are <hostname>/<log type>/<log name>.json.gz
"""
import glob
import pathlib
import shutil

__LOG_DIR = "/tmp/btv_logs"


pathlib.Path("../logs").mkdir(exist_ok=True)
for logFile in glob.glob(f"{__LOG_DIR}/*/*/*.json.gz"):
    logFileSplit = logFile.split("/")
    hostname = logFileSplit[3]
    logType = logFileSplit[4]

    pathlib.Path(f"../logs/{hostname}").mkdir(exist_ok=True)
    print(logFile)
    with open(logFile, "rb") as sourceFile, open(
        f"../logs/{hostname}/{logType}.json.gz", "wb"
    ) as hostLogFile:
        shutil.copyfileobj(sourceFile, hostLogFile)


for logFile in glob.glob(f"{__LOG_DIR}/*/*/*.json.gz"):
    logFileSplit = logFile.split("/")
    hostname = logFileSplit[3]
    logType = logFileSplit[4]

    pathlib.Path(f"../logs/{logType}").mkdir(exist_ok=True)
    print(logFile)
    with open(logFile, "rb") as sourceFile, open(
        f"../logs/{logType}/{hostname}.json.gz", "wb"
    ) as hostLogFile:
        shutil.copyfileobj(sourceFile, hostLogFile)
