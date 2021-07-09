#!/usr/bin/env python3

import lupa
import copy
from functools import partial
from pprint import pprint
import json
from collections import Counter

lua = lupa.LuaRuntime()

codes = {}        #contains the lua code per file. Keys are filenames
pycodes = {}    #contains the same code as list of strings. More useful for debugging.

BASEPATH = ""

def require(filename):
    """loads and executes the code of the given lua file"""
    filename = BASEPATH + filename
    #print("REQUIRE",filename)
    try: 
        with open(filename, "r") as file:
            codes[filename] = file.read()
            file.seek(0)
            pycodes[filename] = file.readlines()
            lua.execute(codes[filename])
    except Exception as e:
        raise
        print(e)


def dataToDict(lst, idKey, updateDict=None):
    """converts list of entries containing idKey (most likely 'Name') to a dict, where idKey is the key.
        If updateDict is a dict, it is updated in place. Otherwise a new dict is returned.
    """
    if updateDict:
        assert type(updateDict) == dict
        ret = updateDict
    else:
        ret = {}
    for e in lst:
        try:
            identifier = e.data[idKey]
            assert identifier not in ret, "duplicate "+str(idKey)+ ": "+str(identifier)
            ret[identifier] = e.data
        except Exception as e:
            raise
            print(e)
    return ret

def valuesToLua(value):
    #returns string of tuple
    if isinstance(value, tuple):
        values = value
    else:
        values = (value,)
    reprs = []
    for value in values:
        if isinstance(value, str):
            if "\n" in value or "'" in value or '"' in value:
                value = "[["+value+"]]"
            else:
                value = repr(value)
        elif isinstance(value, bool):
            value = repr(value).lower()
        else:
            value = repr(value)
        reprs.append(value)
    result = ", ".join(reprs)
    result = "("+result+")"
    return result


class ShipTemplate: 
    ships = [] 
    def __init__(self, data=None): 
        #print("init - Ein neues Schiff ist vom Stapel gelaufen") 
        if data:
            self.data = data 
        else:
            self.data = {} 
        self._changes = set() 
        ShipTemplate.ships.append(self) 
        for k in ["Beam", "BeamWeapon", "Tube", "WeaponStorage", "TubeDirection", "WeaponTubeExclusiveFor", "TubeSize", "BeamWeaponTurret"]: 
            self._create_dictsetter(k, hasSet=True) 
        for k in ["weaponTubeAllowMissle", "weaponTubeDisallowMissle"]:
            self._create_dictsetter(k, hasSet=False) 

    def setter(self, key, _, *values): 
        #print("set",key,values) 
        if key == "Name":
            pass
            #print("Name: "+values[0])
        assert key not in self._changes, "duplicate key: "+key
        if len(values) == 1:
            values = values[0]
        self.data[key] = values 
        self._changes.add(key) 
        return self 
         
    def dictsetter(self, first_key, _, second_key, *values): 
        #print("set2", first_key, second_key, values) 
        if first_key not in self.data: 
            self.data[first_key] = {} 
        if len(values) == 1:
            values = values[0]
        if second_key in self.data[first_key]:
            if not isinstance(self.data[first_key][second_key], list):
                self.data[first_key][second_key] = [self.data[first_key][second_key]]
            self.data[first_key][second_key].append(values)
        else:
            self.data[first_key][second_key] = values 
        return self 

    def adder(self, key, _, *values): 
        #print("add",key,values) 
        if key not in self.data: 
            self.data[key] = [] 
        self.data[key].append(values)
        return self 
                 
    def _create_dictsetter(self, key, hasSet=True): 
        if hasSet:
            prefix = "set"
        else:
            prefix = ""
        self.__dict__[prefix+key] = partial(self.dictsetter, key) 
         
    def call(self, name, _, *values): 
        #print("CALL", name, values) 
        return self 
 
    def copy(self,name): 
        #print("copy as", name) 
        cp = copy.deepcopy(self) 
        ShipTemplate.ships.append(cp)
        cp._changes.clear() 
        cp.setter("Name", cp, name) 
        return cp 

    def __getitem__(self,name): 
        #print("item",name) 
        if hasattr(self, name): 
            return getattr(self,name) 
        elif name.startswith("set"): 
            name = name.replace("set", "", 1) 
            return partial(self.setter, name) 
        elif name.startswith("add"): 
            name = name.replace("add", "", 1) 
            return partial(self.adder, name) 
        else: 
            return partial(self.call, name) 

    def toLua(self):
        code = "template = ShipTemplate()\n"
        for key, value in self.data.items():
            if isinstance(value, list):
                #adder
                for entry in value:
                    entry = valuesToLua(entry)
                    attrcode = f"add{key}{entry}"
                    code += "template:"+attrcode+"\n"
            elif isinstance(value, dict):
                #dictsetter
                if key[0].isupper():
                    #setter
                    attrcode = f"set{key}"
                else:
                    #function
                    attrcode = f"{key}"
                for entryKey, entryVal in value.items():
                    if isinstance(entryVal, tuple):
                        entry = (entryKey, ) + entryVal
                    else:
                        entry = (entryKey, entryVal)
                    entry = valuesToLua(entry)
                    code += f"template:{attrcode}{entry}\n"
            else:
                #setter
                entry = valuesToLua(value)
                attrcode = f"set{key}{entry}"
                code += "template:"+attrcode+"\n"
        code += "\n"
        return code


lua.execute("params = {...} ShipTemplate = params[1] require = params[2]", ShipTemplate, require)

lua.execute("function _(id) return id end")

def TubesToSides(ship):
    tubes = ship.get("Tubes",[0])[0]
    tube_config = {}
    for i in range(tubes):
        tube_config[i] = "front"
    for num,direction in ship.get("TubeDirection", {}).items():
        if direction < 0:
            direction = 360 + direction
        if direction < 45 or direction >= 315:
            tube_config[num] = "front"
        elif 45 <= direction < 135:
            tube_config[num] = "left"
        elif 135 <= direction < 225:
            tube_config[num] = "rear"
        elif 225 <= direction < 315:
            tube_config[num] = "right"
#    for num,size in ship.get("TubeSize", {}).items():
#        tube_config[num] = size +" "+ tube_config[num]
    for num,missile in ship.get("WeaponTubeExclusiveFor", {}).items():
        tube_config[num] += " ("+missile+")"
#    for num,missile in ship.get("weaponTubeDisallowMissle", {}).items():
#        if isinstance(missile, list):
#            missile = ", ".join(missile)
#        tube_config[num] += " (not for "+missile+")"
#    for num,missile in ship.get("weaponTubeAllowMissle", {}).items():
#        if isinstance(missile, list):
#            missile = ", ".join(missile)
#        tube_config[num] += " (and for "+missile+")"
    if not tube_config:
        tube_config = 0
    else:
        tube_config = Counter(tube_config.values())
        tube_config["total"] = tubes
    return tube_config

def BeamsToSides(ship):
    turrets = ship.get("BeamWeaponTurret", {})
    beams = ship.get("Beam", {})
    if not beams:
        beams = ship.get("BeamWeapon", {})
    if not beams:
        return 0
    beam_config = Counter()
    beam_dps = Counter()
    for n,beam in beams.items():
        direction = beam[1]
        dps = beam[4]/beam[3]
        d = ""
        if n in turrets:
            d += " turret"
        if direction < 0:
            direction = 360 + direction
        if direction < 45 or direction >= 315:
            beam_config["front"+d] += 1
            beam_dps["front"+d] += dps
        elif 45 <= direction < 135:
            beam_config["left"+d] += 1
            beam_dps["left"+d] += dps
        elif 135 <= direction < 225:
            beam_config["rear"+d] += 1
            beam_dps["rear"+d] += dps
        elif 225 <= direction < 315:
            beam_config["right"+d] += 1
            beam_dps["right"+d] += dps
    beams = {}
    for side,num in beam_config.items():
        if num:
            beams[side]= num #str(num) + " ("+str(round(beam_dps[side],2))+")"
    if not beams:
        beams = 0
    return beams 

def readShipTemplate(path):
    import pathlib
    global BASEPATH
    ShipTemplate.ships = []
    file = pathlib.Path(path)
    BASEPATH = str(file.parent)+"/"
    file = file.name
    require(file)
    ships = ShipTemplate.ships
    ships = dataToDict(ships, "Name")
    return ships

def print_pretty(ships):
    pprint(ships)

def print_json(ships):
    print(json.dumps(ships, indent=4))

def print_lua(ships):
    for ship in ships:
        print(ship.toLua())

def print_descr(ships):
    descr = []
    select_keys = ["Name", "Hull"]
    for _, ship in ships.items():
        d = {
            "Class": ship["Class"][0],
            "Subclass": ship["Class"][1],
        }
        for k in select_keys:
            d[k] = ship.get(k)
        shields = ship["Shields"]
        if isinstance(shields, tuple):
            if len(shields) == 2 and shields[0] == shields[1]:
                shields = str(shields[0]) + "*2"
        d["Shields"] = shields
        d["Beams"] = BeamsToSides(ship)
        d["Tubes"] = TubesToSides(ship)
        d["Reload Time"] = ship.get("Tubes",[0,0])[1]
        d["Weapon Storage"] = ship.get("WeaponStorage", 0)
        drive = []
        warp = ship.get("WarpSpeed")
        if warp:
            drive.append("Warp ("+str(warp)+")")
        if ship.get("JumpDrive"):
            drive.append("Jump")
            if "JumpDriveRange" in ship:
                drive[-1] += " ("+str(ship["JumpDriveRange"][1]//1000)+"u)"
        drive.append("Impulse ("+str(ship["Speed"][0])+")")
        d["Drive"] = ", ".join(drive)
        d["Turn Speed"] = ship["Speed"][1]
        d["Acceleration"] = ship["Speed"][2]
        d["Energy"] = ship.get("EnergyStorage", 1000)
        d["Repair Crew"] = ship.get("RepairCrewCount", 3)
        bay = ship.get("DockClasses")
        if not bay:
            d["Docking Bay"] = 0
        elif isinstance(bay, tuple):
            d["Docking Bay"] = ", ".join(bay)
        else:
            d["Docking Bay"] = bay 
        descr.append(d)
    print_json(descr)

def dictcompare(first,second):
    if not isinstance(first, dict) or not isinstance(second, dict):
        if first == second:
            return None, None, None, first
        else:
            return None, None, (first,second), None
    fk = set(first.keys())
    sk = set(second.keys())
    shared = fk.intersection(sk)
    added = fk - sk
    removed = sk - fk
    modified = {o: (first[o], second[o]) for o in shared if first[o] != second[o]}
    for name, items in modified.items():
        a,r,m,s = dictcompare(items[0], items[1])
        mod = {}
        if a:
            mod["added"] = a
        if r:
            mod["removed"] = r
        if m:
            mod["modified"] = m
        if s:
            mod["same"] = s
        modified[name] = mod
    same =  set( o for o in shared if first[o] == second[o])
    return added, removed, modified, same

if __name__ == "__main__":
    import sys
    if len(sys.argv) >= 2:
        file = sys.argv[1]
    else:
        file = "shipTemplates.lua"
    ships = readShipTemplate(file)
    if len(sys.argv) >= 3:
        file = sys.argv[2]
        ships2 = readShipTemplate(file)
        a,r,m,s = dictcompare(ships, ships2)
        ships = {
            "added":a,
            "removed":r,
            "modified":m,
            "same":s
        }
    
    print_descr(ships)




