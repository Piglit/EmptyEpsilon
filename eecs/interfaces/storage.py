"""Use this interface to store and restore data."""
import pickle
import os

def _create_dir_path(subdir):
	path = "data/"
	if subdir:
		path += subdir
	if not path.endswith("/"):
		path += "/"
	return path

def storeInfo(data, filename, subdir=None):
	path = _create_dir_path(subdir) 
	os.makedirs(path, exist_ok=True)
	path += filename
	with open(path, "wb") as file:
		pickle.dump(data, file)

def loadInfo(filename, subdir=None):
	path = _create_dir_path(subdir) + filename
	try:
		with open(path, "rb") as file:
			return pickle.load(file)
	except:
		return None


