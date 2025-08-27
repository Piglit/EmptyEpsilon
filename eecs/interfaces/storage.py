"""Use this interface to store and restore data."""
import pickle
import os
import shutil

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
		if not os.path.exists(path):
			return None
		with open(path, "rb") as file:
			return pickle.load(file)
	except:
		return None

def delete(filename, subdir):
	path = _create_dir_path(subdir)
	shutil.rmtree(path, ignore_errors=True)



